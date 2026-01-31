# Security notes (RideIQ)

This project follows a **defense-in-depth** approach:

1) **RLS on Postgres** is the primary guardrail.
2) **Edge Functions** use the Service Role key where required and enforce additional checks.
3) The **web client** uses the public `anon` key and should never contain privileged secrets.

## Key handling

- Never expose `SUPABASE_SERVICE_ROLE_KEY` in the web app.
- Rotate secrets if they were ever logged or committed.
- Prefer Dashboard-managed secrets for production.

## RLS best practices

- Always use `TO authenticated` / `TO anon` rather than implicit default roles.
- Index columns used inside policies (e.g., `rider_id`, `driver_id`).
- Avoid calling `auth.uid()` / `auth.role()` directly per-row in large tables; wrap in a subquery:

```sql
using ((select auth.uid()) = user_id)
```

## Database hardening

RideIQ relies on **minimal database grants**:

- No client role can update `profiles.is_admin`.
- Untrusted roles (`anon`, `authenticated`) cannot `CREATE` objects in the `public` schema.
- Function `EXECUTE` privileges are **deny-by-default** and then re-granted to a small allowlist of RPCs used by the app.

See: `supabase/migrations/202601270001_p0_security_hardening.sql`.

### RPC allowlist source of truth

The allowlist of client-callable RPCs lives in:

- `config/security/rpc-allowlist.json`

The DB hardening migration contains **generated** allowlist blocks. Do not edit them by hand:

```bash
node scripts/generate-security-hardening.mjs
```

### Admin security audit views

After migrations, these views exist for quick checks (service-role only):

- `public.admin_security_audit_schema_v1`
- `public.admin_security_audit_functions_v1`

Created by: `supabase/migrations/202601270002_admin_security_audit.sql`.

## Regression tests (pgTAP)

CI runs pgTAP database tests using `supabase test db`.

Security-sensitive regression checks live in `supabase/tests/005_security_hardening.test.sql` and will fail CI if:

- New broad EXECUTE grants are accidentally added
- `public` schema `CREATE` privileges are reintroduced
- A self-escalation path to admin privileges reappears

## Edge Functions (verify_jwt = false) audit

Supabase Edge Functions normally require a valid JWT in the `Authorization` header.
If `verify_jwt = false` is set (commonly for **webhooks**, **public share links**, or **cron** endpoints), the function **must** implement its own authorization/integrity checks.

RideIQ enforces this with a static CI guardrail:

- `scripts/audit-edge-functions.mjs` scans `supabase/config.toml` for functions configured with `verify_jwt = false`.
- It then checks each function's `index.ts` contains a recognizable guard (e.g., webhook HMAC/signature, CRON secret, token validation, or explicit user auth).

This audit runs in `.github/workflows/functions-tests.yml` before Deno unit tests.

## RPC allowlist audit

Because the DB hardening migration locks down `EXECUTE` privileges on RPCs, any new `.rpc('...')` call added to the web app must be explicitly allowlisted.

RideIQ enforces this with a static CI guardrail:

- `scripts/audit-rpc-allowlist.mjs` scans the repo for `.rpc('name')` usage.
- `scripts/audit-rpc-allowlist.mjs` scans the repo for `.rpc('name')` usage.
- It then checks those names exist in `config/security/rpc-allowlist.json`.

The `pnpm check` workflow also enforces that `202601270001_p0_security_hardening.sql` is in sync with the JSON allowlist.

This audit runs in `.github/workflows/web-tests.yml`.

## Realtime

- Realtime respects RLS. If a client is seeing too much data, it usually means the table is missing RLS or has permissive policies.

## Pickup PIN (RideCheck)

- Pickup PINs are HMAC-hashed server-side in Edge Functions.
- `PIN_SECRET` is required in Supabase Function Secrets.

## SECURITY DEFINER search_path

SECURITY DEFINER functions must **pin `search_path`** so untrusted users cannot shadow referenced objects by creating lookalike functions/operators in a writable schema.

We enforce this in:

- `supabase/migrations/202601270003_fix_security_definer_search_path.sql`
- `supabase/tests/005_security_hardening.test.sql` (regression test)



## RPC allowlist single source of truth

The database hardening migration re-grants EXECUTE only to RPCs explicitly allowlisted in:

- `config/security/rpc-allowlist.json`

Keep everything in sync by running:

```bash
node scripts/generate-security-hardening.mjs
```

CI runs `node scripts/generate-security-hardening.mjs --check` and fails if the migration or SQL tests drift.
