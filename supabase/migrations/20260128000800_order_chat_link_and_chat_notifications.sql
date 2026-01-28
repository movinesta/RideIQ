-- P13: Link merchant orders to chat threads + notify on new merchant chat messages
-- Goals:
-- - Minimal schema changes: add chat_thread_id to merchant_orders
-- - Provide a safe RPC to get-or-create the thread for a specific order
-- - Add notifications on chat message inserts (to existing user_notifications)
-- - Keep RLS performant (initPlan wrappers) and SECURITY DEFINER functions safe via fixed search_path

begin;

-- 1) Link orders -> chat thread (nullable, set by RPC)
alter table public.merchant_orders
  add column if not exists chat_thread_id uuid references public.merchant_chat_threads(id) on delete set null;

create index if not exists ix_merchant_orders_chat_thread_id on public.merchant_orders(chat_thread_id);

-- 2) RPC: get or create the correct chat thread for an order, and store it on the order.
--    Callable by:
--      - the order customer
--      - the merchant owner for that order
--      - admin
create or replace function public.merchant_order_get_or_create_chat_thread(p_order_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid;
  v_order record;
  v_thread_id uuid;
begin
  uid := auth.uid();
  if uid is null then
    raise exception 'Not authenticated';
  end if;

  select o.id, o.merchant_id, o.customer_id, o.chat_thread_id
    into v_order
  from public.merchant_orders o
  where o.id = p_order_id;

  if not found then
    raise exception 'Order not found';
  end if;

  if not (
    v_order.customer_id = uid
    or exists (select 1 from public.merchants m where m.id = v_order.merchant_id and m.owner_profile_id = uid)
    or (select is_admin())
  ) then
    raise exception 'Not allowed';
  end if;

  if v_order.chat_thread_id is not null then
    return v_order.chat_thread_id;
  end if;

  -- Find existing thread
  select t.id into v_thread_id
  from public.merchant_chat_threads t
  where t.merchant_id = v_order.merchant_id
    and t.customer_id = v_order.customer_id;

  if v_thread_id is null then
    insert into public.merchant_chat_threads(merchant_id, customer_id)
    values (v_order.merchant_id, v_order.customer_id)
    returning id into v_thread_id;
  end if;

  update public.merchant_orders
    set chat_thread_id = v_thread_id
  where id = v_order.id
    and chat_thread_id is null;

  return v_thread_id;
end;
$$;

revoke all on function public.merchant_order_get_or_create_chat_thread(uuid) from public;
grant execute on function public.merchant_order_get_or_create_chat_thread(uuid) to authenticated;
grant execute on function public.merchant_order_get_or_create_chat_thread(uuid) to service_role;

-- 3) Notify the other participant when a message is sent
create or replace function public.merchant_chat_notify_new_message()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_thread record;
  v_receiver uuid;
  v_owner uuid;
  v_body text;
begin
  -- Ignore non-text messages with empty body (still notify but without body preview)
  v_body := coalesce(nullif(new.body, ''), '');

  select t.id, t.merchant_id, t.customer_id
    into v_thread
  from public.merchant_chat_threads t
  where t.id = new.thread_id;

  if not found then
    return new;
  end if;

  select m.owner_profile_id into v_owner
  from public.merchants m
  where m.id = v_thread.merchant_id;

  -- Determine receiver based on sender
  if new.sender_id = v_thread.customer_id then
    v_receiver := v_owner;
  elsif v_owner is not null and new.sender_id = v_owner then
    v_receiver := v_thread.customer_id;
  else
    -- sender is neither participant (shouldn't happen under RLS); skip
    return new;
  end if;

  if v_receiver is null then
    return new;
  end if;

  insert into public.user_notifications(user_id, kind, title, body, data)
  values (
    v_receiver,
    'merchant_chat_message',
    'New message',
    case when v_body = '' then null else left(v_body, 140) end,
    jsonb_build_object(
      'thread_id', new.thread_id,
      'merchant_id', v_thread.merchant_id
    )
  );

  return new;
end;
$$;

drop trigger if exists trg_mcm_notify on public.merchant_chat_messages;
create trigger trg_mcm_notify
after insert on public.merchant_chat_messages
for each row
execute function public.merchant_chat_notify_new_message();

commit;
