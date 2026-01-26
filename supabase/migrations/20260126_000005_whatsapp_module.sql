-- RideIQ Squashed Migrations: 04_whatsapp_module.sql
-- Generated: 2026-01-25T21:51:19.003532Z
-- Notes:
-- - This squashed set EXCLUDES 20260124_000001_init.sql (already applied).
-- - Source migrations merged here: 20260125_000023_whatsapp_booking.sql, 20260125_000024_whatsapp_templates_ops_cleanup.sql (without cron schedule), 20260125_000025_whatsapp_status_and_interactive.sql, 20260125_000026_whatsapp_ops_assignment_notes_sla.sql
-- - Run files in order: 01 -> 02 -> 03 -> 04 -> 05

-- Session 21: WhatsApp Cloud API booking intake + operator inbox + secure booking tokens
-- Best practices:
-- - Store inbound/outbound messages for audit + idempotency (unique wa_message_id)
-- - Tokenized bridging flow (guest WhatsApp -> authenticated rider) with short-lived tokens
-- - RLS: admin-only visibility for threads/messages/tokens; public access is via edge functions only

-- =========================
-- 1) Tables
-- =========================

CREATE TABLE IF NOT EXISTS public.whatsapp_threads (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  wa_id text NOT NULL, -- WhatsApp user id (messages[].from)
  phone_e164 text,
  stage text NOT NULL DEFAULT 'awaiting_pickup',
  pickup_lat double precision,
  pickup_lng double precision,
  dropoff_lat double precision,
  dropoff_lng double precision,
  pickup_address text,
  dropoff_address text,
  last_inbound_at timestamptz,
  last_outbound_at timestamptz,
  last_message_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT whatsapp_threads_wa_id_uniq UNIQUE (wa_id),
  CONSTRAINT whatsapp_threads_stage_check CHECK (stage IN ('awaiting_pickup','awaiting_dropoff','ready','closed'))
);

DROP TRIGGER IF EXISTS trg_whatsapp_threads_set_updated_at ON public.whatsapp_threads;
CREATE TRIGGER trg_whatsapp_threads_set_updated_at
BEFORE UPDATE ON public.whatsapp_threads
FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE INDEX IF NOT EXISTS idx_whatsapp_threads_last_message_at ON public.whatsapp_threads (last_message_at DESC);
CREATE INDEX IF NOT EXISTS idx_whatsapp_threads_stage_last_message_at ON public.whatsapp_threads (stage, last_message_at DESC);

CREATE TABLE IF NOT EXISTS public.whatsapp_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  thread_id uuid NOT NULL REFERENCES public.whatsapp_threads(id) ON DELETE CASCADE,
  wa_message_id text, -- unique message id from WhatsApp webhook for idempotency
  direction text NOT NULL, -- 'in' | 'out'
  msg_type text NOT NULL,  -- 'text' | 'location' | ...
  body text,
  payload jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT whatsapp_messages_direction_check CHECK (direction IN ('in','out'))
);

CREATE UNIQUE INDEX IF NOT EXISTS uq_whatsapp_messages_wa_message_id ON public.whatsapp_messages (wa_message_id) WHERE wa_message_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_thread_created_at ON public.whatsapp_messages (thread_id, created_at DESC);

CREATE TABLE IF NOT EXISTS public.whatsapp_booking_tokens (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  thread_id uuid NOT NULL REFERENCES public.whatsapp_threads(id) ON DELETE CASCADE,
  token text NOT NULL,
  token_hash text,
  expires_at timestamptz NOT NULL,
  used_at timestamptz,
  used_by uuid REFERENCES public.profiles(id) ON DELETE SET NULL,

  pickup_lat double precision NOT NULL,
  pickup_lng double precision NOT NULL,
  dropoff_lat double precision NOT NULL,
  dropoff_lng double precision NOT NULL,
  pickup_address text,
  dropoff_address text,

  created_at timestamptz NOT NULL DEFAULT now(),

  CONSTRAINT whatsapp_booking_tokens_token_uniq UNIQUE (token),
  CONSTRAINT whatsapp_booking_tokens_token_hash_uniq UNIQUE (token_hash),
  CONSTRAINT whatsapp_booking_tokens_pickup_lat_check CHECK (pickup_lat >= -90 AND pickup_lat <= 90),
  CONSTRAINT whatsapp_booking_tokens_pickup_lng_check CHECK (pickup_lng >= -180 AND pickup_lng <= 180),
  CONSTRAINT whatsapp_booking_tokens_dropoff_lat_check CHECK (dropoff_lat >= -90 AND dropoff_lat <= 90),
  CONSTRAINT whatsapp_booking_tokens_dropoff_lng_check CHECK (dropoff_lng >= -180 AND dropoff_lng <= 180)
);

