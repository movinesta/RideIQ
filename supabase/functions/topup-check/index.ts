import { handleOptions } from '../_shared/cors.ts';
import { createServiceClient, requireUser } from '../_shared/supabase.ts';
import { errorJson, json } from '../_shared/json.ts';
import { buildRateLimitHeaders, consumeRateLimit, getClientIp } from '../_shared/rateLimit.ts';
import { signJwtHS256 } from '../_shared/crypto.ts';

const ZAINCASH_BASE_URL = (Deno.env.get('ZAINCASH_BASE_URL') ?? 'https://test.zaincash.iq').replace(/\/$/, '');
const ZAINCASH_MERCHANT_ID = Deno.env.get('ZAINCASH_MERCHANT_ID') ?? '';
const ZAINCASH_SECRET = Deno.env.get('ZAINCASH_SECRET') ?? '';
const ZAINCASH_MSISDN = Deno.env.get('ZAINCASH_MSISDN') ?? '';

function isUuid(v: string) {
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(v);
}

function envTrim(key: string) {
  return (Deno.env.get(key) ?? '').trim();
}

function basicAuthHeader(user: string, pass: string) {
  return `Basic ${btoa(`${user}:${pass}`)}`;
}

function mapStatus(s: string) {
  const v = (s ?? '').toLowerCase();
  const succeeded = ['success', 'succeeded', 'paid', 'completed', 'captured', 'done', 'approved'].includes(v);
  const failed = ['failed', 'canceled', 'cancelled', 'declined', 'rejected', 'error', 'expired'].includes(v);
  if (succeeded) return 'succeeded' as const;
  if (failed) return 'failed' as const;
  return 'pending' as const;
}

async function checkZainCash(txId: string) {
  if (!ZAINCASH_MERCHANT_ID || !ZAINCASH_SECRET || !ZAINCASH_MSISDN) {
    throw new Error('ZainCash not configured');
  }

  const jwt = await signJwtHS256(
    { id: txId, msisdn: Number(ZAINCASH_MSISDN) },
    ZAINCASH_SECRET,
    60 * 10,
  );

  const form = new URLSearchParams();
  form.set('token', jwt);
  form.set('merchantId', ZAINCASH_MERCHANT_ID);

  const res = await fetch(`${ZAINCASH_BASE_URL}/transaction/get`, {
    method: 'POST',
    headers: { 'content-type': 'application/x-www-form-urlencoded' },
    body: form,
  });

  const text = await res.text();
  let out: any = null;
  try { out = JSON.parse(text); } catch { out = null; }
  const statusRaw = String(out?.status ?? out?.result ?? out?.response ?? '').toLowerCase();
  return {
  ok: res.ok,
  statusRaw,
  payload: {
    url,
    http_status: res.status,
    body: out ?? { raw: text },
  },
};
}

