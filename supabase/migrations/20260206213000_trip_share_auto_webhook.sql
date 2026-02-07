-- Session: Trip safety auto-share webhook
--
-- Goal: move "auto share on trip start" off the ride-transition hot path.
-- We enqueue a durable outbox item from a DB trigger (no HTTP in-transaction).
-- The edge-webhook-dispatcher will deliver it to the trip-share-auto Edge function.

CREATE OR REPLACE FUNCTION public.trg_wh_trip_share_auto() RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog, public'
AS $$
DECLARE
  payload jsonb;
  v_enabled boolean;
  v_ttl integer;
BEGIN
  IF TG_OP <> 'UPDATE' THEN
    RETURN NEW;
  END IF;

  IF NEW.status IS DISTINCT FROM 'in_progress'::public.ride_status THEN
    RETURN NEW;
  END IF;

  IF OLD.status IS NOT DISTINCT FROM NEW.status THEN
    RETURN NEW;
  END IF;

  IF NEW.rider_id IS NULL THEN
    RETURN NEW;
  END IF;

  SELECT auto_share_on_trip_start, default_share_ttl_minutes
  INTO v_enabled, v_ttl
  FROM public.user_safety_settings
  WHERE user_id = NEW.rider_id;

  IF NOT COALESCE(v_enabled, false) THEN
    RETURN NEW;
  END IF;

  payload := jsonb_build_object(
    'type', 'UPDATE',
    'schema', TG_TABLE_SCHEMA,
    'table', TG_TABLE_NAME,
    'record', to_jsonb(NEW),
    'old_record', to_jsonb(OLD),
    'meta', jsonb_build_object('ttl_minutes', COALESCE(v_ttl, 120))
  );

  PERFORM public._edge_webhook_post(
    'trip-share-auto',
    'DISPATCH_WEBHOOK_SECRET',
    payload
  );

  RETURN NEW;
END;
$$;

ALTER FUNCTION public.trg_wh_trip_share_auto() OWNER TO postgres;

DROP TRIGGER IF EXISTS trg_wh_trip_share_auto ON public.rides;
CREATE TRIGGER trg_wh_trip_share_auto
AFTER UPDATE OF status ON public.rides
FOR EACH ROW
EXECUTE FUNCTION public.trg_wh_trip_share_auto();
