import { handleOptions } from '../_shared/cors.ts';
import { createServiceClient } from '../_shared/supabase.ts';
import { json } from '../_shared/json.ts';
import { getZaincashV2Config } from '../_shared/zaincashV2.ts';
import { verifyJwtHS256 } from '../_shared/crypto.ts';
import { withRequestContext } from '../_shared/requestContext.ts';

function isUuid(v: string) {
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(v);
}
function pickFirst(...vals: unknown[]) {
  for (const v of vals) {
    if (v === null || v === undefined) continue;
    if (typeof v === 'string' && v.trim() === '') continue;
    return v;
  }
  return null;
}

Deno.serve(async (req) => {
  // verify_jwt=false in config.toml (webhook endpoint)
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  return await withRequestContext('zaincash-withdraw-webhook', req, async (ctx) => {
    try {
      if (req.method !== 'POST') return json({ ok: true, ignored: true });

      const body = await req.json().catch(() => null);
      const token = String(pickFirst((body as any)?.webhook_token, (body as any)?.webhookToken, (body as any)?.token) ?? '').trim();

      if (!token) {
        return json({ ok: true, ignored: true, reason: 'missing_webhook_token' });
      }

      const cfg = getZaincashV2Config();
      const claims = await verifyJwtHS256(token, cfg.apiKey);

      const eventId = String(pickFirst((claims as any)?.eventId, (claims as any)?.event_id, (claims as any)?.jti, (claims as any)?.id) ?? '').trim();
      const txId = String(pickFirst((claims as any)?.transactionId, (claims as any)?.transaction_id) ?? '').trim();
      const statusRaw = String(pickFirst((claims as any)?.status, (claims as any)?.transactionStatus) ?? '').trim();

      // We expect externalReferenceId to be wallet_withdraw_requests.id (UUID)
      const withdrawId = String(
        pickFirst(
          (claims as any)?.externalReferenceId,
          (claims as any)?.external_reference_id,
          (claims as any)?.merchantReference,
          (claims as any)?.orderId,
          (claims as any)?.order_id,
        ) ?? '',
      ).trim();

      const service = createServiceClient();

      if (eventId) {
        try {
          await service.from('provider_events').insert({
            provider_code: 'zaincash',
            provider_event_id: `payout:${eventId}`,
            payload: { claims, raw: body },
          });
        } catch {
          return json({ ok: true, duplicate: true });
        }
      }

      if (!withdrawId || !isUuid(withdrawId)) {
        return json({ ok: true, ignored: true, reason: 'missing_or_invalid_externalReferenceId', event_id: eventId || null });
      }

      const s = statusRaw.toLowerCase();
      const mapped =
        s === 'success' || s === 'paid' || s === 'completed'
          ? 'succeeded'
          : s === 'failed' || s === 'canceled' || s === 'cancelled' || s === 'expired'
            ? 'failed'
            : 'pending';

      if (mapped === 'succeeded') {
        await service.from('payout_provider_jobs').update({
          status: 'confirmed',
          provider_ref: txId || null,
          confirmed_at: new Date().toISOString(),
          response_payload: { claims, raw: body },
        }).eq('withdraw_request_id', withdrawId).eq('payout_kind', 'zaincash');

        const { error: finErr } = await service.rpc('system_withdraw_mark_paid', {
          p_request_id: withdrawId,
          p_payout_reference: txId || null,
          p_provider_payload: { provider: 'zaincash', webhook: claims, raw: body },
        });
        if (finErr) ctx.error('Finalize withdraw failed', { msg: finErr.message });
      } else if (mapped === 'failed') {
        await service.from('payout_provider_jobs').update({
          status: 'failed',
          provider_ref: txId || null,
          failed_at: new Date().toISOString(),
          last_error: `status=${s || 'failed'}`,
          response_payload: { claims, raw: body },
        }).eq('withdraw_request_id', withdrawId).eq('payout_kind', 'zaincash');

        await service.rpc('system_withdraw_mark_failed', {
          p_request_id: withdrawId,
          p_error_message: `status=${s || 'failed'}`,
          p_provider_payload: { provider: 'zaincash', webhook: claims, raw: body },
        });
      } else {
        await service.from('payout_provider_jobs').update({
          response_payload: { claims, raw: body },
        }).eq('withdraw_request_id', withdrawId).eq('payout_kind', 'zaincash');
      }

      return json({ ok: true, withdraw_request_id: withdrawId, event_id: eventId || null, status: mapped });
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e);
      // Always 200 OK to avoid retries; reconcile job can fix eventual consistency.
      return json({ ok: true, error: msg });
    }
  });
});
