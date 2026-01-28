-- P6: Merchant catalog + customer<->merchant chat (minimal schema additions)
-- Design goals:
-- - keep existing ride chat/support systems untouched
-- - minimal new tables, clean RLS, indexed policy columns
-- - money stored in IQD minor units (bigint)
-- - realtime enabled only for chat tables

begin;

-- 1) Allow 'merchant' in active_role for single-app role switch UX
alter table public.profiles
  drop constraint if exists profiles_active_role_check;

alter table public.profiles
  add constraint profiles_active_role_check
  check (active_role = any (array['rider'::text,'driver'::text,'merchant'::text]));

-- 2) Merchants (owner-only for now)
create table public.merchants (
  id uuid primary key default gen_random_uuid(),
  owner_profile_id uuid not null references public.profiles(id) on delete restrict,
  business_name text not null,
  business_type text not null,
  status text not null default 'pending' check (status in ('draft','pending','approved','suspended')),
  contact_phone text,
  address_text text,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index ix_merchants_owner_profile_id on public.merchants(owner_profile_id);
create index ix_merchants_status on public.merchants(status);

alter table public.merchants enable row level security;

-- Select: approved merchants are public; owners/admins can see their own even if not approved
create policy merchants_select
on public.merchants
for select
to anon, authenticated
using (
  status = 'approved'
  or owner_profile_id = (select auth.uid())
  or (select is_admin())
);

-- Insert: owner creates their own merchant (status forced to 'pending' by trigger)
create policy merchants_insert_owner
on public.merchants
for insert
to authenticated
with check (
  owner_profile_id = (select auth.uid())
);

-- Update: owner can update their merchant (status guarded by trigger)
create policy merchants_update_owner
on public.merchants
for update
to authenticated
using (owner_profile_id = (select auth.uid()) or (select is_admin()))
with check (owner_profile_id = (select auth.uid()) or (select is_admin()));

-- Delete: owner can delete only if not approved; admin can delete anytime
create policy merchants_delete_owner
on public.merchants
for delete
to authenticated
using (
  (select is_admin())
  or (owner_profile_id = (select auth.uid()) and status in ('draft','pending'))
);

-- Guard status changes: only admins can change status
create or replace function public.merchants_guard_status()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  -- On insert, enforce pending unless admin
  if (tg_op = 'INSERT') then
    if not (select is_admin()) then
      new.status := 'pending';
    end if;
    return new;
  end if;

  if (tg_op = 'UPDATE') then
    if new.status is distinct from old.status and not (select is_admin()) then
      raise exception 'Only admins can change merchant status';
    end if;
    return new;
  end if;

  return new;
end;
$$;

drop trigger if exists trg_merchants_guard_status on public.merchants;
create trigger trg_merchants_guard_status
before insert or update on public.merchants
for each row
execute function public.merchants_guard_status();

drop trigger if exists trg_touch_merchants_updated_at on public.merchants;
create trigger trg_touch_merchants_updated_at
before update on public.merchants
for each row
execute function public.touch_updated_at();

-- 3) Merchant products
create table public.merchant_products (
  id uuid primary key default gen_random_uuid(),
  merchant_id uuid not null references public.merchants(id) on delete cascade,
  name text not null,
  description text,
  category text,
  price_iqd bigint not null check (price_iqd >= 0),
  compare_at_price_iqd bigint check (compare_at_price_iqd is null or compare_at_price_iqd >= 0),
  is_active boolean not null default true,
  stock_qty integer,
  images jsonb not null default '[]'::jsonb,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index ix_merchant_products_merchant_active on public.merchant_products(merchant_id, is_active);
create index ix_merchant_products_merchant_created on public.merchant_products(merchant_id, created_at desc);

alter table public.merchant_products enable row level security;

-- Public can view active products of approved merchants. Owners/admins can view all their products.
create policy merchant_products_select
on public.merchant_products
for select
to anon, authenticated
using (
  (
    is_active = true
    and exists (
      select 1
      from public.merchants m
      where m.id = merchant_id
        and m.status = 'approved'
    )
  )
  or exists (
    select 1
    from public.merchants m
    where m.id = merchant_id
      and (
        m.owner_profile_id = (select auth.uid())
        or (select is_admin())
      )
  )
);

-- Owners/admins can insert/update/delete products for their merchant
create policy merchant_products_write
on public.merchant_products
for insert
to authenticated
with check (
  exists (
    select 1
    from public.merchants m
    where m.id = merchant_id
      and (m.owner_profile_id = (select auth.uid()) or (select is_admin()))
  )
);

create policy merchant_products_update
on public.merchant_products
for update
to authenticated
using (
  exists (
    select 1
    from public.merchants m
    where m.id = merchant_id
      and (m.owner_profile_id = (select auth.uid()) or (select is_admin()))
  )
)
with check (
  exists (
    select 1
    from public.merchants m
    where m.id = merchant_id
      and (m.owner_profile_id = (select auth.uid()) or (select is_admin()))
  )
);

create policy merchant_products_delete
on public.merchant_products
for delete
to authenticated
using (
  exists (
    select 1
    from public.merchants m
    where m.id = merchant_id
      and (m.owner_profile_id = (select auth.uid()) or (select is_admin()))
  )
);

drop trigger if exists trg_touch_merchant_products_updated_at on public.merchant_products;
create trigger trg_touch_merchant_products_updated_at
before update on public.merchant_products
for each row
execute function public.touch_updated_at();

-- 4) Promotions (optional but clean, avoids stuffing discount fields into products)
create table public.merchant_promotions (
  id uuid primary key default gen_random_uuid(),
  merchant_id uuid not null references public.merchants(id) on delete cascade,
  product_id uuid references public.merchant_products(id) on delete cascade,
  discount_type text not null check (discount_type in ('percent','fixed_iqd')),
  value numeric(10,2) not null check (value > 0),
  starts_at timestamptz,
  ends_at timestamptz,
  is_active boolean not null default true,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index ix_merchant_promotions_merchant_active on public.merchant_promotions(merchant_id, is_active);
create index ix_merchant_promotions_product_active on public.merchant_promotions(product_id, is_active);

alter table public.merchant_promotions enable row level security;

create policy merchant_promotions_select
on public.merchant_promotions
for select
to anon, authenticated
using (
  exists (
    select 1 from public.merchants m
    where m.id = merchant_id and m.status = 'approved'
  )
  or exists (
    select 1 from public.merchants m
    where m.id = merchant_id and (m.owner_profile_id = (select auth.uid()) or (select is_admin()))
  )
);

create policy merchant_promotions_insert
on public.merchant_promotions
for insert
to authenticated
with check (
  exists (
    select 1 from public.merchants m
    where m.id = merchant_id and (m.owner_profile_id = (select auth.uid()) or (select is_admin()))
  )
);

create policy merchant_promotions_update
on public.merchant_promotions
for update
to authenticated
using (
  exists (
    select 1 from public.merchants m
    where m.id = merchant_id and (m.owner_profile_id = (select auth.uid()) or (select is_admin()))
  )
)
with check (
  exists (
    select 1 from public.merchants m
    where m.id = merchant_id and (m.owner_profile_id = (select auth.uid()) or (select is_admin()))
  )
);

create policy merchant_promotions_delete
on public.merchant_promotions
for delete
to authenticated
using (
  exists (
    select 1 from public.merchants m
    where m.id = merchant_id and (m.owner_profile_id = (select auth.uid()) or (select is_admin()))
  )
);

-- 5) Customer <-> Merchant chat (separate from ride chat/support chat)
create table public.merchant_chat_threads (
  id uuid primary key default gen_random_uuid(),
  merchant_id uuid not null references public.merchants(id) on delete cascade,
  customer_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  last_message_at timestamptz,
  unique (merchant_id, customer_id)
);

