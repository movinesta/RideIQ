# Release checklist (RideIQ)

This is a practical checklist to run before you publish **web + functions + database**.

## 1) Database & security

- [ ] **RLS enabled** on every table reachable from the client.
- [ ] Every RLS policy explicitly targets roles (`TO authenticated`, `TO anon`, etc.).
- [ ] Columns used inside RLS filters are **indexed** (e.g., `user_id`, `rider_id`, `driver_id`).
- [ ] Run local checks:
  - [ ] `supabase db lint --level error`
  - [ ] `supabase test db`
- [ ] Run Supabase advisors (Dashboard → Database → Advisors) and resolve **SECURITY** and **PERFORMANCE** warnings.

## 2) Realtime

- [ ] Required tables are added to Realtime publication(s).
- [ ] Each table in Realtime has **correct RLS** so clients only receive rows they are allowed to see.

## 3) Edge Functions secrets

Set secrets in Supabase Dashboard → Project Settings → Functions → Secrets:

- [ ] `SUPABASE_URL`
- [ ] `SUPABASE_ANON_KEY`
- [ ] `SUPABASE_SERVICE_ROLE_KEY` (server-only)
- [ ] `CRON_SECRET` (protect scheduled functions)
- [ ] `PIN_SECRET` (required for Pickup PIN / RideCheck)
- [ ] Trusted contacts delivery:
  - [ ] `CONTACT_PROVIDER` = `webhook` | `twilio_sms` | `whatsapp_cloud`
  - [ ] If `CONTACT_PROVIDER=webhook`: `CONTACT_WEBHOOK_URL` (+ optional `CONTACT_WEBHOOK_AUTH`)
  - [ ] If `CONTACT_PROVIDER=twilio_sms`: `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, and (`TWILIO_FROM` or `TWILIO_MESSAGING_SERVICE_SID`)
  - [ ] If `CONTACT_PROVIDER=whatsapp_cloud`: `WHATSAPP_TOKEN`, `WHATSAPP_PHONE_NUMBER_ID`, optional `WHATSAPP_TEMPLATE_NAME`, `WHATSAPP_TEMPLATE_LANG`


Payment provider secrets (as applicable):

- [ ] `PAYMENTS_PUBLIC_CONFIG_JSON` (providers + presets)
- [ ] `ZAINCASH_V2_BASE_URL`, `ZAINCASH_V2_CLIENT_ID`, `ZAINCASH_V2_CLIENT_SECRET`, `ZAINCASH_V2_API_KEY`, `ZAINCASH_V2_SERVICE_TYPE` (and optionally `ZAINCASH_V2_SCOPE`, `ZAINCASH_V2_LANGUAGE`)
- [ ] AsiaPay / QiCard secrets

## 4) Auth URLs

- [ ] Dashboard → Authentication → URL Configuration:
  - [ ] **Site URL** = your production URL
  - [ ] **Additional Redirect URLs** include:
    - `https://<user>.github.io/<repo>/*` (if GitHub Pages)
    - `http://localhost:5173/*` (for dev)

## 5) Web app build

- [ ] `pnpm check` passes locally.
- [ ] GitHub Actions **web-tests** workflow passes.
- [ ] GitHub Pages workflow has the correct `VITE_BASE` (project-site base path).

## 6) Operations

- [ ] Configure database backups and retention.
- [ ] Set up error monitoring (Sentry or equivalent) for web + edge.
- [ ] Rate limit the most sensitive endpoints (already present in `supabase/functions/_shared/rateLimit.ts`).


## WhatsApp (Session 22)
- [ ] If you need to send messages outside the 24h customer service window, create and approve templates in Meta and set `WHATSAPP_BOOKING_TEMPLATE_NAME` + `WHATSAPP_TEMPLATE_LANG`.
- [ ] Confirm webhook signature verification (`WHATSAPP_APP_SECRET`) is set in production.
