import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { handleOptions, getCorsHeaders } from "../_shared/cors.ts";
import { createAnonClient, createServiceClient, requireUser } from "../_shared/supabase.ts";

function jsonResponse(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...getCorsHeaders(), "content-type": "application/json" },
  });
}

function toHex(bytes: ArrayBuffer): string {
  const arr = new Uint8Array(bytes);
  return Array.from(arr).map((b) => b.toString(16).padStart(2, "0")).join("");
}

async function sha256Hex(input: string): Promise<string> {
  const data = new TextEncoder().encode(input);
  const digest = await crypto.subtle.digest("SHA-256", data);
  return toHex(digest);
}

function randomToken(): string {
  // 32 bytes => 64 hex chars
  const bytes = crypto.getRandomValues(new Uint8Array(32));
  return Array.from(bytes).map((b) => b.toString(16).padStart(2, "0")).join("");
}

serve(async (req) => {
  const opt = handleOptions(req);
  if (opt) return opt;
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405, headers: getCorsHeaders() });
  }

  const { user, error: authErr } = await requireUser(req);
  if (authErr || !user) {
    return jsonResponse({ error: "unauthorized", detail: authErr ?? "unauthorized" }, 401);
  }

  const body = await req.json().catch(() => ({} as any));
  const rideId = body.ride_id as string | undefined;
  const ttlMinutes = Math.max(5, Math.min(24 * 60, Number(body.ttl_minutes ?? 120))); // default 2h, cap 24h

  if (!rideId) return jsonResponse({ error: "missing_ride_id" }, 400);

  // Validate user is the rider or driver for this ride via RLS (anon client)
  const anon = createAnonClient(req);
  const { data: ride, error: rideErr } = await anon
    .from("rides")
    .select("id,status,rider_id,driver_id")
    .eq("id", rideId)
    .maybeSingle();

  if (rideErr || !ride) {
    // If RLS blocks access, treat as not found
    return jsonResponse({ error: "ride_not_found" }, 404);
  }

  // Explicit ownership check (defense-in-depth; prevents sharing arbitrary ride ids if RLS changes)
  if (ride.rider_id !== user.id && ride.driver_id !== user.id) {
    return jsonResponse({ error: "forbidden" }, 403);
  }

  const token = randomToken();
  const tokenHash = await sha256Hex(token);
  const expiresAt = new Date(Date.now() + ttlMinutes * 60_000).toISOString();

  // Use service role to insert share token (prevents client-side direct inserts)
  const admin = createServiceClient();
  const { error: insErr } = await admin.from("trip_share_tokens").insert({
    ride_id: rideId,
    created_by: user.id,
    token_hash: tokenHash,
    expires_at: expiresAt,
  });

  if (insErr) {
    return jsonResponse({ error: "insert_failed", detail: insErr.message }, 400);
  }

  return jsonResponse({ ok: true, token, expires_at: expiresAt }, 200);
});
