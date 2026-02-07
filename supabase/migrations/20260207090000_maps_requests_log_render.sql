-- Enable render request logging in public.maps_requests_log.
-- We extend existing CHECK constraints to include capability/action='render'.

BEGIN;

ALTER TABLE public.maps_requests_log
  DROP CONSTRAINT IF EXISTS maps_requests_log_cap_chk;

ALTER TABLE public.maps_requests_log
  ADD CONSTRAINT maps_requests_log_cap_chk
  CHECK (capability IN ('geocode', 'reverse_geocode', 'directions', 'distance_matrix', 'render'));

ALTER TABLE public.maps_requests_log
  DROP CONSTRAINT IF EXISTS maps_requests_log_action_chk;

ALTER TABLE public.maps_requests_log
  ADD CONSTRAINT maps_requests_log_action_chk
  CHECK (action IN ('geocode', 'reverse_geocode', 'directions', 'matrix', 'render'));

COMMIT;
