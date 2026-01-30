import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { handleOptions, getCorsHeaders } from "../_shared/cors.ts";
import { errorJson, json } from "../_shared/json.ts";
import { createAnonClient, createServiceClient, requireUser } from "../_shared/supabase.ts";
import { AI_ASSISTANT_PROFILE_ID, ensureAiAssistantProfile } from "../_shared/assistant.ts";
import {
  callOpenRouterResponses,
  callOpenRouterResponsesStream,
  extractFunctionCalls,
  extractOutputText,
  type ResponsesInputItem,
  type ToolDef,
} from "../_shared/openrouter.ts";

type Surface = "auto" | "copilot" | "merchant_chat" | "driver" | "merchant";

type ReqBody = {
  surface?: Surface;
  message?: string;
  stream?: boolean;
  thread_id?: string; // merchant_chat thread id
  merchant_id?: string; // optional override for merchant tools
  ui_path?: string; // optional UI path hint for auto surface inference
  hours?: number; // driver hotspots
};

const MODEL = (Deno.env.get("OPENROUTER_MODEL") ?? "arcee-ai/trinity-mini:free").trim();

function sysPromptBase() {
  return [
    "انت مساعد ذكي داخل تطبيق RideIQ.",
    "شرط مهم جداً: لازم تجاوب باللهجة العراقية. استخدم العربي بالأساس، بس إذا اكو اسم منتج/مكان/رمز بالإنكليزي خلّه مثل ما هو.",
    "لا تكتب جمل كاملة بالإنكليزي. خلي ردودك عراقية وبالعربي، والإنكليزي فقط للأسماء/الأكواد إذا لازم.",
    "اذا ما متأكد من معلومة، كل بصراحة وما تخمن.",
    "اذا تحتاج بيانات، استخدم الأدوات المتاحة حتى تجيب معلومات دقيقة من قاعدة البيانات.",
    "لا تعرض معلومات حساسة (مثل مفاتيح، توكنات، ايميلات داخلية).",
  ].join("\n");
}

function systemForSurface(surface: Surface): string {
  const base = sysPromptBase();
  switch (surface) {
    case "merchant":
      return [
        base,
        "أنت مساعد ذكي للتاجر داخل RideIQ.",
        "مهمتك: تساعد التاجر يفهم المبيعات، الطلبات، المنتجات، العروض، وتقترح خطوات عملية لزيادة المبيعات.",
        "لا تخمّن أرقام أو حقائق غير موجودة. إذا ما عندك معلومة، كل: ما متأكد / خلّيني أتحقق.",
        "إذا تحتاج بيانات من النظام، اطلبها بشكل محدد (مثال: اسم المنتج، الفترة، رقم الطلب).",
      ].join("\n");
    case "driver":
      return [
        base,
        "أنت مساعد ذكي للسائق داخل RideIQ.",
        "مهمتك: تساعد السائق يزود دخله ورحلاته عبر نصائح مكان/وقت، وتحسين استخدام التطبيق.",
        "لا تعد بنتائج مضمونة. قدّم توصيات مبنية على بيانات التطبيق إذا متوفرة أو قواعد عامة إذا غير متوفرة.",
      ].join("\n");
    case "merchant_chat":
      return [
        base,
        "أنت مساعد ذكي داخل محادثة بين زبون وتاجر في RideIQ.",
        "أنت مشارك ثالث: تساعد الطرفين يكملون الطلب بسرعة ودقة.",
        "ركز على: جمع تفاصيل الطلب، توضيح الأسعار والتوفر، اقتراح بدائل، تلخيص الطلب قبل الإرسال.",
        "إذا ما عندك بيانات (سعر/توفر)، اطلب من التاجر يزوّدك أو اطلب السماح للتحقق من النظام.",
      ].join("\n");
    default:
      return [
        base,
        "أنت مساعد ذكي عام داخل RideIQ.",
        "مهمتك: تساعد المستخدم يسأل عن أي شي داخل التطبيق: عروض، محلات، منتجات، توصيل، رحلات، محفظة، إلخ.",
        "إذا السؤال يحتاج بيانات من النظام، اطلب تفاصيل أو نفّذ أدوات البحث (إذا متاحة).",
        "إذا مو واضح، اسأل سؤال واحد يوضح المطلوب قبل ما تعطي جواب طويل.",
      ].join("\n");
  }
}

