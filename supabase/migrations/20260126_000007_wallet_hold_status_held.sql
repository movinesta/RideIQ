DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_enum e
    JOIN pg_type t ON t.oid = e.enumtypid
    WHERE t.typname = 'wallet_hold_status'
      AND e.enumlabel = 'held'
  ) THEN
    ALTER TYPE public.wallet_hold_status ADD VALUE 'held';
  END IF;
END $$;

CREATE OR REPLACE FUNCTION public.wallet_holds_normalize_status()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog, public'
AS $$
BEGIN
  IF NEW.status = 'held' THEN
    NEW.status := 'active';
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS wallet_holds_normalize_status ON public.wallet_holds;

CREATE TRIGGER wallet_holds_normalize_status
BEFORE INSERT OR UPDATE ON public.wallet_holds
FOR EACH ROW
EXECUTE FUNCTION public.wallet_holds_normalize_status();
