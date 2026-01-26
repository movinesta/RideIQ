import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { createClient } from "npm:@supabase/supabase-js@2.92.0";

function corsHeaders(origin: string | null) {
  return {
    "Access-Control-Allow-Origin": origin ?? "*",
    "Access-Control-Allow-Methods": "GET,OPTIONS",
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

serve(async (req) => {
  const origin = req.headers.get("origin");
  if (req.method === "OPTIONS") return new Response("", { status: 204, headers: corsHeaders(origin) });
  if (req.method !== "GET") return new Response("Method not allowed", { status: 405, headers: corsHeaders(origin) });

  const url = new URL(req.url);
  const token = url.searchParams.get("token")?.trim();
  if (!token || token.length < 16) {
    return new Response(JSON.stringify({ error: "invalid_token" }), { status: 400, headers: { ...corsHeaders(origin), "content-type": "application/json" } });
  }

  const tokenHash = await sha256Hex(token);

  // Service role is required because this is a tokenized public endpoint (no JWT).
  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  // Validate token + fetch ride id
  const { data: share, error: shareErr } = await supabase
    .from("trip_share_tokens")
    .select("ride_id, expires_at, revoked_at")
    .eq("token_hash", tokenHash)
    .maybeSingle();

  if (shareErr || !share || share.revoked_at) {
    return new Response(JSON.stringify({ error: "not_found" }), { status: 404, headers: { ...corsHeaders(origin), "content-type": "application/json" } });
  }
  if (share.expires_at && new Date(share.expires_at).getTime() < Date.now()) {
    return new Response(JSON.stringify({ error: "expired" }), { status: 410, headers: { ...corsHeaders(origin), "content-type": "application/json" } });
  }

  // Fetch minimal, non-sensitive ride data
  const { data: ride, error: rideErr } = await supabase
    .from("rides")
    .select("id,status,pickup_lat,pickup_lng,dropoff_lat,dropoff_lng,driver_id,vehicle_id,created_at")
    .eq("id", share.ride_id)
    .maybeSingle();

  if (rideErr || !ride) {
    return new Response(JSON.stringify({ error: "ride_not_found" }), { status: 404, headers: { ...corsHeaders(origin), "content-type": "application/json" } });
  }

  // Latest driver location (optional)
  let location: any = null;
  if (ride.driver_id) {
    const { data: loc } = await supabase
      .from("driver_locations")
      .select("lat,lng,updated_at")
      .eq("driver_id", ride.driver_id)
      .order("updated_at", { ascending: false })
      .limit(1);
    location = loc?.[0] ?? null;
  }

  // Vehicle (optional) - keep it minimal for public sharing
  let vehicle: any = null;
  if (ride.vehicle_id) {
    const { data: v } = await supabase
      .from("driver_vehicles")
      .select("make,model,color,plate_number,vehicle_type")
      .eq("id", ride.vehicle_id)
      .maybeSingle();
    if (v) {
      const plate = (v.plate_number ?? "").toString();
      vehicle = {
        make: v.make ?? null,
        model: v.model ?? null,
        color: v.color ?? null,
        vehicle_type: v.vehicle_type ?? null,
        plate_suffix: plate ? plate.slice(Math.max(0, plate.length - 3)) : null,
      };
    }
  }

  return new Response(
    JSON.stringify({
      ride: {
        id: ride.id,
        status: ride.status,
        pickup: { lat: ride.pickup_lat, lng: ride.pickup_lng },
        dropoff: { lat: ride.dropoff_lat, lng: ride.dropoff_lng },
        created_at: ride.created_at,
      },
      vehicle,
      location,
    }),
    { status: 200, headers: { ...corsHeaders(origin), "content-type": "application/json" } },
  );
});
