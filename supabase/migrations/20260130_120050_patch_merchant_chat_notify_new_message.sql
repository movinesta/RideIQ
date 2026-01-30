-- Patch: merchant chat notifications
-- - Skip AI messages (message_type='ai' or sender_id=AI system profile)
-- - Use Iraqi title ('مسج جديد')

CREATE OR REPLACE FUNCTION public.merchant_chat_notify_new_message() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
declare
  v_thread record;
  v_receiver uuid;
  v_owner uuid;
  v_body text;
begin
  -- لا نرسل إشعار لرسائل المساعد (حتى ما يزعج الطرفين بإشعارات غير لازمة)
  if new.sender_id = '00000000-0000-0000-0000-00000000a1a1'::uuid or coalesce(new.message_type, '') = 'ai' then
    return new;
  end if;

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

  -- تحديد المستلم حسب المرسل
  if new.sender_id = v_thread.customer_id then
    v_receiver := v_owner;
  elsif v_owner is not null and new.sender_id = v_owner then
    v_receiver := v_thread.customer_id;
  else
    return new;
  end if;

  if v_receiver is null then
    return new;
  end if;

  insert into public.user_notifications(user_id, kind, title, body, data)
  values (
    v_receiver,
    'merchant_chat_message',
    'مسج جديد',
    case when v_body = '' then null else left(v_body, 140) end,
    jsonb_build_object(
      'thread_id', new.thread_id,
      'merchant_id', v_thread.merchant_id,
      'push', true,
      'inapp', true
    )
  );

  return new;
end;
$$;

DROP TRIGGER IF EXISTS trg_mcm_notify ON public.merchant_chat_messages;
CREATE TRIGGER trg_mcm_notify AFTER INSERT ON public.merchant_chat_messages FOR EACH ROW EXECUTE FUNCTION public.merchant_chat_notify_new_message();
