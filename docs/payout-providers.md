# Provider Payouts (Withdrawals)

This project supports driver withdrawals paid out via:

- **QiCard**
- **AsiaPay**
- **ZainCash**

## High-level flow

1. Driver creates a withdraw request (status `pending`).
2. Admin approves it (status `approved`) — funds remain on hold.
3. A **payout job** is created in `public.payout_provider_jobs` (status `queued`).
4. A sender triggers the payout:
   - Admin "Send" button (`payout-job-send`) OR
   - Cron runner (`payout-job-runner`, protected with `CRON_SECRET`)
5. Provider callback/webhook finalizes the payout:
   - `qicard-withdraw-webhook`
   - `asiapay-withdraw-webhook`
   - `zaincash-withdraw-webhook`

Finalization happens via service-role-only SQL helpers:

- `public.system_withdraw_mark_paid(...)`
- `public.system_withdraw_mark_failed(...)`

## Send modes

By default, sending is in **mock** mode:

- `PAYOUT_SEND_MODE=mock`

To enable real provider calls:

- `PAYOUT_SEND_MODE=real`

> Best practice: Keep provider payout endpoints and secrets in **Edge Function secrets**.

## Env vars (Edge Functions)

### Common
- `PAYOUT_SEND_MODE` = `mock` | `real`
- `PAYOUT_RETRY_BASE_SECONDS` (default `30`)
- `PAYOUT_RETRY_MAX_SECONDS` (default `3600`)
- `PAYOUT_FINALIZE_ON_SEND` (default `false`) — safer to confirm via webhooks.

### Cron runner
- `CRON_SECRET` — required header `x-cron-secret` for `payout-job-runner`.

### QiCard
- `QICARD_PAYOUT_ENDPOINT`
- `QICARD_PAYOUT_API_KEY`

### AsiaPay
- `ASIAPAY_PAYOUT_ENDPOINT`
- `ASIAPAY_PAYOUT_SECURE_HASH_SECRET`

### ZainCash (Disbursement)
- `ZAINCASH_DISBURSEMENT_ENDPOINT`
- `ZAINCASH_DISBURSEMENT_API_KEY`

## Scheduling the runner

Create a Supabase scheduled function call to:

`/functions/v1/payout-job-runner?limit=10`

…and include header:

`x-cron-secret: <CRON_SECRET>`
