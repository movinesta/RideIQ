import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { handleOptions, getCorsHeaders } from "../_shared/cors.ts";
import { createServiceClient } from "../_shared/supabase.ts";

function json(body: unknown, status = 200) {
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

serve(async (req) => {
  const opt = handleOptions(req);
  if (opt) return opt;

  if (req.method !== "GET") {
    return new Response("Method not allowed", { status: 405, headers: getCorsHeaders() });
  }

  const url = new URL(req.url);
  const token = url.searchParams.get("token")?.trim() ?? "";
  if (!token || token.length < 16) {
    return json({ error: "invalid_token" }, 400);
  }

  const supabase = createServiceClient();

  // Support both:
  // - token (plaintext) => hash it and match token_hash
  // - token_hash (client mistakenly passes hash) => match token_hash directly
  let share: any = null;
  let token_mode: "hash" | "token" | "legacy_token" = "token";

  // 1) token provided is already token_hash
  {
    const { data, error } = await supabase
      .from("trip_share_tokens")
      .select("ride_id, expires_at, revoked_at")
      .eq("token_hash", token)
      .maybeSingle();
    if (!error && data) {
      share = data;
      token_mode = "hash";
    }
  }

  // 2) normal path: sha256(token) equals token_hash
  if (!share) {
    const tokenHash = await sha256Hex(token);
    const { data, error } = await supabase
      .from("trip_share_tokens")
      .select("ride_id, expires_at, revoked_at")
      .eq("token_hash", tokenHash)
      .maybeSingle();
    if (!error && data) {
      share = data;
      token_mode = "token";
    }
  }

  // 3) legacy fallback (if any old rows stored plaintext token)
  if (!share) {
    const { data, error } = await supabase
      .from("trip_share_tokens")
      .select("ride_id, expires_at, revoked_at")
      .eq("token", token)
      .maybeSingle();
    if (!error && data) {
      share = data;
      token_mode = "legacy_token";
    }
  }

  if (!share || share.revoked_at) {
    return json({ error: "not_found" }, 404);
  }
  if (share.expires_at && new Date(share.expires_at).getTime() < Date.now()) {
    return json({ error: "expired" }, 410);
  }

  // Fetch minimal, non-sensitive ride data
  const { data: ride, error: rideErr } = await supabase
    .from("rides")
    .select("id,status,pickup_lat,pickup_lng,dropoff_lat,dropoff_lng,driver_id,vehicle_id,created_at")
    .eq("id", share.ride_id)
    .maybeSingle();

  if (rideErr || !ride) {
    return json({ error: "ride_not_found" }, 404);
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

  return json(
    {
      ok: true,
      token_mode,
      ride: {
        id: ride.id,
        status: ride.status,
        pickup: { lat: ride.pickup_lat, lng: ride.pickup_lng },
        dropoff: { lat: ride.dropoff_lat, lng: ride.dropoff_lng },
        created_at: ride.created_at,
      },
      vehicle,
      location,
    },
    200,
  );
});
