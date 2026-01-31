import { handleOptions } from '../_shared/cors.ts';
import { createAnonClient, requireUser } from '../_shared/supabase.ts';
import { errorJson, json } from '../_shared/json.ts';
import { consumeRateLimit, getClientIp } from '../_shared/rateLimit.ts';

type Body = {
  key?: string;
};

Deno.serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  if (req.method !== 'POST') return errorJson('Method not allowed', 405);

  const { user, error: authError } = await requireUser(req);
  if (!user) return errorJson(String(authError ?? 'Unauthorized'), 401, 'UNAUTHORIZED');

  const ip = getClientIp(req);
  const rl = await consumeRateLimit({
    key: `achclaim:${user.id}:${ip ?? 'noip'}`,
    windowSeconds: 60,
    limit: 20,
  });
  if (!rl.allowed) {
    return json({ error: 'Rate limit exceeded', code: 'RATE_LIMITED', reset_at: rl.resetAt, remaining: rl.remaining }, 429);
  }

  const body: Body = await req.json().catch(() => ({}));
  const key = (body.key ?? '').trim();
  if (!key) return errorJson('key is required', 400, 'VALIDATION_ERROR');

  const anon = createAnonClient(req);
  const { data, error } = await anon.rpc('achievement_claim', { p_key: key });

  if (error) return errorJson(error.message, 400, 'ACHIEVEMENT_ERROR');

  return json({ ok: true, result: data, rate_limit: { remaining: rl.remaining, reset_at: rl.resetAt } });
});
