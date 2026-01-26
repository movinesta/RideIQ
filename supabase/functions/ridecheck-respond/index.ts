import { handleOptions } from '../_shared/cors.ts';
import { errorJson, json } from '../_shared/json.ts';
import { logAppEvent } from '../_shared/log.ts';
import { consumeRateLimit, getClientIp } from '../_shared/rateLimit.ts';
import { withRequestContext } from '../_shared/requestContext.ts';
import { createServiceClient, requireUser } from '../_shared/supabase.ts';

type Body = {
  event_id?: string;
  response?: 'ok' | 'false_alarm' | 'need_help';
  note?: string;
};

Deno.serve((req) => withRequestContext('ridecheck-respond', req, async (ctx) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  try {
    if (req.method !== 'POST') return errorJson('Method not allowed', 405);

    const { user, error: authError } = await requireUser(req);
    if (!user) return errorJson(String(authError ?? 'Unauthorized'), 401, 'UNAUTHORIZED');

    const ip = getClientIp(req);
    const rl = await consumeRateLimit({
      key: `ridecheck_respond:${user.id}:${ip ?? 'noip'}`,
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

    const body = (await req.json().catch(() => ({}))) as Body;
    const eventId = String(body.event_id ?? '').trim();
    const response = body.response;
    const note = typeof body.note === 'string' ? body.note.trim().slice(0, 500) : null;

    if (!eventId) return errorJson('event_id is required', 400, 'VALIDATION_ERROR');
    if (!response || !['ok', 'false_alarm', 'need_help'].includes(response)) {
      return errorJson('response must be one of ok|false_alarm|need_help', 400, 'VALIDATION_ERROR');
    }

    const service = createServiceClient();

    // Load event + ride participants
    const { data: ev, error: evErr } = await service
      .from('ridecheck_events')
      .select('id,ride_id,kind,status,rides!inner(rider_id,driver_id,status)')
      .eq('id', eventId)
      .maybeSingle();

    if (evErr) return errorJson(evErr.message, 500, 'DB_ERROR');
    if (!ev) return errorJson('RideCheck event not found', 404, 'NOT_FOUND');

    const ride = (ev as any).rides;
    const rideId = (ev as any).ride_id as string;

    const isRider = ride?.rider_id === user.id;
    const isDriver = ride?.driver_id === user.id;
    if (!isRider && !isDriver) return errorJson('Forbidden', 403, 'FORBIDDEN');

    if ((ev as any).status !== 'open') {
      return json({ ok: true, already_closed: true, status: (ev as any).status, ride_id: rideId });
    }

    const role = (isDriver ? 'driver' : 'rider') as 'driver' | 'rider';

    // Store response
    const { error: insErr } = await service.from('ridecheck_responses').insert({
      event_id: eventId,
      ride_id: rideId,
      user_id: user.id,
      role,
      response,
      note,
    });
    if (insErr) return errorJson(insErr.message, 500, 'DB_ERROR');

    // Close event (or escalate)
    const newStatus = response === 'need_help' ? 'escalated' : 'resolved';
    const patch: any = {
      status: newStatus,
      updated_at: new Date().toISOString(),
      resolved_at: new Date().toISOString(),
      metadata: { responded_by: role, response, requestId: ctx.requestId },
    };

    const { error: upErr } = await service
      .from('ridecheck_events')
      .update(patch)
      .eq('id', eventId)
      .eq('status', 'open');

    if (upErr) return errorJson(upErr.message, 500, 'DB_ERROR');

    await logAppEvent({
      event_type: 'ridecheck_response',
      actor_id: user.id,
      actor_type: role,
      ride_id: rideId,
      payload: { event_id: eventId, kind: (ev as any).kind, response, requestId: ctx.requestId },
    });

    return json({
      ok: true,
      ride_id: rideId,
      event_id: eventId,
      kind: (ev as any).kind,
      status: newStatus,
      response,
      rate_limit: { remaining: rl.remaining, reset_at: rl.resetAt },
    });
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    return errorJson(msg, 500, 'INTERNAL');
  }
}))); 
