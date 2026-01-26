import { handleOptions } from '../_shared/cors.ts';
import { createServiceClient } from '../_shared/supabase.ts';
import { errorJson, json } from '../_shared/json.ts';
import { hmacSha256Bytes, timingSafeEqual } from '../_shared/crypto.ts';

function isUuid(v: string) {
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(v);
}

function toHex(bytes: Uint8Array) {
  return Array.from(bytes).map((b) => b.toString(16).padStart(2, '0')).join('');
}

function normalizeSig(s: string) {
  return (s ?? '').trim().replace(/^sha256=/i, '');
}

function pickFirst<T>(...vals: Array<T | null | undefined>): T | null {
  for (const v of vals) if (v != null && v !== '') return v as T;
  return null;
}

Deno.serve(async (req) => {
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  try {
    if (req.method !== 'POST') return json({ ok: true, ignored: true });

    const service = createServiceClient();

    const raw = await req.text();
    let payload: any = null;
    try {
      payload = JSON.parse(raw);
    } catch {
      // try form-urlencoded
      try {
        const params = new URLSearchParams(raw);
        const obj: Record<string, any> = {};
        for (const [k, v] of params.entries()) obj[k] = v;
        payload = Object.keys(obj).length ? obj : null;
      } catch {
        payload = null;
      }
    }
    if (!payload || typeof payload !== 'object') {
      // Always acknowledge to avoid gateway retries
      try {
        const service = createServiceClient();
        await service.from('provider_events').insert({
          provider_code: 'qicard',
          provider_event_id: `parse_error:${Date.now()}`,
          payload: { raw },
        });
      } catch {}
      return json({ ok: true, ignored: true });
    }

    const { data: provider, error: provErr } = await service
      .from('payment_providers')
      .select('code,enabled,config')
      .eq('code', 'qicard')
      .maybeSingle();
    if (provErr || !provider) return json({ ok: true, ignored: true, reason: 'provider_not_found' });
    if (!provider.enabled) return json({ ok: true, ignored: true, reason: 'provider_disabled' });

    const cfg = (provider as any).config ?? {};
    const webhookSecret = String(cfg.webhook_secret ?? Deno.env.get('QICARD_WEBHOOK_SECRET') ?? '');
    const allowInsecure = String(Deno.env.get('ALLOW_INSECURE_WEBHOOKS') ?? '').toLowerCase() === 'true';

    // Verify signature if configured.
    if (webhookSecret) {
      const headerSig = normalizeSig(
        req.headers.get('x-signature') ??
          req.headers.get('x-webhook-signature') ??
          req.headers.get('x-qicard-signature') ??
          '',
      );

      if (!headerSig) return json({ ok: true, ignored: true, reason: 'missing_signature' });

      const mac = await hmacSha256Bytes(webhookSecret, raw);
      const hex = toHex(mac);
      const b64 = btoa(String.fromCharCode(...mac));
      if (!timingSafeEqual(headerSig.toLowerCase(), hex.toLowerCase()) && !timingSafeEqual(headerSig, b64)) {
        return json({ ok: true, ignored: true, reason: 'invalid_signature' });
      }
    } else if (!allowInsecure) {
      // Safer default: require the admin to configure webhook_secret.
      return json({ ok: true, ignored: true, reason: 'secret_not_configured' });
    }

    // Extract fields (QiCard docs are not publicly accessible in our environment; we accept multiple common shapes).
    const statusRaw = String(
      pickFirst(payload.status, payload.paymentStatus, payload.state, payload.result) ?? '',
    ).toLowerCase();

    const intentId = String(
      pickFirst(
        payload.reference,
        payload.orderId,
        payload.order_id,
        payload.merchantReference,
        payload.merchant_reference,
        payload?.metadata?.intent_id,
        payload?.metadata?.intentId,
      ) ?? '',
    );

    const providerTxId = String(
      pickFirst(payload.id, payload.paymentId, payload.payment_id, payload.transactionId, payload.transaction_id) ?? '',
    );

    const eventId = String(
      pickFirst(payload.eventId, payload.event_id, payload.id, payload.paymentId, payload.transactionId) ?? `webhook:${intentId || 'unknown'}:${statusRaw || 'unknown'}`,
    );

    // Log raw provider event (idempotent).
    try {
      await service.from('provider_events').insert({
        provider_code: 'qicard',
        provider_event_id: eventId,
        payload,
      });
    } catch {
      // ignore duplicates
    }

    if (!intentId || !isUuid(intentId)) {
      // Don't fail hard; the event log is still useful.
      return json({ ok: true, ignored: true, reason: 'missing_intent_id' });
    }

    const succeeded = ['success', 'succeeded', 'paid', 'completed', 'captured', 'done'].includes(statusRaw);
    const failed = ['failed', 'canceled', 'cancelled', 'declined', 'rejected', 'error'].includes(statusRaw);

    if (succeeded) {
      const { error } = await service.rpc('wallet_finalize_topup', {
        p_intent_id: intentId,
        p_provider_tx_id: providerTxId || null,
        p_provider_payload: payload,
      });
      if (error) return json({ ok: true, intent_id: intentId, status: 'error' });
      return json({ ok: true, intent_id: intentId, status: 'succeeded' });
    }

    if (failed) {
      const { error } = await service.rpc('wallet_fail_topup', {
        p_intent_id: intentId,
        p_failure_reason: `qicard_failed:${statusRaw || 'failed'}`,
        p_provider_payload: payload,
      });
      if (error) return errorJson(error.message ?? 'Fail failed', 500, 'FAIL_FAILED');
      return json({ ok: true, intent_id: intentId, status: 'failed' });
    }

    // pending/unknown: store payload + keep pending.
    await service
      .from('topup_intents')
      .update({ status: 'pending', provider_tx_id: providerTxId || null, provider_payload: payload })
      .eq('id', intentId);

    return json({ ok: true, intent_id: intentId, status: 'pending' });
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    return json({ ok: true, error: msg });
  }
});
