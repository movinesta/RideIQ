import { handleOptions } from '../_shared/cors.ts';
import { createAnonClient, requireUser } from '../_shared/supabase.ts';
import { errorJson, json } from '../_shared/json.ts';
import { buildRateLimitHeaders, consumeRateLimit, getClientIp } from '../_shared/rateLimit.ts';

Deno.serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  if (req.method !== 'GET') return errorJson('Method not allowed', 405, 'METHOD_NOT_ALLOWED');

  const { user, error } = await requireUser(req);
  if (!user) return errorJson(error ?? 'Unauthorized', 401, 'UNAUTHORIZED');

  const ip = getClientIp(req);
  const rl = await consumeRateLimit({
    key: `support_categories:${user.id}:${ip ?? 'noip'}`,
    windowSeconds: 60,
    limit: 120,
  });
  if (!rl.allowed) return json({ error: 'Rate limit exceeded' }, 429, buildRateLimitHeaders({ limit: 120, remaining: rl.remaining, resetAt: rl.resetAt }));

  const supabase = createAnonClient(req);
  const { data, error: qErr } = await supabase
    .from('support_categories')
    .select('code,title,description,sort_order,enabled')
    .eq('enabled', true)
    .order('sort_order', { ascending: true });

  if (qErr) return errorJson(qErr.message, 400, 'QUERY_FAILED');

  return json({ ok: true, categories: data ?? [] }, 200);
});
