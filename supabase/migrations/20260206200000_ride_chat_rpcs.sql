-- Session: Ride chat refactor (thin edge wrappers + DB RPCs)

-- 1) Allow thread-level read receipts by relaxing legacy NOT NULL columns.
-- (Idempotent; safe if already nullable.)
ALTER TABLE public.ride_chat_read_receipts
  ALTER COLUMN message_id DROP NOT NULL,
  ALTER COLUMN reader_id DROP NOT NULL;

-- 2) Add a unique constraint for thread-level read state upserts.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'ride_chat_read_receipts_thread_user_key'
  ) THEN
    ALTER TABLE public.ride_chat_read_receipts
      ADD CONSTRAINT ride_chat_read_receipts_thread_user_key UNIQUE (thread_id, user_id);
  END IF;
END $$;

-- 3) Canonical RPC: send chat message (atomic; enforces participant membership).
CREATE OR REPLACE FUNCTION public.ride_chat_send_message(
  p_ride_id uuid,
  p_kind public.chat_message_type DEFAULT 'text',
  p_text text DEFAULT NULL,
  p_attachment_bucket text DEFAULT NULL,
  p_attachment_key text DEFAULT NULL,
  p_metadata jsonb DEFAULT '{}'::jsonb,
  p_message_id uuid DEFAULT NULL
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'extensions', 'pg_temp'
AS $$
DECLARE
  v_uid uuid;
  v_thread uuid;
  v_body text;
  v_id uuid;
  v_msg record;
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  -- Normalize inputs
  v_body := NULLIF(btrim(COALESCE(p_text, '')), '');

  IF p_kind = 'text' AND v_body IS NULL THEN
    RAISE EXCEPTION 'text_required';
  END IF;

  IF p_kind = 'image' AND (p_attachment_key IS NULL OR length(btrim(p_attachment_key)) = 0) THEN
    RAISE EXCEPTION 'attachment_key_required';
  END IF;

  -- Membership enforcement + thread creation are centralized here.
  v_thread := public.ride_chat_get_or_create_thread(p_ride_id);

  v_id := COALESCE(p_message_id, gen_random_uuid());

  INSERT INTO public.ride_chat_messages (
    id,
    thread_id,
    ride_id,
    sender_id,
    kind,
    message_type,
    body,
    attachment_bucket,
    attachment_key,
    metadata
  ) VALUES (
    v_id,
    v_thread,
    p_ride_id,
    v_uid,
    p_kind,
    COALESCE(p_kind, 'text'),
    CASE WHEN p_kind = 'text' THEN v_body ELSE NULL END,
    p_attachment_bucket,
    p_attachment_key,
    COALESCE(p_metadata, '{}'::jsonb)
  )
  ON CONFLICT (id) DO NOTHING
  RETURNING
    id,
    thread_id,
    ride_id,
    sender_id,
    kind,
    body,
    attachment_bucket,
    attachment_key,
    metadata,
    created_at
  INTO v_msg;

  IF NOT FOUND THEN
    -- Idempotency path: return the existing message if it matches this caller + ride.
    SELECT
      id,
      thread_id,
      ride_id,
      sender_id,
      kind,
      body,
      attachment_bucket,
      attachment_key,
      metadata,
      created_at
    INTO v_msg
    FROM public.ride_chat_messages
    WHERE id = v_id
      AND ride_id = p_ride_id
      AND sender_id = v_uid;

    IF NOT FOUND THEN
      RAISE EXCEPTION 'message_id_conflict';
    END IF;
  END IF;

  RETURN jsonb_build_object(
    'ok', true,
    'message', jsonb_build_object(
      'id', v_msg.id,
      'thread_id', v_msg.thread_id,
      'ride_id', v_msg.ride_id,
      'sender_id', v_msg.sender_id,
      'kind', v_msg.kind,
      'body', v_msg.body,
      'attachment_bucket', v_msg.attachment_bucket,
      'attachment_key', v_msg.attachment_key,
      'metadata', COALESCE(v_msg.metadata, '{}'::jsonb),
      'created_at', v_msg.created_at
    )
  );
END;
$$;

ALTER FUNCTION public.ride_chat_send_message(uuid, public.chat_message_type, text, text, text, jsonb, uuid) OWNER TO postgres;

REVOKE ALL ON FUNCTION public.ride_chat_send_message(uuid, public.chat_message_type, text, text, text, jsonb, uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.ride_chat_send_message(uuid, public.chat_message_type, text, text, text, jsonb, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.ride_chat_send_message(uuid, public.chat_message_type, text, text, text, jsonb, uuid) TO service_role;


-- 4) Canonical RPC: mark chat thread as read (atomic; monotonic timestamps).
CREATE OR REPLACE FUNCTION public.ride_chat_mark_read(
  p_ride_id uuid,
  p_last_read_at timestamptz DEFAULT NULL,
  p_last_read_message_id uuid DEFAULT NULL
) RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'extensions', 'pg_temp'
AS $$
DECLARE
  v_uid uuid;
  v_thread uuid;
  v_at timestamptz;
  v_row record;
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  v_thread := public.ride_chat_get_or_create_thread(p_ride_id);
  v_at := COALESCE(p_last_read_at, now());

  IF p_last_read_message_id IS NOT NULL THEN
    PERFORM 1
    FROM public.ride_chat_messages m
    WHERE m.id = p_last_read_message_id
      AND m.ride_id = p_ride_id
      AND (m.thread_id = v_thread OR m.thread_id IS NULL);
    IF NOT FOUND THEN
      RAISE EXCEPTION 'invalid_last_read_message';
    END IF;
  END IF;

  INSERT INTO public.ride_chat_read_receipts (
    ride_id,
    thread_id,
    user_id,
    last_read_at,
    last_read_message_id,
    updated_at
  ) VALUES (
    p_ride_id,
    v_thread,
    v_uid,
    v_at,
    p_last_read_message_id,
    now()
  )
  ON CONFLICT (thread_id, user_id) DO UPDATE
  SET last_read_at = GREATEST(
        COALESCE(public.ride_chat_read_receipts.last_read_at, to_timestamp(0)),
        EXCLUDED.last_read_at
      ),
      last_read_message_id = COALESCE(EXCLUDED.last_read_message_id, public.ride_chat_read_receipts.last_read_message_id),
      updated_at = now()
  RETURNING
    id,
    ride_id,
    thread_id,
    user_id,
    last_read_at,
    last_read_message_id,
    updated_at
  INTO v_row;

  RETURN jsonb_build_object(
    'ok', true,
    'receipt', jsonb_build_object(
      'id', v_row.id,
      'ride_id', v_row.ride_id,
      'thread_id', v_row.thread_id,
      'user_id', v_row.user_id,
      'last_read_at', v_row.last_read_at,
      'last_read_message_id', v_row.last_read_message_id,
      'updated_at', v_row.updated_at
    )
  );
END;
$$;

ALTER FUNCTION public.ride_chat_mark_read(uuid, timestamptz, uuid) OWNER TO postgres;

REVOKE ALL ON FUNCTION public.ride_chat_mark_read(uuid, timestamptz, uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.ride_chat_mark_read(uuid, timestamptz, uuid) TO authenticated;
GRANT EXECUTE ON FUNCTION public.ride_chat_mark_read(uuid, timestamptz, uuid) TO service_role;
