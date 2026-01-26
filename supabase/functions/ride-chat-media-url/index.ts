import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { handleOptions } from "../_shared/cors.ts";
import { errorJson, json } from "../_shared/json.ts";
import { createAnonClient, createServiceClient, requireUser } from "../_shared/supabase.ts";

type Body = {
  action?: "upload" | "download";
  ride_id?: string;
  filename?: string | null;
  object_key?: string | null;
  expires_in?: number | null; // seconds
};

function safeExt(name: string) {
  const m = name.toLowerCase().match(/\.([a-z0-9]{1,8})$/);
  return m ? m[1] : "bin";
}

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

  const action = body.action ?? "upload";
  const rideId = (body.ride_id ?? "").trim();
  if (!rideId) return errorJson("ride_id is required", 400, "VALIDATION_ERROR");

  const anon = createAnonClient(req);

  // Ensure participant (RLS read)
  const { data: ride, error: rideErr } = await anon
    .from("rides")
    .select("id")
    .eq("id", rideId)
    .maybeSingle();

  if (rideErr) return errorJson(rideErr.message, 400, "DB_ERROR");
  if (!ride) return errorJson("Ride not found", 404, "RIDE_NOT_FOUND");

  if (action === "upload") {
    const filename = (body.filename ?? "upload.bin").trim() || "upload.bin";
    const ext = safeExt(filename);
    const objectKey = `chat/${user.id}/${crypto.randomUUID()}.${ext}`;

    const { data, error: upErr } = await anon.storage.from("chat-media").createSignedUploadUrl(objectKey);
    if (upErr) return errorJson(upErr.message, 400, "STORAGE_ERROR");

    return json({ ok: true, bucket: "chat-media", object_key: objectKey, ...data });
  }

  const objectKey = (body.object_key ?? "").trim();
  if (!objectKey) return errorJson("object_key is required for download", 400, "VALIDATION_ERROR");

  // Verify the object belongs to a message in this ride (RLS-protected)
  const { data: msg, error: mErr } = await anon
    .from("ride_chat_messages")
    .select("id,ride_id,attachment_key")
    .eq("ride_id", rideId)
    .eq("attachment_key", objectKey)
    .limit(1)
    .maybeSingle();

  if (mErr) return errorJson(mErr.message, 400, "DB_ERROR");
  if (!msg) return errorJson("Not found", 404, "NOT_FOUND");

  const expiresIn = Math.min(Math.max(body.expires_in ?? 3600, 60), 60 * 60 * 24);
  const svc = createServiceClient();
  const { data, error: sErr } = await svc.storage.from("chat-media").createSignedUrl(objectKey, expiresIn);
  if (sErr) return errorJson(sErr.message, 400, "STORAGE_ERROR");

  return json({ ok: true, bucket: "chat-media", object_key: objectKey, signed_url: data?.signedUrl, expires_in: expiresIn });
});
