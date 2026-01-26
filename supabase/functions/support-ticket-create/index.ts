import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { errorJson, json } from "../_shared/json.ts";
import { requireUser, createServiceClient, createAnonClient } from "../_shared/supabase.ts";
import { withRequestContext } from '../_shared/requestContext.ts';

type Payload = {
  role_context: "rider" | "driver";
  category_key?: string;
  title: string;
  message: string;
  ride_id?: string | null;
  priority?: "low" | "normal" | "high";
};

serve(async (req) => {
  if (req.method === "OPTIONS") return json({ ok: true }, 204);
  if (req.method !== "POST") return errorJson("Method not allowed", 405);

  const { user, error } = await requireUser(req);
  if (!user) return errorJson(error ?? "Unauthorized", 401, "UNAUTHORIZED");

  const body = (await req.json().catch(() => ({}))) as Partial<Payload>;
  const role = body.role_context;
  const title = (body.title ?? "").trim();
  const message = (body.message ?? "").trim();

  if (!role || !["rider", "driver"].includes(role)) return errorJson("Invalid role_context", 400, "INVALID_ROLE");
  if (!title || title.length < 3) return errorJson("Title too short", 400, "INVALID_TITLE");
  if (!message || message.length < 2) return errorJson("Message too short", 400, "INVALID_MESSAGE");

  // Validate ride_id belongs to user via RLS (least privilege)
  const rideId = (body.ride_id ?? null) ? String(body.ride_id) : null;
  if (rideId) {
    const anon = createAnonClient(req);
    const { data: ride } = await anon.from("rides").select("id").eq("id", rideId).maybeSingle();
    if (!ride) return errorJson("Ride not found", 404, "RIDE_NOT_FOUND");
  }

  const svc = createServiceClient();

  // Resolve category
  let categoryId: string | null = null;
  const categoryKey = (body.category_key ?? "other").trim() || "other";
  const { data: cat } = await svc.from("support_categories").select("id").eq("key", categoryKey).maybeSingle();
  categoryId = cat?.id ?? null;

  const priority = body.priority ?? "normal";

  const { data: ticket, error: tErr } = await svc
    .from("support_tickets")
    .insert({
      created_by: user.id,
      role_context: role,
      ride_id: rideId,
      category_id: categoryId,
      title,
      priority,
      status: "open",
    })
    .select("id,created_at,status,role_context,title,priority,ride_id,category_id")
    .single();

  if (tErr || !ticket) return errorJson(tErr?.message ?? "Ticket create failed", 400, "DB_ERROR");

  const { error: mErr } = await svc.from("support_messages").insert({
    ticket_id: ticket.id,
    sender_profile_id: user.id,
    body: message,
  });

  if (mErr) return errorJson(mErr.message, 400, "DB_ERROR");

  return json({ ok: true, ticket_id: ticket.id });
}));
