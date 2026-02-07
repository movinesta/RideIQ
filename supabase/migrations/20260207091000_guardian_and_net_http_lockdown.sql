-- Session: Guardian tracking hardening + lock down net.http_post

-- ---------------------------------------------------------------------------
-- 1) Guardian trip tracking: prevent guardian_id spoofing
--
-- `get_guardian_trip_info(p_trip_id, p_guardian_id)` is SECURITY DEFINER and
-- previously executable by authenticated users. That allowed a caller to pass
-- another user's guardian_id (spoofing) if they could guess it.
--
-- Fix: restrict direct execution to service_role and introduce a user-bound
-- wrapper that derives guardian_id from auth.uid().
-- ---------------------------------------------------------------------------

REVOKE ALL ON FUNCTION public.get_guardian_trip_info(uuid, uuid) FROM authenticated;
REVOKE ALL ON FUNCTION public.get_guardian_trip_info(uuid, uuid) FROM anon;
GRANT ALL ON FUNCTION public.get_guardian_trip_info(uuid, uuid) TO service_role;
GRANT ALL ON FUNCTION public.get_guardian_trip_info(uuid, uuid) TO postgres;

CREATE OR REPLACE FUNCTION public.guardian_trip_track_user_v1(
  p_trip_id uuid
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog, public'
AS $$
DECLARE
  v_uid uuid;
  r record;
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  SELECT * INTO r
  FROM public.get_guardian_trip_info(p_trip_id, v_uid)
  LIMIT 1;

  IF NOT FOUND OR r.trip_id IS NULL THEN
    RAISE EXCEPTION 'trip_not_found';
  END IF;

  RETURN jsonb_build_object(
    'trip', jsonb_build_object(
      'id', r.trip_id,
      'status', r.status,
      'eta_minutes', r.eta_minutes,
      'driver', jsonb_build_object(
        'first_name', r.driver_first_name,
        'vehicle', jsonb_build_object(
          'make', r.vehicle_make,
          'model', r.vehicle_model,
          'color', r.vehicle_color
        )
      ),
      'location', jsonb_build_object(
        'lat', r.current_lat,
        'lng', r.current_lng
      )
    )
  );
END;
$$;

ALTER FUNCTION public.guardian_trip_track_user_v1(uuid) OWNER TO postgres;

REVOKE ALL ON FUNCTION public.guardian_trip_track_user_v1(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.guardian_trip_track_user_v1(uuid) TO authenticated;

-- ---------------------------------------------------------------------------
-- 2) net.http_post privilege tightening
--
-- Even if not used in triggers anymore, net.http_post is a powerful primitive.
-- Restrict it to service_role and privileged admin roles only.
-- ---------------------------------------------------------------------------

DO $$
BEGIN
  -- Function signature may vary by extension version. Attempt the known one.
  BEGIN
    REVOKE EXECUTE ON FUNCTION net.http_post(
      url text,
      body jsonb,
      params jsonb,
      headers jsonb,
      timeout_milliseconds integer
    ) FROM anon;

    REVOKE EXECUTE ON FUNCTION net.http_post(
      url text,
      body jsonb,
      params jsonb,
      headers jsonb,
      timeout_milliseconds integer
    ) FROM authenticated;
  EXCEPTION WHEN undefined_function THEN
    -- If the signature differs, do nothing; operator must re-apply with the right signature.
    NULL;
  END;
END;
$$;