async function inferSurfaceFromContext(
  svc: ReturnType<typeof createAnonClient>,
  uiPath?: string | null,
): Promise<Exclude<Surface, "auto" | "merchant_chat">> {
  // Fast path: if the UI tells us what section the user is currently in,
  // prefer it over profile role (role switching can lag, multiple tabs, etc.).
  const p = String(uiPath ?? "").trim();
  if (p.startsWith("/driver")) return "driver";
  if (p.startsWith("/merchant")) return "merchant";

  try {
    const { data } = await svc.rpc("get_my_app_context");
    const row: any = Array.isArray(data) ? (data[0] ?? null) : data;
    const role = String(row?.active_role ?? "").toLowerCase();
    if (role === "driver") return "driver";
    if (role === "merchant") return "merchant";
  } catch (_) {
    // ignore
  }
  return "copilot";
}


function buildTools(svc: ReturnType<typeof createAnonClient>, ctx: { userId: string; merchantId?: string; surface: Surface }) {
  const tools: ToolDef[] = [
    {
      type: "function",
      name: "search_catalog",
      description:
        "بحث موحد عن المحلات والمواد (والصنف) باستخدام RPC واحد. يرجع نتائج مرتبة حسب درجة التطابق.",
      parameters: {
        type: "object",
        properties: {
          query: { type: "string" },
          merchant_id: { type: "string", description: "اختياري: حصر البحث بمتجر معين" },
          limit: { type: "integer", minimum: 1, maximum: 50, default: 10 },
        },
        required: ["query"],
      },
    },
    {
      type: "function",
      name: "search_merchants",
      description: "بحث عن محلات حسب الاسم او نوع النشاط.",
      parameters: {
        type: "object",
        properties: {
          query: { type: "string" },
          limit: { type: "integer", minimum: 1, maximum: 25, default: 10 },
        },
        required: ["query"],
      },
    },
    {
      type: "function",
      name: "search_products",
      description: "بحث عن منتجات (مواد) حسب الاسم او الصنف. ممكن تحدد متجر.",
      parameters: {
        type: "object",
        properties: {
          query: { type: "string" },
          merchant_id: { type: "string" },
          limit: { type: "integer", minimum: 1, maximum: 50, default: 10 },
        },
        required: ["query"],
      },
    },
    {
      type: "function",
      name: "list_active_promotions",
      description: "جلب الخصومات الفعالة حالياً. ممكن تحدد متجر او صنف.",
      parameters: {
        type: "object",
        properties: {
          merchant_id: { type: "string" },
          category: { type: "string" },
          limit: { type: "integer", minimum: 1, maximum: 50, default: 10 },
        },
        required: [],
      },
    },
    {
      type: "function",
      name: "list_my_promotions",
      description:
        "يجلب اهم الخصومات الفعالة حاليا حسب اهتماماتي (متاجر/منتجات/اصناف/كلمات) بدون ما تحتاج تحدد شي.",
      parameters: {
        type: "object",
        properties: {
          limit: { type: "integer", minimum: 1, maximum: 50, default: 10 },
        },
        required: [],
      },
    },
  ];

  if (ctx.surface === "merchant" || ctx.surface === "merchant_chat") {
    tools.push({
      type: "function",
      name: "get_merchant_catalog",
      description: "جلب كاتالوك المتجر (منتجات فعالة مع اسعار) حتى تجاوب الزبون.",
      parameters: { type: "object", properties: { merchant_id: { type: "string" }, limit: { type: "integer", default: 50, minimum: 1, maximum: 200 } }, required: ["merchant_id"] },
    });
  }

  if (ctx.surface === "merchant") {
    tools.push({
      type: "function",
      name: "merchant_sales_summary",
      description: "ملخص مبيعات/طلبات المتجر خلال عدد ايام محدد.",
      parameters: { type: "object", properties: { merchant_id: { type: "string" }, days: { type: "integer", default: 14, minimum: 1, maximum: 90 } }, required: ["merchant_id"] },
    });
  }

  if (ctx.surface === "driver") {
    tools.push({
      type: "function",
      name: "driver_hotspots",
      description: "افضل مناطق النشاط خلال اخر كم ساعة (طلبات + رحلات) حسب مواقع الالتقاط.",
      parameters: { type: "object", properties: { hours: { type: "integer", default: 3, minimum: 1, maximum: 24 }, limit: { type: "integer", default: 5, minimum: 1, maximum: 10 } }, required: [] },
    });
  }

  async function runTool(name: string, args: any) {
    const limit = Math.max(1, Math.min(200, Number(args?.limit ?? 10)));

    if (name === "search_catalog") {
      const q = String(args?.query ?? "").trim();
      const merchantId = args?.merchant_id ? String(args.merchant_id).trim() : null;
      if (!q) return [];
      const { data, error } = await svc.rpc("search_catalog_v1", {
        p_query: q,
        p_limit: Math.max(1, Math.min(50, limit)),
        p_merchant_id: merchantId || null,
      });
      if (error) throw error;
      return data ?? [];
    }

    if (name === "search_merchants") {
      const q = String(args?.query ?? "").trim();
      if (!q) return [];
      const { data, error } = await svc
        .from("merchants")
        .select("id,business_name,business_type,status")
        .eq("status", "approved")
        .ilike("business_name", `%${q}%`)
        .limit(limit);
      if (error) throw error;
      return data ?? [];
    }

    if (name === "search_products") {
      const q = String(args?.query ?? "").trim();
      const merchantId = args?.merchant_id ? String(args.merchant_id) : null;
      if (!q) return [];
      let query = svc
        .from("merchant_products")
        .select("id,merchant_id,name,category,price_iqd,compare_at_price_iqd,is_active")
        .eq("is_active", true)
        .ilike("name", `%${q}%`)
        .limit(limit);
      if (merchantId) query = query.eq("merchant_id", merchantId);
      const { data, error } = await query;
      if (error) throw error;
      return data ?? [];
    }

    if (name === "list_active_promotions") {
      const merchantId = args?.merchant_id ? String(args.merchant_id) : null;
      const category = args?.category ? String(args.category) : null;
      const now = new Date().toISOString();
      let query = svc
        .from("merchant_promotions")
        .select("id,merchant_id,product_id,category,discount_type,value,starts_at,ends_at,is_active,created_at")
        .eq("is_active", true)
        .or(`starts_at.is.null,starts_at.lte.${now}`)
        .or(`ends_at.is.null,ends_at.gte.${now}`)
        .order("created_at", { ascending: false })
        .limit(limit);

      if (merchantId) query = query.eq("merchant_id", merchantId);
      if (category) query = query.eq("category", category);
      const { data, error } = await query;
      if (error) throw error;
      return data ?? [];
    }

    if (name === "list_my_promotions") {
      const nowIso = new Date().toISOString();
      const lim = Math.max(1, Math.min(50, Number(args?.limit ?? 10)));

      // Pull enabled targets for the current user.
      const { data: targets, error: tErr } = await svc
        .from("user_interest_targets")
        .select("kind,merchant_id,product_id,category,keyword,enabled")
        .eq("user_id", ctx.userId)
        .eq("enabled", true)
        .limit(60);
      if (tErr) throw tErr;

      const merchantIds = Array.from(new Set((targets ?? []).filter((x: any) => x.kind === "merchant" && x.merchant_id).map((x: any) => x.merchant_id))) as string[];
      const productIds = Array.from(new Set((targets ?? []).filter((x: any) => x.kind === "product" && x.product_id).map((x: any) => x.product_id))) as string[];
      const categories = Array.from(new Set((targets ?? []).filter((x: any) => x.kind === "category" && x.category).map((x: any) => x.category))) as string[];
      const keywords = Array.from(new Set((targets ?? []).filter((x: any) => x.kind === "keyword" && x.keyword).map((x: any) => String(x.keyword).toLowerCase().trim()).filter(Boolean))) as string[];

      // Fetch promos by merchant/product/category with small bounded queries.
      const baseSel = "id,merchant_id,product_id,category,discount_type,value,starts_at,ends_at,is_active,created_at";
      const results: any[] = [];

      if (merchantIds.length) {
        const { data, error } = await svc
          .from("merchant_promotions")
          .select(baseSel)
          .eq("is_active", true)
          .in("merchant_id", merchantIds)
          .order("created_at", { ascending: false })
          .limit(100);
        if (error) throw error;
        results.push(...(data ?? []));
      }

      if (productIds.length) {
        const { data, error } = await svc
          .from("merchant_promotions")
          .select(baseSel)
          .eq("is_active", true)
          .in("product_id", productIds)
          .order("created_at", { ascending: false })
          .limit(100);
        if (error) throw error;
        results.push(...(data ?? []));
      }

      if (categories.length) {
        const { data, error } = await svc
          .from("merchant_promotions")
          .select(baseSel)
          .eq("is_active", true)
          .in("category", categories)
          .order("created_at", { ascending: false })
          .limit(120);
        if (error) throw error;
        results.push(...(data ?? []));
      }

      // Keyword targets (best-effort): scan a small window of active promos and filter in-memory.
      if (keywords.length) {
        const { data, error } = await svc
          .from("merchant_promotions")
          .select(baseSel)
          .eq("is_active", true)
          .order("created_at", { ascending: false })
          .limit(120);
        if (error) throw error;

        const raw = (data ?? []) as any[];
        const mIds = Array.from(new Set(raw.map((p: any) => p.merchant_id).filter(Boolean)));
        const pIds = Array.from(new Set(raw.map((p: any) => p.product_id).filter(Boolean))) as string[];

        const [{ data: merchRows }, { data: prodRows }] = await Promise.all([
          mIds.length ? svc.from("merchants").select("id,business_name").in("id", mIds).limit(200) : Promise.resolve({ data: [] as any[] }),
          pIds.length ? svc.from("merchant_products").select("id,name,category").in("id", pIds).limit(200) : Promise.resolve({ data: [] as any[] }),
        ]);

        const merchMap = new Map<string, string>();
        for (const r of merchRows ?? []) merchMap.set(String((r as any).id), String((r as any).business_name ?? ""));
        const prodMap = new Map<string, { name: string; category: string }>();
        for (const r of prodRows ?? []) prodMap.set(String((r as any).id), { name: String((r as any).name ?? ""), category: String((r as any).category ?? "") });

        for (const p of raw) {
          const m = merchMap.get(String((p as any).merchant_id)) ?? "";
          const prod = (p as any).product_id ? prodMap.get(String((p as any).product_id)) : null;
          const hay = `${m} ${prod?.name ?? ""} ${(p as any).category ?? ""} ${prod?.category ?? ""}`.toLowerCase();
          if (keywords.some((k) => k && hay.includes(k))) {
            results.push(p);
          }
        }
      }

      // Filter by active window, dedupe, sort.
      const within = (p: any) => {
        if (!p?.is_active) return false;
        if (p.starts_at && p.starts_at > nowIso) return false;
        if (p.ends_at && p.ends_at < nowIso) return false;
        return true;
      };
      const map = new Map<string, any>();
      for (const p of results) {
        if (!within(p)) continue;
        map.set(String(p.id), p);
      }
      return Array.from(map.values())
        .sort((a, b) => String(b.created_at ?? "").localeCompare(String(a.created_at ?? "")))
        .slice(0, lim);
    }

    if (name === "get_merchant_catalog") {
      const merchantId = String(args?.merchant_id ?? ctx.merchantId ?? "").trim();
      const lim = Math.max(1, Math.min(200, Number(args?.limit ?? 50)));
      if (!merchantId) return [];
      const { data, error } = await svc
        .from("merchant_products")
        .select("id,name,category,price_iqd,compare_at_price_iqd,is_active,stock_qty")
        .eq("merchant_id", merchantId)
        .eq("is_active", true)
        .order("is_featured", { ascending: false })
        .order("updated_at", { ascending: false })
        .limit(lim);
      if (error) throw error;
      return data ?? [];
    }

    if (name === "merchant_sales_summary") {
      const merchantId = String(args?.merchant_id ?? ctx.merchantId ?? "").trim();
      const days = Math.max(1, Math.min(90, Number(args?.days ?? 14)));
      if (!merchantId) return { error: "missing_merchant_id" };

      const since = new Date(Date.now() - days * 86400_000).toISOString();
      const [ordersRes, itemsRes] = await Promise.all([
        svc
          .from("merchant_orders")
          .select("id,status,total_iqd,created_at")
          .eq("merchant_id", merchantId)
          .gte("created_at", since),
        svc
          .from("merchant_order_items")
          .select("product_id,quantity,price_iqd,created_at,order_id")
          .gte("created_at", since),
      ]);

      if (ordersRes.error) throw ordersRes.error;
      if (itemsRes.error) throw itemsRes.error;

      const orders = (ordersRes.data ?? []) as any[];
      const orderIds = new Set(orders.map((o) => String(o.id)));
      const items = (itemsRes.data ?? []).filter((it: any) => orderIds.has(String(it.order_id)));

      const total = orders.reduce((s, o) => s + Number(o.total_iqd ?? 0), 0);
      const count = orders.length;

      const byProduct = new Map<string, { qty: number; revenue: number }>();
      for (const it of items) {
        const pid = String(it.product_id);
        const cur = byProduct.get(pid) ?? { qty: 0, revenue: 0 };
        cur.qty += Number(it.quantity ?? 0);
        cur.revenue += Number(it.quantity ?? 0) * Number(it.price_iqd ?? 0);
        byProduct.set(pid, cur);
      }

      const top = Array.from(byProduct.entries())
        .sort((a, b) => b[1].revenue - a[1].revenue)
        .slice(0, 10)
        .map(([product_id, v]) => ({ product_id, ...v }));

      return { days, orders_count: count, revenue_iqd: total, top_products: top };
    }

    if (name === "driver_hotspots") {
      const hours = Math.max(1, Math.min(24, Number(args?.hours ?? 3)));
      const lim = Math.max(1, Math.min(10, Number(args?.limit ?? 5)));

      // Scope hotspots to the driver's current service area (if we can resolve it).
      const { data: loc, error: locErr } = await svc
        .from("driver_locations")
        .select("lat,lng,updated_at")
        .maybeSingle();
      if (locErr) throw locErr;

      let service_area_id: string | null = null;
      if (loc?.lat != null && loc?.lng != null) {
        const { data: areaRows, error: areaErr } = await svc.rpc("resolve_service_area", {
          p_lat: Number((loc as any).lat),
          p_lng: Number((loc as any).lng),
        });
        if (areaErr) throw areaErr;
        service_area_id = (areaRows?.[0] as any)?.id ?? null;
      }

      const { data, error } = await svc.rpc("driver_hotspots_v1", {
        p_hours: hours,
        p_limit: lim,
        p_grid_m: 500,
        p_service_area_id: service_area_id,
      });
      if (error) throw error;

      return data ?? [];
    }

    return { error: `unknown_tool:${name}` };
  }

  return { tools, runTool };
}

