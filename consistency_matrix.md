
# End-to-End Consistency Matrix

**Project:** RideIQ
**Date:** 2026-01-30
**Audit Phase:** 2 (Completed)

This matrix maps the data flow from Frontend Client Actions through Edge Functions to the Database (RPC/Tables). It confirms that for every client action, there is a corresponding backend handler and security boundary.

## 1. Edge Functions (API Layer)

| Frontend Context | API Endpoint (Edge Function) | Database Dependency (RPC/Table) | Auth Level |
| :--- | :--- | :--- | :--- |
| **Wallet** | `topup-check` | `(ZainCash Provider API)` | User |
| **Wallet** | `payments-config` | `public.payment_configs` | User |
| **Wallet** | `topup-create` | `wallet_create_topup_intent` (RPC) | User |
| **Safety** | `trusted-contacts-test` | `trusted_contacts` (Table) | User |
| **Driver** | `ride-verify-pin` | `ride_verify_pin` (RPC) | Driver |
| **Driver** | `ride-transition` | `transition_driver` (RPC) | Driver |
| **Admin** | `payout-job-create` | `admin_payout_create` (RPC) | Admin |
| **Admin** | `payout-job-send` | `admin_payout_send` (RPC) | Admin |
| **Maps** | `maps-config` | `(Env Vars)` | Public |
| **RideCheck** | `ridecheck-respond` | `ridecheck_responses` (Table) | User |
| **Safety** | `safety-sos` | `sos_events` (Table) | User |
| **Payment Config** | `payments-config` | `payment_providers` (Table) | User |

## 2. Direct Database RPCs (Client Layer)

| Frontend Context | RPC Name | Purpose | Security Model |
| :--- | :--- | :--- | :--- |
| **Wallet** | `wallet_get_my_account` | Get balance/hold info | `security definer` (View Own) |
| **Wallet** | `redeem_gift_code` | Apply promo code | `security definer` |
| **Wallet** | `wallet_request_withdraw` | Driver cashout request | `security definer` |
| **Rider/Schedule** | `quote_breakdown_iqd` | Fare estimation | `stable` (Public/Auth) |
| **Rider** | `resolve_service_area` | Geospatial lookup | `stable` (Public/Auth) |
| **History** | `submit_ride_rating` | Rate driver/rider | `security definer` |
| **History** | `create_ride_incident` | Report safety issue | `security definer` |
| **Admin** | `admin_withdraw_approve` | Approve payout | `security definer` (Admin Only) |
| **Admin** | `is_admin` | Check admin status | `stable` (Auth match) |
| **Driver** | `nearby_available_drivers_v1` | Driver heatmap | `stable` |
| **Profile** | `get_my_app_context` | User metadata | `stable` |
| **Merchant** | `merchant_order_create` | Delivery request | `security definer` |

## 3. Data Integrity & Type Safety

| Layer | Mechanism | Status |
| :--- | :--- | :--- |
| **Database** | Postgres Types (`UUID`, `Text`, `Enum`) | ✅ Defined in `schema.sql` |
| **Backend** | Supabase Generated Types | ✅ `scripts/generate-db-types.mjs` |
| **Frontend** | TypeScript Interfaces | ✅ Imported from `database.types.ts` |
| **Validation** | RLS Policies | ✅ Verified on critical tables |

## 4. Anomalies Resolved

- **Match Logic:** `dispatch_match_ride` guardrail issue identified (See Findings Report).
- **Type Sync:** No manual type duplications found; strictly relying on auto-generation.
