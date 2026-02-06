import { handleOptions } from '../_shared/cors.ts';
import { createAnonClient, requireUser } from '../_shared/supabase.ts';
import { buildRateLimitHeaders, consumeRateLimit, getClientIp } from '../_shared/rateLimit.ts';
import { errorJson, json } from '../_shared/json.ts';
import { withRequestContext } from '../_shared/requestContext.ts';
import { rideIntentCreateSchema } from '../_shared/schemas.ts';
import { ZodError } from 'npm:zod@3.23.8';
import {
  expiresIso,
  fraudEnforceActionBestEffort,
  fraudGetActiveActionBestEffort,
  fraudLogEventBestEffort,
  fraudOpenCaseBestEffort,
} from '../_shared/fraud.ts';

const ACTION_BLOCK = 'block_ride_intent_create';

Deno.serve((req) =>
  withRequestContext('ride-intent-create', req, async (ctx) => {
    const opt = handleOptions(req);
    if (opt) return opt;

    if (req.method !== 'POST') {
      return errorJson('Method not allowed', 405, 'METHOD_NOT_ALLOWED', undefined, ctx.headers);
    }

    const { user, error: authErr } = await requireUser(req);
    if (!user) {
      return errorJson(String(authErr ?? 'Unauthorized'), 401, 'UNAUTHORIZED', undefined, ctx.headers);
    }

    ctx.setUserId(user.id);

    // Enforcement gate (best-effort; fails open)
    const active = await fraudGetActiveActionBestEffort({ actionType: ACTION_BLOCK, subjectKind: 'user', subjectId: user.id });
    if (active) {
      await fraudLogEventBestEffort({
        reason: 'fake_account_blocked',
        subjectKind: 'user',
        subjectId: user.id,
        severity: 2,
        score: 20,
        metadata: { action_type: ACTION_BLOCK, action_id: active.id, expires_at: active.expires_at },
        req,
      });
      return json(
        { error: 'Temporarily blocked', code: 'BLOCKED', retry_at: active.expires_at ?? null },
        429,
        {
          ...ctx.headers,
          ...(active.expires_at
            ? {
                'Retry-After': String(
                  Math.max(1, Math.ceil((new Date(active.expires_at).getTime() - Date.now()) / 1000)),
                ),
              }
            : {}),
        },
      );
    }

    // Rate limit per user + IP (protects from accidental spam)
    const ip = getClientIp(req);
    const rl = await consumeRateLimit({
      key: `ride_intent_create:${user.id}:${ip ?? 'noip'}`,
      windowSeconds: 60,
      limit: 20,
    });
    if (!rl.allowed) {
      const expiresAt = expiresIso(120);
      await fraudLogEventBestEffort({
        reason: 'fake_account_ride_intent_velocity',
        subjectKind: 'user',
        subjectId: user.id,
        severity: 3,
        score: 40,
        metadata: { limit: 20, window_seconds: 60, ip_present: !!ip },
        req,
      });
      await fraudOpenCaseBestEffort({
        reason: 'fake_account_spam',
        subjectKind: 'user',
        subjectId: user.id,
        severity: 3,
        metadata: { source: 'ride-intent-create', limit: 20, window_seconds: 60 },
      });
      await fraudEnforceActionBestEffort({
        actionType: ACTION_BLOCK,
        reason: 'velocity',
        subjectKind: 'user',
        subjectId: user.id,
        severity: 3,
        expiresAt,
        metadata: { limit: 20, window_seconds: 60 },
      });
      return json(
        { error: 'Rate limit exceeded', code: 'RATE_LIMITED', remaining: rl.remaining, reset_at: rl.resetAt },
        429,
        { ...ctx.headers, ...buildRateLimitHeaders({ limit: 20, remaining: rl.remaining, resetAt: rl.resetAt }) },
      );
    }

    // Parse and validate input with Zod - REJECTS invalid inputs with clear errors
    let input: ReturnType<typeof rideIntentCreateSchema.parse>;
    try {
      const rawBody = await req.json();
      input = rideIntentCreateSchema.parse(rawBody);
    } catch (e) {
      if (e instanceof ZodError) {
        const firstIssue = e.issues[0];
        const field = firstIssue?.path.join('.') || 'unknown';
        const message = firstIssue?.message || 'Validation failed';
        return errorJson(`${field}: ${message}`, 400, 'VALIDATION_ERROR', { issues: e.issues }, ctx.headers);
      }
      if (e instanceof SyntaxError) {
        return errorJson('Invalid JSON body', 400, 'INVALID_JSON', undefined, ctx.headers);
      }
      throw e;
    }

    const supa = createAnonClient(req);

    // Resolve service area from pickup point (Iraq multi-city readiness)
    const { data: area, error: areaErr } = await supa.rpc('resolve_service_area', {
      p_lat: input.pickup_lat,
      p_lng: input.pickup_lng,
    });
    if (areaErr) return errorJson(areaErr.message, 400, 'DB_ERROR', undefined, ctx.headers);
    const picked = Array.isArray(area) ? area[0] : null;
    if (!picked?.id) {
      return errorJson('Pickup is outside supported service areas', 400, 'OUTSIDE_SERVICE_AREA', undefined, ctx.headers);
    }

    const payload = {
      rider_id: user.id,
      pickup_lat: input.pickup_lat,
      pickup_lng: input.pickup_lng,
      dropoff_lat: input.dropoff_lat,
      dropoff_lng: input.dropoff_lng,
      pickup_address: input.pickup_address,
      dropoff_address: input.dropoff_address,
      service_area_id: picked.id as string,
      product_code: input.product_code,
      scheduled_at: input.scheduled_at,
      source: input.source,
      status: 'new',
      preferences: input.preferences,
    };

    const { data, error } = await supa
      .from('ride_intents')
      .insert(payload)
      .select('id,created_at,service_area_id,product_code,source,status')
      .single();

    if (error) {
      ctx.error('db.insert_failed', { err: error.message });
      return errorJson('Failed to create ride intent', 400, 'DB_ERROR', undefined, ctx.headers);
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
