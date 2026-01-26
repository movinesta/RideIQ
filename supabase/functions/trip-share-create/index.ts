import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.92.0?target=deno";

function corsHeaders(origin: string | null) {
  return {
    "Access-Control-Allow-Origin": origin ?? "*",
    "Access-Control-Allow-Methods": "POST,OPTIONS",
    "Access-Control-Allow-Headers": "authorization,content-type",
    "Access-Control-Max-Age": "86400",
  };
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
  const origin = req.headers.get("origin");
  if (req.method === "OPTIONS") return new Response("", { status: 204, headers: corsHeaders(origin) });
  if (req.method !== "POST") return new Response("Method not allowed", { status: 405, headers: corsHeaders(origin) });

  const authHeader = req.headers.get("authorization") || "";
  if (!authHeader.toLowerCase().startsWith("bearer ")) {
    return new Response(JSON.stringify({ error: "unauthorized" }), { status: 401, headers: { ...corsHeaders(origin), "content-type": "application/json" } });
  }

  const anon = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_ANON_KEY")!, {
    global: { headers: { Authorization: authHeader } },
  });

  const { data: userRes, error: userErr } = await anon.auth.getUser();
  const user = userRes?.user;
  if (userErr || !user) {
    return new Response(JSON.stringify({ error: "unauthorized" }), { status: 401, headers: { ...corsHeaders(origin), "content-type": "application/json" } });
  }

  const body = await req.json().catch(() => ({}));
  const rideId = body.ride_id;
  const ttlMinutes = Math.max(5, Math.min(24 * 60, Number(body.ttl_minutes ?? 120))); // default 2h, cap 24h

  if (!rideId) {
    return new Response(JSON.stringify({ error: "missing_ride_id" }), { status: 400, headers: { ...corsHeaders(origin), "content-type": "application/json" } });
  }

  // Validate user is the rider or driver for this ride via RLS (anon client)
  const { data: ride, error: rideErr } = await anon
    .from("rides")
    .select("id,status")
    .eq("id", rideId)
    .maybeSingle();

  if (rideErr || !ride) {
    return new Response(JSON.stringify({ error: "ride_not_found" }), { status: 404, headers: { ...corsHeaders(origin), "content-type": "application/json" } });
  }

  const token = randomToken();
  const tokenHash = await sha256Hex(token);
  const expiresAt = new Date(Date.now() + ttlMinutes * 60_000).toISOString();

  // Use service role to insert share token (prevents client-side direct inserts)
  const admin = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);

  const { error: insErr } = await admin
    .from("trip_share_tokens")
    .insert({
      ride_id: rideId,
      created_by: user.id,
      token_hash: tokenHash,
      expires_at: expiresAt,
    });

  if (insErr) {
    return new Response(JSON.stringify({ error: "insert_failed", detail: insErr.message }), { status: 400, headers: { ...corsHeaders(origin), "content-type": "application/json" } });
  }

  return new Response(JSON.stringify({ ok: true, token, expires_at: expiresAt }), { status: 200, headers: { ...corsHeaders(origin), "content-type": "application/json" } });
});
