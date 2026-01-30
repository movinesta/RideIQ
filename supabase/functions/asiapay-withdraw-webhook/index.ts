import { handleOptions } from '../_shared/cors.ts';
import { createServiceClient } from '../_shared/supabase.ts';
import { errorJson, json } from '../_shared/json.ts';
import { shaHex, timingSafeEqual } from '../_shared/crypto.ts';
import { withRequestContext } from '../_shared/requestContext.ts';

function isUuid(v: unknown): v is string {
  return typeof v === 'string' && /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(v);
}

function mapStatusFromCodes(successCode: string, prc: string) {
  const sc = (successCode ?? '').toLowerCase();
  const p = (prc ?? '').toLowerCase();
  // PayDollar/AsiaPay convention: SuccessCode=0 indicates success
  if (sc === '0' || sc === 'success') return 'succeeded';
  if (p.includes('fail') || sc === '1' || sc === 'failed') return 'failed';
  return 'pending';
}

Deno.serve(async (req) => {
  // verify_jwt=false in config.toml (webhook endpoint)
  const preflight = handleOptions(req);
  if (preflight) return preflight;

  return await withRequestContext('asiapay-withdraw-webhook', req, async (ctx) => {
    try {
      if (req.method !== 'POST') return errorJson('Method not allowed', 405);

      const service = createServiceClient();

      const bodyText = await req.text();
      const params = new URLSearchParams(bodyText);

      const src = params.get('src') ?? params.get('Src') ?? '';
      const prc = params.get('prc') ?? params.get('Prc') ?? '';
      const successCode = params.get('successcode') ?? params.get('SuccessCode') ?? params.get('successCode') ?? '';
      const ref =
        params.get('Ref') ??
        params.get('ref') ??
        params.get('orderRef') ??
        params.get('OrderRef') ??
        params.get('merchantRef') ??
        params.get('MerchantRef') ??
        '';

      const payRef = params.get('PayRef') ?? params.get('payRef') ?? '';
      const curr = params.get('Cur') ?? params.get('cur') ?? '';
      const amt = params.get('Amt') ?? params.get('amt') ?? '';
      const payerAuth = params.get('PayerAuth') ?? params.get('payerauth') ?? '';
      const secureHash = (params.get('secureHash') ?? params.get('SecureHash') ?? '').trim();
      const secureHashType = (params.get('secureHashType') ?? params.get('SecureHashType') ?? 'sha1').toLowerCase();

      // Idempotency event log (best effort)
      const eventId = `payout:${ref}:${payRef || prc || ''}:${successCode || 'unknown'}`;
      try {
        await service.from('provider_events').insert({
          provider_code: 'asiapay',
          provider_event_id: eventId,
          payload: Object.fromEntries(params.entries()),
        });
      } catch {
        return json({ ok: true, duplicate: true });
      }

      if (!isUuid(ref)) return json({ ok: true, ignored: true, reason: 'invalid_ref' });

      // Verify SecureHash if secret configured
      const secret = String(Deno.env.get('ASIAPAY_PAYOUT_SECURE_HASH_SECRET') ?? Deno.env.get('ASIAPAY_SECURE_HASH_SECRET') ?? '');
      const allowInsecure = String(Deno.env.get('ASIAPAY_ALLOW_INSECURE_WEBHOOKS') ?? '').toLowerCase() === 'true';

      if (secret) {
        if (!secureHash) return json({ ok: true, ignored: true, reason: 'missing_secureHash' });

        const algo = secureHashType === 'sha256' ? ('SHA-256' as const) : ('SHA-1' as const);

        // Verify data string = Src|Prc|SuccessCode|MerchantRef|PayRef|Curr|Amt|payerAuth|Secret
        const dataStr = `${src}|${prc}|${successCode}|${ref}|${payRef}|${curr}|${amt}|${payerAuth}|${secret}`;
        const expected = await shaHex(algo, dataStr);

        if (!timingSafeEqual(secureHash.toLowerCase(), expected.toLowerCase())) {
          return json({ ok: true, ignored: true, reason: 'invalid_secureHash' });
        }
      } else if (!allowInsecure) {
        return json({ ok: true, ignored: true, reason: 'secret_not_configured' });
      }

      const status = mapStatusFromCodes(successCode, prc);

      if (status === 'succeeded') {
        await service.from('payout_provider_jobs').update({
          status: 'confirmed',
          provider_ref: payRef || null,
          confirmed_at: new Date().toISOString(),
          response_payload: Object.fromEntries(params.entries()),
        }).eq('withdraw_request_id', ref).eq('payout_kind', 'asiapay');

        const { error: finErr } = await service.rpc('system_withdraw_mark_paid', {
          p_request_id: ref,
          p_payout_reference: payRef || null,
          p_provider_payload: { provider: 'asiapay', webhook: Object.fromEntries(params.entries()) },
        });
        if (finErr) ctx.error('Finalize withdraw failed', { msg: finErr.message });
      } else if (status === 'failed') {
        await service.from('payout_provider_jobs').update({
          status: 'failed',
          provider_ref: payRef || null,
          failed_at: new Date().toISOString(),
          last_error: `successCode=${successCode || ''} prc=${prc || ''}`,
          response_payload: Object.fromEntries(params.entries()),
        }).eq('withdraw_request_id', ref).eq('payout_kind', 'asiapay');

        await service.rpc('system_withdraw_mark_failed', {
          p_request_id: ref,
          p_error_message: `successCode=${successCode || ''} prc=${prc || ''}`,
          p_provider_payload: { provider: 'asiapay', webhook: Object.fromEntries(params.entries()) },
        });
      } else {
        await service.from('payout_provider_jobs').update({
          response_payload: Object.fromEntries(params.entries()),
        }).eq('withdraw_request_id', ref).eq('payout_kind', 'asiapay');
      }

      return json({ ok: true, withdraw_request_id: ref, status });
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e);
      return json({ ok: true, error: msg });
    }
  });
});
