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

## Realtime

- Realtime respects RLS. If a client is seeing too much data, it usually means the table is missing RLS or has permissive policies.

## Pickup PIN (RideCheck)

- Pickup PINs are HMAC-hashed server-side in Edge Functions.
- `PIN_SECRET` is required in Supabase Function Secrets.