import { handleOptions } from '../_shared/cors.ts';
import { hmacSha256Bytes, safeJsonParse, timingSafeEqual } from '../_shared/crypto.ts';
import { errorJson, json } from '../_shared/json.ts';
import { withRequestContext } from '../_shared/requestContext.ts';
import { createServiceClient } from '../_shared/supabase.ts';

type StatusUpdate = {
  id: string;           // message id being updated (business outbound id)
  status: string;       // sent|delivered|read|failed
  timestamp?: string;   // unix seconds as string
  recipient_id?: string;
  errors?: unknown;
  raw: unknown;
};

function extractStatusUpdates(payload: WebhookPayload): StatusUpdate[] {
  const entry = Array.isArray(payload.entry) ? payload.entry[0] : null;
  const changes = entry && typeof entry === 'object' ? (entry as any).changes : null;
  const value = Array.isArray(changes) ? changes[0]?.value : null;
  const statuses = value?.statuses;
  if (!Array.isArray(statuses)) return [];
  const out: StatusUpdate[] = [];
  for (const st of statuses) {
    const id = typeof st?.id === 'string' ? st.id : null;
    const status = typeof st?.status === 'string' ? st.status : null;
    if (!id || !status) continue;
    out.push({
      id,
      status,
      timestamp: typeof st?.timestamp === 'string' ? st.timestamp : undefined,
      recipient_id: typeof st?.recipient_id === 'string' ? st.recipient_id : undefined,
      errors: st?.errors,
      raw: st,
    });
  }
  return out;
}

function unixSecondsToIso(ts?: string): string | null {
  if (!ts) return null;
  const n = Number(ts);
  if (!Number.isFinite(n)) return null;
  return new Date(n * 1000).toISOString();
}

function toHex(bytes: Uint8Array): string {
  return Array.from(bytes).map((b) => b.toString(16).padStart(2, '0')).join('');
}

async function sha256Hex(input: string): Promise<string> {
  const digest = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(input));
  return toHex(new Uint8Array(digest));
}

function env(key: string): string {
  return (('permissions' in Deno) ? Deno.env.get(key) : (Deno.env.get(key))) ?? '';
}

type WebhookPayload = Record<string, unknown>;

type LocationPayload = {
  latitude?: number;
  longitude?: number;
  name?: string;
  address?: string;
};

function extractFirstMessage(payload: WebhookPayload): {
  waId?: string;
  phoneE164?: string;
  messageId?: string;
  type?: string;
  textBody?: string;
  buttonId?: string;
  location?: LocationPayload | null;
  raw?: unknown;
} {
  const entry = Array.isArray(payload.entry) ? payload.entry[0] : null;
  const changes = entry && typeof entry === 'object' ? (entry as any).changes : null;
  const value = Array.isArray(changes) ? changes[0]?.value : null;
  const messages = value?.messages;
  const contacts = value?.contacts;

  const msg = Array.isArray(messages) ? messages[0] : null;
  if (!msg) return {};
  const waId = typeof msg.from === 'string' ? msg.from : undefined;
  const messageId = typeof msg.id === 'string' ? msg.id : undefined;
  const type = typeof msg.type === 'string' ? msg.type : undefined;

  const phoneE164 =
    Array.isArray(contacts) && contacts[0]?.wa_id && typeof contacts[0].wa_id === 'string' ? `+${contacts[0].wa_id}` : undefined;

  const textBody = type === 'text' && msg.text && typeof msg.text.body === 'string' ? msg.text.body : undefined;
  const buttonId =
    type === 'button' && msg.button && typeof msg.button.payload === 'string' ? msg.button.payload : (
      type === 'interactive' && msg.interactive && msg.interactive.button_reply && typeof msg.interactive.button_reply.id === 'string' ? msg.interactive.button_reply.id : (
      type === 'interactive' && msg.interactive && msg.interactive.list_reply && typeof msg.interactive.list_reply.id === 'string' ? msg.interactive.list_reply.id : undefined
    )
    );

  const buttonTitle =
    type === 'button' && msg.button && typeof msg.button.text === 'string' ? msg.button.text : (
      type === 'interactive' && msg.interactive && msg.interactive.button_reply && typeof msg.interactive.button_reply.title === 'string' ? msg.interactive.button_reply.title : (
      type === 'interactive' && msg.interactive && msg.interactive.list_reply && typeof msg.interactive.list_reply.title === 'string' ? msg.interactive.list_reply.title : undefined
    )
    );

  const effectiveTextBody =
    textBody ?? buttonTitle;


  const location: LocationPayload | null =
    type === 'location' && msg.location && typeof msg.location === 'object' ? (msg.location as LocationPayload) : null;

  return { waId, phoneE164, messageId, type, textBody, location, raw: msg };
}