async function checkQiCard(providerCfg: Record<string, unknown>, providerTxId: string, intentId: string) {
  const baseUrl = String(providerCfg.base_url ?? envTrim('QICARD_BASE_URL') ?? '').replace(/\/$/, '');

  // Normalize status path:
  // - Some configs historically used `/payment/{id}` but docs list action endpoints like `/payment/{paymentId}/cancel`,
  //   and many gateways expose a dedicated status route.
  // We'll try multiple candidates to be resilient across sandbox/prod.
  let statusPath = String(providerCfg.status_path ?? (envTrim('QICARD_STATUS_PATH') || '/payment/{id}/status')).trim();

  // If a legacy config is set to `/payment/{id}` (or similar), prefer `/status`.
  const legacyPlain = ['/payment/{id}', '/payment/{paymentId}', '/payment/{payment_id}'];
  if (legacyPlain.includes(statusPath)) statusPath = '/payment/{id}/status';

  const apiKey = String(providerCfg.api_key ?? '');
  const bearerToken = String(providerCfg.bearer_token ?? apiKey ?? envTrim('QICARD_BEARER_TOKEN'));
  const basicUser = String(providerCfg.basic_auth_user ?? envTrim('QICARD_BASIC_AUTH_USER')).trim();
  const basicPass = String(providerCfg.basic_auth_pass ?? envTrim('QICARD_BASIC_AUTH_PASS')).trim();
  const terminalId = String(providerCfg.terminal_id ?? envTrim('QICARD_TERMINAL_ID')).trim();

  if (!baseUrl) {
    return { ok: false, statusRaw: 'pending', payload: { error: 'qicard_missing_base_url', intentId } };
  }

  const headers: Record<string, string> = { accept: 'application/json' };
  if (basicUser && basicPass) headers.Authorization = basicAuthHeader(basicUser, basicPass);
  else if (bearerToken) headers.Authorization = `Bearer ${bearerToken}`;
  if (terminalId) headers['X-Terminal-Id'] = terminalId;

  async function fetchStatus(url: string) {
    const res = await fetch(url, { method: 'GET', headers });
    const text = await res.text();
    let out: any = null;
    try { out = JSON.parse(text); } catch { out = null; }

    const statusRaw = String(
      out?.status ??
      out?.paymentStatus ??
      out?.state ??
      out?.payment?.status ??
      out?.payment?.paymentStatus ??
      out?.data?.status ??
      out?.result?.status ??
      ''
    ).toLowerCase();

    // Try to surface provider error code if present (for diagnostics)
    const providerErrorCode = out?.error?.code ?? out?.errorCode ?? out?.code ?? null;

    return {
      ok: res.ok,
      statusRaw,
      payload: {
        url,
        http_status: res.status,
        provider_error_code: providerErrorCode,
        body: out ?? { raw: text },
      },
    };
  }

  // Candidate URLs (dedupe while keeping order)
  const candidates: string[] = [];
  const add = (u: string) => { if (!candidates.includes(u)) candidates.push(u); };

  // 1) Config-driven (normalized) path
  add(`${baseUrl}${statusPath}`.replace('{id}', encodeURIComponent(providerTxId)).replace('{intent_id}', encodeURIComponent(intentId)));

  // 2) Common alternative: `/payment/{id}/status`
  add(`${baseUrl}/payment/{id}/status`.replace('{id}', encodeURIComponent(providerTxId)));

  // 3) Some gateways expose status on the payment object itself
  add(`${baseUrl}/payment/{id}`.replace('{id}', encodeURIComponent(providerTxId)));

  // Try each candidate until we get a meaningful status or a 2xx
  let last: any = null;
  for (const url of candidates) {
    const r = await fetchStatus(url);
    last = r;

    // If we got a mapped status, return immediately
    if (r.statusRaw) return r;

    // If provider returned non-5xx, don't keep hammering more endpoints unless empty status
    if (r.ok) return r;
  }

  return last ?? { ok: false, statusRaw: 'pending', payload: { error: 'qicard_status_unreachable' } };
}
async function checkAsiaPayFromEvents(service: any, intentId: string) {
  const { data } = await service
    .from('provider_events')
    .select('payload,received_at')
    .eq('provider_code', 'asiapay')
    .eq('provider_event_id', intentId)
    .order('received_at', { ascending: false })
    .limit(1);

  const payload = (data?.[0] as any)?.payload ?? null;
  const statusRaw = String(payload?.status ?? payload?.result ?? '').toLowerCase();
  const providerTxId = String(payload?.tx_id ?? payload?.transaction_id ?? payload?.transactionId ?? '');
  return { ok: true, statusRaw, payload, providerTxId: providerTxId || null };
}

