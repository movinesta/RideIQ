-- Session: Ride transition user RPC
--
-- Goal: make the ride transition hot path a thin Edge wrapper around a single DB RPC
-- while preserving optimistic-concurrency (optional expected_version) and idempotent retries.

CREATE OR REPLACE FUNCTION public.transition_ride_user_v1(
  p_ride_id uuid,
  p_to_status public.ride_status,
  p_expected_version integer DEFAULT NULL,
  p_cash_collected_amount_iqd integer DEFAULT NULL,
  p_cash_change_given_iqd integer DEFAULT NULL
) RETURNS public.rides
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog, public, extensions'
AS $$
DECLARE
  v_uid uuid;
  r public.rides;
  v_actor_type public.ride_actor_type;
  v_expected integer;
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  SELECT * INTO r
  FROM public.rides
  WHERE id = p_ride_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'ride_not_found';
  END IF;

  -- Idempotent retry: if the ride is already in the requested status, return the row.
  IF r.status = p_to_status THEN
    RETURN r;
  END IF;

  -- Actor must be a ride participant.
  IF r.driver_id = v_uid THEN
    v_actor_type := 'driver'::public.ride_actor_type;
  ELSIF r.rider_id = v_uid THEN
    v_actor_type := 'rider'::public.ride_actor_type;
  ELSE
    RAISE EXCEPTION 'forbidden';
  END IF;

  -- MVP authorization rules:
  -- - Driver can mark arrived / start / complete.
  -- - Rider cannot perform state-advancing driver actions, but can cancel.
  IF v_actor_type = 'rider'::public.ride_actor_type AND p_to_status IN (
    'arrived'::public.ride_status,
    'in_progress'::public.ride_status,
    'completed'::public.ride_status
  ) THEN
    RAISE EXCEPTION 'forbidden';
  END IF;

  -- Optional optimistic concurrency: if not provided, default to the current locked version.
  v_expected := COALESCE(p_expected_version, r.version);

  RETURN public.transition_ride_v3(
    p_ride_id,
    p_to_status,
    v_uid,
    v_actor_type,
    v_expected,
    p_cash_collected_amount_iqd,
    p_cash_change_given_iqd
  );
END;
$$;

ALTER FUNCTION public.transition_ride_user_v1(uuid, public.ride_status, integer, integer, integer) OWNER TO postgres;

REVOKE ALL ON FUNCTION public.transition_ride_user_v1(uuid, public.ride_status, integer, integer, integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.transition_ride_user_v1(uuid, public.ride_status, integer, integer, integer) FROM anon;
GRANT ALL ON FUNCTION public.transition_ride_user_v1(uuid, public.ride_status, integer, integer, integer) TO authenticated;
