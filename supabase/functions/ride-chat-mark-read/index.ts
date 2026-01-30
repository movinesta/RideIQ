import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { handleOptions } from "../_shared/cors.ts";
import { errorJson, json } from "../_shared/json.ts";
import { createAnonClient, requireUser } from "../_shared/supabase.ts";

type Body = {
  ride_id?: string;
  last_read_at?: string | null; // ISO
  last_read_message_id?: string | null;
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

  const anon = createAnonClient(req);
  const { data: threadId, error: thrErr } = await anon.rpc("ride_chat_get_or_create_thread", { p_ride_id: rideId });
  if (thrErr) return errorJson(thrErr.message, 400, "DB_ERROR");

  const upsertRow = {
    thread_id: threadId as string,
    user_id: user.id,
    last_read_at: body.last_read_at ? new Date(body.last_read_at).toISOString() : new Date().toISOString(),
    last_read_message_id: body.last_read_message_id ?? null,
    updated_at: new Date().toISOString(),
  };

  const { data, error: upErr } = await anon
    .from("ride_chat_read_receipts")
    .upsert(upsertRow, { onConflict: "thread_id,user_id" })
    .select("thread_id,user_id,last_read_at,last_read_message_id,updated_at")
    .single();

  if (upErr) return errorJson(upErr.message, 400, "DB_ERROR");
  return json({ ok: true, receipt: data });
});
