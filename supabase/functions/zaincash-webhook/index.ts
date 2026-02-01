import { handleOptions } from '../_shared/cors.ts';
import { createServiceClient } from '../_shared/supabase.ts';
import { errorJson, json } from '../_shared/json.ts';
import { getZaincashV2Config } from '../_shared/zaincashV2.ts';
import { verifyJwtHS256 } from '../_shared/crypto.ts';

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
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  try {
    if (req.method !== 'POST') return errorJson('Method not allowed', 405, 'METHOD_NOT_ALLOWED');

    const body = await req.json().catch(() => null);
    const token = String(pickFirst((body as any)?.webhook_token, (body as any)?.webhookToken, (body as any)?.token) ?? '').trim();

    if (!token) {
      // Always 200 so gateway doesn't keep retrying invalid requests.
      return json({ ok: true, ignored: true, reason: 'missing_webhook_token' });
    }

    const cfg = getZaincashV2Config();

    // Webhook token is a JWT signed with ApiKey (HS256).
    // Docs recommend using eventId for idempotency.
    const claims = await verifyJwtHS256(token, cfg.apiKey);

    const eventId = String(
      pickFirst(
        (claims as any)?.eventId,
        (claims as any)?.event_id,
        (claims as any)?.jti,
        (claims as any)?.id,
      ) ?? '',
    ).trim();

    const txId = String(pickFirst((claims as any)?.transactionId, (claims as any)?.transaction_id) ?? '').trim();
    const status = String(pickFirst((claims as any)?.status, (claims as any)?.transactionStatus) ?? '').trim();

    // This is our topup_intents.id (UUID) we sent as externalReferenceId when initializing the payment.
    const intentId = String(
      pickFirst(
        (claims as any)?.externalReferenceId,
        (claims as any)?.external_reference_id,
        (claims as any)?.merchantReference,
      ) ?? '',
    ).trim();

    const service = createServiceClient();

    // Idempotency: store event (best effort). Duplicate event => noop.
    if (eventId) {
      try {
        await service.from('provider_events').insert({
          provider_code: 'zaincash',
          provider_event_id: eventId,
          payload: { claims, raw: body },
        });
      } catch {
        return json({ ok: true, duplicate: true });
      }
    }

    if (!intentId || !isUuid(intentId)) {
      return json({ ok: true, ignored: true, reason: 'missing_or_invalid_externalReferenceId', event_id: eventId || null });
    }

    const statusRaw = status.toLowerCase();
    const mapped =
      statusRaw === 'success' || statusRaw === 'paid' || statusRaw === 'completed'
        ? 'succeeded'
        : statusRaw === 'failed' || statusRaw === 'canceled' || statusRaw === 'cancelled' || statusRaw === 'expired'
          ? 'failed'
          : 'pending';

    if (mapped === 'succeeded') {
      const { error } = await service.rpc('wallet_finalize_topup', {
        p_intent_id: intentId,
        p_provider_tx_id: txId || null,
        p_provider_payload: { webhook: claims, raw: body },
      });
      if (error) return errorJson(error.message ?? 'Finalize failed', 500, 'FINALIZE_FAILED');
    } else if (mapped === 'failed') {
      const { error } = await service.rpc('wallet_fail_topup', {
        p_intent_id: intentId,
        p_reason: `webhook:${statusRaw || 'failed'}`,
        p_provider_payload: { webhook: claims, raw: body },
      });
      if (error) return errorJson(error.message ?? 'Fail failed', 500, 'FAIL_FAILED');
    } else {
      // Pending/update only.
      try {
        await service
          .from('topup_intents')
          .update({ status: 'pending', provider_tx_id: txId || null, provider_payload: { webhook: claims, raw: body } })
          .eq('id', intentId);
      } catch {
        // ignore
      }
    }

    return json({ ok: true, intent_id: intentId, event_id: eventId || null, status: mapped });
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    // Always 200 OK so the gateway doesn't retry on our internal errors (we rely on reconcile job for eventual consistency).
    return json({ ok: true, error: msg });
  }
});
