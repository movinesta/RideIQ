
# End-to-End Audit Findings Report

**Date:** 2026-01-30
**Project:** RideIQ
**Auditor:** Antigravity (AI)

## 1. Executive Summary
The RideIQ codebase is in **Healthy** condition. The architecture follows best practices for Supabase/Edge Functions, with heavy lifting correctly delegated to Postgres functions (`dispatch_match_ride`, `dispatch_accept_ride`). Security controls (RLS, Auth) are robust and correctly implemented.

**Key Strengths:**
- **RLS Coverage:** Critical tables (`ride_requests`, `ride_intents`, `ride_incidents`) have precise, role-based policies.
- **Type Safety:** Automated type generation (`scripts/generate-db-types.mjs`) ensures Frontend and Backend are in sync.
- **Security:** Secrets are managed via `Deno.env` (checked) and critical payments logic (`zaincash-return`) verifies signatures.

**Issues Found:**
- **P2 (Logic):** `dispatch_match_ride` SQL function has a hardcoded guardrail (120s) that overrides the API's `stale_after_seconds` parameter, preventing "fresh" driver matching (e.g. 30s).
- **P3 (Maintenance):** `supabase/schema.sql` is a monolithic 1.2MB file, making manual review difficult.
- **Tooling:** Grep tools struggle with the schema file encoding/size, requiring custom scripts for audit.

---

## 2. Findings Detail

### [P2] Logic Mismatch in Match Configuration
- **Component:** Database (`dispatch_match_ride` function)
- **Evidence:** `supabase/schema.sql` line 2842: `v_stale_after := greatest(120, coalesce(p_stale_after_seconds, 120));`
- **Impact:** Clients requesting fresher driver locations (e.g., `stale_after_seconds: 30`) are ignored. The DB enforces `120s` minimum. This degrades matching quality for moving drivers.
- **Fix:** Lower the SQL guardrail to `30s`. (Patch provided).

### [P3] Privileged Payment Operations (Audit Warning)
- **Component:** Edge Function (`zaincash-return`)
- **Evidence:** `supabase/functions/zaincash-return/index.ts` uses `createServiceClient()`.
- **Analysis:** The function correctly verifies the JWT signature (`verifyJwtHS256`) from the provider before using the service client.
- **Verdict:** **False Positive** (Safe). Added to "Authorized Exceptions" list.

### [Info] Schema file size
- **Component:** Database
- **Observation:** `schema.sql` is 35k lines.
- **Recommendation:** Future refactors should split this into logical migrations, but current state is functional.

---

## 3. Inventory Summary

### Critical Tables & RLS Status
| Table | RLS Enabled | Policies Verified | Notes |
| :--- | :---: | :---: | :--- |
| `ride_requests` | ✅ | ✅ | Isolated to Rider/Driver/Admin |
| `ride_intents` | ✅ | ✅ | Admin or Self-Insert only |
| `ride_incidents`| ✅ | ✅ | Enforces participant check |
| `profiles` | - | - | (Auth link verified) |
| `wallet_entries`| ✅ | ✅ | Immutable ledger |

### Edge Functions (Sample)
| Function | Route | Auth | Secrets |
| :--- | :--- | :--- | :--- |
| `match-ride` | `/match-ride` | User | `None` (Delegate to RPC) |
| `driver-accept`| `/driver-accept`| User | `None` (Delegate to RPC) |
| `ride-intent` | `/ride-intent` | User | `None` (Anon client) |
| `zaincash-return`| `/zaincash-return`| Public | `APP_BASE_URL`, `ZAINCASH_SECRET` |

---

## 4. Verification Plan

### Fix: `dispatch_match_ride` Logic
1. **Apply Patch:** Run `supabase/migrations/20260130120000_fix_dispatch_match_logic.sql`.
2. **Test:**
   - Call `rpc('dispatch_match_ride', { p_stale_after_seconds: 45 })`.
   - Before fix: Drivers updated 60s ago would be included (120s window).
   - After fix: Drivers updated 60s ago should be EXCLUDED (45s window).

### Security: Payment Webhooks
1. **Mock Request:** Send a request to `/zaincash-return` without a token.
   - Expect: `400 Missing token`.
2. **Mock Request:** Send a request with an invalid JWT signature.
   - Expect: `400 Invalid token`.
