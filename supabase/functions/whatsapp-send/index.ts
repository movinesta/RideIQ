import { handleOptions } from '../_shared/cors.ts';
import { errorJson, json } from '../_shared/json.ts';
import { withRequestContext } from '../_shared/requestContext.ts';
import { createAnonClient, createServiceClient, requireUser } from '../_shared/supabase.ts';
import { consumeRateLimit, getClientIp } from '../_shared/rateLimit.ts';

function env(key: string): string {
  return (('permissions' in Deno) ? Deno.env.get(key) : (Deno.env.get(key))) ?? '';
}

type TemplatePayload = {
  name: string;
  language?: string; // e.g. en_US
  components?: unknown[]; // raw WhatsApp components array
};

type Body = {
  thread_id?: string;

  // Send plain text (only allowed when the 24h customer service window is open)
  message?: string;

  // Send a template (allowed anytime; required when customer service window is closed)
  template?: TemplatePayload;

  // Convenience actions
  action?: 'send_booking_link' | 'send_menu';
  expires_minutes?: number; // default 30
};

function isCswOpen(lastInboundAt: string | null): { open: boolean; expiresAt: string | null } {
  if (!lastInboundAt) return { open: false, expiresAt: null };
  const t = new Date(lastInboundAt).getTime();
  if (!Number.isFinite(t)) return { open: false, expiresAt: null };
  const expires = new Date(t + 24 * 60 * 60 * 1000);
  const open = Date.now() <= expires.getTime();
  return { open, expiresAt: expires.toISOString() };
}

async function sendWhatsAppText(toWaId: string, body: string) {
  const token = env('WHATSAPP_TOKEN');
  const phoneNumberId = env('WHATSAPP_PHONE_NUMBER_ID');
  const version = env('WHATSAPP_GRAPH_VERSION') || 'v21.0';
  if (!token || !phoneNumberId) throw new Error('Missing WHATSAPP_TOKEN or WHATSAPP_PHONE_NUMBER_ID');

  const url = `https://graph.facebook.com/${version}/${encodeURIComponent(phoneNumberId)}/messages`;
  const res = await fetch(url, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      messaging_product: 'whatsapp',
      to: toWaId,
      type: 'text',
      text: { body },
    }),
  });
  const out = await res.json().catch(() => ({}));
  if (!res.ok) {
    const msg = typeof (out as any)?.error?.message === 'string' ? (out as any).error.message : `HTTP ${res.status}`;
    throw new Error(`WhatsApp send failed: ${msg}`);
  }
  return out;
}

async function sendWhatsAppTemplate(toWaId: string, tpl: TemplatePayload) {
  const token = env('WHATSAPP_TOKEN');
  const phoneNumberId = env('WHATSAPP_PHONE_NUMBER_ID');
  const version = env('WHATSAPP_GRAPH_VERSION') || 'v21.0';
  if (!token || !phoneNumberId) throw new Error('Missing WHATSAPP_TOKEN or WHATSAPP_PHONE_NUMBER_ID');

  const language = (tpl.language ?? env('WHATSAPP_TEMPLATE_LANG') ?? 'en_US').trim() || 'en_US';

  const url = `https://graph.facebook.com/${version}/${encodeURIComponent(phoneNumberId)}/messages`;
  const res = await fetch(url, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      messaging_product: 'whatsapp',
      to: toWaId,
      type: 'template',
      template: {
        name: tpl.name,
        language: { code: language },
        ...(Array.isArray(tpl.components) ? { components: tpl.components } : {}),
      },
    }),
  });
  const out = await res.json().catch(() => ({}));
  if (!res.ok) {
    const msg = typeof (out as any)?.error?.message === 'string' ? (out as any).error.message : `HTTP ${res.status}`;
    throw new Error(`WhatsApp template send failed: ${msg}`);
  }
  return out;
}


async function sendWhatsAppList(
  toWaId: string,
  bodyText: string,
  buttonText: string,
  sections: { title: string; rows: { id: string; title: string; description?: string }[] }[],
) {
  const token = env('WHATSAPP_TOKEN');
  const phoneNumberId = env('WHATSAPP_PHONE_NUMBER_ID');
  const version = env('WHATSAPP_GRAPH_VERSION') || 'v21.0';
  if (!token || !phoneNumberId) throw new Error('Missing WHATSAPP_TOKEN or WHATSAPP_PHONE_NUMBER_ID');

  const url = `https://graph.facebook.com/${version}/${encodeURIComponent(phoneNumberId)}/messages`;
  const res = await fetch(url, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      messaging_product: 'whatsapp',
      to: toWaId,
      type: 'interactive',
      interactive: {
        type: 'list',
        body: { text: bodyText },
        action: {
          button: buttonText,
          sections: sections.map((s) => ({
            title: s.title,
            rows: s.rows.slice(0, 10).map((r) => ({
              id: r.id,
              title: r.title,
              ...(r.description ? { description: r.description } : {}),
            })),
          })),
        },
      },
    }),
  });

  const out = await res.json().catch(() => ({}));
  if (!res.ok) {
    const msg = typeof (out as any)?.error?.message === 'string' ? (out as any).error.message : `HTTP ${res.status}`;
    throw new Error(`WhatsApp list send failed: ${msg}`);
  }
  return out;
}