CREATE INDEX IF NOT EXISTS idx_whatsapp_booking_tokens_expires_at ON public.whatsapp_booking_tokens (expires_at);
CREATE INDEX IF NOT EXISTS idx_whatsapp_booking_tokens_used_at ON public.whatsapp_booking_tokens (used_at);

-- =========================
-- 2) RLS (admin-only)
-- =========================

ALTER TABLE public.whatsapp_threads ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.whatsapp_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.whatsapp_booking_tokens ENABLE ROW LEVEL SECURITY;

-- Threads
DROP POLICY IF EXISTS whatsapp_threads_select_admin ON public.whatsapp_threads;
CREATE POLICY whatsapp_threads_select_admin
ON public.whatsapp_threads
FOR SELECT
TO authenticated
USING ((SELECT public.is_admin()));

DROP POLICY IF EXISTS whatsapp_threads_write_admin ON public.whatsapp_threads;
CREATE POLICY whatsapp_threads_write_admin
ON public.whatsapp_threads
FOR ALL
TO authenticated
USING ((SELECT public.is_admin()))
WITH CHECK ((SELECT public.is_admin()));

-- Messages
DROP POLICY IF EXISTS whatsapp_messages_select_admin ON public.whatsapp_messages;
CREATE POLICY whatsapp_messages_select_admin
ON public.whatsapp_messages
FOR SELECT
TO authenticated
USING ((SELECT public.is_admin()));

DROP POLICY IF EXISTS whatsapp_messages_write_admin ON public.whatsapp_messages;
CREATE POLICY whatsapp_messages_write_admin
ON public.whatsapp_messages
FOR ALL
TO authenticated
USING ((SELECT public.is_admin()))
WITH CHECK ((SELECT public.is_admin()));

-- Tokens
DROP POLICY IF EXISTS whatsapp_booking_tokens_select_admin ON public.whatsapp_booking_tokens;
CREATE POLICY whatsapp_booking_tokens_select_admin
ON public.whatsapp_booking_tokens
FOR SELECT
TO authenticated
USING ((SELECT public.is_admin()));

DROP POLICY IF EXISTS whatsapp_booking_tokens_write_admin ON public.whatsapp_booking_tokens;
CREATE POLICY whatsapp_booking_tokens_write_admin
ON public.whatsapp_booking_tokens
FOR ALL
TO authenticated
USING ((SELECT public.is_admin()))
WITH CHECK ((SELECT public.is_admin()));

-- =========================
-- 3) RPCs


-- Create token for an existing thread (admin only). Returns the raw token (display it once).
DROP FUNCTION IF EXISTS public.whatsapp_booking_token_create_v1(uuid, integer);
CREATE OR REPLACE FUNCTION public.whatsapp_booking_token_create_v1(p_thread_id uuid, p_expires_minutes integer DEFAULT 30)
RETURNS text
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog, public'
AS $$
DECLARE
  v_token text;
  v_hash text;
  v_thread public.whatsapp_threads%ROWTYPE;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'not_admin' USING errcode = '42501';
  END IF;

  SELECT * INTO v_thread FROM public.whatsapp_threads WHERE id = p_thread_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'thread_not_found' USING errcode = '22023';
  END IF;

  IF v_thread.pickup_lat IS NULL OR v_thread.pickup_lng IS NULL OR v_thread.dropoff_lat IS NULL OR v_thread.dropoff_lng IS NULL THEN
    RAISE EXCEPTION 'thread_not_ready' USING errcode = '22023';
  END IF;

  v_token := encode(extensions.gen_random_bytes(32), 'hex');
  v_hash := encode(extensions.digest(v_token, 'sha256'), 'hex');

  INSERT INTO public.whatsapp_booking_tokens (
    thread_id, token, token_hash, expires_at,
    pickup_lat, pickup_lng, dropoff_lat, dropoff_lng,
    pickup_address, dropoff_address
  ) VALUES (
    p_thread_id, v_token, v_hash, now() + make_interval(mins => greatest(5, least(coalesce(p_expires_minutes, 30), 1440))),
    v_thread.pickup_lat, v_thread.pickup_lng, v_thread.dropoff_lat, v_thread.dropoff_lng,
    v_thread.pickup_address, v_thread.dropoff_address
  );

  RETURN v_token;
