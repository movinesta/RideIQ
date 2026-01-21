-- Hotfix: wallet & rides constraints
-- - wallet_get_my_account() performs INSERT/UPSERT and must be VOLATILE (not STABLE)
-- - rides(request_id) must be uniquely constrained for ON CONFLICT (request_id) to work

ALTER FUNCTION public.wallet_get_my_account() VOLATILE;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_index i
    JOIN pg_attribute a
      ON a.attrelid = i.indrelid
     AND a.attnum = ANY(i.indkey)
    WHERE i.indrelid = 'public.rides'::regclass
      AND i.indisunique
      AND a.attname = 'request_id'
  ) THEN
    CREATE UNIQUE INDEX ux_rides_request_id ON public.rides(request_id);
  END IF;
END $$;
