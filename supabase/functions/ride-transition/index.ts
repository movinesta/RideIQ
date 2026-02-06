import { handleOptions } from '../_shared/cors.ts';
import { createAnonClient, createServiceClient, requireUser } from '../_shared/supabase.ts';
import { errorJson, json } from '../_shared/json.ts';
import { buildRateLimitHeaders, consumeRateLimit, getClientIp } from '../_shared/rateLimit.ts';
import { logAppEvent } from '../_shared/log.ts';
import { shaHex } from '../_shared/crypto.ts';
import { withRequestContext } from '../_shared/requestContext.ts';
import { emitMetricBestEffort, metricTimer } from '../_shared/metrics.ts';

type Body = {
  ride_id: string;
  to_status: 'arrived' | 'in_progress' | 'completed' | 'canceled';
  cash_collected_amount_iqd?: number;
  cash_change_given_iqd?: number;
};

const allowed: Record<string, Set<string>> = {
  assigned: new Set(['arrived', 'canceled']),
  arrived: new Set(['in_progress', 'canceled']),
  in_progress: new Set(['completed', 'canceled']),
};

function clampInt(v: unknown, min: number, max: number, fallback: number) {
  const n = typeof v === 'number' && Number.isFinite(v) ? Math.floor(v) : fallback;
  return Math.max(min, Math.min(max, n));
}

function bytesToHex(bytes: Uint8Array) {
  return Array.from(bytes)
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
}

function randomTokenHex(bytes = 32) {
  const arr = new Uint8Array(bytes);
  crypto.getRandomValues(arr);
  return bytesToHex(arr);
}

async function createTripShareToken(
  service: ReturnType<typeof createServiceClient>,
  rideId: string,
  createdBy: string,
  ttlMinutes: number,
) {
  const token = randomTokenHex(32);
  const token_hash = await shaHex('SHA-256', token);
  const expires_at = new Date(Date.now() + ttlMinutes * 60 * 1000).toISOString();

  const { error } = await service.from('trip_share_tokens').insert({
    ride_id: rideId,
    created_by: createdBy,
    expires_at,
    token_hash,
  });
  if (error) throw error;
  return { token, expires_at } as const;
}


