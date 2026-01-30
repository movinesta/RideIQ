-- Add: unified catalog search RPC (used by copilot tools)
-- Requires pg_trgm for similarity search.
CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA extensions;

CREATE OR REPLACE FUNCTION public.search_catalog_v1(p_query text, p_limit integer DEFAULT 10, p_merchant_id uuid DEFAULT NULL::uuid)
RETURNS TABLE(
  entity_type text,
  merchant_id uuid,
  merchant_name text,
  business_type text,
  product_id uuid,
  product_name text,
  category text,
  price_iqd integer,
  score real
)
LANGUAGE sql STABLE
SET search_path TO 'pg_catalog, public'
AS $$
  WITH params AS (
    SELECT NULLIF(btrim(p_query), '') AS q,
           LEAST(GREATEST(COALESCE(p_limit, 10), 1), 50) AS lim,
           p_merchant_id AS mid
  ),
  merchants AS (
    SELECT
      'merchant'::text AS entity_type,
      m.id AS merchant_id,
      m.business_name AS merchant_name,
      m.business_type,
      NULL::uuid AS product_id,
      NULL::text AS product_name,
      NULL::text AS category,
      NULL::integer AS price_iqd,
      GREATEST(
        extensions.similarity(m.business_name::text, (SELECT q FROM params)::text),
        extensions.similarity(COALESCE(m.business_type,'')::text, (SELECT q FROM params)::text)
      )::real AS score
    FROM public.merchants m
    WHERE (SELECT q FROM params) IS NOT NULL
      AND m.status = 'approved'::text
      AND (
        m.business_name ILIKE '%' || (SELECT q FROM params) || '%'
        OR COALESCE(m.business_type,'') ILIKE '%' || (SELECT q FROM params) || '%'
        OR extensions.similarity(m.business_name::text, (SELECT q FROM params)::text) > 0.2
      )
  ),
  products AS (
    SELECT
      'product'::text AS entity_type,
      p.merchant_id,
      m.business_name,
      m.business_type,
      p.id AS product_id,
      p.name AS product_name,
      p.category,
      p.price_iqd,
      GREATEST(
        extensions.similarity(p.name::text, (SELECT q FROM params)::text),
        extensions.similarity(COALESCE(p.category,'')::text, (SELECT q FROM params)::text)
      )::real AS score
    FROM public.merchant_products p
    JOIN public.merchants m ON m.id = p.merchant_id
    WHERE (SELECT q FROM params) IS NOT NULL
      AND p.is_active = true
      AND m.status = 'approved'::text
      AND ((SELECT mid FROM params) IS NULL OR p.merchant_id = (SELECT mid FROM params))
      AND (
        p.name ILIKE '%' || (SELECT q FROM params) || '%'
        OR COALESCE(p.category,'') ILIKE '%' || (SELECT q FROM params) || '%'
        OR extensions.similarity(p.name::text, (SELECT q FROM params)::text) > 0.2
        OR extensions.similarity(COALESCE(p.category,'')::text, (SELECT q FROM params)::text) > 0.2
      )
  )
  SELECT *
  FROM (
    SELECT * FROM merchants
    UNION ALL
    SELECT * FROM products
  ) s
  ORDER BY score DESC, merchant_name ASC NULLS LAST
  LIMIT (SELECT lim FROM params);
$$;

GRANT EXECUTE ON FUNCTION public.search_catalog_v1(text, integer, uuid) TO authenticated;
