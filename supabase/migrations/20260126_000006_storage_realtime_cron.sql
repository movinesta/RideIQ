-- RideIQ Squashed Migrations: 05_storage_realtime_cron.sql
-- Generated: 2026-01-25T21:51:19.003657Z
-- Notes:
-- - This squashed set EXCLUDES 20260124_000001_init.sql (already applied).
-- - Source migrations merged here: 20260125_000015_storage_buckets_seed.sql (enhanced to include kyc-docs/driver-docs), 20260125_000013_storage_rls_initplan_fix.sql (+ extra legacy drops), 20260125_000014_realtime_publications_full.sql (plus ridecheck tables from 000019), 20260124_000005_scheduled_rides_cron_fix.sql (cron schedule), 20260125_000018_ridecheck.sql (cron schedule), 20260125_000024_whatsapp_templates_ops_cleanup.sql (cron schedule)
-- - Run files in order: 01 -> 02 -> 03 -> 04 -> 05

-- Session 13 (E2E): Storage buckets required by Edge Functions
--
-- The app uses private buckets + signed URLs for:
-- - avatars
-- - chat-media
--
-- Buckets are metadata rows in storage.buckets. A fresh database will not have them
-- unless you create them via the Dashboard.
--
-- Idempotent.

INSERT INTO storage.buckets (id, name, public, avif_autodetection)
VALUES
  ('avatars', 'avatars', false, false),
  ('chat-media', 'chat-media', false, false),
  ('kyc-docs', 'kyc-docs', false, false),
  ('driver-docs', 'driver-docs', false, false)
ON CONFLICT (name) DO NOTHING;

-- Consolidated Storage setup (Session 24 squash)
-- Ensure buckets exist, enable RLS, drop legacy policy names, then create final policies (initPlan-friendly).
ALTER TABLE IF EXISTS storage.objects ENABLE ROW LEVEL SECURITY;

-- Drop older consolidated policy names (from earlier sessions) if they exist
DROP POLICY IF EXISTS storage_objects_select_anon_avatars ON storage.objects;
DROP POLICY IF EXISTS storage_objects_select_authenticated ON storage.objects;
DROP POLICY IF EXISTS storage_objects_insert_authenticated ON storage.objects;
DROP POLICY IF EXISTS storage_objects_update_authenticated ON storage.objects;
DROP POLICY IF EXISTS storage_objects_delete_authenticated ON storage.objects;

-- Session 13: Reduce Auth RLS initPlan warnings for storage.objects policies
--
-- Supabase RLS performance best practice:
-- Wrap auth.* calls with (select ...) so Postgres can cache results in the initPlan
-- instead of recalculating per-row.

begin;

-- ---------------------------------------------------------------------------
-- Avatars bucket
-- ---------------------------------------------------------------------------

drop policy if exists avatars_delete_own on storage.objects;
drop policy if exists avatars_insert_own on storage.objects;
drop policy if exists avatars_read_public on storage.objects;
drop policy if exists avatars_update_own on storage.objects;

create policy avatars_read_public
on storage.objects
for select
to public
using (bucket_id = 'avatars');

create policy avatars_insert_own
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'avatars'
  and owner = (select auth.uid())
  and name like ((select auth.uid())::text || '/%')
);

create policy avatars_update_own
on storage.objects
for update
to authenticated
using (
  bucket_id = 'avatars'
  and owner = (select auth.uid())
  and name like ((select auth.uid())::text || '/%')
)
with check (
  bucket_id = 'avatars'
  and owner = (select auth.uid())
  and name like ((select auth.uid())::text || '/%')
);

create policy avatars_delete_own
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'avatars'
  and owner = (select auth.uid())
  and name like ((select auth.uid())::text || '/%')
);

-- ---------------------------------------------------------------------------
-- KYC docs bucket
-- ---------------------------------------------------------------------------

drop policy if exists kyc_delete_own on storage.objects;
drop policy if exists kyc_insert_own on storage.objects;
drop policy if exists kyc_read_own on storage.objects;
drop policy if exists kyc_update_own on storage.objects;

create policy kyc_read_own
on storage.objects
for select
to authenticated
using (
  bucket_id = 'kyc-docs'
  and owner = (select auth.uid())
);

create policy kyc_insert_own
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'kyc-docs'
  and owner = (select auth.uid())
  and name like ((select auth.uid())::text || '/%')
);