Deno.serve((req) => withRequestContext('ride-transition', req, async (ctx) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  let stopTimer: ReturnType<typeof metricTimer> | null = null;

  try {
    if (req.method !== 'POST') {
      emitMetricBestEffort(ctx, { event_type: 'metric.trip.transition', level: 'warn', payload: { ok: false, reason: 'method' } });
      return errorJson('Method not allowed', 405, 'METHOD_NOT_ALLOWED', undefined, ctx.headers);
    }

    const { user, error: authError } = await requireUser(req, ctx);
    if (!user) {
      emitMetricBestEffort(ctx, { event_type: 'metric.trip.transition', level: 'warn', payload: { ok: false, reason: 'unauthorized' } });
      return errorJson(String(authError ?? 'Unauthorized'), 401, 'UNAUTHORIZED', undefined, ctx.headers);
    }

    const ip = getClientIp(req);
    const rl = await consumeRateLimit({
      key: `transition:${user.id}:${ip ?? 'noip'}`,
      windowSeconds: 60,
      limit: 60,
    });
    if (!rl.allowed) {
      emitMetricBestEffort(ctx, { event_type: 'metric.trip.transition', level: 'warn', payload: { ok: false, reason: 'rate_limited' } });
      return json(
        { error: 'Rate limit exceeded', code: 'RATE_LIMITED', reset_at: rl.resetAt, remaining: rl.remaining },
        429,
        {
          ...ctx.headers,
          ...buildRateLimitHeaders({ limit: 60, remaining: rl.remaining, resetAt: rl.resetAt }),
          'Retry-After': String(Math.max(1, Math.ceil((new Date(rl.resetAt).getTime() - Date.now()) / 1000))),
        },
      );
    }

    const body = (await req.json()) as Body;
    if (!body?.ride_id || !body?.to_status) {
      emitMetricBestEffort(ctx, { event_type: 'metric.trip.transition', level: 'warn', payload: { ok: false, reason: 'validation' } });
      return errorJson('ride_id and to_status are required', 400, 'VALIDATION_ERROR', undefined, ctx.headers);
    }

    ctx.setCorrelationId(body.ride_id);
    stopTimer = metricTimer(ctx, 'metric.trip.transition_latency', {
      ride_id: body.ride_id,
      payload: { to_status: body.to_status },
    });

    const service = createServiceClient();

    const { data: ride, error: rideErr } = await service
      .from('rides')
      .select('id,rider_id,driver_id,status,version,started_at,completed_at,payment_method,cash_expected_amount_iqd,fare_amount_iqd')
      .eq('id', body.ride_id)
      .single();

    if (rideErr || !ride) {
      emitMetricBestEffort(ctx, { event_type: 'metric.trip.transition', level: 'warn', payload: { ok: false, reason: 'ride_not_found' } });
      await stopTimer?.('ok', { ok: false, reason: 'ride_not_found' });
      return errorJson(rideErr?.message ?? 'Ride not found', 404, 'NOT_FOUND', undefined, ctx.headers);
    }

    const isRider = ride.rider_id === user.id;
    const isDriver = ride.driver_id === user.id;
    if (!isRider && !isDriver) {
      emitMetricBestEffort(ctx, { event_type: 'metric.trip.transition', level: 'warn', payload: { ok: false, reason: 'forbidden' } });
      await stopTimer?.('ok', { ok: false, reason: 'forbidden' });
      return errorJson('Forbidden', 403, 'FORBIDDEN', undefined, ctx.headers);
    }

    const current = ride.status as string;
    const target = body.to_status as string;

    if (current === target) {
      emitMetricBestEffort(ctx, { event_type: 'metric.trip.transition', payload: { ok: true, idempotent: true, from: current, to: target } });
      await stopTimer?.('ok', { ok: true, idempotent: true, from: current, to: target });
      return json(
        { ok: true, ride, idempotent: true, rate_limit: { remaining: rl.remaining, reset_at: rl.resetAt } },
        200,
        { ...ctx.headers, ...buildRateLimitHeaders({ limit: 60, remaining: rl.remaining, resetAt: rl.resetAt }) },
      );
    }

    if (!allowed[current] || !allowed[current].has(target)) {
      emitMetricBestEffort(ctx, { event_type: 'metric.trip.transition', level: 'warn', payload: { ok: false, reason: 'invalid_transition', from: current, to: target } });
      await stopTimer?.('ok', { ok: false, reason: 'invalid_transition', from: current, to: target });
      return errorJson(`Invalid transition ${current} -> ${target}`, 409, 'INVALID_TRANSITION', undefined, ctx.headers);
    }

    // Actor constraints (simple MVP rules)
    if (target === 'arrived' && !isDriver) {
      emitMetricBestEffort(ctx, { event_type: 'metric.trip.transition', level: 'warn', payload: { ok: false, reason: 'forbidden', to: target } });
      await stopTimer?.('ok', { ok: false, reason: 'forbidden', to: target });
      return errorJson('Only driver can mark arrived', 403, 'FORBIDDEN', undefined, ctx.headers);
    }

    if ((target === 'in_progress' || target === 'completed') && !isDriver) {
      emitMetricBestEffort(ctx, { event_type: 'metric.trip.transition', level: 'warn', payload: { ok: false, reason: 'forbidden', to: target } });
      await stopTimer?.('ok', { ok: false, reason: 'forbidden', to: target });
      return errorJson('Only driver can progress trip', 403, 'FORBIDDEN', undefined, ctx.headers);
    }

    const actorType = (isDriver ? 'driver' : 'rider') as 'driver' | 'rider';

    // Cash rides (Iraq-first): driver must report cash collection before completing.
    const paymentMethod = String((ride as any)?.payment_method ?? 'wallet');
    if (target === 'completed' && paymentMethod === 'cash') {
      const expected = clampInt((ride as any)?.cash_expected_amount_iqd ?? (ride as any)?.fare_amount_iqd, 0, 2_000_000_000, 0);
      const collected = clampInt((body as any)?.cash_collected_amount_iqd, 0, 2_000_000_000, -1);
      const change = clampInt((body as any)?.cash_change_given_iqd, 0, 2_000_000_000, 0);

      if (expected <= 0) {
        emitMetricBestEffort(ctx, { event_type: 'metric.trip.transition', level: 'warn', payload: { ok: false, reason: 'cash_expected_missing' } });
        await stopTimer?.('ok', { ok: false, reason: 'cash_expected_missing' });
        return errorJson('Expected cash amount is missing for this ride', 409, 'CASH_EXPECTED_MISSING', undefined, ctx.headers);
      }
      if (collected < 0) {
        emitMetricBestEffort(ctx, { event_type: 'metric.trip.transition', level: 'warn', payload: { ok: false, reason: 'cash_required' } });
        await stopTimer?.('ok', { ok: false, reason: 'cash_required' });
        return errorJson('cash_collected_amount_iqd is required to complete a cash ride', 400, 'CASH_REQUIRED', undefined, ctx.headers);
      }
      if (collected < change) {
        emitMetricBestEffort(ctx, { event_type: 'metric.trip.transition', level: 'warn', payload: { ok: false, reason: 'validation' } });
        await stopTimer?.('ok', { ok: false, reason: 'validation' });
        return errorJson('cash_collected_amount_iqd must be >= cash_change_given_iqd', 400, 'VALIDATION_ERROR', undefined, ctx.headers);
      }
      const net = collected - change;
      if (net < expected) {
        emitMetricBestEffort(ctx, { event_type: 'metric.trip.transition', level: 'warn', payload: { ok: false, reason: 'cash_underpaid' } });
        await stopTimer?.('ok', { ok: false, reason: 'cash_underpaid' });
        return errorJson(
          `Collected cash is less than expected fare (${expected} IQD)`,
          400,
          'CASH_UNDERPAID',
          { expected_iqd: expected, net_iqd: net, collected_iqd: collected, change_iqd: change },
          ctx.headers,
        );
      }

      // Insert cash collection using the anon client so auth.uid() is correctly set (RLS enforced).
      const anon = createAnonClient(req);
      const { data: existing, error: exErr } = await anon
        .from('cash_collections')
        .select('ride_id,status')
        .eq('ride_id', ride.id)
        .maybeSingle();

      if (exErr) {
        ctx.error('cash_collections.read_failed', { err: exErr.message, ride_id: ride.id });
        emitMetricBestEffort(ctx, { event_type: 'metric.trip.transition', level: 'error', payload: { ok: false, reason: 'cash_collection_read_failed' } });
        await stopTimer?.('error', { ok: false, reason: 'cash_collection_read_failed' });
        return errorJson('Failed to validate cash collection', 500, 'CASH_COLLECTION_FAILED', undefined, ctx.headers);
      }

      if (!existing) {
        const { error: insErr } = await anon.from('cash_collections').insert({
          ride_id: ride.id,
          expected_amount_iqd: expected,
          collected_amount_iqd: collected,
          change_given_iqd: change,
        });
        if (insErr) {
          ctx.error('cash_collections.insert_failed', { err: insErr.message, ride_id: ride.id });
          emitMetricBestEffort(ctx, { event_type: 'metric.trip.transition', level: 'error', payload: { ok: false, reason: 'cash_collection_insert_failed' } });
          await stopTimer?.('error', { ok: false, reason: 'cash_collection_insert_failed' });
          return errorJson('Failed to record cash collection', 500, 'CASH_COLLECTION_FAILED', undefined, ctx.headers);
        }
      }
    }

    const { data: updated, error: upErr } = await service.rpc('transition_ride_v2', {
      p_ride_id: ride.id,
      p_to_status: target,
      p_actor_id: user.id,
      p_actor_type: actorType,
      p_expected_version: ride.version,
    });

    if (upErr) {
      const msg = upErr.message ?? 'Transition failed';
      const code = msg.includes('pickup_pin_required') ? 'PICKUP_PIN_REQUIRED'
        : msg.includes('cash_collection_required') ? 'CASH_COLLECTION_REQUIRED'
          : msg.includes('version_mismatch') ? 'VERSION_MISMATCH'
            : msg.includes('invalid_transition') ? 'INVALID_TRANSITION'
              : msg.includes('ride_not_found') ? 'NOT_FOUND'
                : 'TRANSITION_FAILED';
      const status = code === 'PICKUP_PIN_REQUIRED' ? 428 : (code === 'NOT_FOUND' ? 404 : 409);

      await logAppEvent({
        event_type: 'ride_transition_error',
        actor_id: user.id,
        actor_type: actorType,
        ride_id: ride.id,
        payload: { message: msg, from: current, to: target },
      });

      emitMetricBestEffort(ctx, { event_type: 'metric.trip.transition', level: 'warn', payload: { ok: false, reason: code, from: current, to: target } });
      await stopTimer?.('error', { ok: false, reason: code, error: msg, from: current, to: target });

      return errorJson(
        msg,
        status,
        code,
        code === 'VERSION_MISMATCH' ? { hint: 'Ride was updated elsewhere. Refresh and retry.' } : undefined,
        ctx.headers,
      );
    }

    await logAppEvent({
      event_type: 'ride_transition',
      actor_id: user.id,
      actor_type: actorType,
      ride_id: (updated as any)?.id ?? ride.id,
      payload: { from: current, to: target },
    });

    // Safety auto-share (best-effort): when a trip starts, optionally create a share link for the rider.
    if (target === 'in_progress') {
      try {
        const { data: settings } = await service
          .from('user_safety_settings')
          .select('auto_share_on_trip_start,default_share_ttl_minutes')
          .eq('user_id', ride.rider_id)
          .maybeSingle();

        const enabled = Boolean(settings?.auto_share_on_trip_start ?? false);
        if (enabled) {
          const ttl = clampInt(settings?.default_share_ttl_minutes, 5, 1440, 120);
          const { token, expires_at } = await createTripShareToken(service, ride.id, ride.rider_id, ttl);

          await service.from('user_notifications').insert({
            user_id: ride.rider_id,
            kind: 'trip_share',
            title: 'Trip started — share link ready',
            body: 'Your trip has started. Share this private link with trusted contacts.',
            data: { ride_id: ride.id, token, expires_at, reason: 'auto_trip_start' },
          });

          await service.from('trusted_contact_events').insert({
            user_id: ride.rider_id,
            ride_id: ride.id,
            event_type: 'auto_share_token_created',
            status: 'ok',
            payload: { ttl_minutes: ttl, expires_at },
          });
        }
      } catch (e: unknown) {
        ctx.error('auto_share.failed', { error: String(e), ride_id: ride.id });
      }
    }

    const didCancel = target === 'canceled';
    emitMetricBestEffort(ctx, { event_type: 'metric.trip.transition', payload: { ok: true, from: current, to: target, canceled: didCancel } });
    if (didCancel) emitMetricBestEffort(ctx, { event_type: 'metric.trip.canceled', level: 'warn', payload: { ride_id: ride.id, actor_type: actorType } });
    await stopTimer?.('ok', { ok: true, from: current, to: target, canceled: didCancel });
    return json(
      { ok: true, ride: updated, rate_limit: { remaining: rl.remaining, reset_at: rl.resetAt } },
      200,
      { ...ctx.headers, ...buildRateLimitHeaders({ limit: 60, remaining: rl.remaining, resetAt: rl.resetAt }) },
    );
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    emitMetricBestEffort(ctx, { event_type: 'metric.trip.transition', level: 'error', payload: { ok: false, reason: 'internal', error: msg } });
    await stopTimer?.('error', { ok: false, reason: 'internal', error: msg });
    return errorJson(msg, 500, 'INTERNAL', undefined, ctx.headers);
  }
}));