function buildPickupPrompt() {
  const en =
    "Welcome to RideIQ! Please share your pickup location.\n\nWhatsApp → 📎 Attach → Location → Send current location.";
  const ar =
    "مرحباً بك في RideIQ! يرجى إرسال موقع الالتقاط.\n\nواتساب → 📎 إرفاق → الموقع → إرسال الموقع الحالي.";
  return `${en}\n\n${ar}`;
}

function buildDropoffPrompt() {
  const en =
    "Great. Now please share your drop-off location.\n\nWhatsApp → 📎 Attach → Location → Send location.";
  const ar =
    "تم. الآن يرجى إرسال موقع الوصول (الإنزال).\n\nواتساب → 📎 إرفاق → الموقع → إرسال الموقع.";
  return `${en}\n\n${ar}`;
}

function buildNeedLocationPrompt() {
  const en =
    "For accurate routing, please send a location pin (not just text).\n\nWhatsApp → 📎 Attach → Location.";
  const ar =
    "لضمان دقة المسار، يرجى إرسال الموقع كـ (Location) وليس كنص فقط.\n\nواتساب → 📎 إرفاق → الموقع.";
  return `${en}\n\n${ar}`;
}

function buildHelpPrompt() {
  const en =
    "Commands:\nSTART — new request\nPICKUP — change pickup\nDROPOFF — change drop-off\nLINK — resend confirmation link\nCANCEL — close\n\nSend locations as pins: 📎 → Location.";
  const ar =
    "الأوامر:\nSTART — طلب جديد\nPICKUP — تغيير موقع الالتقاط\nDROPOFF — تغيير موقع الوصول\nLINK — إعادة إرسال رابط التأكيد\nCANCEL — إغلاق\n\nأرسل الموقع كـ Location: 📎 → الموقع.";
  return `${en}\n\n${ar}`;
}

function buildLinkMessage(link: string) {
  const en = `Thanks! Open this link to confirm the ride:\n${link}`;
  const ar = `شكراً! افتح الرابط لتأكيد طلب المشوار:\n${link}`;
  return `${en}\n\n${ar}`;
}


async function sendWhatsAppReplyButtons(toWaId: string, bodyText: string, buttons: { id: string; title: string }[]) {
  const token = env('WHATSAPP_TOKEN');
  const phoneNumberId = env('WHATSAPP_PHONE_NUMBER_ID');
  const version = env('WHATSAPP_GRAPH_VERSION') || 'v21.0';
  if (!token || !phoneNumberId) throw new Error('Missing WHATSAPP_TOKEN or WHATSAPP_PHONE_NUMBER_ID');

  const trimmed = buttons.slice(0, 3);
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
        type: 'button',
        body: { text: bodyText },
        action: {
          buttons: trimmed.map((b) => ({
            type: 'reply',
            reply: { id: b.id, title: b.title },
          })),
        },
      },
    }),
  });

  const out = await res.json().catch(() => ({}));
  if (!res.ok) {
    const msg = typeof (out as any)?.error?.message === 'string' ? (out as any).error.message : `HTTP ${res.status}`;
    throw new Error(`whatsapp_send_buttons_failed: ${msg}`);
  }
  return out;
}

async function sendWhatsAppListMessage(toWaId: string, bodyText: string, buttonText: string, sections: { title: string; rows: { id: string; title: string; description?: string }[] }[]) {
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
    throw new Error(`whatsapp_send_list_failed: ${msg}`);
  }
  return out;
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

