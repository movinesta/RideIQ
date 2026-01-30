import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { handleOptions, corsHeaders } from "../_shared/cors.ts";
import { errorJson, json } from "../_shared/json.ts";
import { createServiceClient } from "../_shared/supabase.ts";
import { requireWebhookSecret } from "../_shared/webhookAuth.ts";
import { AI_ASSISTANT_PROFILE_ID, ensureAiAssistantProfile } from "../_shared/assistant.ts";
import {
  callOpenRouterResponses,
  extractFunctionCalls,
  extractOutputText,
  type ResponsesInputItem,
  type ToolDef,
} from "../_shared/openrouter.ts";

/**
 * merchant-chat-autoreply
 *
 * Trigger: Supabase Database Webhook on public.merchant_chat_messages (INSERT)
 *
 * If merchant enabled autopilot for the thread, the AI replies as a 3rd participant
 * (sender_id = AI_ASSISTANT_PROFILE_ID).
 *
 * Design constraints:
 * - No cron jobs: event-driven via Database Webhooks.
 * - Iraqi Arabic only.
 * - Idempotent on webhook retries via merchant_chat_ai_receipts.
 */

type WebhookPayload<T> =
  | { type: "INSERT" | "UPDATE" | "DELETE"; table: string; schema: string; record: T | null; old_record: T | null }
  | Record<string, unknown>;

type ChatMsg = {
  id: string;
  thread_id: string;
  sender_id: string;
  message_type: string;
  body: string | null;
  created_at: string;
};

const MODEL = (Deno.env.get("OPENROUTER_MODEL") ?? "arcee-ai/trinity-mini:free").trim();

function shouldAutoReplySmart(text: string): boolean {
  const t = text.trim();
  if (!t) return false;

  // Basic Iraqi Arabic retail intent + questions.
  const needles = [
    "سعر",
    "بكم",
    "شكد",
    "كم",
    "خصم",
    "عرض",
    "توصيل",
    "التوصيل",
    "موجود",
    "متوفر",
    "شنو",
    "شنو عندكم",
    "شنو موجود",
    "وين",
    "اللوكيشن",
    "اطلب",
    "طلب",
    "اوردر",
    "مواد",
    "قائمة",
    "منيو",
    "menu",
    "price",
    "discount",
  ];

  const low = t.toLowerCase();
  if (t.includes("?") || t.endsWith("؟")) return true;
  if (needles.some((n) => low.includes(n))) return true;

  // If the user mentions numbers/currency, likely a pricing/order question.
  if (/\b\d+\b/.test(low) && (low.includes("د") || low.includes("iqd") || low.includes("دينار"))) return true;
  return false;
}

function systemPrompt(merchantName: string) {
  return `انت مساعد ذكي داخل دردشة متجر (التاجر + الزبون + المساعد).

قواعد مهمة:
- لازم تكتب باللهجة العراقية فقط.
- هدفك تساعد الزبون يكمل طلبه بسرعة: تسأل أسئلة توضيحية قصيرة، وتعرض بدائل.
- لا تخترع أسعار/مخزون: إذا ما موجود بالبيانات، قل "ما عندي تأكيد" واطلب من التاجر.
- إذا سأل الزبون عن خصومات/عروض، دَوّر العروض الفعالة.
- إذا الموضوع ما يخص المنتجات/الأسعار/التوصيل/الطلب، جاوب بشكل عام وباختصار.
- اسم المتجر: ${merchantName}
`;
}

