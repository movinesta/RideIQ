// supabase/functions/drivers-nearby/index.ts
// Nearby-drivers endpoint for browser maps (rider/admin).
//
// Supports two modes:
// - request_id: uses the stored pickup_lat/pickup_lng from ride_requests (and enforces rider ownership)
// - coords: uses pickup_lat/pickup_lng directly (for manual map clicks)

import { handleOptions } from "../_shared/cors.ts";
import { errorJson, json } from "../_shared/json.ts";
import { createServiceClient, requireUser } from "../_shared/supabase.ts";

type NearbyDriversBody = {
  request_id?: string;
  pickup_lat?: number;
  pickup_lng?: number;
  lat?: number;
  lng?: number;
  radius_m?: number;
  limit_n?: number;
  stale_after_seconds?: number;
  stale_seconds?: number;
  required_capacity?: number;
  debug?: boolean;
};

function toNumber(v: unknown): number | null {
  const n = typeof v === "string" ? Number(v) : typeof v === "number" ? v : NaN;
  return Number.isFinite(n) ? n : null;
}

function clamp(n: number, min: number, max: number): number {
  return Math.min(max, Math.max(min, n));
}

function isUuid(v: string): boolean {
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(v);
}

function haversineMeters(lat1: number, lng1: number, lat2: number, lng2: number): number {
  const R = 6371000; // meters
  const toRad = (d: number) => (d * Math.PI) / 180;
  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) *
      Math.sin(dLng / 2) * Math.sin(dLng / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

Deno.serve(async (req) => {
  const opt = handleOptions(req);
  if (opt) return opt;

  if (req.method !== "POST") {
    return errorJson("Method not allowed", 405, "METHOD_NOT_ALLOWED");
  }

  // Auth: require a real user (rider/admin). Preflight is allowed via OPTIONS.
  const { user, error: authError } = await requireUser(req);
  if (!user) {
    return errorJson(authError ?? "Unauthorized", 401, "UNAUTHORIZED");
  }

  let body: NearbyDriversBody;
  try {
    body = await req.json();
  } catch {
    return errorJson("Invalid JSON body", 400, "BAD_REQUEST");
  }

  const service = createServiceClient();

  // Mode selection: request_id preferred if provided
  const request_id = typeof body?.request_id === "string" ? body.request_id.trim() : "";
  let pickup_source: "coords" | "request" = "coords";

  let pickup_lat = toNumber(body?.pickup_lat ?? body?.lat);
  let pickup_lng = toNumber(body?.pickup_lng ?? body?.lng);

  if (request_id) {
    if (!isUuid(request_id)) {
      return errorJson("Invalid request_id", 400, "BAD_REQUEST");
    }

    const { data: rr, error: rrErr } = await service
      .from("ride_requests")
      .select("id, rider_id, pickup_lat, pickup_lng")
      .eq("id", request_id)
      .maybeSingle();

    if (rrErr) {
      return errorJson(`Failed to load ride request: ${rrErr.message}`, 500, "DB_ERROR");
    }
    if (!rr) {
      return errorJson("Ride request not found", 404, "NOT_FOUND");
    }
    if (String(rr.rider_id ?? "") !== String(user.id)) {
      return errorJson("Forbidden", 403, "FORBIDDEN");
    }

    pickup_lat = typeof rr.pickup_lat === "number" ? rr.pickup_lat : null;
    pickup_lng = typeof rr.pickup_lng === "number" ? rr.pickup_lng : null;
    pickup_source = "request";
  }

  if (pickup_lat === null || pickup_lng === null) {
    return errorJson("pickup_lat/pickup_lng are required", 400, "BAD_REQUEST");
  }

  const radius_m = clamp(toNumber(body?.radius_m) ?? 5000, 100, 50000);
  const limit_n = clamp(Math.trunc(toNumber(body?.limit_n) ?? 25), 1, 200);
  const stale_after_seconds = clamp(
    Math.trunc(toNumber(body?.stale_after_seconds ?? body?.stale_seconds) ?? 120),
    10,
    3600,
  );
  const required_capacity = clamp(Math.trunc(toNumber(body?.required_capacity) ?? 4), 1, 8);
  const debug = body?.debug === true;

  // 1) Busy drivers (has an active ride)
  const busy = new Set<string>();
  {
    const { data, error } = await service
      .from("rides")
      .select("driver_id")
      .in("status", ["assigned", "arrived", "in_progress"]);
    if (error) {
      return errorJson(`Failed to load rides: ${error.message}`, 500, "DB_ERROR");
    }
    for (const r of data ?? []) {
      if (r?.driver_id) busy.add(String(r.driver_id));
    }
  }

  // 2) Recent driver locations
  // NOTE: We intentionally rely on driver_locations.lat/lng (not loc EWKB) to avoid output-format mismatches.
  const since = new Date(Date.now() - stale_after_seconds * 1000).toISOString();
  const { data: rows, error: locErr } = await service
    .from("driver_locations")
    .select("driver_id, updated_at, lat, lng, drivers(status, driver_vehicles(vehicle_type, capacity, is_active))")
    .gte("updated_at", since)
    .limit(2000);

  if (locErr) {
    return errorJson(`Failed to load driver locations: ${locErr.message}`, 500, "DB_ERROR");
  }

  const candidates: Array<{
    id: string;
    lat: number;
    lng: number;
    dist_m: number;
    updated_at: string;
    vehicle_type: string;
  }> = [];

  const debug_rows: Array<Record<string, unknown>> = [];

  for (const row of rows ?? []) {
    const driverId = String(row?.driver_id ?? "");
    if (!driverId) continue;

    if (busy.has(driverId)) {
      if (debug && debug_rows.length < 10) debug_rows.push({ driver_id: driverId, skip: "busy" });
      continue;
    }

    const driverObj = Array.isArray(row?.drivers) ? row.drivers[0] : row?.drivers;
    const status = driverObj?.status;
    if (status !== "available") {
      if (debug && debug_rows.length < 10) debug_rows.push({ driver_id: driverId, skip: "status", status });
      continue;
    }

    const vehicles = Array.isArray(driverObj?.driver_vehicles) ? driverObj.driver_vehicles : [];
    const activeVehicle = vehicles.find((v: any) => {
      const isActive = v?.is_active ?? true;
      const cap = typeof v?.capacity === "number" ? v.capacity : 4;
      return !!isActive && cap >= required_capacity;
    });
    if (!activeVehicle) {
      if (debug && debug_rows.length < 10) debug_rows.push({ driver_id: driverId, skip: "vehicle" });
      continue;
    }

    const lat = toNumber(row?.lat);
    const lng = toNumber(row?.lng);
    if (lat === null || lng === null) {
      if (debug && debug_rows.length < 10) debug_rows.push({ driver_id: driverId, skip: "missing_latlng" });
      continue;
    }

    const dist_m = haversineMeters(pickup_lat, pickup_lng, lat, lng);
    if (dist_m > radius_m) {
      if (debug && debug_rows.length < 10) debug_rows.push({ driver_id: driverId, skip: "radius", dist_m, radius_m });
      continue;
    }

    candidates.push({
      id: driverId,
      lat,
      lng,
      dist_m,
      updated_at: row.updated_at,
      vehicle_type: String(activeVehicle?.vehicle_type ?? "car_taxi"),
    });
  }

  candidates.sort((a, b) => a.dist_m - b.dist_m);
  const drivers = candidates.slice(0, limit_n);

  const resp: Record<string, unknown> = {
    ok: true,
    request: {
      user_id: user.id,
      request_id: request_id || null,
      pickup_source,
      pickup_lat,
      pickup_lng,
      radius_m,
      limit_n,
      stale_after_seconds,
      required_capacity,
    },
    stats: {
      scanned_locations: rows?.length ?? 0,
      busy_drivers: busy.size,
      matched: drivers.length,
    },
    drivers,
  };

  if (debug) resp["debug"] = debug_rows;

  return json(resp);
});