async function verifyMetaSignature(rawBody: string, header: string | null) {
  const appSecret = env('WHATSAPP_APP_SECRET');
  if (!appSecret) return false;
  const sig = header?.trim() ?? '';
  if (!sig.toLowerCase().startsWith('sha256=')) return false;
  const expected = sig.slice('sha256='.length);
  const mac = await hmacSha256Bytes(appSecret, rawBody);
  const actual = toHex(mac);
  return timingSafeEqual(actual, expected);
}

function buildBookingLink(token: string) {
  const base = env('APP_BASE_URL') || 'http://localhost:5173';
  const clean = base.replace(/\/$/, '');
  return `${clean}/booking/${encodeURIComponent(token)}`;
}

Deno.serve((req) =>
  withRequestContext('whatsapp-webhook', req, async (ctx) => {
    if (req.method === 'OPTIONS') return handleOptions(req);

    // Meta verification challenge (GET)
    if (req.method === 'GET') {
      const url = new URL(req.url);
      const mode = url.searchParams.get('hub.mode');
      const challenge = url.searchParams.get('hub.challenge');
      const verifyToken = url.searchParams.get('hub.verify_token');
      const expected = env('META_VERIFY_TOKEN');

      if (mode === 'subscribe' && challenge && expected && verifyToken === expected) {
        return new Response(challenge, { status: 200 });
      }
      return new Response('forbidden', { status: 403 });
    }

    if (req.method !== 'POST') return errorJson('method_not_allowed', 405, 'METHOD_NOT_ALLOWED');

    // Must use raw body for signature verification.
    const rawBody = await req.text();
    const signature = req.headers.get('x-hub-signature-256');

    // Verify signature when secret is configured; for local dev you can omit WHATSAPP_APP_SECRET.
    if (env('WHATSAPP_APP_SECRET')) {
      const ok = await verifyMetaSignature(rawBody, signature);
      if (!ok) return errorJson('invalid_signature', 401, 'UNAUTHORIZED');
    }

    const parsed = safeJsonParse(rawBody);
    if (!parsed) return errorJson('invalid_json', 400, 'BAD_REQUEST');

    
    // Handle message status webhooks (delivery/read/failed) for outbound messages
    const statusUpdates = extractStatusUpdates(parsed);
    if (statusUpdates.length) {
      const svc = createServiceClient();
      for (const st of statusUpdates) {
        const iso = unixSecondsToIso(st.timestamp);
        const patch: Record<string, unknown> = {
          wa_status: st.status,
          status_payload: st.raw,
        };
        if (st.status === 'delivered' && iso) patch.delivered_at = iso;
        if (st.status === 'read' && iso) patch.read_at = iso;
        if (st.status === 'failed' && iso) patch.failed_at = iso;

        // Match by provider_message_id first, fall back to wa_message_id
        const q = svc.from('whatsapp_messages').update(patch).eq('provider_message_id', st.id);
        const { error: e1 } = await q;
        if (e1) {
          // fallback
          await svc.from('whatsapp_messages').update(patch).eq('wa_message_id', st.id);
        }
      }
      return json({ ok: true, statuses: statusUpdates.length });
    }

const { waId, phoneE164, messageId, type, textBody, buttonId, location, raw } = extractFirstMessage(parsed);
    if (!waId || !messageId || !type) {
      // Ignore non-message webhooks
      return json({ ok: true, ignored: true });
    }

    const svc = createServiceClient();
    const nowIso = new Date().toISOString();

    async function sendAndLog(text: string, meta: Record<string, unknown> = {}) {
      const out = await sendWhatsAppText(waId, text);
      // Persist outbound best-effort
      try {
        await svc.from('whatsapp_messages').insert({
          thread_id: thread.id,
          wa_message_id: (out as any)?.messages?.[0]?.id ?? null,
          provider_message_id: (out as any)?.messages?.[0]?.id ?? null,
          direction: 'out',
          msg_type: 'text',
          body: text,
          payload: { out, ...meta },
        });
      } catch (e) {
        ctx.log('outbound_persist_failed', { err: String(e) });
      }
      await svc.from('whatsapp_threads').update({ last_outbound_at: new Date().toISOString(), last_message_at: new Date().toISOString() }).eq('id', thread.id);
      return out;
    
    async function sendAndLogButtons(bodyText: string, buttons: { id: string; title: string }[], meta: Record<string, unknown> = {}) {
      const out = await sendWhatsAppReplyButtons(waId, bodyText, buttons);
      try {
        await svc.from('whatsapp_messages').insert({
          thread_id: thread.id,
          wa_message_id: (out as any)?.messages?.[0]?.id ?? null,
          provider_message_id: (out as any)?.messages?.[0]?.id ?? null,
          direction: 'out',
          msg_type: 'interactive_buttons',
          body: bodyText,
          payload: { out, buttons, ...meta },
        });
      } catch (e) {
        ctx.log('outbound_persist_failed', { err: String(e) });
      }
      await svc.from('whatsapp_threads').update({ last_outbound_at: new Date().toISOString(), last_message_at: new Date().toISOString() }).eq('id', thread.id);
      return out;
    }

}

    async function sendAndLogList(bodyText: string, buttonText: string, sections: { title: string; rows: { id: string; title: string; description?: string }[] }[], meta: Record<string, unknown> = {}) {
      const out = await sendWhatsAppListMessage(waId, bodyText, buttonText, sections);
      try {
        await svc.from('whatsapp_messages').insert({
          thread_id: thread.id,
          wa_message_id: (out as any)?.messages?.[0]?.id ?? null,
          provider_message_id: (out as any)?.messages?.[0]?.id ?? null,
          direction: 'out',
          msg_type: 'interactive_list',
          body: bodyText,
          payload: { out, sections, ...meta },
        });
      } catch (e) {
        ctx.log('outbound_persist_failed', { err: String(e) });
      }
      await svc.from('whatsapp_threads').update({ last_outbound_at: new Date().toISOString(), last_message_at: new Date().toISOString() }).eq('id', thread.id);
      return out;
    }

    // Upsert thread
    const { data: threadRow, error: thrErr } = await svc.from('whatsapp_threads').select('*').eq('wa_id', waId).maybeSingle();
    let thread = threadRow as any;
    if (thrErr) ctx.error('thread_select_failed', { err: String(thrErr) });

    if (!thread) {
      const { data: created, error: createErr } = await svc
        .from('whatsapp_threads')
        .insert({
          wa_id: waId,
          phone_e164: phoneE164 ?? null,
          stage: 'awaiting_pickup',
          last_inbound_at: nowIso,
          last_message_at: nowIso,
        })
        .select('*')
        .single();

      if (createErr) return errorJson('thread_create_failed', 500, 'INTERNAL');
      thread = created;
    } else {
      await svc
        .from('whatsapp_threads')
        .update({
          phone_e164: phoneE164 ?? thread.phone_e164 ?? null,
          last_inbound_at: nowIso,
          last_message_at: nowIso,
        })
        .eq('id', thread.id);
    }

    // Insert inbound message (unique constraint on wa_message_id)
    const { error: msgErr } = await svc.from('whatsapp_messages').insert({
      thread_id: thread.id,
      wa_message_id: messageId,
      direction: 'in',
      msg_type: type,
      body: (type === 'text' || type === 'button' || type === 'interactive') ? (textBody ?? null) : null,
      payload: { raw, webhook: parsed },
    });

    if (msgErr) {
      const pg = (msgErr as any)?.code;
      if (pg === '23505') {
        return json({ ok: true, duplicate: true });
      }
      ctx.error('message_insert_failed', { err: String(msgErr) });
      // Continue anyway (best-effort)
    }

    const text = (textBody ?? '').trim().toLowerCase();
    if (text === 'menu' || text === 'قائمة' || text === 'القائمة') {
      const sections = [
        { title: 'Ride booking', rows: [
          { id: 'start_booking', title: 'Start booking' },
          { id: 'share_pickup', title: 'Send pickup location' },
          { id: 'share_dropoff', title: 'Send dropoff location' },
          { id: 'cancel', title: 'Cancel' },
        ]},
      ];
      await sendAndLogList('Quick menu — اختر خياراً / Choose:', 'Open menu', sections, { kind: 'menu' });
      return json({ ok: true });
    }


    // Quick replies from interactive buttons
    const btn = (buttonId ?? '').trim();
    const isPickupBtn = btn === 'share_pickup';
    const isDropoffBtn = btn === 'share_dropoff';
    const isCancelBtn = btn === 'cancel';
    const isStartBookingBtn = btn === 'start_booking';


    const stage0 = (thread.stage as string) || 'awaiting_pickup';

    // Commands
    if (text === 'help' || text === 'مساعدة' || text === 'مساعده') {
      await sendAndLog(buildHelpPrompt(), { kind: 'help' });
      return json({ ok: true });
    }
    if (isCancelBtn || text === 'cancel' || text === 'الغاء' || text === 'إلغاء') {
      await svc.from('whatsapp_threads').update({ stage: 'closed' }).eq('id', thread.id);
      await sendAndLog('Canceled. To start again, type START.\n\nتم الإلغاء. للبدء من جديد اكتب START.', { kind: 'cancel' });
      return json({ ok: true });
    }
    if (isStartBookingBtn || text === 'start' || text === 'ابدأ' || text === 'ابدا') {
      await svc
        .from('whatsapp_threads')
        .update({ stage: 'awaiting_pickup', pickup_lat: null, pickup_lng: null, dropoff_lat: null, dropoff_lng: null, pickup_address: null, dropoff_address: null })
        .eq('id', thread.id);
      await sendAndLogButtons(buildPickupPrompt(), [{ id: 'share_pickup', title: '📍 Pickup' }, { id: 'cancel', title: 'Cancel' }], { kind: 'start' });
      return json({ ok: true });
    }
    if (isPickupBtn || text === 'pickup') {
      await svc
        .from('whatsapp_threads')
        .update({ stage: 'awaiting_pickup', pickup_lat: null, pickup_lng: null, pickup_address: null })
        .eq('id', thread.id);
      await sendAndLogButtons(buildPickupPrompt(), [{ id: 'share_pickup', title: '📍 Pickup' }, { id: 'cancel', title: 'Cancel' }], { kind: 'pickup' });
      return json({ ok: true });
    }
    if (isDropoffBtn || text === 'dropoff' || text === 'drop-off' || text === 'drop off') {
      if (!thread.pickup_lat || !thread.pickup_lng) {
        await svc.from('whatsapp_threads').update({ stage: 'awaiting_pickup' }).eq('id', thread.id);
        await sendAndLog(buildPickupPrompt(), { kind: 'dropoff_needs_pickup' });
        return json({ ok: true });
      }
      await svc.from('whatsapp_threads').update({ stage: 'awaiting_dropoff' }).eq('id', thread.id);
      await sendAndLogButtons(buildDropoffPrompt(), [{ id: 'share_dropoff', title: '📍 Dropoff' }, { id: 'cancel', title: 'Cancel' }], { kind: 'dropoff' });
      return json({ ok: true });
    }
    if (text === 'link' && stage0 === 'ready') {
      // Re-issue a new token
      const token = Array.from(crypto.getRandomValues(new Uint8Array(32))).map((b) => b.toString(16).padStart(2, '0')).join('');
      const tokenHash = await sha256Hex(token);
      const expiresAt = new Date(Date.now() + 30 * 60 * 1000).toISOString();
      await svc.from('whatsapp_booking_tokens').insert({
        thread_id: thread.id,
        token,
        token_hash: tokenHash,
        expires_at: expiresAt,
        pickup_lat: thread.pickup_lat ?? 0,
        pickup_lng: thread.pickup_lng ?? 0,
        dropoff_lat: thread.dropoff_lat ?? 0,
        dropoff_lng: thread.dropoff_lng ?? 0,
        pickup_address: thread.pickup_address ?? null,
        dropoff_address: thread.dropoff_address ?? null,
      });
      const link = buildBookingLink(token);
      await sendAndLog(buildLinkMessage(link), { kind: 'link' });
      return json({ ok: true, link });
    }

    // State machine
    const stage = stage0;

    if (stage === 'awaiting_pickup') {
      if (type !== 'location' || !location?.latitude || !location?.longitude) {
        await sendAndLog(buildPickupPrompt(), { kind: 'pickup_prompt' });
        return json({ ok: true, next: 'awaiting_pickup' });
      }

      await svc
        .from('whatsapp_threads')
        .update({
          pickup_lat: location.latitude,
          pickup_lng: location.longitude,
          pickup_address: location.address ?? null,
          stage: 'awaiting_dropoff',
        })
        .eq('id', thread.id);

      await sendAndLog(buildDropoffPrompt(), { kind: 'dropoff_prompt' });
      return json({ ok: true, next: 'awaiting_dropoff' });
    }

    if (stage === 'awaiting_dropoff') {
      if (type !== 'location' || !location?.latitude || !location?.longitude) {
        await sendAndLog(buildNeedLocationPrompt(), { kind: 'need_location' });
        return json({ ok: true, next: 'awaiting_dropoff' });
      }

      await svc
        .from('whatsapp_threads')
        .update({
          dropoff_lat: location.latitude,
          dropoff_lng: location.longitude,
          dropoff_address: location.address ?? null,
          stage: 'ready',
        })
        .eq('id', thread.id);

      // Create booking token
      const token = Array.from(crypto.getRandomValues(new Uint8Array(32))).map((b) => b.toString(16).padStart(2, '0')).join('');
      const tokenHash = await sha256Hex(token);
      const expiresAt = new Date(Date.now() + 30 * 60 * 1000).toISOString();

      const { error: tokErr } = await svc.from('whatsapp_booking_tokens').insert({
        thread_id: thread.id,
        token,
        token_hash: tokenHash,
        expires_at: expiresAt,
        pickup_lat: thread.pickup_lat ?? 0,
        pickup_lng: thread.pickup_lng ?? 0,
        dropoff_lat: location.latitude,
        dropoff_lng: location.longitude,
        pickup_address: thread.pickup_address ?? null,
        dropoff_address: location.address ?? null,
      });

      if (tokErr) {
        ctx.error('token_insert_failed', { err: String(tokErr) });
        await sendAndLog('Sorry—something went wrong. Please try again.\n\nحدث خطأ. حاول مرة أخرى.', { kind: 'token_error' });
        return json({ ok: false, error: 'token_insert_failed' }, 500);
      }

      const link = buildBookingLink(token);
      await sendAndLog(buildLinkMessage(link), { kind: 'booking_link', link });
      return json({ ok: true, next: 'ready', link });
    }

    if (stage === 'ready') {
      // If user sends a new location, interpret it as an updated dropoff and re-issue link.
      if (type === 'location' && location?.latitude && location?.longitude) {
        await svc
          .from('whatsapp_threads')
          .update({
            dropoff_lat: location.latitude,
            dropoff_lng: location.longitude,
            dropoff_address: location.address ?? null,
            stage: 'ready',
          })
          .eq('id', thread.id);

        const token = Array.from(crypto.getRandomValues(new Uint8Array(32))).map((b) => b.toString(16).padStart(2, '0')).join('');
        const tokenHash = await sha256Hex(token);
        const expiresAt = new Date(Date.now() + 30 * 60 * 1000).toISOString();

        await svc.from('whatsapp_booking_tokens').insert({
          thread_id: thread.id,
          token,
          token_hash: tokenHash,
          expires_at: expiresAt,
          pickup_lat: thread.pickup_lat ?? 0,
          pickup_lng: thread.pickup_lng ?? 0,
          dropoff_lat: location.latitude,
          dropoff_lng: location.longitude,
          pickup_address: thread.pickup_address ?? null,
          dropoff_address: location.address ?? null,
        });

        const link = buildBookingLink(token);
        await sendAndLog(buildLinkMessage(link), { kind: 'updated_dropoff_link', link });
        return json({ ok: true, next: 'ready', link });
      }
      await sendAndLog('To start a new request, type START.\n\nلبدء طلب جديد اكتب START.', { kind: 'ready_help' });
      return json({ ok: true });
    }

    // closed or unknown
    await sendAndLog('To start a new request, type START.\n\nلبدء طلب جديد اكتب START.', { kind: 'closed_help' });
    return json({ ok: true });
  }),
);
