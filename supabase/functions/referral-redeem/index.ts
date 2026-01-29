import { handleOptions } from '../_shared/cors.ts';
import { createServiceClient, requireUser } from '../_shared/supabase.ts';
import { errorJson, json } from '../_shared/json.ts';
import { buildRateLimitHeaders, consumeRateLimit, getClientIp } from '../_shared/rateLimit.ts';

type Body = {
  code: string;
};

Deno.serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  const ip = getClientIp(req);
  const rl = await consumeRateLimit({
    key: `refredeem:${ip ?? 'noip'}`,
    windowSeconds: 60,
    limit: 15,
  });
  if (!rl.allowed) return json({ error: 'Rate limit exceeded' }, 429, buildRateLimitHeaders({ limit: 15, remaining: rl.remaining, resetAt: rl.resetAt }));

  try {
    if (req.method !== 'POST') return errorJson('method_not_allowed', 405, null);

    const { user } = await requireUser(req);
    const body = (await req.json().catch(() => null)) as Body | null;
    if (!body?.code) return errorJson('invalid_body', 400, { required: ['code'] });

    const svc = createServiceClient();

    const { data: ref, error: refErr } = await svc
      .from('referral_codes')
      .select('code,owner_user_id,campaign_id')
      .eq('code', body.code)
      .maybeSingle();

    if (refErr) return errorJson('lookup_failed', 500, { message: refErr.message });
    if (!ref) return errorJson('invalid_code', 400, null);
    if (ref.owner_user_id === user.id) return errorJson('cannot_redeem_own_code', 400, null);

    const { error } = await svc.from('referral_redemptions').insert({
      referred_user_id: user.id,
      referrer_user_id: ref.owner_user_id,
      referral_code: ref.code,
      campaign_id: ref.campaign_id,
    });

    if (error) {
      // unique(referred_user_id) means already redeemed
      if (String(error.message).toLowerCase().includes('duplicate')) {
        return json({ ok: true, already_redeemed: true }, 200, headers);
      }
      return errorJson('redeem_failed', 500, { message: error.message });
    }

    return json({ ok: true }, 200, headers);
  } catch (e) {
    return errorJson('server_error', 500, { message: String(e) }, headers);
  }
});
