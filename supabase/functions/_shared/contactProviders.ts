import { encodeBase64 } from "https://deno.land/std@0.224.0/encoding/base64.ts";

export type ContactSendRequest = {
  channel: "sms" | "whatsapp" | "webhook";
  to: string;
  message: string;
  meta?: Record<string, unknown>;
};

export type ContactSendResult = {
  ok: boolean;
  status: number;
  providerMessageId?: string;
  responseText?: string;
  retryable?: boolean;
};

/**
 * Minimal E.164-ish normalization: trim spaces.
 * Provider-specific validation happens at provider layer.
 */
export function normalizePhone(v: string): string {
  return (v ?? "").trim();
}

function isRetryableStatus(status: number): boolean {
  // 429 (rate limit) and 5xx generally retryable.
  return status === 429 || (status >= 500 && status <= 599);
}

export function computeBackoffSeconds(attempts: number): number {
  // Exponential backoff with cap: 30s, 60s, 120s, 240s... up to 1 hour.
  const base = 30;
  const exp = Math.max(0, Math.min(10, attempts)); // cap exponent
  const seconds = base * Math.pow(2, exp);
  return Math.min(3600, Math.trunc(seconds));
}

async function sendViaWebhook(req: ContactSendRequest): Promise<ContactSendResult> {
  const webhookUrl = (Deno.env.get("CONTACT_WEBHOOK_URL") ?? "").trim();
  const webhookAuth = (Deno.env.get("CONTACT_WEBHOOK_AUTH") ?? "").trim();
  if (!webhookUrl) {
    return { ok: false, status: 0, responseText: "CONTACT_WEBHOOK_URL not configured", retryable: false };
  }

  const res = await fetch(webhookUrl, {
    method: "POST",
    headers: {
      "content-type": "application/json",
      ...(webhookAuth ? { authorization: webhookAuth } : {}),
    },
    body: JSON.stringify({
      channel: req.channel,
      to: req.to,
      message: req.message,
      meta: req.meta ?? {},
    }),
  });

  const text = await res.text().catch(() => "");
  // Some providers return JSON with message_id.
  let providerMessageId: string | undefined;
  try {
    const parsed = JSON.parse(text);
    providerMessageId = typeof parsed?.message_id === "string" ? parsed.message_id : undefined;
  } catch {
    // ignore
  }

  return {
    ok: res.ok,
    status: res.status,
    responseText: text.slice(0, 1000),
    providerMessageId,
    retryable: !res.ok && isRetryableStatus(res.status),
  };
}

async function sendViaTwilioSms(req: ContactSendRequest): Promise<ContactSendResult> {
  const accountSid = (Deno.env.get("TWILIO_ACCOUNT_SID") ?? "").trim();
  const authToken = (Deno.env.get("TWILIO_AUTH_TOKEN") ?? "").trim();
  const from = (Deno.env.get("TWILIO_FROM") ?? "").trim(); // E.164 or MessagingServiceSid
  const messagingServiceSid = (Deno.env.get("TWILIO_MESSAGING_SERVICE_SID") ?? "").trim();

  if (!accountSid || !authToken || (!from && !messagingServiceSid)) {
    return { ok: false, status: 0, responseText: "Twilio not configured", retryable: false };
  }

  const url = `https://api.twilio.com/2010-04-01/Accounts/${accountSid}/Messages.json`;
  const auth = encodeBase64(new TextEncoder().encode(`${accountSid}:${authToken}`));

  const params = new URLSearchParams();
  params.set("To", req.to);
  params.set("Body", req.message);
  if (messagingServiceSid) params.set("MessagingServiceSid", messagingServiceSid);
  else params.set("From", from);

  const res = await fetch(url, {
    method: "POST",
    headers: {
      authorization: `Basic ${auth}`,
      "content-type": "application/x-www-form-urlencoded",
    },
    body: params.toString(),
  });

  const text = await res.text().catch(() => "");
  let providerMessageId: string | undefined;
  try {
    const parsed = JSON.parse(text);
    providerMessageId = typeof parsed?.sid === "string" ? parsed.sid : undefined;
  } catch {
    // ignore
  }

  return {
    ok: res.ok,
    status: res.status,
    responseText: text.slice(0, 1000),
    providerMessageId,
    retryable: !res.ok && isRetryableStatus(res.status),
  };
}

async function sendViaWhatsAppCloud(req: ContactSendRequest): Promise<ContactSendResult> {
  // WhatsApp Cloud API typically requires templates outside 24h window.
  const token = (Deno.env.get("WHATSAPP_TOKEN") ?? "").trim();
  const phoneNumberId = (Deno.env.get("WHATSAPP_PHONE_NUMBER_ID") ?? "").trim();
  const templateName = (Deno.env.get("WHATSAPP_TEMPLATE_NAME") ?? "rideiq_safety_alert").trim();
  const templateLang = (Deno.env.get("WHATSAPP_TEMPLATE_LANG") ?? "en_US").trim();

  if (!token || !phoneNumberId) {
    return { ok: false, status: 0, responseText: "WhatsApp Cloud not configured", retryable: false };
  }

  const url = `https://graph.facebook.com/v21.0/${phoneNumberId}/messages`;

  // Default: template message with one body parameter = message text.
  // You can customize templates to include share_url separately.
  const body = {
    messaging_product: "whatsapp",
    to: req.to.replace("+", ""), // many setups use MSISDN without '+'
    type: "template",
    template: {
      name: templateName,
      language: { code: templateLang },
      components: [
        {
          type: "body",
          parameters: [{ type: "text", text: req.message }],
        },
      ],
    },
  };

  const res = await fetch(url, {
    method: "POST",
    headers: {
      authorization: `Bearer ${token}`,
      "content-type": "application/json",
    },
    body: JSON.stringify(body),
  });

  const text = await res.text().catch(() => "");
  let providerMessageId: string | undefined;
  try {
    const parsed = JSON.parse(text);
    const id = parsed?.messages?.[0]?.id;
    providerMessageId = typeof id === "string" ? id : undefined;
  } catch {
    // ignore
  }

  return {
    ok: res.ok,
    status: res.status,
    responseText: text.slice(0, 1000),
    providerMessageId,
    retryable: !res.ok && isRetryableStatus(res.status),
  };
}

export async function sendContactMessage(req: ContactSendRequest): Promise<ContactSendResult> {
  const provider = (Deno.env.get("CONTACT_PROVIDER") ?? "webhook").trim().toLowerCase();

  if (provider === "twilio_sms") {
    return await sendViaTwilioSms(req);
  }

  if (provider === "whatsapp_cloud") {
    return await sendViaWhatsAppCloud(req);
  }

  // default provider: webhook
  return await sendViaWebhook(req);
}
