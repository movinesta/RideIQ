# RLS performance notes

Supabase/Postgres can re-evaluate certain helper functions (e.g., `auth.uid()`) per-row inside RLS policies.
On large tables, this can cause severe performance regressions.

Prefer wrapping auth helpers in a scalar subquery so Postgres evaluates them once per statement:

```sql
using ((select auth.uid()) = user_id)
```

## Audit in production (service_role)

Run:

```sql
select *
from public.admin_security_audit_policies_v1
where should_wrap_auth_uid_with_select;
```

Then update the listed policies to use `(select auth.uid())`.

