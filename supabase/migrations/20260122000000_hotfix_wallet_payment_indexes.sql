-- Hotfixes for production testing
-- - Ensure wallet_get_my_account is VOLATILE (it performs INSERTs)
-- - Ensure required unique indexes exist for ON CONFLICT clauses

-- 1) wallet_get_my_account() must be VOLATILE because it may INSERT a wallet account.
ALTER FUNCTION public.wallet_get_my_account() VOLATILE;

-- 2) transition_ride / wallet_capture_ride_hold uses:
--    INSERT ... ON CONFLICT (ride_id) WHERE status='succeeded' ...
--    So we need a matching partial unique index.
CREATE UNIQUE INDEX IF NOT EXISTS ux_payments_ride_succeeded
  ON public.payments (ride_id)
  WHERE status = 'succeeded';

-- 3) Some flows use ON CONFLICT (request_id) for idempotency.
CREATE UNIQUE INDEX IF NOT EXISTS ux_rides_request_id
  ON public.rides (request_id);
