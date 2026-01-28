-- Database Index Recommendations for RideIQ
-- Run these in your Supabase SQL Editor to improve query performance.

-- ============================================================
-- RIDE INTENTS
-- ============================================================
-- High-cardinality lookups by service area and status
CREATE INDEX IF NOT EXISTS idx_ride_intents_service_area_status 
  ON public.ride_intents (service_area_id, status);

-- For admin queries filtering by creation time
CREATE INDEX IF NOT EXISTS idx_ride_intents_created_at 
  ON public.ride_intents (created_at DESC);

-- ============================================================
-- RIDE REQUESTS
-- ============================================================
-- Common filter: active requests by rider
CREATE INDEX IF NOT EXISTS idx_ride_requests_rider_status 
  ON public.ride_requests (rider_id, status);

-- Driver matching queries
CREATE INDEX IF NOT EXISTS idx_ride_requests_status_created 
  ON public.ride_requests (status, created_at) 
  WHERE status IN ('requested', 'matched');

-- ============================================================
-- RIDES
-- ============================================================
-- Active rides per driver
CREATE INDEX IF NOT EXISTS idx_rides_driver_status 
  ON public.rides (driver_id, status);

-- Rider history
CREATE INDEX IF NOT EXISTS idx_rides_rider_created 
  ON public.rides (rider_id, created_at DESC);

-- ============================================================
-- DRIVER LOCATIONS (Hot table - location updates)
-- ============================================================
-- Spatial index for nearby driver search (if using PostGIS)
-- Note: This may already exist, verify before creating
-- CREATE INDEX IF NOT EXISTS idx_driver_locations_loc 
--   ON public.driver_locations USING GIST (loc);

-- ============================================================
-- WALLET ENTRIES
-- ============================================================
-- User wallet history
CREATE INDEX IF NOT EXISTS idx_wallet_entries_user_created 
  ON public.wallet_entries (user_id, created_at DESC);

-- ============================================================
-- TOPUP INTENTS
-- ============================================================
-- Pending topups for reconciliation jobs
CREATE INDEX IF NOT EXISTS idx_topup_intents_status 
  ON public.topup_intents (status) 
  WHERE status IN ('created', 'pending');

-- ============================================================
-- API RATE LIMITS
-- ============================================================
-- Key lookup for rate limiting (likely already has PK)
-- Ensure this table uses a composite PK or index on (key, window_start)
