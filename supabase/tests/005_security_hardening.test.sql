begin;

create extension if not exists pgtap with schema extensions;

select plan(10);

-- -------------------------------------------------------------------
-- Security regression tests (P0 hardening)
--
-- These tests ensure:
-- 1) Untrusted roles cannot CREATE objects in the public schema
-- 2) Users cannot self-escalate to admin via profiles.is_admin
-- 3) Function EXECUTE privileges for anon/authenticated remain allowlisted
-- 4) A representative privileged SECURITY DEFINER function is not callable
-- -------------------------------------------------------------------

-- 1) Schema CREATE privileges must be revoked
select ok(
  not has_schema_privilege('anon', 'public', 'CREATE'),
  'anon cannot CREATE in schema public'
);

select ok(
  not has_schema_privilege('authenticated', 'public', 'CREATE'),
  'authenticated cannot CREATE in schema public'
);

-- 2) authenticated must not be able to UPDATE/INSERT profiles.is_admin
select ok(
  not exists (
    select 1
    from information_schema.column_privileges
    where table_schema = 'public'
      and table_name = 'profiles'
      and column_name = 'is_admin'
      and grantee = 'authenticated'
      and privilege_type in ('UPDATE', 'INSERT')
  ),
  'authenticated cannot UPDATE/INSERT profiles.is_admin'
);

-- 3) Function execution must be allowlisted
-- anon
select ok(
  (
    select count(*)
    from information_schema.routine_privileges
    where routine_schema = 'public'
      and grantee = 'anon'
      and privilege_type = 'EXECUTE'
      and routine_name not in (
        -- BEGIN RPC_ALLOWLIST_ANON_TEST
        'quote_breakdown_iqd',
        'resolve_service_area'
-- END RPC_ALLOWLIST_ANON_TEST
)
  ) = 0,
  'anon EXECUTE privileges are allowlisted'
);

-- authenticated
select ok(
  (
    select count(*)
    from information_schema.routine_privileges
    where routine_schema = 'public'
      and grantee = 'authenticated'
      and privilege_type = 'EXECUTE'
      and routine_name not in (
        -- BEGIN RPC_ALLOWLIST_AUTHENTICATED_TEST
        'achievement_claim',
        'admin_create_service_area_bbox_v2',
        'admin_record_ride_refund',
        'admin_ridecheck_escalate',
        'admin_ridecheck_resolve',
        'admin_set_merchant_status',
        'admin_update_pricing_config_caps',
        'admin_update_ride_incident',
        'admin_wallet_integrity_snapshot',
        'admin_withdraw_approve',
        'admin_withdraw_mark_paid',
        'admin_withdraw_reject',
        'create_ride_incident',
        'driver_claim_order_delivery',
        'get_my_app_context',
        'is_admin',
        'merchant_chat_get_or_create_thread',
        'merchant_chat_list_messages',
        'merchant_chat_mark_read',
        'merchant_order_create',
        'merchant_order_get_or_create_chat_thread',
        'merchant_order_request_delivery',
        'merchant_order_set_status',
        'nearby_available_drivers_v1',
        'redeem_gift_code',
        'referral_apply_code',
        'referral_claim',
        'referral_status',
        'ride_chat_get_or_create_thread',
        'set_my_active_role',
        'submit_ride_rating',
        'user_notifications_mark_all_read',
        'user_notifications_mark_read',
        'wallet_cancel_withdraw',
        'wallet_get_my_account',
        'wallet_request_withdraw',
        'whatsapp_booking_token_consume_v1',
        'whatsapp_booking_token_create_v1'
-- END RPC_ALLOWLIST_AUTHENTICATED_TEST
)
  ) = 0,
  'authenticated EXECUTE privileges are allowlisted'
);

-- 3b) PUBLIC must not have EXECUTE on public routines
select ok(
  (
    select count(*)
    from information_schema.routine_privileges
    where routine_schema = 'public'
      and grantee = 'PUBLIC'
      and privilege_type = 'EXECUTE'
  ) = 0,
  'PUBLIC has no EXECUTE privileges on public routines'
);

-- 3c) All SECURITY DEFINER functions must set search_path
select ok(
  (
    select count(*)
    from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.prosecdef
      and (
        p.proconfig is null
        or not exists (
          select 1
          from unnest(p.proconfig) s(x)
          where x like 'search_path=%'
        )
      )
  ) = 0,
  'All SECURITY DEFINER functions set search_path'
);

-- 4) Functional smoke checks for anon allowlist
-- Ensure pricing config exists so quote_breakdown_iqd can compute.
insert into public.pricing_configs (id, active)
values ('aaaaaaaa-0000-0000-0000-000000000001', true)
on conflict (id) do nothing;

-- Ensure a service area exists so resolve_service_area returns a row.
insert into public.service_areas (
  id, name, governorate, is_active, priority, pricing_config_id, geom
) values (
  'bbbbbbbb-0000-0000-0000-000000000001',
  'Baghdad Test Area',
  'Baghdad',
  true,
  100,
  'aaaaaaaa-0000-0000-0000-000000000001',
  extensions.st_geomfromtext(
    'MULTIPOLYGON(((44.2 33.2,44.5 33.2,44.5 33.4,44.2 33.4,44.2 33.2)))',
    4326
  )
) on conflict (id) do nothing;

set local role anon;

select ok(
  (select public.quote_breakdown_iqd(33.3152, 44.3661, 33.3000, 44.4000, 'standard') is not null),
  'anon can EXECUTE quote_breakdown_iqd'
);

select ok(
  (select count(*) from public.resolve_service_area(33.3152, 44.3661)) = 1,
  'anon can EXECUTE resolve_service_area'
);

-- 5) Representative privileged function must NOT be callable by anon
select throws_ok(
  $$ select public.transition_ride_v2(
        '00000000-0000-0000-0000-000000000000'::uuid,
        'accepted'::public.ride_status,
        '00000000-0000-0000-0000-000000000000'::uuid,
        'rider'::public.ride_actor_type,
        0
      ) $$,
  '42501',
  'anon cannot EXECUTE transition_ride_v2 (insufficient_privilege)'
);

select * from finish();
rollback;