function menuMessage() {
  const en = `Quick menu — choose an option:`;
  const ar = `قائمة سريعة — اختر خياراً:`;
  return `${en}\n\n${ar}`;
}

function buildBookingLink(token: string) {
  const base = env('APP_BASE_URL') || 'http://localhost:5173';
  const clean = base.replace(/\/$/, '');
  return `${clean}/booking/${encodeURIComponent(token)}`;
}

function bookingLinkMessage(link: string) {
  const en = `Thanks! Open this link to confirm the ride:\n${link}`;
  const ar = `شكراً! افتح الرابط لتأكيد طلب المشوار:\n${link}`;
  return `${en}\n\n${ar}`;
}

Deno.serve((req) =>
  withRequestContext('whatsapp-send', req, async (ctx) => {
    if (req.method === 'OPTIONS') return handleOptions(req);
    if (req.method !== 'POST') return errorJson('method_not_allowed', 405, 'METHOD_NOT_ALLOWED');

    const ip = getClientIp(req);
    await consumeRateLimit({ key: `wa_send:${ip}`, limit: 60, windowSeconds: 60 });

    const user = await requireUser(req);
    const anon = createAnonClient(req);

    const { data: prof, error: profErr } = await anon.from('profiles').select('is_admin').eq('id', user.id).maybeSingle();
    if (profErr) return errorJson(profErr.message, 500, 'INTERNAL');
    if (!prof?.is_admin) return errorJson('not_admin', 403, 'FORBIDDEN');

    const body = (await req.json().catch(() => ({}))) as Body;
    const threadId = (body.thread_id ?? '').trim();
    if (!threadId) return errorJson('missing_thread', 400, 'BAD_REQUEST');

    const svc = createServiceClient();
    const { data: thread, error: thrErr } = await svc
      .from('whatsapp_threads')
      .select('*')
      .eq('id', threadId)
      .maybeSingle();
    if (thrErr) return errorJson(thrErr.message, 500, 'INTERNAL');
    if (!thread) return errorJson('thread_not_found', 404, 'NOT_FOUND');

    const waId = (thread as any).wa_id as string;
    const csw = isCswOpen((thread as any).last_inbound_at ?? null);

    // Action: create token + send booking link (text if CSW open, template if closed)
    if (body.action === 'send_booking_link') {
      const expiresMinutes = Math.max(5, Math.min(240, Number(body.expires_minutes ?? 30) || 30));
      const { data: token, error: tokErr } = await svc.rpc('whatsapp_booking_token_create_v1', {
        p_thread_id: threadId,
        p_expires_minutes: expiresMinutes,
      });
      if (tokErr) return errorJson(tokErr.message, 500, 'INTERNAL');
      const rawToken = typeof token === 'string' ? token : String(token);
      const link = buildBookingLink(rawToken);

      let out: any = null;
      let msgType: 'text' | 'template' = 'text';
      let messageBody: string | null = null;
      let tplName: string | null = null;
      let tplLang: string | null = null;
      let tplComponents: unknown[] | null = null;

      if (csw.open) {
        messageBody = bookingLinkMessage(link);
        out = await sendWhatsAppText(waId, messageBody);
        msgType = 'text';
      } else {
        // Template required outside the 24h customer service window.
        const name = (body.template?.name ?? env('WHATSAPP_BOOKING_TEMPLATE_NAME') ?? '').trim();
        if (!name) {
          return errorJson(
            'template_required',
            409,
            'TEMPLATE_REQUIRED',
            { csw_open: false, csw_expires_at: csw.expiresAt, hint: 'Set WHATSAPP_BOOKING_TEMPLATE_NAME or pass body.template' },
          );
        }
        const language = (body.template?.language ?? env('WHATSAPP_TEMPLATE_LANG') ?? 'en_US').trim() || 'en_US';
        // Default: 1 body parameter with the booking link
        const components =
          Array.isArray(body.template?.components) && body.template!.components!.length
            ? body.template!.components!
            : [
                {
                  type: 'body',
                  parameters: [{ type: 'text', text: link }],
                },
              ];

        out = await sendWhatsAppTemplate(waId, { name, language, components });
        msgType = 'template';
        tplName = name;
        tplLang = language;
        tplComponents = components as any;
      }

      // Persist outbound message best-effort
      try {
        await svc.from('whatsapp_messages').insert({
          thread_id: threadId,
          wa_message_id: (out as any)?.messages?.[0]?.id ?? null,
          provider_message_id: (out as any)?.messages?.[0]?.id ?? null,
          direction: 'out',
          msg_type: msgType,
          body: messageBody,
          template_name: tplName,
          template_lang: tplLang,
          template_components: tplComponents,
          payload: { out, action: 'send_booking_link', link },
        });
      } catch (e) {
        ctx.log('wa_outbound_persist_failed', { err: String(e) });
      }

      await svc
        .from('whatsapp_threads')
        .update({ last_outbound_at: new Date().toISOString(), last_message_at: new Date().toISOString() })
        .eq('id', threadId);

      return json({ ok: true, sent: true, action: 'send_booking_link', link, csw_open: csw.open });
    
    // Action: send interactive menu (Session message; only when CSW open)
    if (body.action === 'send_menu') {
      if (!csw.open) {
        return errorJson('template_required', 409, 'TEMPLATE_REQUIRED', { csw_open: false, csw_expires_at: csw.expiresAt, hint: 'Interactive list messages require CSW open. Use a template (or open window) to re-engage.' });
      }

      const sections = [
        {
          title: 'Ride booking',
          rows: [
            { id: 'start_booking', title: 'Start booking', description: 'Begin a new ride request' },
            { id: 'share_pickup', title: 'Send pickup location', description: 'Share where you are' },
            { id: 'share_dropoff', title: 'Send dropoff location', description: 'Where are you going?' },
            { id: 'cancel', title: 'Cancel', description: 'Stop this request' },
          ],
        },
      ];

      const out = await sendWhatsAppList(waId, menuMessage(), 'Open menu', sections);

      try {
        await svc.from('whatsapp_messages').insert({
          thread_id: threadId,
          wa_message_id: (out as any)?.messages?.[0]?.id ?? null,
          provider_message_id: (out as any)?.messages?.[0]?.id ?? null,
          direction: 'out',
          msg_type: 'interactive_list',
          body: menuMessage(),
          payload: { out, action: 'send_menu', sections },
        });
      } catch (e) {
        ctx.log('wa_outbound_persist_failed', { err: String(e) });
      }

      await svc
        .from('whatsapp_threads')
        .update({ last_outbound_at: new Date().toISOString(), last_message_at: new Date().toISOString() })
        .eq('id', threadId);

      return json({ ok: true, sent: true, action: 'send_menu', csw_open: true });
    }

}

    // Plain send: message OR template
    const message = (body.message ?? '').trim();
    const tpl = body.template;

    if (!message && !tpl) return errorJson('missing_message_or_template', 400, 'BAD_REQUEST');

    // Enforce policy: free-form messages only within 24h window.
    if (message && !csw.open) {
      return errorJson('template_required', 409, 'TEMPLATE_REQUIRED', { csw_open: false, csw_expires_at: csw.expiresAt });
    }

    let out: any = null;
    let msgType: 'text' | 'template' = 'text';
    let bodyText: string | null = null;
    let tplName: string | null = null;
    let tplLang: string | null = null;
    let tplComponents: unknown[] | null = null;

    if (tpl) {
      const name = (tpl.name ?? '').trim();
      if (!name) return errorJson('missing_template_name', 400, 'BAD_REQUEST');
      const language = (tpl.language ?? env('WHATSAPP_TEMPLATE_LANG') ?? 'en_US').trim() || 'en_US';
      out = await sendWhatsAppTemplate(waId, { name, language, components: tpl.components });
      msgType = 'template';
      tplName = name;
      tplLang = language;
      tplComponents = Array.isArray(tpl.components) ? tpl.components : null;
    } else {
      bodyText = message;
      out = await sendWhatsAppText(waId, bodyText);
      msgType = 'text';
    }

    // Persist outbound message best-effort
    try {
      await svc.from('whatsapp_messages').insert({
        thread_id: threadId,
        wa_message_id: (out as any)?.messages?.[0]?.id ?? null,
        provider_message_id: (out as any)?.messages?.[0]?.id ?? null,
        direction: 'out',
        msg_type: msgType,
        body: bodyText,
        template_name: tplName,
        template_lang: tplLang,
        template_components: tplComponents,
        payload: { out },
      });
    } catch (e) {
      ctx.log('wa_outbound_persist_failed', { err: String(e) });
    }

    await svc
      .from('whatsapp_threads')
      .update({ last_outbound_at: new Date().toISOString(), last_message_at: new Date().toISOString() })
      .eq('id', threadId);

    return json({ ok: true, sent: true, csw_open: csw.open });
  }),
);
