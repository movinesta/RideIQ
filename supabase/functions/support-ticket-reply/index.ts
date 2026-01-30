import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { errorJson, json } from "../_shared/json.ts";
import { requireUser, createServiceClient, createAnonClient } from "../_shared/supabase.ts";

type Payload = {
  ticket_id: string;
  message: string;
};

serve(async (req) => {
  if (req.method === "OPTIONS") return json({ ok: true }, 204);
  if (req.method !== "POST") return errorJson("Method not allowed", 405);

  const { user, error } = await requireUser(req);
  if (!user) return errorJson(error ?? "Unauthorized", 401, "UNAUTHORIZED");

  const body = (await req.json().catch(() => ({}))) as Partial<Payload>;
  const ticketId = (body.ticket_id ?? "").trim();
  const message = (body.message ?? "").trim();

  if (!ticketId) return errorJson("Missing ticket_id", 400, "INVALID_PAYLOAD");
  if (!message) return errorJson("Missing message", 400, "INVALID_PAYLOAD");

  // Ensure the user owns the ticket (RLS check via anon client)
  const anon = createAnonClient(req);
  const { data: ticket } = await anon.from("support_tickets").select("id").eq("id", ticketId).maybeSingle();
  if (!ticket) return errorJson("Ticket not found", 404, "NOT_FOUND");

  const svc = createServiceClient();
  const { error: mErr } = await svc.from("support_messages").insert({
    ticket_id: ticketId,
    sender_profile_id: user.id,
    body: message,
  });
  if (mErr) return errorJson(mErr.message, 400, "DB_ERROR");

  // touch updated_at
  await svc.from("support_tickets").update({ updated_at: new Date().toISOString() }).eq("id", ticketId);

  return json({ ok: true });
});
