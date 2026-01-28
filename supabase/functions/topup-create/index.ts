import { handleOptions } from '../_shared/cors.ts';
import { createServiceClient, requireUser } from '../_shared/supabase.ts';
import { errorJson, json } from '../_shared/json.ts';
import { buildRateLimitHeaders, consumeRateLimit, getClientIp } from '../_shared/rateLimit.ts';
import { logAppEvent } from '../_shared/log.ts';
import { SUPABASE_URL } from '../_shared/config.ts';
import { shaHex } from '../_shared/crypto.ts';
import { CURRENCY_IQD, ISO4217_NUMERIC_IQD, QICARD_DEFAULT_CREATE_PATH } from '../_shared/constants.ts';
import { getZaincashV2Config, zaincashV2InitPayment } from '../_shared/zaincashV2.ts';
import { findPreset, findProvider, getPaymentsPublicConfig } from '../_shared/paymentsConfig.ts';

type Body = {
  provider_code?: string;
  preset_id?: string;
  idempotency_key?: string;
};

const APP_SERVICE_TYPE = Deno.env.get('TOPUP_SERVICE_TYPE') ?? 'Ride top-up';

function isUuid(v: string) {
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(v);
}


function envTrim(key: string) {
  return (Deno.env.get(key) ?? '').trim();
}

function basicAuthHeader(user: string, pass: string) {
  return `Basic ${btoa(`${user}:${pass}`)}`;
}


// (JWT signing + SHA helpers moved to _shared/crypto.ts)