create index ix_mct_merchant_last_message on public.merchant_chat_threads(merchant_id, last_message_at desc);
create index ix_mct_customer_last_message on public.merchant_chat_threads(customer_id, last_message_at desc);

alter table public.merchant_chat_threads enable row level security;

-- participants: customer, merchant owner, admin
create policy mct_select
on public.merchant_chat_threads
for select
to authenticated
using (
  customer_id = (select auth.uid())
  or exists (select 1 from public.merchants m where m.id = merchant_id and m.owner_profile_id = (select auth.uid()))
  or (select is_admin())
);

-- customer can create a thread for themselves (merchant must exist)
create policy mct_insert_customer
on public.merchant_chat_threads
for insert
to authenticated
with check (
  customer_id = (select auth.uid())
  and exists (select 1 from public.merchants m where m.id = merchant_id)
);

create policy mct_delete_participant
on public.merchant_chat_threads
for delete
to authenticated
using (
  customer_id = (select auth.uid())
  or exists (select 1 from public.merchants m where m.id = merchant_id and m.owner_profile_id = (select auth.uid()))
  or (select is_admin())
);

drop trigger if exists trg_touch_mct_updated_at on public.merchant_chat_threads;
create trigger trg_touch_mct_updated_at
before update on public.merchant_chat_threads
for each row
execute function public.touch_updated_at();

