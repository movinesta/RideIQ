-- Session: Reduce edge functions by moving Support + Chat list to DB RPCs

-- ---------------------------------------------------------------------------
-- Support Center RPCs (authenticated)
--
-- These functions intentionally run as SECURITY INVOKER (default) so that
-- table RLS policies remain the primary authorization boundary.
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.support_categories_list_user_v1()
RETURNS jsonb
LANGUAGE plpgsql
SET search_path TO 'pg_catalog, public'
AS $$
DECLARE
  v_uid uuid;
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  RETURN jsonb_build_object(
    'ok', true,
    'categories', COALESCE(
      (
        SELECT jsonb_agg(to_jsonb(c) ORDER BY c.sort_order ASC)
        FROM (
          SELECT code, title, description, sort_order, enabled
          FROM public.support_categories
          WHERE enabled = true
          ORDER BY sort_order ASC
        ) c
      ),
      '[]'::jsonb
    )
  );
END;
$$;

REVOKE ALL ON FUNCTION public.support_categories_list_user_v1() FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.support_categories_list_user_v1() TO authenticated;


CREATE OR REPLACE FUNCTION public.support_ticket_list_user_v1(
  p_status text DEFAULT NULL,
  p_limit integer DEFAULT 20,
  p_offset integer DEFAULT 0
)
RETURNS jsonb
LANGUAGE plpgsql
SET search_path TO 'pg_catalog, public'
AS $$
DECLARE
  v_uid uuid;
  v_limit integer;
  v_offset integer;
  v_status text;
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  v_limit := GREATEST(1, LEAST(COALESCE(p_limit, 20), 50));
  v_offset := GREATEST(0, LEAST(COALESCE(p_offset, 0), 100000));
  v_status := NULLIF(trim(COALESCE(p_status, '')), '');

  IF v_status IS NOT NULL AND v_status NOT IN ('open','pending','resolved','closed') THEN
    RAISE EXCEPTION 'invalid_status';
  END IF;

  RETURN jsonb_build_object(
    'ok', true,
    'tickets', COALESCE(
      (
        SELECT jsonb_agg(to_jsonb(t) ORDER BY t.updated_at DESC)
        FROM (
          SELECT
            id,
            category_code,
            subject,
            status,
            priority,
            ride_id,
            created_by,
            created_at,
            updated_at,
            last_message,
            last_message_at,
            messages_count
          FROM public.support_ticket_summaries
          WHERE (v_status IS NULL OR status = v_status)
          ORDER BY updated_at DESC
          OFFSET v_offset
          LIMIT v_limit
        ) t
      ),
      '[]'::jsonb
    ),
    'next_offset', v_offset + (
      SELECT COALESCE(count(*), 0)
      FROM (
        SELECT 1
        FROM public.support_ticket_summaries
        WHERE (v_status IS NULL OR status = v_status)
        ORDER BY updated_at DESC
        OFFSET v_offset
        LIMIT v_limit
      ) x
    )
  );
END;
$$;

REVOKE ALL ON FUNCTION public.support_ticket_list_user_v1(text, integer, integer) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.support_ticket_list_user_v1(text, integer, integer) TO authenticated;


CREATE OR REPLACE FUNCTION public.support_ticket_get_user_v1(
  p_ticket_id uuid
)
RETURNS jsonb
LANGUAGE plpgsql
SET search_path TO 'pg_catalog, public'
AS $$
DECLARE
  v_uid uuid;
  v_ticket record;
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  SELECT id, category_code, subject, status, priority, ride_id, created_at, updated_at
  INTO v_ticket
  FROM public.support_tickets
  WHERE id = p_ticket_id
    AND (created_by = v_uid OR public.is_admin());

  IF NOT FOUND THEN
    RAISE EXCEPTION 'not_found';
  END IF;

  RETURN jsonb_build_object(
    'ok', true,
    'ticket', to_jsonb(v_ticket),
    'messages', COALESCE(
      (
        SELECT jsonb_agg(to_jsonb(m) ORDER BY m.created_at ASC)
        FROM (
          SELECT id, ticket_id, sender_id, message, attachments, created_at
          FROM public.support_messages
          WHERE ticket_id = p_ticket_id
          ORDER BY created_at ASC
        ) m
      ),
      '[]'::jsonb
    )
  );
END;
$$;

