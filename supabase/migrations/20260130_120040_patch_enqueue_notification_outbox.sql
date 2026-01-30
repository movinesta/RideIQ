-- Patch: respect per-notification push gating when enqueueing push outbox rows.
-- If user_notifications.data.push = false => do not enqueue to notification_outbox.

CREATE OR REPLACE FUNCTION public.enqueue_notification_outbox() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
  -- Respect per-notification channel gating.
  -- If the notification payload explicitly sets data.push=false, do NOT enqueue to notification_outbox.
  -- (The row still exists for in-app UX; push delivery is suppressed.)
  if (new.data ? 'push') and coalesce(nullif(new.data->>'push','')::boolean, true) = false then
    return new;
  end if;

  insert into public.notification_outbox (notification_id, user_id, device_token_id, payload)
  select
    new.id,
    new.user_id,
    dt.id,
    jsonb_build_object(
      'title', new.title,
      'body', new.body,
      'type', new.kind,
      'data', coalesce(new.data, '{}'::jsonb),
      'notification_id', new.id::text
    )
  from public.device_tokens dt
  where dt.user_id = new.user_id and dt.enabled = true;

  return new;
end;
$$;

-- Ensure trigger exists and uses updated function.
DROP TRIGGER IF EXISTS trg_enqueue_notification_outbox ON public.user_notifications;
CREATE TRIGGER trg_enqueue_notification_outbox AFTER INSERT ON public.user_notifications FOR EACH ROW EXECUTE FUNCTION public.enqueue_notification_outbox();
