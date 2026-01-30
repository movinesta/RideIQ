
# Verification Walkthrough

**Purpose:** Verify the logic fix for assignments, concurrency fixes for Chat, and security hardening for Driver Location.

## 1. Prerequisites
- **Supabase CLI:** Ensure you have the `supabase` CLI installed.
- **Project Root:** Run commands from `RideIQ-main/RideIQ-main`.

## 2. Apply Database Migrations (Batch 1 & 2)
**Goal:** Deploy the Logic Fix (Batch 1) and Concurrency/UX Fixes (Batch 2).

1.  **Review Migrations:**
    *   `supabase/migrations/20260130120000_fix_dispatch_match_logic.sql` (Logic)
    *   `supabase/migrations/20260130130000_fix_concurrency_and_ux.sql` (Chat Race + Cancel RPC)

2.  **Deploy:**
    ```bash
    supabase db reset
    # OR manually run both SQL files in the Dashboard SQL Editor.
    ```

## 3. Deploy Edge Functions
**Goal:** Deploy the new `driver-location-update` function.

1.  **Deploy:**
    ```bash
    supabase functions deploy driver-location-update
    ```

## 4. Verification Steps

### A. Logic Fix (Match Freshness) (From Previous Step)
- Call `dispatch_match_ride` with `stale_after_seconds: 45`.
- Ensure drivers updated 60s ago are **excluded**.

### B. Concurrency Fix (Chat Thread)
- **Manual Test (SQL):**
  ```sql
  -- Try to create the same thread twice in the same transaction block or rapidly.
  -- Should no longer throw Unique Violation.
  SELECT public.merchant_order_get_or_create_chat_thread('YOUR_ORDER_ID');
  ```

### C. UX Fix (Cancellation)
- **Frontend Test:**
  1. Request a ride.
  2. Have a driver accept it.
  3. Try to cancel from the Rider UI.
  4. **Expectation:** You should see a specific toast message: "Cannot cancel ride at this stage" (instead of a generic error).

### D. Security Fix (Driver Location)
- **Frontend Test:**
  1. Open Driver Page -> Go Online.
  2. Monitor Network Tab.
  3. **Check:** Verify calls go to `/functions/v1/driver-location-update` instead of `rest/v1/driver_locations`.
  4. **Rate Limit:** If you manipulate the client to send >20 req/min, expect `429 Too Many Requests`.
