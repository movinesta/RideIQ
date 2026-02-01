import { handleOptions } from '../_shared/cors.ts';
import { errorJson, json } from '../_shared/json.ts';
import { logAppEvent } from '../_shared/log.ts';
import { withRequestContext } from '../_shared/requestContext.ts';
import { createServiceClient, requireUser } from '../_shared/supabase.ts';
import { consumeRateLimit } from '../_shared/rateLimit.ts';
import { normalizePhone, sendContactMessage } from '../_shared/contactProviders.ts';

type Body = {
  contact_id?: string;
  channel?: 'sms' | 'whatsapp';
};

function buildTestMessage() {
  const headerEn = 'RideIQ Test Message';
  const headerAr = 'رسالة اختبار RideIQ';
  const en = 'If you received this message, Trusted Contacts notifications are working.';
  const ar = 'إذا وصلتك هذه الرسالة، فإشعارات جهات الاتصال الموثوقة تعمل بنجاح.';
  return `${headerEn}\n${en}\n\n${headerAr}\n${ar}`;
}

Deno.serve((req) =>
  withRequestContext('trusted-contacts-test', req, async () => {
    const preflight = handleOptions(req);
    if (preflight) return preflight;

    const { user, error } = await requireUser(req);
    if (error || !user) return errorJson('Unauthorized', 401, 'UNAUTHORIZED');

    const rl = await consumeRateLimit({
      key: `trusted_contact_test:${user.id}`,
      windowSeconds: 60 * 60,
      limit: 3,
    });
    if (!rl.allowed) {
      return errorJson('Rate limited', 429, 'RATE_LIMITED', { retryAfter: rl.resetAt });
    }

    let body: Body = {};
    try {
      body = (await req.json().catch(() => ({}))) as Body;
    } catch {
      body = {};
    }

    const contactId = String(body.contact_id ?? '').trim();
    if (!contactId) return errorJson('Missing contact_id', 400, 'BAD_REQUEST');

    const channel = (body.channel ?? 'whatsapp') === 'sms' ? 'sms' : 'whatsapp';

    // Fetch contact under user ownership.
    const service = createServiceClient();
    const { data: contact, error: cErr } = await service
      .from('trusted_contacts')
      .select('id,user_id,name,phone,is_active')
      .eq('id', contactId)
      .eq('user_id', user.id)
      .maybeSingle();

    if (cErr) return errorJson(cErr.message, 500, 'DB_ERROR');
    if (!contact || !contact.is_active) return errorJson('Contact not found', 404, 'NOT_FOUND');

    const to = normalizePhone(String((contact as any).phone ?? ''));
    if (!to) return errorJson('Contact phone missing', 400, 'BAD_REQUEST');

    const message = buildTestMessage();

    try {
      const res = await sendContactMessage({
        channel,
        to,
        message,
        meta: { type: 'trusted_contact_test', contact_id: contactId, user_id: user.id },
      });

      await logAppEvent({
        event_type: res.ok ? 'trusted_contact_test_sent' : 'trusted_contact_test_failed',
        actor_type: 'user',
        actor_id: user.id,
        ride_id: null,
        payload: {
          contact_id: contactId,
          channel,
          to_phone_last4: to.slice(-4),
          provider_status: res.status,
          provider_message_id: res.providerMessageId ?? null,
        },
      });

      if (!res.ok) {
        return errorJson(
          'Failed to send test message',
          res.status && res.status > 0 ? 502 : 400,
          'PROVIDER_ERROR',
          { status: res.status, response: res.responseText?.slice(0, 500) ?? null },
        );
      }

      return json({ ok: true, status: res.status, provider_message_id: res.providerMessageId ?? null });
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e);
      await logAppEvent({
        event_type: 'trusted_contact_test_failed',
        actor_type: 'user',
        actor_id: user.id,
        ride_id: null,
        payload: { contact_id: contactId, channel, error: msg },
      });
      return errorJson(msg, 500, 'INTERNAL');
    }
  }),
);
