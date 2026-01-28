-- P9: Merchant chat read tracking + keyset pagination RPC + thread creation guard
-- Goals:
-- - minimal schema changes (columns only) to support unread indicators
-- - efficient message pagination via keyset cursor (created_at,id)
-- - prevent customer threads with non-approved merchants (unless owner/admin)

begin;

-- 1) Read tracking on threads (unread indicators)
alter table public.merchant_chat_threads
  add column if not exists customer_last_read_at timestamptz,
  add column if not exists merchant_last_read_at timestamptz;

-- 2) Index to support keyset pagination (created_at DESC, id DESC)
create index if not exists ix_mcm_thread_created_id_desc
on public.merchant_chat_messages(thread_id, created_at desc, id desc);

-- 3) Guard: customer may only create/get threads for approved merchants (owners/admins bypass)
create or replace function public.merchant_chat_get_or_create_thread(p_merchant_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_thread_id uuid;
  v_uid uuid;
  v_ok boolean;
begin
  v_uid := (select auth.uid());
  if v_uid is null then
    raise exception 'Not authenticated';
  end if;

  -- Merchant must be approved for customers. Owners/admins can still access.
  select exists(
    select 1
    from public.merchants m
    where m.id = p_merchant_id
      and (
        m.status = 'approved'
        or m.owner_profile_id = v_uid
        or (select is_admin())
      )
  ) into v_ok;

  if not v_ok then
    raise exception 'Merchant not available';
  end if;

  select id into v_thread_id
  from public.merchant_chat_threads
  where merchant_id = p_merchant_id
    and customer_id = v_uid;

  if v_thread_id is not null then
    return v_thread_id;
  end if;

  insert into public.merchant_chat_threads (merchant_id, customer_id)
  values (p_merchant_id, v_uid)
  returning id into v_thread_id;

  return v_thread_id;
end;
$$;

grant execute on function public.merchant_chat_get_or_create_thread(uuid) to authenticated;

-- 4) Mark thread as read (no direct UPDATE policy needed; server-side validation only)
create or replace function public.merchant_chat_mark_read(p_thread_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid;
  v_customer uuid;
  v_owner uuid;
begin
  v_uid := (select auth.uid());
  if v_uid is null then
    raise exception 'Not authenticated';
  end if;

  select t.customer_id, m.owner_profile_id
    into v_customer, v_owner
  from public.merchant_chat_threads t
  join public.merchants m on m.id = t.merchant_id
  where t.id = p_thread_id;

  if not found then
    raise exception 'Thread not found';
  end if;

  if v_uid = v_customer then
    update public.merchant_chat_threads
      set customer_last_read_at = now()
    where id = p_thread_id;
    return;
  end if;

  if v_uid = v_owner then
    update public.merchant_chat_threads
      set merchant_last_read_at = now()
    where id = p_thread_id;
    return;
  end if;

  if (select is_admin()) then
    -- Admin may mark both sides as read for operational tooling
    update public.merchant_chat_threads
      set customer_last_read_at = coalesce(customer_last_read_at, now()),
          merchant_last_read_at = coalesce(merchant_last_read_at, now())
    where id = p_thread_id;
    return;
  end if;

  raise exception 'Not permitted';
end;
$$;

grant execute on function public.merchant_chat_mark_read(uuid) to authenticated;

-- 5) Keyset pagination RPC (invoker: respects RLS on merchant_chat_messages)
create or replace function public.merchant_chat_list_messages(
  p_thread_id uuid,
  p_before_created_at timestamptz default null,
  p_before_id uuid default null,
  p_limit int default 50
)
returns table (
  id uuid,
  thread_id uuid,
  sender_id uuid,
  body text,
  message_type text,
  attachments jsonb,
  created_at timestamptz
)
language sql
stable
set search_path = public
as $$
  select
    m.id,
    m.thread_id,
    m.sender_id,
    m.body,
    m.message_type,
    m.attachments,
    m.created_at
  from public.merchant_chat_messages m
  where m.thread_id = p_thread_id
    and (
      p_before_created_at is null
      or (
        p_before_id is null
        and m.created_at < p_before_created_at
      )
      or (
        p_before_id is not null
        and (m.created_at, m.id) < (p_before_created_at, p_before_id)
      )
    )
  order by m.created_at desc, m.id desc
  limit least(greatest(p_limit, 1), 200);
$$;

grant execute on function public.merchant_chat_list_messages(uuid,timestamptz,uuid,int) to authenticated;



-- 6) Tighten write rules: only approved merchants can receive customer messages (owners/admins bypass)
do $$
begin
  -- Thread creation policy (customer): merchant must be approved (owners/admins bypass)
  if exists (select 1 from pg_policies where schemaname='public' and tablename='merchant_chat_threads' and policyname='mct_insert_customer') then
    execute 'drop policy mct_insert_customer on public.merchant_chat_threads';
  end if;

  execute $p$
    create policy mct_insert_customer
    on public.merchant_chat_threads
    for insert
    to authenticated
    with check (
      customer_id = (select auth.uid())
      and exists (
        select 1 from public.merchants m
        where m.id = merchant_id
          and (m.status = 'approved' or m.owner_profile_id = (select auth.uid()) or (select is_admin()))
      )
    )
  $p$;

  -- Message insert policy: merchant must be approved (owners/admins bypass) and sender must be a participant
  if exists (select 1 from pg_policies where schemaname='public' and tablename='merchant_chat_messages' and policyname='mcm_insert') then
    execute 'drop policy mcm_insert on public.merchant_chat_messages';
  end if;

  execute $p$
    create policy mcm_insert
    on public.merchant_chat_messages
    for insert
    to authenticated
    with check (
      sender_id = (select auth.uid())
      and exists (
        select 1
        from public.merchant_chat_threads t
        join public.merchants m on m.id = t.merchant_id
        where t.id = thread_id
          and (
            t.customer_id = (select auth.uid())
            or m.owner_profile_id = (select auth.uid())
            or (select is_admin())
          )
          and (
            m.status = 'approved'
            or m.owner_profile_id = (select auth.uid())
            or (select is_admin())
          )
      )
    )
  $p$;
end $$;


commit;
