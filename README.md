# RideIQ

A production-minded ride-sharing starter (rider + driver + admin) built on:

- **Frontend:** Vite + React + TypeScript
- **Backend:** Supabase (Postgres + RLS + Edge Functions)
- **Geo:** PostGIS (`geography(Point,4326)` + GiST)
- **Realtime:** Supabase Realtime (Postgres changes with RLS)
- **Wallet:** Top-ups + holds + ledger + withdrawals (QiCard / AsiaPay / ZainCash)

## Local quick start

## Database security hardening (REQUIRED)

This repo applies **least-privilege** database access:

- `profiles.is_admin` is not writable by end users (admin membership is stored in `admin_users`).
- Wallet balances are not writable from the client (mutations happen through server-side functions / Edge Functions).

### Apply on a hosted Supabase project (recommended)

Run these migrations in order via Supabase Dashboard → **SQL Editor**:

- Fresh project (recommended):
  1) `supabase/migrations/20260127000100_init_public.sql`
  2) `supabase/migrations/20260127000200_p0_security.sql`

- Existing project (already has the schema): run only
  - `supabase/migrations/20260127000200_p0_security.sql`

Notes:
- Admin access is controlled via `public.admin_users` + the RPC `public.is_admin()`.
- `profiles.is_admin` exists for backwards compatibility but is **not** used for authorization and is blocked from client updates.

### Apply locally (Supabase CLI) (Supabase CLI)

```bash
supabase start
supabase db reset --no-seed
supabase test db
```

### Verify in production (service_role)

```sql
select * from public.admin_security_audit_schema_v1;
select *
from public.admin_security_audit_functions_v1
where public_execute or anon_execute or authenticated_execute;

select *
from public.admin_security_audit_policies_v1
where should_wrap_auth_uid_with_select;
```

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

