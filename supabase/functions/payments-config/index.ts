import { handleOptions } from '../_shared/cors.ts';
import { requireUser } from '../_shared/supabase.ts';
import { errorJson, json } from '../_shared/json.ts';
import { getEnabledProviders, getPaymentsPublicConfig } from '../_shared/paymentsConfig.ts';

Deno.serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  try {
    // Wallet UI reads this config; keep it auth-only.
    const { user, error } = await requireUser(req);
    if (!user) return errorJson(error ?? 'Unauthorized', 401, 'UNAUTHORIZED');


    const cfg = getPaymentsPublicConfig();
    const providers = getEnabledProviders(cfg).map((p) => ({
      code: p.code,
      name: p.name,
      kind: p.kind,
      presets: (p.presets ?? []).filter((x) => x.active).map((x) => ({
        id: x.id,
        label: x.label,
        amount_iqd: x.amount_iqd,
        bonus_iqd: x.bonus_iqd,
      })),
    }));

    return json({ ok: true, providers });
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    return errorJson(msg, 500, 'INTERNAL');
  }
});
