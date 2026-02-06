# Edge Function Auth Contract

This repo uses an explicit **auth contract** to prevent accidental exposure of Supabase Edge Functions.

## Why this exists

Supabase Edge Functions can be configured with `verify_jwt = false` in `supabase/config.toml`. This is required for:

- Payment provider webhooks/callbacks
- Public read-only endpoints (e.g., share views)
- Scheduled jobs (cron) protected by a shared secret

When `verify_jwt = false`, **the function must enforce its own guard** (JWT verification, admin check, webhook signature verification, cron secret, or a token-based public access mechanism). Keeping this explicit prevents drift and reduces the chance of introducing unauthenticated privileged endpoints.

Supabase recommends configuring functions intentionally via `config.toml` and making security behavior explicit per endpoint.

## Files

- `supabase/config.toml` — function config (`verify_jwt` flags)
- `config/security/edge-auth-contract.json` — the required auth mechanism per `verify_jwt=false` function
- `scripts/audit-edge-functions.mjs` — static audit enforced by CI/local `pnpm security:audit`

## Auth types

The auth contract supports these values (see the audit script for exact checks):

- `user_jwt` — must verify the user (e.g., `requireUser()` / `requireUserStrict()`)
- `cron_secret` — must enforce `CRON_SECRET` (e.g., `requireCronSecret()`)
- `webhook_signature` — must verify integrity/authenticity of provider callbacks (signature/JWT/HMAC)
- `token_public` — public access gated by a strong unguessable token (and ideally hashed storage)
- `public_readonly` — public read-only content only
- `return_handler` — provider return/redirect handlers (should not do privileged operations)
- `optional_jwt` — can run without JWT but uses auth where present (use sparingly)

## Running the audit

```bash
pnpm security:audit
```

The audit fails if:

- A `verify_jwt=false` function is missing from the contract
- The function does not contain a recognizable guard for its declared auth type
