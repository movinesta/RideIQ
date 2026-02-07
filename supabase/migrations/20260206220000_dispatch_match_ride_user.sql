-- User-bound wrapper for dispatch matching.
--
-- Motivation:
--   `public.dispatch_match_ride(...)` is service_role-only because it performs
--   privileged dispatch/matching state changes. The client-facing edge endpoint
--   should not need service_role; instead it should bind rider_id to auth.uid()
--   in a SECURITY DEFINER wrapper.

BEGIN;

CREATE OR REPLACE FUNCTION public.dispatch_match_ride_user(
  p_request_id uuid,
  p_radius_m numeric DEFAULT 5000,
  p_limit_n integer DEFAULT 20,
  p_match_ttl_seconds integer DEFAULT 120,
  p_stale_after_seconds integer DEFAULT 120
) RETURNS TABLE(
  id uuid,
  status public.ride_request_status,
  assigned_driver_id uuid,
  match_deadline timestamp with time zone,
  match_attempts integer,
  matched_at timestamp with time zone
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog, public, extensions'
AS $$
DECLARE
  v_uid uuid;
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  RETURN QUERY
    SELECT *
    FROM public.dispatch_match_ride(
      p_request_id,
      v_uid,
      p_radius_m,
      p_limit_n,
      p_match_ttl_seconds,
      p_stale_after_seconds
    );
END;
$$;

COMMENT ON FUNCTION public.dispatch_match_ride_user(
  p_request_id uuid,
  p_radius_m numeric,
  p_limit_n integer,
  p_match_ttl_seconds integer,
  p_stale_after_seconds integer
) IS 'User-bound wrapper around dispatch_match_ride; binds rider_id to auth.uid().';

REVOKE ALL ON FUNCTION public.dispatch_match_ride_user(
  p_request_id uuid,
  p_radius_m numeric,
  p_limit_n integer,
  p_match_ttl_seconds integer,
  p_stale_after_seconds integer
) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION public.dispatch_match_ride_user(
  p_request_id uuid,
  p_radius_m numeric,
  p_limit_n integer,
  p_match_ttl_seconds integer,
  p_stale_after_seconds integer
) TO authenticated;

GRANT EXECUTE ON FUNCTION public.dispatch_match_ride_user(
  p_request_id uuid,
  p_radius_m numeric,
  p_limit_n integer,
  p_match_ttl_seconds integer,
  p_stale_after_seconds integer
) TO service_role;

COMMIT;
