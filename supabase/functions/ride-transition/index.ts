import { handleOptions } from '../_shared/cors.ts';
import { createServiceClient, requireUser } from '../_shared/supabase.ts';
import { errorJson, json } from '../_shared/json.ts';
import { consumeRateLimit, getClientIp } from '../_shared/rateLimit.ts';
import { logAppEvent } from '../_shared/log.ts';
import { shaHex } from '../_shared/crypto.ts';
import { withRequestContext } from '../_shared/requestContext.ts';

type Body = {
  ride_id: string;
  to_status: 'arrived' | 'in_progress' | 'completed' | 'canceled';
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

  try {
    if (req.method !== 'POST') {
      return errorJson('Method not allowed', 405);
    }

    const { user, error: authError } = await requireUser(req);
    if (!user) {
      return errorJson(String(authError ?? 'Unauthorized'), 401, 'UNAUTHORIZED');
    }

    const ip = getClientIp(req);
    const rl = await consumeRateLimit({
      key: `transition:${user.id}:${ip ?? 'noip'}`,
      windowSeconds: 60,
      limit: 60,
    });
    if (!rl.allowed) {
      return json(
        { error: 'Rate limit exceeded', code: 'RATE_LIMITED', reset_at: rl.resetAt, remaining: rl.remaining },
        429,
        { 'Retry-After': String(Math.max(1, Math.ceil((new Date(rl.resetAt).getTime() - Date.now()) / 1000))) },
      );
    }

    const body = (await req.json()) as Body;
    if (!body?.ride_id || !body?.to_status) {
      return errorJson('ride_id and to_status are required', 400, 'VALIDATION_ERROR');
    }

    const service = createServiceClient();

    const { data: ride, error: rideErr } = await service
      .from('rides')
      .select('id,rider_id,driver_id,status,version,started_at,completed_at')
      .eq('id', body.ride_id)
      .single();

    if (rideErr || !ride) {
      return errorJson(rideErr?.message ?? 'Ride not found', 404, 'NOT_FOUND');
    }

    const isRider = ride.rider_id === user.id;
    const isDriver = ride.driver_id === user.id;
    if (!isRider && !isDriver) {
      return errorJson('Forbidden', 403, 'FORBIDDEN');
    }

    const current = ride.status as string;
    const target = body.to_status as string;

    if (current === target) {
      return json({ ok: true, ride, idempotent: true, rate_limit: { remaining: rl.remaining, reset_at: rl.resetAt } });
    }

    if (!allowed[current] || !allowed[current].has(target)) {
      return errorJson(`Invalid transition ${current} -> ${target}`, 409, 'INVALID_TRANSITION');
    }

    // Actor constraints (simple MVP rules)
    if (target === 'arrived' && !isDriver) {
      return errorJson('Only driver can mark arrived', 403, 'FORBIDDEN');
    }

    if ((target === 'in_progress' || target === 'completed') && !isDriver) {
      return errorJson('Only driver can progress trip', 403, 'FORBIDDEN');
    }

    const actorType = (isDriver ? 'driver' : 'rider') as 'driver' | 'rider';

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

      return errorJson(msg, status, code, code === 'VERSION_MISMATCH' ? { hint: 'Ride was updated elsewhere. Refresh and retry.' } : undefined);
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

    return json({ ok: true, ride: updated, rate_limit: { remaining: rl.remaining, reset_at: rl.resetAt } });
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    return errorJson(msg, 500, 'INTERNAL');
  }
}));
