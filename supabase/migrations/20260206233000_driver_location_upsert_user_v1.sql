-- Session: Driver location update RPC
--
-- Goal:
--   Make `driver-location-update` a thin Edge wrapper around a single DB RPC.
--   This centralizes validation and the upsert in one transaction, avoids
--   direct table writes from Edge, and keeps the endpoint user-scoped.

BEGIN;

CREATE OR REPLACE FUNCTION public.driver_location_upsert_user_v1(
  p_lat double precision,
  p_lng double precision,
  p_vehicle_type text,
  p_accuracy_m numeric DEFAULT NULL,
  p_heading numeric DEFAULT NULL,
  p_speed_mps numeric DEFAULT NULL
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog, public, extensions'
AS $$
DECLARE
  v_uid uuid;
  v_vehicle text;
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  -- Location updates are driver-scoped. Fail fast with a stable error code.
  IF NOT EXISTS (SELECT 1 FROM public.drivers d WHERE d.id = v_uid) THEN
    RAISE EXCEPTION 'not_a_driver';
  END IF;

  IF p_lat IS NULL OR p_lng IS NULL OR p_lat < -90 OR p_lat > 90 OR p_lng < -180 OR p_lng > 180 THEN
    RAISE EXCEPTION 'invalid_coordinates';
  END IF;

  -- Normalize and validate vehicle type.
  v_vehicle := lower(left(coalesce(p_vehicle_type, ''), 32));
  IF v_vehicle = '' THEN
    RAISE EXCEPTION 'invalid_vehicle_type';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM unnest(enum_range(NULL::public.driver_vehicle_type)) AS t(val)
    WHERE t.val::text = v_vehicle
  ) THEN
    RAISE EXCEPTION 'invalid_vehicle_type';
  END IF;

  -- Upsert current location. Optional fields are only updated when provided.
  INSERT INTO public.driver_locations(
    driver_id,
    lat,
    lng,
    accuracy_m,
    heading,
    speed_mps,
    vehicle_type
  ) VALUES (
    v_uid,
    p_lat,
    p_lng,
    p_accuracy_m,
    p_heading,
    p_speed_mps,
    v_vehicle
  )
  ON CONFLICT (driver_id)
  DO UPDATE SET
    lat = EXCLUDED.lat,
    lng = EXCLUDED.lng,
    accuracy_m = COALESCE(EXCLUDED.accuracy_m, public.driver_locations.accuracy_m),
    heading = COALESCE(EXCLUDED.heading, public.driver_locations.heading),
    speed_mps = COALESCE(EXCLUDED.speed_mps, public.driver_locations.speed_mps),
    vehicle_type = EXCLUDED.vehicle_type;

  RETURN jsonb_build_object('ok', true);
END;
$$;

COMMENT ON FUNCTION public.driver_location_upsert_user_v1(
  p_lat double precision,
  p_lng double precision,
  p_vehicle_type text,
  p_accuracy_m numeric,
  p_heading numeric,
  p_speed_mps numeric
) IS 'User-bound driver location upsert. Binds driver_id to auth.uid() and upserts into driver_locations with basic validation.';

REVOKE ALL ON FUNCTION public.driver_location_upsert_user_v1(
  p_lat double precision,
  p_lng double precision,
  p_vehicle_type text,
  p_accuracy_m numeric,
  p_heading numeric,
  p_speed_mps numeric
) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION public.driver_location_upsert_user_v1(
  p_lat double precision,
  p_lng double precision,
  p_vehicle_type text,
  p_accuracy_m numeric,
  p_heading numeric,
  p_speed_mps numeric
) TO authenticated;

GRANT EXECUTE ON FUNCTION public.driver_location_upsert_user_v1(
  p_lat double precision,
  p_lng double precision,
  p_vehicle_type text,
  p_accuracy_m numeric,
  p_heading numeric,
  p_speed_mps numeric
) TO service_role;

COMMIT;