create policy kyc_update_own
on storage.objects
for update
to authenticated
using (
  bucket_id = 'kyc-docs'
  and owner = (select auth.uid())
  and name like ((select auth.uid())::text || '/%')
)
with check (
  bucket_id = 'kyc-docs'
  and owner = (select auth.uid())
  and name like ((select auth.uid())::text || '/%')
);

create policy kyc_delete_own
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'kyc-docs'
  and owner = (select auth.uid())
  and name like ((select auth.uid())::text || '/%')
);

-- ---------------------------------------------------------------------------
-- Driver docs bucket
-- ---------------------------------------------------------------------------

drop policy if exists driver_docs_delete_own on storage.objects;
drop policy if exists driver_docs_insert_own on storage.objects;
drop policy if exists driver_docs_read_own on storage.objects;
drop policy if exists driver_docs_update_own on storage.objects;

create policy driver_docs_read_own
on storage.objects
for select
to authenticated
using (
  bucket_id = 'driver-docs'
  and owner = (select auth.uid())
);

create policy driver_docs_insert_own
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'driver-docs'
  and owner = (select auth.uid())
  and name like ((select auth.uid())::text || '/%')
);

create policy driver_docs_update_own
on storage.objects
for update
to authenticated
using (
  bucket_id = 'driver-docs'
  and owner = (select auth.uid())
  and name like ((select auth.uid())::text || '/%')
)
with check (
  bucket_id = 'driver-docs'
  and owner = (select auth.uid())
  and name like ((select auth.uid())::text || '/%')
);

create policy driver_docs_delete_own
on storage.objects
for delete
to authenticated
using (
  bucket_id = 'driver-docs'
  and owner = (select auth.uid())
  and name like ((select auth.uid())::text || '/%')
);

-- ---------------------------------------------------------------------------
-- Chat media bucket (thread participants only)
-- ---------------------------------------------------------------------------

drop policy if exists chat_media_read_thread_participants on storage.objects;
drop policy if exists chat_media_insert_thread_participants on storage.objects;

create policy chat_media_read_thread_participants
on storage.objects
for select
to authenticated
using (
  bucket_id = 'chat-media'
  and name like 'threads/%'
  and exists (
    select 1
    from public.ride_chat_threads t
    where t.id::text = split_part(name, '/', 2)
      and (
        t.rider_id = (select auth.uid())
        or t.driver_id = (select auth.uid())
      )
  )
);

create policy chat_media_insert_thread_participants
on storage.objects
for insert
to authenticated
with check (
  bucket_id = 'chat-media'
  and name like 'threads/%'
  and exists (
    select 1
    from public.ride_chat_threads t
    where t.id::text = split_part(name, '/', 2)
      and (
        t.rider_id = (select auth.uid())
        or t.driver_id = (select auth.uid())
      )
  )
);

commit;

-- Session 13 (E2E): Realtime completeness
-- The frontend subscribes to these tables via Postgres Changes.
-- Ensure they are included in the `supabase_realtime` publication.
--
-- Idempotent: safe to run multiple times.
-- Ref: https://supabase.com/docs/guides/realtime/postgres-changes

DO $$
DECLARE
  v_pubname text := 'supabase_realtime';
  v_tbl text;
  v_tables text[] := ARRAY[
    'scheduled_rides',
    'ride_intents',
    'ride_requests',
    'rides',
    'topup_intents',
    'wallet_accounts',
    'wallet_entries',
    'wallet_holds',
    'wallet_withdraw_requests',
    'user_notifications',
    'ridecheck_events',
    'ridecheck_responses'
  ];
BEGIN
  FOREACH v_tbl IN ARRAY v_tables
  LOOP
    IF NOT EXISTS (
      SELECT 1
      FROM pg_publication_rel pr
      JOIN pg_class c ON c.oid = pr.prrelid
      JOIN pg_namespace n ON n.oid = c.relnamespace
      JOIN pg_publication p ON p.oid = pr.prpubid
      WHERE p.pubname = v_pubname
        AND n.nspname = 'public'
        AND c.relname = v_tbl
    ) THEN
      EXECUTE format('ALTER PUBLICATION %I ADD TABLE ONLY public.%I', v_pubname, v_tbl);
    END IF;
  END LOOP;
END $$;

-- ---------------------------------------------------------------------------
-- Cron schedules (run last)
-- Uses robust detection for pg_cron versions (jobname column / named schedule).
-- ---------------------------------------------------------------------------

-- Scheduled rides runner schedule
DO $$
DECLARE
  has_jobname_col boolean;
  has_named_schedule boolean;
