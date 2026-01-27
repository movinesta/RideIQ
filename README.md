# RideIQ

A production-minded ride-sharing starter (rider + driver + admin) built on:

- **Frontend:** Vite + React + TypeScript
- **Backend:** Supabase (Postgres + RLS + Edge Functions)
- **Geo:** PostGIS (`geography(Point,4326)` + GiST)
- **Realtime:** Supabase Realtime (Postgres changes with RLS)
- **Wallet:** Top-ups + holds + ledger + withdrawals (QiCard / AsiaPay / ZainCash)

## Local quick start

### 1) Configure web env
Create `apps/web/.env.local`:

```bash
VITE_SUPABASE_URL=...
VITE_SUPABASE_ANON_KEY=...

# Optional: fallback booking channel (WhatsApp click-to-chat)
VITE_WHATSAPP_BOOKING_NUMBER=9647XXXXXXXXX
```

### 1b) Configure Supabase Edge Function secrets (WhatsApp Cloud API)
For WhatsApp booking via webhooks, configure these secrets in Supabase (Project Settings → Edge Functions → Secrets):

```bash
# Meta webhook verification (GET hub.verify_token)
META_VERIFY_TOKEN=...

# WhatsApp Cloud API sending
WHATSAPP_TOKEN=...                 # permanent access token
WHATSAPP_PHONE_NUMBER_ID=...       # phone number ID from Meta app
WHATSAPP_GRAPH_VERSION=v21.0       # optional

# Webhook signature verification (recommended)
WHATSAPP_APP_SECRET=...            # Meta App Secret (used to verify X-Hub-Signature-256)


# Template messaging (Session 22)
# WhatsApp allows free-form messages only within the 24-hour customer service window.
# Outside that window, you must use approved templates.
WHATSAPP_TEMPLATE_LANG=en_US        # default template language
WHATSAPP_BOOKING_TEMPLATE_NAME=...  # template used by admin "Send booking link" when CSW is closed

# Public web base URL used when sending booking links to WhatsApp users
APP_BASE_URL=https://your-domain.example
```

Then deploy these Edge Functions:
- `whatsapp-webhook` (public webhook endpoint)
- `whatsapp-booking-view` (public token view)
- `whatsapp-booking-consume` (authenticated token consume)
- `whatsapp-send` (admin outbound messages)



### 2) Initialize the database
Recommended approach is **Supabase CLI migrations** (works well for CI and repeatable environments):

- **CLI migrations (recommended):** Run the files in `supabase/migrations/` in order.  
  `20260124_000001_init.sql` is the full base schema; follow with incremental migrations like `20260124_000002_support_and_sos.sql`.

Quick-start if you prefer **SQL Editor**:

1) Run `supabase/migrations/20260124_000001_init.sql`
2) Then run `supabase/migrations/20260124_000002_support_and_sos.sql`

3) Then run `supabase/migrations/20260124_000003_rls_storage_cleanup.sql`
4) Then run `supabase/migrations/20260124_000004_scheduled_rides.sql`
5) Then run `supabase/migrations/20260124_000005_scheduled_rides_cron_fix.sql`
6) Then run `supabase/migrations/20260125_000006_service_areas.sql`
7) Then run `supabase/migrations/20260125_000007_service_area_admin_rpcs.sql`
8) Then run `supabase/migrations/20260125_000008_ride_intents_and_pricing_override.sql`
9) Then run `supabase/migrations/20260125_000009_women_family_prefs_and_kyc_gating.sql`
10) Then run `supabase/migrations/20260125_000010_realtime_publications.sql`

11) Then run `supabase/migrations/20260125_000011_user_notifications_unread_index.sql`
12) Then run `supabase/migrations/20260125_000012_pricing_fairness_surge_caps.sql`
13) Then run `supabase/migrations/20260125_000013_storage_rls_initplan_fix.sql`
14) Then run `supabase/migrations/20260125_000014_realtime_publications_full.sql`
15) Then run `supabase/migrations/20260125_000015_storage_buckets_seed.sql`

`supabase/schema.sql` is kept for convenience, but **migrations are the source of truth** going forward.

