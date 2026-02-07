-- Session: Compatibility RPCs for pickup PIN verification (edge-computed PIN fallback)

CREATE OR REPLACE FUNCTION public.ride_pickup_pin_record_failure(
  p_ride_id uuid
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog, public'
AS $$
DECLARE
  v_uid uuid;
  r record;
  v_now timestamptz := now();
  v_fail int;
  v_locked_until timestamptz;
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  SELECT id, driver_id, pickup_pin_required, pickup_pin_verified_at, pickup_pin_fail_count, pickup_pin_locked_until
  INTO r
  FROM public.rides
  WHERE id = p_ride_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'ride_not_found';
  END IF;

  IF r.driver_id IS DISTINCT FROM v_uid THEN
    RAISE EXCEPTION 'forbidden';
  END IF;

  IF NOT COALESCE(r.pickup_pin_required, false) THEN
    RETURN jsonb_build_object('ok', true, 'required', false, 'verified', r.pickup_pin_verified_at IS NOT NULL, 'verified_at', r.pickup_pin_verified_at);
  END IF;

  IF r.pickup_pin_verified_at IS NOT NULL THEN
    RETURN jsonb_build_object('ok', true, 'required', true, 'verified', true, 'verified_at', r.pickup_pin_verified_at);
  END IF;

  v_fail := COALESCE(r.pickup_pin_fail_count, 0) + 1;
  v_locked_until := CASE WHEN v_fail >= 5 THEN v_now + interval '10 minutes' ELSE NULL END;

  UPDATE public.rides
  SET pickup_pin_fail_count = v_fail,
      pickup_pin_last_attempt_at = v_now,
      pickup_pin_locked_until = v_locked_until
  WHERE id = p_ride_id;

  RETURN jsonb_build_object(
    'ok', false,
    'code', CASE WHEN v_locked_until IS NOT NULL THEN 'PIN_LOCKED' ELSE 'INVALID_PIN' END,
    'fail_count', v_fail,
    'remaining_attempts', GREATEST(0, 5 - v_fail),
    'locked_until', v_locked_until
  );
END;
$$;

ALTER FUNCTION public.ride_pickup_pin_record_failure(uuid) OWNER TO postgres;

REVOKE ALL ON FUNCTION public.ride_pickup_pin_record_failure(uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION public.ride_pickup_pin_record_failure(uuid) TO service_role;
GRANT ALL ON FUNCTION public.ride_pickup_pin_record_failure(uuid) TO authenticated;


CREATE OR REPLACE FUNCTION public.ride_pickup_pin_mark_verified(
  p_ride_id uuid
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog, public'
AS $$
DECLARE
  v_uid uuid;
  r record;
  v_now timestamptz := now();
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  SELECT id, rider_id, driver_id, pickup_pin_required, pickup_pin_verified_at, pickup_pin_locked_until
  INTO r
  FROM public.rides
  WHERE id = p_ride_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'ride_not_found';
  END IF;

  IF r.driver_id IS DISTINCT FROM v_uid THEN
    RAISE EXCEPTION 'forbidden';
  END IF;

  IF NOT COALESCE(r.pickup_pin_required, false) THEN
    RETURN jsonb_build_object('ok', true, 'required', false, 'verified', r.pickup_pin_verified_at IS NOT NULL, 'verified_at', r.pickup_pin_verified_at);
  END IF;

  IF r.pickup_pin_verified_at IS NOT NULL THEN
    RETURN jsonb_build_object('ok', true, 'required', true, 'verified', true, 'verified_at', r.pickup_pin_verified_at);
  END IF;

  IF r.pickup_pin_locked_until IS NOT NULL AND r.pickup_pin_locked_until > v_now THEN
    RETURN jsonb_build_object('ok', false, 'code', 'PIN_LOCKED', 'locked_until', r.pickup_pin_locked_until);
  END IF;

  UPDATE public.rides
  SET pickup_pin_verified_at = v_now,
      pickup_pin_fail_count = 0,
      pickup_pin_locked_until = NULL,
      pickup_pin_last_attempt_at = v_now
  WHERE id = p_ride_id;

  INSERT INTO public.ride_events(ride_id, actor_id, actor_type, event_type, payload)
  VALUES (
    p_ride_id,
    v_uid,
    'driver'::public.ride_actor_type,
    'pickup_pin_verified',
    jsonb_build_object('verified_at', v_now)
  );

  RETURN jsonb_build_object('ok', true, 'required', true, 'verified', true, 'verified_at', v_now);
END;
$$;

ALTER FUNCTION public.ride_pickup_pin_mark_verified(uuid) OWNER TO postgres;

REVOKE ALL ON FUNCTION public.ride_pickup_pin_mark_verified(uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION public.ride_pickup_pin_mark_verified(uuid) TO service_role;
GRANT ALL ON FUNCTION public.ride_pickup_pin_mark_verified(uuid) TO authenticated;