BEGIN
  -- Ensure pg_cron exists (safe on hosted Supabase; may require Dashboard enable)
  IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron') THEN
    RETURN;
  END IF;
  -- Try to enable pg_cron (may require privileges depending on environment)
  BEGIN
    CREATE EXTENSION IF NOT EXISTS pg_cron;
  EXCEPTION
    WHEN insufficient_privilege THEN
      -- In hosted environments, this can be managed via Dashboard; do not fail migrations.
      NULL;
    WHEN undefined_file THEN
      NULL;
  END;

  IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron') THEN
    RETURN;
  END IF;

  has_jobname_col := EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'cron'
      AND table_name = 'job'
      AND column_name = 'jobname'
  );

  -- pg_cron 1.5+ supports cron.schedule(job_name, schedule, command)
  has_named_schedule := to_regprocedure('cron.schedule(text,text,text)') IS NOT NULL;

  IF has_named_schedule AND has_jobname_col THEN
    IF NOT EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'scheduled_rides_execute_due') THEN
      PERFORM cron.schedule(
        'scheduled_rides_execute_due',
        '* * * * *',
        $$select public.scheduled_rides_execute_due();$$
      );
    END IF;
  ELSE
    -- Older pg_cron: cron.schedule(schedule, command), and cron.job has no jobname.
    IF NOT EXISTS (
      SELECT 1 FROM cron.job
      WHERE command ILIKE '%scheduled_rides_execute_due%'
    ) THEN
      PERFORM cron.schedule(
        '* * * * *',
        $$select public.scheduled_rides_execute_due();$$
      );
    END IF;
  END IF;
END $$;

-- Ridecheck runner schedule
-- 6) Schedule ridecheck runner every minute (idempotent across pg_cron versions)
DO $$
DECLARE
  has_jobname_col boolean;
  has_named_schedule boolean;
BEGIN
  BEGIN
    CREATE EXTENSION IF NOT EXISTS pg_cron;
  EXCEPTION
    WHEN insufficient_privilege THEN NULL;
    WHEN undefined_file THEN NULL;
  END;

  IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron') THEN
    RETURN;
  END IF;

  has_jobname_col := EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_schema = 'cron'
      AND table_name = 'job'
      AND column_name = 'jobname'
  );

  has_named_schedule := to_regprocedure('cron.schedule(text,text,text)') IS NOT NULL;

  IF has_named_schedule AND has_jobname_col THEN
    IF NOT EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'ridecheck_run_v1') THEN
      PERFORM cron.schedule(
        'ridecheck_run_v1',
        '* * * * *',
        $$select public.ridecheck_run_v1();$$
      );
    END IF;
  ELSE
    IF NOT EXISTS (
      SELECT 1 FROM cron.job
      WHERE command ILIKE '%ridecheck_run_v1%'
    ) THEN
      PERFORM cron.schedule(
        '* * * * *',
        $$select public.ridecheck_run_v1();$$
      );
    END IF;
  END IF;
END $$;

-- WhatsApp token cleanup schedule (wrap with pg_cron enable guard)
DO $$
BEGIN
  BEGIN
    CREATE EXTENSION IF NOT EXISTS pg_cron;
  EXCEPTION
    WHEN insufficient_privilege THEN NULL;
    WHEN undefined_file THEN NULL;
  END;

  IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron') THEN
    RETURN;
  END IF;
END $$;

-- 4) Schedule daily cleanup via pg_cron (idempotent; handles older cron versions)
DO $$
DECLARE
  has_jobname_col boolean;
  has_named_schedule boolean;
BEGIN
  -- Skip if pg_cron isn't available
  IF NOT EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_cron') THEN
    RETURN;
  END IF;
  SELECT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'cron' AND table_name = 'job' AND column_name = 'jobname'
  ) INTO has_jobname_col;

  has_named_schedule := to_regprocedure('cron.schedule(text,text,text)') IS NOT NULL;

  IF has_named_schedule AND has_jobname_col THEN
    IF NOT EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'whatsapp_tokens_cleanup_v1') THEN
      PERFORM cron.schedule(
        'whatsapp_tokens_cleanup_v1',
        '15 2 * * *',
        $$select public.whatsapp_booking_tokens_cleanup_v1(5000);$$
      );
    END IF;
  ELSE
    IF NOT EXISTS (
      SELECT 1 FROM cron.job
      WHERE command ILIKE '%whatsapp_booking_tokens_cleanup_v1%'
    ) THEN
      PERFORM cron.schedule(
        '15 2 * * *',
        $$select public.whatsapp_booking_tokens_cleanup_v1(5000);$$
      );
    END IF;
  END IF;
END $$;
