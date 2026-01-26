-- RideIQ Squashed Migrations: 03_trusted_contacts.sql
-- Generated: 2026-01-25T21:51:19.003447Z
-- Notes:
-- - This squashed set EXCLUDES 20260124_000001_init.sql (already applied).
-- - Source migrations merged here: 20260125_000021_trusted_contacts_outbox.sql, 20260125_000022_trusted_contacts_outbox_retry_and_provider.sql
-- - Run files in order: 01 -> 02 -> 03 -> 04 -> 05

-- RideIQ Session 19
-- Trusted Contacts Outbox (provider-agnostic dispatcher)

-- Purpose:
-- - When a Safety SOS share link is created, optionally enqueue an outbound message per trusted contact.
-- - A scheduled Edge Function (trusted-contacts-dispatch) claims pending rows and sends them via CONTACT_WEBHOOK_URL.

BEGIN;

-- Table: trusted_contact_outbox
CREATE TABLE IF NOT EXISTS public.trusted_contact_outbox (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  contact_id uuid NOT NULL REFERENCES public.trusted_contacts(id) ON DELETE CASCADE,
  sos_event_id uuid NOT NULL REFERENCES public.sos_events(id) ON DELETE CASCADE,
  ride_id uuid REFERENCES public.rides(id) ON DELETE SET NULL,

  -- Provider/channel hint (dispatcher decides)
  channel text NOT NULL DEFAULT 'whatsapp',
  to_phone text NOT NULL,

  -- Payload includes share token + url + expiry + optional template vars.
  -- NOTE: token is already stored in user_notifications.data today, so this doesn't introduce a new class of secret.
  payload jsonb NOT NULL DEFAULT '{}'::jsonb,

  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','processing','sent','failed','skipped')),
  attempts integer NOT NULL DEFAULT 0,
  last_attempt_at timestamptz,
  last_error text,
  next_attempt_at timestamptz NOT NULL DEFAULT now(),

  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Prevent duplicates for the same SOS + contact.
CREATE UNIQUE INDEX IF NOT EXISTS ux_trusted_contact_outbox_contact_sos
  ON public.trusted_contact_outbox (contact_id, sos_event_id);

CREATE INDEX IF NOT EXISTS idx_trusted_contact_outbox_pending
  ON public.trusted_contact_outbox (status, next_attempt_at, created_at);

CREATE INDEX IF NOT EXISTS idx_trusted_contact_outbox_user
  ON public.trusted_contact_outbox (user_id, created_at DESC);

-- Trigger: updated_at
DROP TRIGGER IF EXISTS trg_trusted_contact_outbox_set_updated_at ON public.trusted_contact_outbox;
CREATE TRIGGER trg_trusted_contact_outbox_set_updated_at
BEFORE UPDATE ON public.trusted_contact_outbox
FOR EACH ROW EXECUTE FUNCTION public.tg__set_updated_at();

-- RLS
ALTER TABLE public.trusted_contact_outbox ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS trusted_contact_outbox_service_role_all ON public.trusted_contact_outbox;
CREATE POLICY trusted_contact_outbox_service_role_all ON public.trusted_contact_outbox
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);

-- Admin read-only for debugging (no token exposure in UI by default)
DROP POLICY IF EXISTS trusted_contact_outbox_admin_read ON public.trusted_contact_outbox;
CREATE POLICY trusted_contact_outbox_admin_read ON public.trusted_contact_outbox
  FOR SELECT
  TO authenticated
  USING (public.is_admin(auth.uid()));

-- Claim pending rows (SKIP LOCKED) - similar pattern to notification_outbox_claim
CREATE OR REPLACE FUNCTION public.trusted_contact_outbox_claim(p_limit integer DEFAULT 50)
RETURNS TABLE(
  id uuid,
  user_id uuid,
  contact_id uuid,
  sos_event_id uuid,
  ride_id uuid,
  channel text,
  to_phone text,
  payload jsonb,
  attempts integer
)
LANGUAGE plpgsql SECURITY DEFINER
SET search_path TO 'pg_catalog, public'
AS $$
BEGIN
  RETURN QUERY
  WITH picked AS (
    SELECT o.id
    FROM public.trusted_contact_outbox o
    WHERE o.status = 'pending'
      AND o.next_attempt_at <= now()
    ORDER BY o.created_at ASC
    LIMIT greatest(1, least(coalesce(p_limit, 50), 200))
    FOR UPDATE SKIP LOCKED
  )
  UPDATE public.trusted_contact_outbox o
    SET status = 'processing',
        attempts = o.attempts + 1,
        last_attempt_at = now(),
        updated_at = now()
  WHERE o.id IN (SELECT id FROM picked)
  RETURNING o.id, o.user_id, o.contact_id, o.sos_event_id, o.ride_id, o.channel, o.to_phone, o.payload, o.attempts;
END;
$$;

