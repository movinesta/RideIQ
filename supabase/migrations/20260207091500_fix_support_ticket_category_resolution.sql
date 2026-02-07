-- Fix: support_ticket_create_user_v1 should prefer explicit category_code when category_key is omitted.

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
  v_category_code_in text;
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
  v_category_code_in := NULLIF(trim(COALESCE(p_category_code, '')), '');

  -- Default to 'other' only when nothing is specified.
  IF v_category_key IS NULL AND v_category_code_in IS NULL THEN
    v_category_key := 'other';
  END IF;

  -- Resolve category by key (preferred) then by code.
  IF v_category_key IS NOT NULL THEN
    SELECT c.id, c.code
    INTO v_category_id, v_category_code
    FROM public.support_categories c
    WHERE c.enabled = true
      AND c.key = v_category_key
    LIMIT 1;
  ELSIF v_category_code_in IS NOT NULL THEN
    SELECT c.id, c.code
    INTO v_category_id, v_category_code
    FROM public.support_categories c
    WHERE c.enabled = true
      AND c.code = v_category_code_in
    LIMIT 1;
  END IF;

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

-- Keep existing grants (re-assert)
REVOKE ALL ON FUNCTION public.support_ticket_create_user_v1(public.user_role, text, text, text, text, uuid, public.support_ticket_priority) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.support_ticket_create_user_v1(public.user_role, text, text, text, text, uuid, public.support_ticket_priority) TO authenticated;

