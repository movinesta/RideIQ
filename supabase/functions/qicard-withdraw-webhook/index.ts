import { handleOptions } from '../_shared/cors.ts';
import { createServiceClient } from '../_shared/supabase.ts';
import { json } from '../_shared/json.ts';
import { hmacSha256Bytes, shaHex, timingSafeEqual } from '../_shared/crypto.ts';
import { withRequestContext } from '../_shared/requestContext.ts';

function isUuid(v: unknown): v is string {
  return typeof v === 'string' && /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(v);
}
function toHex(bytes: Uint8Array) {
  return Array.from(bytes).map((b) => b.toString(16).padStart(2, '0')).join('');
}
function normalizeSig(s: string) {
  return (s ?? '').trim().replace(/^sha256=/i, '');
}
function pickFirst(...vals: unknown[]) {
  for (const v of vals) {
    if (v === null || v === undefined) continue;
    if (typeof v === 'string' && v.trim() === '') continue;
    return v;
  }
  return null;
}
function mapStatus(raw: string) {
  const s = (raw ?? '').toLowerCase();
  if (['success', 'succeeded', 'paid', 'completed', 'ok', '00'].includes(s)) return 'succeeded';
  if (['fail', 'failed', 'error', 'canceled', 'cancelled', 'rejected'].includes(s)) return 'failed';
  return 'pending';
}

Deno.serve(async (req) => {
  // verify_jwt=false in config.toml (webhook endpoint)
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  return await withRequestContext('qicard-withdraw-webhook', req, async (ctx) => {
    try {
      if (req.method !== 'POST') return json({ ok: true, ignored: true });

      const service = createServiceClient();
      const raw = await req.text();

      // Parse JSON or form
      let payload: any = null;
      try {
        payload = JSON.parse(raw);
      } catch {
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
        return json({ ok: true, ignored: true, reason: 'bad_payload' });
      }

      // HMAC verification (same pattern as qicard-notify)
      const webhookSecret = String(Deno.env.get('QICARD_PAYOUT_WEBHOOK_SECRET') ?? Deno.env.get('QICARD_WEBHOOK_SECRET') ?? '');
      const allowInsecure = String(Deno.env.get('QICARD_ALLOW_INSECURE_WEBHOOKS') ?? '').toLowerCase() === 'true';

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
        return json({ ok: true, ignored: true, reason: 'secret_not_configured' });
      }

      const withdrawId = String(
        pickFirst(payload.withdraw_request_id, payload.withdrawal_id, payload.ref, payload.reference, payload.orderId, payload.order_id) ?? '',
      ).trim();

      if (!isUuid(withdrawId)) {
        return json({ ok: true, ignored: true, reason: 'missing_or_invalid_withdraw_id' });
      }

      const providerRef = String(pickFirst(payload.transactionId, payload.transaction_id, payload.txId, payload.tx_id, payload.paymentId, payload.payment_id) ?? '').trim();
      const status = mapStatus(String(pickFirst(payload.status, payload.result, payload.code, payload.success) ?? ''));

      const eventId =
        String(pickFirst(payload.eventId, payload.event_id, payload.id, payload.uuid) ?? '').trim() ||
        (await shaHex('SHA-256', raw));

      // Idempotency: provider_events unique (provider_code, provider_event_id)
      try {
        await service.from('provider_events').insert({
          provider_code: 'qicard',
          provider_event_id: `payout:${eventId}`,
          payload: { raw: payload },
        });
      } catch {
        return json({ ok: true, duplicate: true });
      }

      if (status === 'succeeded') {
        await service.from('payout_provider_jobs').update({
          status: 'confirmed',
          provider_ref: providerRef || null,
          confirmed_at: new Date().toISOString(),
          response_payload: payload,
        }).eq('withdraw_request_id', withdrawId).eq('payout_kind', 'qicard');

        const { error: finErr } = await service.rpc('system_withdraw_mark_paid', {
          p_request_id: withdrawId,
          p_payout_reference: providerRef || null,
          p_provider_payload: { provider: 'qicard', webhook: payload },
        });
        if (finErr) ctx.error('Finalize withdraw failed', { msg: finErr.message });
      } else if (status === 'failed') {
        await service.from('payout_provider_jobs').update({
          status: 'failed',
          provider_ref: providerRef || null,
          failed_at: new Date().toISOString(),
          last_error: String(payload.error ?? payload.message ?? 'failed'),
          response_payload: payload,
        }).eq('withdraw_request_id', withdrawId).eq('payout_kind', 'qicard');

        await service.rpc('system_withdraw_mark_failed', {
          p_request_id: withdrawId,
          p_error_message: String(payload.error ?? payload.message ?? 'failed'),
          p_provider_payload: { provider: 'qicard', webhook: payload },
        });
      } else {
        // pending: update payload only
        await service.from('payout_provider_jobs').update({
          response_payload: payload,
        }).eq('withdraw_request_id', withdrawId).eq('payout_kind', 'qicard');
      }

      return json({ ok: true, withdraw_request_id: withdrawId, status });
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e);
      return json({ ok: true, error: msg });
    }
  });
});