function buildTools(
  svc: ReturnType<typeof createServiceClient>,
  merchantId: string,
): { tools: ToolDef[]; runTool: (name: string, args: any) => Promise<any> } {
  const tools: ToolDef[] = [
    {
      type: "function",
      name: "search_merchant_catalog",
      description: "البحث في منتجات المتجر (اسم/وصف/تصنيف) مع الأسعار.",
      parameters: {
        type: "object",
        properties: {
          q: { type: "string" },
          limit: { type: "integer", minimum: 1, maximum: 30, default: 10 },
        },
        required: ["q"],
      },
    },
    {
      type: "function",
      name: "list_active_promotions",
      description: "جلب العروض/الخصومات الفعالة لهذا المتجر.",
      parameters: {
        type: "object",
        properties: {
          limit: { type: "integer", minimum: 1, maximum: 30, default: 10 },
        },
        required: [],
      },
    },
    {
      type: "function",
      name: "get_merchant_catalog",
      description: "جلب كاتالوك المتجر (اهم المنتجات الفعالة) حتى تجاوب بسرعة.",
      parameters: {
        type: "object",
        properties: {
          limit: { type: "integer", minimum: 1, maximum: 120, default: 50 },
        },
        required: [],
      },
    },
  ];

  async function runTool(name: string, args: any) {
    if (name === "search_merchant_catalog") {
      const q = String(args?.q ?? "").trim();
      const limit = Math.max(1, Math.min(30, Number(args?.limit ?? 10)));
      if (!q) return [];

      // Use existing RPC (already scopes by merchant_id)
      const { data, error } = await svc.rpc("search_catalog_v1", {
        p_merchant_id: merchantId,
        p_query: q,
        p_limit: limit,
      });
      if (error) throw error;
      return data ?? [];
    }

    if (name === "list_active_promotions") {
      const limit = Math.max(1, Math.min(30, Number(args?.limit ?? 10)));
      const now = new Date().toISOString();
      const { data, error } = await svc
        .from("merchant_promotions")
        .select("id,discount_type,value,starts_at,ends_at,is_active,product_id,category,metadata,created_at")
        .eq("merchant_id", merchantId)
        .eq("is_active", true)
        .or(`starts_at.is.null,starts_at.lte.${now}`)
        .or(`ends_at.is.null,ends_at.gte.${now}`)
        .order("created_at", { ascending: false })
        .limit(limit);
      if (error) throw error;
      return data ?? [];
    }

    if (name === "get_merchant_catalog") {
      const limit = Math.max(1, Math.min(120, Number(args?.limit ?? 50)));
      const { data, error } = await svc
        .from("merchant_products")
        .select("id,name,category,price_iqd,compare_at_price_iqd,is_active,stock_qty,updated_at")
        .eq("merchant_id", merchantId)
        .eq("is_active", true)
        .order("is_featured", { ascending: false })
        .order("updated_at", { ascending: false })
        .limit(limit);
      if (error) throw error;
      return data ?? [];
    }

    throw new Error(`Unknown tool: ${name}`);
  }

  return { tools, runTool };
}

async function runAgentForMerchantChat(
  svc: ReturnType<typeof createServiceClient>,
  merchantId: string,
  merchantName: string,
  transcript: string,
  userText: string,
) {
  const { tools, runTool } = buildTools(svc, merchantId);

  let input: ResponsesInputItem[] = [
    { type: "message", role: "system", content: [{ type: "input_text", text: systemPrompt(merchantName) }] },
    {
      type: "message",
      role: "user",
      content: [
        {
          type: "input_text",
          text: `محادثة سابقة:\n${transcript}\n\nهسه رسالة جديدة:\n${userText}`,
        },
      ],
    },
  ];

  // Tool loop: max 3 hops (fast and safe)
  for (let step = 0; step < 3; step++) {
    const resp = await callOpenRouterResponses({
      model: MODEL,
      input,
      tools,
      tool_choice: "auto",
      reasoning: { effort: "low" },
      temperature: 0.35,
      max_output_tokens: 260,
    });

    const calls = extractFunctionCalls(resp);
    const text = extractOutputText(resp);

    if (!calls.length) return (text ?? "").trim();

    for (const c of calls) {
      let out: any;
      try {
        const args = JSON.parse(c.arguments || "{}");
        out = await runTool(c.name, args);
      } catch (e) {
        out = { error: String(e) };
      }

      input.push({ type: "function_call", id: c.id, call_id: c.call_id, name: c.name, arguments: c.arguments });
      input.push({ type: "function_call_output", id: crypto.randomUUID(), call_id: c.call_id, output: JSON.stringify(out) });
    }
  }

  return "ما كدرت اوصل لجواب دقيق. ممكن توضح سؤالك اكثر؟";
}

