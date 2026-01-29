import { handleOptions } from '../_shared/cors.ts';
import { createAnonClient, requireUser } from '../_shared/supabase.ts';
import { errorJson, json } from '../_shared/json.ts';
import { buildRateLimitHeaders, consumeRateLimit, getClientIp } from '../_shared/rateLimit.ts';
import { logAppEvent } from '../_shared/log.ts';

function clampInt(v: string | null, def: number, min: number, max: number) {
  const n = Number(v ?? def);
  if (!Number.isFinite(n)) return def;
  return Math.max(min, Math.min(max, Math.trunc(n)));
}

Deno.serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  if (req.method !== 'GET') return errorJson('Method not allowed', 405, 'METHOD_NOT_ALLOWED');

  const { user, error } = await requireUser(req);
  if (!user) return errorJson(error ?? 'Unauthorized', 401, 'UNAUTHORIZED');

  const ip = getClientIp(req);
  const rl = await consumeRateLimit({
    key: `support_ticket_list:${user.id}:${ip ?? 'noip'}`,
    windowSeconds: 60,
    limit: 120,
  });
  if (!rl.allowed) return json({ error: 'Rate limit exceeded' }, 429, buildRateLimitHeaders({ limit: 120, remaining: rl.remaining, resetAt: rl.resetAt }));

  const url = new URL(req.url);
  const status = (url.searchParams.get('status') ?? '').trim(); // '', 'open','pending','resolved','closed'
  const limit = clampInt(url.searchParams.get('limit'), 20, 1, 50);
  const offset = clampInt(url.searchParams.get('offset'), 0, 0, 100000);

  const supabase = createAnonClient(req);

  let q = supabase
    .from('support_ticket_summaries')
    .select('id,category_code,subject,status,priority,ride_id,created_at,updated_at,last_message,last_message_at,messages_count')
    .order('updated_at', { ascending: false })
    .range(offset, offset + limit - 1);

  if (status) q = q.eq('status', status);

  const { data, error: qErr } = await q;
  if (qErr) return errorJson(qErr.message, 400, 'QUERY_FAILED');

  logAppEvent({ name: 'support_ticket_list', user_id: user.id, ok: true });

  return json({ ok: true, tickets: data ?? [], next_offset: offset + (data?.length ?? 0) }, 200);
});