REVOKE ALL ON FUNCTION public.trusted_contact_outbox_claim(p_limit integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.trusted_contact_outbox_claim(p_limit integer) TO service_role;

-- Mark as final status
CREATE OR REPLACE FUNCTION public.trusted_contact_outbox_mark(
  p_outbox_id uuid,
  p_status text,
  p_error text DEFAULT NULL
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER
SET search_path TO 'pg_catalog, public'
AS $$
DECLARE
  v_status text := lower(coalesce(p_status, 'failed'));
BEGIN
  IF v_status NOT IN ('sent','failed','skipped') THEN
    RAISE EXCEPTION 'invalid_status';
  END IF;

  UPDATE public.trusted_contact_outbox
    SET status = v_status,
        last_error = CASE WHEN v_status IN ('failed','skipped') THEN left(coalesce(p_error,''), 1000) ELSE NULL END,
        updated_at = now()
  WHERE id = p_outbox_id;
END;
$$;

REVOKE ALL ON FUNCTION public.trusted_contact_outbox_mark(p_outbox_id uuid, p_status text, p_error text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.trusted_contact_outbox_mark(p_outbox_id uuid, p_status text, p_error text) TO service_role;

COMMIT;

-- RideIQ Session 20
-- Trusted contacts outbox: retries/backoff + provider metadata
-- - Adds provider_message_id + http status fields
-- - Improves claim() to recover stale "processing" rows
-- - Adds mark_v2() to support retry with exponential backoff
BEGIN;

ALTER TABLE IF EXISTS public.trusted_contact_outbox
  ADD COLUMN IF NOT EXISTS provider_message_id text,
  ADD COLUMN IF NOT EXISTS last_http_status integer,
  ADD COLUMN IF NOT EXISTS last_response text;

-- Refresh pending index to include status/next_attempt_at already present.
-- (No-op if exists)
CREATE INDEX IF NOT EXISTS idx_trusted_contact_outbox_status_next
  ON public.trusted_contact_outbox (status, next_attempt_at);

-- Replace claim to also recover stale processing rows
CREATE OR REPLACE FUNCTION public.trusted_contact_outbox_claim(p_limit integer DEFAULT 50)
RETURNS TABLE(
  id uuid,
  user_id uuid,
  contact_id uuid,
  sos_event_id uuid,
  ride_id uuid,
  channel text,
  to_phone text,
  payload jsonb,
  attempts integer
)
LANGUAGE plpgsql SECURITY DEFINER
SET search_path TO 'pg_catalog, public'
AS $$
BEGIN
  RETURN QUERY
  WITH picked AS (
    SELECT o.id
    FROM public.trusted_contact_outbox o
    WHERE (
      (o.status = 'pending' AND o.next_attempt_at <= now())
      OR
      (o.status = 'processing' AND o.last_attempt_at < now() - interval '15 minutes')
    )
    ORDER BY o.created_at ASC
    LIMIT greatest(1, least(coalesce(p_limit, 50), 200))
    FOR UPDATE SKIP LOCKED
  )
  UPDATE public.trusted_contact_outbox o
    SET status = 'processing',
        attempts = o.attempts + 1,
        last_attempt_at = now(),
        updated_at = now()
  WHERE o.id IN (SELECT id FROM picked)
  RETURNING o.id, o.user_id, o.contact_id, o.sos_event_id, o.ride_id, o.channel, o.to_phone, o.payload, o.attempts;
END;
$$;

REVOKE ALL ON FUNCTION public.trusted_contact_outbox_claim(p_limit integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.trusted_contact_outbox_claim(p_limit integer) TO service_role;

-- Mark results with retry support
CREATE OR REPLACE FUNCTION public.trusted_contact_outbox_mark_v2(
  p_outbox_id uuid,
  p_result text,
  p_error text DEFAULT NULL,
  p_retry_in_seconds integer DEFAULT NULL,
  p_http_status integer DEFAULT NULL,
  p_provider_message_id text DEFAULT NULL,
  p_response text DEFAULT NULL
) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER
SET search_path TO 'pg_catalog, public'
AS $$
DECLARE
  v_result text := lower(coalesce(p_result, 'failed'));
  v_retry_seconds integer := greatest(10, least(coalesce(p_retry_in_seconds, 60), 86400)); -- 10s..24h
  v_attempts integer;
  v_max_attempts integer := 8;
BEGIN
  IF v_result NOT IN ('sent','retry','failed','skipped') THEN
    RAISE EXCEPTION 'invalid_result';
  END IF;

  SELECT attempts INTO v_attempts FROM public.trusted_contact_outbox WHERE id = p_outbox_id;

  IF v_attempts IS NULL THEN
    RETURN;
  END IF;

  IF v_result = 'sent' THEN
    UPDATE public.trusted_contact_outbox
      SET status = 'sent',
          last_error = NULL,
          last_http_status = p_http_status,
          provider_message_id = left(coalesce(p_provider_message_id,''), 200),
          last_response = left(coalesce(p_response,''), 1000),
          updated_at = now()
    WHERE id = p_outbox_id;
    RETURN;
  END IF;

  IF v_result = 'skipped' THEN
    UPDATE public.trusted_contact_outbox
      SET status = 'skipped',
          last_error = left(coalesce(p_error,''), 1000),
          last_http_status = p_http_status,
          last_response = left(coalesce(p_response,''), 1000),
          updated_at = now()
    WHERE id = p_outbox_id;
    RETURN;
  END IF;

  -- retry/failure
  IF v_result = 'retry' AND v_attempts < v_max_attempts THEN
    UPDATE public.trusted_contact_outbox
      SET status = 'pending',
          next_attempt_at = now() + make_interval(secs => v_retry_seconds),
          last_error = left(coalesce(p_error,''), 1000),
          last_http_status = p_http_status,
          last_response = left(coalesce(p_response,''), 1000),
          updated_at = now()
    WHERE id = p_outbox_id;
    RETURN;
  END IF;

  -- permanent failure or exceeded max retries
  UPDATE public.trusted_contact_outbox
    SET status = 'failed',
        last_error = left(coalesce(p_error,''), 1000),
        last_http_status = p_http_status,
        last_response = left(coalesce(p_response,''), 1000),
        updated_at = now()
  WHERE id = p_outbox_id;
END;
$$;

REVOKE ALL ON FUNCTION public.trusted_contact_outbox_mark_v2(
  uuid, text, text, integer, integer, text, text
) FROM PUBLIC;
GRANT ALL ON FUNCTION public.trusted_contact_outbox_mark_v2(
  uuid, text, text, integer, integer, text, text
) TO service_role;

COMMIT;