END;
$$;

ALTER FUNCTION public.whatsapp_booking_token_create_v1(uuid, integer) OWNER TO postgres;


-- =========================

-- Public view (used via Edge Function); does not require auth but is SECURITY DEFINER and only returns active tokens.
DROP FUNCTION IF EXISTS public.whatsapp_booking_token_view_v1(text);
CREATE OR REPLACE FUNCTION public.whatsapp_booking_token_view_v1(p_token text)
RETURNS TABLE (
  pickup_lat double precision,
  pickup_lng double precision,
  dropoff_lat double precision,
  dropoff_lng double precision,
  pickup_address text,
  dropoff_address text,
  expires_at timestamptz,
  used_at timestamptz
)
LANGUAGE sql
SECURITY DEFINER
SET search_path TO 'pg_catalog, public'
AS $$
  select
    t.pickup_lat,
    t.pickup_lng,
    t.dropoff_lat,
    t.dropoff_lng,
    t.pickup_address,
    t.dropoff_address,
    t.expires_at,
    t.used_at
  from public.whatsapp_booking_tokens t
  where t.token = p_token
    and t.used_at is null
    and t.expires_at > now()
  limit 1;
$$;

ALTER FUNCTION public.whatsapp_booking_token_view_v1(text) OWNER TO postgres;

-- Consume token as authenticated rider; creates a ride_intent and marks token used.
DROP FUNCTION IF EXISTS public.whatsapp_booking_token_consume_v1(text);
CREATE OR REPLACE FUNCTION public.whatsapp_booking_token_consume_v1(p_token text)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'pg_catalog, public'
AS $$
DECLARE
  v_uid uuid;
  v_row public.whatsapp_booking_tokens%ROWTYPE;
  v_intent_id uuid;
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'not_authenticated' USING errcode = '28000';
  END IF;

  SELECT *
    INTO v_row
  FROM public.whatsapp_booking_tokens
  WHERE token = p_token
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'invalid_token' USING errcode = '22023';
  END IF;

  IF v_row.used_at IS NOT NULL THEN
    RAISE EXCEPTION 'token_used' USING errcode = '22023';
  END IF;

  IF v_row.expires_at <= now() THEN
    RAISE EXCEPTION 'token_expired' USING errcode = '22023';
  END IF;

  -- Mark used first to prevent races.
  UPDATE public.whatsapp_booking_tokens
     SET used_at = now(),
         used_by = v_uid
   WHERE id = v_row.id;

  -- Create ride intent for the authenticated rider.
  INSERT INTO public.ride_intents (
    rider_id,
    pickup_lat, pickup_lng,
    dropoff_lat, dropoff_lng,
    pickup_address, dropoff_address,
    product_code, source, status,
    notes
  ) VALUES (
    v_uid,
    v_row.pickup_lat, v_row.pickup_lng,
    v_row.dropoff_lat, v_row.dropoff_lng,
    v_row.pickup_address, v_row.dropoff_address,
    'standard', 'whatsapp', 'new',
    'Created via WhatsApp booking token'
  )
  RETURNING id INTO v_intent_id;

  RETURN v_intent_id;
END;
$$;

ALTER FUNCTION public.whatsapp_booking_token_consume_v1(text) OWNER TO postgres;

-- Tighten function execution
REVOKE ALL ON FUNCTION public.whatsapp_booking_token_create_v1(uuid, integer) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.whatsapp_booking_token_view_v1(text) FROM PUBLIC;
REVOKE ALL ON FUNCTION public.whatsapp_booking_token_consume_v1(text) FROM PUBLIC;