create table public.merchant_chat_messages (
  id uuid primary key default gen_random_uuid(),
  thread_id uuid not null references public.merchant_chat_threads(id) on delete cascade,
  sender_id uuid not null references public.profiles(id) on delete cascade,
  body text,
  message_type text not null default 'text',
  attachments jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

create index ix_mcm_thread_created on public.merchant_chat_messages(thread_id, created_at desc);
create index ix_mcm_sender_created on public.merchant_chat_messages(sender_id, created_at desc);

alter table public.merchant_chat_messages enable row level security;

create policy mcm_select
on public.merchant_chat_messages
for select
to authenticated
using (
  exists (
    select 1 from public.merchant_chat_threads t
    where t.id = thread_id
      and (
        t.customer_id = (select auth.uid())
        or exists (select 1 from public.merchants m where m.id = t.merchant_id and m.owner_profile_id = (select auth.uid()))
        or (select is_admin())
      )
  )
);

create policy mcm_insert
on public.merchant_chat_messages
for insert
to authenticated
with check (
  sender_id = (select auth.uid())
  and exists (
    select 1 from public.merchant_chat_threads t
    where t.id = thread_id
      and (
        t.customer_id = (select auth.uid())
        or exists (select 1 from public.merchants m where m.id = t.merchant_id and m.owner_profile_id = (select auth.uid()))
        or (select is_admin())
      )
  )
);

-- no updates/deletes from clients (immutable messages); admin can manage via service role if needed
create policy mcm_delete_admin
on public.merchant_chat_messages
for delete
to authenticated
using ((select is_admin()));

-- Keep thread.last_message_at in sync
create or replace function public.merchant_chat_touch_thread()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.merchant_chat_threads
  set last_message_at = greatest(coalesce(last_message_at, 'epoch'::timestamptz), new.created_at)
  where id = new.thread_id;
  return new;
end;
$$;

drop trigger if exists trg_mcm_touch_thread on public.merchant_chat_messages;
create trigger trg_mcm_touch_thread
after insert on public.merchant_chat_messages
for each row
execute function public.merchant_chat_touch_thread();

-- Helper RPC: customer gets or creates a thread for a merchant
create or replace function public.merchant_chat_get_or_create_thread(p_merchant_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_thread_id uuid;
begin
  if (select auth.uid()) is null then
    raise exception 'Not authenticated';
  end if;

  select id into v_thread_id
  from public.merchant_chat_threads
  where merchant_id = p_merchant_id
    and customer_id = (select auth.uid());

  if v_thread_id is not null then
    return v_thread_id;
  end if;

  insert into public.merchant_chat_threads (merchant_id, customer_id)
  values (p_merchant_id, (select auth.uid()))
  returning id into v_thread_id;

  return v_thread_id;
end;
$$;

grant execute on function public.merchant_chat_get_or_create_thread(uuid) to authenticated;

-- Realtime: enable Postgres Changes on chat tables
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'merchant_chat_threads'
  ) then
    execute 'alter publication supabase_realtime add table public.merchant_chat_threads';
  end if;

  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'merchant_chat_messages'
  ) then
    execute 'alter publication supabase_realtime add table public.merchant_chat_messages';
  end if;
end $$;

commit;
