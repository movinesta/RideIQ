-- Add: driver hotspots recommendation RPC
CREATE OR REPLACE FUNCTION public.driver_hotspots_v1(
  p_hours integer DEFAULT 3,
  p_limit integer DEFAULT 5,
  p_grid_m integer DEFAULT 500,
  p_service_area_id uuid DEFAULT NULL
) RETURNS TABLE(
  lat double precision,
  lng double precision,
  requests_count integer,
  rides_count integer,
  score numeric
)
LANGUAGE sql STABLE SECURITY DEFINER
SET search_path TO 'pg_catalog', 'extensions'
AS $$
  WITH params AS (
    SELECT
      greatest(1, least(p_hours, 24))::int AS hours,
      greatest(1, least(p_limit, 50))::int AS lim,
      greatest(100, least(p_grid_m, 5000))::int AS grid_m,
      p_service_area_id AS service_area_id
  ),
  req AS (
    SELECT
      extensions.st_snaptogrid(
        extensions.st_transform((rr.pickup_loc::geometry), 3857),
        (SELECT grid_m FROM params)
      ) AS cell,
      1 AS requests_count,
      0 AS rides_count
    FROM public.ride_requests rr, params
    WHERE rr.created_at >= now() - ((SELECT hours FROM params) || ' hours')::interval
      AND ((SELECT service_area_id FROM params) IS NULL OR rr.service_area_id = (SELECT service_area_id FROM params))
  ),
  rid AS (
    SELECT
      extensions.st_snaptogrid(
        extensions.st_transform((rr.pickup_loc::geometry), 3857),
        (SELECT grid_m FROM params)
      ) AS cell,
      0 AS requests_count,
      1 AS rides_count
    FROM public.rides r
    JOIN public.ride_requests rr ON rr.id = r.request_id
    CROSS JOIN params
    WHERE r.created_at >= now() - ((SELECT hours FROM params) || ' hours')::interval
      AND ((SELECT service_area_id FROM params) IS NULL OR rr.service_area_id = (SELECT service_area_id FROM params))
  ),
  unioned AS (
    SELECT * FROM req
    UNION ALL
    SELECT * FROM rid
  ),
  agg AS (
    SELECT
      cell,
      sum(requests_count)::int AS requests_count,
      sum(rides_count)::int AS rides_count
    FROM unioned
    GROUP BY cell
  ),
  with_centroid AS (
    SELECT
      extensions.st_transform(extensions.st_centroid(cell), 4326) AS cgeom,
      requests_count,
      rides_count
    FROM agg
  )
  SELECT
    extensions.st_y(cgeom) AS lat,
    extensions.st_x(cgeom) AS lng,
    requests_count,
    rides_count,
    (requests_count + rides_count)::numeric AS score
  FROM with_centroid
  ORDER BY score DESC, requests_count DESC, rides_count DESC
  LIMIT (SELECT lim FROM params);
$$;

ALTER FUNCTION public.driver_hotspots_v1(integer, integer, integer, uuid) OWNER TO postgres;

GRANT EXECUTE ON FUNCTION public.driver_hotspots_v1(integer, integer, integer, uuid) TO authenticated;