GRANT EXECUTE ON FUNCTION public.whatsapp_booking_token_create_v1(uuid, integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.whatsapp_booking_token_consume_v1(text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.whatsapp_booking_token_view_v1(text) TO service_role;

-- Session 22: WhatsApp templates + operator tooling + token cleanup
-- Adds template message metadata, admin convenience view, and a cleanup job for expired booking tokens.

-- 1) Extend whatsapp_messages to capture template sends + provider metadata
ALTER TABLE IF EXISTS public.whatsapp_messages
  ADD COLUMN IF NOT EXISTS template_name text,
  ADD COLUMN IF NOT EXISTS template_lang text,
  ADD COLUMN IF NOT EXISTS template_components jsonb,
  ADD COLUMN IF NOT EXISTS provider_message_id text;

CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_template_name ON public.whatsapp_messages (template_name) WHERE template_name IS NOT NULL;

-- 2) Admin convenience view (no SECURITY DEFINER)
-- Computes Customer Service Window (CSW) status based on last inbound message
CREATE OR REPLACE VIEW public.whatsapp_threads_admin_v1 AS
SELECT
  t.*,
  CASE
    WHEN t.last_inbound_at IS NULL THEN false
    WHEN t.last_inbound_at >= (now() - interval '24 hours') THEN true
    ELSE false
  END AS csw_open,
  CASE
    WHEN t.last_inbound_at IS NULL THEN NULL
    ELSE (t.last_inbound_at + interval '24 hours')
  END AS csw_expires_at,
  CASE
    WHEN t.last_inbound_at IS NULL THEN NULL
    ELSE GREATEST(0, floor(extract(epoch from ((t.last_inbound_at + interval '24 hours') - now()))))::bigint
  END AS csw_seconds_left
FROM public.whatsapp_threads t;

GRANT SELECT ON public.whatsapp_threads_admin_v1 TO authenticated;

-- 3) Cleanup expired unused tokens
CREATE OR REPLACE FUNCTION public.whatsapp_booking_tokens_cleanup_v1(p_limit int DEFAULT 2000)
RETURNS int
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  deleted_count int := 0;
BEGIN
  WITH doomed AS (
    SELECT id
    FROM public.whatsapp_booking_tokens
    WHERE used_at IS NULL
      AND expires_at < now()
    ORDER BY expires_at ASC
    LIMIT GREATEST(1, LEAST(p_limit, 50000))
  )
  DELETE FROM public.whatsapp_booking_tokens b
  USING doomed
  WHERE b.id = doomed.id;

  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  RETURN deleted_count;
END;
$$;

REVOKE ALL ON FUNCTION public.whatsapp_booking_tokens_cleanup_v1(int) FROM PUBLIC;

-- Session 23: WhatsApp message status tracking + interactive reply buttons
-- Adds status fields to whatsapp_messages and supports updating them from webhook 'statuses' payloads.

ALTER TABLE IF EXISTS public.whatsapp_messages
  ADD COLUMN IF NOT EXISTS wa_status text,
  ADD COLUMN IF NOT EXISTS delivered_at timestamptz,
  ADD COLUMN IF NOT EXISTS read_at timestamptz,
  ADD COLUMN IF NOT EXISTS failed_at timestamptz,
  ADD COLUMN IF NOT EXISTS status_payload jsonb,
  ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();

-- Helpful indexes for matching status updates
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_provider_message_id ON public.whatsapp_messages (provider_message_id) WHERE provider_message_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_wa_status ON public.whatsapp_messages (wa_status) WHERE wa_status IS NOT NULL;

-- Keep updated_at fresh
CREATE OR REPLACE FUNCTION public.whatsapp_messages_touch_updated_at_v1()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_whatsapp_messages_touch_updated_at ON public.whatsapp_messages;
CREATE TRIGGER trg_whatsapp_messages_touch_updated_at
BEFORE UPDATE ON public.whatsapp_messages
FOR EACH ROW
EXECUTE FUNCTION public.whatsapp_messages_touch_updated_at_v1();

-- Session 24: WhatsApp operator workflow hardening
-- Adds assignment, internal notes, follow-up flags, SLA helpers, and a failed-outbound trigger.

-- 1) Extend whatsapp_threads with operator workflow fields
ALTER TABLE IF EXISTS public.whatsapp_threads
  ADD COLUMN IF NOT EXISTS op_status text NOT NULL DEFAULT 'open',
  ADD COLUMN IF NOT EXISTS assigned_admin_id uuid REFERENCES public.profiles(id),
  ADD COLUMN IF NOT EXISTS assigned_at timestamptz,
  ADD COLUMN IF NOT EXISTS needs_followup boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS followup_reason text,
  ADD COLUMN IF NOT EXISTS followup_at timestamptz,
  ADD COLUMN IF NOT EXISTS last_failed_outbound_at timestamptz,
  ADD COLUMN IF NOT EXISTS last_failed_outbound_message_id text;

DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_constraint
    WHERE conname = 'whatsapp_threads_op_status_check'
  ) THEN
    ALTER TABLE public.whatsapp_threads
      ADD CONSTRAINT whatsapp_threads_op_status_check
      CHECK (op_status IN ('open','waiting_user','waiting_operator','resolved'));
  END IF;
