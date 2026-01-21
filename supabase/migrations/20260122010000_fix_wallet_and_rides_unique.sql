-- Fixes:
-- 1) Ensure rides(request_id) has a unique constraint (required for ON CONFLICT (request_id))
-- 2) Ensure wallet_get_my_account() is VOLATILE (it performs INSERT when the wallet account doesn't exist)

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'rides_request_id_key'
      and conrelid = 'public.rides'::regclass
  ) then
    alter table public.rides
      add constraint rides_request_id_key unique (request_id);
  end if;
end $$;

create or replace function public.wallet_get_my_account()
returns public.wallet_accounts
language plpgsql
security definer
volatile
set search_path to 'pg_catalog, extensions'
as $function$
declare
  v_user uuid;
  r public.wallet_accounts;
begin
  v_user := auth.uid();
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  select * into r
  from public.wallet_accounts
  where user_id = v_user;

  if not found then
    insert into public.wallet_accounts (user_id, balance_iqd)
    values (v_user, 0)
    returning * into r;
  end if;

  return r;
end;
$function$;
