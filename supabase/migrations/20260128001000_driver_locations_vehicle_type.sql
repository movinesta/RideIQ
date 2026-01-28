-- RideIQ: fix PGRST204 - driver_locations.vehicle_type missing from PostgREST schema cache
-- Adds a nullable vehicle_type column to public.driver_locations to match frontend location upsert payload.
-- Triggers PostgREST schema cache reload in Supabase.

BEGIN;

ALTER TABLE public.driver_locations
  ADD COLUMN IF NOT EXISTS vehicle_type text;

-- Reload PostgREST schema cache (Supabase/PostgREST)
NOTIFY pgrst, 'reload schema';

COMMIT;
