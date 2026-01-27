import { handleOptions } from '../_shared/cors.ts';
import { errorJson, json } from '../_shared/json.ts';
import { hmacSha256Bytes } from '../_shared/crypto.ts';
import { logAppEvent } from '../_shared/log.ts';
import { consumeRateLimit, getClientIp } from '../_shared/rateLimit.ts';
import { withRequestContext } from '../_shared/requestContext.ts';
import { createServiceClient, requireUser } from '../_shared/supabase.ts';

type Body = {
  ride_id?: string;
  pin?: string;
};

function computePin(secret: string, rideId: string, riderId: string, driverId: string): string {
  const msg = `ride_pin:${rideId}:${riderId}:${driverId}`;
  const bytes = hmacSha256Bytes(secret, msg);
  const n = ((bytes[0] << 24) | (bytes[1] << 16) | (bytes[2] << 8) | bytes[3]) >>> 0;
  return (n % 10000).toString().padStart(4, '0');
}

Deno.serve((req) => withRequestContext('ride-verify-pin', req, async (ctx) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  try {
    if (req.method !== 'POST') return errorJson('Method not allowed', 405);

    const { user, error: authError } = await requireUser(req);
    if (!user) return errorJson(String(authError ?? 'Unauthorized'), 401, 'UNAUTHORIZED');

    const ip = getClientIp(req);
    const rl = await consumeRateLimit({
      key: `verify_pin:${user.id}:${ip ?? 'noip'}`,
      windowSeconds: 60,
      limit: 30,
    });
    if (!rl.allowed) {
      return json(
        { error: 'Rate limit exceeded', code: 'RATE_LIMITED', reset_at: rl.resetAt, remaining: rl.remaining },
        429,
        { 'Retry-After': String(Math.max(1, Math.ceil((new Date(rl.resetAt).getTime() - Date.now()) / 1000))) },
      );
    }

    const body = (await req.json().catch(() => ({}))) as Body;
    const rideId = String(body.ride_id ?? '').trim();
    const pin = String(body.pin ?? '').trim();
    if (!rideId) return errorJson('ride_id is required', 400, 'VALIDATION_ERROR');
    if (!pin || pin.length < 4) return errorJson('pin is required', 400, 'VALIDATION_ERROR');

    const service = createServiceClient();

    const { data: ride, error: rideErr } = await service
      .from('rides')
      .select('id,rider_id,driver_id,status,pickup_pin_required,pickup_pin_verified_at,pickup_pin_fail_count,pickup_pin_locked_until')
      .eq('id', rideId)
      .maybeSingle();

    if (rideErr) return errorJson(rideErr.message, 500, 'DB_ERROR');
    if (!ride) return errorJson('Ride not found', 404, 'NOT_FOUND');

    if (ride.driver_id !== user.id) return errorJson('Forbidden', 403, 'FORBIDDEN');

    const required = Boolean((ride as any).pickup_pin_required ?? false);
    const verifiedAt = (ride as any).pickup_pin_verified_at as string | null;
    const lockedUntil = (ride as any).pickup_pin_locked_until as string | null;
    const failCount = Number((ride as any).pickup_pin_fail_count ?? 0);

    if (!required) {
      return json({ ok: true, required: false, verified: Boolean(verifiedAt), rate_limit: { remaining: rl.remaining, reset_at: rl.resetAt } });
    }

    if (verifiedAt) {
      return json({ ok: true, required: true, verified: true, verified_at: verifiedAt, rate_limit: { remaining: rl.remaining, reset_at: rl.resetAt } });
    }

    if (lockedUntil) {
      const t = new Date(lockedUntil).getTime();
      if (Number.isFinite(t) && t > Date.now()) {
        return json(
          {
            error: 'PIN entry temporarily locked.',
            code: 'PIN_LOCKED',
            locked_until: lockedUntil,
            fail_count: failCount,
            rate_limit: { remaining: rl.remaining, reset_at: rl.resetAt },
          },
          423,
        );
      }
    }

    const secret = Deno.env.get('PIN_SECRET') ?? '';
    if (!secret || secret.length < 16) {
      return errorJson('Missing PIN_SECRET function secret', 500, 'MISSING_SECRET');
    }

    const expected = computePin(secret, ride.id, ride.rider_id, ride.driver_id);

    const nowIso = new Date().toISOString();

    if (pin !== expected) {
      const newFail = failCount + 1;
      const lockNow = newFail >= 5;
      const lockUntilIso = lockNow ? new Date(Date.now() + 10 * 60 * 1000).toISOString() : null;

      await service
        .from('rides')
        .update({
          pickup_pin_fail_count: newFail,
          pickup_pin_last_attempt_at: nowIso,
          pickup_pin_locked_until: lockUntilIso,
        })
        .eq('id', rideId);

      await logAppEvent({
        event_type: 'pickup_pin_invalid',
        actor_id: user.id,
        actor_type: 'driver',
        ride_id: rideId,
        payload: { requestId: ctx.requestId, newFail, locked: lockNow },
      });

      if (lockNow) {
        return json(
          {
            error: 'Too many failed attempts. PIN entry locked.',
            code: 'PIN_LOCKED',
            locked_until: lockUntilIso,
            fail_count: newFail,
            rate_limit: { remaining: rl.remaining, reset_at: rl.resetAt },
          },
          423,
        );
      }

      return errorJson('Invalid PIN', 400, 'INVALID_PIN', {
        fail_count: newFail,
        remaining_attempts: Math.max(0, 5 - newFail),
      });
    }

    // Success
    const { error: upErr } = await service
      .from('rides')
      .update({
        pickup_pin_verified_at: nowIso,
        pickup_pin_fail_count: 0,
        pickup_pin_locked_until: null,
        pickup_pin_last_attempt_at: nowIso,
      })
      .eq('id', rideId);

    if (upErr) return errorJson(upErr.message, 500, 'DB_ERROR');

    // Audit
    await service.from('ride_events').insert({
      ride_id: rideId,
      actor_id: user.id,
      actor_type: 'driver',
      event_type: 'pickup_pin_verified',
      payload: { verified_at: nowIso },
    });

    await logAppEvent({
      event_type: 'pickup_pin_verified',
      actor_id: user.id,
      actor_type: 'driver',
      ride_id: rideId,
      payload: { requestId: ctx.requestId },
    });

    return json({
      ok: true,
      required: true,
      verified: true,
      verified_at: nowIso,
      rate_limit: { remaining: rl.remaining, reset_at: rl.resetAt },
    });
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    return errorJson(msg, 500, 'INTERNAL');
  }
}));