### 3) Edge Function env (Supabase Dashboard → Project Settings → Functions → Secrets)
Set:

- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`

Required for Pickup PIN (RideCheck):

- `PIN_SECRET` (long random string; used to HMAC-hash PINs server-side)

Recommended:

- `APP_BASE_URL` (e.g. `http://localhost:5173` in dev, or your GitHub Pages URL in prod)
- `APP_ORIGIN` (optional) if your app origin differs from `APP_BASE_URL` (used for Edge Function CORS)
- `CRON_SECRET` (protects scheduled endpoints)

Trusted Contacts notifications (optional, provider-agnostic):

- `CONTACT_WEBHOOK_URL` (your SMS/WhatsApp dispatcher endpoint)
- `CONTACT_WEBHOOK_AUTH` (optional: e.g. `Bearer ...`)

Choose delivery provider (optional):
- `CONTACT_PROVIDER` = `webhook` (default) | `twilio_sms` | `whatsapp_cloud`

If using Twilio SMS:
- `TWILIO_ACCOUNT_SID`
- `TWILIO_AUTH_TOKEN`
- `TWILIO_FROM` (E.164) **or** `TWILIO_MESSAGING_SERVICE_SID`

If using WhatsApp Cloud API:
- `WHATSAPP_TOKEN`
- `WHATSAPP_PHONE_NUMBER_ID`
- `WHATSAPP_TEMPLATE_NAME` (default: `rideiq_safety_alert`)
- `WHATSAPP_TEMPLATE_LANG` (default: `en_US`)

Notes:
- WhatsApp Cloud generally requires approved templates for outbound messages outside the 24h window.


Payment provider config (top-ups):

ZainCash v2 (Edge Function secrets; no client-side keys):

- `ZAINCASH_V2_BASE_URL` (e.g. UAT/Prod API base from ZainCash)
- `ZAINCASH_V2_CLIENT_ID`
- `ZAINCASH_V2_CLIENT_SECRET`
- `ZAINCASH_V2_API_KEY` (used to verify redirect/webhook JWTs)
- `ZAINCASH_V2_SCOPE` (default: `payment:read payment:write`)
- `ZAINCASH_V2_LANGUAGE` (default: `En`; allowed: `En`, `Ar`, `Ku`)
- `ZAINCASH_V2_SERVICE_TYPE` (serviceType provided by ZainCash)



Providers + presets are configured via a single Edge Function secret (no database seeding):

- `PAYMENTS_PUBLIC_CONFIG_JSON` — JSON string with enabled providers and their presets.
  - Example:
    ```json
    {
      "providers": [
        {
          "code": "zaincash",
          "name": "ZainCash",
          "kind": "zaincash",
          "enabled": true,
          "presets": [
            { "id": "z10", "label": "10,000 IQD", "amount_iqd": 10000, "bonus_iqd": 0, "active": true }
          ]
        },
        {
          "code": "asiapay",
          "name": "AsiaPay",
          "kind": "asiapay",
          "enabled": true,
          "presets": [
            { "id": "a10", "label": "10,000 IQD", "amount_iqd": 10000, "bonus_iqd": 0, "active": true }
          ]
        },
        {
          "code": "qicard",
          "name": "QiCard",
          "kind": "qicard",
          "enabled": true,
          "presets": [
            { "id": "q10", "label": "10,000 IQD", "amount_iqd": 10000, "bonus_iqd": 0, "active": true }
          ]
        }
      ]
    }
    ```

AsiaPay (PayDollar) (server-side only):

- `ASIAPAY_MERCHANT_ID`
- `ASIAPAY_SECURE_HASH_SECRET`
- `ASIAPAY_SECURE_HASH_FUNCTION` (`sha1` default, or `sha256`)
- `ASIAPAY_CURRENCY_CODE` (default: `IQD`)
- `ASIAPAY_LANG` (default: `E` / English; depends on AsiaPay setup)
- `ASIAPAY_PAYMENT_URL` (gateway URL)
- Webhooks:
  - `asiapay-notify` (server-to-server datafeed)
  - `asiapay-return` (browser return)