async function runAgent(svc: ReturnType<typeof createAnonClient>, surface: Surface, message: string, ctx: { userId: string; merchantId?: string }) {
  const sys = systemForSurface(surface);

  let input: ResponsesInputItem[] = [
    { type: "message", role: "system", content: [{ type: "input_text", text: sys }] },
    { type: "message", role: "user", content: [{ type: "input_text", text: message }] },
  ];

  const { tools, runTool } = buildTools(svc, { userId: ctx.userId, merchantId: ctx.merchantId, surface });

  for (let step = 0; step < 3; step++) {
    const resp = await callOpenRouterResponses({
      model: MODEL,
      input,
      tools,
      tool_choice: "auto",
      reasoning: { effort: surface === "merchant" ? "medium" : "low" },
      max_output_tokens: 700,
      temperature: 0.4,
    });

    const calls = extractFunctionCalls(resp);
    const text = extractOutputText(resp);
    if (calls.length === 0) return text || "";

    for (const c of calls) {
      let out: unknown;
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

  return "ما كدرت اكمل بسبب تعقيد عالي. جرب سؤال ابسط.";
}

function sse(event: string, data: unknown) {
  return `event: ${event}\ndata: ${JSON.stringify(data)}\n\n`;
}

async function streamText(controller: ReadableStreamDefaultController<Uint8Array>, text: string) {
  const enc = new TextEncoder();
  const chunkSize = 28;
  for (let i = 0; i < text.length; i += chunkSize) {
    controller.enqueue(enc.encode(sse("delta", { delta: text.slice(i, i + chunkSize) })));
    // Yield to allow UI updates.
    await Promise.resolve();
  }
}

async function proxyOpenRouterResponsesSse(openrouterRes: Response, onDelta: (d: string) => void, onError: (e: any) => void) {
  const reader = openrouterRes.body?.getReader();
  if (!reader) throw new Error("Missing stream body");

  const dec = new TextDecoder();
  let buf = "";
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    buf += dec.decode(value, { stream: true });

    let idx: number;
    while ((idx = buf.indexOf("\n")) >= 0) {
      const rawLine = buf.slice(0, idx);
      buf = buf.slice(idx + 1);

      const line = rawLine.trimEnd();
      if (!line) continue;
      if (line.startsWith(":")) continue; // SSE comment, e.g. ": OPENROUTER PROCESSING"
      if (!line.startsWith("data: ")) continue;

      const data = line.slice(6).trim();
      if (!data) continue;
      if (data === "[DONE]") return;

      let parsed: any = null;
      try {
        parsed = JSON.parse(data);
      } catch {
        continue;
      }

      // Error events (OpenRouter Responses API compatible).
      if (parsed?.type === "response.failed" || parsed?.type === "response.error" || parsed?.type === "error" || parsed?.error) {
        onError(parsed);
        return;
      }

      // Text delta events.
      if (parsed?.type === "response.content_part.delta" && typeof parsed?.delta === "string") {
        onDelta(parsed.delta);
      }
    }
  }
}

async function runAgentStream(
  svc: ReturnType<typeof createAnonClient>,
  surface: Surface,
  message: string,
  ctx: { userId: string; merchantId?: string },
  onFinal?: (finalText: string) => Promise<Record<string, unknown> | void>,
) {
  const sys = systemForSurface(surface);
  const { tools, runTool } = buildTools(svc, { userId: ctx.userId, merchantId: ctx.merchantId, surface });

  let input: ResponsesInputItem[] = [
    { type: "message", role: "system", content: [{ type: "input_text", text: sys }] },
    { type: "message", role: "user", content: [{ type: "input_text", text: message }] },
  ];

  // First: resolve tool calls (non-stream) with small token budget.
  let usedTools = false;
  let directText: string | null = null;
  for (let step = 0; step < 3; step++) {
    const resp = await callOpenRouterResponses({
      model: MODEL,
      input,
      tools,
      tool_choice: "auto",
      reasoning: { effort: surface === "merchant" ? "medium" : "low" },
      max_output_tokens: 220,
      temperature: 0.4,
    });

    const calls = extractFunctionCalls(resp);
    const text = extractOutputText(resp);
    if (calls.length === 0) {
      directText = (text || "").trim();
      break;
    }

    usedTools = true;
    for (const c of calls) {
      let out: unknown;
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

  // Create SSE response for the caller.
  const headers = new Headers({
    ...getCorsHeaders(req),
    "Content-Type": "text/event-stream; charset=utf-8",
    "Cache-Control": "no-cache, no-transform",
    "Connection": "keep-alive",
  });

  const stream = new ReadableStream<Uint8Array>({
    start: async (controller) => {
      const enc = new TextEncoder();
      let acc = "";
      const emit = (evt: string, data: unknown) => controller.enqueue(enc.encode(sse(evt, data)));

      try {
        emit("meta", { surface, mode: "stream" });

        if (!usedTools && directText != null) {
          // No tools used: stream the already-generated text (cheap + fast).
          await streamText(controller, directText);
          acc = directText;
        } else {
          // Tools were used (or we exhausted tool steps): stream the final answer generation.
          const openRes = await callOpenRouterResponsesStream({
            model: MODEL,
            input,
            tool_choice: "none",
            reasoning: { effort: surface === "merchant" ? "medium" : "low" },
            max_output_tokens: 700,
            temperature: 0.4,
          });

          await proxyOpenRouterResponsesSse(
            openRes,
            (d) => {
              acc += d;
              emit("delta", { delta: d });
            },
            (err) => {
              const msg = err?.error?.message ?? err?.response?.error?.message ?? "OpenRouter stream error";
              emit("error", { message: msg, raw: err?.type ?? null });
            },
          );
        }

        const finalText = acc.trim() || "ما لكيت جواب واضح. جرب صياغة ثانية.";
        const extra = onFinal ? (await onFinal(finalText)) : undefined;
        emit("done", { reply: finalText, ...(extra ?? {}) });
      } catch (e: any) {
        emit("error", { message: e?.message ?? String(e) });
      } finally {
        try {
          controller.close();
        } catch {
          // ignore
        }
      }
    },
  });

  return new Response(stream, { status: 200, headers });
}

serve(async (req) => {
  const opt = handleOptions(req);
  if (opt) return opt;
  const cors = getCorsHeaders(req);
  if (req.method !== "POST") return errorJson("Method not allowed", 405, "METHOD_NOT_ALLOWED", undefined, cors);

  const { user, error } = await requireUser(req);
  if (error || !user) return errorJson(error ?? "Unauthorized", 401, "UNAUTHORIZED", undefined, cors);

  const body = (await req.json().catch(() => ({}))) as ReqBody;
  let surface: Surface = (body.surface ?? "auto") as Surface;
  const message = String(body.message ?? "").trim();
  if (!message) return errorJson("Missing message", 400, "BAD_REQUEST", undefined, cors);

  // Use a user-scoped Supabase client (least-privilege). RLS stays enforced.
  const svc = createAnonClient(req);
  if (surface === "auto") {
    surface = await inferSurfaceFromContext(svc, body.ui_path);
  }

  const svcAdmin = createServiceClient();

  if (surface === "merchant_chat") {
    const threadId = String(body.thread_id ?? "").trim();
    if (!threadId) return errorJson("Missing thread_id", 400, "BAD_REQUEST", undefined, cors);

    const { data: thread, error: tErr } = await svc
      .from("merchant_chat_threads")
      .select("id,merchant_id,customer_id")
      .eq("id", threadId)
      .maybeSingle();

    if (tErr || !thread) return errorJson("Thread not found", 404, "NOT_FOUND", undefined, cors);

    const { data: merchant, error: mErr } = await svc
      .from("merchants")
      .select("id,owner_profile_id,business_name")
      .eq("id", (thread as any).merchant_id)
      .maybeSingle();

    if (mErr || !merchant) return errorJson("Merchant not found", 404, "NOT_FOUND", undefined, cors);

    const userId = user.id;
    const allowed = userId === (thread as any).customer_id || userId === (merchant as any).owner_profile_id;
    if (!allowed) return errorJson("Forbidden", 403, "FORBIDDEN", undefined, cors);

    const merchantId = String((merchant as any).id);

    const { data: msgs, error: msgErr } = await svc
      .rpc("merchant_chat_list_messages", { p_thread_id: threadId, p_before_created_at: null, p_before_id: null, p_limit: 30 });

    if (msgErr) return errorJson(msgErr.message, 400, "DB_ERROR", undefined, cors);

    const transcript = (msgs ?? [])
      .slice()
      .reverse()
      .map((m: any) => {
        const senderId = String(m.sender_id ?? "");
        const isBot = senderId === AI_ASSISTANT_PROFILE_ID || m.message_type === "ai";
        const who = isBot
          ? "المساعد"
          : senderId === String((thread as any).customer_id)
            ? "الزبون"
            : senderId === String((merchant as any).owner_profile_id)
              ? "التاجر"
              : "مستخدم";

        const icon = isBot ? "🤖" : "👤";
        const body = String(m.body ?? "").replaceAll("\n", " ").trim();
        return `${icon} ${who}: ${body}`;
      })
      .filter(Boolean)
      .join("\n");

    const caller = userId === (thread as any).customer_id ? "الزبون" : "التاجر";
    const merged = `هاي محادثة سابقة:
${transcript}

معلومة: اللي هسه يسأل هو: ${caller}.

هسه سؤال/طلب المستخدم:
${message}`;
    if (body.stream) {
      return await runAgentStream(svc, "merchant_chat", merged, { userId, merchantId }, async (finalText) => {
        // Write the bot reply as a real 3rd participant (service role bypasses RLS).
        await ensureAiAssistantProfile();
        const { data: inserted, error: insErr } = await svcAdmin
          .from("merchant_chat_messages")
          .insert({
            thread_id: threadId,
            sender_id: AI_ASSISTANT_PROFILE_ID,
            body: finalText,
            message_type: "ai",
          })
          .select("id")
          .single();

        if (insErr) throw insErr;
        return { message_id: (inserted as any)?.id ?? null };
      });
    }

    const reply = await runAgent(svc, "merchant_chat", merged, { userId, merchantId });

    // Write the bot reply as a real 3rd participant (service role bypasses RLS).
    await ensureAiAssistantProfile();
    const { error: insErr } = await svcAdmin.from("merchant_chat_messages").insert({
      thread_id: threadId,
      sender_id: AI_ASSISTANT_PROFILE_ID,
      body: reply,
      message_type: "ai",
    });

    if (insErr) return errorJson(insErr.message, 400, "DB_ERROR", undefined, cors);

    return json({ ok: true, surface, reply }, 200, cors);
  }

  if (surface === "merchant") {
    const { data: merchants, error: mErr } = await svc
      .from("merchants")
      .select("id,business_name")
      .eq("owner_profile_id", user.id)
      .limit(5);

    if (mErr) return errorJson(mErr.message, 400, "DB_ERROR", undefined, cors);
    const merchantId = body.merchant_id ? String(body.merchant_id) : (merchants?.[0]?.id ?? null);

    const prefix = merchants && merchants.length > 1
      ? `ملاحظة: انت عندك اكثر من متجر: ${merchants.map((m:any)=>m.business_name).join("، ")}. اذا تريد واحد محدد قلّي اسمه.\n\n`
      : "";

    if (body.stream) return await runAgentStream(svc, "merchant", prefix + message, { userId: user.id, merchantId: merchantId ?? undefined });
    const reply = await runAgent(svc, "merchant", prefix + message, { userId: user.id, merchantId: merchantId ?? undefined });
    return json({ ok: true, surface, reply }, 200, cors);
  }

  if (surface === "driver") {
    if (body.stream) return await runAgentStream(svc, "driver", message, { userId: user.id });
    const reply = await runAgent(svc, "driver", message, { userId: user.id });
    return json({ ok: true, surface, reply }, 200, cors);
  }

  if (body.stream) return await runAgentStream(svc, "copilot", message, { userId: user.id });

  const reply = await runAgent(svc, "copilot", message, { userId: user.id });
  return json({ ok: true, surface, reply }, 200, cors);
});