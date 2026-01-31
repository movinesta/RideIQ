import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { handleOptions } from "../_shared/cors.ts";
import { errorJson, json } from "../_shared/json.ts";
import { createAnonClient, requireUser } from "../_shared/supabase.ts";

type Body = {
  ride_id?: string;
  text?: string | null;
  kind?: "text" | "image" | "system";
  attachment_key?: string | null; // path in chat-media bucket
  metadata?: Record<string, unknown> | null;
};

serve(async (req) => {
  const opt = handleOptions(req);
  if (opt) return opt;

  if (req.method !== "POST") return errorJson("Method not allowed", 405, "METHOD_NOT_ALLOWED");

  const { user, error } = await requireUser(req);
  if (error || !user) return errorJson("Unauthorized", 401, "UNAUTHORIZED");

  let body: Body;
  try {
    body = (await req.json()) as Body;
  } catch {
    return errorJson("Invalid JSON", 400, "BAD_JSON");
  }

  const rideId = (body.ride_id ?? "").trim();
  if (!rideId) return errorJson("ride_id is required", 400, "VALIDATION_ERROR");

  const kind = body.kind ?? "text";
  const text = (body.text ?? "").toString();
  const attachmentKey = body.attachment_key ?? null;

  if (kind === "text" && !text.trim()) return errorJson("text is required", 400, "VALIDATION_ERROR");
  if (kind === "image" && !attachmentKey) return errorJson("attachment_key is required for image", 400, "VALIDATION_ERROR");

  const anon = createAnonClient(req);

  // Ensure the caller is a ride participant (RLS-protected read)
  const { data: ride, error: rideErr } = await anon
    .from("rides")
    .select("id,status,rider_id,driver_id")
    .eq("id", rideId)
    .maybeSingle();

  if (rideErr) return errorJson(rideErr.message, 400, "DB_ERROR");
  if (!ride) return errorJson("Ride not found", 404, "RIDE_NOT_FOUND");

  // Create / fetch chat thread (SECURITY DEFINER function enforces membership)
  const { data: threadId, error: thrErr } = await anon.rpc("ride_chat_get_or_create_thread", { p_ride_id: rideId });
  if (thrErr) return errorJson(thrErr.message, 400, "DB_ERROR");

  const payload = {
    thread_id: threadId as string,
    ride_id: rideId,
    sender_id: user.id,
    kind,
    body: kind === "text" ? text.trim() : null,
    attachment_bucket: attachmentKey ? "chat-media" : null,
    attachment_key: attachmentKey,
    metadata: body.metadata ?? {},
  };

  const { data: msg, error: msgErr } = await anon
    .from("ride_chat_messages")
    .insert(payload)
    .select("id,thread_id,ride_id,sender_id,kind,body,attachment_bucket,attachment_key,metadata,created_at")
    .single();

  if (msgErr) return errorJson(msgErr.message, 400, "DB_ERROR");

  return json({ ok: true, message: msg });
});