REVOKE ALL ON FUNCTION public.support_ticket_get_user_v1(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.support_ticket_get_user_v1(uuid) TO authenticated;


CREATE OR REPLACE FUNCTION public.support_ticket_create_user_v1(
  p_role_context public.user_role,
  p_subject text,
  p_message text,
  p_category_key text DEFAULT NULL,
  p_category_code text DEFAULT NULL,
  p_ride_id uuid DEFAULT NULL,
  p_priority public.support_ticket_priority DEFAULT 'normal'
)
RETURNS jsonb
LANGUAGE plpgsql
SET search_path TO 'pg_catalog, public'
AS $$
DECLARE
  v_uid uuid;
  v_subject text;
  v_message text;
  v_priority public.support_ticket_priority;
  v_role public.user_role;
  v_category_key text;
  v_category_id uuid;
  v_category_code text;
  v_ticket_id uuid;
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  v_role := p_role_context;
  IF v_role NOT IN ('rider','driver') THEN
    RAISE EXCEPTION 'invalid_role';
  END IF;

  v_subject := trim(COALESCE(p_subject, ''));
  v_message := trim(COALESCE(p_message, ''));
  IF length(v_subject) < 3 THEN
    RAISE EXCEPTION 'invalid_subject';
  END IF;
  IF length(v_message) < 2 THEN
    RAISE EXCEPTION 'invalid_message';
  END IF;

  v_priority := COALESCE(p_priority, 'normal');

  -- Validate ride relationship if provided
  IF p_ride_id IS NOT NULL THEN
    IF NOT EXISTS (
      SELECT 1
      FROM public.rides r
      WHERE r.id = p_ride_id
        AND (r.rider_id = v_uid OR r.driver_id = v_uid)
    ) THEN
      RAISE EXCEPTION 'ride_not_found';
    END IF;
  END IF;

  v_category_key := NULLIF(trim(COALESCE(p_category_key, '')), '');
  IF v_category_key IS NULL THEN
    v_category_key := 'other';
  END IF;

  -- Resolve category by key (preferred) then by code.
  SELECT c.id, c.code
  INTO v_category_id, v_category_code
  FROM public.support_categories c
  WHERE c.enabled = true
    AND (
      (v_category_key IS NOT NULL AND c.key = v_category_key)
      OR (v_category_key IS NULL AND NULLIF(trim(COALESCE(p_category_code, '')), '') IS NOT NULL AND c.code = trim(p_category_code))
    )
  LIMIT 1;

  INSERT INTO public.support_tickets (
    created_by,
    role_context,
    category_id,
    category_code,
    subject,
    ride_id,
    priority,
    status
  ) VALUES (
    v_uid,
    v_role,
    v_category_id,
    v_category_code,
    v_subject,
    p_ride_id,
    v_priority,
    'open'
  )
  RETURNING id INTO v_ticket_id;

  INSERT INTO public.support_messages (
    ticket_id,
    sender_id,
    message,
    attachments
  ) VALUES (
    v_ticket_id,
    v_uid,
    v_message,
    '[]'::jsonb
  );

  RETURN jsonb_build_object('ok', true, 'ticket_id', v_ticket_id);
END;
$$;

REVOKE ALL ON FUNCTION public.support_ticket_create_user_v1(public.user_role, text, text, text, text, uuid, public.support_ticket_priority) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.support_ticket_create_user_v1(public.user_role, text, text, text, text, uuid, public.support_ticket_priority) TO authenticated;


CREATE OR REPLACE FUNCTION public.support_ticket_post_message_user_v1(
  p_ticket_id uuid,
  p_message text,
  p_attachments jsonb DEFAULT '[]'::jsonb
)
RETURNS jsonb
LANGUAGE plpgsql
SET search_path TO 'pg_catalog, public'
AS $$
DECLARE
  v_uid uuid;
  v_message text;
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  v_message := trim(COALESCE(p_message, ''));
  IF length(v_message) < 1 THEN
    RAISE EXCEPTION 'invalid_message';
  END IF;

  -- Ensure the caller is allowed to see the ticket (owner or admin)
  IF NOT EXISTS (
    SELECT 1
    FROM public.support_tickets t
    WHERE t.id = p_ticket_id
      AND (t.created_by = v_uid OR public.is_admin())
  ) THEN
    RAISE EXCEPTION 'not_found';
  END IF;

  INSERT INTO public.support_messages (
    ticket_id,
    sender_id,
    message,
    attachments
  ) VALUES (
    p_ticket_id,
    v_uid,
    v_message,
    COALESCE(p_attachments, '[]'::jsonb)
  );

  RETURN jsonb_build_object('ok', true);
END;
$$;

REVOKE ALL ON FUNCTION public.support_ticket_post_message_user_v1(uuid, text, jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.support_ticket_post_message_user_v1(uuid, text, jsonb) TO authenticated;


-- ---------------------------------------------------------------------------
-- Ride chat list RPC (authenticated)
-- ---------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION public.ride_chat_list_user_v1(
  p_ride_id uuid,
  p_limit integer DEFAULT 50,
  p_before timestamptz DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SET search_path TO 'pg_catalog, public'
AS $$
DECLARE
  v_uid uuid;
  v_thread_id uuid;
  v_limit integer;
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  v_limit := GREATEST(1, LEAST(COALESCE(p_limit, 50), 100));

  v_thread_id := public.ride_chat_get_or_create_thread(p_ride_id);

  RETURN (
    WITH msgs AS (
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
      FROM public.ride_chat_messages
      WHERE thread_id = v_thread_id
        AND (p_before IS NULL OR created_at < p_before)
      ORDER BY created_at DESC
      LIMIT v_limit
    )
    SELECT jsonb_build_object(
      'ok', true,
      'thread_id', v_thread_id,
      'messages', COALESCE(
        (
          SELECT jsonb_agg(to_jsonb(m) ORDER BY m.created_at ASC)
          FROM msgs m
        ),
        '[]'::jsonb
      ),
      'next_cursor', (
        SELECT min(created_at) FROM msgs
      )
    )
  );
END;
$$;

REVOKE ALL ON FUNCTION public.ride_chat_list_user_v1(uuid, integer, timestamptz) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.ride_chat_list_user_v1(uuid, integer, timestamptz) TO authenticated;