serve(async (req) => {
  const opt = handleOptions(req);
  if (opt) return opt;
  if (req.method !== "POST") return errorJson("Method not allowed", 405);

  // Shared-secret auth (verify_jwt=false)
  const auth = requireWebhookSecret(req, "MERCHANT_CHAT_WEBHOOK_SECRET", "x-webhook-secret");
  if (auth) return auth;

  const payload = (await req.json().catch(() => ({}))) as WebhookPayload<ChatMsg>;

  const type = (payload as any)?.type;
  const table = (payload as any)?.table;
  const record = (payload as any)?.record;

  if (type !== "INSERT" || table !== "merchant_chat_messages" || !record) {
    return json({ ok: true, ignored: true, reason: "not_target_event" }, 200, corsHeaders);
  }

  const msg = record as ChatMsg;
  if (!msg.id || !msg.thread_id) return errorJson("Invalid payload", 400, "BAD_REQUEST");

  // Skip AI/self/system messages
  if (String(msg.message_type ?? "") === "ai") return json({ ok: true, ignored: true, reason: "already_ai" }, 200, corsHeaders);
  if (String(msg.sender_id ?? "") === AI_ASSISTANT_PROFILE_ID) return json({ ok: true, ignored: true, reason: "ai_sender" }, 200, corsHeaders);

  const body = String(msg.body ?? "").trim();
  if (!body) return json({ ok: true, ignored: true, reason: "empty" }, 200, corsHeaders);

  const svc = createServiceClient();

  // Load thread + settings
  const { data: thread, error: tErr } = await svc
    .from("merchant_chat_threads")
    .select("id,merchant_id,customer_id")
    .eq("id", msg.thread_id)
    .maybeSingle();
  if (tErr || !thread) return errorJson(tErr?.message ?? "Thread not found", 400, "DB_ERROR");

  // Only auto-reply on customer messages.
  if (String((thread as any).customer_id) !== String(msg.sender_id)) {
    return json({ ok: true, ignored: true, reason: "not_customer_message" }, 200, corsHeaders);
  }

  const merchantId = String((thread as any).merchant_id);

  const [{ data: settings }, { data: merchant }] = await Promise.all([
    svc
      .from("merchant_chat_ai_settings")
      .select("auto_enabled,auto_reply_mode,min_gap_seconds")
      .eq("thread_id", msg.thread_id)
      .maybeSingle(),
    svc.from("merchants").select("id,business_name").eq("id", merchantId).maybeSingle(),
  ]);

  const s = settings as any;
  if (!s?.auto_enabled) {
    return json({ ok: true, ignored: true, reason: "auto_disabled" }, 200, corsHeaders);
  }

  const mode = String(s.auto_reply_mode ?? "smart");
  if (mode === "smart" && !shouldAutoReplySmart(body)) {
    return json({ ok: true, ignored: true, reason: "smart_filter_no_match" }, 200, corsHeaders);
  }

  // Rate-limit: don't auto reply too frequently in the same thread.
  const minGap = Math.max(0, Math.min(300, Number(s.min_gap_seconds ?? 15)));
  if (minGap > 0) {
    const since = new Date(Date.now() - minGap * 1000).toISOString();
    const { count, error: cErr } = await svc
      .from("merchant_chat_messages")
      .select("id", { count: "exact", head: true })
      .eq("thread_id", msg.thread_id)
      .eq("message_type", "ai")
      .gte("created_at", since);
    if (!cErr && (count ?? 0) > 0) {
      return json({ ok: true, ignored: true, reason: "rate_limited" }, 200, corsHeaders);
    }
  }

  // Idempotency: claim a receipt (webhook retries / duplicates)
  const { error: insReceiptErr } = await svc.from("merchant_chat_ai_receipts").insert({ message_id: msg.id, thread_id: msg.thread_id });
  if (insReceiptErr) {
    const m = String(insReceiptErr.message ?? "");
    if (m.includes("23505") || m.toLowerCase().includes("duplicate")) {
      return json({ ok: true, ignored: true, reason: "duplicate_receipt" }, 200, corsHeaders);
    }
    return errorJson(insReceiptErr.message, 400, "DB_ERROR");
  }

  try {
    // Build a compact transcript (last 25 messages)
    const { data: lastMsgs, error: lmErr } = await svc
      .from("merchant_chat_messages")
      .select("id,sender_id,message_type,body,created_at")
      .eq("thread_id", msg.thread_id)
      .order("created_at", { ascending: false })
      .limit(25);
    if (lmErr) throw lmErr;

    const merchantName = (merchant as any)?.business_name ?? "المتجر";

    const transcript = (lastMsgs ?? [])
      .slice()
      .reverse()
      .map((m: any) => {
        const isAi = String(m.message_type) === "ai" || String(m.sender_id) === AI_ASSISTANT_PROFILE_ID;
        const who = isAi ? "المساعد" : String(m.sender_id) === String((thread as any).customer_id) ? "الزبون" : "التاجر";
        const icon = isAi ? "🤖" : "👤";
        const txt = String(m.body ?? "").replaceAll("\n", " ").trim();
        return txt ? `${icon} ${who}: ${txt}` : null;
      })
      .filter(Boolean)
      .join("\n");

    const reply = await runAgentForMerchantChat(svc, merchantId, merchantName, transcript, body);
    const finalText = String(reply ?? "").trim();
    if (!finalText) return json({ ok: true, ignored: true, reason: "empty_reply" }, 200, corsHeaders);

    await ensureAiAssistantProfile();

    const { error: insErr } = await svc.from("merchant_chat_messages").insert({
      thread_id: msg.thread_id,
      sender_id: AI_ASSISTANT_PROFILE_ID,
      body: finalText,
      message_type: "ai",
    });
    if (insErr) throw insErr;

    return json({ ok: true, replied: true }, 200, corsHeaders);
  } catch (e) {
    // If we failed to reply, remove the receipt so a webhook retry can attempt again.
    await svc.from("merchant_chat_ai_receipts").delete().eq("message_id", msg.id);
    return errorJson(String((e as any)?.message ?? e), 500, "INTERNAL");
  }
});