Deno.serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  try {
    if (req.method !== 'POST') return errorJson('Method not allowed', 405);

    const { user, error: authError } = await requireUser(req);
    if (!user) return errorJson(String(authError ?? 'Unauthorized'), 401, 'UNAUTHORIZED');

    const ip = getClientIp(req);
    const rl = await consumeRateLimit({ key: `topup:${user.id}:${ip ?? 'noip'}`, windowSeconds: 60, limit: 10 });
    if (!rl.allowed) {
      return json(
        { error: 'Rate limit exceeded', code: 'RATE_LIMITED', reset_at: rl.resetAt, remaining: rl.remaining },
        429,
        { 'Retry-After': String(Math.max(1, Math.ceil((new Date(rl.resetAt).getTime() - Date.now()) / 1000))) },
      );
    }

    const body: Body = await req.json().catch(() => ({}));
    const providerCode = (body.provider_code ?? '').trim().toLowerCase();
    const presetId = (body.preset_id ?? '').trim();
    const idempotencyKey = (body.idempotency_key ?? '').trim() || null;

    if (!providerCode) return errorJson('provider_code is required', 400, 'VALIDATION_ERROR');
    if (!presetId) return errorJson('preset_id is required', 400, 'VALIDATION_ERROR');

    const service = createServiceClient();

    // Payment provider + presets are configured via Edge Function secrets (not DB seed rows)
    let paymentsCfg;
    try {
      paymentsCfg = getPaymentsPublicConfig();
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e);
      return errorJson(`Payments config is not configured: ${msg}`, 500, 'MISCONFIGURED');
    }

    const provider = findProvider(paymentsCfg, providerCode);
    if (!provider) return errorJson('Payment provider not found', 404, 'NOT_FOUND');
    if (!provider.enabled) return errorJson('Payment provider is disabled', 409, 'PROVIDER_DISABLED');

    const preset = findPreset(provider, presetId);
    if (!preset || !preset.active) return errorJson('Top-up preset not found', 404, 'NOT_FOUND');

    const amountIqd = Number(preset.amount_iqd ?? 0);
    const bonusIqd = Number(preset.bonus_iqd ?? 0);
    if (!Number.isFinite(amountIqd) || amountIqd <= 0) return errorJson('Invalid preset amount', 400, 'VALIDATION_ERROR');

    // Insert intent. If the user passes an idempotency_key and it already exists, return existing intent.
    let intentId: string | null = null;
    {
      const { data: ins, error: insErr } = await service
        .from('topup_intents')
        .insert({
          user_id: user.id,
          provider_code: provider.code,
          // We don't rely on seeded DB rows for payment configuration.
          package_id: null,
          amount_iqd: amountIqd,
          bonus_iqd: bonusIqd,
          status: 'created',
          idempotency_key: idempotencyKey,
          provider_payload: { preset_id: presetId },
        })
        .select('id')
        .single();

      if (insErr) {
        const msg = insErr.message ?? '';
        if (idempotencyKey && (msg.includes('duplicate') || msg.includes('23505') || msg.includes('unique'))) {
          const { data: existing, error: exErr } = await service
            .from('topup_intents')
            .select('id')
            .eq('user_id', user.id)
            .eq('idempotency_key', idempotencyKey)
            .order('created_at', { ascending: false })
            .limit(1)
            .maybeSingle();
          if (exErr || !existing) return errorJson('Failed to create top-up intent', 500, 'INTENT_CREATE_FAILED');
          intentId = existing.id as string;
        } else {
          await logAppEvent({
            event_type: 'topup_intent_create_error',
            actor_id: user.id,
            actor_type: 'rider',
            payload: { message: msg, provider: provider.code, preset_id: presetId },
          });
          return errorJson('Failed to create top-up intent', 500, 'INTENT_CREATE_FAILED');
        }
      } else {
        intentId = (ins as any)?.id ?? null;
      }
    }

    if (!intentId) return errorJson('Failed to create top-up intent', 500, 'INTENT_CREATE_FAILED');

    const providerKind = String((provider as any).kind ?? '').toLowerCase();

    // Provider-specific init.
    if (providerKind === 'zaincash') {
      // ZainCash amount is IQD integer, min 250.
      if (amountIqd < 250) return errorJson('Minimum top-up is 250 IQD.', 400, 'VALIDATION_ERROR');

      let cfg;
      try {
        cfg = getZaincashV2Config();
      } catch (e) {
        const msg = e instanceof Error ? e.message : String(e);
        return errorJson(`ZainCash v2 is not configured: ${msg}`, 500, 'MISCONFIGURED');
      }

      const base = SUPABASE_URL.replace(/\/$/, '');
      const successUrl = new URL(`${base}/functions/v1/zaincash-return`);
      successUrl.searchParams.set('intentId', intentId);
      successUrl.searchParams.set('result', 'success');

      const failureUrl = new URL(`${base}/functions/v1/zaincash-return`);
      failureUrl.searchParams.set('intentId', intentId);
      failureUrl.searchParams.set('result', 'failure');

      let transactionId = '';
      let redirectUrl = '';
      let raw: any = null;
      try {
        const out = await zaincashV2InitPayment(cfg, {
          // Use intentId as a UUID externalReferenceId (idempotency key)
          externalReferenceId: intentId,
          orderId: intentId,
          amountIQD: Math.trunc(amountIqd),
          // Optional: you can pass user phone if you have it; we keep it unset here.
          customerPhone: null,
          successUrl: successUrl.toString(),
          failureUrl: failureUrl.toString(),
        });
        transactionId = out.transactionId;
        redirectUrl = out.redirectUrl;
        raw = out.raw;
      } catch (e) {
        const msg = e instanceof Error ? e.message : String(e);
        const status = (e as any)?.status ?? null;
        const url = (e as any)?.url ?? null;
        const body = (e as any)?.body ?? null;

        // Persist failure for debugging and idempotency.
        try {
          await service.from('provider_events').insert({
            provider_code: 'zaincash',
            provider_event_id: `init_error:${intentId}`,
            payload: { intent_id: intentId, error: { message: msg, status, url, body } },
          });
        } catch {
          // ignore duplicates
        }

        await service
          .from('topup_intents')
          .update({
            status: 'failed',
            failure_reason: `zaincash_init_failed:${status ?? 'error'}`,
            provider_payload: { error: { message: msg, status, url, body }, external_reference_id: intentId },
          })
          .eq('id', intentId);

        if (status === 404) {
          return errorJson(
            'ZainCash v2 endpoint was not found (HTTP 404). Check ZAINCASH_V2_BASE_URL: it should be the environment base URL (e.g. https://pg-api-uat.zaincash.iq), not a full endpoint path.',
            502,
            'PROVIDER_ERROR',
          );
        }

        if (status === 401 || status === 403) {
          return errorJson(
            'ZainCash v2 rejected the request (HTTP 401/403). Verify ZAINCASH_V2_CLIENT_ID, ZAINCASH_V2_CLIENT_SECRET, ZAINCASH_V2_SCOPE, and that you are using the correct environment base URL.',
            502,
            'PROVIDER_ERROR',
          );
        }

        return errorJson('Failed to initialize ZainCash payment.', 502, 'PROVIDER_ERROR');
      }

      await service
        .from('topup_intents')
        .update({
          status: 'pending',
          provider_tx_id: transactionId,
          provider_payload: { init: raw, external_reference_id: intentId },
        })
        .eq('id', intentId);

      await logAppEvent({
        event_type: 'topup_intent_created',
        actor_id: user.id,
        actor_type: 'rider',
        payload: { intent_id: intentId, provider: 'zaincash', provider_tx_id: transactionId, amount: amountIqd },
      });

      return json({
        ok: true,
        intent_id: intentId,
        provider_tx_id: transactionId,
        redirect_url: redirectUrl,
        rate_limit: { remaining: rl.remaining, reset_at: rl.resetAt },
      });
    }




    if (providerKind === 'asiapay') {
      // Provider settings are stored as Edge Function secrets (env vars), not DB rows.
      const paymentUrl = envTrim('ASIAPAY_PAYMENT_URL');
      const merchantId = envTrim('ASIAPAY_MERCHANT_ID');
      const secret = envTrim('ASIAPAY_SECURE_HASH_SECRET');
      const currCode = (envTrim('ASIAPAY_CURR_CODE') || ISO4217_NUMERIC_IQD).trim();
      const payType = (envTrim('ASIAPAY_PAY_TYPE') || 'N').trim() || 'N';
      const lang = (envTrim('ASIAPAY_LANG') || 'E').trim() || 'E';
      const hashTypeRaw = (envTrim('ASIAPAY_SECURE_HASH_TYPE') || 'sha1').toLowerCase();
      const secureHashType = hashTypeRaw === 'sha256' ? 'sha256' : 'sha1';

      if (!paymentUrl || !merchantId || !secret) {
        await service
          .from('topup_intents')
          .update({ status: 'failed', failure_reason: 'asiapay_missing_config' })
          .eq('id', intentId);
        return errorJson(
          'AsiaPay is not configured. Set payment_url, merchant_id and secure_hash_secret in provider config.',
          500,
          'MISCONFIGURED',
        );
      }

      const returnUrl = `${SUPABASE_URL.replace(/\/$/, '')}/functions/v1/asiapay-return`;

      // Amount for PayDollar is numeric (often supports decimals). We send IQD integer string.
      const amountStr = String(Math.trunc(amountIqd));

      // Signing data string = Merchant ID|Merchant Reference (orderRef)|Currency Code|Amount|Payment Type|Secure Hash Secret
      const signing = `${merchantId}|${intentId}|${currCode}|${amountStr}|${payType}|${secret}`;
      const algo = secureHashType === 'sha256' ? ('SHA-256' as const) : ('SHA-1' as const);
      const secureHash = await shaHex(algo, signing);

      const postFields: Record<string, string> = {
        merchantId,
        orderRef: intentId,
        amount: amountStr,
        currCode,
        payType,
        successUrl: returnUrl,
        failUrl: returnUrl,
        errorUrl: returnUrl,
        lang,
        secureHash,
      };
      // Some merchant accounts require explicit secureHashType parameter.
      postFields.secureHashType = secureHashType;

      // Best-effort provider event logging.
      try {
        await service.from('provider_events').insert({
          provider_code: provider.code,
          provider_event_id: `init:${intentId}`,
          payload: { post_url: paymentUrl, post_fields: postFields },
        });
      } catch {
        // ignore duplicates
      }

      await service
        .from('topup_intents')
        .update({
          status: 'pending',
          provider_tx_id: null,
          provider_payload: { init: { post_url: paymentUrl, post_fields: postFields } },
        })
        .eq('id', intentId);

      await logAppEvent({
        event_type: 'topup_intent_created',
        actor_id: user.id,
        actor_type: 'rider',
        payload: { intent_id: intentId, provider: 'asiapay', amount: amountIqd },
      });

      return json({
        ok: true,
        intent_id: intentId,
        post_url: paymentUrl,
        post_fields: postFields,
        rate_limit: { remaining: rl.remaining, reset_at: rl.resetAt },
      });
    }

    
