
# Adversarial Code Audit Findings

**Date:** 2026-01-30
**Auditor:** Antigravity (AI)
**Assessment:** Healthy, with specific concurrency and failure-handling risks.

## 1. Concurrency: Race Condition in Merchant Chat Creation (Medium)
- **Problem:** The SQL function `merchant_order_get_or_create_chat_thread` checks for an existing thread (`SELECT`) and then inserts one if missing. It lacks `FOR UPDATE` or `ON CONFLICT` handling.
- **Why:** If the Merchant and Customer open the chat simultaneously, both transactions see "no thread" -> both attempt `INSERT`. One fails with a Unique Constraint violation.
- **Component:** `supabase/schema.sql` (Function: `merchant_order_get_or_create_chat_thread`)
- **Fix:** Use `INSERT ... ON CONFLICT (merchant_id, customer_id) DO NOTHING` and then `SELECT` again to return the ID.

## 2. Logic: Blind Cancellation Logic in Frontend (Low/UX)
- **Problem:** `RiderPage.tsx` calls `update({ status: 'cancelled' })` on the matching request.
- **Why:** If the driver accepts the ride *milliseconds* before the user clicks cancel, the RLS policy (`ride_requests_update_own_cancel`) correctly blocks the update (status is now 'accepted', not 'matched').
- **Failure Scenario:** The user sees a generic implementation error (e.g., "Row not found" or "Permission denied") instead of "Ride already assigned - Cancellation Failed".
- **Fix:** Frontend should handle the specific error or `rpc('cancel_ride_request')` should be used to return a clean error code (`ALREADY_ACCEPTED`) for better UX.

## 3. Security: Unbounded Location Writes (Medium)
- **Problem:** `DriverPage.tsx` writes directly to `driver_locations` via Supabase Client (`upsert`).
- **Why:** While RLS likely protects *who* can write (own rows), there is no rate limiting at the database layer. A malicious client could flood the table with millions of location points per second.
- **Component:** `apps/web/src/pages/DriverPage.tsx` + Database.
- **Fix:** Move location updates to an Edge Function (`driver-location-update`) to enforce rate limits (e.g., 1 update per 3s), OR use a minimal `driver_locations_latest` table for current state and a separate partitioned table for history.

## 4. Resilience: Payout Job Locking is "DIY" (Low)
- **Problem:** `payout-job-send` implements its own locking mechanism using `locked_at` timestamp.
- **Analysis:** The logic `locked_at < 5 mins ago` effectively handles crashed jobs. However, high-concurrency environments might prefer Postgres Advisory Locks or `FOR UPDATE SKIP LOCKED` on the `SELECT` to avoid optimistic lock contention.
- **Verdict:** Acceptable for current scale.

## 5. Performance: Monolithic Schema File (Low)
- **Problem:** `supabase/schema.sql` is >35k lines.
- **Impact:** Reviewing changes is error-prone. Risky for team scaling.
- **Suggestion:** No immediate code fix, but operational risk.

## 6. Logic: `dispatch_match_ride` Stale Guardrail (Fixed)
- **Status:** **CRITICAL** issue found and fixed in previous step.
- **Recap:** Hardcoded 120s limit prevented realtime matching. Patch provided.

---

## 7. Next Steps (Prioritized)

1.  **Apply Logic Patch:** Deploy `supabase/migrations/20260130120000_fix_dispatch_match_logic.sql`.
2.  **Fix Chat Race Condition:** Update `merchant_order_get_or_create_chat_thread` to use `ON CONFLICT`.
3.  **Harden Location Tracking:** Consider moving driver location updates to an Edge Function.
