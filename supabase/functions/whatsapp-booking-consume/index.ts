import { handleOptions } from '../_shared/cors.ts';
import { errorJson, json } from '../_shared/json.ts';
import { withRequestContext } from '../_shared/requestContext.ts';
import { createAnonClient, requireUser } from '../_shared/supabase.ts';
import { consumeRateLimit, getClientIp } from '../_shared/rateLimit.ts';

type Body = { token?: string };

Deno.serve((req) =>
  withRequestContext('whatsapp-booking-consume', req, async () => {
    if (req.method === 'OPTIONS') return handleOptions(req);
    if (req.method !== 'POST') return errorJson('method_not_allowed', 405, 'METHOD_NOT_ALLOWED');

    // Basic rate limit by IP (edge); consume is state-changing.
    const ip = getClientIp(req);
    await consumeRateLimit({ key: `wa_booking_consume:${ip}`, limit: 20, windowSeconds: 60 });

    const user = await requireUser(req);

    const body = (await req.json().catch(() => ({}))) as Body;
    const token = (body.token ?? '').trim();
    if (!token) return errorJson('missing_token', 400, 'BAD_REQUEST');

    const supa = createAnonClient(req);
    const { data, error } = await supa.rpc('whatsapp_booking_token_consume_v1', { p_token: token });
    if (error) {
      // Normalize common errors
      const msg = (error.message ?? '').toLowerCase();
      if (msg.includes('token_used')) return errorJson('token_used', 409, 'CONFLICT');
      if (msg.includes('token_expired')) return errorJson('token_expired', 410, 'GONE');
      if (msg.includes('invalid_token')) return errorJson('invalid_token', 404, 'NOT_FOUND');
      return errorJson(error.message, 500, 'INTERNAL');
    }

    const intentId = typeof data === 'string' ? data : (data as any)?.id ?? data;
    return json({ ride_intent_id: intentId, user_id: user.id });
  }),
);