END;
$$;

CREATE INDEX IF NOT EXISTS idx_whatsapp_threads_assigned_admin ON public.whatsapp_threads (assigned_admin_id) WHERE assigned_admin_id IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_whatsapp_threads_needs_followup ON public.whatsapp_threads (needs_followup) WHERE needs_followup = true;
CREATE INDEX IF NOT EXISTS idx_whatsapp_threads_op_status_last_message ON public.whatsapp_threads (op_status, last_message_at DESC);

-- 2) Thread internal notes (admin-only)
CREATE TABLE IF NOT EXISTS public.whatsapp_thread_notes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  thread_id uuid NOT NULL REFERENCES public.whatsapp_threads(id) ON DELETE CASCADE,
  author_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  body text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.whatsapp_thread_notes ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS whatsapp_thread_notes_select_admin ON public.whatsapp_thread_notes;
CREATE POLICY whatsapp_thread_notes_select_admin
ON public.whatsapp_thread_notes
FOR SELECT
TO authenticated
USING ((SELECT public.is_admin()));

DROP POLICY IF EXISTS whatsapp_thread_notes_write_admin ON public.whatsapp_thread_notes;
CREATE POLICY whatsapp_thread_notes_write_admin
ON public.whatsapp_thread_notes
FOR ALL
TO authenticated
USING ((SELECT public.is_admin()))
WITH CHECK ((SELECT public.is_admin()));

CREATE INDEX IF NOT EXISTS idx_whatsapp_thread_notes_thread_created_at ON public.whatsapp_thread_notes (thread_id, created_at DESC);

-- 3) Failed-outbound trigger: mark thread as needing follow-up
CREATE OR REPLACE FUNCTION public.whatsapp_messages_failed_outbound_to_followup_v1()
RETURNS trigger
LANGUAGE plpgsql
AS $$
BEGIN
  -- Only when outbound status transitions to failed
  IF (NEW.direction = 'out')
     AND (NEW.wa_status = 'failed')
     AND (OLD.wa_status IS DISTINCT FROM NEW.wa_status) THEN
    UPDATE public.whatsapp_threads
      SET needs_followup = true,
          followup_reason = COALESCE(followup_reason, 'outbound_failed'),
          followup_at = now(),
          last_failed_outbound_at = now(),
          last_failed_outbound_message_id = COALESCE(NEW.provider_message_id, NEW.wa_message_id),
          op_status = CASE WHEN op_status = 'resolved' THEN op_status ELSE 'waiting_operator' END,
          updated_at = now()
    WHERE id = NEW.thread_id;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_whatsapp_messages_failed_outbound_followup ON public.whatsapp_messages;
CREATE TRIGGER trg_whatsapp_messages_failed_outbound_followup
AFTER UPDATE OF wa_status ON public.whatsapp_messages
FOR EACH ROW
EXECUTE FUNCTION public.whatsapp_messages_failed_outbound_to_followup_v1();

-- 4) Admin convenience view v2 (no SECURITY DEFINER)
CREATE OR REPLACE VIEW public.whatsapp_threads_admin_v2 AS
SELECT
  t.*,
  CASE
    WHEN t.last_inbound_at IS NULL THEN false
    WHEN t.last_inbound_at >= (now() - interval '24 hours') THEN true
    ELSE false
  END AS csw_open,
  CASE
    WHEN t.last_inbound_at IS NULL THEN NULL
    ELSE (t.last_inbound_at + interval '24 hours')
  END AS csw_expires_at,
  CASE
    WHEN t.last_inbound_at IS NULL THEN NULL
    ELSE GREATEST(0, floor(extract(epoch from ((t.last_inbound_at + interval '24 hours') - now()))))::bigint
  END AS csw_seconds_left,
  CASE
    WHEN t.last_inbound_at IS NULL THEN NULL
    ELSE floor(extract(epoch from (now() - t.last_inbound_at)))::bigint
  END AS sla_seconds_since_last_inbound,
  CASE
    WHEN t.last_message_at IS NULL THEN NULL
    ELSE floor(extract(epoch from (now() - t.last_message_at)))::bigint
  END AS sla_seconds_since_last_message
FROM public.whatsapp_threads t;

GRANT SELECT ON public.whatsapp_threads_admin_v2 TO authenticated;

-- Grants
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.whatsapp_thread_notes TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE public.whatsapp_thread_notes TO service_role;
