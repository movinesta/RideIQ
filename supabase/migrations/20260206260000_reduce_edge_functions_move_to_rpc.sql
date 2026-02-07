-- Session 11 (edge reduction)
-- Goal: remove Edge Functions that are purely DB reads/writes and serve them via Postgres RPC.

-- =========================
-- Public support content
-- =========================

CREATE OR REPLACE FUNCTION public.support_articles_list_public_v1()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $$
DECLARE
  v_sections jsonb;
  v_articles jsonb;
BEGIN
  SELECT COALESCE(
    jsonb_agg(
      jsonb_build_object(
        'id', s.id,
        'key', s.key,
        'title', s.title,
        'sort_order', s.sort_order
      )
      ORDER BY s.sort_order ASC
    ),
    '[]'::jsonb
  )
  INTO v_sections
  FROM public.support_sections s
  WHERE s.enabled = true;

  SELECT COALESCE(
    jsonb_agg(
      jsonb_build_object(
        'id', a.id,
        'section_id', a.section_id,
        'slug', a.slug,
        'title', a.title,
        'summary', a.summary,
        'tags', a.tags,
        'updated_at', a.updated_at
      )
      ORDER BY a.updated_at DESC
    ),
    '[]'::jsonb
  )
  INTO v_articles
  FROM (
    SELECT a.*
    FROM public.support_articles a
    WHERE a.enabled = true
    ORDER BY a.updated_at DESC
    LIMIT 200
  ) a;

  RETURN jsonb_build_object('ok', true, 'sections', v_sections, 'articles', v_articles);
END;
$$;

REVOKE ALL ON FUNCTION public.support_articles_list_public_v1() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.support_articles_list_public_v1() TO anon;
GRANT EXECUTE ON FUNCTION public.support_articles_list_public_v1() TO authenticated;


