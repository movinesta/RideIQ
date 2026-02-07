-- Session: Ride transition hardening
-- Goal: eliminate Edge-side cash collection writes on the ride completion hot path
-- by moving cash validation + cash_collections insertion into a single DB RPC.

CREATE OR REPLACE FUNCTION public.transition_ride_v3(
  p_ride_id uuid,
  p_to_status public.ride_status,
  p_actor_id uuid,
  p_actor_type public.ride_actor_type,
  p_expected_version integer,
  p_cash_collected_amount_iqd integer DEFAULT NULL,
  p_cash_change_given_iqd integer DEFAULT NULL
) RETURNS public.rides
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog, public, extensions'
AS $$
DECLARE
  r public.rides;
  v_from public.ride_status;
  v_pay public.ride_payment_method;
  v_cash record;
  v_service_area uuid;
  v_fee integer;
  v_expected integer;
  v_collected integer;
  v_change integer;
  v_net integer;
BEGIN
  SELECT * INTO r FROM public.rides WHERE id = p_ride_id FOR UPDATE;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'ride_not_found';
  END IF;

  IF r.version <> p_expected_version THEN
    RAISE EXCEPTION 'version_mismatch';
  END IF;

  v_from := r.status;

  IF NOT (
    (v_from = 'assigned' AND p_to_status IN ('arrived','canceled')) OR
    (v_from = 'arrived' AND p_to_status IN ('in_progress','canceled')) OR
    (v_from = 'in_progress' AND p_to_status IN ('completed','canceled'))
  ) THEN
    RAISE EXCEPTION 'invalid_transition';
  END IF;

  IF p_to_status = 'in_progress' THEN
    IF COALESCE(r.pickup_pin_required, false) AND r.pickup_pin_verified_at IS NULL THEN
      RAISE EXCEPTION 'pickup_pin_required';
    END IF;
  END IF;

  v_pay := COALESCE(r.payment_method, 'wallet'::public.ride_payment_method);

  -- Cash ride completion: validate and record cash collection atomically if missing.
  IF p_to_status = 'completed' AND v_pay = 'cash'::public.ride_payment_method THEN
    v_expected := COALESCE(r.cash_expected_amount_iqd, r.fare_amount_iqd, 0);
    IF v_expected <= 0 THEN
      RAISE EXCEPTION 'cash_expected_missing';
    END IF;

    v_collected := p_cash_collected_amount_iqd;
    v_change := COALESCE(p_cash_change_given_iqd, 0);

    IF v_collected IS NULL THEN
      RAISE EXCEPTION 'cash_required';
    END IF;

    IF v_collected < 0 OR v_change < 0 OR v_collected < v_change THEN
      RAISE EXCEPTION 'cash_invalid';
    END IF;

    v_net := v_collected - v_change;
    IF v_net < v_expected THEN
      RAISE EXCEPTION 'cash_underpaid';
    END IF;

    -- If no cash collection exists yet, insert a reported row attributed to the actor.
    SELECT * INTO v_cash
    FROM public.cash_collections
    WHERE ride_id = r.id
      AND status IN ('reported'::public.cash_collection_status, 'verified'::public.cash_collection_status)
    LIMIT 1;

    IF NOT FOUND THEN
      INSERT INTO public.cash_collections (
        ride_id,
        expected_amount_iqd,
        collected_amount_iqd,
        change_given_iqd,
        status,
        reported_by
      ) VALUES (
        r.id,
        v_expected,
        v_collected,
        v_change,
        'reported'::public.cash_collection_status,
        p_actor_id
      )
      ON CONFLICT (ride_id) DO NOTHING;
    END IF;
  END IF;

  UPDATE public.rides
    SET status = p_to_status,
        version = version + 1,
        started_at = CASE WHEN p_to_status = 'in_progress' THEN COALESCE(started_at, now()) ELSE started_at END,
        completed_at = CASE WHEN p_to_status = 'completed' THEN COALESCE(completed_at, now()) ELSE completed_at END
  WHERE id = r.id
  RETURNING * INTO r;

  INSERT INTO public.ride_events (ride_id, actor_id, actor_type, event_type, payload)
  VALUES (r.id, p_actor_id, p_actor_type, 'ride_status_changed',
          jsonb_build_object('from', v_from, 'to', p_to_status));

  IF p_to_status IN ('completed','canceled') THEN
    PERFORM public.transition_driver(r.driver_id, 'available'::public.driver_status, p_actor_id, 'ride_' || p_to_status::text);
  END IF;

  IF p_to_status = 'completed' THEN
    IF v_pay = 'wallet'::public.ride_payment_method THEN
      PERFORM public.wallet_capture_ride_hold(r.id);
      UPDATE public.rides
        SET payment_status = 'captured'::public.ride_payment_status,
            paid_at = COALESCE(paid_at, now())
      WHERE id = r.id;
    ELSE
      -- Load cash collection and finalize ride payment fields.
      SELECT * INTO v_cash
      FROM public.cash_collections
      WHERE ride_id = r.id
        AND status IN ('reported'::public.cash_collection_status, 'verified'::public.cash_collection_status)
      LIMIT 1;

      IF NOT FOUND THEN
        RAISE EXCEPTION 'cash_collection_required';
      END IF;

      UPDATE public.rides
        SET payment_status = 'collected_cash'::public.ride_payment_status,
            cash_expected_amount_iqd = COALESCE(v_cash.expected_amount_iqd, cash_expected_amount_iqd, r.fare_amount_iqd),
            cash_collected_amount_iqd = COALESCE(v_cash.collected_amount_iqd, cash_collected_amount_iqd),
            cash_change_given_iqd = COALESCE(v_cash.change_given_iqd, cash_change_given_iqd),
            cash_collected_at = COALESCE(cash_collected_at, v_cash.created_at, now()),
            paid_at = COALESCE(paid_at, v_cash.created_at, now())
      WHERE id = r.id;

      SELECT service_area_id INTO v_service_area
      FROM public.ride_requests
      WHERE id = r.request_id;

      v_fee := public.platform_fee_compute_iqd(r.product_code, v_service_area, COALESCE(r.fare_amount_iqd, 0));
      UPDATE public.rides
        SET platform_fee_iqd = v_fee
      WHERE id = r.id;

      IF v_fee > 0 THEN
        PERFORM public.settlement_post_entry(
          'driver'::public.settlement_party_type,
          r.driver_id,
          -v_fee::bigint,
          'platform_fee_cash_ride',
          'ride',
          r.id,
          'ride:' || r.id::text || ':platform_fee'
        );
      END IF;
    END IF;

    PERFORM public.on_ride_completed_v1(r.id);

  ELSIF p_to_status = 'canceled' THEN
    IF v_pay = 'wallet'::public.ride_payment_method THEN
      PERFORM public.wallet_release_ride_hold(r.id);
    END IF;
  END IF;

  SELECT * INTO r FROM public.rides WHERE id = p_ride_id;
  RETURN r;
END;
$$;

ALTER FUNCTION public.transition_ride_v3(uuid, public.ride_status, uuid, public.ride_actor_type, integer, integer, integer) OWNER TO postgres;

COMMENT ON FUNCTION public.transition_ride_v3(uuid, public.ride_status, uuid, public.ride_actor_type, integer, integer, integer)
  IS 'Transitions a ride to a new status with version checking; for cash completions it can record a cash collection atomically when provided.';

REVOKE ALL ON FUNCTION public.transition_ride_v3(uuid, public.ride_status, uuid, public.ride_actor_type, integer, integer, integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.transition_ride_v3(uuid, public.ride_status, uuid, public.ride_actor_type, integer, integer, integer) TO service_role;
