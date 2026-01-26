import { handleOptions } from '../_shared/cors.ts';
import { createAnonClient, requireUser } from '../_shared/supabase.ts';
import { buildRateLimitHeaders, consumeRateLimit, getClientIp } from '../_shared/rateLimit.ts';
import { errorJson, json } from '../_shared/json.ts';
import { withRequestContext } from '../_shared/requestContext.ts';

type Body = {
  pickup_lat?: number;
  pickup_lng?: number;
  dropoff_lat?: number;
  dropoff_lng?: number;
  pickup_address?: string | null;
  dropoff_address?: string | null;
  product_code?: string;
  scheduled_at?: string | null;
  source?: string;
  preferences?: Record<string, unknown>;
};

function isFiniteNumber(x: unknown): x is number {
  return typeof x === 'number' && Number.isFinite(x);
}

function clampString(v: unknown, maxLen: number): string | null {
  if (typeof v !== 'string') return null;
  const t = v.trim();
  if (!t) return null;
  return t.length > maxLen ? t.slice(0, maxLen) : t;
}

function normalizeProductCode(v: unknown): string {
  if (typeof v !== 'string') return 'standard';
  const t = v.trim().toLowerCase();
  return t ? t.slice(0, 32) : 'standard';
}

function normalizeSource(v: unknown): string {
  if (typeof v !== 'string') return 'whatsapp';
  const t = v.trim().toLowerCase();
  if (t === 'whatsapp' || t === 'callcenter') return t;
  return 'whatsapp';
}

function parseOptionalIsoDate(v: unknown): string | null {
  if (typeof v !== 'string') return null;
  const t = v.trim();
  if (!t) return null;
  const d = new Date(t);
  if (Number.isNaN(d.getTime())) return null;
  return d.toISOString();
}

function validateLatLng(lat: number, lng: number) {
  if (lat < -90 || lat > 90) throw new Error('Invalid latitude');
  if (lng < -180 || lng > 180) throw new Error('Invalid longitude');
}

Deno.serve((req) =>
  withRequestContext('ride-intent-create', req, async (ctx) => {
    const opt = handleOptions(req);
    if (opt) return opt;

    if (req.method !== 'POST') {
      return errorJson('Method not allowed', 405, 'METHOD_NOT_ALLOWED');
    }

    const { user, error: authErr } = await requireUser(req);
    if (!user) {
      return errorJson(String(authErr ?? 'Unauthorized'), 401, 'UNAUTHORIZED');
    }

    // Rate limit per user + IP (protects from accidental spam)
    const ip = getClientIp(req);
    const rl = await consumeRateLimit({
      key: `ride_intent_create:${user.id}:${ip ?? 'noip'}`,
      windowSeconds: 60,
      limit: 20,
    });
    if (!rl.allowed) {
      return json(
        { error: 'Rate limit exceeded', code: 'RATE_LIMITED', remaining: rl.remaining, reset_at: rl.resetAt },
        429,
        buildRateLimitHeaders({ limit: 20, remaining: rl.remaining, resetAt: rl.resetAt }),
      );
    }

    let body: Body;
    try {
      body = (await req.json()) as Body;
    } catch {
      return errorJson('Invalid JSON body', 400, 'INVALID_JSON');
    }

    if (!isFiniteNumber(body.pickup_lat) || !isFiniteNumber(body.pickup_lng)) {
      return errorJson('pickup_lat and pickup_lng are required numbers', 400, 'VALIDATION_ERROR');
    }
    if (!isFiniteNumber(body.dropoff_lat) || !isFiniteNumber(body.dropoff_lng)) {
      return errorJson('dropoff_lat and dropoff_lng are required numbers', 400, 'VALIDATION_ERROR');
    }

    try {
      validateLatLng(body.pickup_lat, body.pickup_lng);
      validateLatLng(body.dropoff_lat, body.dropoff_lng);
    } catch (e) {
      return errorJson(String(e), 400, 'VALIDATION_ERROR');
    }

    const supa = createAnonClient(req);

    // Resolve service area from pickup point (Iraq multi-city readiness)
    const { data: area, error: areaErr } = await supa.rpc('resolve_service_area', {
      p_lat: body.pickup_lat,
      p_lng: body.pickup_lng,
    });
    if (areaErr) return errorJson(areaErr.message, 400, 'DB_ERROR');
    const picked = Array.isArray(area) ? area[0] : null;
    if (!picked?.id) {
      return errorJson('Pickup is outside supported service areas', 400, 'OUTSIDE_SERVICE_AREA');
    }

    const payload = {
      rider_id: user.id,
      pickup_lat: body.pickup_lat,
      pickup_lng: body.pickup_lng,
      dropoff_lat: body.dropoff_lat,
      dropoff_lng: body.dropoff_lng,
      pickup_address: clampString(body.pickup_address, 240),
      dropoff_address: clampString(body.dropoff_address, 240),
      service_area_id: picked.id as string,
      product_code: normalizeProductCode(body.product_code),
      scheduled_at: parseOptionalIsoDate(body.scheduled_at),
      source: normalizeSource(body.source),
      status: 'new',
      preferences:
        body.preferences && typeof body.preferences === 'object' && !Array.isArray(body.preferences)
          ? body.preferences
          : {},
    };

    const { data, error } = await supa
      .from('ride_intents')
      .insert(payload)
      .select('id,created_at,service_area_id,product_code,source,status')
      .single();

    if (error) {
      ctx.error('db.insert_failed', { err: error.message });
      return errorJson('Failed to create ride intent', 400, 'DB_ERROR');
    }

    return json(
      {
        intent: data,
        service_area: { id: picked.id, name: picked.name, governorate: picked.governorate },
        rate_limit: { remaining: rl.remaining, reset_at: rl.resetAt },
      },
      200,
      ctx.headers,
    );
  }),
);
