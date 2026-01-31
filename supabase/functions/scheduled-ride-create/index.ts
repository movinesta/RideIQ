import { handleOptions } from '../_shared/cors.ts';
import { createAnonClient, requireUser } from '../_shared/supabase.ts';
import { consumeRateLimit } from '../_shared/rateLimit.ts';
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
  scheduled_at?: string; // ISO string
  preferences?: Record<string, unknown>;
};

function isFiniteNumber(v: unknown): v is number {
  return typeof v === 'number' && Number.isFinite(v);
}

Deno.serve((req) =>
  withRequestContext('scheduled-ride-create', req, async (ctx) => {
    const preflight = handleOptions(req);
    if (preflight) return preflight;

    const { user, error } = await requireUser(req);
    if (error || !user) return errorJson('Unauthorized', 401, 'UNAUTHORIZED', undefined, ctx.headers);

    let body: Body;
    try {
      body = (await req.json()) as Body;
    } catch {
      return errorJson('Invalid JSON body', 400, 'INVALID_JSON', undefined, ctx.headers);
    }

    if (!isFiniteNumber(body.pickup_lat) || !isFiniteNumber(body.pickup_lng)) {
      return errorJson('Missing pickup_lat/pickup_lng', 400, 'VALIDATION_ERROR', undefined, ctx.headers);
    }
    if (!isFiniteNumber(body.dropoff_lat) || !isFiniteNumber(body.dropoff_lng)) {
      return errorJson('Missing dropoff_lat/dropoff_lng', 400, 'VALIDATION_ERROR', undefined, ctx.headers);
    }
    if (!body.scheduled_at || typeof body.scheduled_at !== 'string') {
      return errorJson('Missing scheduled_at', 400, 'VALIDATION_ERROR', undefined, ctx.headers);
    }

    const when = new Date(body.scheduled_at);
    if (Number.isNaN(when.getTime())) {
      return errorJson('scheduled_at must be a valid ISO date string', 400, 'VALIDATION_ERROR', undefined, ctx.headers);
    }

    // Guardrails:
    // - require >= 5 minutes in the future (avoid race with cron, allow user corrections)
    // - restrict max scheduling window (keep operations predictable)
    const minMs = 5 * 60 * 1000;
    const maxMs = 14 * 24 * 60 * 60 * 1000; // 14 days
    const now = Date.now();
    if (when.getTime() < now + minMs) {
      return errorJson('scheduled_at must be at least 5 minutes in the future', 400, 'VALIDATION_ERROR', undefined, ctx.headers);
    }
    if (when.getTime() > now + maxMs) {
      return errorJson('scheduled_at is too far in the future (max 14 days)', 400, 'VALIDATION_ERROR', undefined, ctx.headers);
    }

    // Rate limit: protect from abuse (fail-open by design in helper)
    const rl = await consumeRateLimit({
      key: `scheduled_ride_create:${user.id}`,
      windowSeconds: 60,
      limit: 10,
    });
    if (!rl.allowed) {
      return errorJson('Too many requests. Please try again later.', 429, 'RATE_LIMITED', undefined, ctx.headers);
    }

    const supa = createAnonClient(req);

    // Validate product_code (if provided) exists
    const productCode = body.product_code ?? 'standard';
    {
      const { data: prod, error: prodErr } = await supa.from('ride_products').select('code').eq('code', productCode).maybeSingle();
      if (prodErr) {
        // If ride_products isn't accessible, do not block core flow; fallback to provided code.
        ctx.log('ride_products validation skipped', { error: String(prodErr.message ?? prodErr) });
      } else if (!prod) {
        return errorJson('Invalid product_code', 400, 'VALIDATION_ERROR', undefined, ctx.headers);
      }
    }

    // Pending limits (per day + total)
    const dayStart = new Date(when);
    dayStart.setHours(0, 0, 0, 0);
    const dayEnd = new Date(dayStart);
    dayEnd.setDate(dayEnd.getDate() + 1);

    const { count: pendingTotal, error: cErr1 } = await supa
      .from('scheduled_rides')
      .select('id', { count: 'exact', head: true })
      .eq('rider_id', user.id)
      .eq('status', 'pending');

    if (cErr1) {
      ctx.log('pending total count error (ignored)', { error: String(cErr1.message ?? cErr1) });
    } else if ((pendingTotal ?? 0) >= 20) {
      return errorJson('Too many pending scheduled rides (max 20)', 400, 'VALIDATION_ERROR', undefined, ctx.headers);
    }

    const { count: pendingToday, error: cErr2 } = await supa
      .from('scheduled_rides')
      .select('id', { count: 'exact', head: true })
      .eq('rider_id', user.id)
      .eq('status', 'pending')
      .gte('scheduled_at', dayStart.toISOString())
      .lt('scheduled_at', dayEnd.toISOString());

    if (cErr2) {
      ctx.log('pending today count error (ignored)', { error: String(cErr2.message ?? cErr2) });
    } else if ((pendingToday ?? 0) >= 5) {
      return errorJson('Too many scheduled rides for that day (max 5)', 400, 'VALIDATION_ERROR', undefined, ctx.headers);
    }
    // Service area: ensure pickup is within an active operating area
    let serviceAreaId: string | null = null;
    {
      const { data: areaRows, error: areaErr } = await supa.rpc('resolve_service_area', {
        p_lat: body.pickup_lat,
        p_lng: body.pickup_lng,
      });

      if (areaErr) {
        ctx.error('service_area.resolve_failed', { err: areaErr.message });
        return errorJson('Unable to resolve service area', 500, 'SERVICE_AREA_ERROR', undefined, ctx.headers);
      }

      const area = Array.isArray(areaRows) ? areaRows[0] : null;
      if (!area?.id) {
        return errorJson('Pickup location is outside supported service areas', 400, 'OUT_OF_SERVICE_AREA', undefined, ctx.headers);
      }

      serviceAreaId = area.id;
    }




    const insert = {
      rider_id: user.id,
      pickup_lat: body.pickup_lat,
      pickup_lng: body.pickup_lng,
      dropoff_lat: body.dropoff_lat,
      dropoff_lng: body.dropoff_lng,
      pickup_address: body.pickup_address ?? null,
      dropoff_address: body.dropoff_address ?? null,
      product_code: productCode,
      scheduled_at: when.toISOString(),
      service_area_id: serviceAreaId,
    };

    const { data, error: dbErr } = await supa
      .from('scheduled_rides')
      .insert(insert)
      .select('*')
      .single();

    if (dbErr) {
      ctx.error('db.insert_failed', { err: dbErr.message });
      return errorJson('Failed to create scheduled ride', 500, 'DB_ERROR', undefined, ctx.headers);
    }

    ctx.log('scheduled_ride.created', { id: data?.id, scheduled_at: data?.scheduled_at });

    return json({ scheduled_ride: data }, 200, ctx.headers);
  }),
);