Deno.serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  try {
    if (req.method !== 'POST') return errorJson('Method not allowed', 405);

    const { user, error } = await requireUser(req);
    if (!user) return errorJson(error ?? 'Unauthorized', 401, 'UNAUTHORIZED');


    const ip = getClientIp(req);
    const rl = await consumeRateLimit({ key: `topup_check:${user.id}:${ip ?? 'noip'}`, windowSeconds: 60, limit: 60 });
    if (!rl.allowed) {
      return json(
        { error: 'Rate limit exceeded', code: 'RATE_LIMITED', reset_at: rl.resetAt, remaining: rl.remaining },
        429,
        buildRateLimitHeaders({ limit: 60, remaining: rl.remaining, resetAt: rl.resetAt }),
      );
    }

    // Body may be missing JSON headers in some clients. Try JSON first, then text parse.
let body: any = {};
try {
  body = await req.json();
} catch (_) {
  try {
    const txt = await req.text();
    body = txt ? JSON.parse(txt) : {};
  } catch (_) {
    body = {};
  }
}

// Accept multiple field names coming from different clients.
const intentCandidate =
  String(body?.intent_id ?? body?.intentId ?? body?.intent ?? body?.id ?? body?.requestId ?? '').trim() || null;

const paymentCandidate =
  String(
    body?.provider_tx_id ??
      body?.providerTxId ??
      body?.payment_id ??
      body?.paymentId ??
      body?.tx_id ??
      body?.txId ??
      ''
  ).trim() || null;

if (intentCandidate && !isUuid(intentCandidate)) return errorJson('Invalid intent_id', 400, 'VALIDATION_ERROR');
if (paymentCandidate && paymentCandidate.length > 200) return errorJson('Invalid paymentId', 400, 'VALIDATION_ERROR');

const service = createServiceClient();

// Find target intent (always scoped to the authenticated user):
// 1) id (intent_id)
// 2) provider_tx_id (paymentId)
// 3) latest pending/created
let intent: any = null;

async function findById(id: string) {
  const { data } = await service
    .from('topup_intents')
    .select('id,user_id,provider_code,provider_tx_id,status,created_at,provider_payload')
    .eq('id', id)
    .eq('user_id', user.id)
    .maybeSingle();
  return data ?? null;
}

async function findByProviderTx(tx: string) {
  const { data } = await service
    .from('topup_intents')
    .select('id,user_id,provider_code,provider_tx_id,status,created_at,provider_payload')
    .eq('provider_tx_id', tx)
    .eq('user_id', user.id)
    .order('created_at', { ascending: false })
    .maybeSingle();
  return data ?? null;
}

if (intentCandidate) {
  intent = await findById(intentCandidate);
  if (!intent) {
    // Many UIs accidentally pass paymentId in place of intent_id
    intent = await findByProviderTx(intentCandidate);
  }
}

if (!intent && paymentCandidate) {
  intent = await findByProviderTx(paymentCandidate);
}

if (!intent) {
  const { data, error: qErr } = await service
    .from('topup_intents')
    .select('id,user_id,provider_code,provider_tx_id,status,created_at,provider_payload')
    .eq('user_id', user.id)
    .in('status', ['pending', 'created'])
    .order('created_at', { ascending: false })
    .limit(1);
  if (qErr) return errorJson(qErr.message ?? 'Query failed', 500, 'QUERY_FAILED');
  intent = (data ?? [])[0] ?? null;
}

if (!intent) {
      // When there are no intents, this is not an error for the UI.
      return json({ ok: true, found: false, code: 'NO_INTENTS' }, 200);
    }

  const intentId = String((intent as any).id);


  const providerCode = String(intent.provider_code ?? '').toLowerCase();
  const providerTxId = String(intent.provider_tx_id ?? '') || null;

    const { data: provider, error: provErr } = await service
      .from('payment_providers')
      .select('code,kind,enabled,config')
      .eq('code', providerCode)
      .maybeSingle();
    if (provErr || !provider || !(provider as any).enabled) {
      return errorJson('Payment provider missing or disabled', 400, 'PROVIDER_DISABLED');
    }

    const kind = String((provider as any).kind ?? '').toLowerCase();
    const providerCfg = ((provider as any).config ?? {}) as Record<string, unknown>;

    let check: { ok: boolean; statusRaw: string; payload: unknown } = { ok: false, statusRaw: 'pending', payload: null };
    let providerTxIdForFinalize = providerTxId;

    if (kind === 'qicard') {
      if (!providerTxIdForFinalize) return errorJson('Missing provider_tx_id', 400, 'MISSING_PROVIDER_TX');
      check = await checkQiCard(providerCfg, providerTxIdForFinalize, intentId);
    } else if (kind === 'zaincash') {
      if (!providerTxIdForFinalize) return errorJson('Missing provider_tx_id', 400, 'MISSING_PROVIDER_TX');
      check = await checkZainCash(providerTxIdForFinalize);
    } else if (kind === 'asiapay') {
      const out = await checkAsiaPayFromEvents(service, intentId);
      check = { ok: true, statusRaw: out.statusRaw, payload: out.payload };
      providerTxIdForFinalize = (out as any).providerTxId ?? providerTxIdForFinalize;
    } else {
      return errorJson('Unsupported provider kind', 400, 'UNSUPPORTED_PROVIDER');
    }

    // Log provider check event (best-effort)
    try {
      await service.from('provider_events').insert({
        provider_code: providerCode,
        provider_event_id: `${providerTxIdForFinalize ?? intentId}:usercheck`,
        payload: { check: check.payload, ok: check.ok, statusRaw: check.statusRaw },
      });
    } catch {
      // ignore duplicates
    }

    const mapped = mapStatus(check.statusRaw);

    if (mapped === 'succeeded') {
      const { error: finErr } = await service.rpc('wallet_finalize_topup', {
        p_intent_id: intentId,
        p_provider_tx_id: providerTxIdForFinalize,
        p_provider_payload: check.payload as any,
      });
      if (finErr) return errorJson(finErr.message ?? 'Finalize failed', 500, 'FINALIZE_FAILED');
      return json({ ok: true, intent_id: intentId, status: 'succeeded' });
    }

    if (mapped === 'failed') {
      const { error: failErr } = await service.rpc('wallet_fail_topup', {
        p_intent_id: intentId,
        p_failure_reason: `${providerCode}_failed:${check.statusRaw || 'failed'}`,
        p_provider_payload: check.payload as any,
      });
      if (failErr) return errorJson(failErr.message ?? 'Fail update failed', 500, 'FAIL_UPDATE_FAILED');
      return json({ ok: true, intent_id: intentId, status: 'failed' });
    }

    // Still pending
    await service
      .from('topup_intents')
      .update({ status: 'pending', provider_payload: check.payload as any })
      .eq('id', intentId);

    return json({ ok: true, intent_id: intentId, status: 'pending' });
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    return errorJson(msg, 500, 'INTERNAL');
  }
});
