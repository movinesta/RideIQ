-- Session: Outbox retention (prevent unbounded growth)

CREATE OR REPLACE FUNCTION public.edge_webhook_outbox_prune(
  p_max_age_days integer DEFAULT 14,
  p_batch integer DEFAULT 5000
) RETURNS integer
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog, public'
AS $$
DECLARE
  v_days integer;
  v_batch integer;
  v_deleted integer;
BEGIN
  IF auth.role() IS DISTINCT FROM 'service_role' THEN
    RAISE EXCEPTION 'forbidden';
  END IF;

  v_days := GREATEST(1, LEAST(COALESCE(p_max_age_days, 14), 365));
  v_batch := GREATEST(1, LEAST(COALESCE(p_batch, 5000), 50000));

  WITH doomed AS (
    SELECT id
    FROM public.edge_webhook_outbox
    WHERE status IN ('sent','failed')
      AND created_at < now() - make_interval(days => v_days)
    ORDER BY id ASC
    LIMIT v_batch
  )
  DELETE FROM public.edge_webhook_outbox o
  USING doomed d
  WHERE o.id = d.id;

  GET DIAGNOSTICS v_deleted = ROW_COUNT;
  RETURN v_deleted;
END;
$$;

ALTER FUNCTION public.edge_webhook_outbox_prune(integer, integer) OWNER TO postgres;

REVOKE ALL ON FUNCTION public.edge_webhook_outbox_prune(integer, integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.edge_webhook_outbox_prune(integer, integer) FROM anon;
REVOKE ALL ON FUNCTION public.edge_webhook_outbox_prune(integer, integer) FROM authenticated;
GRANT ALL ON FUNCTION public.edge_webhook_outbox_prune(integer, integer) TO service_role;
