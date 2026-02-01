import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { handleOptions } from "../_shared/cors.ts";
import { errorJson, json } from "../_shared/json.ts";
import { createAnonClient, requireUser } from "../_shared/supabase.ts";

type Body = {
  ride_id?: string;
  limit?: number;
  before?: string | null; // ISO timestamp cursor
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

  const limit = Math.min(Math.max(body.limit ?? 50, 1), 100);
  const before = body.before ? new Date(body.before).toISOString() : null;

  const anon = createAnonClient(req);

  const { data: threadId, error: thrErr } = await anon.rpc("ride_chat_get_or_create_thread", { p_ride_id: rideId });
  if (thrErr) return errorJson(thrErr.message, 400, "DB_ERROR");

  let q = anon
    .from("ride_chat_messages")
    .select("id,thread_id,ride_id,sender_id,kind,body,attachment_bucket,attachment_key,metadata,created_at")
    .eq("thread_id", threadId as string)
    .order("created_at", { ascending: false })
    .limit(limit);

  if (before) q = q.lt("created_at", before);

  const { data: rows, error: qErr } = await q;
  if (qErr) return errorJson(qErr.message, 400, "DB_ERROR");

  const messages = (rows ?? []).slice().reverse(); // chronological

  const nextCursor = rows && rows.length > 0 ? rows[rows.length - 1].created_at : null;

  return json({ ok: true, thread_id: threadId, messages, next_cursor: nextCursor });
});