QiCard (server-side only):

- `QICARD_BASE_URL` (e.g. `https://sandbox.qicard.iq/api/v1`)
- `QICARD_CREATE_PATH` (default: `/payment`)
- `QICARD_STATUS_PATH` (default: `/payment/{id}/status`)
- Auth (pick one):
  - `QICARD_BEARER_TOKEN` **or**
  - `QICARD_BASIC_AUTH_USER` + `QICARD_BASIC_AUTH_PASS`
- Optional:
  - `QICARD_TERMINAL_ID`
  - `QICARD_CURRENCY` (default: `IQD`)
  - `QICARD_WEBHOOK_SECRET` (for `qicard-notify` signature verification)
  - `ALLOW_INSECURE_WEBHOOKS` (dev only; `true` to bypass signature)

### 4) Run

```bash
pnpm install
pnpm dev
```

Optional: run full local checks (web + schema contract + optional DB lint/tests):

```bash
./scripts/check.sh
```

Open:
- Rider: `http://localhost:5173/rider`
- Driver: `http://localhost:5173/driver`
- Wallet: `http://localhost:5173/wallet`
- Admin Payments: `http://localhost:5173/admin/payments`
- Admin Ride Intents: `http://localhost:5173/admin/intents`
- Admin RideCheck: `http://localhost:5173/admin/ridecheck`

### Scheduled endpoints

Two Edge Functions are intended to run on a schedule (Supabase Dashboard → Edge Functions → Scheduled Triggers):

- `notifications-dispatch` (push/webhook notifications outbox)
- `trusted-contacts-dispatch` (trusted contacts outbox — WhatsApp/SMS)

Both require `CRON_SECRET` and expect either `x-cron-secret: <CRON_SECRET>` or `Authorization: Bearer <CRON_SECRET>`.

---

## Production deploy

### A) Deploy the web app to GitHub Pages
This repo includes `.github/workflows/deploy-pages.yml` (GitHub Actions → Pages) which builds `apps/web` and deploys `apps/web/dist`.

1) GitHub repo → **Settings → Pages** → set **Source** to **GitHub Actions**. (Vite needs a build step.)
2) Add GitHub repo secrets:
   - `VITE_SUPABASE_URL`
   - `VITE_SUPABASE_ANON_KEY`

The workflow automatically sets `VITE_BASE=/<repo>/` for GitHub Pages project sites, so routing + assets work under `https://<user>.github.io/<repo>/`.

### B) Deploy Supabase Edge Functions from GitHub Actions
This repo includes `.github/workflows/deploy-supabase-functions.yml` which deploys all functions under `supabase/functions/` on every push to `main`.

Add GitHub repo secrets:
- `SUPABASE_ACCESS_TOKEN` (create in Supabase Dashboard → Account Settings → Access Tokens)
- `SUPABASE_PROJECT_REF` (your project ref, e.g. `ehtimvlmpghstlzvfipx`)

### C) Supabase Auth URLs (required when using GitHub Pages)
Supabase Dashboard → **Authentication → URL Configuration**:

- **Site URL:** `https://<user>.github.io/<repo>/`
- **Additional Redirect URLs:**
  - `https://<user>.github.io/<repo>/*`
  - `http://localhost:5173/*`

---

## Edge Functions in this repo

Core ride flow:

- `match-ride`
- `driver-accept`
- `ride-transition`

Payments / wallet:

- `topup-create`
- `zaincash-return`
- `asiapay-return`
- `asiapay-notify`
- `qicard-notify`

Safety:

- `safety-sos` (creates SOS incident + trip share token; optionally enqueues trusted contact notifications)
- `trip-share-create`
- `trip-share-refresh`
- `ridecheck-respond`

Lead capture / call-center:

- `ride-intent-create` (creates WhatsApp/call-center intent)
- `admin-ride-intent-convert` (admin-only convert intent → ride request)

Scheduled/maintenance endpoints (protect with `CRON_SECRET` header):

- `topup-reconcile`
- `expire-rides`
- `notifications-dispatch`
- `trusted-contacts-dispatch`