CREATE OR REPLACE FUNCTION public.support_article_get_public_v1(p_slug text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $$
DECLARE
  v_article jsonb;
BEGIN
  IF p_slug IS NULL OR btrim(p_slug) = '' THEN
    RETURN jsonb_build_object('ok', false, 'error', 'missing_slug');
  END IF;

  SELECT to_jsonb(a)
  INTO v_article
  FROM public.support_articles a
  WHERE a.enabled = true
    AND a.slug = btrim(p_slug)
  LIMIT 1;

  IF v_article IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', 'not_found');
  END IF;

  -- Keep response shape compatible with the previous Edge endpoint.
  RETURN jsonb_build_object('ok', true, 'article', v_article);
END;
$$;

REVOKE ALL ON FUNCTION public.support_article_get_public_v1(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.support_article_get_public_v1(text) TO anon;
GRANT EXECUTE ON FUNCTION public.support_article_get_public_v1(text) TO authenticated;


-- =========================
-- Scheduled rides list (user-scoped)
-- =========================

CREATE OR REPLACE FUNCTION public.scheduled_ride_list_user_v1(p_limit integer DEFAULT 50)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $$
DECLARE
  v_user uuid;
  v_limit integer;
  v_rows jsonb;
BEGIN
  v_user := auth.uid();
  IF v_user IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', 'unauthorized');
  END IF;

  v_limit := greatest(1, least(coalesce(p_limit, 50), 200));

  SELECT COALESCE(jsonb_agg(to_jsonb(sr) ORDER BY sr.scheduled_at ASC), '[]'::jsonb)
  INTO v_rows
  FROM (
    SELECT *
    FROM public.scheduled_rides
    WHERE rider_id = v_user
    ORDER BY scheduled_at ASC
    LIMIT v_limit
  ) sr;

  RETURN jsonb_build_object('ok', true, 'scheduled_rides', v_rows);
END;
$$;

REVOKE ALL ON FUNCTION public.scheduled_ride_list_user_v1(integer) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.scheduled_ride_list_user_v1(integer) TO authenticated;


-- =========================
-- Nearby drivers (user-scoped)
-- =========================

CREATE OR REPLACE FUNCTION public.drivers_nearby_user_v1(
  p_request_id uuid DEFAULT NULL,
  p_pickup_lat double precision DEFAULT NULL,
  p_pickup_lng double precision DEFAULT NULL,
  p_radius_m integer DEFAULT 5000,
  p_limit_n integer DEFAULT 25,
  p_required_capacity integer DEFAULT 4,
  p_stale_after_s integer DEFAULT 120
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $$
DECLARE
  v_user uuid;
  v_lat double precision;
  v_lng double precision;
  v_radius integer;
  v_limit integer;
  v_capacity integer;
  v_stale integer;
  v_result jsonb;
  v_allowed boolean;
  v_remaining integer;
  v_reset_at text;
  v_drivers jsonb;
  v_stats jsonb;
BEGIN
  v_user := auth.uid();
  IF v_user IS NULL THEN
    RETURN jsonb_build_object('ok', false, 'error', 'unauthorized');
  END IF;

  v_radius := greatest(100, least(coalesce(p_radius_m, 5000), 50000));
  v_limit := greatest(1, least(coalesce(p_limit_n, 25), 200));
  v_capacity := greatest(1, least(coalesce(p_required_capacity, 4), 8));
  v_stale := greatest(10, least(coalesce(p_stale_after_s, 120), 600));

  IF p_request_id IS NOT NULL THEN
    SELECT rr.pickup_lat, rr.pickup_lng
      INTO v_lat, v_lng
    FROM public.ride_requests rr
    WHERE rr.id = p_request_id
      AND rr.rider_id = v_user
    LIMIT 1;

    IF v_lat IS NULL OR v_lng IS NULL THEN
      RETURN jsonb_build_object('ok', false, 'error', 'not_found');
    END IF;
  ELSE
    v_lat := p_pickup_lat;
    v_lng := p_pickup_lng;
    IF v_lat IS NULL OR v_lng IS NULL THEN
      RETURN jsonb_build_object('ok', false, 'error', 'missing_pickup');
    END IF;
  END IF;

  IF v_lat < -90 OR v_lat > 90 OR v_lng < -180 OR v_lng > 180 THEN
    RETURN jsonb_build_object('ok', false, 'error', 'invalid_pickup');
  END IF;

  -- Delegate to the indexed SECURITY DEFINER function that also enforces rate limiting.
  SELECT public.nearby_available_drivers_v2(
    p_pickup_lat => v_lat,
    p_pickup_lng => v_lng,
    p_radius_m => v_radius,
    p_stale_after_s => v_stale,
    p_limit => v_limit,
    p_required_capacity => v_capacity
  )
  INTO v_result;

  v_allowed := COALESCE((v_result ->> 'allowed')::boolean, true);
  v_remaining := COALESCE((v_result ->> 'remaining')::integer, 0);
  v_reset_at := COALESCE(v_result ->> 'reset_at', (now() + interval '1 minute')::text);

  IF NOT v_allowed THEN
    RETURN jsonb_build_object(
      'ok', false,
      'error', 'rate_limited',
      'remaining', v_remaining,
      'reset_at', v_reset_at
    );
  END IF;

  v_drivers := COALESCE(v_result -> 'drivers', '[]'::jsonb);
  v_stats := COALESCE(v_result -> 'stats', '{}'::jsonb);

  RETURN jsonb_build_object(
    'ok', true,
    'request', jsonb_build_object(
      'request_id', p_request_id,
      'pickup', jsonb_build_object(
        'lat', v_lat,
        'lng', v_lng,
        'radius_m', v_radius,
        'limit_n', v_limit,
        'required_capacity', v_capacity
      )
    ),
    'stats', v_stats,
    'drivers', v_drivers,
    'rate_limit', jsonb_build_object(
      'remaining', v_remaining,
      'reset_at', v_reset_at
    )
  );
END;
$$;

REVOKE ALL ON FUNCTION public.drivers_nearby_user_v1(uuid, double precision, double precision, integer, integer, integer, integer) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.drivers_nearby_user_v1(uuid, double precision, double precision, integer, integer, integer, integer) TO authenticated;


-- =========================
-- Admin user grant/revoke (user-scoped + admin-guarded)
-- =========================

CREATE OR REPLACE FUNCTION public.admin_grant_user_v1(p_user uuid, p_note text DEFAULT NULL)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $$
BEGIN
  -- Reuse the existing audited implementation.
  PERFORM public.admin_grant_user(p_user => p_user, p_note => p_note);
  RETURN jsonb_build_object('ok', true);
EXCEPTION
  WHEN others THEN
    -- Surface the original error message for UI mapping.
    RETURN jsonb_build_object('ok', false, 'error', SQLERRM);
END;
$$;

REVOKE ALL ON FUNCTION public.admin_grant_user_v1(uuid, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.admin_grant_user_v1(uuid, text) TO authenticated;


CREATE OR REPLACE FUNCTION public.admin_revoke_user_v1(p_user uuid, p_note text DEFAULT NULL)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO ''
AS $$
BEGIN
  PERFORM public.admin_revoke_user(p_user => p_user, p_note => p_note);
  RETURN jsonb_build_object('ok', true);
EXCEPTION
  WHEN others THEN
    RETURN jsonb_build_object('ok', false, 'error', SQLERRM);
END;
$$;

REVOKE ALL ON FUNCTION public.admin_revoke_user_v1(uuid, text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.admin_revoke_user_v1(uuid, text) TO authenticated;
