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
  if (!token || token.length < 16) return json({ error: "invalid_token" }, 400);

  const supabase = createServiceClient();

  // Robust token lookup:
  // 1) token param is already token_hash
  // 2) token param is plaintext token -> sha256(token) == token_hash
  // 3) legacy: token param matches trip_share_tokens.token (if any)
  let share: any = null;
  let token_mode: "hash" | "token" | "legacy_token" = "token";

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

  if (!share || share.revoked_at) return json({ error: "not_found" }, 404);
  if (share.expires_at && new Date(share.expires_at).getTime() < Date.now()) return json({ error: "expired" }, 410);

  // rides table does NOT have pickup/dropoff; that lives on ride_requests via rides.request_id
  const { data: ride, error: rideErr } = await supabase
    .from("rides")
    .select("id,status,request_id,rider_id,driver_id,created_at,started_at,completed_at,fare_amount_iqd,currency,product_code")
    .eq("id", share.ride_id)
    .maybeSingle();

  if (rideErr || !ride) {
    return json({ error: "ride_not_found", token_mode }, 404);
  }

  const { data: reqRow, error: reqErr } = await supabase
    .from("ride_requests")
    .select("id,status,pickup_lat,pickup_lng,dropoff_lat,dropoff_lng,pickup_address,dropoff_address,product_code,service_area_id,matched_at,accepted_at")
    .eq("id", ride.request_id)
    .maybeSingle();

  // If request row is missing, still return ride basics (do not hard-fail).
  const request = reqErr || !reqRow ? null : {
    id: reqRow.id,
    status: reqRow.status,
    pickup: { lat: reqRow.pickup_lat, lng: reqRow.pickup_lng, address: reqRow.pickup_address ?? null },
    dropoff: { lat: reqRow.dropoff_lat, lng: reqRow.dropoff_lng, address: reqRow.dropoff_address ?? null },
    product_code: reqRow.product_code ?? ride.product_code ?? null,
    service_area_id: reqRow.service_area_id ?? null,
    matched_at: reqRow.matched_at ?? null,
    accepted_at: reqRow.accepted_at ?? null,
  };

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

  // Active vehicle (optional) - minimal public info
  let vehicle: any = null;
  if (ride.driver_id) {
    const { data: v } = await supabase
      .from("driver_vehicles")
      .select("make,model,color,plate_number,vehicle_type,capacity")
      .eq("driver_id", ride.driver_id)
      .eq("is_active", true)
      .order("updated_at", { ascending: false })
      .limit(1);

    const vv = v?.[0];
    if (vv) {
      const plate = (vv.plate_number ?? "").toString();
      vehicle = {
        make: vv.make ?? null,
        model: vv.model ?? null,
        color: vv.color ?? null,
        vehicle_type: vv.vehicle_type ?? null,
        capacity: vv.capacity ?? null,
        plate_suffix: plate ? plate.slice(Math.max(0, plate.length - 3)) : null,
      };
    }
  }

  return json({
    ok: true,
    token_mode,
    ride: {
      id: ride.id,
      status: ride.status,
      created_at: ride.created_at,
      started_at: ride.started_at,
      completed_at: ride.completed_at,
      fare_amount_iqd: ride.fare_amount_iqd ?? null,
      currency: ride.currency ?? "IQD",
    },
    request,
    driver: ride.driver_id ? { id: ride.driver_id } : null,
    vehicle,
    location,
  }, 200);
});