if (providerKind === 'qicard') {
  const baseUrl = String(envTrim('QICARD_BASE_URL')).replace(/\/$/, '');
  // QiCard sandbox docs typically expose: .../api/v1/payment
  // So default `createPath` is `/payment` when baseUrl already ends with `/api/v1`.
  const createPath = String(envTrim('QICARD_CREATE_PATH') || QICARD_DEFAULT_CREATE_PATH);
  const bearerToken = String(envTrim('QICARD_BEARER_TOKEN')).trim();
  const basicUser = String(envTrim('QICARD_BASIC_AUTH_USER')).trim();
  const basicPass = String(envTrim('QICARD_BASIC_AUTH_PASS')).trim();
  const terminalId = String(envTrim('QICARD_TERMINAL_ID')).trim();
  const currency = String(envTrim('QICARD_CURRENCY') || CURRENCY_IQD).trim() || CURRENCY_IQD;

  if (!baseUrl) {
    await service.from('topup_intents').update({ status: 'failed', failure_reason: 'qicard_missing_base_url' }).eq('id', intentId);
    return errorJson('QiCard is not configured (missing QICARD_BASE_URL).', 500, 'MISCONFIGURED');
  }

  const notifyUrl = `${SUPABASE_URL.replace(/\/$/, '')}/functions/v1/qicard-notify`;
  const defaultReturnUrl = `${SUPABASE_URL.replace(/\/$/, '')}/functions/v1/qicard-return`;
  const returnUrl = String(envTrim('QICARD_RETURN_URL') || defaultReturnUrl);

  const payload: Record<string, unknown> = {
    // QiCard requires requestId uniqueness per merchant terminal.
    // Use the topup intent UUID for idempotency + correlation.
    requestId: intentId,
    amount: Math.trunc(amountIqd),
    currency,
    description: `${APP_SERVICE_TYPE} (${preset.label})`,
    reference: intentId,
    callbackUrl: notifyUrl,
    returnUrl,
    metadata: { intent_id: intentId, user_id: user.id, provider: provider.code, preset_id: preset.id },
  };

  const headers: Record<string, string> = { 'content-type': 'application/json', accept: 'application/json' };
  if (basicUser && basicPass) headers.Authorization = basicAuthHeader(basicUser, basicPass);
  else if (bearerToken) headers.Authorization = `Bearer ${bearerToken}`;
  if (terminalId) headers['X-Terminal-Id'] = terminalId;

  const res = await fetch(`${baseUrl}${createPath}`, {
    method: 'POST',
    headers,
    body: JSON.stringify(payload),
  });

  const text = await res.text();
  let out: any = null;
  try {
    out = JSON.parse(text);
  } catch {
    out = null;
  }

  const redirectUrl = String(out?.formUrl ?? out?.form_url ?? out?.checkoutUrl ?? out?.url ?? out?.redirect_url ?? '');
  const providerTxId = String(out?.paymentId ?? out?.payment_id ?? out?.id ?? out?.txId ?? out?.transactionId ?? '');

  // Log response for debugging/idempotency.
  try {
    await service.from('provider_events').insert({
      provider_code: provider.code,
      provider_event_id: providerTxId || `init:${intentId}`,
      payload: { request: payload, response: out ?? text, status: res.status },
    });
  } catch {
    // ignore duplicates
  }

  if (!res.ok || !redirectUrl) {
    await service
      .from('topup_intents')
      .update({ status: 'failed', failure_reason: `qicard_init_failed:${res.status}`, provider_payload: { init: out ?? text, request: payload } })
      .eq('id', intentId);
    return errorJson('Failed to initialize QiCard payment.', 502, 'PROVIDER_ERROR');
  }

  await service
    .from('topup_intents')
    .update({ status: 'pending', provider_tx_id: providerTxId || null, provider_payload: { init: out ?? {}, request: payload } })
    .eq('id', intentId);

  await logAppEvent({
    event_type: 'topup_intent_created',
    actor_id: user.id,
    actor_type: 'rider',
    payload: { intent_id: intentId, provider: 'qicard', provider_tx_id: providerTxId || null, amount: amountIqd, preset_id: preset.id },
  });

  return json({ ok: true, intent_id: intentId, redirect_url: redirectUrl, rate_limit: { remaining: rl.remaining, reset_at: rl.resetAt } });
}

    return errorJson('This payment provider is not yet supported in the current app build.', 400, 'NOT_IMPLEMENTED');
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    return errorJson(msg, 500, 'INTERNAL');
  }
});
