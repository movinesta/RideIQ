import { handleOptions } from '../_shared/cors.ts';
import { createAnonClient, requireUser } from '../_shared/supabase.ts';
import { errorJson, json } from '../_shared/json.ts';
import { buildRateLimitHeaders, consumeRateLimit, getClientIp } from '../_shared/rateLimit.ts';
import { logAppEvent } from '../_shared/log.ts';

Deno.serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  if (req.method !== 'GET') return errorJson('Method not allowed', 405, 'METHOD_NOT_ALLOWED');

  const { user, error } = await requireUser(req);
  if (!user) return errorJson(error ?? 'Unauthorized', 401, 'UNAUTHORIZED');

  const ip = getClientIp(req);
  const rl = await consumeRateLimit({
    key: `support_ticket_detail:${user.id}:${ip ?? 'noip'}`,
    windowSeconds: 60,
    limit: 240,
  });
  if (!rl.allowed) return json({ error: 'Rate limit exceeded' }, 429, buildRateLimitHeaders({ limit: 240, remaining: rl.remaining, resetAt: rl.resetAt }));

  const url = new URL(req.url);
  const ticketId = (url.searchParams.get('ticket_id') ?? '').trim();
  if (!ticketId) return errorJson('Missing ticket_id', 400, 'INVALID_REQUEST');

  const supabase = createAnonClient(req);

  const { data: ticket, error: tErr } = await supabase
    .from('support_tickets')
    .select('id,category_code,subject,status,priority,ride_id,created_at,updated_at')
    .eq('id', ticketId)
    .single();

  if (tErr) return errorJson(tErr.message, 404, 'NOT_FOUND');

  const { data: messages, error: mErr } = await supabase
    .from('support_messages')
    .select('id,ticket_id,sender_id,message,attachments,created_at')
    .eq('ticket_id', ticketId)
    .order('created_at', { ascending: true });

  if (mErr) return errorJson(mErr.message, 400, 'MESSAGES_QUERY_FAILED');

  logAppEvent({ name: 'support_ticket_detail', user_id: user.id, ok: true });

  return json({ ok: true, ticket, messages: messages ?? [] }, 200);
});
