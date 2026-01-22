--
-- PostgreSQL database dump
--

\restrict 2uGOZkE6AKCJUJtrdnxZbySpRBEeaf3QLf9l8bWzElj3FzCsfAirch5hvjqh4uY

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.7

-- Started on 2026-01-22 03:38:17

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 40 (class 2615 OID 16494)
-- Name: auth; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA auth;


ALTER SCHEMA auth OWNER TO supabase_admin;

--
-- TOC entry 8 (class 3079 OID 23759)
-- Name: pg_cron; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_cron WITH SCHEMA pg_catalog;


--
-- TOC entry 5802 (class 0 OID 0)
-- Dependencies: 8
-- Name: EXTENSION pg_cron; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_cron IS 'Job scheduler for PostgreSQL';


--
-- TOC entry 26 (class 2615 OID 16388)
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA extensions;


ALTER SCHEMA extensions OWNER TO postgres;

--
-- TOC entry 38 (class 2615 OID 16574)
-- Name: graphql; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA graphql;


ALTER SCHEMA graphql OWNER TO supabase_admin;

--
-- TOC entry 37 (class 2615 OID 16563)
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA graphql_public;


ALTER SCHEMA graphql_public OWNER TO supabase_admin;

--
-- TOC entry 9 (class 3079 OID 23810)
-- Name: pg_net; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_net WITH SCHEMA extensions;


--
-- TOC entry 5805 (class 0 OID 0)
-- Dependencies: 9
-- Name: EXTENSION pg_net; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_net IS 'Async HTTP';


--
-- TOC entry 15 (class 2615 OID 16386)
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: pgbouncer
--

CREATE SCHEMA pgbouncer;


ALTER SCHEMA pgbouncer OWNER TO pgbouncer;

--
-- TOC entry 12 (class 2615 OID 16555)
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA realtime;


ALTER SCHEMA realtime OWNER TO supabase_admin;

--
-- TOC entry 41 (class 2615 OID 16542)
-- Name: storage; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA storage;


ALTER SCHEMA storage OWNER TO supabase_admin;

--
-- TOC entry 35 (class 2615 OID 16603)
-- Name: vault; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA vault;


ALTER SCHEMA vault OWNER TO supabase_admin;

--
-- TOC entry 6 (class 3079 OID 16639)
-- Name: pg_graphql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_graphql WITH SCHEMA graphql;


--
-- TOC entry 5811 (class 0 OID 0)
-- Dependencies: 6
-- Name: EXTENSION pg_graphql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_graphql IS 'pg_graphql: GraphQL support';


--
-- TOC entry 2 (class 3079 OID 16389)
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA extensions;


--
-- TOC entry 5812 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- TOC entry 4 (class 3079 OID 16443)
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;


--
-- TOC entry 5813 (class 0 OID 0)
-- Dependencies: 4
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- TOC entry 7 (class 3079 OID 21987)
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA extensions;


--
-- TOC entry 5814 (class 0 OID 0)
-- Dependencies: 7
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- TOC entry 5 (class 3079 OID 16604)
-- Name: supabase_vault; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS supabase_vault WITH SCHEMA vault;


--
-- TOC entry 5815 (class 0 OID 0)
-- Dependencies: 5
-- Name: EXTENSION supabase_vault; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION supabase_vault IS 'Supabase Vault Extension';


--
-- TOC entry 3 (class 3079 OID 16432)
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;


--
-- TOC entry 5816 (class 0 OID 0)
-- Dependencies: 3
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- TOC entry 1995 (class 1247 OID 16738)
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


ALTER TYPE auth.aal_level OWNER TO supabase_auth_admin;

--
-- TOC entry 2019 (class 1247 OID 16879)
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


ALTER TYPE auth.code_challenge_method OWNER TO supabase_auth_admin;

--
-- TOC entry 1992 (class 1247 OID 16732)
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


ALTER TYPE auth.factor_status OWNER TO supabase_auth_admin;

--
-- TOC entry 1989 (class 1247 OID 16727)
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


ALTER TYPE auth.factor_type OWNER TO supabase_auth_admin;

--
-- TOC entry 2037 (class 1247 OID 16982)
-- Name: oauth_authorization_status; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.oauth_authorization_status AS ENUM (
    'pending',
    'approved',
    'denied',
    'expired'
);


ALTER TYPE auth.oauth_authorization_status OWNER TO supabase_auth_admin;

--
-- TOC entry 2049 (class 1247 OID 17055)
-- Name: oauth_client_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.oauth_client_type AS ENUM (
    'public',
    'confidential'
);


ALTER TYPE auth.oauth_client_type OWNER TO supabase_auth_admin;

--
-- TOC entry 2031 (class 1247 OID 16960)
-- Name: oauth_registration_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.oauth_registration_type AS ENUM (
    'dynamic',
    'manual'
);


ALTER TYPE auth.oauth_registration_type OWNER TO supabase_auth_admin;

--
-- TOC entry 2040 (class 1247 OID 16992)
-- Name: oauth_response_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.oauth_response_type AS ENUM (
    'code'
);


ALTER TYPE auth.oauth_response_type OWNER TO supabase_auth_admin;

--
-- TOC entry 2025 (class 1247 OID 16921)
-- Name: one_time_token_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.one_time_token_type AS ENUM (
    'confirmation_token',
    'reauthentication_token',
    'recovery_token',
    'email_change_token_new',
    'email_change_token_current',
    'phone_change_token'
);


ALTER TYPE auth.one_time_token_type OWNER TO supabase_auth_admin;

--
-- TOC entry 2091 (class 1247 OID 23032)
-- Name: driver_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.driver_status AS ENUM (
    'offline',
    'available',
    'on_trip',
    'suspended',
    'reserved'
);


ALTER TYPE public.driver_status OWNER TO postgres;

--
-- TOC entry 2193 (class 1247 OID 23463)
-- Name: incident_severity; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.incident_severity AS ENUM (
    'low',
    'medium',
    'high',
    'critical'
);


ALTER TYPE public.incident_severity OWNER TO postgres;

--
-- TOC entry 2196 (class 1247 OID 23472)
-- Name: incident_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.incident_status AS ENUM (
    'open',
    'triaging',
    'resolved',
    'closed'
);


ALTER TYPE public.incident_status OWNER TO postgres;

--
-- TOC entry 2263 (class 1247 OID 23917)
-- Name: kyc_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.kyc_status AS ENUM (
    'unverified',
    'pending',
    'verified',
    'rejected'
);


ALTER TYPE public.kyc_status OWNER TO postgres;

--
-- TOC entry 2184 (class 1247 OID 23400)
-- Name: party_role; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.party_role AS ENUM (
    'rider',
    'driver'
);


ALTER TYPE public.party_role OWNER TO postgres;

--
-- TOC entry 2172 (class 1247 OID 23305)
-- Name: payment_intent_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.payment_intent_status AS ENUM (
    'requires_payment_method',
    'requires_confirmation',
    'requires_capture',
    'succeeded',
    'failed',
    'canceled',
    'refunded'
);


ALTER TYPE public.payment_intent_status OWNER TO postgres;

--
-- TOC entry 2202 (class 1247 OID 23531)
-- Name: payment_provider_kind; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.payment_provider_kind AS ENUM (
    'zaincash',
    'asiapay',
    'qicard',
    'manual'
);


ALTER TYPE public.payment_provider_kind OWNER TO postgres;

--
-- TOC entry 2100 (class 1247 OID 23068)
-- Name: ride_actor_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.ride_actor_type AS ENUM (
    'rider',
    'driver',
    'system'
);


ALTER TYPE public.ride_actor_type OWNER TO postgres;

--
-- TOC entry 2094 (class 1247 OID 23042)
-- Name: ride_request_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.ride_request_status AS ENUM (
    'requested',
    'matched',
    'accepted',
    'cancelled',
    'no_driver',
    'expired'
);


ALTER TYPE public.ride_request_status OWNER TO postgres;

--
-- TOC entry 2097 (class 1247 OID 23056)
-- Name: ride_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.ride_status AS ENUM (
    'assigned',
    'arrived',
    'in_progress',
    'completed',
    'canceled'
);


ALTER TYPE public.ride_status OWNER TO postgres;

--
-- TOC entry 2205 (class 1247 OID 23540)
-- Name: topup_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.topup_status AS ENUM (
    'created',
    'pending',
    'succeeded',
    'failed'
);


ALTER TYPE public.topup_status OWNER TO postgres;

--
-- TOC entry 2211 (class 1247 OID 23558)
-- Name: wallet_entry_kind; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.wallet_entry_kind AS ENUM (
    'topup',
    'ride_fare',
    'withdrawal',
    'adjustment'
);


ALTER TYPE public.wallet_entry_kind OWNER TO postgres;

--
-- TOC entry 2257 (class 1247 OID 23878)
-- Name: wallet_hold_kind; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.wallet_hold_kind AS ENUM (
    'ride',
    'withdraw'
);


ALTER TYPE public.wallet_hold_kind OWNER TO postgres;

--
-- TOC entry 2208 (class 1247 OID 23550)
-- Name: wallet_hold_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.wallet_hold_status AS ENUM (
    'active',
    'captured',
    'released'
);


ALTER TYPE public.wallet_hold_status OWNER TO postgres;

--
-- TOC entry 2254 (class 1247 OID 23870)
-- Name: withdraw_payout_kind; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.withdraw_payout_kind AS ENUM (
    'qicard',
    'asiapay',
    'zaincash'
);


ALTER TYPE public.withdraw_payout_kind OWNER TO postgres;

--
-- TOC entry 2251 (class 1247 OID 23858)
-- Name: withdraw_request_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.withdraw_request_status AS ENUM (
    'requested',
    'approved',
    'rejected',
    'paid',
    'cancelled'
);


ALTER TYPE public.withdraw_request_status OWNER TO postgres;

--
-- TOC entry 2104 (class 1247 OID 17122)
-- Name: action; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.action AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


ALTER TYPE realtime.action OWNER TO supabase_admin;

--
-- TOC entry 2058 (class 1247 OID 17082)
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.equality_op AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte',
    'in'
);


ALTER TYPE realtime.equality_op OWNER TO supabase_admin;

--
-- TOC entry 2061 (class 1247 OID 17097)
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.user_defined_filter AS (
	column_name text,
	op realtime.equality_op,
	value text
);


ALTER TYPE realtime.user_defined_filter OWNER TO supabase_admin;

--
-- TOC entry 2110 (class 1247 OID 17164)
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.wal_column AS (
	name text,
	type_name text,
	type_oid oid,
	value jsonb,
	is_pkey boolean,
	is_selectable boolean
);


ALTER TYPE realtime.wal_column OWNER TO supabase_admin;

--
-- TOC entry 2107 (class 1247 OID 17135)
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.wal_rls AS (
	wal jsonb,
	is_rls_enabled boolean,
	subscription_ids uuid[],
	errors text[]
);


ALTER TYPE realtime.wal_rls OWNER TO supabase_admin;

--
-- TOC entry 2158 (class 1247 OID 17416)
-- Name: buckettype; Type: TYPE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TYPE storage.buckettype AS ENUM (
    'STANDARD',
    'ANALYTICS',
    'VECTOR'
);


ALTER TYPE storage.buckettype OWNER TO supabase_storage_admin;

--
-- TOC entry 499 (class 1255 OID 16540)
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.email', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
  )::text
$$;


ALTER FUNCTION auth.email() OWNER TO supabase_auth_admin;

--
-- TOC entry 5867 (class 0 OID 0)
-- Dependencies: 499
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- TOC entry 518 (class 1255 OID 16709)
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


ALTER FUNCTION auth.jwt() OWNER TO supabase_auth_admin;

--
-- TOC entry 498 (class 1255 OID 16539)
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.role', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
  )::text
$$;


ALTER FUNCTION auth.role() OWNER TO supabase_auth_admin;

--
-- TOC entry 5870 (class 0 OID 0)
-- Dependencies: 498
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- TOC entry 497 (class 1255 OID 16538)
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  coalesce(
    nullif(current_setting('request.jwt.claim.sub', true), ''),
    (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
  )::uuid
$$;


ALTER FUNCTION auth.uid() OWNER TO supabase_auth_admin;

--
-- TOC entry 5872 (class 0 OID 0)
-- Dependencies: 497
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- TOC entry 500 (class 1255 OID 16547)
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.grant_pg_cron_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_cron'
  )
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;
    revoke all on table cron.job from postgres;
    grant select on table cron.job to postgres with grant option;
  END IF;
END;
$$;


ALTER FUNCTION extensions.grant_pg_cron_access() OWNER TO supabase_admin;

--
-- TOC entry 6060 (class 0 OID 0)
-- Dependencies: 500
-- Name: FUNCTION grant_pg_cron_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_cron_access() IS 'Grants access to pg_cron';


--
-- TOC entry 504 (class 1255 OID 16568)
-- Name: grant_pg_graphql_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.grant_pg_graphql_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
    func_is_graphql_resolve bool;
BEGIN
    func_is_graphql_resolve = (
        SELECT n.proname = 'resolve'
        FROM pg_event_trigger_ddl_commands() AS ev
        LEFT JOIN pg_catalog.pg_proc AS n
        ON ev.objid = n.oid
    );

    IF func_is_graphql_resolve
    THEN
        -- Update public wrapper to pass all arguments through to the pg_graphql resolve func
        DROP FUNCTION IF EXISTS graphql_public.graphql;
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language sql
        as $$
            select graphql.resolve(
                query := query,
                variables := coalesce(variables, '{}'),
                "operationName" := "operationName",
                extensions := extensions
            );
        $$;

        -- This hook executes when `graphql.resolve` is created. That is not necessarily the last
        -- function in the extension so we need to grant permissions on existing entities AND
        -- update default permissions to any others that are created after `graphql.resolve`
        grant usage on schema graphql to postgres, anon, authenticated, service_role;
        grant select on all tables in schema graphql to postgres, anon, authenticated, service_role;
        grant execute on all functions in schema graphql to postgres, anon, authenticated, service_role;
        grant all on all sequences in schema graphql to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on tables to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on functions to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on sequences to postgres, anon, authenticated, service_role;

        -- Allow postgres role to allow granting usage on graphql and graphql_public schemas to custom roles
        grant usage on schema graphql_public to postgres with grant option;
        grant usage on schema graphql to postgres with grant option;
    END IF;

END;
$_$;


ALTER FUNCTION extensions.grant_pg_graphql_access() OWNER TO supabase_admin;

--
-- TOC entry 6062 (class 0 OID 0)
-- Dependencies: 504
-- Name: FUNCTION grant_pg_graphql_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_graphql_access() IS 'Grants access to pg_graphql';


--
-- TOC entry 501 (class 1255 OID 16549)
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.grant_pg_net_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = 'supabase_functions_admin'
    )
    THEN
      CREATE USER supabase_functions_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
    END IF;

    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    IF EXISTS (
      SELECT FROM pg_extension
      WHERE extname = 'pg_net'
      -- all versions in use on existing projects as of 2025-02-20
      -- version 0.12.0 onwards don't need these applied
      AND extversion IN ('0.2', '0.6', '0.7', '0.7.1', '0.8', '0.10.0', '0.11.0')
    ) THEN
      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;

      ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
      ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;

      REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
      REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;

      GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
      GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    END IF;
  END IF;
END;
$$;


ALTER FUNCTION extensions.grant_pg_net_access() OWNER TO supabase_admin;

--
-- TOC entry 6064 (class 0 OID 0)
-- Dependencies: 501
-- Name: FUNCTION grant_pg_net_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_net_access() IS 'Grants access to pg_net';


--
-- TOC entry 502 (class 1255 OID 16559)
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


ALTER FUNCTION extensions.pgrst_ddl_watch() OWNER TO supabase_admin;

--
-- TOC entry 503 (class 1255 OID 16560)
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


ALTER FUNCTION extensions.pgrst_drop_watch() OWNER TO supabase_admin;

--
-- TOC entry 505 (class 1255 OID 16570)
-- Name: set_graphql_placeholder(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.set_graphql_placeholder() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$_$;


ALTER FUNCTION extensions.set_graphql_placeholder() OWNER TO supabase_admin;

--
-- TOC entry 6179 (class 0 OID 0)
-- Dependencies: 505
-- Name: FUNCTION set_graphql_placeholder(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.set_graphql_placeholder() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- TOC entry 447 (class 1255 OID 16387)
-- Name: get_auth(text); Type: FUNCTION; Schema: pgbouncer; Owner: supabase_admin
--

CREATE FUNCTION pgbouncer.get_auth(p_usename text) RETURNS TABLE(username text, password text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $_$
  BEGIN
      RAISE DEBUG 'PgBouncer auth request: %', p_usename;

      RETURN QUERY
      SELECT
          rolname::text,
          CASE WHEN rolvaliduntil < now()
              THEN null
              ELSE rolpassword::text
          END
      FROM pg_authid
      WHERE rolname=$1 and rolcanlogin;
  END;
  $_$;


ALTER FUNCTION pgbouncer.get_auth(p_usename text) OWNER TO supabase_admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 434 (class 1259 OID 24198)
-- Name: gift_codes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.gift_codes (
    code text NOT NULL,
    amount_iqd bigint NOT NULL,
    memo text,
    created_by uuid,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    redeemed_by uuid,
    redeemed_at timestamp with time zone,
    redeemed_entry_id bigint,
    CONSTRAINT gift_codes_amount_iqd_check CHECK ((amount_iqd > 0))
);


ALTER TABLE public.gift_codes OWNER TO postgres;

--
-- TOC entry 1340 (class 1255 OID 24227)
-- Name: admin_create_gift_code(bigint, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.admin_create_gift_code(p_amount_iqd bigint, p_code text DEFAULT NULL::text, p_memo text DEFAULT NULL::text) RETURNS public.gift_codes
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_code text;
  v_row public.gift_codes;
  v_memo text;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'not_admin' USING errcode = '42501';
  END IF;

  IF p_amount_iqd IS NULL OR p_amount_iqd <= 0 THEN
    RAISE EXCEPTION 'invalid_amount';
  END IF;

  v_code := upper(trim(coalesce(p_code, '')));
  v_memo := nullif(trim(coalesce(p_memo, '')), '');

  IF v_code = '' THEN
    v_code := upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 12));
  END IF;

  LOOP
    BEGIN
      INSERT INTO public.gift_codes (code, amount_iqd, memo, created_by)
      VALUES (v_code, p_amount_iqd, v_memo, auth.uid())
      RETURNING * INTO v_row;
      EXIT;
    EXCEPTION WHEN unique_violation THEN
      IF p_code IS NOT NULL AND trim(p_code) <> '' THEN
        RAISE EXCEPTION 'gift_code_exists';
      END IF;
      v_code := upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 12));
    END;
  END LOOP;

  RETURN v_row;
END;
$$;


ALTER FUNCTION public.admin_create_gift_code(p_amount_iqd bigint, p_code text, p_memo text) OWNER TO postgres;

--
-- TOC entry 1339 (class 1255 OID 24024)
-- Name: admin_record_ride_refund(uuid, integer, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.admin_record_ride_refund(p_ride_id uuid, p_refund_amount_iqd integer DEFAULT NULL::integer, p_reason text DEFAULT NULL::text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
declare
  v_receipt public.ride_receipts%rowtype;
  v_payment public.payments%rowtype;
  v_total integer;
  v_prev_refunded integer;
  v_add integer;
  v_new_total integer;
  v_ref_id text;
begin
  -- authz
  if not public.is_admin() then
    raise exception 'not_admin' using errcode = '42501';
  end if;

  -- lock receipt
  select * into v_receipt
  from public.ride_receipts
  where ride_id = p_ride_id
  for update;

  if not found then
    raise exception 'receipt_not_found' using errcode = 'P0002';
  end if;

  v_total := coalesce(v_receipt.total_iqd, 0);
  v_prev_refunded := coalesce(v_receipt.refunded_iqd, 0);

  if p_refund_amount_iqd is null then
    v_add := greatest(v_total - v_prev_refunded, 0);
  else
    v_add := greatest(least(p_refund_amount_iqd, v_total - v_prev_refunded), 0);
  end if;

  if v_add <= 0 then
    return jsonb_build_object(
      'ride_id', p_ride_id,
      'refunded_iqd', v_prev_refunded,
      'added_iqd', 0,
      'status', 'no_op',
      'reason', p_reason
    );
  end if;

  v_new_total := v_prev_refunded + v_add;

  -- lock latest succeeded payment
  select * into v_payment
  from public.payments
  where ride_id = p_ride_id and status = 'succeeded'
  order by created_at desc
  limit 1
  for update;

  if not found then
    raise exception 'payment_not_found' using errcode = 'P0002';
  end if;

  v_ref_id := coalesce(v_payment.provider_refund_id, 'manual_refund:' || gen_random_uuid()::text);

  update public.payments
  set provider_refund_id = v_ref_id,
      refunded_at = now(),
      refund_amount_iqd = v_new_total,
      updated_at = now()
  where id = v_payment.id;

  return jsonb_build_object(
    'ride_id', p_ride_id,
    'payment_id', v_payment.id,
    'provider_refund_id', v_ref_id,
    'added_iqd', v_add,
    'refunded_iqd', v_new_total,
    'reason', p_reason
  );
end;
$$;


ALTER FUNCTION public.admin_record_ride_refund(p_ride_id uuid, p_refund_amount_iqd integer, p_reason text) OWNER TO postgres;

--
-- TOC entry 1296 (class 1255 OID 23522)
-- Name: admin_update_ride_incident(uuid, public.incident_status, uuid, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.admin_update_ride_incident(p_incident_id uuid, p_status public.incident_status DEFAULT NULL::public.incident_status, p_assigned_to uuid DEFAULT NULL::uuid, p_resolution_note text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog'
    AS $$
begin
  if not public.is_admin() then
    raise exception 'not_allowed';
  end if;

  update public.ride_incidents
  set
    status = coalesce(p_status, status),
    assigned_to = coalesce(p_assigned_to, assigned_to),
    resolution_note = coalesce(p_resolution_note, resolution_note),
    reviewed_at = case when p_status is null then reviewed_at else now() end
  where id = p_incident_id;

  if not found then
    raise exception 'not_found';
  end if;
end;
$$;


ALTER FUNCTION public.admin_update_ride_incident(p_incident_id uuid, p_status public.incident_status, p_assigned_to uuid, p_resolution_note text) OWNER TO postgres;

--
-- TOC entry 1308 (class 1255 OID 23755)
-- Name: admin_wallet_integrity_snapshot(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.admin_wallet_integrity_snapshot(p_limit integer DEFAULT 50, p_hold_age_seconds integer DEFAULT 3600, p_topup_age_seconds integer DEFAULT 600) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog'
    AS $$
declare
  v_limit int := greatest(1, least(coalesce(p_limit, 50), 200));
  v_hold_age interval := make_interval(secs => greatest(60, least(coalesce(p_hold_age_seconds, 3600), 30 * 24 * 3600)));
  v_topup_age interval := make_interval(secs => greatest(30, least(coalesce(p_topup_age_seconds, 600), 7 * 24 * 3600)));
  v_now timestamptz := now();

  v_accounts_count bigint;
  v_balance_sum bigint;
  v_held_sum bigint;
  v_active_holds_sum bigint;

  v_active_holds_old jsonb;
  v_active_holds_terminal_ride jsonb;
  v_completed_rides_missing_entries jsonb;
  v_held_mismatch jsonb;
  v_topup_succeeded_missing_entry jsonb;
  v_topup_stuck_pending jsonb;
begin
  if not public.is_admin() then
    raise exception 'not_allowed';
  end if;

  select
    count(*)::bigint,
    coalesce(sum(balance_iqd), 0)::bigint,
    coalesce(sum(held_iqd), 0)::bigint
  into v_accounts_count, v_balance_sum, v_held_sum
  from public.wallet_accounts;

  select coalesce(sum(amount_iqd), 0)::bigint
  into v_active_holds_sum
  from public.wallet_holds
  where status = 'active';

  -- 1) Active holds that are older than a threshold
  select coalesce(jsonb_agg(to_jsonb(t)), '[]'::jsonb)
  into v_active_holds_old
  from (
    select
      h.id as hold_id,
      h.user_id,
      h.ride_id,
      h.amount_iqd,
      h.created_at,
      h.updated_at
    from public.wallet_holds h
    where h.status = 'active'
      and h.created_at < (v_now - v_hold_age)
    order by h.created_at asc
    limit v_limit
  ) t;

  -- 2) Active holds where the related ride is already terminal (should have been captured/released)
  select coalesce(jsonb_agg(to_jsonb(t)), '[]'::jsonb)
  into v_active_holds_terminal_ride
  from (
    select
      h.id as hold_id,
      h.user_id,
      h.ride_id,
      h.amount_iqd,
      h.created_at,
      r.status as ride_status,
      r.updated_at as ride_updated_at
    from public.wallet_holds h
    join public.rides r on r.id = h.ride_id
    where h.status = 'active'
      and r.status in ('completed','canceled')
    order by r.updated_at desc
    limit v_limit
  ) t;

  -- 3) Completed rides missing either the rider debit or driver credit entry
  select coalesce(jsonb_agg(to_jsonb(t)), '[]'::jsonb)
  into v_completed_rides_missing_entries
  from (
    select
      r.id as ride_id,
      r.rider_id,
      r.driver_id,
      r.status,
      r.completed_at,
      r.updated_at,
      not exists(
        select 1
        from public.wallet_entries we
        where we.user_id = r.rider_id
          and we.idempotency_key = ('ride:' || r.id::text || ':rider_debit')
      ) as missing_rider_debit,
      not exists(
        select 1
        from public.wallet_entries we
        where we.user_id = r.driver_id
          and we.idempotency_key = ('ride:' || r.id::text || ':driver_credit')
      ) as missing_driver_credit,
      (
        select h.id
        from public.wallet_holds h
        where h.ride_id = r.id
        order by h.created_at desc
        limit 1
      ) as hold_id
    from public.rides r
    where r.status = 'completed'
      and r.completed_at is not null
      and r.completed_at >= (v_now - interval '30 days')
      and (
        not exists(
          select 1
          from public.wallet_entries we
          where we.user_id = r.rider_id
            and we.idempotency_key = ('ride:' || r.id::text || ':rider_debit')
        )
        or not exists(
          select 1
          from public.wallet_entries we
          where we.user_id = r.driver_id
            and we.idempotency_key = ('ride:' || r.id::text || ':driver_credit')
        )
      )
    order by r.completed_at desc
    limit v_limit
  ) t;

  -- 4) held_iqd mismatch vs active holds sum per user (tolerate small drift by requiring exact match)
  select coalesce(jsonb_agg(to_jsonb(t)), '[]'::jsonb)
  into v_held_mismatch
  from (
    with holds as (
      select user_id, coalesce(sum(amount_iqd), 0)::bigint as holds_active
      from public.wallet_holds
      where status = 'active'
      group by user_id
    )
    select
      wa.user_id,
      wa.held_iqd,
      coalesce(h.holds_active, 0) as holds_active,
      (wa.held_iqd - coalesce(h.holds_active, 0)) as diff
    from public.wallet_accounts wa
    left join holds h on h.user_id = wa.user_id
    where wa.held_iqd <> coalesce(h.holds_active, 0)
    order by abs(wa.held_iqd - coalesce(h.holds_active, 0)) desc
    limit v_limit
  ) t;

  -- 5) Succeeded top-ups missing their wallet entry
  select coalesce(jsonb_agg(to_jsonb(t)), '[]'::jsonb)
  into v_topup_succeeded_missing_entry
  from (
    select
      ti.id as intent_id,
      ti.user_id,
      ti.provider_code,
      ti.provider_tx_id,
      ti.amount_iqd,
      ti.bonus_iqd,
      ti.completed_at,
      ti.updated_at
    from public.topup_intents ti
    where ti.status = 'succeeded'
      and not exists (
        select 1
        from public.wallet_entries we
        where we.user_id = ti.user_id
          and we.idempotency_key = ('topup:' || ti.id::text)
      )
    order by ti.updated_at desc
    limit v_limit
  ) t;

  -- 6) Top-ups stuck in created/pending beyond a threshold
  select coalesce(jsonb_agg(to_jsonb(t)), '[]'::jsonb)
  into v_topup_stuck_pending
  from (
    select
      ti.id as intent_id,
      ti.user_id,
      ti.provider_code,
      ti.status,
      ti.provider_tx_id,
      ti.created_at,
      ti.updated_at
    from public.topup_intents ti
    where ti.status in ('created','pending')
      and ti.created_at < (v_now - v_topup_age)
    order by ti.created_at asc
    limit v_limit
  ) t;

  return jsonb_build_object(
    'ok', true,
    'generated_at', v_now,
    'params', jsonb_build_object(
      'limit', v_limit,
      'hold_age_seconds', extract(epoch from v_hold_age)::int,
      'topup_age_seconds', extract(epoch from v_topup_age)::int
    ),
    'summary', jsonb_build_object(
      'accounts_count', v_accounts_count,
      'balance_iqd_sum', v_balance_sum,
      'held_iqd_sum', v_held_sum,
      'active_holds_iqd_sum', v_active_holds_sum,
      'held_minus_active_holds', (v_held_sum - v_active_holds_sum)
    ),
    'issues', jsonb_build_object(
      'active_holds_old', v_active_holds_old,
      'active_holds_terminal_ride', v_active_holds_terminal_ride,
      'completed_rides_missing_entries', v_completed_rides_missing_entries,
      'held_iqd_mismatch', v_held_mismatch,
      'topup_succeeded_missing_entry', v_topup_succeeded_missing_entry,
      'topup_stuck_pending', v_topup_stuck_pending
    )
  );
end;
$$;


ALTER FUNCTION public.admin_wallet_integrity_snapshot(p_limit integer, p_hold_age_seconds integer, p_topup_age_seconds integer) OWNER TO postgres;

--
-- TOC entry 1336 (class 1255 OID 24016)
-- Name: admin_withdraw_approve(uuid, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.admin_withdraw_approve(p_request_id uuid, p_note text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public, extensions'
    AS $$
DECLARE
  r record;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'not_admin';
  END IF;

  SELECT * INTO r
  FROM public.wallet_withdraw_requests
  WHERE id = p_request_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'withdraw_request_not_found';
  END IF;

  IF r.status <> 'requested' THEN
    RAISE EXCEPTION 'invalid_status_transition';
  END IF;

  UPDATE public.wallet_withdraw_requests
  SET status = 'approved',
      note = COALESCE(p_note, note),
      approved_at = now(),
      updated_at = now()
  WHERE id = r.id;

  PERFORM public.notify_user(r.user_id, 'withdraw_approved', 'Withdrawal approved',
    'Your withdrawal request was approved and will be paid soon.',
    jsonb_build_object('request_id', r.id, 'amount_iqd', r.amount_iqd, 'payout_kind', r.payout_kind)
  );
END;
$$;


ALTER FUNCTION public.admin_withdraw_approve(p_request_id uuid, p_note text) OWNER TO postgres;

--
-- TOC entry 1338 (class 1255 OID 24018)
-- Name: admin_withdraw_mark_paid(uuid, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.admin_withdraw_mark_paid(p_request_id uuid, p_payout_reference text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public, extensions'
    AS $$
DECLARE
  r record;
  h record;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'not_admin';
  END IF;

  SELECT * INTO r
  FROM public.wallet_withdraw_requests
  WHERE id = p_request_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'withdraw_request_not_found';
  END IF;

  IF r.status <> 'approved' THEN
    RAISE EXCEPTION 'invalid_status_transition';
  END IF;

  -- lock active hold
  SELECT * INTO h
  FROM public.wallet_holds
  WHERE withdraw_request_id = r.id AND status = 'active'
  ORDER BY created_at DESC
  LIMIT 1
  FOR UPDATE;

  -- lock wallet account
  PERFORM 1 FROM public.wallet_accounts wa WHERE wa.user_id = r.user_id FOR UPDATE;

  UPDATE public.wallet_accounts
  SET held_iqd = GREATEST(held_iqd - r.amount_iqd, 0),
      balance_iqd = balance_iqd - r.amount_iqd,
      updated_at = now()
  WHERE user_id = r.user_id;

  -- ledger entry
  INSERT INTO public.wallet_entries (user_id, delta_iqd, kind, memo, source_type, source_id, metadata, idempotency_key)
  VALUES (
    r.user_id,
    -r.amount_iqd,
    'withdrawal',
    'Driver withdrawal',
    'withdraw',
    r.id,
    jsonb_build_object(
      'payout_kind', r.payout_kind,
      'destination', r.destination,
      'payout_reference', p_payout_reference
    ),
    'withdraw:' || r.id::text
  )
  ON CONFLICT (idempotency_key) DO NOTHING;

  UPDATE public.wallet_holds
  SET status = 'captured', captured_at = now(), updated_at = now()
  WHERE id = h.id AND status = 'active';

  UPDATE public.wallet_withdraw_requests
  SET status = 'paid',
      payout_reference = COALESCE(p_payout_reference, payout_reference),
      paid_at = now(),
      updated_at = now()
  WHERE id = r.id;

  PERFORM public.notify_user(r.user_id, 'withdraw_paid', 'Withdrawal paid',
    CASE WHEN p_payout_reference IS NULL OR p_payout_reference = '' THEN 'Your withdrawal has been paid.'
      ELSE 'Your withdrawal has been paid. Reference: ' || p_payout_reference END,
    jsonb_build_object('request_id', r.id, 'amount_iqd', r.amount_iqd, 'payout_kind', r.payout_kind, 'payout_reference', p_payout_reference)
  );
END;
$$;


ALTER FUNCTION public.admin_withdraw_mark_paid(p_request_id uuid, p_payout_reference text) OWNER TO postgres;

--
-- TOC entry 1337 (class 1255 OID 24017)
-- Name: admin_withdraw_reject(uuid, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.admin_withdraw_reject(p_request_id uuid, p_note text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public, extensions'
    AS $$
DECLARE
  r record;
  h record;
BEGIN
  IF NOT public.is_admin() THEN
    RAISE EXCEPTION 'not_admin';
  END IF;

  SELECT * INTO r
  FROM public.wallet_withdraw_requests
  WHERE id = p_request_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'withdraw_request_not_found';
  END IF;

  IF r.status NOT IN ('requested','approved') THEN
    RAISE EXCEPTION 'invalid_status_transition';
  END IF;

  SELECT * INTO h
  FROM public.wallet_holds
  WHERE withdraw_request_id = r.id AND status = 'active'
  ORDER BY created_at DESC
  LIMIT 1
  FOR UPDATE;

  UPDATE public.wallet_holds
  SET status = 'released', released_at = now(), updated_at = now()
  WHERE id = h.id AND status = 'active';

  UPDATE public.wallet_accounts
  SET held_iqd = GREATEST(held_iqd - r.amount_iqd, 0),
      updated_at = now()
  WHERE user_id = r.user_id;

  UPDATE public.wallet_withdraw_requests
  SET status = 'rejected',
      note = COALESCE(p_note, note),
      rejected_at = now(),
      updated_at = now()
  WHERE id = r.id;

  PERFORM public.notify_user(r.user_id, 'withdraw_rejected', 'Withdrawal rejected',
    COALESCE(p_note, 'Your withdrawal request was rejected and funds were released.'),
    jsonb_build_object('request_id', r.id, 'amount_iqd', r.amount_iqd, 'payout_kind', r.payout_kind)
  );
END;
$$;


ALTER FUNCTION public.admin_withdraw_reject(p_request_id uuid, p_note text) OWNER TO postgres;

--
-- TOC entry 1293 (class 1255 OID 23460)
-- Name: apply_rating_aggregate(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.apply_rating_aggregate() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog'
    AS $$
begin
  if new.ratee_role = 'driver' then
    update public.drivers
      set rating_avg = ((rating_avg * rating_count) + new.rating)::numeric / (rating_count + 1),
          rating_count = rating_count + 1
      where id = new.ratee_id;
  elsif new.ratee_role = 'rider' then
    update public.profiles
      set rating_avg = ((rating_avg * rating_count) + new.rating)::numeric / (rating_count + 1),
          rating_count = rating_count + 1
      where id = new.ratee_id;
  end if;
  return new;
end;
$$;


ALTER FUNCTION public.apply_rating_aggregate() OWNER TO postgres;

--
-- TOC entry 1291 (class 1255 OID 23428)
-- Name: create_receipt_from_payment(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.create_receipt_from_payment() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog'
    AS $$
declare
  v_ride public.rides%rowtype;
  v_base integer;
  v_total integer;
  v_tip integer;
  v_currency text;
begin
  -- Only generate receipt for succeeded payments
  if new.status <> 'succeeded' then
    return new;
  end if;

  select * into v_ride from public.rides where id = new.ride_id;
  if not found then
    return new;
  end if;

  v_currency := coalesce(new.currency, v_ride.currency, 'IQD');
  v_total := greatest(new.amount_iqd, 0);
  v_base := coalesce(v_ride.fare_amount_iqd, v_total);
  v_tip := greatest(v_total - v_base, 0);

  insert into public.ride_receipts (ride_id, base_fare_iqd, tax_iqd, tip_iqd, total_iqd, currency)
  values (new.ride_id, v_base, 0, v_tip, v_total, v_currency)
  on conflict (ride_id) do update
    set base_fare_iqd = excluded.base_fare_iqd,
        tax_iqd = excluded.tax_iqd,
        tip_iqd = excluded.tip_iqd,
        total_iqd = excluded.total_iqd,
        currency = excluded.currency,
        generated_at = now();

  return new;
end;
$$;


ALTER FUNCTION public.create_receipt_from_payment() OWNER TO postgres;

--
-- TOC entry 1294 (class 1255 OID 23509)
-- Name: create_ride_incident(uuid, text, text, public.incident_severity); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.create_ride_incident(p_ride_id uuid, p_category text, p_description text, p_severity public.incident_severity DEFAULT 'low'::public.incident_severity) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog'
    AS $$
declare
  v_uid uuid;
  v_ok boolean;
  v_id uuid;
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'not_authenticated';
  end if;

  select exists(
    select 1 from public.rides r
    where r.id = p_ride_id and (r.rider_id = v_uid or r.driver_id = v_uid)
  ) into v_ok;

  if not v_ok then
    raise exception 'not_allowed';
  end if;

  insert into public.ride_incidents (ride_id, reporter_id, category, description, severity)
  values (p_ride_id, v_uid, left(coalesce(p_category,''), 120), nullif(p_description,''), p_severity)
  returning id into v_id;

  return v_id;
end;
$$;


ALTER FUNCTION public.create_ride_incident(p_ride_id uuid, p_category text, p_description text, p_severity public.incident_severity) OWNER TO postgres;

--
-- TOC entry 1303 (class 1255 OID 23736)
-- Name: dispatch_accept_ride(uuid, uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.dispatch_accept_ride(p_request_id uuid, p_driver_id uuid) RETURNS TABLE(id uuid, request_id uuid, rider_id uuid, driver_id uuid, status public.ride_status, version integer, created_at timestamp with time zone, started_at timestamp with time zone, completed_at timestamp with time zone, fare_amount_iqd integer, currency text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
    AS $$
#variable_conflict use_column
declare
  rr record;
  r record;
  d_status public.driver_status;
  v_hold_id uuid;
begin
  -- Lock request row
  select * into rr
  from public.ride_requests
  where id = p_request_id
  for update;

  if not found then
    raise exception 'ride_request_not_found';
  end if;

  -- If already accepted, return the ride (idempotent) + ensure a hold exists.
  if rr.status = 'accepted' then
    select * into r from public.rides where request_id = rr.id;
    if r.wallet_hold_id is null then
      v_hold_id := public.wallet_hold_upsert_for_ride(r.rider_id, r.id, r.fare_amount_iqd::bigint);
    end if;
    return query select r.id, r.request_id, r.rider_id, r.driver_id, r.status, r.version, r.created_at, r.started_at, r.completed_at, r.fare_amount_iqd, r.currency;
    return;
  end if;

  if rr.status <> 'matched' then
    raise exception 'request_not_matched';
  end if;

  if rr.assigned_driver_id is null or rr.assigned_driver_id <> p_driver_id then
    raise exception 'forbidden';
  end if;

  -- Enforce TTL (driver must accept before match_deadline)
  if rr.match_deadline is not null and rr.match_deadline <= now() then
    -- Mark expired (release trigger will make driver available and clear match fields)
    update public.ride_requests
      set status = 'expired'
    where id = rr.id and status = 'matched';

    raise exception 'match_expired';
  end if;

  -- Ensure driver is currently reserved
  select status into d_status
  from public.drivers
  where id = p_driver_id
  for update;

  if d_status is distinct from 'reserved' then
    raise exception 'driver_not_reserved';
  end if;

  -- Mark accepted
  update public.ride_requests
    set status = 'accepted'
  where id = rr.id and status = 'matched';

  -- Create ride (idempotent)
  insert into public.rides (request_id, rider_id, driver_id, status, version, started_at, completed_at, fare_amount_iqd, currency)
  values (rr.id, rr.rider_id, p_driver_id, 'assigned', 0, null, null, rr.quote_amount_iqd, rr.currency)
  on conflict (request_id) do update
    set driver_id = excluded.driver_id
  returning * into r;

  -- Reserve fare amount from rider wallet (hold)
  v_hold_id := public.wallet_hold_upsert_for_ride(r.rider_id, r.id, r.fare_amount_iqd::bigint);

  -- Driver is now on-trip
  update public.drivers
    set status = 'on_trip'
  where id = p_driver_id;

  -- Event log
  insert into public.ride_events (ride_id, actor_id, actor_type, event_type, payload)
  values (r.id, p_driver_id, 'driver', 'driver_accepted', jsonb_build_object('request_id', rr.id, 'wallet_hold_id', v_hold_id));

  return query select r.id, r.request_id, r.rider_id, r.driver_id, r.status, r.version, r.created_at, r.started_at, r.completed_at, r.fare_amount_iqd, r.currency;
end;
$$;


ALTER FUNCTION public.dispatch_accept_ride(p_request_id uuid, p_driver_id uuid) OWNER TO postgres;

--
-- TOC entry 1306 (class 1255 OID 23747)
-- Name: dispatch_match_ride(uuid, uuid, numeric, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.dispatch_match_ride(p_request_id uuid, p_rider_id uuid, p_radius_m numeric DEFAULT 5000, p_limit_n integer DEFAULT 20, p_match_ttl_seconds integer DEFAULT 120, p_stale_after_seconds integer DEFAULT 30) RETURNS TABLE(id uuid, status public.ride_request_status, assigned_driver_id uuid, match_deadline timestamp with time zone, match_attempts integer, matched_at timestamp with time zone)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions, public'
    AS $$
#variable_conflict use_column
declare
  rr record;
  candidate uuid;
  updated record;
  tried uuid[] := '{}'::uuid[];
  v_balance bigint;
  v_held bigint;
  v_available bigint;
  v_quote bigint;
begin
  select * into rr
  from public.ride_requests as req
  where req.id = p_request_id
  for update;

  if not found then
    raise exception 'ride_request_not_found';
  end if;

  if rr.rider_id <> p_rider_id then
    raise exception 'forbidden';
  end if;

  if rr.status = 'accepted' then
    return query select rr.id, rr.status, rr.assigned_driver_id, rr.match_deadline, rr.match_attempts, rr.matched_at;
    return;
  end if;

  if rr.status = 'matched' and rr.match_deadline is not null and rr.match_deadline <= now() then
    update public.drivers
      set status = 'available'
    where public.drivers.id = rr.assigned_driver_id
      and public.drivers.status = 'reserved';

    update public.ride_requests
      set status = 'expired'
    where public.ride_requests.id = rr.id
      and public.ride_requests.status = 'matched';

    rr.status := 'expired';
  end if;

  if rr.status = 'matched' and (rr.match_deadline is null or rr.match_deadline > now()) then
    return query select rr.id, rr.status, rr.assigned_driver_id, rr.match_deadline, rr.match_attempts, rr.matched_at;
    return;
  end if;

  if rr.status in ('no_driver','expired') then
    update public.ride_requests
      set status = 'requested'
    where public.ride_requests.id = rr.id and public.ride_requests.status in ('no_driver','expired');
    rr.status := 'requested';
  end if;

  if rr.status <> 'requested' then
    return query select rr.id, rr.status, rr.assigned_driver_id, rr.match_deadline, rr.match_attempts, rr.matched_at;
    return;
  end if;

  v_quote := coalesce(rr.quote_amount_iqd, 0)::bigint;
  if v_quote <= 0 then
    v_quote := public.estimate_ride_quote_iqd(rr.pickup_loc, rr.dropoff_loc)::bigint;
    if v_quote <= 0 then
      raise exception 'invalid_quote';
    end if;
  end if;

  insert into public.wallet_accounts(user_id)
  values (rr.rider_id)
  on conflict (user_id) do nothing;

  select balance_iqd, held_iqd
    into v_balance, v_held
  from public.wallet_accounts
  where user_id = rr.rider_id;

  v_available := coalesce(v_balance,0) - coalesce(v_held,0);
  if v_available < v_quote then
    raise exception 'insufficient_wallet_balance';
  end if;

  for i in 1..3 loop
    candidate := null;

    with pickup as (
      select rr.pickup_loc as pickup
    ), candidates as (
      select d.id as driver_id
      from public.drivers d
      join public.driver_locations dl on dl.driver_id = d.id
      cross join pickup
      where d.status = 'available'
        and (array_length(tried, 1) is null or d.id <> all(tried))
        and dl.updated_at >= now() - make_interval(secs => p_stale_after_seconds)
        and extensions.st_dwithin(dl.loc, pickup.pickup, (p_radius_m)::double precision, true)
        and not exists (
          select 1 from public.rides r
          where r.driver_id = d.id
            and r.status in ('assigned','arrived','in_progress')
        )
      order by extensions.st_distance(dl.loc, pickup.pickup)
      limit p_limit_n
    ), locked as (
      select c.driver_id
      from candidates c
      join public.drivers d on d.id = c.driver_id
      where d.status = 'available'
      for update of d skip locked
      limit 1
    )
    select driver_id into candidate from locked;

    exit when candidate is null;

    update public.drivers
      set status = 'reserved'
    where public.drivers.id = candidate and public.drivers.status = 'available';

    if not found then
      tried := array_append(tried, candidate);
      continue;
    end if;

    begin
      update public.ride_requests as req
        set status = 'matched',
            assigned_driver_id = candidate,
            match_attempts = rr.match_attempts + 1,
            match_deadline = now() + make_interval(secs => p_match_ttl_seconds)
      where req.id = rr.id
        and req.status = 'requested'
        and assigned_driver_id is null
      returning req.id, req.status, req.assigned_driver_id, req.match_deadline, req.match_attempts, req.matched_at
        into updated;

      if found then
        return query select updated.id, updated.status, updated.assigned_driver_id, updated.match_deadline, updated.match_attempts, updated.matched_at;
        return;
      end if;
    exception when unique_violation then
      update public.drivers
        set status = 'available'
      where public.drivers.id = candidate and public.drivers.status = 'reserved';

      tried := array_append(tried, candidate);
      continue;
    end;

    update public.drivers
      set status = 'available'
    where public.drivers.id = candidate and public.drivers.status = 'reserved';

    tried := array_append(tried, candidate);
  end loop;

  update public.ride_requests
    set status = 'no_driver',
        match_attempts = rr.match_attempts + 1
  where public.ride_requests.id = rr.id and public.ride_requests.status = 'requested';

  select * into rr from public.ride_requests as req where req.id = rr.id;
  return query select rr.id, rr.status, rr.assigned_driver_id, rr.match_deadline, rr.match_attempts, rr.matched_at;
end;
$$;


ALTER FUNCTION public.dispatch_match_ride(p_request_id uuid, p_rider_id uuid, p_radius_m numeric, p_limit_n integer, p_match_ttl_seconds integer, p_stale_after_seconds integer) OWNER TO postgres;

--
-- TOC entry 1298 (class 1255 OID 23724)
-- Name: ensure_wallet_account(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ensure_wallet_account() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog'
    AS $$
BEGIN
  INSERT INTO public.wallet_accounts(user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.ensure_wallet_account() OWNER TO postgres;

--
-- TOC entry 1286 (class 1255 OID 23295)
-- Name: estimate_ride_quote_iqd(extensions.geography, extensions.geography); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.estimate_ride_quote_iqd(_pickup extensions.geography, _dropoff extensions.geography) RETURNS integer
    LANGUAGE plpgsql STABLE
    SET search_path TO 'pg_catalog, extensions'
    AS $$
declare
  cfg record;
  dist_m double precision;
  dist_km numeric;
  quote integer;
begin
  select currency, base_fare_iqd, per_km_iqd, per_min_iqd, minimum_fare_iqd
    into cfg
  from public.pricing_configs
  where active = true
  order by created_at desc
  limit 1;

  dist_m := extensions.st_distance(_pickup::extensions.geometry, _dropoff::extensions.geometry);
  dist_km := greatest(0, dist_m / 1000.0);

  -- MVP: base + per_km, ignore duration for now
  quote := (cfg.base_fare_iqd + ceil(dist_km * cfg.per_km_iqd))::integer;
  quote := greatest(quote, cfg.minimum_fare_iqd);
  return quote;
end;
$$;


ALTER FUNCTION public.estimate_ride_quote_iqd(_pickup extensions.geography, _dropoff extensions.geography) OWNER TO postgres;

--
-- TOC entry 1284 (class 1255 OID 23093)
-- Name: handle_new_user(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.handle_new_user() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO ''
    AS $$
begin
  insert into public.profiles (id, display_name, phone)
  values (new.id, coalesce(new.raw_user_meta_data->>'display_name', null), new.phone);
  return new;
end;
$$;


ALTER FUNCTION public.handle_new_user() OWNER TO postgres;

--
-- TOC entry 1295 (class 1255 OID 23511)
-- Name: is_admin(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.is_admin() RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
  select coalesce((select p.is_admin from public.profiles p where p.id = auth.uid()), false);
$$;


ALTER FUNCTION public.is_admin() OWNER TO postgres;

--
-- TOC entry 1330 (class 1255 OID 24007)
-- Name: notify_user(uuid, text, text, text, jsonb); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.notify_user(p_user_id uuid, p_kind text, p_title text, p_body text DEFAULT NULL::text, p_data jsonb DEFAULT '{}'::jsonb) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public, extensions'
    AS $$
DECLARE
  v_id uuid;
BEGIN
  INSERT INTO public.user_notifications (user_id, kind, title, body, data)
  VALUES (p_user_id, p_kind, p_title, p_body, COALESCE(p_data, '{}'::jsonb))
  RETURNING id INTO v_id;
  RETURN v_id;
END;
$$;


ALTER FUNCTION public.notify_user(p_user_id uuid, p_kind text, p_title text, p_body text, p_data jsonb) OWNER TO postgres;

--
-- TOC entry 1329 (class 1255 OID 23947)
-- Name: profile_kyc_init(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.profile_kyc_init() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
BEGIN
  INSERT INTO public.profile_kyc (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.profile_kyc_init() OWNER TO postgres;

--
-- TOC entry 1290 (class 1255 OID 23387)
-- Name: rate_limit_consume(text, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.rate_limit_consume(p_key text, p_window_seconds integer, p_limit integer) RETURNS TABLE(allowed boolean, remaining integer, reset_at timestamp with time zone)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog'
    AS $$
declare
  now_ts timestamptz := now();
  epoch bigint := floor(extract(epoch from now_ts));
  start_epoch bigint;
  win_start timestamptz;
  new_count integer;
begin
  if p_window_seconds <= 0 or p_limit <= 0 then
    allowed := true;
    remaining := 0;
    reset_at := now_ts;
    return next;
    return;
  end if;

  start_epoch := (epoch / p_window_seconds) * p_window_seconds;
  win_start := to_timestamp(start_epoch);

  insert into public.api_rate_limits(key, window_start, window_seconds, count)
  values (p_key, win_start, p_window_seconds, 1)
  on conflict (key, window_start, window_seconds)
  do update set count = public.api_rate_limits.count + 1
  returning count into new_count;

  allowed := new_count <= p_limit;
  remaining := greatest(p_limit - new_count, 0);
  reset_at := win_start + make_interval(secs => p_window_seconds);
  return next;
end;
$$;


ALTER FUNCTION public.rate_limit_consume(p_key text, p_window_seconds integer, p_limit integer) OWNER TO postgres;

--
-- TOC entry 1341 (class 1255 OID 24228)
-- Name: redeem_gift_code(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.redeem_gift_code(p_code text) RETURNS public.gift_codes
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public'
    AS $$
DECLARE
  v_uid uuid;
  v_code text;
  v_gift public.gift_codes;
  v_entry_id bigint;
  v_memo text;
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  v_code := upper(trim(coalesce(p_code, '')));
  IF v_code = '' THEN
    RAISE EXCEPTION 'missing_code';
  END IF;

  SELECT * INTO v_gift
  FROM public.gift_codes
  WHERE code = v_code
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'gift_code_not_found' USING errcode = 'P0002';
  END IF;

  IF v_gift.redeemed_at IS NOT NULL THEN
    RAISE EXCEPTION 'gift_code_already_redeemed';
  END IF;

  INSERT INTO public.wallet_accounts(user_id)
  VALUES (v_uid)
  ON CONFLICT (user_id) DO NOTHING;

  v_memo := coalesce(v_gift.memo, 'Gift code');

  UPDATE public.wallet_accounts
  SET balance_iqd = balance_iqd + v_gift.amount_iqd
  WHERE user_id = v_uid;

  INSERT INTO public.wallet_entries (user_id, delta_iqd, kind, memo, source_type, source_id, metadata, idempotency_key)
  VALUES (
    v_uid,
    v_gift.amount_iqd,
    'adjustment',
    v_memo,
    'gift_code',
    NULL,
    jsonb_build_object('code', v_code, 'amount_iqd', v_gift.amount_iqd),
    'gift_code:' || v_code
  )
  RETURNING id INTO v_entry_id;

  UPDATE public.gift_codes
  SET redeemed_by = v_uid,
      redeemed_at = now(),
      redeemed_entry_id = v_entry_id
  WHERE code = v_code
  RETURNING * INTO v_gift;

  RETURN v_gift;
END;
$$;


ALTER FUNCTION public.redeem_gift_code(p_code text) OWNER TO postgres;

--
-- TOC entry 1288 (class 1255 OID 23298)
-- Name: ride_requests_clear_match_fields(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ride_requests_clear_match_fields() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
    AS $$
begin
  if tg_op = 'UPDATE' then
    if new.status in ('cancelled','expired','no_driver') then
      new.assigned_driver_id := null;
      new.match_deadline := null;
    end if;
  end if;
  return new;
end;
$$;


ALTER FUNCTION public.ride_requests_clear_match_fields() OWNER TO postgres;

--
-- TOC entry 1289 (class 1255 OID 23300)
-- Name: ride_requests_release_driver_on_unmatch(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ride_requests_release_driver_on_unmatch() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
    AS $$
begin
  if tg_op = 'UPDATE' then
    if old.status = 'matched'
       and new.status in ('cancelled','expired','no_driver')
       and old.assigned_driver_id is not null then
      update public.drivers
        set status = 'available'
      where id = old.assigned_driver_id
        and status = 'reserved';
    end if;
  end if;
  return null;
end;
$$;


ALTER FUNCTION public.ride_requests_release_driver_on_unmatch() OWNER TO postgres;

--
-- TOC entry 1287 (class 1255 OID 23296)
-- Name: ride_requests_set_quote(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ride_requests_set_quote() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
    AS $$
declare
  cfg record;
begin
  select currency
    into cfg
  from public.pricing_configs
  where active = true
  order by created_at desc
  limit 1;

  if new.currency is null then
    new.currency := coalesce(cfg.currency, 'IQD');
  end if;

  if new.quote_amount_iqd is null then
    new.quote_amount_iqd := public.estimate_ride_quote_iqd(new.pickup_loc, new.dropoff_loc);
  end if;

  return new;
end;
$$;


ALTER FUNCTION public.ride_requests_set_quote() OWNER TO postgres;

--
-- TOC entry 1285 (class 1255 OID 23272)
-- Name: ride_requests_set_status_timestamps(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ride_requests_set_status_timestamps() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog, public'
    AS $$
begin
  if tg_op = 'UPDATE' then
    if new.status = 'matched' and old.status = 'requested' and new.matched_at is null then
      new.matched_at := now();
    end if;

    if new.status = 'accepted' and old.status = 'matched' and new.accepted_at is null then
      new.accepted_at := now();
    end if;

    if new.status = 'cancelled' and old.status in ('requested','matched') and new.cancelled_at is null then
      new.cancelled_at := now();
    end if;
  end if;
  return new;
end;
$$;


ALTER FUNCTION public.ride_requests_set_status_timestamps() OWNER TO postgres;

--
-- TOC entry 1283 (class 1255 OID 23075)
-- Name: set_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog, public'
    AS $$
begin
  new.updated_at = now();
  return new;
end;
$$;


ALTER FUNCTION public.set_updated_at() OWNER TO postgres;

--
-- TOC entry 1342 (class 1255 OID 24237)
-- Name: st_dwithin(extensions.geography, extensions.geography, numeric); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.st_dwithin(extensions.geography, extensions.geography, numeric) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    SET search_path TO 'pg_catalog, public, extensions'
    AS $_$
  SELECT extensions.st_dwithin($1, $2, $3::double precision);
$_$;


ALTER FUNCTION public.st_dwithin(extensions.geography, extensions.geography, numeric) OWNER TO postgres;

--
-- TOC entry 1292 (class 1255 OID 23459)
-- Name: submit_ride_rating(uuid, smallint, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.submit_ride_rating(p_ride_id uuid, p_rating smallint, p_comment text DEFAULT NULL::text) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog'
    AS $$
declare
  v_uid uuid;
  v_ride public.rides%rowtype;
  v_rater_role public.party_role;
  v_ratee_role public.party_role;
  v_ratee_id uuid;
  v_rating_id uuid;
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'not_authenticated';
  end if;

  select * into v_ride
  from public.rides
  where id = p_ride_id
    and status = 'completed'
    and (rider_id = v_uid or driver_id = v_uid);

  if not found then
    raise exception 'not_allowed';
  end if;

  if v_ride.rider_id = v_uid then
    v_rater_role := 'rider';
    v_ratee_role := 'driver';
    v_ratee_id := v_ride.driver_id;
  else
    v_rater_role := 'driver';
    v_ratee_role := 'rider';
    v_ratee_id := v_ride.rider_id;
  end if;

  insert into public.ride_ratings (ride_id, rater_id, ratee_id, rater_role, ratee_role, rating, comment)
  values (p_ride_id, v_uid, v_ratee_id, v_rater_role, v_ratee_role, p_rating, p_comment)
  on conflict (ride_id, rater_id) do nothing;

  select id into v_rating_id
  from public.ride_ratings
  where ride_id = p_ride_id and rater_id = v_uid;

  return v_rating_id;
end;
$$;


ALTER FUNCTION public.submit_ride_rating(p_ride_id uuid, p_rating smallint, p_comment text) OWNER TO postgres;

--
-- TOC entry 395 (class 1259 OID 23200)
-- Name: rides; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rides (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    request_id uuid NOT NULL,
    rider_id uuid DEFAULT auth.uid() NOT NULL,
    driver_id uuid NOT NULL,
    status public.ride_status DEFAULT 'assigned'::public.ride_status NOT NULL,
    version integer DEFAULT 0 NOT NULL,
    started_at timestamp with time zone,
    completed_at timestamp with time zone,
    fare_amount_iqd integer,
    currency text DEFAULT 'IQD'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    paid_at timestamp with time zone,
    payment_intent_id uuid,
    wallet_hold_id uuid
);


ALTER TABLE public.rides OWNER TO postgres;

--
-- TOC entry 1304 (class 1255 OID 23737)
-- Name: transition_ride_v2(uuid, public.ride_status, uuid, public.ride_actor_type, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.transition_ride_v2(p_ride_id uuid, p_to_status public.ride_status, p_actor_id uuid, p_actor_type public.ride_actor_type, p_expected_version integer) RETURNS public.rides
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
    AS $$
declare
  r public.rides;
  v_from public.ride_status;
begin
  select * into r from public.rides where id = p_ride_id for update;
  if not found then
    raise exception 'ride_not_found';
  end if;

  if r.version <> p_expected_version then
    raise exception 'version_mismatch';
  end if;

  v_from := r.status;

  -- Allowed transitions
  if not (
    (v_from = 'assigned' and p_to_status in ('arrived','canceled')) or
    (v_from = 'arrived' and p_to_status in ('in_progress','canceled')) or
    (v_from = 'in_progress' and p_to_status in ('completed','canceled'))
  ) then
    raise exception 'invalid_transition';
  end if;

  update public.rides
    set status = p_to_status,
        version = version + 1,
        started_at = case when p_to_status = 'in_progress' then coalesce(started_at, now()) else started_at end,
        completed_at = case when p_to_status = 'completed' then coalesce(completed_at, now()) else completed_at end
  where id = r.id
  returning * into r;

  insert into public.ride_events (ride_id, actor_id, actor_type, event_type, payload)
  values (r.id, p_actor_id, p_actor_type, 'ride_status_changed',
          jsonb_build_object('from', v_from, 'to', p_to_status));

  if p_to_status in ('completed','canceled') then
    update public.drivers
      set status = 'available'
    where id = r.driver_id;
  end if;

  if p_to_status = 'completed' then
    perform public.wallet_capture_ride_hold(r.id);
  elsif p_to_status = 'canceled' then
    perform public.wallet_release_ride_hold(r.id);
  end if;

  return r;
end;
$$;


ALTER FUNCTION public.transition_ride_v2(p_ride_id uuid, p_to_status public.ride_status, p_actor_id uuid, p_actor_type public.ride_actor_type, p_expected_version integer) OWNER TO postgres;

--
-- TOC entry 1328 (class 1255 OID 23856)
-- Name: try_get_vault_secret(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.try_get_vault_secret(p_name text) RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog'
    AS $$
declare
  v text;
begin
  begin
    execute format('select decrypted_secret from vault.decrypted_secrets where name = %L limit 1', p_name)
      into v;
  exception when undefined_table or invalid_schema_name then
    return null;
  end;
  return v;
end;
$$;


ALTER FUNCTION public.try_get_vault_secret(p_name text) OWNER TO postgres;

--
-- TOC entry 1297 (class 1255 OID 23525)
-- Name: update_receipt_on_refund(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_receipt_on_refund() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog'
    AS $$
declare
  v_total integer;
  v_refund integer;
begin
  -- Only act when a refund is recorded/updated
  if new.refunded_at is null and new.provider_refund_id is null then
    return new;
  end if;

  select rr.total_iqd into v_total
  from public.ride_receipts rr
  where rr.ride_id = new.ride_id;

  if v_total is null then
    return new;
  end if;

  v_refund := greatest(coalesce(new.refund_amount_iqd, 0), 0);

  update public.ride_receipts
  set
    refunded_iqd = greatest(refunded_iqd, v_refund),
    refunded_at = coalesce(new.refunded_at, refunded_at, now()),
    receipt_status = case
      when v_refund >= v_total then 'refunded'
      when v_refund > 0 then 'partially_refunded'
      else receipt_status
    end
  where ride_id = new.ride_id;

  return new;
end;
$$;


ALTER FUNCTION public.update_receipt_on_refund() OWNER TO postgres;

--
-- TOC entry 1332 (class 1255 OID 24009)
-- Name: user_notifications_mark_all_read(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.user_notifications_mark_all_read() RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
DECLARE
  v_uid uuid;
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  UPDATE public.user_notifications
  SET read_at = COALESCE(read_at, now())
  WHERE user_id = v_uid AND read_at IS NULL;
END;
$$;


ALTER FUNCTION public.user_notifications_mark_all_read() OWNER TO postgres;

--
-- TOC entry 1331 (class 1255 OID 24008)
-- Name: user_notifications_mark_read(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.user_notifications_mark_read(p_notification_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
DECLARE
  v_uid uuid;
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  UPDATE public.user_notifications
  SET read_at = COALESCE(read_at, now())
  WHERE id = p_notification_id AND user_id = v_uid;
END;
$$;


ALTER FUNCTION public.user_notifications_mark_read(p_notification_id uuid) OWNER TO postgres;

--
-- TOC entry 1335 (class 1255 OID 24015)
-- Name: wallet_cancel_withdraw(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.wallet_cancel_withdraw(p_request_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public, extensions'
    AS $$
DECLARE
  v_uid uuid;
  r record;
  h record;
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  SELECT * INTO r
  FROM public.wallet_withdraw_requests
  WHERE id = p_request_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'withdraw_request_not_found';
  END IF;

  IF r.user_id <> v_uid THEN
    RAISE EXCEPTION 'forbidden';
  END IF;

  IF r.status <> 'requested' THEN
    RAISE EXCEPTION 'withdraw_not_cancellable';
  END IF;

  SELECT * INTO h
  FROM public.wallet_holds
  WHERE withdraw_request_id = r.id AND status = 'active'
  ORDER BY created_at DESC
  LIMIT 1
  FOR UPDATE;

  UPDATE public.wallet_holds
  SET status = 'released', released_at = now(), updated_at = now()
  WHERE id = h.id AND status = 'active';

  UPDATE public.wallet_accounts
  SET held_iqd = GREATEST(held_iqd - r.amount_iqd, 0),
      updated_at = now()
  WHERE user_id = v_uid;

  UPDATE public.wallet_withdraw_requests
  SET status = 'cancelled', cancelled_at = now(), updated_at = now()
  WHERE id = r.id;

  PERFORM public.notify_user(v_uid, 'withdraw_cancelled', 'Withdrawal cancelled',
    'Your withdrawal request was cancelled and funds were released.',
    jsonb_build_object('request_id', r.id, 'amount_iqd', r.amount_iqd, 'payout_kind', r.payout_kind)
  );
END;
$$;


ALTER FUNCTION public.wallet_cancel_withdraw(p_request_id uuid) OWNER TO postgres;

--
-- TOC entry 1307 (class 1255 OID 23754)
-- Name: wallet_capture_ride_hold(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.wallet_capture_ride_hold(p_ride_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions, public'
    AS $$
declare
  r record;
  h record;
  v_amount bigint;
  v_balance bigint;
  v_held bigint;
begin
  -- Lock ride
  select * into r
  from public.rides
  where id = p_ride_id
  for update;

  if not found then
    raise exception 'ride_not_found';
  end if;

  -- Lock hold
  select * into h
  from public.wallet_holds
  where ride_id = p_ride_id
  for update;

  if not found then
    raise exception 'hold_not_found';
  end if;

  if h.status = 'captured' then
    return; -- idempotent
  end if;

  if h.status <> 'active' then
    raise exception 'hold_not_active';
  end if;

  v_amount := h.amount_iqd;
  if v_amount <= 0 then
    raise exception 'invalid_amount';
  end if;

  -- Validate wallet state
  select balance_iqd, held_iqd
    into v_balance, v_held
  from public.wallet_accounts
  where user_id = r.rider_id
  for update;

  if not found then
    raise exception 'wallet_missing';
  end if;

  if coalesce(v_held,0) < v_amount then
    raise exception 'wallet_insufficient_held';
  end if;

  if coalesce(v_balance,0) < v_amount then
    raise exception 'wallet_insufficient_balance';
  end if;

  -- Debit rider
  update public.wallet_accounts
    set held_iqd = held_iqd - v_amount,
        balance_iqd = balance_iqd - v_amount,
        updated_at = now()
  where user_id = r.rider_id;

  insert into public.wallet_entries (
    user_id, delta_iqd, kind, memo, source_type, source_id, metadata, idempotency_key
  )
  values (
    r.rider_id, -v_amount, 'ride_fare', 'Ride fare', 'ride', r.id,
    jsonb_build_object('ride_id', r.id, 'driver_id', r.driver_id),
    'ride:' || r.id::text || ':rider_debit'
  )
  on conflict (user_id, idempotency_key) where idempotency_key is not null do nothing;

  -- Credit driver
  insert into public.wallet_accounts(user_id)
  values (r.driver_id)
  on conflict (user_id) do nothing;

  update public.wallet_accounts
    set balance_iqd = balance_iqd + v_amount,
        updated_at = now()
  where user_id = r.driver_id;

  insert into public.wallet_entries (
    user_id, delta_iqd, kind, memo, source_type, source_id, metadata, idempotency_key
  )
  values (
    r.driver_id, v_amount, 'ride_fare', 'Ride payout', 'ride', r.id,
    jsonb_build_object('ride_id', r.id, 'rider_id', r.rider_id),
    'ride:' || r.id::text || ':driver_credit'
  )
  on conflict (user_id, idempotency_key) where idempotency_key is not null do nothing;

  -- Mark hold captured
  update public.wallet_holds
    set status = 'captured', captured_at = now(), updated_at = now()
  where id = h.id and status = 'active';

  -- Synthetic payment row (requires partial unique index on payments(ride_id) where status='succeeded')
  insert into public.payments (ride_id, provider, provider_ref, amount_iqd, currency, status)
  values (r.id, 'wallet', h.id::text, v_amount::integer, 'IQD', 'succeeded')
  on conflict (ride_id) where status = 'succeeded' do nothing;

  update public.rides
    set paid_at = coalesce(paid_at, now()),
        payment_intent_id = null
  where id = r.id;
end;
$$;


ALTER FUNCTION public.wallet_capture_ride_hold(p_ride_id uuid) OWNER TO postgres;

--
-- TOC entry 412 (class 1259 OID 23668)
-- Name: topup_intents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.topup_intents (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    provider_code text NOT NULL,
    package_id uuid,
    amount_iqd bigint NOT NULL,
    bonus_iqd bigint DEFAULT 0 NOT NULL,
    status public.topup_status DEFAULT 'created'::public.topup_status NOT NULL,
    idempotency_key text,
    provider_tx_id text,
    provider_payload jsonb DEFAULT '{}'::jsonb NOT NULL,
    failure_reason text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    completed_at timestamp with time zone,
    CONSTRAINT topup_intents_amount_iqd_check CHECK ((amount_iqd > 0)),
    CONSTRAINT topup_intents_bonus_iqd_check CHECK ((bonus_iqd >= 0))
);


ALTER TABLE public.topup_intents OWNER TO postgres;

--
-- TOC entry 1300 (class 1255 OID 23727)
-- Name: wallet_fail_topup(uuid, text, jsonb); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.wallet_fail_topup(p_intent_id uuid, p_failure_reason text, p_provider_payload jsonb DEFAULT '{}'::jsonb) RETURNS public.topup_intents
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog'
    AS $$
DECLARE
  v_intent public.topup_intents;
BEGIN
  SELECT * INTO v_intent
  FROM public.topup_intents
  WHERE id = p_intent_id
  FOR UPDATE;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'topup_intent_not_found' USING ERRCODE = 'P0002';
  END IF;

  IF v_intent.status IN ('failed','succeeded') THEN
    RETURN v_intent;
  END IF;

  UPDATE public.topup_intents
  SET
    status = 'failed',
    failure_reason = p_failure_reason,
    provider_payload = COALESCE(p_provider_payload, provider_payload),
    completed_at = now(),
    updated_at = now()
  WHERE id = p_intent_id;

  RETURN (SELECT ti FROM public.topup_intents ti WHERE ti.id = p_intent_id);
END;
$$;


ALTER FUNCTION public.wallet_fail_topup(p_intent_id uuid, p_failure_reason text, p_provider_payload jsonb) OWNER TO postgres;

--
-- TOC entry 1305 (class 1255 OID 23741)
-- Name: wallet_finalize_topup(uuid, text, jsonb); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.wallet_finalize_topup(p_intent_id uuid, p_provider_tx_id text, p_provider_payload jsonb DEFAULT '{}'::jsonb) RETURNS public.topup_intents
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog'
    AS $$
declare
  v_intent public.topup_intents;
  v_total_iqd bigint;
begin
  select * into v_intent
  from public.topup_intents
  where id = p_intent_id
  for update;

  if not found then
    raise exception 'topup_intent_not_found' using errcode = 'P0002';
  end if;

  if v_intent.status = 'succeeded' then
    return v_intent;
  end if;

  v_total_iqd := v_intent.amount_iqd + v_intent.bonus_iqd;

  update public.topup_intents
  set
    status = 'succeeded',
    provider_tx_id = coalesce(p_provider_tx_id, provider_tx_id),
    provider_payload = coalesce(p_provider_payload, provider_payload),
    completed_at = now(),
    updated_at = now()
  where id = p_intent_id;

  insert into public.wallet_accounts(user_id)
  values (v_intent.user_id)
  on conflict (user_id) do nothing;

  update public.wallet_accounts
  set
    balance_iqd = balance_iqd + v_total_iqd,
    updated_at = now()
  where user_id = v_intent.user_id;

  insert into public.wallet_entries(
    user_id,
    kind,
    delta_iqd,
    memo,
    source_type,
    source_id,
    metadata,
    idempotency_key
  )
  values (
    v_intent.user_id,
    'topup',
    v_total_iqd,
    'Top-up',
    'topup_intent',
    v_intent.id,
    jsonb_build_object('provider', v_intent.provider_code, 'provider_tx_id', p_provider_tx_id),
    'topup:' || v_intent.id::text
  )
  on conflict (user_id, idempotency_key) where idempotency_key is not null do nothing;

  return (select ti from public.topup_intents ti where ti.id = p_intent_id);
end;
$$;


ALTER FUNCTION public.wallet_finalize_topup(p_intent_id uuid, p_provider_tx_id text, p_provider_payload jsonb) OWNER TO postgres;

--
-- TOC entry 406 (class 1259 OID 23567)
-- Name: wallet_accounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.wallet_accounts (
    user_id uuid NOT NULL,
    balance_iqd bigint DEFAULT 0 NOT NULL,
    held_iqd bigint DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT wallet_accounts_balance_iqd_check CHECK ((balance_iqd >= 0)),
    CONSTRAINT wallet_accounts_held_iqd_check CHECK ((held_iqd >= 0))
);


ALTER TABLE public.wallet_accounts OWNER TO postgres;

--
-- TOC entry 1299 (class 1255 OID 23726)
-- Name: wallet_get_my_account(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.wallet_get_my_account() RETURNS public.wallet_accounts
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
    AS $$
declare
  v_user uuid;
  r public.wallet_accounts;
begin
  v_user := auth.uid();
  if v_user is null then
    raise exception 'not_authenticated';
  end if;

  select * into r
  from public.wallet_accounts
  where user_id = v_user;

  if not found then
    insert into public.wallet_accounts (user_id, balance_iqd)
    values (v_user, 0)
    returning * into r;
  end if;

  return r;
end;
$$;


ALTER FUNCTION public.wallet_get_my_account() OWNER TO postgres;

--
-- TOC entry 1301 (class 1255 OID 23734)
-- Name: wallet_hold_upsert_for_ride(uuid, uuid, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.wallet_hold_upsert_for_ride(p_user_id uuid, p_ride_id uuid, p_amount_iqd bigint) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
    AS $$
declare
  v_hold_id uuid;
  v_balance bigint;
  v_held bigint;
  v_available bigint;
  v_inserted boolean := false;
begin
  if p_amount_iqd <= 0 then
    raise exception 'invalid_amount';
  end if;

  -- Ensure wallet exists
  insert into public.wallet_accounts(user_id)
  values (p_user_id)
  on conflict (user_id) do nothing;

  -- Lock wallet row
  select balance_iqd, held_iqd
    into v_balance, v_held
  from public.wallet_accounts
  where user_id = p_user_id
  for update;

  v_available := coalesce(v_balance,0) - coalesce(v_held,0);
  if v_available < p_amount_iqd then
    raise exception 'insufficient_wallet_balance';
  end if;

  -- If already active hold exists, return it.
  select id into v_hold_id
  from public.wallet_holds
  where ride_id = p_ride_id and status = 'active'
  for update;

  if v_hold_id is null then
    begin
      insert into public.wallet_holds(user_id, ride_id, amount_iqd, status)
      values (p_user_id, p_ride_id, p_amount_iqd, 'active')
      returning id into v_hold_id;
      v_inserted := true;
    exception when unique_violation then
      select id into v_hold_id
      from public.wallet_holds
      where ride_id = p_ride_id and status = 'active'
      for update;
      v_inserted := false;
    end;
  end if;

  -- Only adjust held_iqd when we created the hold.
  if v_inserted then
    update public.wallet_accounts
      set held_iqd = held_iqd + p_amount_iqd,
          updated_at = now()
    where user_id = p_user_id;

    update public.rides
      set wallet_hold_id = v_hold_id
    where id = p_ride_id;
  end if;

  return v_hold_id;
end;
$$;


ALTER FUNCTION public.wallet_hold_upsert_for_ride(p_user_id uuid, p_ride_id uuid, p_amount_iqd bigint) OWNER TO postgres;

--
-- TOC entry 1302 (class 1255 OID 23735)
-- Name: wallet_release_ride_hold(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.wallet_release_ride_hold(p_ride_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
    AS $$
declare
  h record;
begin
  select * into h
  from public.wallet_holds
  where ride_id = p_ride_id and status = 'active'
  for update;

  if not found then
    return;
  end if;

  update public.wallet_holds
    set status = 'released', released_at = now(), updated_at = now()
  where id = h.id and status = 'active';

  update public.wallet_accounts
    set held_iqd = greatest(0, held_iqd - h.amount_iqd),
        updated_at = now()
  where user_id = h.user_id;
end;
$$;


ALTER FUNCTION public.wallet_release_ride_hold(p_ride_id uuid) OWNER TO postgres;

--
-- TOC entry 1334 (class 1255 OID 24011)
-- Name: wallet_request_withdraw(bigint, public.withdraw_payout_kind, jsonb, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.wallet_request_withdraw(p_amount_iqd bigint, p_payout_kind public.withdraw_payout_kind, p_destination jsonb DEFAULT '{}'::jsonb, p_idempotency_key text DEFAULT NULL::text) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public, extensions'
    AS $$
DECLARE
  v_uid uuid;
  v_req_id uuid;
  v_available bigint;
  v_policy record;
  v_today date;
  v_day_sum bigint;
  v_day_count integer;
  v_driver record;
  v_kyc public.kyc_status;
BEGIN
  v_uid := auth.uid();
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'not_authenticated';
  END IF;

  -- payout method enabled?
  IF NOT EXISTS (
    SELECT 1 FROM public.wallet_withdraw_payout_methods m
    WHERE m.payout_kind = p_payout_kind AND m.enabled = true
  ) THEN
    RAISE EXCEPTION 'payout_method_disabled';
  END IF;

  -- policy (single row)
  SELECT * INTO v_policy FROM public.wallet_withdrawal_policy WHERE id = 1;

  IF p_amount_iqd IS NULL OR p_amount_iqd <= 0 THEN
    RAISE EXCEPTION 'invalid_amount';
  END IF;
  IF p_amount_iqd < v_policy.min_amount_iqd THEN
    RAISE EXCEPTION 'below_min_withdrawal';
  END IF;
  IF p_amount_iqd > v_policy.max_amount_iqd THEN
    RAISE EXCEPTION 'above_max_withdrawal';
  END IF;

  -- only drivers can withdraw + eligibility rules
  SELECT d.status, d.trips_count INTO v_driver
  FROM public.drivers d
  WHERE d.id = v_uid;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'not_driver';
  END IF;

  IF v_policy.require_driver_not_suspended AND v_driver.status = 'suspended' THEN
    RAISE EXCEPTION 'driver_suspended';
  END IF;

  IF v_driver.trips_count < v_policy.min_trips_count THEN
    RAISE EXCEPTION 'driver_not_eligible_trips';
  END IF;

  IF v_policy.require_kyc THEN
    SELECT pk.status INTO v_kyc
    FROM public.profile_kyc pk
    WHERE pk.user_id = v_uid;
    IF coalesce(v_kyc, 'unverified') <> 'verified' THEN
      RAISE EXCEPTION 'kyc_required';
    END IF;
  END IF;

  -- destination validation
  PERFORM public.wallet_validate_withdraw_destination(p_payout_kind, COALESCE(p_destination, '{}'::jsonb));

  -- daily caps (based on Asia/Baghdad day boundary)
  v_today := (timezone('Asia/Baghdad', now()))::date;
  SELECT
    COALESCE(sum(w.amount_iqd), 0)::bigint,
    COALESCE(count(*), 0)::int
  INTO v_day_sum, v_day_count
  FROM public.wallet_withdraw_requests w
  WHERE w.user_id = v_uid
    AND w.status NOT IN ('rejected','cancelled')
    AND (timezone('Asia/Baghdad', w.created_at))::date = v_today;

  IF (v_day_count + 1) > v_policy.daily_cap_count THEN
    RAISE EXCEPTION 'daily_withdraw_count_cap';
  END IF;
  IF (v_day_sum + p_amount_iqd) > v_policy.daily_cap_amount_iqd THEN
    RAISE EXCEPTION 'daily_withdraw_amount_cap';
  END IF;

  -- lock wallet account row
  PERFORM 1 FROM public.wallet_accounts wa WHERE wa.user_id = v_uid FOR UPDATE;
  IF NOT FOUND THEN
    INSERT INTO public.wallet_accounts (user_id, balance_iqd, held_iqd)
    VALUES (v_uid, 0, 0)
    ON CONFLICT (user_id) DO NOTHING;
  END IF;

  SELECT (wa.balance_iqd - wa.held_iqd) INTO v_available
  FROM public.wallet_accounts wa
  WHERE wa.user_id = v_uid
  FOR UPDATE;

  IF v_available IS NULL THEN
    RAISE EXCEPTION 'wallet_account_missing';
  END IF;

  IF v_available < p_amount_iqd THEN
    RAISE EXCEPTION 'insufficient_wallet_balance';
  END IF;

  -- idempotency
  IF p_idempotency_key IS NOT NULL THEN
    SELECT id INTO v_req_id
    FROM public.wallet_withdraw_requests
    WHERE user_id = v_uid AND idempotency_key = p_idempotency_key
    LIMIT 1;

    IF v_req_id IS NOT NULL THEN
      RETURN v_req_id;
    END IF;
  END IF;

  INSERT INTO public.wallet_withdraw_requests (user_id, amount_iqd, payout_kind, destination, idempotency_key)
  VALUES (v_uid, p_amount_iqd, p_payout_kind, COALESCE(p_destination, '{}'::jsonb), p_idempotency_key)
  RETURNING id INTO v_req_id;

  -- create hold
  INSERT INTO public.wallet_holds (user_id, kind, withdraw_request_id, amount_iqd, status, reason, created_at, updated_at)
  VALUES (v_uid, 'withdraw', v_req_id, p_amount_iqd, 'active', 'Withdraw request', now(), now());

  UPDATE public.wallet_accounts
  SET held_iqd = held_iqd + p_amount_iqd,
      updated_at = now()
  WHERE user_id = v_uid;

  RETURN v_req_id;
END;
$$;


ALTER FUNCTION public.wallet_request_withdraw(p_amount_iqd bigint, p_payout_kind public.withdraw_payout_kind, p_destination jsonb, p_idempotency_key text) OWNER TO postgres;

--
-- TOC entry 1333 (class 1255 OID 24010)
-- Name: wallet_validate_withdraw_destination(public.withdraw_payout_kind, jsonb); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.wallet_validate_withdraw_destination(p_payout_kind public.withdraw_payout_kind, p_destination jsonb) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $_$
DECLARE
  v_wallet text;
  v_card text;
  v_account text;
BEGIN
  IF p_payout_kind = 'zaincash' THEN
    v_wallet := trim(coalesce(p_destination->>'wallet_number', ''));
    IF v_wallet = '' THEN
      RAISE EXCEPTION 'missing_destination_wallet_number';
    END IF;
    -- Iraq mobile format: allow 07XXXXXXXXX, 7XXXXXXXXX, 9647XXXXXXXXX, +9647XXXXXXXXX
    IF v_wallet !~ '^(\+?964)?0?7\d{9}$' THEN
      RAISE EXCEPTION 'invalid_wallet_number_format';
    END IF;
  ELSIF p_payout_kind = 'qicard' THEN
    v_card := regexp_replace(trim(coalesce(p_destination->>'card_number', '')), '\s+', '', 'g');
    IF v_card = '' THEN
      RAISE EXCEPTION 'missing_destination_card_number';
    END IF;
    -- QiCard numbers vary by issuer; enforce digits-only with a safe length range.
    IF v_card !~ '^\d{12,19}$' THEN
      RAISE EXCEPTION 'invalid_card_number_format';
    END IF;
  ELSIF p_payout_kind = 'asiapay' THEN
    v_account := trim(coalesce(p_destination->>'account', coalesce(p_destination->>'wallet_number', '')));
    IF v_account = '' THEN
      RAISE EXCEPTION 'missing_destination_account';
    END IF;
    IF length(v_account) < 3 OR length(v_account) > 64 THEN
      RAISE EXCEPTION 'invalid_account_format';
    END IF;
  ELSE
    RAISE EXCEPTION 'invalid_payout_kind';
  END IF;
END;
$_$;


ALTER FUNCTION public.wallet_validate_withdraw_destination(p_payout_kind public.withdraw_payout_kind, p_destination jsonb) OWNER TO postgres;

--
-- TOC entry 524 (class 1255 OID 17157)
-- Name: apply_rls(jsonb, integer); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer DEFAULT (1024 * 1024)) RETURNS SETOF realtime.wal_rls
    LANGUAGE plpgsql
    AS $$
declare
-- Regclass of the table e.g. public.notes
entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

-- I, U, D, T: insert, update ...
action realtime.action = (
    case wal ->> 'action'
        when 'I' then 'INSERT'
        when 'U' then 'UPDATE'
        when 'D' then 'DELETE'
        else 'ERROR'
    end
);

-- Is row level security enabled for the table
is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

subscriptions realtime.subscription[] = array_agg(subs)
    from
        realtime.subscription subs
    where
        subs.entity = entity_;

-- Subscription vars
roles regrole[] = array_agg(distinct us.claims_role::text)
    from
        unnest(subscriptions) us;

working_role regrole;
claimed_role regrole;
claims jsonb;

subscription_id uuid;
subscription_has_access bool;
visible_to_subscription_ids uuid[] = '{}';

-- structured info for wal's columns
columns realtime.wal_column[];
-- previous identity values for update/delete
old_columns realtime.wal_column[];

error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

-- Primary jsonb output for record
output jsonb;

begin
perform set_config('role', null, true);

columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'columns') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

old_columns =
    array_agg(
        (
            x->>'name',
            x->>'type',
            x->>'typeoid',
            realtime.cast(
                (x->'value') #>> '{}',
                coalesce(
                    (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                    (x->>'type')::regtype
                )
            ),
            (pks ->> 'name') is not null,
            true
        )::realtime.wal_column
    )
    from
        jsonb_array_elements(wal -> 'identity') x
        left join jsonb_array_elements(wal -> 'pk') pks
            on (x ->> 'name') = (pks ->> 'name');

for working_role in select * from unnest(roles) loop

    -- Update `is_selectable` for columns and old_columns
    columns =
        array_agg(
            (
                c.name,
                c.type_name,
                c.type_oid,
                c.value,
                c.is_pkey,
                pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
            )::realtime.wal_column
        )
        from
            unnest(columns) c;

    old_columns =
            array_agg(
                (
                    c.name,
                    c.type_name,
                    c.type_oid,
                    c.value,
                    c.is_pkey,
                    pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                )::realtime.wal_column
            )
            from
                unnest(old_columns) c;

    if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            -- subscriptions is already filtered by entity
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 400: Bad Request, no primary key']
        )::realtime.wal_rls;

    -- The claims role does not have SELECT permission to the primary key of entity
    elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
        return next (
            jsonb_build_object(
                'schema', wal ->> 'schema',
                'table', wal ->> 'table',
                'type', action
            ),
            is_rls_enabled,
            (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
            array['Error 401: Unauthorized']
        )::realtime.wal_rls;

    else
        output = jsonb_build_object(
            'schema', wal ->> 'schema',
            'table', wal ->> 'table',
            'type', action,
            'commit_timestamp', to_char(
                ((wal ->> 'timestamp')::timestamptz at time zone 'utc'),
                'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"'
            ),
            'columns', (
                select
                    jsonb_agg(
                        jsonb_build_object(
                            'name', pa.attname,
                            'type', pt.typname
                        )
                        order by pa.attnum asc
                    )
                from
                    pg_attribute pa
                    join pg_type pt
                        on pa.atttypid = pt.oid
                where
                    attrelid = entity_
                    and attnum > 0
                    and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
            )
        )
        -- Add "record" key for insert and update
        || case
            when action in ('INSERT', 'UPDATE') then
                jsonb_build_object(
                    'record',
                    (
                        select
                            jsonb_object_agg(
                                -- if unchanged toast, get column name and value from old record
                                coalesce((c).name, (oc).name),
                                case
                                    when (c).name is null then (oc).value
                                    else (c).value
                                end
                            )
                        from
                            unnest(columns) c
                            full outer join unnest(old_columns) oc
                                on (c).name = (oc).name
                        where
                            coalesce((c).is_selectable, (oc).is_selectable)
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                    )
                )
            else '{}'::jsonb
        end
        -- Add "old_record" key for update and delete
        || case
            when action = 'UPDATE' then
                jsonb_build_object(
                        'old_record',
                        (
                            select jsonb_object_agg((c).name, (c).value)
                            from unnest(old_columns) c
                            where
                                (c).is_selectable
                                and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                        )
                    )
            when action = 'DELETE' then
                jsonb_build_object(
                    'old_record',
                    (
                        select jsonb_object_agg((c).name, (c).value)
                        from unnest(old_columns) c
                        where
                            (c).is_selectable
                            and ( not error_record_exceeds_max_size or (octet_length((c).value::text) <= 64))
                            and ( not is_rls_enabled or (c).is_pkey ) -- if RLS enabled, we can't secure deletes so filter to pkey
                    )
                )
            else '{}'::jsonb
        end;

        -- Create the prepared statement
        if is_rls_enabled and action <> 'DELETE' then
            if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                deallocate walrus_rls_stmt;
            end if;
            execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
        end if;

        visible_to_subscription_ids = '{}';

        for subscription_id, claims in (
                select
                    subs.subscription_id,
                    subs.claims
                from
                    unnest(subscriptions) subs
                where
                    subs.entity = entity_
                    and subs.claims_role = working_role
                    and (
                        realtime.is_visible_through_filters(columns, subs.filters)
                        or (
                          action = 'DELETE'
                          and realtime.is_visible_through_filters(old_columns, subs.filters)
                        )
                    )
        ) loop

            if not is_rls_enabled or action = 'DELETE' then
                visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
            else
                -- Check if RLS allows the role to see the record
                perform
                    -- Trim leading and trailing quotes from working_role because set_config
                    -- doesn't recognize the role as valid if they are included
                    set_config('role', trim(both '"' from working_role::text), true),
                    set_config('request.jwt.claims', claims::text, true);

                execute 'execute walrus_rls_stmt' into subscription_has_access;

                if subscription_has_access then
                    visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
                end if;
            end if;
        end loop;

        perform set_config('role', null, true);

        return next (
            output,
            is_rls_enabled,
            visible_to_subscription_ids,
            case
                when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                else '{}'
            end
        )::realtime.wal_rls;

    end if;
end loop;

perform set_config('role', null, true);
end;
$$;


ALTER FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) OWNER TO supabase_admin;

--
-- TOC entry 530 (class 1255 OID 17236)
-- Name: broadcast_changes(text, text, text, text, text, record, record, text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text DEFAULT 'ROW'::text) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
    -- Declare a variable to hold the JSONB representation of the row
    row_data jsonb := '{}'::jsonb;
BEGIN
    IF level = 'STATEMENT' THEN
        RAISE EXCEPTION 'function can only be triggered for each row, not for each statement';
    END IF;
    -- Check the operation type and handle accordingly
    IF operation = 'INSERT' OR operation = 'UPDATE' OR operation = 'DELETE' THEN
        row_data := jsonb_build_object('old_record', OLD, 'record', NEW, 'operation', operation, 'table', table_name, 'schema', table_schema);
        PERFORM realtime.send (row_data, event_name, topic_name);
    ELSE
        RAISE EXCEPTION 'Unexpected operation type: %', operation;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Failed to process the row: %', SQLERRM;
END;

$$;


ALTER FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) OWNER TO supabase_admin;

--
-- TOC entry 526 (class 1255 OID 17169)
-- Name: build_prepared_statement_sql(text, regclass, realtime.wal_column[]); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) RETURNS text
    LANGUAGE sql
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;


ALTER FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) OWNER TO supabase_admin;

--
-- TOC entry 522 (class 1255 OID 17119)
-- Name: cast(text, regtype); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime."cast"(val text, type_ regtype) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    declare
      res jsonb;
    begin
      execute format('select to_jsonb(%L::'|| type_::text || ')', val)  into res;
      return res;
    end
    $$;


ALTER FUNCTION realtime."cast"(val text, type_ regtype) OWNER TO supabase_admin;

--
-- TOC entry 521 (class 1255 OID 17114)
-- Name: check_equality_op(realtime.equality_op, regtype, text, text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
      /*
      Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
      */
      declare
          op_symbol text = (
              case
                  when op = 'eq' then '='
                  when op = 'neq' then '!='
                  when op = 'lt' then '<'
                  when op = 'lte' then '<='
                  when op = 'gt' then '>'
                  when op = 'gte' then '>='
                  when op = 'in' then '= any'
                  else 'UNKNOWN OP'
              end
          );
          res boolean;
      begin
          execute format(
              'select %L::'|| type_::text || ' ' || op_symbol
              || ' ( %L::'
              || (
                  case
                      when op = 'in' then type_::text || '[]'
                      else type_::text end
              )
              || ')', val_1, val_2) into res;
          return res;
      end;
      $$;


ALTER FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) OWNER TO supabase_admin;

--
-- TOC entry 525 (class 1255 OID 17165)
-- Name: is_visible_through_filters(realtime.wal_column[], realtime.user_defined_filter[]); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$
    /*
    Should the record be visible (true) or filtered out (false) after *filters* are applied
    */
        select
            -- Default to allowed when no filters present
            $2 is null -- no filters. this should not happen because subscriptions has a default
            or array_length($2, 1) is null -- array length of an empty array is null
            or bool_and(
                coalesce(
                    realtime.check_equality_op(
                        op:=f.op,
                        type_:=coalesce(
                            col.type_oid::regtype, -- null when wal2json version <= 2.4
                            col.type_name::regtype
                        ),
                        -- cast jsonb to text
                        val_1:=col.value #>> '{}',
                        val_2:=f.value
                    ),
                    false -- if null, filter does not match
                )
            )
        from
            unnest(filters) f
            join unnest(columns) col
                on f.column_name = col.name;
    $_$;


ALTER FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) OWNER TO supabase_admin;

--
-- TOC entry 527 (class 1255 OID 17176)
-- Name: list_changes(name, name, integer, integer); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) RETURNS SETOF realtime.wal_rls
    LANGUAGE sql
    SET log_min_messages TO 'fatal'
    AS $$
      with pub as (
        select
          concat_ws(
            ',',
            case when bool_or(pubinsert) then 'insert' else null end,
            case when bool_or(pubupdate) then 'update' else null end,
            case when bool_or(pubdelete) then 'delete' else null end
          ) as w2j_actions,
          coalesce(
            string_agg(
              realtime.quote_wal2json(format('%I.%I', schemaname, tablename)::regclass),
              ','
            ) filter (where ppt.tablename is not null and ppt.tablename not like '% %'),
            ''
          ) w2j_add_tables
        from
          pg_publication pp
          left join pg_publication_tables ppt
            on pp.pubname = ppt.pubname
        where
          pp.pubname = publication
        group by
          pp.pubname
        limit 1
      ),
      w2j as (
        select
          x.*, pub.w2j_add_tables
        from
          pub,
          pg_logical_slot_get_changes(
            slot_name, null, max_changes,
            'include-pk', 'true',
            'include-transaction', 'false',
            'include-timestamp', 'true',
            'include-type-oids', 'true',
            'format-version', '2',
            'actions', pub.w2j_actions,
            'add-tables', pub.w2j_add_tables
          ) x
      )
      select
        xyz.wal,
        xyz.is_rls_enabled,
        xyz.subscription_ids,
        xyz.errors
      from
        w2j,
        realtime.apply_rls(
          wal := w2j.data::jsonb,
          max_record_bytes := max_record_bytes
        ) xyz(wal, is_rls_enabled, subscription_ids, errors)
      where
        w2j.w2j_add_tables <> ''
        and xyz.subscription_ids[1] is not null
    $$;


ALTER FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) OWNER TO supabase_admin;

--
-- TOC entry 520 (class 1255 OID 17113)
-- Name: quote_wal2json(regclass); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.quote_wal2json(entity regclass) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
      select
        (
          select string_agg('' || ch,'')
          from unnest(string_to_array(nsp.nspname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
        )
        || '.'
        || (
          select string_agg('' || ch,'')
          from unnest(string_to_array(pc.relname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
          )
      from
        pg_class pc
        join pg_namespace nsp
          on pc.relnamespace = nsp.oid
      where
        pc.oid = entity
    $$;


ALTER FUNCTION realtime.quote_wal2json(entity regclass) OWNER TO supabase_admin;

--
-- TOC entry 529 (class 1255 OID 17235)
-- Name: send(jsonb, text, text, boolean); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean DEFAULT true) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
  generated_id uuid;
  final_payload jsonb;
BEGIN
  BEGIN
    -- Generate a new UUID for the id
    generated_id := gen_random_uuid();

    -- Check if payload has an 'id' key, if not, add the generated UUID
    IF payload ? 'id' THEN
      final_payload := payload;
    ELSE
      final_payload := jsonb_set(payload, '{id}', to_jsonb(generated_id));
    END IF;

    -- Set the topic configuration
    EXECUTE format('SET LOCAL realtime.topic TO %L', topic);

    -- Attempt to insert the message
    INSERT INTO realtime.messages (id, payload, event, topic, private, extension)
    VALUES (generated_id, final_payload, event, topic, private, 'broadcast');
  EXCEPTION
    WHEN OTHERS THEN
      -- Capture and notify the error
      RAISE WARNING 'ErrorSendingBroadcastMessage: %', SQLERRM;
  END;
END;
$$;


ALTER FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) OWNER TO supabase_admin;

--
-- TOC entry 519 (class 1255 OID 17111)
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.subscription_check_filters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    /*
    Validates that the user defined filters for a subscription:
    - refer to valid columns that the claimed role may access
    - values are coercable to the correct column type
    */
    declare
        col_names text[] = coalesce(
                array_agg(c.column_name order by c.ordinal_position),
                '{}'::text[]
            )
            from
                information_schema.columns c
            where
                format('%I.%I', c.table_schema, c.table_name)::regclass = new.entity
                and pg_catalog.has_column_privilege(
                    (new.claims ->> 'role'),
                    format('%I.%I', c.table_schema, c.table_name)::regclass,
                    c.column_name,
                    'SELECT'
                );
        filter realtime.user_defined_filter;
        col_type regtype;

        in_val jsonb;
    begin
        for filter in select * from unnest(new.filters) loop
            -- Filtered column is valid
            if not filter.column_name = any(col_names) then
                raise exception 'invalid column for filter %', filter.column_name;
            end if;

            -- Type is sanitized and safe for string interpolation
            col_type = (
                select atttypid::regtype
                from pg_catalog.pg_attribute
                where attrelid = new.entity
                      and attname = filter.column_name
            );
            if col_type is null then
                raise exception 'failed to lookup type for column %', filter.column_name;
            end if;

            -- Set maximum number of entries for in filter
            if filter.op = 'in'::realtime.equality_op then
                in_val = realtime.cast(filter.value, (col_type::text || '[]')::regtype);
                if coalesce(jsonb_array_length(in_val), 0) > 100 then
                    raise exception 'too many values for `in` filter. Maximum 100';
                end if;
            else
                -- raises an exception if value is not coercable to type
                perform realtime.cast(filter.value, col_type);
            end if;

        end loop;

        -- Apply consistent order to filters so the unique constraint on
        -- (subscription_id, entity, filters) can't be tricked by a different filter order
        new.filters = coalesce(
            array_agg(f order by f.column_name, f.op, f.value),
            '{}'
        ) from unnest(new.filters) f;

        return new;
    end;
    $$;


ALTER FUNCTION realtime.subscription_check_filters() OWNER TO supabase_admin;

--
-- TOC entry 523 (class 1255 OID 17146)
-- Name: to_regrole(text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.to_regrole(role_name text) RETURNS regrole
    LANGUAGE sql IMMUTABLE
    AS $$ select role_name::regrole $$;


ALTER FUNCTION realtime.to_regrole(role_name text) OWNER TO supabase_admin;

--
-- TOC entry 528 (class 1255 OID 17229)
-- Name: topic(); Type: FUNCTION; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE FUNCTION realtime.topic() RETURNS text
    LANGUAGE sql STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;


ALTER FUNCTION realtime.topic() OWNER TO supabase_realtime_admin;

--
-- TOC entry 543 (class 1255 OID 17394)
-- Name: add_prefixes(text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.add_prefixes(_bucket_id text, _name text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    prefixes text[];
BEGIN
    prefixes := "storage"."get_prefixes"("_name");

    IF array_length(prefixes, 1) > 0 THEN
        INSERT INTO storage.prefixes (name, bucket_id)
        SELECT UNNEST(prefixes) as name, "_bucket_id" ON CONFLICT DO NOTHING;
    END IF;
END;
$$;


ALTER FUNCTION storage.add_prefixes(_bucket_id text, _name text) OWNER TO supabase_storage_admin;

--
-- TOC entry 536 (class 1255 OID 17320)
-- Name: can_insert_object(text, text, uuid, jsonb); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
  INSERT INTO "storage"."objects" ("bucket_id", "name", "owner", "metadata") VALUES (bucketid, name, owner, metadata);
  -- hack to rollback the successful insert
  RAISE sqlstate 'PT200' using
  message = 'ROLLBACK',
  detail = 'rollback successful insert';
END
$$;


ALTER FUNCTION storage.can_insert_object(bucketid text, name text, owner uuid, metadata jsonb) OWNER TO supabase_storage_admin;

--
-- TOC entry 555 (class 1255 OID 17435)
-- Name: delete_leaf_prefixes(text[], text[]); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.delete_leaf_prefixes(bucket_ids text[], names text[]) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_rows_deleted integer;
BEGIN
    LOOP
        WITH candidates AS (
            SELECT DISTINCT
                t.bucket_id,
                unnest(storage.get_prefixes(t.name)) AS name
            FROM unnest(bucket_ids, names) AS t(bucket_id, name)
        ),
        uniq AS (
             SELECT
                 bucket_id,
                 name,
                 storage.get_level(name) AS level
             FROM candidates
             WHERE name <> ''
             GROUP BY bucket_id, name
        ),
        leaf AS (
             SELECT
                 p.bucket_id,
                 p.name,
                 p.level
             FROM storage.prefixes AS p
                  JOIN uniq AS u
                       ON u.bucket_id = p.bucket_id
                           AND u.name = p.name
                           AND u.level = p.level
             WHERE NOT EXISTS (
                 SELECT 1
                 FROM storage.objects AS o
                 WHERE o.bucket_id = p.bucket_id
                   AND o.level = p.level + 1
                   AND o.name COLLATE "C" LIKE p.name || '/%'
             )
             AND NOT EXISTS (
                 SELECT 1
                 FROM storage.prefixes AS c
                 WHERE c.bucket_id = p.bucket_id
                   AND c.level = p.level + 1
                   AND c.name COLLATE "C" LIKE p.name || '/%'
             )
        )
        DELETE
        FROM storage.prefixes AS p
            USING leaf AS l
        WHERE p.bucket_id = l.bucket_id
          AND p.name = l.name
          AND p.level = l.level;

        GET DIAGNOSTICS v_rows_deleted = ROW_COUNT;
        EXIT WHEN v_rows_deleted = 0;
    END LOOP;
END;
$$;


ALTER FUNCTION storage.delete_leaf_prefixes(bucket_ids text[], names text[]) OWNER TO supabase_storage_admin;

--
-- TOC entry 544 (class 1255 OID 17395)
-- Name: delete_prefix(text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.delete_prefix(_bucket_id text, _name text) RETURNS boolean
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    -- Check if we can delete the prefix
    IF EXISTS(
        SELECT FROM "storage"."prefixes"
        WHERE "prefixes"."bucket_id" = "_bucket_id"
          AND level = "storage"."get_level"("_name") + 1
          AND "prefixes"."name" COLLATE "C" LIKE "_name" || '/%'
        LIMIT 1
    )
    OR EXISTS(
        SELECT FROM "storage"."objects"
        WHERE "objects"."bucket_id" = "_bucket_id"
          AND "storage"."get_level"("objects"."name") = "storage"."get_level"("_name") + 1
          AND "objects"."name" COLLATE "C" LIKE "_name" || '/%'
        LIMIT 1
    ) THEN
    -- There are sub-objects, skip deletion
    RETURN false;
    ELSE
        DELETE FROM "storage"."prefixes"
        WHERE "prefixes"."bucket_id" = "_bucket_id"
          AND level = "storage"."get_level"("_name")
          AND "prefixes"."name" = "_name";
        RETURN true;
    END IF;
END;
$$;


ALTER FUNCTION storage.delete_prefix(_bucket_id text, _name text) OWNER TO supabase_storage_admin;

--
-- TOC entry 547 (class 1255 OID 17398)
-- Name: delete_prefix_hierarchy_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.delete_prefix_hierarchy_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    prefix text;
BEGIN
    prefix := "storage"."get_prefix"(OLD."name");

    IF coalesce(prefix, '') != '' THEN
        PERFORM "storage"."delete_prefix"(OLD."bucket_id", prefix);
    END IF;

    RETURN OLD;
END;
$$;


ALTER FUNCTION storage.delete_prefix_hierarchy_trigger() OWNER TO supabase_storage_admin;

--
-- TOC entry 552 (class 1255 OID 17413)
-- Name: enforce_bucket_name_length(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.enforce_bucket_name_length() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
begin
    if length(new.name) > 100 then
        raise exception 'bucket name "%" is too long (% characters). Max is 100.', new.name, length(new.name);
    end if;
    return new;
end;
$$;


ALTER FUNCTION storage.enforce_bucket_name_length() OWNER TO supabase_storage_admin;

--
-- TOC entry 533 (class 1255 OID 17294)
-- Name: extension(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.extension(name text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
    _filename text;
BEGIN
    SELECT string_to_array(name, '/') INTO _parts;
    SELECT _parts[array_length(_parts,1)] INTO _filename;
    RETURN reverse(split_part(reverse(_filename), '.', 1));
END
$$;


ALTER FUNCTION storage.extension(name text) OWNER TO supabase_storage_admin;

--
-- TOC entry 532 (class 1255 OID 17293)
-- Name: filename(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.filename(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
	select string_to_array(name, '/') into _parts;
	return _parts[array_length(_parts,1)];
END
$$;


ALTER FUNCTION storage.filename(name text) OWNER TO supabase_storage_admin;

--
-- TOC entry 531 (class 1255 OID 17292)
-- Name: foldername(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.foldername(name text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    _parts text[];
BEGIN
    -- Split on "/" to get path segments
    SELECT string_to_array(name, '/') INTO _parts;
    -- Return everything except the last segment
    RETURN _parts[1 : array_length(_parts,1) - 1];
END
$$;


ALTER FUNCTION storage.foldername(name text) OWNER TO supabase_storage_admin;

--
-- TOC entry 540 (class 1255 OID 17376)
-- Name: get_level(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_level(name text) RETURNS integer
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
SELECT array_length(string_to_array("name", '/'), 1);
$$;


ALTER FUNCTION storage.get_level(name text) OWNER TO supabase_storage_admin;

--
-- TOC entry 541 (class 1255 OID 17392)
-- Name: get_prefix(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_prefix(name text) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $_$
SELECT
    CASE WHEN strpos("name", '/') > 0 THEN
             regexp_replace("name", '[\/]{1}[^\/]+\/?$', '')
         ELSE
             ''
        END;
$_$;


ALTER FUNCTION storage.get_prefix(name text) OWNER TO supabase_storage_admin;

--
-- TOC entry 542 (class 1255 OID 17393)
-- Name: get_prefixes(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_prefixes(name text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE STRICT
    AS $$
DECLARE
    parts text[];
    prefixes text[];
    prefix text;
BEGIN
    -- Split the name into parts by '/'
    parts := string_to_array("name", '/');
    prefixes := '{}';

    -- Construct the prefixes, stopping one level below the last part
    FOR i IN 1..array_length(parts, 1) - 1 LOOP
            prefix := array_to_string(parts[1:i], '/');
            prefixes := array_append(prefixes, prefix);
    END LOOP;

    RETURN prefixes;
END;
$$;


ALTER FUNCTION storage.get_prefixes(name text) OWNER TO supabase_storage_admin;

--
-- TOC entry 550 (class 1255 OID 17411)
-- Name: get_size_by_bucket(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_size_by_bucket() RETURNS TABLE(size bigint, bucket_id text)
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::bigint) as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


ALTER FUNCTION storage.get_size_by_bucket() OWNER TO supabase_storage_admin;

--
-- TOC entry 538 (class 1255 OID 17359)
-- Name: list_multipart_uploads_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, next_key_token text DEFAULT ''::text, next_upload_token text DEFAULT ''::text) RETURNS TABLE(key text, id text, created_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(key COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                        substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1)))
                    ELSE
                        key
                END AS key, id, created_at
            FROM
                storage.s3_multipart_uploads
            WHERE
                bucket_id = $5 AND
                key ILIKE $1 || ''%'' AND
                CASE
                    WHEN $4 != '''' AND $6 = '''' THEN
                        CASE
                            WHEN position($2 IN substring(key from length($1) + 1)) > 0 THEN
                                substring(key from 1 for length($1) + position($2 IN substring(key from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                key COLLATE "C" > $4
                            END
                    ELSE
                        true
                END AND
                CASE
                    WHEN $6 != '''' THEN
                        id COLLATE "C" > $6
                    ELSE
                        true
                    END
            ORDER BY
                key COLLATE "C" ASC, created_at ASC) as e order by key COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_key_token, bucket_id, next_upload_token;
END;
$_$;


ALTER FUNCTION storage.list_multipart_uploads_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, next_key_token text, next_upload_token text) OWNER TO supabase_storage_admin;

--
-- TOC entry 537 (class 1255 OID 17322)
-- Name: list_objects_with_delimiter(text, text, text, integer, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer DEFAULT 100, start_after text DEFAULT ''::text, next_token text DEFAULT ''::text) RETURNS TABLE(name text, id uuid, metadata jsonb, updated_at timestamp with time zone)
    LANGUAGE plpgsql
    AS $_$
BEGIN
    RETURN QUERY EXECUTE
        'SELECT DISTINCT ON(name COLLATE "C") * from (
            SELECT
                CASE
                    WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                        substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1)))
                    ELSE
                        name
                END AS name, id, metadata, updated_at
            FROM
                storage.objects
            WHERE
                bucket_id = $5 AND
                name ILIKE $1 || ''%'' AND
                CASE
                    WHEN $6 != '''' THEN
                    name COLLATE "C" > $6
                ELSE true END
                AND CASE
                    WHEN $4 != '''' THEN
                        CASE
                            WHEN position($2 IN substring(name from length($1) + 1)) > 0 THEN
                                substring(name from 1 for length($1) + position($2 IN substring(name from length($1) + 1))) COLLATE "C" > $4
                            ELSE
                                name COLLATE "C" > $4
                            END
                    ELSE
                        true
                END
            ORDER BY
                name COLLATE "C" ASC) as e order by name COLLATE "C" LIMIT $3'
        USING prefix_param, delimiter_param, max_keys, next_token, bucket_id, start_after;
END;
$_$;


ALTER FUNCTION storage.list_objects_with_delimiter(bucket_id text, prefix_param text, delimiter_param text, max_keys integer, start_after text, next_token text) OWNER TO supabase_storage_admin;

--
-- TOC entry 554 (class 1255 OID 17434)
-- Name: lock_top_prefixes(text[], text[]); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.lock_top_prefixes(bucket_ids text[], names text[]) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_bucket text;
    v_top text;
BEGIN
    FOR v_bucket, v_top IN
        SELECT DISTINCT t.bucket_id,
            split_part(t.name, '/', 1) AS top
        FROM unnest(bucket_ids, names) AS t(bucket_id, name)
        WHERE t.name <> ''
        ORDER BY 1, 2
        LOOP
            PERFORM pg_advisory_xact_lock(hashtextextended(v_bucket || '/' || v_top, 0));
        END LOOP;
END;
$$;


ALTER FUNCTION storage.lock_top_prefixes(bucket_ids text[], names text[]) OWNER TO supabase_storage_admin;

--
-- TOC entry 556 (class 1255 OID 17436)
-- Name: objects_delete_cleanup(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.objects_delete_cleanup() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_bucket_ids text[];
    v_names      text[];
BEGIN
    IF current_setting('storage.gc.prefixes', true) = '1' THEN
        RETURN NULL;
    END IF;

    PERFORM set_config('storage.gc.prefixes', '1', true);

    SELECT COALESCE(array_agg(d.bucket_id), '{}'),
           COALESCE(array_agg(d.name), '{}')
    INTO v_bucket_ids, v_names
    FROM deleted AS d
    WHERE d.name <> '';

    PERFORM storage.lock_top_prefixes(v_bucket_ids, v_names);
    PERFORM storage.delete_leaf_prefixes(v_bucket_ids, v_names);

    RETURN NULL;
END;
$$;


ALTER FUNCTION storage.objects_delete_cleanup() OWNER TO supabase_storage_admin;

--
-- TOC entry 546 (class 1255 OID 17397)
-- Name: objects_insert_prefix_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.objects_insert_prefix_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    NEW.level := "storage"."get_level"(NEW."name");

    RETURN NEW;
END;
$$;


ALTER FUNCTION storage.objects_insert_prefix_trigger() OWNER TO supabase_storage_admin;

--
-- TOC entry 557 (class 1255 OID 17437)
-- Name: objects_update_cleanup(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.objects_update_cleanup() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    -- NEW - OLD (destinations to create prefixes for)
    v_add_bucket_ids text[];
    v_add_names      text[];

    -- OLD - NEW (sources to prune)
    v_src_bucket_ids text[];
    v_src_names      text[];
BEGIN
    IF TG_OP <> 'UPDATE' THEN
        RETURN NULL;
    END IF;

    -- 1) Compute NEW−OLD (added paths) and OLD−NEW (moved-away paths)
    WITH added AS (
        SELECT n.bucket_id, n.name
        FROM new_rows n
        WHERE n.name <> '' AND position('/' in n.name) > 0
        EXCEPT
        SELECT o.bucket_id, o.name FROM old_rows o WHERE o.name <> ''
    ),
    moved AS (
         SELECT o.bucket_id, o.name
         FROM old_rows o
         WHERE o.name <> ''
         EXCEPT
         SELECT n.bucket_id, n.name FROM new_rows n WHERE n.name <> ''
    )
    SELECT
        -- arrays for ADDED (dest) in stable order
        COALESCE( (SELECT array_agg(a.bucket_id ORDER BY a.bucket_id, a.name) FROM added a), '{}' ),
        COALESCE( (SELECT array_agg(a.name      ORDER BY a.bucket_id, a.name) FROM added a), '{}' ),
        -- arrays for MOVED (src) in stable order
        COALESCE( (SELECT array_agg(m.bucket_id ORDER BY m.bucket_id, m.name) FROM moved m), '{}' ),
        COALESCE( (SELECT array_agg(m.name      ORDER BY m.bucket_id, m.name) FROM moved m), '{}' )
    INTO v_add_bucket_ids, v_add_names, v_src_bucket_ids, v_src_names;

    -- Nothing to do?
    IF (array_length(v_add_bucket_ids, 1) IS NULL) AND (array_length(v_src_bucket_ids, 1) IS NULL) THEN
        RETURN NULL;
    END IF;

    -- 2) Take per-(bucket, top) locks: ALL prefixes in consistent global order to prevent deadlocks
    DECLARE
        v_all_bucket_ids text[];
        v_all_names text[];
    BEGIN
        -- Combine source and destination arrays for consistent lock ordering
        v_all_bucket_ids := COALESCE(v_src_bucket_ids, '{}') || COALESCE(v_add_bucket_ids, '{}');
        v_all_names := COALESCE(v_src_names, '{}') || COALESCE(v_add_names, '{}');

        -- Single lock call ensures consistent global ordering across all transactions
        IF array_length(v_all_bucket_ids, 1) IS NOT NULL THEN
            PERFORM storage.lock_top_prefixes(v_all_bucket_ids, v_all_names);
        END IF;
    END;

    -- 3) Create destination prefixes (NEW−OLD) BEFORE pruning sources
    IF array_length(v_add_bucket_ids, 1) IS NOT NULL THEN
        WITH candidates AS (
            SELECT DISTINCT t.bucket_id, unnest(storage.get_prefixes(t.name)) AS name
            FROM unnest(v_add_bucket_ids, v_add_names) AS t(bucket_id, name)
            WHERE name <> ''
        )
        INSERT INTO storage.prefixes (bucket_id, name)
        SELECT c.bucket_id, c.name
        FROM candidates c
        ON CONFLICT DO NOTHING;
    END IF;

    -- 4) Prune source prefixes bottom-up for OLD−NEW
    IF array_length(v_src_bucket_ids, 1) IS NOT NULL THEN
        -- re-entrancy guard so DELETE on prefixes won't recurse
        IF current_setting('storage.gc.prefixes', true) <> '1' THEN
            PERFORM set_config('storage.gc.prefixes', '1', true);
        END IF;

        PERFORM storage.delete_leaf_prefixes(v_src_bucket_ids, v_src_names);
    END IF;

    RETURN NULL;
END;
$$;


ALTER FUNCTION storage.objects_update_cleanup() OWNER TO supabase_storage_admin;

--
-- TOC entry 559 (class 1255 OID 17442)
-- Name: objects_update_level_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.objects_update_level_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Ensure this is an update operation and the name has changed
    IF TG_OP = 'UPDATE' AND (NEW."name" <> OLD."name" OR NEW."bucket_id" <> OLD."bucket_id") THEN
        -- Set the new level
        NEW."level" := "storage"."get_level"(NEW."name");
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION storage.objects_update_level_trigger() OWNER TO supabase_storage_admin;

--
-- TOC entry 551 (class 1255 OID 17412)
-- Name: objects_update_prefix_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.objects_update_prefix_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    old_prefixes TEXT[];
BEGIN
    -- Ensure this is an update operation and the name has changed
    IF TG_OP = 'UPDATE' AND (NEW."name" <> OLD."name" OR NEW."bucket_id" <> OLD."bucket_id") THEN
        -- Retrieve old prefixes
        old_prefixes := "storage"."get_prefixes"(OLD."name");

        -- Remove old prefixes that are only used by this object
        WITH all_prefixes as (
            SELECT unnest(old_prefixes) as prefix
        ),
        can_delete_prefixes as (
             SELECT prefix
             FROM all_prefixes
             WHERE NOT EXISTS (
                 SELECT 1 FROM "storage"."objects"
                 WHERE "bucket_id" = OLD."bucket_id"
                   AND "name" <> OLD."name"
                   AND "name" LIKE (prefix || '%')
             )
         )
        DELETE FROM "storage"."prefixes" WHERE name IN (SELECT prefix FROM can_delete_prefixes);

        -- Add new prefixes
        PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    END IF;
    -- Set the new level
    NEW."level" := "storage"."get_level"(NEW."name");

    RETURN NEW;
END;
$$;


ALTER FUNCTION storage.objects_update_prefix_trigger() OWNER TO supabase_storage_admin;

--
-- TOC entry 539 (class 1255 OID 17375)
-- Name: operation(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.operation() RETURNS text
    LANGUAGE plpgsql STABLE
    AS $$
BEGIN
    RETURN current_setting('storage.operation', true);
END;
$$;


ALTER FUNCTION storage.operation() OWNER TO supabase_storage_admin;

--
-- TOC entry 558 (class 1255 OID 17438)
-- Name: prefixes_delete_cleanup(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.prefixes_delete_cleanup() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
    v_bucket_ids text[];
    v_names      text[];
BEGIN
    IF current_setting('storage.gc.prefixes', true) = '1' THEN
        RETURN NULL;
    END IF;

    PERFORM set_config('storage.gc.prefixes', '1', true);

    SELECT COALESCE(array_agg(d.bucket_id), '{}'),
           COALESCE(array_agg(d.name), '{}')
    INTO v_bucket_ids, v_names
    FROM deleted AS d
    WHERE d.name <> '';

    PERFORM storage.lock_top_prefixes(v_bucket_ids, v_names);
    PERFORM storage.delete_leaf_prefixes(v_bucket_ids, v_names);

    RETURN NULL;
END;
$$;


ALTER FUNCTION storage.prefixes_delete_cleanup() OWNER TO supabase_storage_admin;

--
-- TOC entry 545 (class 1255 OID 17396)
-- Name: prefixes_insert_trigger(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.prefixes_insert_trigger() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    PERFORM "storage"."add_prefixes"(NEW."bucket_id", NEW."name");
    RETURN NEW;
END;
$$;


ALTER FUNCTION storage.prefixes_insert_trigger() OWNER TO supabase_storage_admin;

--
-- TOC entry 534 (class 1255 OID 17309)
-- Name: search(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql
    AS $$
declare
    can_bypass_rls BOOLEAN;
begin
    SELECT rolbypassrls
    INTO can_bypass_rls
    FROM pg_roles
    WHERE rolname = coalesce(nullif(current_setting('role', true), 'none'), current_user);

    IF can_bypass_rls THEN
        RETURN QUERY SELECT * FROM storage.search_v1_optimised(prefix, bucketname, limits, levels, offsets, search, sortcolumn, sortorder);
    ELSE
        RETURN QUERY SELECT * FROM storage.search_legacy_v1(prefix, bucketname, limits, levels, offsets, search, sortcolumn, sortorder);
    END IF;
end;
$$;


ALTER FUNCTION storage.search(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text) OWNER TO supabase_storage_admin;

--
-- TOC entry 549 (class 1255 OID 17409)
-- Name: search_legacy_v1(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search_legacy_v1(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
declare
    v_order_by text;
    v_sort_order text;
begin
    case
        when sortcolumn = 'name' then
            v_order_by = 'name';
        when sortcolumn = 'updated_at' then
            v_order_by = 'updated_at';
        when sortcolumn = 'created_at' then
            v_order_by = 'created_at';
        when sortcolumn = 'last_accessed_at' then
            v_order_by = 'last_accessed_at';
        else
            v_order_by = 'name';
        end case;

    case
        when sortorder = 'asc' then
            v_sort_order = 'asc';
        when sortorder = 'desc' then
            v_sort_order = 'desc';
        else
            v_sort_order = 'asc';
        end case;

    v_order_by = v_order_by || ' ' || v_sort_order;

    return query execute
        'with folders as (
           select path_tokens[$1] as folder
           from storage.objects
             where objects.name ilike $2 || $3 || ''%''
               and bucket_id = $4
               and array_length(objects.path_tokens, 1) <> $1
           group by folder
           order by folder ' || v_sort_order || '
     )
     (select folder as "name",
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[$1] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where objects.name ilike $2 || $3 || ''%''
       and bucket_id = $4
       and array_length(objects.path_tokens, 1) = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


ALTER FUNCTION storage.search_legacy_v1(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text) OWNER TO supabase_storage_admin;

--
-- TOC entry 548 (class 1255 OID 17408)
-- Name: search_v1_optimised(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search_v1_optimised(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
declare
    v_order_by text;
    v_sort_order text;
begin
    case
        when sortcolumn = 'name' then
            v_order_by = 'name';
        when sortcolumn = 'updated_at' then
            v_order_by = 'updated_at';
        when sortcolumn = 'created_at' then
            v_order_by = 'created_at';
        when sortcolumn = 'last_accessed_at' then
            v_order_by = 'last_accessed_at';
        else
            v_order_by = 'name';
        end case;

    case
        when sortorder = 'asc' then
            v_sort_order = 'asc';
        when sortorder = 'desc' then
            v_sort_order = 'desc';
        else
            v_sort_order = 'asc';
        end case;

    v_order_by = v_order_by || ' ' || v_sort_order;

    return query execute
        'with folders as (
           select (string_to_array(name, ''/''))[level] as name
           from storage.prefixes
             where lower(prefixes.name) like lower($2 || $3) || ''%''
               and bucket_id = $4
               and level = $1
           order by name ' || v_sort_order || '
     )
     (select name,
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[level] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where lower(objects.name) like lower($2 || $3) || ''%''
       and bucket_id = $4
       and level = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


ALTER FUNCTION storage.search_v1_optimised(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text) OWNER TO supabase_storage_admin;

--
-- TOC entry 553 (class 1255 OID 17433)
-- Name: search_v2(text, text, integer, integer, text, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer DEFAULT 100, levels integer DEFAULT 1, start_after text DEFAULT ''::text, sort_order text DEFAULT 'asc'::text, sort_column text DEFAULT 'name'::text, sort_column_after text DEFAULT ''::text) RETURNS TABLE(key text, name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
DECLARE
    sort_col text;
    sort_ord text;
    cursor_op text;
    cursor_expr text;
    sort_expr text;
BEGIN
    -- Validate sort_order
    sort_ord := lower(sort_order);
    IF sort_ord NOT IN ('asc', 'desc') THEN
        sort_ord := 'asc';
    END IF;

    -- Determine cursor comparison operator
    IF sort_ord = 'asc' THEN
        cursor_op := '>';
    ELSE
        cursor_op := '<';
    END IF;
    
    sort_col := lower(sort_column);
    -- Validate sort column  
    IF sort_col IN ('updated_at', 'created_at') THEN
        cursor_expr := format(
            '($5 = '''' OR ROW(date_trunc(''milliseconds'', %I), name COLLATE "C") %s ROW(COALESCE(NULLIF($6, '''')::timestamptz, ''epoch''::timestamptz), $5))',
            sort_col, cursor_op
        );
        sort_expr := format(
            'COALESCE(date_trunc(''milliseconds'', %I), ''epoch''::timestamptz) %s, name COLLATE "C" %s',
            sort_col, sort_ord, sort_ord
        );
    ELSE
        cursor_expr := format('($5 = '''' OR name COLLATE "C" %s $5)', cursor_op);
        sort_expr := format('name COLLATE "C" %s', sort_ord);
    END IF;

    RETURN QUERY EXECUTE format(
        $sql$
        SELECT * FROM (
            (
                SELECT
                    split_part(name, '/', $4) AS key,
                    name,
                    NULL::uuid AS id,
                    updated_at,
                    created_at,
                    NULL::timestamptz AS last_accessed_at,
                    NULL::jsonb AS metadata
                FROM storage.prefixes
                WHERE name COLLATE "C" LIKE $1 || '%%'
                    AND bucket_id = $2
                    AND level = $4
                    AND %s
                ORDER BY %s
                LIMIT $3
            )
            UNION ALL
            (
                SELECT
                    split_part(name, '/', $4) AS key,
                    name,
                    id,
                    updated_at,
                    created_at,
                    last_accessed_at,
                    metadata
                FROM storage.objects
                WHERE name COLLATE "C" LIKE $1 || '%%'
                    AND bucket_id = $2
                    AND level = $4
                    AND %s
                ORDER BY %s
                LIMIT $3
            )
        ) obj
        ORDER BY %s
        LIMIT $3
        $sql$,
        cursor_expr,    -- prefixes WHERE
        sort_expr,      -- prefixes ORDER BY
        cursor_expr,    -- objects WHERE
        sort_expr,      -- objects ORDER BY
        sort_expr       -- final ORDER BY
    )
    USING prefix, bucket_name, limits, levels, start_after, sort_column_after;
END;
$_$;


ALTER FUNCTION storage.search_v2(prefix text, bucket_name text, limits integer, levels integer, start_after text, sort_order text, sort_column text, sort_column_after text) OWNER TO supabase_storage_admin;

--
-- TOC entry 535 (class 1255 OID 17310)
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


ALTER FUNCTION storage.update_updated_at_column() OWNER TO supabase_storage_admin;

--
-- TOC entry 349 (class 1259 OID 16525)
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE auth.audit_log_entries OWNER TO supabase_auth_admin;

--
-- TOC entry 6697 (class 0 OID 0)
-- Dependencies: 349
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- TOC entry 363 (class 1259 OID 16883)
-- Name: flow_state; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.flow_state (
    id uuid NOT NULL,
    user_id uuid,
    auth_code text NOT NULL,
    code_challenge_method auth.code_challenge_method NOT NULL,
    code_challenge text NOT NULL,
    provider_type text NOT NULL,
    provider_access_token text,
    provider_refresh_token text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    authentication_method text NOT NULL,
    auth_code_issued_at timestamp with time zone
);


ALTER TABLE auth.flow_state OWNER TO supabase_auth_admin;

--
-- TOC entry 6699 (class 0 OID 0)
-- Dependencies: 363
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.flow_state IS 'stores metadata for pkce logins';


--
-- TOC entry 354 (class 1259 OID 16681)
-- Name: identities; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.identities (
    provider_id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE auth.identities OWNER TO supabase_auth_admin;

--
-- TOC entry 6701 (class 0 OID 0)
-- Dependencies: 354
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- TOC entry 6702 (class 0 OID 0)
-- Dependencies: 354
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- TOC entry 348 (class 1259 OID 16518)
-- Name: instances; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE auth.instances OWNER TO supabase_auth_admin;

--
-- TOC entry 6704 (class 0 OID 0)
-- Dependencies: 348
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- TOC entry 358 (class 1259 OID 16770)
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


ALTER TABLE auth.mfa_amr_claims OWNER TO supabase_auth_admin;

--
-- TOC entry 6706 (class 0 OID 0)
-- Dependencies: 358
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- TOC entry 357 (class 1259 OID 16758)
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL,
    otp_code text,
    web_authn_session_data jsonb
);


ALTER TABLE auth.mfa_challenges OWNER TO supabase_auth_admin;

--
-- TOC entry 6708 (class 0 OID 0)
-- Dependencies: 357
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- TOC entry 356 (class 1259 OID 16745)
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text,
    phone text,
    last_challenged_at timestamp with time zone,
    web_authn_credential jsonb,
    web_authn_aaguid uuid,
    last_webauthn_challenge_data jsonb
);


ALTER TABLE auth.mfa_factors OWNER TO supabase_auth_admin;

--
-- TOC entry 6710 (class 0 OID 0)
-- Dependencies: 356
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- TOC entry 6711 (class 0 OID 0)
-- Dependencies: 356
-- Name: COLUMN mfa_factors.last_webauthn_challenge_data; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.mfa_factors.last_webauthn_challenge_data IS 'Stores the latest WebAuthn challenge data including attestation/assertion for customer verification';


--
-- TOC entry 366 (class 1259 OID 16995)
-- Name: oauth_authorizations; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.oauth_authorizations (
    id uuid NOT NULL,
    authorization_id text NOT NULL,
    client_id uuid NOT NULL,
    user_id uuid,
    redirect_uri text NOT NULL,
    scope text NOT NULL,
    state text,
    resource text,
    code_challenge text,
    code_challenge_method auth.code_challenge_method,
    response_type auth.oauth_response_type DEFAULT 'code'::auth.oauth_response_type NOT NULL,
    status auth.oauth_authorization_status DEFAULT 'pending'::auth.oauth_authorization_status NOT NULL,
    authorization_code text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone DEFAULT (now() + '00:03:00'::interval) NOT NULL,
    approved_at timestamp with time zone,
    nonce text,
    CONSTRAINT oauth_authorizations_authorization_code_length CHECK ((char_length(authorization_code) <= 255)),
    CONSTRAINT oauth_authorizations_code_challenge_length CHECK ((char_length(code_challenge) <= 128)),
    CONSTRAINT oauth_authorizations_expires_at_future CHECK ((expires_at > created_at)),
    CONSTRAINT oauth_authorizations_nonce_length CHECK ((char_length(nonce) <= 255)),
    CONSTRAINT oauth_authorizations_redirect_uri_length CHECK ((char_length(redirect_uri) <= 2048)),
    CONSTRAINT oauth_authorizations_resource_length CHECK ((char_length(resource) <= 2048)),
    CONSTRAINT oauth_authorizations_scope_length CHECK ((char_length(scope) <= 4096)),
    CONSTRAINT oauth_authorizations_state_length CHECK ((char_length(state) <= 4096))
);


ALTER TABLE auth.oauth_authorizations OWNER TO supabase_auth_admin;

--
-- TOC entry 368 (class 1259 OID 17068)
-- Name: oauth_client_states; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.oauth_client_states (
    id uuid NOT NULL,
    provider_type text NOT NULL,
    code_verifier text,
    created_at timestamp with time zone NOT NULL
);


ALTER TABLE auth.oauth_client_states OWNER TO supabase_auth_admin;

--
-- TOC entry 6714 (class 0 OID 0)
-- Dependencies: 368
-- Name: TABLE oauth_client_states; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.oauth_client_states IS 'Stores OAuth states for third-party provider authentication flows where Supabase acts as the OAuth client.';


--
-- TOC entry 365 (class 1259 OID 16965)
-- Name: oauth_clients; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.oauth_clients (
    id uuid NOT NULL,
    client_secret_hash text,
    registration_type auth.oauth_registration_type NOT NULL,
    redirect_uris text NOT NULL,
    grant_types text NOT NULL,
    client_name text,
    client_uri text,
    logo_uri text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    client_type auth.oauth_client_type DEFAULT 'confidential'::auth.oauth_client_type NOT NULL,
    CONSTRAINT oauth_clients_client_name_length CHECK ((char_length(client_name) <= 1024)),
    CONSTRAINT oauth_clients_client_uri_length CHECK ((char_length(client_uri) <= 2048)),
    CONSTRAINT oauth_clients_logo_uri_length CHECK ((char_length(logo_uri) <= 2048))
);


ALTER TABLE auth.oauth_clients OWNER TO supabase_auth_admin;

--
-- TOC entry 367 (class 1259 OID 17028)
-- Name: oauth_consents; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.oauth_consents (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    client_id uuid NOT NULL,
    scopes text NOT NULL,
    granted_at timestamp with time zone DEFAULT now() NOT NULL,
    revoked_at timestamp with time zone,
    CONSTRAINT oauth_consents_revoked_after_granted CHECK (((revoked_at IS NULL) OR (revoked_at >= granted_at))),
    CONSTRAINT oauth_consents_scopes_length CHECK ((char_length(scopes) <= 2048)),
    CONSTRAINT oauth_consents_scopes_not_empty CHECK ((char_length(TRIM(BOTH FROM scopes)) > 0))
);


ALTER TABLE auth.oauth_consents OWNER TO supabase_auth_admin;

--
-- TOC entry 364 (class 1259 OID 16933)
-- Name: one_time_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.one_time_tokens (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    token_type auth.one_time_token_type NOT NULL,
    token_hash text NOT NULL,
    relates_to text NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    CONSTRAINT one_time_tokens_token_hash_check CHECK ((char_length(token_hash) > 0))
);


ALTER TABLE auth.one_time_tokens OWNER TO supabase_auth_admin;

--
-- TOC entry 347 (class 1259 OID 16507)
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);


ALTER TABLE auth.refresh_tokens OWNER TO supabase_auth_admin;

--
-- TOC entry 6719 (class 0 OID 0)
-- Dependencies: 347
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- TOC entry 346 (class 1259 OID 16506)
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: supabase_auth_admin
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE auth.refresh_tokens_id_seq OWNER TO supabase_auth_admin;

--
-- TOC entry 6721 (class 0 OID 0)
-- Dependencies: 346
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: supabase_auth_admin
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- TOC entry 361 (class 1259 OID 16812)
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    name_id_format text,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);


ALTER TABLE auth.saml_providers OWNER TO supabase_auth_admin;

--
-- TOC entry 6723 (class 0 OID 0)
-- Dependencies: 361
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- TOC entry 362 (class 1259 OID 16830)
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    flow_state_id uuid,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);


ALTER TABLE auth.saml_relay_states OWNER TO supabase_auth_admin;

--
-- TOC entry 6725 (class 0 OID 0)
-- Dependencies: 362
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- TOC entry 350 (class 1259 OID 16533)
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


ALTER TABLE auth.schema_migrations OWNER TO supabase_auth_admin;

--
-- TOC entry 6727 (class 0 OID 0)
-- Dependencies: 350
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- TOC entry 355 (class 1259 OID 16711)
-- Name: sessions; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone,
    refreshed_at timestamp without time zone,
    user_agent text,
    ip inet,
    tag text,
    oauth_client_id uuid,
    refresh_token_hmac_key text,
    refresh_token_counter bigint,
    scopes text,
    CONSTRAINT sessions_scopes_length CHECK ((char_length(scopes) <= 4096))
);


ALTER TABLE auth.sessions OWNER TO supabase_auth_admin;

--
-- TOC entry 6729 (class 0 OID 0)
-- Dependencies: 355
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- TOC entry 6730 (class 0 OID 0)
-- Dependencies: 355
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- TOC entry 6731 (class 0 OID 0)
-- Dependencies: 355
-- Name: COLUMN sessions.refresh_token_hmac_key; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sessions.refresh_token_hmac_key IS 'Holds a HMAC-SHA256 key used to sign refresh tokens for this session.';


--
-- TOC entry 6732 (class 0 OID 0)
-- Dependencies: 355
-- Name: COLUMN sessions.refresh_token_counter; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sessions.refresh_token_counter IS 'Holds the ID (counter) of the last issued refresh token.';


--
-- TOC entry 360 (class 1259 OID 16797)
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


ALTER TABLE auth.sso_domains OWNER TO supabase_auth_admin;

--
-- TOC entry 6734 (class 0 OID 0)
-- Dependencies: 360
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- TOC entry 359 (class 1259 OID 16788)
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    disabled boolean,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


ALTER TABLE auth.sso_providers OWNER TO supabase_auth_admin;

--
-- TOC entry 6736 (class 0 OID 0)
-- Dependencies: 359
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- TOC entry 6737 (class 0 OID 0)
-- Dependencies: 359
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- TOC entry 345 (class 1259 OID 16495)
-- Name: users; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone text DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change text DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    deleted_at timestamp with time zone,
    is_anonymous boolean DEFAULT false NOT NULL,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);


ALTER TABLE auth.users OWNER TO supabase_auth_admin;

--
-- TOC entry 6739 (class 0 OID 0)
-- Dependencies: 345
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- TOC entry 6740 (class 0 OID 0)
-- Dependencies: 345
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- TOC entry 402 (class 1259 OID 23378)
-- Name: api_rate_limits; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.api_rate_limits (
    key text NOT NULL,
    window_start timestamp with time zone NOT NULL,
    window_seconds integer NOT NULL,
    count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.api_rate_limits OWNER TO postgres;

--
-- TOC entry 401 (class 1259 OID 23352)
-- Name: app_events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.app_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    event_type text NOT NULL,
    level text DEFAULT 'info'::text NOT NULL,
    actor_id uuid,
    actor_type text,
    request_id text,
    ride_id uuid,
    payment_intent_id uuid,
    payload jsonb DEFAULT '{}'::jsonb NOT NULL
);


ALTER TABLE public.app_events OWNER TO postgres;

--
-- TOC entry 393 (class 1259 OID 23138)
-- Name: driver_locations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.driver_locations (
    driver_id uuid DEFAULT auth.uid() NOT NULL,
    lat double precision NOT NULL,
    lng double precision NOT NULL,
    loc extensions.geography(Point,4326) GENERATED ALWAYS AS ((extensions.st_setsrid(extensions.st_makepoint(lng, lat), 4326))::extensions.geography) STORED,
    heading numeric,
    speed_mps numeric,
    accuracy_m numeric,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT driver_locations_lat_check CHECK (((lat >= ('-90'::integer)::double precision) AND (lat <= (90)::double precision))),
    CONSTRAINT driver_locations_lng_check CHECK (((lng >= ('-180'::integer)::double precision) AND (lng <= (180)::double precision)))
);


ALTER TABLE public.driver_locations OWNER TO postgres;

--
-- TOC entry 392 (class 1259 OID 23116)
-- Name: driver_vehicles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.driver_vehicles (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    driver_id uuid NOT NULL,
    make text,
    model text,
    color text,
    plate_number text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.driver_vehicles OWNER TO postgres;

--
-- TOC entry 391 (class 1259 OID 23095)
-- Name: drivers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.drivers (
    id uuid NOT NULL,
    status public.driver_status DEFAULT 'offline'::public.driver_status NOT NULL,
    vehicle_type text,
    rating_avg numeric(3,2) DEFAULT 5.00 NOT NULL,
    trips_count integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    rating_count integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.drivers OWNER TO postgres;

--
-- TOC entry 400 (class 1259 OID 23319)
-- Name: payment_intents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payment_intents (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ride_id uuid NOT NULL,
    provider text DEFAULT 'stub'::text NOT NULL,
    provider_ref text,
    status public.payment_intent_status DEFAULT 'requires_payment_method'::public.payment_intent_status NOT NULL,
    amount_iqd integer NOT NULL,
    currency text DEFAULT 'IQD'::text NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    idempotency_key text,
    provider_session_id text,
    provider_payment_intent_id text,
    last_error text,
    provider_charge_id text
);


ALTER TABLE public.payment_intents OWNER TO postgres;

--
-- TOC entry 410 (class 1259 OID 23630)
-- Name: payment_providers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payment_providers (
    code text NOT NULL,
    name text NOT NULL,
    kind public.payment_provider_kind NOT NULL,
    enabled boolean DEFAULT false NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    config jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.payment_providers OWNER TO postgres;

--
-- TOC entry 398 (class 1259 OID 23255)
-- Name: payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ride_id uuid NOT NULL,
    provider text NOT NULL,
    provider_ref text,
    status text NOT NULL,
    amount_iqd integer NOT NULL,
    currency text DEFAULT 'IQD'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    payment_intent_id uuid,
    provider_payment_intent_id text,
    provider_charge_id text,
    provider_refund_id text,
    method text,
    failure_code text,
    failure_message text,
    refunded_at timestamp with time zone,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    refund_amount_iqd integer,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL
);


ALTER TABLE public.payments OWNER TO postgres;

--
-- TOC entry 399 (class 1259 OID 23277)
-- Name: pricing_configs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pricing_configs (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    currency text DEFAULT 'IQD'::text NOT NULL,
    base_fare_iqd integer DEFAULT 200 NOT NULL,
    per_km_iqd integer DEFAULT 80 NOT NULL,
    per_min_iqd integer DEFAULT 15 NOT NULL,
    minimum_fare_iqd integer DEFAULT 300 NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.pricing_configs OWNER TO postgres;

--
-- TOC entry 425 (class 1259 OID 23925)
-- Name: profile_kyc; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.profile_kyc (
    user_id uuid NOT NULL,
    status public.kyc_status DEFAULT 'unverified'::public.kyc_status NOT NULL,
    note text,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by uuid
);


ALTER TABLE public.profile_kyc OWNER TO postgres;

--
-- TOC entry 390 (class 1259 OID 23076)
-- Name: profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.profiles (
    id uuid NOT NULL,
    display_name text,
    phone text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    rating_avg numeric(3,2) DEFAULT 5.00 NOT NULL,
    rating_count integer DEFAULT 0 NOT NULL,
    is_admin boolean DEFAULT false NOT NULL
);


ALTER TABLE public.profiles OWNER TO postgres;

--
-- TOC entry 414 (class 1259 OID 23706)
-- Name: provider_events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.provider_events (
    id bigint NOT NULL,
    provider_code text NOT NULL,
    provider_event_id text NOT NULL,
    payload jsonb DEFAULT '{}'::jsonb NOT NULL,
    received_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.provider_events OWNER TO postgres;

--
-- TOC entry 413 (class 1259 OID 23705)
-- Name: provider_events_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.provider_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.provider_events_id_seq OWNER TO postgres;

--
-- TOC entry 6758 (class 0 OID 0)
-- Dependencies: 413
-- Name: provider_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.provider_events_id_seq OWNED BY public.provider_events.id;


--
-- TOC entry 397 (class 1259 OID 23237)
-- Name: ride_events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ride_events (
    id bigint NOT NULL,
    ride_id uuid NOT NULL,
    actor_id uuid,
    actor_type public.ride_actor_type NOT NULL,
    event_type text NOT NULL,
    payload jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.ride_events OWNER TO postgres;

--
-- TOC entry 396 (class 1259 OID 23236)
-- Name: ride_events_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ride_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.ride_events_id_seq OWNER TO postgres;

--
-- TOC entry 6761 (class 0 OID 0)
-- Dependencies: 396
-- Name: ride_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ride_events_id_seq OWNED BY public.ride_events.id;


--
-- TOC entry 405 (class 1259 OID 23481)
-- Name: ride_incidents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ride_incidents (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ride_id uuid NOT NULL,
    reporter_id uuid NOT NULL,
    severity public.incident_severity DEFAULT 'low'::public.incident_severity NOT NULL,
    status public.incident_status DEFAULT 'open'::public.incident_status NOT NULL,
    category text NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    assigned_to uuid,
    reviewed_at timestamp with time zone,
    resolution_note text
);


ALTER TABLE public.ride_incidents OWNER TO postgres;

--
-- TOC entry 404 (class 1259 OID 23430)
-- Name: ride_ratings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ride_ratings (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ride_id uuid NOT NULL,
    rater_id uuid NOT NULL,
    ratee_id uuid NOT NULL,
    rater_role public.party_role NOT NULL,
    ratee_role public.party_role NOT NULL,
    rating smallint NOT NULL,
    comment text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ride_ratings_rating_check CHECK (((rating >= 1) AND (rating <= 5)))
);


ALTER TABLE public.ride_ratings OWNER TO postgres;

--
-- TOC entry 403 (class 1259 OID 23410)
-- Name: ride_receipts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ride_receipts (
    ride_id uuid NOT NULL,
    base_fare_iqd integer,
    tax_iqd integer DEFAULT 0 NOT NULL,
    tip_iqd integer DEFAULT 0 NOT NULL,
    total_iqd integer NOT NULL,
    currency text DEFAULT 'IQD'::text NOT NULL,
    generated_at timestamp with time zone DEFAULT now() NOT NULL,
    refunded_iqd integer DEFAULT 0 NOT NULL,
    refunded_at timestamp with time zone,
    receipt_status text DEFAULT 'paid'::text NOT NULL
);


ALTER TABLE public.ride_receipts OWNER TO postgres;

--
-- TOC entry 394 (class 1259 OID 23161)
-- Name: ride_requests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ride_requests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    rider_id uuid DEFAULT auth.uid() NOT NULL,
    pickup_lat double precision NOT NULL,
    pickup_lng double precision NOT NULL,
    pickup_loc extensions.geography(Point,4326) GENERATED ALWAYS AS ((extensions.st_setsrid(extensions.st_makepoint(pickup_lng, pickup_lat), 4326))::extensions.geography) STORED,
    dropoff_lat double precision NOT NULL,
    dropoff_lng double precision NOT NULL,
    dropoff_loc extensions.geography(Point,4326) GENERATED ALWAYS AS ((extensions.st_setsrid(extensions.st_makepoint(dropoff_lng, dropoff_lat), 4326))::extensions.geography) STORED,
    pickup_address text,
    dropoff_address text,
    status public.ride_request_status DEFAULT 'requested'::public.ride_request_status NOT NULL,
    assigned_driver_id uuid,
    match_deadline timestamp with time zone,
    match_attempts integer DEFAULT 0 NOT NULL,
    quote_amount_iqd integer,
    currency text DEFAULT 'IQD'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    matched_at timestamp with time zone,
    accepted_at timestamp with time zone,
    cancelled_at timestamp with time zone,
    CONSTRAINT ride_requests_dropoff_lat_check CHECK (((dropoff_lat >= ('-90'::integer)::double precision) AND (dropoff_lat <= (90)::double precision))),
    CONSTRAINT ride_requests_dropoff_lng_check CHECK (((dropoff_lng >= ('-180'::integer)::double precision) AND (dropoff_lng <= (180)::double precision))),
    CONSTRAINT ride_requests_pickup_lat_check CHECK (((pickup_lat >= ('-90'::integer)::double precision) AND (pickup_lat <= (90)::double precision))),
    CONSTRAINT ride_requests_pickup_lng_check CHECK (((pickup_lng >= ('-180'::integer)::double precision) AND (pickup_lng <= (180)::double precision)))
);


ALTER TABLE public.ride_requests OWNER TO postgres;

--
-- TOC entry 411 (class 1259 OID 23647)
-- Name: topup_packages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.topup_packages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    label text NOT NULL,
    amount_iqd bigint NOT NULL,
    bonus_iqd bigint DEFAULT 0 NOT NULL,
    active boolean DEFAULT true NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT topup_packages_amount_iqd_check CHECK ((amount_iqd > 0)),
    CONSTRAINT topup_packages_bonus_iqd_check CHECK ((bonus_iqd >= 0))
);


ALTER TABLE public.topup_packages OWNER TO postgres;

--
-- TOC entry 428 (class 1259 OID 23989)
-- Name: user_notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_notifications (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    kind text NOT NULL,
    title text NOT NULL,
    body text,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    read_at timestamp with time zone
);


ALTER TABLE public.user_notifications OWNER TO postgres;

--
-- TOC entry 408 (class 1259 OID 23587)
-- Name: wallet_entries; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.wallet_entries (
    id bigint NOT NULL,
    user_id uuid NOT NULL,
    kind public.wallet_entry_kind NOT NULL,
    delta_iqd bigint NOT NULL,
    memo text,
    source_type text,
    source_id uuid,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    idempotency_key text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.wallet_entries OWNER TO postgres;

--
-- TOC entry 407 (class 1259 OID 23586)
-- Name: wallet_entries_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.wallet_entries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.wallet_entries_id_seq OWNER TO postgres;

--
-- TOC entry 6770 (class 0 OID 0)
-- Dependencies: 407
-- Name: wallet_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.wallet_entries_id_seq OWNED BY public.wallet_entries.id;


--
-- TOC entry 409 (class 1259 OID 23605)
-- Name: wallet_holds; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.wallet_holds (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    ride_id uuid,
    amount_iqd bigint NOT NULL,
    status public.wallet_hold_status DEFAULT 'active'::public.wallet_hold_status NOT NULL,
    reason text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    captured_at timestamp with time zone,
    released_at timestamp with time zone,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    kind public.wallet_hold_kind DEFAULT 'ride'::public.wallet_hold_kind NOT NULL,
    withdraw_request_id uuid,
    CONSTRAINT wallet_holds_amount_iqd_check CHECK ((amount_iqd > 0))
);


ALTER TABLE public.wallet_holds OWNER TO postgres;

--
-- TOC entry 427 (class 1259 OID 23973)
-- Name: wallet_withdraw_payout_methods; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.wallet_withdraw_payout_methods (
    payout_kind public.withdraw_payout_kind NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by uuid
);


ALTER TABLE public.wallet_withdraw_payout_methods OWNER TO postgres;

--
-- TOC entry 424 (class 1259 OID 23883)
-- Name: wallet_withdraw_requests; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.wallet_withdraw_requests (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    amount_iqd bigint NOT NULL,
    payout_kind public.withdraw_payout_kind NOT NULL,
    destination jsonb DEFAULT '{}'::jsonb NOT NULL,
    status public.withdraw_request_status DEFAULT 'requested'::public.withdraw_request_status NOT NULL,
    note text,
    payout_reference text,
    idempotency_key text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    approved_at timestamp with time zone,
    paid_at timestamp with time zone,
    cancelled_at timestamp with time zone,
    rejected_at timestamp with time zone,
    CONSTRAINT wallet_withdraw_requests_amount_iqd_check CHECK ((amount_iqd > 0))
);


ALTER TABLE public.wallet_withdraw_requests OWNER TO postgres;

--
-- TOC entry 426 (class 1259 OID 23949)
-- Name: wallet_withdrawal_policy; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.wallet_withdrawal_policy (
    id integer DEFAULT 1 NOT NULL,
    min_amount_iqd bigint DEFAULT 5000 NOT NULL,
    max_amount_iqd bigint DEFAULT 2000000 NOT NULL,
    daily_cap_amount_iqd bigint DEFAULT 5000000 NOT NULL,
    daily_cap_count integer DEFAULT 5 NOT NULL,
    require_kyc boolean DEFAULT false NOT NULL,
    require_driver_not_suspended boolean DEFAULT true NOT NULL,
    min_trips_count integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_by uuid,
    CONSTRAINT wallet_withdrawal_policy_id_check CHECK ((id = 1))
);


ALTER TABLE public.wallet_withdrawal_policy OWNER TO postgres;

--
-- TOC entry 375 (class 1259 OID 17239)
-- Name: messages; Type: TABLE; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE TABLE realtime.messages (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
)
PARTITION BY RANGE (inserted_at);


ALTER TABLE realtime.messages OWNER TO supabase_realtime_admin;

--
-- TOC entry 429 (class 1259 OID 24055)
-- Name: messages_2026_01_20; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2026_01_20 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2026_01_20 OWNER TO supabase_admin;

--
-- TOC entry 430 (class 1259 OID 24067)
-- Name: messages_2026_01_21; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2026_01_21 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2026_01_21 OWNER TO supabase_admin;

--
-- TOC entry 431 (class 1259 OID 24079)
-- Name: messages_2026_01_22; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2026_01_22 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2026_01_22 OWNER TO supabase_admin;

--
-- TOC entry 432 (class 1259 OID 24091)
-- Name: messages_2026_01_23; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2026_01_23 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2026_01_23 OWNER TO supabase_admin;

--
-- TOC entry 433 (class 1259 OID 24103)
-- Name: messages_2026_01_24; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2026_01_24 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2026_01_24 OWNER TO supabase_admin;

--
-- TOC entry 369 (class 1259 OID 17076)
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


ALTER TABLE realtime.schema_migrations OWNER TO supabase_admin;

--
-- TOC entry 372 (class 1259 OID 17099)
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.subscription (
    id bigint NOT NULL,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    filters realtime.user_defined_filter[] DEFAULT '{}'::realtime.user_defined_filter[] NOT NULL,
    claims jsonb NOT NULL,
    claims_role regrole GENERATED ALWAYS AS (realtime.to_regrole((claims ->> 'role'::text))) STORED NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);


ALTER TABLE realtime.subscription OWNER TO supabase_admin;

--
-- TOC entry 371 (class 1259 OID 17098)
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE realtime.subscription ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME realtime.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 377 (class 1259 OID 17264)
-- Name: buckets; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.buckets (
    id text NOT NULL,
    name text NOT NULL,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    public boolean DEFAULT false,
    avif_autodetection boolean DEFAULT false,
    file_size_limit bigint,
    allowed_mime_types text[],
    owner_id text,
    type storage.buckettype DEFAULT 'STANDARD'::storage.buckettype NOT NULL
);


ALTER TABLE storage.buckets OWNER TO supabase_storage_admin;

--
-- TOC entry 6785 (class 0 OID 0)
-- Dependencies: 377
-- Name: COLUMN buckets.owner; Type: COMMENT; Schema: storage; Owner: supabase_storage_admin
--

COMMENT ON COLUMN storage.buckets.owner IS 'Field is deprecated, use owner_id instead';


--
-- TOC entry 382 (class 1259 OID 17422)
-- Name: buckets_analytics; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.buckets_analytics (
    name text NOT NULL,
    type storage.buckettype DEFAULT 'ANALYTICS'::storage.buckettype NOT NULL,
    format text DEFAULT 'ICEBERG'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE storage.buckets_analytics OWNER TO supabase_storage_admin;

--
-- TOC entry 383 (class 1259 OID 17449)
-- Name: buckets_vectors; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.buckets_vectors (
    id text NOT NULL,
    type storage.buckettype DEFAULT 'VECTOR'::storage.buckettype NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE storage.buckets_vectors OWNER TO supabase_storage_admin;

--
-- TOC entry 376 (class 1259 OID 17256)
-- Name: migrations; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE storage.migrations OWNER TO supabase_storage_admin;

--
-- TOC entry 378 (class 1259 OID 17274)
-- Name: objects; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.objects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_accessed_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED,
    version text,
    owner_id text,
    user_metadata jsonb,
    level integer
);


ALTER TABLE storage.objects OWNER TO supabase_storage_admin;

--
-- TOC entry 6789 (class 0 OID 0)
-- Dependencies: 378
-- Name: COLUMN objects.owner; Type: COMMENT; Schema: storage; Owner: supabase_storage_admin
--

COMMENT ON COLUMN storage.objects.owner IS 'Field is deprecated, use owner_id instead';


--
-- TOC entry 381 (class 1259 OID 17377)
-- Name: prefixes; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.prefixes (
    bucket_id text NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    level integer GENERATED ALWAYS AS (storage.get_level(name)) STORED NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE storage.prefixes OWNER TO supabase_storage_admin;

--
-- TOC entry 379 (class 1259 OID 17324)
-- Name: s3_multipart_uploads; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.s3_multipart_uploads (
    id text NOT NULL,
    in_progress_size bigint DEFAULT 0 NOT NULL,
    upload_signature text NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    version text NOT NULL,
    owner_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    user_metadata jsonb
);


ALTER TABLE storage.s3_multipart_uploads OWNER TO supabase_storage_admin;

--
-- TOC entry 380 (class 1259 OID 17338)
-- Name: s3_multipart_uploads_parts; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.s3_multipart_uploads_parts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    upload_id text NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    part_number integer NOT NULL,
    bucket_id text NOT NULL,
    key text NOT NULL COLLATE pg_catalog."C",
    etag text NOT NULL,
    owner_id text,
    version text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE storage.s3_multipart_uploads_parts OWNER TO supabase_storage_admin;

--
-- TOC entry 384 (class 1259 OID 17459)
-- Name: vector_indexes; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.vector_indexes (
    id text DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL COLLATE pg_catalog."C",
    bucket_id text NOT NULL,
    data_type text NOT NULL,
    dimension integer NOT NULL,
    distance_metric text NOT NULL,
    metadata_configuration jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE storage.vector_indexes OWNER TO supabase_storage_admin;

--
-- TOC entry 4823 (class 0 OID 0)
-- Name: messages_2026_01_20; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_01_20 FOR VALUES FROM ('2026-01-20 00:00:00') TO ('2026-01-21 00:00:00');


--
-- TOC entry 4824 (class 0 OID 0)
-- Name: messages_2026_01_21; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_01_21 FOR VALUES FROM ('2026-01-21 00:00:00') TO ('2026-01-22 00:00:00');


--
-- TOC entry 4825 (class 0 OID 0)
-- Name: messages_2026_01_22; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_01_22 FOR VALUES FROM ('2026-01-22 00:00:00') TO ('2026-01-23 00:00:00');


--
-- TOC entry 4826 (class 0 OID 0)
-- Name: messages_2026_01_23; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_01_23 FOR VALUES FROM ('2026-01-23 00:00:00') TO ('2026-01-24 00:00:00');


--
-- TOC entry 4827 (class 0 OID 0)
-- Name: messages_2026_01_24; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_01_24 FOR VALUES FROM ('2026-01-24 00:00:00') TO ('2026-01-25 00:00:00');


--
-- TOC entry 4837 (class 2604 OID 16510)
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- TOC entry 4997 (class 2604 OID 23709)
-- Name: provider_events id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.provider_events ALTER COLUMN id SET DEFAULT nextval('public.provider_events_id_seq'::regclass);


--
-- TOC entry 4926 (class 2604 OID 23240)
-- Name: ride_events id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_events ALTER COLUMN id SET DEFAULT nextval('public.ride_events_id_seq'::regclass);


--
-- TOC entry 4972 (class 2604 OID 23590)
-- Name: wallet_entries id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallet_entries ALTER COLUMN id SET DEFAULT nextval('public.wallet_entries_id_seq'::regclass);


--
-- TOC entry 5149 (class 2606 OID 16783)
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- TOC entry 5118 (class 2606 OID 16531)
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- TOC entry 5172 (class 2606 OID 16889)
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- TOC entry 5127 (class 2606 OID 16907)
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- TOC entry 5129 (class 2606 OID 16917)
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);


--
-- TOC entry 5116 (class 2606 OID 16524)
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- TOC entry 5151 (class 2606 OID 16776)
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- TOC entry 5147 (class 2606 OID 16764)
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- TOC entry 5139 (class 2606 OID 16957)
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);


--
-- TOC entry 5141 (class 2606 OID 16751)
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- TOC entry 5185 (class 2606 OID 17016)
-- Name: oauth_authorizations oauth_authorizations_authorization_code_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_code_key UNIQUE (authorization_code);


--
-- TOC entry 5187 (class 2606 OID 17014)
-- Name: oauth_authorizations oauth_authorizations_authorization_id_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_id_key UNIQUE (authorization_id);


--
-- TOC entry 5189 (class 2606 OID 17012)
-- Name: oauth_authorizations oauth_authorizations_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_pkey PRIMARY KEY (id);


--
-- TOC entry 5199 (class 2606 OID 17074)
-- Name: oauth_client_states oauth_client_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_client_states
    ADD CONSTRAINT oauth_client_states_pkey PRIMARY KEY (id);


--
-- TOC entry 5182 (class 2606 OID 16976)
-- Name: oauth_clients oauth_clients_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_clients
    ADD CONSTRAINT oauth_clients_pkey PRIMARY KEY (id);


--
-- TOC entry 5193 (class 2606 OID 17038)
-- Name: oauth_consents oauth_consents_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_pkey PRIMARY KEY (id);


--
-- TOC entry 5195 (class 2606 OID 17040)
-- Name: oauth_consents oauth_consents_user_client_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_client_unique UNIQUE (user_id, client_id);


--
-- TOC entry 5176 (class 2606 OID 16942)
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);


--
-- TOC entry 5110 (class 2606 OID 16514)
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- TOC entry 5113 (class 2606 OID 16694)
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- TOC entry 5161 (class 2606 OID 16823)
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- TOC entry 5163 (class 2606 OID 16821)
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- TOC entry 5168 (class 2606 OID 16837)
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- TOC entry 5121 (class 2606 OID 16537)
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- TOC entry 5134 (class 2606 OID 16715)
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- TOC entry 5158 (class 2606 OID 16804)
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- TOC entry 5153 (class 2606 OID 16795)
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- TOC entry 5103 (class 2606 OID 16877)
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- TOC entry 5105 (class 2606 OID 16501)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 5310 (class 2606 OID 23385)
-- Name: api_rate_limits api_rate_limits_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.api_rate_limits
    ADD CONSTRAINT api_rate_limits_pkey PRIMARY KEY (key, window_start, window_seconds);


--
-- TOC entry 5303 (class 2606 OID 23362)
-- Name: app_events app_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_events
    ADD CONSTRAINT app_events_pkey PRIMARY KEY (id);


--
-- TOC entry 5256 (class 2606 OID 23149)
-- Name: driver_locations driver_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.driver_locations
    ADD CONSTRAINT driver_locations_pkey PRIMARY KEY (driver_id);


--
-- TOC entry 5251 (class 2606 OID 23127)
-- Name: driver_vehicles driver_vehicles_driver_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.driver_vehicles
    ADD CONSTRAINT driver_vehicles_driver_id_key UNIQUE (driver_id);


--
-- TOC entry 5253 (class 2606 OID 23125)
-- Name: driver_vehicles driver_vehicles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.driver_vehicles
    ADD CONSTRAINT driver_vehicles_pkey PRIMARY KEY (id);


--
-- TOC entry 5247 (class 2606 OID 23106)
-- Name: drivers drivers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drivers
    ADD CONSTRAINT drivers_pkey PRIMARY KEY (id);


--
-- TOC entry 5405 (class 2606 OID 24206)
-- Name: gift_codes gift_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gift_codes
    ADD CONSTRAINT gift_codes_pkey PRIMARY KEY (code);


--
-- TOC entry 5300 (class 2606 OID 23332)
-- Name: payment_intents payment_intents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_intents
    ADD CONSTRAINT payment_intents_pkey PRIMARY KEY (id);


--
-- TOC entry 5346 (class 2606 OID 23641)
-- Name: payment_providers payment_providers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_providers
    ADD CONSTRAINT payment_providers_pkey PRIMARY KEY (code);


--
-- TOC entry 5290 (class 2606 OID 23264)
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- TOC entry 5294 (class 2606 OID 23292)
-- Name: pricing_configs pricing_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pricing_configs
    ADD CONSTRAINT pricing_configs_pkey PRIMARY KEY (id);


--
-- TOC entry 5378 (class 2606 OID 23933)
-- Name: profile_kyc profile_kyc_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profile_kyc
    ADD CONSTRAINT profile_kyc_pkey PRIMARY KEY (user_id);


--
-- TOC entry 5245 (class 2606 OID 23084)
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- TOC entry 5360 (class 2606 OID 23715)
-- Name: provider_events provider_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.provider_events
    ADD CONSTRAINT provider_events_pkey PRIMARY KEY (id);


--
-- TOC entry 5285 (class 2606 OID 23246)
-- Name: ride_events ride_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_events
    ADD CONSTRAINT ride_events_pkey PRIMARY KEY (id);


--
-- TOC entry 5328 (class 2606 OID 23492)
-- Name: ride_incidents ride_incidents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_incidents
    ADD CONSTRAINT ride_incidents_pkey PRIMARY KEY (id);


--
-- TOC entry 5319 (class 2606 OID 23439)
-- Name: ride_ratings ride_ratings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_ratings
    ADD CONSTRAINT ride_ratings_pkey PRIMARY KEY (id);


--
-- TOC entry 5314 (class 2606 OID 23420)
-- Name: ride_receipts ride_receipts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_receipts
    ADD CONSTRAINT ride_receipts_pkey PRIMARY KEY (ride_id);


--
-- TOC entry 5265 (class 2606 OID 23180)
-- Name: ride_requests ride_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_requests
    ADD CONSTRAINT ride_requests_pkey PRIMARY KEY (id);


--
-- TOC entry 5278 (class 2606 OID 23213)
-- Name: rides rides_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rides
    ADD CONSTRAINT rides_pkey PRIMARY KEY (id);


--
-- TOC entry 5280 (class 2606 OID 23215)
-- Name: rides rides_request_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rides
    ADD CONSTRAINT rides_request_id_key UNIQUE (request_id);


--
-- TOC entry 5356 (class 2606 OID 23682)
-- Name: topup_intents topup_intents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.topup_intents
    ADD CONSTRAINT topup_intents_pkey PRIMARY KEY (id);


--
-- TOC entry 5348 (class 2606 OID 23661)
-- Name: topup_packages topup_packages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.topup_packages
    ADD CONSTRAINT topup_packages_pkey PRIMARY KEY (id);


--
-- TOC entry 5388 (class 2606 OID 23998)
-- Name: user_notifications user_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_notifications
    ADD CONSTRAINT user_notifications_pkey PRIMARY KEY (id);


--
-- TOC entry 5331 (class 2606 OID 23577)
-- Name: wallet_accounts wallet_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallet_accounts
    ADD CONSTRAINT wallet_accounts_pkey PRIMARY KEY (user_id);


--
-- TOC entry 5336 (class 2606 OID 23596)
-- Name: wallet_entries wallet_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallet_entries
    ADD CONSTRAINT wallet_entries_pkey PRIMARY KEY (id);


--
-- TOC entry 5344 (class 2606 OID 23615)
-- Name: wallet_holds wallet_holds_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallet_holds
    ADD CONSTRAINT wallet_holds_pkey PRIMARY KEY (id);


--
-- TOC entry 5384 (class 2606 OID 23980)
-- Name: wallet_withdraw_payout_methods wallet_withdraw_payout_methods_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallet_withdraw_payout_methods
    ADD CONSTRAINT wallet_withdraw_payout_methods_pkey PRIMARY KEY (payout_kind);


--
-- TOC entry 5374 (class 2606 OID 23895)
-- Name: wallet_withdraw_requests wallet_withdraw_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallet_withdraw_requests
    ADD CONSTRAINT wallet_withdraw_requests_pkey PRIMARY KEY (id);


--
-- TOC entry 5381 (class 2606 OID 23964)
-- Name: wallet_withdrawal_policy wallet_withdrawal_policy_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallet_withdrawal_policy
    ADD CONSTRAINT wallet_withdrawal_policy_pkey PRIMARY KEY (id);


--
-- TOC entry 5208 (class 2606 OID 17253)
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE ONLY realtime.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id, inserted_at);


--
-- TOC entry 5391 (class 2606 OID 24063)
-- Name: messages_2026_01_20 messages_2026_01_20_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2026_01_20
    ADD CONSTRAINT messages_2026_01_20_pkey PRIMARY KEY (id, inserted_at);


--
-- TOC entry 5394 (class 2606 OID 24075)
-- Name: messages_2026_01_21 messages_2026_01_21_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2026_01_21
    ADD CONSTRAINT messages_2026_01_21_pkey PRIMARY KEY (id, inserted_at);


--
-- TOC entry 5397 (class 2606 OID 24087)
-- Name: messages_2026_01_22 messages_2026_01_22_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2026_01_22
    ADD CONSTRAINT messages_2026_01_22_pkey PRIMARY KEY (id, inserted_at);


--
-- TOC entry 5400 (class 2606 OID 24099)
-- Name: messages_2026_01_23 messages_2026_01_23_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2026_01_23
    ADD CONSTRAINT messages_2026_01_23_pkey PRIMARY KEY (id, inserted_at);


--
-- TOC entry 5403 (class 2606 OID 24111)
-- Name: messages_2026_01_24 messages_2026_01_24_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2026_01_24
    ADD CONSTRAINT messages_2026_01_24_pkey PRIMARY KEY (id, inserted_at);


--
-- TOC entry 5204 (class 2606 OID 17107)
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);


--
-- TOC entry 5201 (class 2606 OID 17080)
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- TOC entry 5233 (class 2606 OID 17482)
-- Name: buckets_analytics buckets_analytics_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.buckets_analytics
    ADD CONSTRAINT buckets_analytics_pkey PRIMARY KEY (id);


--
-- TOC entry 5215 (class 2606 OID 17272)
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- TOC entry 5236 (class 2606 OID 17458)
-- Name: buckets_vectors buckets_vectors_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.buckets_vectors
    ADD CONSTRAINT buckets_vectors_pkey PRIMARY KEY (id);


--
-- TOC entry 5210 (class 2606 OID 17263)
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- TOC entry 5212 (class 2606 OID 17261)
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- TOC entry 5223 (class 2606 OID 17284)
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);


--
-- TOC entry 5231 (class 2606 OID 17386)
-- Name: prefixes prefixes_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.prefixes
    ADD CONSTRAINT prefixes_pkey PRIMARY KEY (bucket_id, level, name);


--
-- TOC entry 5228 (class 2606 OID 17347)
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_pkey PRIMARY KEY (id);


--
-- TOC entry 5226 (class 2606 OID 17332)
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_pkey PRIMARY KEY (id);


--
-- TOC entry 5239 (class 2606 OID 17468)
-- Name: vector_indexes vector_indexes_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_pkey PRIMARY KEY (id);


--
-- TOC entry 5119 (class 1259 OID 16532)
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- TOC entry 5093 (class 1259 OID 16704)
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- TOC entry 5094 (class 1259 OID 16706)
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- TOC entry 5095 (class 1259 OID 16707)
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- TOC entry 5137 (class 1259 OID 16785)
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- TOC entry 5170 (class 1259 OID 16893)
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- TOC entry 5125 (class 1259 OID 16873)
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- TOC entry 6799 (class 0 OID 0)
-- Dependencies: 5125
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- TOC entry 5130 (class 1259 OID 16701)
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- TOC entry 5173 (class 1259 OID 16890)
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- TOC entry 5197 (class 1259 OID 17075)
-- Name: idx_oauth_client_states_created_at; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_oauth_client_states_created_at ON auth.oauth_client_states USING btree (created_at);


--
-- TOC entry 5174 (class 1259 OID 16891)
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- TOC entry 5145 (class 1259 OID 16896)
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- TOC entry 5142 (class 1259 OID 16757)
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- TOC entry 5143 (class 1259 OID 16902)
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- TOC entry 5183 (class 1259 OID 17027)
-- Name: oauth_auth_pending_exp_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_auth_pending_exp_idx ON auth.oauth_authorizations USING btree (expires_at) WHERE (status = 'pending'::auth.oauth_authorization_status);


--
-- TOC entry 5180 (class 1259 OID 16980)
-- Name: oauth_clients_deleted_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_clients_deleted_at_idx ON auth.oauth_clients USING btree (deleted_at);


--
-- TOC entry 5190 (class 1259 OID 17053)
-- Name: oauth_consents_active_client_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_consents_active_client_idx ON auth.oauth_consents USING btree (client_id) WHERE (revoked_at IS NULL);


--
-- TOC entry 5191 (class 1259 OID 17051)
-- Name: oauth_consents_active_user_client_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_consents_active_user_client_idx ON auth.oauth_consents USING btree (user_id, client_id) WHERE (revoked_at IS NULL);


--
-- TOC entry 5196 (class 1259 OID 17052)
-- Name: oauth_consents_user_order_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_consents_user_order_idx ON auth.oauth_consents USING btree (user_id, granted_at DESC);


--
-- TOC entry 5177 (class 1259 OID 16949)
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- TOC entry 5178 (class 1259 OID 16948)
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- TOC entry 5179 (class 1259 OID 16950)
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


--
-- TOC entry 5096 (class 1259 OID 16708)
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- TOC entry 5097 (class 1259 OID 16705)
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- TOC entry 5106 (class 1259 OID 16515)
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- TOC entry 5107 (class 1259 OID 16516)
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- TOC entry 5108 (class 1259 OID 16700)
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- TOC entry 5111 (class 1259 OID 16787)
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- TOC entry 5114 (class 1259 OID 16892)
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- TOC entry 5164 (class 1259 OID 16829)
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- TOC entry 5165 (class 1259 OID 16894)
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- TOC entry 5166 (class 1259 OID 16844)
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- TOC entry 5169 (class 1259 OID 16843)
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- TOC entry 5131 (class 1259 OID 16895)
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- TOC entry 5132 (class 1259 OID 17065)
-- Name: sessions_oauth_client_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_oauth_client_id_idx ON auth.sessions USING btree (oauth_client_id);


--
-- TOC entry 5135 (class 1259 OID 16786)
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- TOC entry 5156 (class 1259 OID 16811)
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- TOC entry 5159 (class 1259 OID 16810)
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- TOC entry 5154 (class 1259 OID 16796)
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- TOC entry 5155 (class 1259 OID 16958)
-- Name: sso_providers_resource_id_pattern_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sso_providers_resource_id_pattern_idx ON auth.sso_providers USING btree (resource_id text_pattern_ops);


--
-- TOC entry 5144 (class 1259 OID 16955)
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);


--
-- TOC entry 5136 (class 1259 OID 16784)
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- TOC entry 5098 (class 1259 OID 16864)
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- TOC entry 6800 (class 0 OID 0)
-- Dependencies: 5098
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- TOC entry 5099 (class 1259 OID 16702)
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- TOC entry 5100 (class 1259 OID 16505)
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- TOC entry 5101 (class 1259 OID 16919)
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


--
-- TOC entry 5304 (class 1259 OID 23373)
-- Name: ix_app_events_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_app_events_created_at ON public.app_events USING btree (created_at DESC);


--
-- TOC entry 5305 (class 1259 OID 23374)
-- Name: ix_app_events_event_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_app_events_event_type ON public.app_events USING btree (event_type);


--
-- TOC entry 5306 (class 1259 OID 23376)
-- Name: ix_app_events_level; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_app_events_level ON public.app_events USING btree (level);


--
-- TOC entry 5307 (class 1259 OID 24185)
-- Name: ix_app_events_payment_intent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_app_events_payment_intent_id ON public.app_events USING btree (payment_intent_id);


--
-- TOC entry 5308 (class 1259 OID 23375)
-- Name: ix_app_events_ride_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_app_events_ride_id ON public.app_events USING btree (ride_id);


--
-- TOC entry 5257 (class 1259 OID 24466)
-- Name: ix_driver_locations_driver_locations_driver_id_fkey_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_driver_locations_driver_locations_driver_id_fkey_fkey ON public.driver_locations USING btree (driver_id);


--
-- TOC entry 5258 (class 1259 OID 23156)
-- Name: ix_driver_locations_loc_gist; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_driver_locations_loc_gist ON public.driver_locations USING gist (loc);


--
-- TOC entry 5259 (class 1259 OID 23157)
-- Name: ix_driver_locations_updated_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_driver_locations_updated_at ON public.driver_locations USING btree (updated_at DESC);


--
-- TOC entry 5254 (class 1259 OID 23134)
-- Name: ix_driver_vehicles_driver_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_driver_vehicles_driver_id ON public.driver_vehicles USING btree (driver_id);


--
-- TOC entry 5248 (class 1259 OID 24473)
-- Name: ix_drivers_drivers_id_fkey_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_drivers_drivers_id_fkey_fkey ON public.drivers USING btree (id);


--
-- TOC entry 5249 (class 1259 OID 23408)
-- Name: ix_drivers_rating_avg; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_drivers_rating_avg ON public.drivers USING btree (rating_avg DESC);


--
-- TOC entry 5406 (class 1259 OID 24222)
-- Name: ix_gift_codes_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_gift_codes_created_at ON public.gift_codes USING btree (created_at DESC);


--
-- TOC entry 5407 (class 1259 OID 24503)
-- Name: ix_gift_codes_gift_codes_created_by_fkey_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_gift_codes_gift_codes_created_by_fkey_fkey ON public.gift_codes USING btree (created_by);


--
-- TOC entry 5408 (class 1259 OID 24504)
-- Name: ix_gift_codes_gift_codes_redeemed_by_fkey_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_gift_codes_gift_codes_redeemed_by_fkey_fkey ON public.gift_codes USING btree (redeemed_by);


--
-- TOC entry 5409 (class 1259 OID 24505)
-- Name: ix_gift_codes_gift_codes_redeemed_entry_id_fkey_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_gift_codes_gift_codes_redeemed_entry_id_fkey_fkey ON public.gift_codes USING btree (redeemed_entry_id);


--
-- TOC entry 5410 (class 1259 OID 24223)
-- Name: ix_gift_codes_redeemed_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_gift_codes_redeemed_by ON public.gift_codes USING btree (redeemed_by, redeemed_at DESC);


--
-- TOC entry 5295 (class 1259 OID 23398)
-- Name: ix_payment_intents_provider_charge_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_payment_intents_provider_charge_id ON public.payment_intents USING btree (provider_charge_id);


--
-- TOC entry 5296 (class 1259 OID 23343)
-- Name: ix_payment_intents_provider_payment_intent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_payment_intents_provider_payment_intent_id ON public.payment_intents USING btree (provider_payment_intent_id);


--
-- TOC entry 5297 (class 1259 OID 23342)
-- Name: ix_payment_intents_provider_session_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_payment_intents_provider_session_id ON public.payment_intents USING btree (provider_session_id);


--
-- TOC entry 5298 (class 1259 OID 23339)
-- Name: ix_payment_intents_ride_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_payment_intents_ride_id ON public.payment_intents USING btree (ride_id);


--
-- TOC entry 5286 (class 1259 OID 23395)
-- Name: ix_payments_payment_intent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_payments_payment_intent_id ON public.payments USING btree (payment_intent_id);


--
-- TOC entry 5287 (class 1259 OID 23396)
-- Name: ix_payments_provider_payment_intent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_payments_provider_payment_intent_id ON public.payments USING btree (provider_payment_intent_id);


--
-- TOC entry 5288 (class 1259 OID 23270)
-- Name: ix_payments_ride_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_payments_ride_id ON public.payments USING btree (ride_id);


--
-- TOC entry 5375 (class 1259 OID 24499)
-- Name: ix_profile_kyc_profile_kyc_user_id_fkey_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_profile_kyc_profile_kyc_user_id_fkey_fkey ON public.profile_kyc USING btree (user_id);


--
-- TOC entry 5376 (class 1259 OID 24186)
-- Name: ix_profile_kyc_updated_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_profile_kyc_updated_by ON public.profile_kyc USING btree (updated_by);


--
-- TOC entry 5242 (class 1259 OID 24476)
-- Name: ix_profiles_profiles_id_fkey_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_profiles_profiles_id_fkey_fkey ON public.profiles USING btree (id);


--
-- TOC entry 5243 (class 1259 OID 23409)
-- Name: ix_profiles_rating_avg; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_profiles_rating_avg ON public.profiles USING btree (rating_avg DESC);


--
-- TOC entry 5358 (class 1259 OID 24486)
-- Name: ix_provider_events_provider_events_provider_code_fkey_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_provider_events_provider_events_provider_code_fkey_fkey ON public.provider_events USING btree (provider_code);


--
-- TOC entry 5282 (class 1259 OID 23253)
-- Name: ix_ride_events_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_events_created_at ON public.ride_events USING btree (created_at DESC);


--
-- TOC entry 5283 (class 1259 OID 23252)
-- Name: ix_ride_events_ride_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_events_ride_id ON public.ride_events USING btree (ride_id);


--
-- TOC entry 5321 (class 1259 OID 23518)
-- Name: ix_ride_incidents_assigned_to; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_incidents_assigned_to ON public.ride_incidents USING btree (assigned_to);


--
-- TOC entry 5322 (class 1259 OID 23507)
-- Name: ix_ride_incidents_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_incidents_created_at ON public.ride_incidents USING btree (created_at DESC);


--
-- TOC entry 5323 (class 1259 OID 23505)
-- Name: ix_ride_incidents_reporter_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_incidents_reporter_id ON public.ride_incidents USING btree (reporter_id);


--
-- TOC entry 5324 (class 1259 OID 23504)
-- Name: ix_ride_incidents_ride_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_incidents_ride_id ON public.ride_incidents USING btree (ride_id);


--
-- TOC entry 5325 (class 1259 OID 23519)
-- Name: ix_ride_incidents_severity; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_incidents_severity ON public.ride_incidents USING btree (severity);


--
-- TOC entry 5326 (class 1259 OID 23506)
-- Name: ix_ride_incidents_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_incidents_status ON public.ride_incidents USING btree (status);


--
-- TOC entry 5315 (class 1259 OID 23457)
-- Name: ix_ride_ratings_ratee_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_ratings_ratee_id ON public.ride_ratings USING btree (ratee_id);


--
-- TOC entry 5316 (class 1259 OID 24187)
-- Name: ix_ride_ratings_rater_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_ratings_rater_id ON public.ride_ratings USING btree (rater_id);


--
-- TOC entry 5317 (class 1259 OID 23456)
-- Name: ix_ride_ratings_ride_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_ratings_ride_id ON public.ride_ratings USING btree (ride_id);


--
-- TOC entry 5311 (class 1259 OID 23426)
-- Name: ix_ride_receipts_generated_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_receipts_generated_at ON public.ride_receipts USING btree (generated_at DESC);


--
-- TOC entry 5312 (class 1259 OID 24480)
-- Name: ix_ride_receipts_ride_receipts_ride_id_fkey_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_receipts_ride_receipts_ride_id_fkey_fkey ON public.ride_receipts USING btree (ride_id);


--
-- TOC entry 5260 (class 1259 OID 23194)
-- Name: ix_ride_requests_assigned_driver_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_requests_assigned_driver_id ON public.ride_requests USING btree (assigned_driver_id);


--
-- TOC entry 5261 (class 1259 OID 23195)
-- Name: ix_ride_requests_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_requests_created_at ON public.ride_requests USING btree (created_at DESC);


--
-- TOC entry 5262 (class 1259 OID 23192)
-- Name: ix_ride_requests_rider_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_requests_rider_id ON public.ride_requests USING btree (rider_id);


--
-- TOC entry 5263 (class 1259 OID 23193)
-- Name: ix_ride_requests_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_requests_status ON public.ride_requests USING btree (status);


--
-- TOC entry 5267 (class 1259 OID 23527)
-- Name: ix_rides_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_rides_created_at ON public.rides USING btree (created_at DESC);


--
-- TOC entry 5268 (class 1259 OID 23529)
-- Name: ix_rides_driver_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_rides_driver_created_at ON public.rides USING btree (driver_id, created_at DESC);


--
-- TOC entry 5269 (class 1259 OID 23233)
-- Name: ix_rides_driver_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_rides_driver_id ON public.rides USING btree (driver_id);


--
-- TOC entry 5270 (class 1259 OID 23350)
-- Name: ix_rides_paid_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_rides_paid_at ON public.rides USING btree (paid_at DESC);


--
-- TOC entry 5271 (class 1259 OID 24188)
-- Name: ix_rides_payment_intent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_rides_payment_intent_id ON public.rides USING btree (payment_intent_id);


--
-- TOC entry 5272 (class 1259 OID 23528)
-- Name: ix_rides_rider_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_rides_rider_created_at ON public.rides USING btree (rider_id, created_at DESC);


--
-- TOC entry 5273 (class 1259 OID 23232)
-- Name: ix_rides_rider_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_rides_rider_id ON public.rides USING btree (rider_id);


--
-- TOC entry 5274 (class 1259 OID 24489)
-- Name: ix_rides_rides_request_id_fkey_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_rides_rides_request_id_fkey_fkey ON public.rides USING btree (request_id);


--
-- TOC entry 5275 (class 1259 OID 23234)
-- Name: ix_rides_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_rides_status ON public.rides USING btree (status);


--
-- TOC entry 5276 (class 1259 OID 23733)
-- Name: ix_rides_wallet_hold_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_rides_wallet_hold_id ON public.rides USING btree (wallet_hold_id);


--
-- TOC entry 5350 (class 1259 OID 24189)
-- Name: ix_topup_intents_package_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_topup_intents_package_id ON public.topup_intents USING btree (package_id);


--
-- TOC entry 5351 (class 1259 OID 24190)
-- Name: ix_topup_intents_provider_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_topup_intents_provider_code ON public.topup_intents USING btree (provider_code);


--
-- TOC entry 5352 (class 1259 OID 23700)
-- Name: ix_topup_intents_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_topup_intents_status ON public.topup_intents USING btree (status);


--
-- TOC entry 5353 (class 1259 OID 24485)
-- Name: ix_topup_intents_topup_intents_user_id_fkey_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_topup_intents_topup_intents_user_id_fkey_fkey ON public.topup_intents USING btree (user_id);


--
-- TOC entry 5354 (class 1259 OID 23699)
-- Name: ix_topup_intents_user_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_topup_intents_user_created ON public.topup_intents USING btree (user_id, created_at DESC);


--
-- TOC entry 5385 (class 1259 OID 24004)
-- Name: ix_user_notifications_user_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_user_notifications_user_created ON public.user_notifications USING btree (user_id, created_at DESC);


--
-- TOC entry 5386 (class 1259 OID 24502)
-- Name: ix_user_notifications_user_notifications_user_id_fkey_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_user_notifications_user_notifications_user_id_fkey_fkey ON public.user_notifications USING btree (user_id);


--
-- TOC entry 5329 (class 1259 OID 24481)
-- Name: ix_wallet_accounts_wallet_accounts_user_id_fkey_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_wallet_accounts_wallet_accounts_user_id_fkey_fkey ON public.wallet_accounts USING btree (user_id);


--
-- TOC entry 5332 (class 1259 OID 23602)
-- Name: ix_wallet_entries_user_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_wallet_entries_user_created ON public.wallet_entries USING btree (user_id, created_at DESC);


--
-- TOC entry 5333 (class 1259 OID 24482)
-- Name: ix_wallet_entries_wallet_entries_user_id_fkey_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_wallet_entries_wallet_entries_user_id_fkey_fkey ON public.wallet_entries USING btree (user_id);


--
-- TOC entry 5337 (class 1259 OID 23627)
-- Name: ix_wallet_holds_ride_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_wallet_holds_ride_id ON public.wallet_holds USING btree (ride_id);


--
-- TOC entry 5338 (class 1259 OID 23626)
-- Name: ix_wallet_holds_user_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_wallet_holds_user_created ON public.wallet_holds USING btree (user_id, created_at DESC);


--
-- TOC entry 5339 (class 1259 OID 24495)
-- Name: ix_wallet_holds_wallet_holds_user_id_fkey_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_wallet_holds_wallet_holds_user_id_fkey_fkey ON public.wallet_holds USING btree (user_id);


--
-- TOC entry 5340 (class 1259 OID 23911)
-- Name: ix_wallet_holds_withdraw_request; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_wallet_holds_withdraw_request ON public.wallet_holds USING btree (withdraw_request_id);


--
-- TOC entry 5382 (class 1259 OID 24191)
-- Name: ix_wallet_withdraw_payout_methods_updated_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_wallet_withdraw_payout_methods_updated_by ON public.wallet_withdraw_payout_methods USING btree (updated_by);


--
-- TOC entry 5369 (class 1259 OID 24497)
-- Name: ix_wallet_withdraw_requ_67e67264c160fa61_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_wallet_withdraw_requ_67e67264c160fa61_fkey ON public.wallet_withdraw_requests USING btree (user_id);


--
-- TOC entry 5370 (class 1259 OID 24021)
-- Name: ix_wallet_withdraw_requests_status_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_wallet_withdraw_requests_status_created ON public.wallet_withdraw_requests USING btree (status, created_at DESC);


--
-- TOC entry 5371 (class 1259 OID 24019)
-- Name: ix_wallet_withdraw_requests_user_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_wallet_withdraw_requests_user_created ON public.wallet_withdraw_requests USING btree (user_id, created_at DESC);


--
-- TOC entry 5379 (class 1259 OID 24192)
-- Name: ix_wallet_withdrawal_policy_updated_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_wallet_withdrawal_policy_updated_by ON public.wallet_withdrawal_policy USING btree (updated_by);


--
-- TOC entry 5361 (class 1259 OID 24406)
-- Name: provider_events_provider_code_provider_event_id_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX provider_events_provider_code_provider_event_id_key ON public.provider_events USING btree (provider_code, provider_event_id);


--
-- TOC entry 5362 (class 1259 OID 24407)
-- Name: provider_events_provider_code_received_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX provider_events_provider_code_received_at_idx ON public.provider_events USING btree (provider_code, received_at DESC);


--
-- TOC entry 5301 (class 1259 OID 23344)
-- Name: ux_payment_intents_ride_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_payment_intents_ride_active ON public.payment_intents USING btree (ride_id) WHERE (status = ANY (ARRAY['requires_payment_method'::public.payment_intent_status, 'requires_confirmation'::public.payment_intent_status, 'requires_capture'::public.payment_intent_status]));


--
-- TOC entry 5291 (class 1259 OID 23397)
-- Name: ux_payments_provider_refund_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_payments_provider_refund_id ON public.payments USING btree (provider_refund_id) WHERE (provider_refund_id IS NOT NULL);


--
-- TOC entry 5292 (class 1259 OID 23351)
-- Name: ux_payments_ride_succeeded; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_payments_ride_succeeded ON public.payments USING btree (ride_id) WHERE (status = 'succeeded'::text);


--
-- TOC entry 5320 (class 1259 OID 23455)
-- Name: ux_ride_ratings_ride_rater; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_ride_ratings_ride_rater ON public.ride_ratings USING btree (ride_id, rater_id);


--
-- TOC entry 5266 (class 1259 OID 23302)
-- Name: ux_ride_requests_driver_matched; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_ride_requests_driver_matched ON public.ride_requests USING btree (assigned_driver_id) WHERE ((status = 'matched'::public.ride_request_status) AND (assigned_driver_id IS NOT NULL));


--
-- TOC entry 5281 (class 1259 OID 23303)
-- Name: ux_rides_driver_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_rides_driver_active ON public.rides USING btree (driver_id) WHERE (status = ANY (ARRAY['assigned'::public.ride_status, 'arrived'::public.ride_status, 'in_progress'::public.ride_status]));


--
-- TOC entry 5357 (class 1259 OID 23701)
-- Name: ux_topup_intents_user_idempotency; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_topup_intents_user_idempotency ON public.topup_intents USING btree (user_id, idempotency_key) WHERE (idempotency_key IS NOT NULL);


--
-- TOC entry 5349 (class 1259 OID 23662)
-- Name: ux_topup_packages_label; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_topup_packages_label ON public.topup_packages USING btree (label);


--
-- TOC entry 5334 (class 1259 OID 23603)
-- Name: ux_wallet_entries_user_idempotency; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_wallet_entries_user_idempotency ON public.wallet_entries USING btree (user_id, idempotency_key) WHERE (idempotency_key IS NOT NULL);


--
-- TOC entry 5341 (class 1259 OID 23628)
-- Name: ux_wallet_holds_active_per_ride; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_wallet_holds_active_per_ride ON public.wallet_holds USING btree (ride_id) WHERE ((ride_id IS NOT NULL) AND (status = 'active'::public.wallet_hold_status));


--
-- TOC entry 5342 (class 1259 OID 23912)
-- Name: ux_wallet_holds_active_per_withdraw; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_wallet_holds_active_per_withdraw ON public.wallet_holds USING btree (withdraw_request_id) WHERE ((withdraw_request_id IS NOT NULL) AND (status = 'active'::public.wallet_hold_status));


--
-- TOC entry 5372 (class 1259 OID 24020)
-- Name: ux_wallet_withdraw_requests_user_idempotency; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_wallet_withdraw_requests_user_idempotency ON public.wallet_withdraw_requests USING btree (user_id, idempotency_key) WHERE (idempotency_key IS NOT NULL);


--
-- TOC entry 5202 (class 1259 OID 17254)
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity);


--
-- TOC entry 5206 (class 1259 OID 17255)
-- Name: messages_inserted_at_topic_index; Type: INDEX; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE INDEX messages_inserted_at_topic_index ON ONLY realtime.messages USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- TOC entry 5389 (class 1259 OID 24064)
-- Name: messages_2026_01_20_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2026_01_20_inserted_at_topic_idx ON realtime.messages_2026_01_20 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- TOC entry 5392 (class 1259 OID 24076)
-- Name: messages_2026_01_21_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2026_01_21_inserted_at_topic_idx ON realtime.messages_2026_01_21 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- TOC entry 5395 (class 1259 OID 24088)
-- Name: messages_2026_01_22_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2026_01_22_inserted_at_topic_idx ON realtime.messages_2026_01_22 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- TOC entry 5398 (class 1259 OID 24100)
-- Name: messages_2026_01_23_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2026_01_23_inserted_at_topic_idx ON realtime.messages_2026_01_23 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- TOC entry 5401 (class 1259 OID 24112)
-- Name: messages_2026_01_24_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2026_01_24_inserted_at_topic_idx ON realtime.messages_2026_01_24 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- TOC entry 5205 (class 1259 OID 17156)
-- Name: subscription_subscription_id_entity_filters_key; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_key ON realtime.subscription USING btree (subscription_id, entity, filters);


--
-- TOC entry 5213 (class 1259 OID 17273)
-- Name: bname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);


--
-- TOC entry 5216 (class 1259 OID 17290)
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name);


--
-- TOC entry 5234 (class 1259 OID 17483)
-- Name: buckets_analytics_unique_name_idx; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX buckets_analytics_unique_name_idx ON storage.buckets_analytics USING btree (name) WHERE (deleted_at IS NULL);


--
-- TOC entry 5224 (class 1259 OID 17358)
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);


--
-- TOC entry 5217 (class 1259 OID 17404)
-- Name: idx_name_bucket_level_unique; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX idx_name_bucket_level_unique ON storage.objects USING btree (name COLLATE "C", bucket_id, level);


--
-- TOC entry 5218 (class 1259 OID 17323)
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");


--
-- TOC entry 5219 (class 1259 OID 17406)
-- Name: idx_objects_lower_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_objects_lower_name ON storage.objects USING btree ((path_tokens[level]), lower(name) text_pattern_ops, bucket_id, level);


--
-- TOC entry 5229 (class 1259 OID 17407)
-- Name: idx_prefixes_lower_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_prefixes_lower_name ON storage.prefixes USING btree (bucket_id, level, ((string_to_array(name, '/'::text))[level]), lower(name) text_pattern_ops);


--
-- TOC entry 5220 (class 1259 OID 17291)
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- TOC entry 5221 (class 1259 OID 17405)
-- Name: objects_bucket_id_level_idx; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX objects_bucket_id_level_idx ON storage.objects USING btree (bucket_id, level, name COLLATE "C");


--
-- TOC entry 5237 (class 1259 OID 17474)
-- Name: vector_indexes_name_bucket_id_idx; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX vector_indexes_name_bucket_id_idx ON storage.vector_indexes USING btree (name, bucket_id);


--
-- TOC entry 5411 (class 0 OID 0)
-- Name: messages_2026_01_20_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_01_20_inserted_at_topic_idx;


--
-- TOC entry 5412 (class 0 OID 0)
-- Name: messages_2026_01_20_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_01_20_pkey;


--
-- TOC entry 5413 (class 0 OID 0)
-- Name: messages_2026_01_21_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_01_21_inserted_at_topic_idx;


--
-- TOC entry 5414 (class 0 OID 0)
-- Name: messages_2026_01_21_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_01_21_pkey;


--
-- TOC entry 5415 (class 0 OID 0)
-- Name: messages_2026_01_22_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_01_22_inserted_at_topic_idx;


--
-- TOC entry 5416 (class 0 OID 0)
-- Name: messages_2026_01_22_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_01_22_pkey;


--
-- TOC entry 5417 (class 0 OID 0)
-- Name: messages_2026_01_23_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_01_23_inserted_at_topic_idx;


--
-- TOC entry 5418 (class 0 OID 0)
-- Name: messages_2026_01_23_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_01_23_pkey;


--
-- TOC entry 5419 (class 0 OID 0)
-- Name: messages_2026_01_24_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_01_24_inserted_at_topic_idx;


--
-- TOC entry 5420 (class 0 OID 0)
-- Name: messages_2026_01_24_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_01_24_pkey;


--
-- TOC entry 5485 (class 2620 OID 23094)
-- Name: users on_auth_user_created; Type: TRIGGER; Schema: auth; Owner: supabase_auth_admin
--

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


--
-- TOC entry 5499 (class 2620 OID 23155)
-- Name: driver_locations driver_locations_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER driver_locations_set_updated_at BEFORE UPDATE ON public.driver_locations FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 5498 (class 2620 OID 23133)
-- Name: driver_vehicles driver_vehicles_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER driver_vehicles_set_updated_at BEFORE UPDATE ON public.driver_vehicles FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 5497 (class 2620 OID 23112)
-- Name: drivers drivers_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER drivers_set_updated_at BEFORE UPDATE ON public.drivers FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 5510 (class 2620 OID 23338)
-- Name: payment_intents payment_intents_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER payment_intents_set_updated_at BEFORE UPDATE ON public.payment_intents FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 5515 (class 2620 OID 23642)
-- Name: payment_providers payment_providers_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER payment_providers_set_updated_at BEFORE UPDATE ON public.payment_providers FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 5506 (class 2620 OID 23429)
-- Name: payments payments_generate_receipt; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER payments_generate_receipt AFTER INSERT ON public.payments FOR EACH ROW EXECUTE FUNCTION public.create_receipt_from_payment();


--
-- TOC entry 5507 (class 2620 OID 23394)
-- Name: payments payments_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER payments_set_updated_at BEFORE UPDATE ON public.payments FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 5508 (class 2620 OID 23526)
-- Name: payments payments_update_receipt_on_refund; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER payments_update_receipt_on_refund AFTER UPDATE ON public.payments FOR EACH ROW EXECUTE FUNCTION public.update_receipt_on_refund();


--
-- TOC entry 5509 (class 2620 OID 23293)
-- Name: pricing_configs pricing_configs_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER pricing_configs_set_updated_at BEFORE UPDATE ON public.pricing_configs FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 5519 (class 2620 OID 23944)
-- Name: profile_kyc profile_kyc_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER profile_kyc_set_updated_at BEFORE UPDATE ON public.profile_kyc FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 5494 (class 2620 OID 23948)
-- Name: profiles profiles_after_insert_profile_kyc; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER profiles_after_insert_profile_kyc AFTER INSERT ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.profile_kyc_init();


--
-- TOC entry 5495 (class 2620 OID 23725)
-- Name: profiles profiles_ensure_wallet_account; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER profiles_ensure_wallet_account AFTER INSERT ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.ensure_wallet_account();


--
-- TOC entry 5496 (class 2620 OID 23090)
-- Name: profiles profiles_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER profiles_set_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 5512 (class 2620 OID 23503)
-- Name: ride_incidents ride_incidents_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ride_incidents_set_updated_at BEFORE UPDATE ON public.ride_incidents FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 5511 (class 2620 OID 23461)
-- Name: ride_ratings ride_ratings_apply_aggregate; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ride_ratings_apply_aggregate AFTER INSERT ON public.ride_ratings FOR EACH ROW EXECUTE FUNCTION public.apply_rating_aggregate();


--
-- TOC entry 5500 (class 2620 OID 23299)
-- Name: ride_requests ride_requests_clear_match_fields; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ride_requests_clear_match_fields BEFORE UPDATE ON public.ride_requests FOR EACH ROW EXECUTE FUNCTION public.ride_requests_clear_match_fields();


--
-- TOC entry 5501 (class 2620 OID 23301)
-- Name: ride_requests ride_requests_release_driver_on_unmatch; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ride_requests_release_driver_on_unmatch AFTER UPDATE ON public.ride_requests FOR EACH ROW EXECUTE FUNCTION public.ride_requests_release_driver_on_unmatch();


--
-- TOC entry 5502 (class 2620 OID 23297)
-- Name: ride_requests ride_requests_set_quote; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ride_requests_set_quote BEFORE INSERT ON public.ride_requests FOR EACH ROW EXECUTE FUNCTION public.ride_requests_set_quote();


--
-- TOC entry 5503 (class 2620 OID 23191)
-- Name: ride_requests ride_requests_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ride_requests_set_updated_at BEFORE UPDATE ON public.ride_requests FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 5504 (class 2620 OID 23273)
-- Name: ride_requests ride_requests_status_timestamps; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ride_requests_status_timestamps BEFORE UPDATE ON public.ride_requests FOR EACH ROW EXECUTE FUNCTION public.ride_requests_set_status_timestamps();


--
-- TOC entry 5505 (class 2620 OID 23231)
-- Name: rides rides_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER rides_set_updated_at BEFORE UPDATE ON public.rides FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 5517 (class 2620 OID 23698)
-- Name: topup_intents topup_intents_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER topup_intents_set_updated_at BEFORE UPDATE ON public.topup_intents FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 5516 (class 2620 OID 23663)
-- Name: topup_packages topup_packages_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER topup_packages_set_updated_at BEFORE UPDATE ON public.topup_packages FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 5513 (class 2620 OID 23583)
-- Name: wallet_accounts wallet_accounts_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER wallet_accounts_set_updated_at BEFORE UPDATE ON public.wallet_accounts FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 5514 (class 2620 OID 23739)
-- Name: wallet_holds wallet_holds_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER wallet_holds_set_updated_at BEFORE UPDATE ON public.wallet_holds FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 5521 (class 2620 OID 23986)
-- Name: wallet_withdraw_payout_methods wallet_withdraw_payout_methods_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER wallet_withdraw_payout_methods_set_updated_at BEFORE UPDATE ON public.wallet_withdraw_payout_methods FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 5518 (class 2620 OID 23904)
-- Name: wallet_withdraw_requests wallet_withdraw_requests_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER wallet_withdraw_requests_set_updated_at BEFORE UPDATE ON public.wallet_withdraw_requests FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 5520 (class 2620 OID 23970)
-- Name: wallet_withdrawal_policy wallet_withdrawal_policy_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER wallet_withdrawal_policy_set_updated_at BEFORE UPDATE ON public.wallet_withdrawal_policy FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 5486 (class 2620 OID 17112)
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: supabase_admin
--

CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECUTE FUNCTION realtime.subscription_check_filters();


--
-- TOC entry 5487 (class 2620 OID 17414)
-- Name: buckets enforce_bucket_name_length_trigger; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER enforce_bucket_name_length_trigger BEFORE INSERT OR UPDATE OF name ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.enforce_bucket_name_length();


--
-- TOC entry 5488 (class 2620 OID 17445)
-- Name: objects objects_delete_delete_prefix; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER objects_delete_delete_prefix AFTER DELETE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.delete_prefix_hierarchy_trigger();


--
-- TOC entry 5489 (class 2620 OID 17400)
-- Name: objects objects_insert_create_prefix; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER objects_insert_create_prefix BEFORE INSERT ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.objects_insert_prefix_trigger();


--
-- TOC entry 5490 (class 2620 OID 17444)
-- Name: objects objects_update_create_prefix; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER objects_update_create_prefix BEFORE UPDATE ON storage.objects FOR EACH ROW WHEN (((new.name <> old.name) OR (new.bucket_id <> old.bucket_id))) EXECUTE FUNCTION storage.objects_update_prefix_trigger();


--
-- TOC entry 5492 (class 2620 OID 17410)
-- Name: prefixes prefixes_create_hierarchy; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER prefixes_create_hierarchy BEFORE INSERT ON storage.prefixes FOR EACH ROW WHEN ((pg_trigger_depth() < 1)) EXECUTE FUNCTION storage.prefixes_insert_trigger();


--
-- TOC entry 5493 (class 2620 OID 17446)
-- Name: prefixes prefixes_delete_hierarchy; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER prefixes_delete_hierarchy AFTER DELETE ON storage.prefixes FOR EACH ROW EXECUTE FUNCTION storage.delete_prefix_hierarchy_trigger();


--
-- TOC entry 5491 (class 2620 OID 17311)
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();


--
-- TOC entry 5422 (class 2606 OID 16688)
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- TOC entry 5427 (class 2606 OID 16777)
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- TOC entry 5426 (class 2606 OID 16765)
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- TOC entry 5425 (class 2606 OID 16752)
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- TOC entry 5433 (class 2606 OID 17017)
-- Name: oauth_authorizations oauth_authorizations_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- TOC entry 5434 (class 2606 OID 17022)
-- Name: oauth_authorizations oauth_authorizations_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- TOC entry 5435 (class 2606 OID 17046)
-- Name: oauth_consents oauth_consents_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- TOC entry 5436 (class 2606 OID 17041)
-- Name: oauth_consents oauth_consents_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- TOC entry 5432 (class 2606 OID 16943)
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- TOC entry 5421 (class 2606 OID 16721)
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- TOC entry 5429 (class 2606 OID 16824)
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- TOC entry 5430 (class 2606 OID 16897)
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;


--
-- TOC entry 5431 (class 2606 OID 16838)
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- TOC entry 5423 (class 2606 OID 17060)
-- Name: sessions sessions_oauth_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_oauth_client_id_fkey FOREIGN KEY (oauth_client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- TOC entry 5424 (class 2606 OID 16716)
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- TOC entry 5428 (class 2606 OID 16805)
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- TOC entry 5458 (class 2606 OID 23368)
-- Name: app_events app_events_payment_intent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_events
    ADD CONSTRAINT app_events_payment_intent_id_fkey FOREIGN KEY (payment_intent_id) REFERENCES public.payment_intents(id) ON DELETE SET NULL;


--
-- TOC entry 5459 (class 2606 OID 23363)
-- Name: app_events app_events_ride_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_events
    ADD CONSTRAINT app_events_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE SET NULL;


--
-- TOC entry 5446 (class 2606 OID 23150)
-- Name: driver_locations driver_locations_driver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.driver_locations
    ADD CONSTRAINT driver_locations_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(id) ON DELETE CASCADE;


--
-- TOC entry 5445 (class 2606 OID 23128)
-- Name: driver_vehicles driver_vehicles_driver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.driver_vehicles
    ADD CONSTRAINT driver_vehicles_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(id) ON DELETE CASCADE;


--
-- TOC entry 5444 (class 2606 OID 23107)
-- Name: drivers drivers_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drivers
    ADD CONSTRAINT drivers_id_fkey FOREIGN KEY (id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5482 (class 2606 OID 24207)
-- Name: gift_codes gift_codes_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gift_codes
    ADD CONSTRAINT gift_codes_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id) ON DELETE SET NULL;


--
-- TOC entry 5483 (class 2606 OID 24212)
-- Name: gift_codes gift_codes_redeemed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gift_codes
    ADD CONSTRAINT gift_codes_redeemed_by_fkey FOREIGN KEY (redeemed_by) REFERENCES public.profiles(id) ON DELETE SET NULL;


--
-- TOC entry 5484 (class 2606 OID 24217)
-- Name: gift_codes gift_codes_redeemed_entry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gift_codes
    ADD CONSTRAINT gift_codes_redeemed_entry_id_fkey FOREIGN KEY (redeemed_entry_id) REFERENCES public.wallet_entries(id) ON DELETE SET NULL;


--
-- TOC entry 5457 (class 2606 OID 23333)
-- Name: payment_intents payment_intents_ride_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_intents
    ADD CONSTRAINT payment_intents_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE CASCADE;


--
-- TOC entry 5455 (class 2606 OID 23389)
-- Name: payments payments_payment_intent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_payment_intent_id_fkey FOREIGN KEY (payment_intent_id) REFERENCES public.payment_intents(id) ON DELETE SET NULL;


--
-- TOC entry 5456 (class 2606 OID 23265)
-- Name: payments payments_ride_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE CASCADE;


--
-- TOC entry 5477 (class 2606 OID 23939)
-- Name: profile_kyc profile_kyc_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profile_kyc
    ADD CONSTRAINT profile_kyc_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.profiles(id) ON DELETE SET NULL;


--
-- TOC entry 5478 (class 2606 OID 23934)
-- Name: profile_kyc profile_kyc_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profile_kyc
    ADD CONSTRAINT profile_kyc_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5443 (class 2606 OID 23085)
-- Name: profiles profiles_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- TOC entry 5475 (class 2606 OID 23716)
-- Name: provider_events provider_events_provider_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.provider_events
    ADD CONSTRAINT provider_events_provider_code_fkey FOREIGN KEY (provider_code) REFERENCES public.payment_providers(code);


--
-- TOC entry 5454 (class 2606 OID 23247)
-- Name: ride_events ride_events_ride_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_events
    ADD CONSTRAINT ride_events_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE CASCADE;


--
-- TOC entry 5464 (class 2606 OID 23513)
-- Name: ride_incidents ride_incidents_assigned_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_incidents
    ADD CONSTRAINT ride_incidents_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.profiles(id) ON DELETE SET NULL;


--
-- TOC entry 5465 (class 2606 OID 23498)
-- Name: ride_incidents ride_incidents_reporter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_incidents
    ADD CONSTRAINT ride_incidents_reporter_id_fkey FOREIGN KEY (reporter_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5466 (class 2606 OID 23493)
-- Name: ride_incidents ride_incidents_ride_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_incidents
    ADD CONSTRAINT ride_incidents_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE CASCADE;


--
-- TOC entry 5461 (class 2606 OID 23450)
-- Name: ride_ratings ride_ratings_ratee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_ratings
    ADD CONSTRAINT ride_ratings_ratee_id_fkey FOREIGN KEY (ratee_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5462 (class 2606 OID 23445)
-- Name: ride_ratings ride_ratings_rater_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_ratings
    ADD CONSTRAINT ride_ratings_rater_id_fkey FOREIGN KEY (rater_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5463 (class 2606 OID 23440)
-- Name: ride_ratings ride_ratings_ride_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_ratings
    ADD CONSTRAINT ride_ratings_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE CASCADE;


--
-- TOC entry 5460 (class 2606 OID 23421)
-- Name: ride_receipts ride_receipts_ride_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_receipts
    ADD CONSTRAINT ride_receipts_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE CASCADE;


--
-- TOC entry 5447 (class 2606 OID 23186)
-- Name: ride_requests ride_requests_assigned_driver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_requests
    ADD CONSTRAINT ride_requests_assigned_driver_id_fkey FOREIGN KEY (assigned_driver_id) REFERENCES public.drivers(id) ON DELETE SET NULL;


--
-- TOC entry 5448 (class 2606 OID 23181)
-- Name: ride_requests ride_requests_rider_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_requests
    ADD CONSTRAINT ride_requests_rider_id_fkey FOREIGN KEY (rider_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5449 (class 2606 OID 23226)
-- Name: rides rides_driver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rides
    ADD CONSTRAINT rides_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(id) ON DELETE CASCADE;


--
-- TOC entry 5450 (class 2606 OID 23345)
-- Name: rides rides_payment_intent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rides
    ADD CONSTRAINT rides_payment_intent_id_fkey FOREIGN KEY (payment_intent_id) REFERENCES public.payment_intents(id) ON DELETE SET NULL;


--
-- TOC entry 5451 (class 2606 OID 23216)
-- Name: rides rides_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rides
    ADD CONSTRAINT rides_request_id_fkey FOREIGN KEY (request_id) REFERENCES public.ride_requests(id) ON DELETE CASCADE;


--
-- TOC entry 5452 (class 2606 OID 23221)
-- Name: rides rides_rider_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rides
    ADD CONSTRAINT rides_rider_id_fkey FOREIGN KEY (rider_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5453 (class 2606 OID 23728)
-- Name: rides rides_wallet_hold_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rides
    ADD CONSTRAINT rides_wallet_hold_id_fkey FOREIGN KEY (wallet_hold_id) REFERENCES public.wallet_holds(id) ON DELETE SET NULL;


--
-- TOC entry 5472 (class 2606 OID 23693)
-- Name: topup_intents topup_intents_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.topup_intents
    ADD CONSTRAINT topup_intents_package_id_fkey FOREIGN KEY (package_id) REFERENCES public.topup_packages(id);


--
-- TOC entry 5473 (class 2606 OID 23688)
-- Name: topup_intents topup_intents_provider_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.topup_intents
    ADD CONSTRAINT topup_intents_provider_code_fkey FOREIGN KEY (provider_code) REFERENCES public.payment_providers(code);


--
-- TOC entry 5474 (class 2606 OID 23683)
-- Name: topup_intents topup_intents_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.topup_intents
    ADD CONSTRAINT topup_intents_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5481 (class 2606 OID 23999)
-- Name: user_notifications user_notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_notifications
    ADD CONSTRAINT user_notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5467 (class 2606 OID 23578)
-- Name: wallet_accounts wallet_accounts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallet_accounts
    ADD CONSTRAINT wallet_accounts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5468 (class 2606 OID 23597)
-- Name: wallet_entries wallet_entries_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallet_entries
    ADD CONSTRAINT wallet_entries_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5469 (class 2606 OID 23621)
-- Name: wallet_holds wallet_holds_ride_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallet_holds
    ADD CONSTRAINT wallet_holds_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE SET NULL;


--
-- TOC entry 5470 (class 2606 OID 23616)
-- Name: wallet_holds wallet_holds_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallet_holds
    ADD CONSTRAINT wallet_holds_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5471 (class 2606 OID 23906)
-- Name: wallet_holds wallet_holds_withdraw_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallet_holds
    ADD CONSTRAINT wallet_holds_withdraw_request_id_fkey FOREIGN KEY (withdraw_request_id) REFERENCES public.wallet_withdraw_requests(id) ON DELETE SET NULL;


--
-- TOC entry 5480 (class 2606 OID 23981)
-- Name: wallet_withdraw_payout_methods wallet_withdraw_payout_methods_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallet_withdraw_payout_methods
    ADD CONSTRAINT wallet_withdraw_payout_methods_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.profiles(id) ON DELETE SET NULL;


--
-- TOC entry 5476 (class 2606 OID 23896)
-- Name: wallet_withdraw_requests wallet_withdraw_requests_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallet_withdraw_requests
    ADD CONSTRAINT wallet_withdraw_requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5479 (class 2606 OID 23965)
-- Name: wallet_withdrawal_policy wallet_withdrawal_policy_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallet_withdrawal_policy
    ADD CONSTRAINT wallet_withdrawal_policy_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.profiles(id) ON DELETE SET NULL;


--
-- TOC entry 5437 (class 2606 OID 17285)
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- TOC entry 5441 (class 2606 OID 17387)
-- Name: prefixes prefixes_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.prefixes
    ADD CONSTRAINT "prefixes_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- TOC entry 5438 (class 2606 OID 17333)
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- TOC entry 5439 (class 2606 OID 17353)
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- TOC entry 5440 (class 2606 OID 17348)
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES storage.s3_multipart_uploads(id) ON DELETE CASCADE;


--
-- TOC entry 5442 (class 2606 OID 17469)
-- Name: vector_indexes vector_indexes_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets_vectors(id);


--
-- TOC entry 5678 (class 0 OID 16525)
-- Dependencies: 349
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5689 (class 0 OID 16883)
-- Dependencies: 363
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5680 (class 0 OID 16681)
-- Dependencies: 354
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5677 (class 0 OID 16518)
-- Dependencies: 348
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5684 (class 0 OID 16770)
-- Dependencies: 358
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5683 (class 0 OID 16758)
-- Dependencies: 357
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5682 (class 0 OID 16745)
-- Dependencies: 356
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5690 (class 0 OID 16933)
-- Dependencies: 364
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5676 (class 0 OID 16507)
-- Dependencies: 347
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5687 (class 0 OID 16812)
-- Dependencies: 361
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5688 (class 0 OID 16830)
-- Dependencies: 362
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5679 (class 0 OID 16533)
-- Dependencies: 350
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5681 (class 0 OID 16711)
-- Dependencies: 355
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5686 (class 0 OID 16797)
-- Dependencies: 360
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5685 (class 0 OID 16788)
-- Dependencies: 359
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5675 (class 0 OID 16495)
-- Dependencies: 345
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5712 (class 0 OID 23378)
-- Dependencies: 402
-- Name: api_rate_limits; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.api_rate_limits ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5739 (class 3256 OID 23386)
-- Name: api_rate_limits api_rate_limits_select_none; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY api_rate_limits_select_none ON public.api_rate_limits FOR SELECT TO authenticated USING (false);


--
-- TOC entry 5711 (class 0 OID 23352)
-- Dependencies: 401
-- Name: app_events; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.app_events ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5738 (class 3256 OID 23377)
-- Name: app_events app_events_select_none; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY app_events_select_none ON public.app_events FOR SELECT TO authenticated USING (false);


--
-- TOC entry 5704 (class 0 OID 23138)
-- Dependencies: 393
-- Name: driver_locations; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.driver_locations ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5780 (class 3256 OID 23159)
-- Name: driver_locations driver_locations_insert_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY driver_locations_insert_own ON public.driver_locations FOR INSERT TO authenticated WITH CHECK ((( SELECT ( SELECT auth.uid() AS uid) AS uid) = driver_id));


--
-- TOC entry 5768 (class 3256 OID 23158)
-- Name: driver_locations driver_locations_select_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY driver_locations_select_own ON public.driver_locations FOR SELECT TO authenticated USING ((( SELECT ( SELECT auth.uid() AS uid) AS uid) = driver_id));


--
-- TOC entry 5781 (class 3256 OID 23160)
-- Name: driver_locations driver_locations_update_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY driver_locations_update_own ON public.driver_locations FOR UPDATE TO authenticated USING ((( SELECT ( SELECT auth.uid() AS uid) AS uid) = driver_id)) WITH CHECK ((( SELECT ( SELECT auth.uid() AS uid) AS uid) = driver_id));


--
-- TOC entry 5703 (class 0 OID 23116)
-- Dependencies: 392
-- Name: driver_vehicles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.driver_vehicles ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5765 (class 3256 OID 23136)
-- Name: driver_vehicles driver_vehicles_insert_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY driver_vehicles_insert_own ON public.driver_vehicles FOR INSERT TO authenticated WITH CHECK ((( SELECT ( SELECT auth.uid() AS uid) AS uid) = driver_id));


--
-- TOC entry 5779 (class 3256 OID 23135)
-- Name: driver_vehicles driver_vehicles_select_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY driver_vehicles_select_own ON public.driver_vehicles FOR SELECT TO authenticated USING ((( SELECT ( SELECT auth.uid() AS uid) AS uid) = driver_id));


--
-- TOC entry 5766 (class 3256 OID 23137)
-- Name: driver_vehicles driver_vehicles_update_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY driver_vehicles_update_own ON public.driver_vehicles FOR UPDATE TO authenticated USING ((( SELECT ( SELECT auth.uid() AS uid) AS uid) = driver_id)) WITH CHECK ((( SELECT ( SELECT auth.uid() AS uid) AS uid) = driver_id));


--
-- TOC entry 5702 (class 0 OID 23095)
-- Dependencies: 391
-- Name: drivers; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.drivers ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5763 (class 3256 OID 23114)
-- Name: drivers drivers_insert_self; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY drivers_insert_self ON public.drivers FOR INSERT TO authenticated WITH CHECK ((( SELECT ( SELECT auth.uid() AS uid) AS uid) = id));


--
-- TOC entry 5778 (class 3256 OID 23113)
-- Name: drivers drivers_select_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY drivers_select_own ON public.drivers FOR SELECT TO authenticated USING ((( SELECT ( SELECT auth.uid() AS uid) AS uid) = id));


--
-- TOC entry 5764 (class 3256 OID 23115)
-- Name: drivers drivers_update_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY drivers_update_own ON public.drivers FOR UPDATE TO authenticated USING ((( SELECT ( SELECT auth.uid() AS uid) AS uid) = id)) WITH CHECK ((( SELECT ( SELECT auth.uid() AS uid) AS uid) = id));


--
-- TOC entry 5728 (class 0 OID 24198)
-- Dependencies: 434
-- Name: gift_codes; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.gift_codes ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5729 (class 3256 OID 24230)
-- Name: gift_codes gift_codes_admin_insert; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY gift_codes_admin_insert ON public.gift_codes FOR INSERT TO authenticated WITH CHECK (public.is_admin());


--
-- TOC entry 5730 (class 3256 OID 24231)
-- Name: gift_codes gift_codes_admin_update; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY gift_codes_admin_update ON public.gift_codes FOR UPDATE TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());


--
-- TOC entry 5735 (class 3256 OID 24229)
-- Name: gift_codes gift_codes_select_admin_or_redeemer; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY gift_codes_select_admin_or_redeemer ON public.gift_codes FOR SELECT TO authenticated USING ((public.is_admin() OR (redeemed_by = ( SELECT auth.uid() AS uid))));


--
-- TOC entry 5710 (class 0 OID 23319)
-- Dependencies: 400
-- Name: payment_intents; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.payment_intents ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5772 (class 3256 OID 23340)
-- Name: payment_intents payment_intents_select_participants; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY payment_intents_select_participants ON public.payment_intents FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.rides r
  WHERE ((r.id = payment_intents.ride_id) AND ((r.rider_id = ( SELECT ( SELECT auth.uid() AS uid) AS uid)) OR (r.driver_id = ( SELECT ( SELECT auth.uid() AS uid) AS uid)))))));


--
-- TOC entry 5719 (class 0 OID 23630)
-- Dependencies: 410
-- Name: payment_providers; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.payment_providers ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5734 (class 3256 OID 23646)
-- Name: payment_providers payment_providers_admin_delete; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY payment_providers_admin_delete ON public.payment_providers FOR DELETE TO authenticated USING (public.is_admin());


--
-- TOC entry 5732 (class 3256 OID 23644)
-- Name: payment_providers payment_providers_admin_insert; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY payment_providers_admin_insert ON public.payment_providers FOR INSERT TO authenticated WITH CHECK (public.is_admin());


--
-- TOC entry 5733 (class 3256 OID 23645)
-- Name: payment_providers payment_providers_admin_update; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY payment_providers_admin_update ON public.payment_providers FOR UPDATE TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());


--
-- TOC entry 5731 (class 3256 OID 23643)
-- Name: payment_providers payment_providers_select_authenticated; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY payment_providers_select_authenticated ON public.payment_providers FOR SELECT TO authenticated USING (true);


--
-- TOC entry 5708 (class 0 OID 23255)
-- Dependencies: 398
-- Name: payments; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5762 (class 3256 OID 23271)
-- Name: payments payments_select_participants; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY payments_select_participants ON public.payments FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.rides r
  WHERE ((r.id = payments.ride_id) AND ((( SELECT ( SELECT auth.uid() AS uid) AS uid) = r.rider_id) OR (( SELECT ( SELECT auth.uid() AS uid) AS uid) = r.driver_id) OR ( SELECT public.is_admin() AS is_admin))))));


--
-- TOC entry 5709 (class 0 OID 23277)
-- Dependencies: 399
-- Name: pricing_configs; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.pricing_configs ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5737 (class 3256 OID 23294)
-- Name: pricing_configs pricing_configs_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY pricing_configs_select ON public.pricing_configs FOR SELECT TO authenticated USING (false);


--
-- TOC entry 5724 (class 0 OID 23925)
-- Dependencies: 425
-- Name: profile_kyc; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.profile_kyc ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5760 (class 3256 OID 24195)
-- Name: profile_kyc profile_kyc_admin_delete; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY profile_kyc_admin_delete ON public.profile_kyc FOR DELETE USING ((( SELECT public.is_admin() AS is_admin) OR public.is_admin()));


--
-- TOC entry 5744 (class 3256 OID 24193)
-- Name: profile_kyc profile_kyc_admin_insert; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY profile_kyc_admin_insert ON public.profile_kyc FOR INSERT WITH CHECK ((( SELECT public.is_admin() AS is_admin) OR public.is_admin()));


--
-- TOC entry 5745 (class 3256 OID 24194)
-- Name: profile_kyc profile_kyc_admin_update; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY profile_kyc_admin_update ON public.profile_kyc FOR UPDATE USING ((( SELECT public.is_admin() AS is_admin) OR public.is_admin())) WITH CHECK ((( SELECT public.is_admin() AS is_admin) OR public.is_admin()));


--
-- TOC entry 5785 (class 3256 OID 23945)
-- Name: profile_kyc profile_kyc_select_own_or_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY profile_kyc_select_own_or_admin ON public.profile_kyc FOR SELECT USING (((user_id = ( SELECT ( SELECT auth.uid() AS uid) AS uid)) OR public.is_admin() OR public.is_admin()));


--
-- TOC entry 5701 (class 0 OID 23076)
-- Dependencies: 390
-- Name: profiles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5747 (class 3256 OID 23512)
-- Name: profiles profiles_select_own_or_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY profiles_select_own_or_admin ON public.profiles FOR SELECT TO authenticated USING (((id = ( SELECT ( SELECT auth.uid() AS uid) AS uid)) OR public.is_admin()));


--
-- TOC entry 5777 (class 3256 OID 23092)
-- Name: profiles profiles_update_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY profiles_update_own ON public.profiles FOR UPDATE TO authenticated USING ((( SELECT ( SELECT auth.uid() AS uid) AS uid) = id)) WITH CHECK ((( SELECT ( SELECT auth.uid() AS uid) AS uid) = id));


--
-- TOC entry 5722 (class 0 OID 23706)
-- Dependencies: 414
-- Name: provider_events; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.provider_events ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5751 (class 3256 OID 23723)
-- Name: provider_events provider_events_admin_insert; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY provider_events_admin_insert ON public.provider_events FOR INSERT TO authenticated WITH CHECK (public.is_admin());


--
-- TOC entry 5750 (class 3256 OID 23722)
-- Name: provider_events provider_events_admin_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY provider_events_admin_select ON public.provider_events FOR SELECT TO authenticated USING (public.is_admin());


--
-- TOC entry 5707 (class 0 OID 23237)
-- Dependencies: 397
-- Name: ride_events; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.ride_events ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5770 (class 3256 OID 23254)
-- Name: ride_events ride_events_select_participants; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY ride_events_select_participants ON public.ride_events FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.rides r
  WHERE ((r.id = ride_events.ride_id) AND ((r.rider_id = ( SELECT ( SELECT auth.uid() AS uid) AS uid)) OR (r.driver_id = ( SELECT ( SELECT auth.uid() AS uid) AS uid)))))));


--
-- TOC entry 5715 (class 0 OID 23481)
-- Dependencies: 405
-- Name: ride_incidents; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.ride_incidents ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5746 (class 3256 OID 23521)
-- Name: ride_incidents ride_incidents_admin_update; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY ride_incidents_admin_update ON public.ride_incidents FOR UPDATE TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());


--
-- TOC entry 5775 (class 3256 OID 23520)
-- Name: ride_incidents ride_incidents_select_reporter_participant_or_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY ride_incidents_select_reporter_participant_or_admin ON public.ride_incidents FOR SELECT TO authenticated USING ((public.is_admin() OR (reporter_id = ( SELECT ( SELECT auth.uid() AS uid) AS uid)) OR (EXISTS ( SELECT 1
   FROM public.rides r
  WHERE ((r.id = ride_incidents.ride_id) AND ((r.rider_id = ( SELECT ( SELECT auth.uid() AS uid) AS uid)) OR (r.driver_id = ( SELECT ( SELECT auth.uid() AS uid) AS uid))))))));


--
-- TOC entry 5714 (class 0 OID 23430)
-- Dependencies: 404
-- Name: ride_ratings; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.ride_ratings ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5774 (class 3256 OID 23458)
-- Name: ride_ratings ride_ratings_select_participants; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY ride_ratings_select_participants ON public.ride_ratings FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.rides r
  WHERE ((r.id = ride_ratings.ride_id) AND ((r.rider_id = ( SELECT ( SELECT auth.uid() AS uid) AS uid)) OR (r.driver_id = ( SELECT ( SELECT auth.uid() AS uid) AS uid)))))));


--
-- TOC entry 5713 (class 0 OID 23410)
-- Dependencies: 403
-- Name: ride_receipts; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.ride_receipts ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5773 (class 3256 OID 23427)
-- Name: ride_receipts ride_receipts_select_participants; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY ride_receipts_select_participants ON public.ride_receipts FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.rides r
  WHERE ((r.id = ride_receipts.ride_id) AND ((r.rider_id = ( SELECT ( SELECT auth.uid() AS uid) AS uid)) OR (r.driver_id = ( SELECT ( SELECT auth.uid() AS uid) AS uid)))))));


--
-- TOC entry 5705 (class 0 OID 23161)
-- Dependencies: 394
-- Name: ride_requests; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.ride_requests ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5736 (class 3256 OID 23197)
-- Name: ride_requests ride_requests_insert_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY ride_requests_insert_own ON public.ride_requests FOR INSERT TO authenticated WITH CHECK ((( SELECT ( SELECT auth.uid() AS uid) AS uid) = rider_id));


--
-- TOC entry 5786 (class 3256 OID 23196)
-- Name: ride_requests ride_requests_select_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY ride_requests_select_own ON public.ride_requests FOR SELECT TO authenticated USING (((( SELECT ( SELECT auth.uid() AS uid) AS uid) = rider_id) OR (( SELECT ( SELECT auth.uid() AS uid) AS uid) = assigned_driver_id) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 5743 (class 3256 OID 23341)
-- Name: ride_requests ride_requests_update_own_cancel; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY ride_requests_update_own_cancel ON public.ride_requests FOR UPDATE TO authenticated USING (((( SELECT ( SELECT auth.uid() AS uid) AS uid) = rider_id) AND (status = ANY (ARRAY['requested'::public.ride_request_status, 'matched'::public.ride_request_status, 'no_driver'::public.ride_request_status, 'expired'::public.ride_request_status])))) WITH CHECK (((( SELECT ( SELECT auth.uid() AS uid) AS uid) = rider_id) AND (status = 'cancelled'::public.ride_request_status)));


--
-- TOC entry 5706 (class 0 OID 23200)
-- Dependencies: 395
-- Name: rides; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.rides ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5769 (class 3256 OID 23235)
-- Name: rides rides_select_participants; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rides_select_participants ON public.rides FOR SELECT TO authenticated USING (((( SELECT ( SELECT auth.uid() AS uid) AS uid) = rider_id) OR (( SELECT ( SELECT auth.uid() AS uid) AS uid) = driver_id)));


--
-- TOC entry 5721 (class 0 OID 23668)
-- Dependencies: 412
-- Name: topup_intents; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.topup_intents ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5749 (class 3256 OID 23704)
-- Name: topup_intents topup_intents_admin_update; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY topup_intents_admin_update ON public.topup_intents FOR UPDATE TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());


--
-- TOC entry 5758 (class 3256 OID 23703)
-- Name: topup_intents topup_intents_insert_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY topup_intents_insert_own ON public.topup_intents FOR INSERT TO authenticated WITH CHECK (((user_id = ( SELECT ( SELECT auth.uid() AS uid) AS uid)) AND (status = 'created'::public.topup_status)));


--
-- TOC entry 5757 (class 3256 OID 23702)
-- Name: topup_intents topup_intents_select_own_or_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY topup_intents_select_own_or_admin ON public.topup_intents FOR SELECT TO authenticated USING (((user_id = ( SELECT ( SELECT auth.uid() AS uid) AS uid)) OR public.is_admin()));


--
-- TOC entry 5720 (class 0 OID 23647)
-- Dependencies: 411
-- Name: topup_packages; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.topup_packages ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5748 (class 3256 OID 23667)
-- Name: topup_packages topup_packages_admin_delete; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY topup_packages_admin_delete ON public.topup_packages FOR DELETE TO authenticated USING (public.is_admin());


--
-- TOC entry 5741 (class 3256 OID 23665)
-- Name: topup_packages topup_packages_admin_insert; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY topup_packages_admin_insert ON public.topup_packages FOR INSERT TO authenticated WITH CHECK (public.is_admin());


--
-- TOC entry 5742 (class 3256 OID 23666)
-- Name: topup_packages topup_packages_admin_update; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY topup_packages_admin_update ON public.topup_packages FOR UPDATE TO authenticated USING (public.is_admin()) WITH CHECK (public.is_admin());


--
-- TOC entry 5740 (class 3256 OID 23664)
-- Name: topup_packages topup_packages_select_active_or_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY topup_packages_select_active_or_admin ON public.topup_packages FOR SELECT TO authenticated USING ((active OR public.is_admin()));


--
-- TOC entry 5727 (class 0 OID 23989)
-- Dependencies: 428
-- Name: user_notifications; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.user_notifications ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5761 (class 3256 OID 24005)
-- Name: user_notifications user_notifications_select_own_or_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY user_notifications_select_own_or_admin ON public.user_notifications FOR SELECT USING (((user_id = ( SELECT ( SELECT auth.uid() AS uid) AS uid)) OR public.is_admin()));


--
-- TOC entry 5756 (class 3256 OID 24006)
-- Name: user_notifications user_notifications_update_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY user_notifications_update_own ON public.user_notifications FOR UPDATE USING (((user_id = ( SELECT ( SELECT auth.uid() AS uid) AS uid)) OR public.is_admin())) WITH CHECK (((user_id = ( SELECT ( SELECT auth.uid() AS uid) AS uid)) OR public.is_admin()));


--
-- TOC entry 5716 (class 0 OID 23567)
-- Dependencies: 406
-- Name: wallet_accounts; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.wallet_accounts ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5782 (class 3256 OID 23585)
-- Name: wallet_accounts wallet_accounts_insert_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY wallet_accounts_insert_own ON public.wallet_accounts FOR INSERT TO authenticated WITH CHECK ((user_id = ( SELECT ( SELECT auth.uid() AS uid) AS uid)));


--
-- TOC entry 5776 (class 3256 OID 23584)
-- Name: wallet_accounts wallet_accounts_select_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY wallet_accounts_select_own ON public.wallet_accounts FOR SELECT TO authenticated USING ((user_id = ( SELECT ( SELECT auth.uid() AS uid) AS uid)));


--
-- TOC entry 5717 (class 0 OID 23587)
-- Dependencies: 408
-- Name: wallet_entries; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.wallet_entries ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5783 (class 3256 OID 23604)
-- Name: wallet_entries wallet_entries_select_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY wallet_entries_select_own ON public.wallet_entries FOR SELECT TO authenticated USING ((user_id = ( SELECT ( SELECT auth.uid() AS uid) AS uid)));


--
-- TOC entry 5718 (class 0 OID 23605)
-- Dependencies: 409
-- Name: wallet_holds; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.wallet_holds ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5784 (class 3256 OID 23629)
-- Name: wallet_holds wallet_holds_select_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY wallet_holds_select_own ON public.wallet_holds FOR SELECT TO authenticated USING ((user_id = ( SELECT ( SELECT auth.uid() AS uid) AS uid)));


--
-- TOC entry 5726 (class 0 OID 23973)
-- Dependencies: 427
-- Name: wallet_withdraw_payout_methods; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.wallet_withdraw_payout_methods ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5723 (class 0 OID 23883)
-- Dependencies: 424
-- Name: wallet_withdraw_requests; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.wallet_withdraw_requests ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5725 (class 0 OID 23949)
-- Dependencies: 426
-- Name: wallet_withdrawal_policy; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.wallet_withdrawal_policy ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5771 (class 3256 OID 23914)
-- Name: wallet_withdraw_requests withdraw_insert_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY withdraw_insert_own ON public.wallet_withdraw_requests FOR INSERT WITH CHECK ((user_id = ( SELECT ( SELECT auth.uid() AS uid) AS uid)));


--
-- TOC entry 5755 (class 3256 OID 23988)
-- Name: wallet_withdraw_payout_methods withdraw_payout_methods_admin_update; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY withdraw_payout_methods_admin_update ON public.wallet_withdraw_payout_methods FOR UPDATE USING (public.is_admin()) WITH CHECK (public.is_admin());


--
-- TOC entry 5754 (class 3256 OID 23987)
-- Name: wallet_withdraw_payout_methods withdraw_payout_methods_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY withdraw_payout_methods_select ON public.wallet_withdraw_payout_methods FOR SELECT TO authenticated USING (true);


--
-- TOC entry 5753 (class 3256 OID 23972)
-- Name: wallet_withdrawal_policy withdraw_policy_admin_update; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY withdraw_policy_admin_update ON public.wallet_withdrawal_policy FOR UPDATE USING (public.is_admin()) WITH CHECK (public.is_admin());


--
-- TOC entry 5752 (class 3256 OID 23971)
-- Name: wallet_withdrawal_policy withdraw_policy_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY withdraw_policy_select ON public.wallet_withdrawal_policy FOR SELECT TO authenticated USING (true);


--
-- TOC entry 5759 (class 3256 OID 23913)
-- Name: wallet_withdraw_requests withdraw_select_own_or_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY withdraw_select_own_or_admin ON public.wallet_withdraw_requests FOR SELECT USING (((user_id = ( SELECT ( SELECT auth.uid() AS uid) AS uid)) OR public.is_admin()));


--
-- TOC entry 5767 (class 3256 OID 23915)
-- Name: wallet_withdraw_requests withdraw_update_admin_or_cancel_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY withdraw_update_admin_or_cancel_own ON public.wallet_withdraw_requests FOR UPDATE USING ((public.is_admin() OR ((user_id = ( SELECT ( SELECT auth.uid() AS uid) AS uid)) AND (status = 'requested'::public.withdraw_request_status)))) WITH CHECK ((public.is_admin() OR ((user_id = ( SELECT ( SELECT auth.uid() AS uid) AS uid)) AND (status = ANY (ARRAY['requested'::public.withdraw_request_status, 'cancelled'::public.withdraw_request_status])))));


--
-- TOC entry 5691 (class 0 OID 17239)
-- Dependencies: 375
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE realtime.messages ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5693 (class 0 OID 17264)
-- Dependencies: 377
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5698 (class 0 OID 17422)
-- Dependencies: 382
-- Name: buckets_analytics; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.buckets_analytics ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5699 (class 0 OID 17449)
-- Dependencies: 383
-- Name: buckets_vectors; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.buckets_vectors ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5692 (class 0 OID 17256)
-- Dependencies: 376
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.migrations ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5694 (class 0 OID 17274)
-- Dependencies: 378
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5697 (class 0 OID 17377)
-- Dependencies: 381
-- Name: prefixes; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.prefixes ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5695 (class 0 OID 17324)
-- Dependencies: 379
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.s3_multipart_uploads ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5696 (class 0 OID 17338)
-- Dependencies: 380
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.s3_multipart_uploads_parts ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5700 (class 0 OID 17459)
-- Dependencies: 384
-- Name: vector_indexes; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.vector_indexes ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 5787 (class 6104 OID 16426)
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: postgres
--

CREATE PUBLICATION supabase_realtime WITH (publish = 'insert, update, delete, truncate');


ALTER PUBLICATION supabase_realtime OWNER TO postgres;

--
-- TOC entry 5788 (class 6104 OID 24115)
-- Name: supabase_realtime_messages_publication; Type: PUBLICATION; Schema: -; Owner: supabase_admin
--

CREATE PUBLICATION supabase_realtime_messages_publication WITH (publish = 'insert, update, delete, truncate');


ALTER PUBLICATION supabase_realtime_messages_publication OWNER TO supabase_admin;

--
-- TOC entry 5792 (class 6106 OID 23746)
-- Name: supabase_realtime topup_intents; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.topup_intents;


--
-- TOC entry 5794 (class 6106 OID 24023)
-- Name: supabase_realtime user_notifications; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.user_notifications;


--
-- TOC entry 5789 (class 6106 OID 23743)
-- Name: supabase_realtime wallet_accounts; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.wallet_accounts;


--
-- TOC entry 5790 (class 6106 OID 23744)
-- Name: supabase_realtime wallet_entries; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.wallet_entries;


--
-- TOC entry 5791 (class 6106 OID 23745)
-- Name: supabase_realtime wallet_holds; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.wallet_holds;


--
-- TOC entry 5793 (class 6106 OID 24022)
-- Name: supabase_realtime wallet_withdraw_requests; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.wallet_withdraw_requests;


--
-- TOC entry 5795 (class 6106 OID 24116)
-- Name: supabase_realtime_messages_publication messages; Type: PUBLICATION TABLE; Schema: realtime; Owner: supabase_admin
--

ALTER PUBLICATION supabase_realtime_messages_publication ADD TABLE ONLY realtime.messages;


--
-- TOC entry 5801 (class 0 OID 0)
-- Dependencies: 40
-- Name: SCHEMA auth; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA auth TO anon;
GRANT USAGE ON SCHEMA auth TO authenticated;
GRANT USAGE ON SCHEMA auth TO service_role;
GRANT ALL ON SCHEMA auth TO supabase_auth_admin;
GRANT ALL ON SCHEMA auth TO dashboard_user;
GRANT USAGE ON SCHEMA auth TO postgres;


--
-- TOC entry 5803 (class 0 OID 0)
-- Dependencies: 46
-- Name: SCHEMA cron; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA cron TO postgres WITH GRANT OPTION;


--
-- TOC entry 5804 (class 0 OID 0)
-- Dependencies: 26
-- Name: SCHEMA extensions; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA extensions TO anon;
GRANT USAGE ON SCHEMA extensions TO authenticated;
GRANT USAGE ON SCHEMA extensions TO service_role;
GRANT ALL ON SCHEMA extensions TO dashboard_user;


--
-- TOC entry 5806 (class 0 OID 0)
-- Dependencies: 48
-- Name: SCHEMA net; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA net TO supabase_functions_admin;
GRANT USAGE ON SCHEMA net TO postgres;
GRANT USAGE ON SCHEMA net TO anon;
GRANT USAGE ON SCHEMA net TO authenticated;
GRANT USAGE ON SCHEMA net TO service_role;


--
-- TOC entry 5807 (class 0 OID 0)
-- Dependencies: 14
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO postgres;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO service_role;


--
-- TOC entry 5808 (class 0 OID 0)
-- Dependencies: 12
-- Name: SCHEMA realtime; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA realtime TO postgres;
GRANT USAGE ON SCHEMA realtime TO anon;
GRANT USAGE ON SCHEMA realtime TO authenticated;
GRANT USAGE ON SCHEMA realtime TO service_role;
GRANT ALL ON SCHEMA realtime TO supabase_realtime_admin;


--
-- TOC entry 5809 (class 0 OID 0)
-- Dependencies: 41
-- Name: SCHEMA storage; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA storage TO postgres WITH GRANT OPTION;
GRANT USAGE ON SCHEMA storage TO anon;
GRANT USAGE ON SCHEMA storage TO authenticated;
GRANT USAGE ON SCHEMA storage TO service_role;
GRANT ALL ON SCHEMA storage TO supabase_storage_admin WITH GRANT OPTION;
GRANT ALL ON SCHEMA storage TO dashboard_user;


--
-- TOC entry 5810 (class 0 OID 0)
-- Dependencies: 35
-- Name: SCHEMA vault; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA vault TO postgres WITH GRANT OPTION;
GRANT USAGE ON SCHEMA vault TO service_role;


--
-- TOC entry 5817 (class 0 OID 0)
-- Dependencies: 583
-- Name: FUNCTION box2d_in(cstring); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.box2d_in(cstring) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5818 (class 0 OID 0)
-- Dependencies: 584
-- Name: FUNCTION box2d_out(extensions.box2d); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.box2d_out(extensions.box2d) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5819 (class 0 OID 0)
-- Dependencies: 585
-- Name: FUNCTION box2df_in(cstring); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.box2df_in(cstring) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5820 (class 0 OID 0)
-- Dependencies: 586
-- Name: FUNCTION box2df_out(extensions.box2df); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.box2df_out(extensions.box2df) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5821 (class 0 OID 0)
-- Dependencies: 581
-- Name: FUNCTION box3d_in(cstring); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.box3d_in(cstring) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5822 (class 0 OID 0)
-- Dependencies: 582
-- Name: FUNCTION box3d_out(extensions.box3d); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.box3d_out(extensions.box3d) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5823 (class 0 OID 0)
-- Dependencies: 1107
-- Name: FUNCTION geography_analyze(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_analyze(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5824 (class 0 OID 0)
-- Dependencies: 1103
-- Name: FUNCTION geography_in(cstring, oid, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_in(cstring, oid, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5825 (class 0 OID 0)
-- Dependencies: 1104
-- Name: FUNCTION geography_out(extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_out(extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5826 (class 0 OID 0)
-- Dependencies: 1105
-- Name: FUNCTION geography_recv(internal, oid, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_recv(internal, oid, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5827 (class 0 OID 0)
-- Dependencies: 1106
-- Name: FUNCTION geography_send(extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_send(extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5828 (class 0 OID 0)
-- Dependencies: 1101
-- Name: FUNCTION geography_typmod_in(cstring[]); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_typmod_in(cstring[]) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5829 (class 0 OID 0)
-- Dependencies: 1102
-- Name: FUNCTION geography_typmod_out(integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_typmod_out(integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5830 (class 0 OID 0)
-- Dependencies: 567
-- Name: FUNCTION geometry_analyze(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_analyze(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5831 (class 0 OID 0)
-- Dependencies: 563
-- Name: FUNCTION geometry_in(cstring); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_in(cstring) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5832 (class 0 OID 0)
-- Dependencies: 564
-- Name: FUNCTION geometry_out(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_out(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5833 (class 0 OID 0)
-- Dependencies: 568
-- Name: FUNCTION geometry_recv(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_recv(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5834 (class 0 OID 0)
-- Dependencies: 569
-- Name: FUNCTION geometry_send(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_send(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5835 (class 0 OID 0)
-- Dependencies: 565
-- Name: FUNCTION geometry_typmod_in(cstring[]); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_typmod_in(cstring[]) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5836 (class 0 OID 0)
-- Dependencies: 566
-- Name: FUNCTION geometry_typmod_out(integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_typmod_out(integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5837 (class 0 OID 0)
-- Dependencies: 587
-- Name: FUNCTION gidx_in(cstring); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gidx_in(cstring) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5838 (class 0 OID 0)
-- Dependencies: 588
-- Name: FUNCTION gidx_out(extensions.gidx); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gidx_out(extensions.gidx) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5839 (class 0 OID 0)
-- Dependencies: 561
-- Name: FUNCTION spheroid_in(cstring); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.spheroid_in(cstring) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5840 (class 0 OID 0)
-- Dependencies: 562
-- Name: FUNCTION spheroid_out(extensions.spheroid); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.spheroid_out(extensions.spheroid) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5841 (class 0 OID 0)
-- Dependencies: 815
-- Name: FUNCTION box3d(extensions.box2d); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.box3d(extensions.box2d) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5842 (class 0 OID 0)
-- Dependencies: 819
-- Name: FUNCTION geometry(extensions.box2d); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry(extensions.box2d) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5843 (class 0 OID 0)
-- Dependencies: 816
-- Name: FUNCTION box(extensions.box3d); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.box(extensions.box3d) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5844 (class 0 OID 0)
-- Dependencies: 814
-- Name: FUNCTION box2d(extensions.box3d); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.box2d(extensions.box3d) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5845 (class 0 OID 0)
-- Dependencies: 820
-- Name: FUNCTION geometry(extensions.box3d); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry(extensions.box3d) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5846 (class 0 OID 0)
-- Dependencies: 1109
-- Name: FUNCTION geography(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5847 (class 0 OID 0)
-- Dependencies: 822
-- Name: FUNCTION geometry(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5848 (class 0 OID 0)
-- Dependencies: 1110
-- Name: FUNCTION bytea(extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.bytea(extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5849 (class 0 OID 0)
-- Dependencies: 1108
-- Name: FUNCTION geography(extensions.geography, integer, boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography(extensions.geography, integer, boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5850 (class 0 OID 0)
-- Dependencies: 1121
-- Name: FUNCTION geometry(extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry(extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5851 (class 0 OID 0)
-- Dependencies: 813
-- Name: FUNCTION box(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.box(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5852 (class 0 OID 0)
-- Dependencies: 811
-- Name: FUNCTION box2d(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.box2d(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5853 (class 0 OID 0)
-- Dependencies: 812
-- Name: FUNCTION box3d(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.box3d(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5854 (class 0 OID 0)
-- Dependencies: 823
-- Name: FUNCTION bytea(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.bytea(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5855 (class 0 OID 0)
-- Dependencies: 1120
-- Name: FUNCTION geography(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5856 (class 0 OID 0)
-- Dependencies: 570
-- Name: FUNCTION geometry(extensions.geometry, integer, boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry(extensions.geometry, integer, boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5857 (class 0 OID 0)
-- Dependencies: 979
-- Name: FUNCTION "json"(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions."json"(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5858 (class 0 OID 0)
-- Dependencies: 980
-- Name: FUNCTION jsonb(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.jsonb(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5859 (class 0 OID 0)
-- Dependencies: 574
-- Name: FUNCTION path(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.path(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5860 (class 0 OID 0)
-- Dependencies: 572
-- Name: FUNCTION point(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.point(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5861 (class 0 OID 0)
-- Dependencies: 576
-- Name: FUNCTION polygon(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.polygon(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5862 (class 0 OID 0)
-- Dependencies: 817
-- Name: FUNCTION text(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.text(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5863 (class 0 OID 0)
-- Dependencies: 573
-- Name: FUNCTION geometry(path); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry(path) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5864 (class 0 OID 0)
-- Dependencies: 571
-- Name: FUNCTION geometry(point); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry(point) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5865 (class 0 OID 0)
-- Dependencies: 575
-- Name: FUNCTION geometry(polygon); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry(polygon) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5866 (class 0 OID 0)
-- Dependencies: 821
-- Name: FUNCTION geometry(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5868 (class 0 OID 0)
-- Dependencies: 499
-- Name: FUNCTION email(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.email() TO dashboard_user;


--
-- TOC entry 5869 (class 0 OID 0)
-- Dependencies: 518
-- Name: FUNCTION jwt(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.jwt() TO postgres;
GRANT ALL ON FUNCTION auth.jwt() TO dashboard_user;


--
-- TOC entry 5871 (class 0 OID 0)
-- Dependencies: 498
-- Name: FUNCTION role(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.role() TO dashboard_user;


--
-- TOC entry 5873 (class 0 OID 0)
-- Dependencies: 497
-- Name: FUNCTION uid(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.uid() TO dashboard_user;


--
-- TOC entry 5874 (class 0 OID 0)
-- Dependencies: 1313
-- Name: FUNCTION alter_job(job_id bigint, schedule text, command text, database text, username text, active boolean); Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON FUNCTION cron.alter_job(job_id bigint, schedule text, command text, database text, username text, active boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5875 (class 0 OID 0)
-- Dependencies: 1311
-- Name: FUNCTION job_cache_invalidate(); Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON FUNCTION cron.job_cache_invalidate() TO postgres WITH GRANT OPTION;


--
-- TOC entry 5876 (class 0 OID 0)
-- Dependencies: 1309
-- Name: FUNCTION schedule(schedule text, command text); Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON FUNCTION cron.schedule(schedule text, command text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5877 (class 0 OID 0)
-- Dependencies: 1312
-- Name: FUNCTION schedule(job_name text, schedule text, command text); Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON FUNCTION cron.schedule(job_name text, schedule text, command text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5878 (class 0 OID 0)
-- Dependencies: 1314
-- Name: FUNCTION schedule_in_database(job_name text, schedule text, command text, database text, username text, active boolean); Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON FUNCTION cron.schedule_in_database(job_name text, schedule text, command text, database text, username text, active boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5879 (class 0 OID 0)
-- Dependencies: 1310
-- Name: FUNCTION unschedule(job_id bigint); Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON FUNCTION cron.unschedule(job_id bigint) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5880 (class 0 OID 0)
-- Dependencies: 1315
-- Name: FUNCTION unschedule(job_name text); Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON FUNCTION cron.unschedule(job_name text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5881 (class 0 OID 0)
-- Dependencies: 560
-- Name: FUNCTION _postgis_deprecate(oldname text, newname text, version text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._postgis_deprecate(oldname text, newname text, version text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5882 (class 0 OID 0)
-- Dependencies: 609
-- Name: FUNCTION _postgis_index_extent(tbl regclass, col text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._postgis_index_extent(tbl regclass, col text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5883 (class 0 OID 0)
-- Dependencies: 607
-- Name: FUNCTION _postgis_join_selectivity(regclass, text, regclass, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._postgis_join_selectivity(regclass, text, regclass, text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5884 (class 0 OID 0)
-- Dependencies: 808
-- Name: FUNCTION _postgis_pgsql_version(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._postgis_pgsql_version() TO postgres WITH GRANT OPTION;


--
-- TOC entry 5885 (class 0 OID 0)
-- Dependencies: 807
-- Name: FUNCTION _postgis_scripts_pgsql_version(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._postgis_scripts_pgsql_version() TO postgres WITH GRANT OPTION;


--
-- TOC entry 5886 (class 0 OID 0)
-- Dependencies: 606
-- Name: FUNCTION _postgis_selectivity(tbl regclass, att_name text, geom extensions.geometry, mode text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._postgis_selectivity(tbl regclass, att_name text, geom extensions.geometry, mode text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5887 (class 0 OID 0)
-- Dependencies: 608
-- Name: FUNCTION _postgis_stats(tbl regclass, att_name text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._postgis_stats(tbl regclass, att_name text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5888 (class 0 OID 0)
-- Dependencies: 926
-- Name: FUNCTION _st_3ddfullywithin(geom1 extensions.geometry, geom2 extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_3ddfullywithin(geom1 extensions.geometry, geom2 extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5889 (class 0 OID 0)
-- Dependencies: 925
-- Name: FUNCTION _st_3ddwithin(geom1 extensions.geometry, geom2 extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_3ddwithin(geom1 extensions.geometry, geom2 extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5890 (class 0 OID 0)
-- Dependencies: 927
-- Name: FUNCTION _st_3dintersects(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_3dintersects(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5891 (class 0 OID 0)
-- Dependencies: 973
-- Name: FUNCTION _st_asgml(integer, extensions.geometry, integer, integer, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_asgml(integer, extensions.geometry, integer, integer, text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5892 (class 0 OID 0)
-- Dependencies: 1250
-- Name: FUNCTION _st_asx3d(integer, extensions.geometry, integer, integer, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_asx3d(integer, extensions.geometry, integer, integer, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5893 (class 0 OID 0)
-- Dependencies: 1171
-- Name: FUNCTION _st_bestsrid(extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_bestsrid(extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5894 (class 0 OID 0)
-- Dependencies: 1170
-- Name: FUNCTION _st_bestsrid(extensions.geography, extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_bestsrid(extensions.geography, extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5895 (class 0 OID 0)
-- Dependencies: 918
-- Name: FUNCTION _st_contains(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_contains(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5896 (class 0 OID 0)
-- Dependencies: 919
-- Name: FUNCTION _st_containsproperly(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_containsproperly(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5897 (class 0 OID 0)
-- Dependencies: 1186
-- Name: FUNCTION _st_coveredby(geog1 extensions.geography, geog2 extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_coveredby(geog1 extensions.geography, geog2 extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5898 (class 0 OID 0)
-- Dependencies: 921
-- Name: FUNCTION _st_coveredby(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_coveredby(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5899 (class 0 OID 0)
-- Dependencies: 1184
-- Name: FUNCTION _st_covers(geog1 extensions.geography, geog2 extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_covers(geog1 extensions.geography, geog2 extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5900 (class 0 OID 0)
-- Dependencies: 920
-- Name: FUNCTION _st_covers(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_covers(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5901 (class 0 OID 0)
-- Dependencies: 917
-- Name: FUNCTION _st_crosses(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_crosses(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5902 (class 0 OID 0)
-- Dependencies: 924
-- Name: FUNCTION _st_dfullywithin(geom1 extensions.geometry, geom2 extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_dfullywithin(geom1 extensions.geometry, geom2 extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5903 (class 0 OID 0)
-- Dependencies: 1158
-- Name: FUNCTION _st_distancetree(extensions.geography, extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_distancetree(extensions.geography, extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5904 (class 0 OID 0)
-- Dependencies: 1157
-- Name: FUNCTION _st_distancetree(extensions.geography, extensions.geography, double precision, boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_distancetree(extensions.geography, extensions.geography, double precision, boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5905 (class 0 OID 0)
-- Dependencies: 1156
-- Name: FUNCTION _st_distanceuncached(extensions.geography, extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_distanceuncached(extensions.geography, extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5906 (class 0 OID 0)
-- Dependencies: 1155
-- Name: FUNCTION _st_distanceuncached(extensions.geography, extensions.geography, boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_distanceuncached(extensions.geography, extensions.geography, boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5907 (class 0 OID 0)
-- Dependencies: 1154
-- Name: FUNCTION _st_distanceuncached(extensions.geography, extensions.geography, double precision, boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_distanceuncached(extensions.geography, extensions.geography, double precision, boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5908 (class 0 OID 0)
-- Dependencies: 914
-- Name: FUNCTION _st_dwithin(geom1 extensions.geometry, geom2 extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_dwithin(geom1 extensions.geometry, geom2 extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5909 (class 0 OID 0)
-- Dependencies: 1185
-- Name: FUNCTION _st_dwithin(geog1 extensions.geography, geog2 extensions.geography, tolerance double precision, use_spheroid boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_dwithin(geog1 extensions.geography, geog2 extensions.geography, tolerance double precision, use_spheroid boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5910 (class 0 OID 0)
-- Dependencies: 1160
-- Name: FUNCTION _st_dwithinuncached(extensions.geography, extensions.geography, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_dwithinuncached(extensions.geography, extensions.geography, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5911 (class 0 OID 0)
-- Dependencies: 1159
-- Name: FUNCTION _st_dwithinuncached(extensions.geography, extensions.geography, double precision, boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_dwithinuncached(extensions.geography, extensions.geography, double precision, boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5912 (class 0 OID 0)
-- Dependencies: 929
-- Name: FUNCTION _st_equals(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_equals(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5913 (class 0 OID 0)
-- Dependencies: 1153
-- Name: FUNCTION _st_expand(extensions.geography, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_expand(extensions.geography, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5914 (class 0 OID 0)
-- Dependencies: 958
-- Name: FUNCTION _st_geomfromgml(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_geomfromgml(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5915 (class 0 OID 0)
-- Dependencies: 916
-- Name: FUNCTION _st_intersects(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_intersects(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5916 (class 0 OID 0)
-- Dependencies: 913
-- Name: FUNCTION _st_linecrossingdirection(line1 extensions.geometry, line2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_linecrossingdirection(line1 extensions.geometry, line2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5917 (class 0 OID 0)
-- Dependencies: 1082
-- Name: FUNCTION _st_longestline(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_longestline(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5918 (class 0 OID 0)
-- Dependencies: 1078
-- Name: FUNCTION _st_maxdistance(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_maxdistance(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5919 (class 0 OID 0)
-- Dependencies: 928
-- Name: FUNCTION _st_orderingequals(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_orderingequals(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5920 (class 0 OID 0)
-- Dependencies: 923
-- Name: FUNCTION _st_overlaps(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_overlaps(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5921 (class 0 OID 0)
-- Dependencies: 1168
-- Name: FUNCTION _st_pointoutside(extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_pointoutside(extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5922 (class 0 OID 0)
-- Dependencies: 1002
-- Name: FUNCTION _st_sortablehash(geom extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_sortablehash(geom extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5923 (class 0 OID 0)
-- Dependencies: 915
-- Name: FUNCTION _st_touches(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_touches(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5924 (class 0 OID 0)
-- Dependencies: 885
-- Name: FUNCTION _st_voronoi(g1 extensions.geometry, clip extensions.geometry, tolerance double precision, return_polygons boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_voronoi(g1 extensions.geometry, clip extensions.geometry, tolerance double precision, return_polygons boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5925 (class 0 OID 0)
-- Dependencies: 922
-- Name: FUNCTION _st_within(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_within(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5926 (class 0 OID 0)
-- Dependencies: 1093
-- Name: FUNCTION addauth(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.addauth(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5927 (class 0 OID 0)
-- Dependencies: 775
-- Name: FUNCTION addgeometrycolumn(table_name character varying, column_name character varying, new_srid integer, new_type character varying, new_dim integer, use_typmod boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.addgeometrycolumn(table_name character varying, column_name character varying, new_srid integer, new_type character varying, new_dim integer, use_typmod boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5928 (class 0 OID 0)
-- Dependencies: 774
-- Name: FUNCTION addgeometrycolumn(schema_name character varying, table_name character varying, column_name character varying, new_srid integer, new_type character varying, new_dim integer, use_typmod boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.addgeometrycolumn(schema_name character varying, table_name character varying, column_name character varying, new_srid integer, new_type character varying, new_dim integer, use_typmod boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5929 (class 0 OID 0)
-- Dependencies: 773
-- Name: FUNCTION addgeometrycolumn(catalog_name character varying, schema_name character varying, table_name character varying, column_name character varying, new_srid_in integer, new_type character varying, new_dim integer, use_typmod boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.addgeometrycolumn(catalog_name character varying, schema_name character varying, table_name character varying, column_name character varying, new_srid_in integer, new_type character varying, new_dim integer, use_typmod boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5930 (class 0 OID 0)
-- Dependencies: 493
-- Name: FUNCTION armor(bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.armor(bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.armor(bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.armor(bytea) TO dashboard_user;


--
-- TOC entry 5931 (class 0 OID 0)
-- Dependencies: 494
-- Name: FUNCTION armor(bytea, text[], text[]); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.armor(bytea, text[], text[]) FROM postgres;
GRANT ALL ON FUNCTION extensions.armor(bytea, text[], text[]) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.armor(bytea, text[], text[]) TO dashboard_user;


--
-- TOC entry 5932 (class 0 OID 0)
-- Dependencies: 818
-- Name: FUNCTION box3dtobox(extensions.box3d); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.box3dtobox(extensions.box3d) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5933 (class 0 OID 0)
-- Dependencies: 1095
-- Name: FUNCTION checkauth(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.checkauth(text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5934 (class 0 OID 0)
-- Dependencies: 1094
-- Name: FUNCTION checkauth(text, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.checkauth(text, text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5935 (class 0 OID 0)
-- Dependencies: 1096
-- Name: FUNCTION checkauthtrigger(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.checkauthtrigger() TO postgres WITH GRANT OPTION;


--
-- TOC entry 5936 (class 0 OID 0)
-- Dependencies: 1237
-- Name: FUNCTION contains_2d(extensions.box2df, extensions.box2df); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.contains_2d(extensions.box2df, extensions.box2df) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5937 (class 0 OID 0)
-- Dependencies: 1233
-- Name: FUNCTION contains_2d(extensions.box2df, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.contains_2d(extensions.box2df, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5938 (class 0 OID 0)
-- Dependencies: 1239
-- Name: FUNCTION contains_2d(extensions.geometry, extensions.box2df); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.contains_2d(extensions.geometry, extensions.box2df) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5939 (class 0 OID 0)
-- Dependencies: 465
-- Name: FUNCTION crypt(text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.crypt(text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.crypt(text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.crypt(text, text) TO dashboard_user;


--
-- TOC entry 5940 (class 0 OID 0)
-- Dependencies: 495
-- Name: FUNCTION dearmor(text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.dearmor(text) FROM postgres;
GRANT ALL ON FUNCTION extensions.dearmor(text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.dearmor(text) TO dashboard_user;


--
-- TOC entry 5941 (class 0 OID 0)
-- Dependencies: 469
-- Name: FUNCTION decrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) TO dashboard_user;


--
-- TOC entry 5942 (class 0 OID 0)
-- Dependencies: 471
-- Name: FUNCTION decrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) TO dashboard_user;


--
-- TOC entry 5943 (class 0 OID 0)
-- Dependencies: 462
-- Name: FUNCTION digest(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.digest(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.digest(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.digest(bytea, text) TO dashboard_user;


--
-- TOC entry 5944 (class 0 OID 0)
-- Dependencies: 461
-- Name: FUNCTION digest(text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.digest(text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.digest(text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.digest(text, text) TO dashboard_user;


--
-- TOC entry 5945 (class 0 OID 0)
-- Dependencies: 1100
-- Name: FUNCTION disablelongtransactions(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.disablelongtransactions() TO postgres WITH GRANT OPTION;


--
-- TOC entry 5946 (class 0 OID 0)
-- Dependencies: 778
-- Name: FUNCTION dropgeometrycolumn(table_name character varying, column_name character varying); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.dropgeometrycolumn(table_name character varying, column_name character varying) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5947 (class 0 OID 0)
-- Dependencies: 777
-- Name: FUNCTION dropgeometrycolumn(schema_name character varying, table_name character varying, column_name character varying); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.dropgeometrycolumn(schema_name character varying, table_name character varying, column_name character varying) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5948 (class 0 OID 0)
-- Dependencies: 776
-- Name: FUNCTION dropgeometrycolumn(catalog_name character varying, schema_name character varying, table_name character varying, column_name character varying); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.dropgeometrycolumn(catalog_name character varying, schema_name character varying, table_name character varying, column_name character varying) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5949 (class 0 OID 0)
-- Dependencies: 781
-- Name: FUNCTION dropgeometrytable(table_name character varying); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.dropgeometrytable(table_name character varying) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5950 (class 0 OID 0)
-- Dependencies: 780
-- Name: FUNCTION dropgeometrytable(schema_name character varying, table_name character varying); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.dropgeometrytable(schema_name character varying, table_name character varying) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5951 (class 0 OID 0)
-- Dependencies: 779
-- Name: FUNCTION dropgeometrytable(catalog_name character varying, schema_name character varying, table_name character varying); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.dropgeometrytable(catalog_name character varying, schema_name character varying, table_name character varying) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5952 (class 0 OID 0)
-- Dependencies: 1098
-- Name: FUNCTION enablelongtransactions(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.enablelongtransactions() TO postgres WITH GRANT OPTION;


--
-- TOC entry 5953 (class 0 OID 0)
-- Dependencies: 468
-- Name: FUNCTION encrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) TO dashboard_user;


--
-- TOC entry 5954 (class 0 OID 0)
-- Dependencies: 470
-- Name: FUNCTION encrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) TO dashboard_user;


--
-- TOC entry 5955 (class 0 OID 0)
-- Dependencies: 957
-- Name: FUNCTION equals(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.equals(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5956 (class 0 OID 0)
-- Dependencies: 785
-- Name: FUNCTION find_srid(character varying, character varying, character varying); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.find_srid(character varying, character varying, character varying) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5957 (class 0 OID 0)
-- Dependencies: 472
-- Name: FUNCTION gen_random_bytes(integer); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.gen_random_bytes(integer) FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_random_bytes(integer) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_random_bytes(integer) TO dashboard_user;


--
-- TOC entry 5958 (class 0 OID 0)
-- Dependencies: 473
-- Name: FUNCTION gen_random_uuid(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.gen_random_uuid() FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_random_uuid() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_random_uuid() TO dashboard_user;


--
-- TOC entry 5959 (class 0 OID 0)
-- Dependencies: 466
-- Name: FUNCTION gen_salt(text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.gen_salt(text) FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_salt(text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_salt(text) TO dashboard_user;


--
-- TOC entry 5960 (class 0 OID 0)
-- Dependencies: 467
-- Name: FUNCTION gen_salt(text, integer); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.gen_salt(text, integer) FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_salt(text, integer) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_salt(text, integer) TO dashboard_user;


--
-- TOC entry 5961 (class 0 OID 0)
-- Dependencies: 1135
-- Name: FUNCTION geog_brin_inclusion_add_value(internal, internal, internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geog_brin_inclusion_add_value(internal, internal, internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5962 (class 0 OID 0)
-- Dependencies: 1141
-- Name: FUNCTION geography_cmp(extensions.geography, extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_cmp(extensions.geography, extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5963 (class 0 OID 0)
-- Dependencies: 1130
-- Name: FUNCTION geography_distance_knn(extensions.geography, extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_distance_knn(extensions.geography, extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5964 (class 0 OID 0)
-- Dependencies: 1140
-- Name: FUNCTION geography_eq(extensions.geography, extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_eq(extensions.geography, extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5965 (class 0 OID 0)
-- Dependencies: 1139
-- Name: FUNCTION geography_ge(extensions.geography, extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_ge(extensions.geography, extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5966 (class 0 OID 0)
-- Dependencies: 1123
-- Name: FUNCTION geography_gist_compress(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_gist_compress(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5967 (class 0 OID 0)
-- Dependencies: 1122
-- Name: FUNCTION geography_gist_consistent(internal, extensions.geography, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_gist_consistent(internal, extensions.geography, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5968 (class 0 OID 0)
-- Dependencies: 1128
-- Name: FUNCTION geography_gist_decompress(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_gist_decompress(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5969 (class 0 OID 0)
-- Dependencies: 1131
-- Name: FUNCTION geography_gist_distance(internal, extensions.geography, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_gist_distance(internal, extensions.geography, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5970 (class 0 OID 0)
-- Dependencies: 1124
-- Name: FUNCTION geography_gist_penalty(internal, internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_gist_penalty(internal, internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5971 (class 0 OID 0)
-- Dependencies: 1125
-- Name: FUNCTION geography_gist_picksplit(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_gist_picksplit(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5972 (class 0 OID 0)
-- Dependencies: 1127
-- Name: FUNCTION geography_gist_same(extensions.box2d, extensions.box2d, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_gist_same(extensions.box2d, extensions.box2d, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5973 (class 0 OID 0)
-- Dependencies: 1126
-- Name: FUNCTION geography_gist_union(bytea, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_gist_union(bytea, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5974 (class 0 OID 0)
-- Dependencies: 1138
-- Name: FUNCTION geography_gt(extensions.geography, extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_gt(extensions.geography, extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5975 (class 0 OID 0)
-- Dependencies: 1137
-- Name: FUNCTION geography_le(extensions.geography, extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_le(extensions.geography, extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5976 (class 0 OID 0)
-- Dependencies: 1136
-- Name: FUNCTION geography_lt(extensions.geography, extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_lt(extensions.geography, extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5977 (class 0 OID 0)
-- Dependencies: 1129
-- Name: FUNCTION geography_overlaps(extensions.geography, extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_overlaps(extensions.geography, extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5978 (class 0 OID 0)
-- Dependencies: 1277
-- Name: FUNCTION geography_spgist_choose_nd(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_spgist_choose_nd(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5979 (class 0 OID 0)
-- Dependencies: 1281
-- Name: FUNCTION geography_spgist_compress_nd(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_spgist_compress_nd(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5980 (class 0 OID 0)
-- Dependencies: 1276
-- Name: FUNCTION geography_spgist_config_nd(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_spgist_config_nd(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5981 (class 0 OID 0)
-- Dependencies: 1279
-- Name: FUNCTION geography_spgist_inner_consistent_nd(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_spgist_inner_consistent_nd(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5982 (class 0 OID 0)
-- Dependencies: 1280
-- Name: FUNCTION geography_spgist_leaf_consistent_nd(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_spgist_leaf_consistent_nd(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5983 (class 0 OID 0)
-- Dependencies: 1278
-- Name: FUNCTION geography_spgist_picksplit_nd(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_spgist_picksplit_nd(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5984 (class 0 OID 0)
-- Dependencies: 1245
-- Name: FUNCTION geom2d_brin_inclusion_add_value(internal, internal, internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geom2d_brin_inclusion_add_value(internal, internal, internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5985 (class 0 OID 0)
-- Dependencies: 1246
-- Name: FUNCTION geom3d_brin_inclusion_add_value(internal, internal, internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geom3d_brin_inclusion_add_value(internal, internal, internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5986 (class 0 OID 0)
-- Dependencies: 1247
-- Name: FUNCTION geom4d_brin_inclusion_add_value(internal, internal, internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geom4d_brin_inclusion_add_value(internal, internal, internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5987 (class 0 OID 0)
-- Dependencies: 627
-- Name: FUNCTION geometry_above(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_above(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5988 (class 0 OID 0)
-- Dependencies: 622
-- Name: FUNCTION geometry_below(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_below(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5989 (class 0 OID 0)
-- Dependencies: 594
-- Name: FUNCTION geometry_cmp(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_cmp(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5990 (class 0 OID 0)
-- Dependencies: 1262
-- Name: FUNCTION geometry_contained_3d(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_contained_3d(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5991 (class 0 OID 0)
-- Dependencies: 618
-- Name: FUNCTION geometry_contains(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_contains(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5992 (class 0 OID 0)
-- Dependencies: 1261
-- Name: FUNCTION geometry_contains_3d(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_contains_3d(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5993 (class 0 OID 0)
-- Dependencies: 636
-- Name: FUNCTION geometry_contains_nd(extensions.geometry, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_contains_nd(extensions.geometry, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5994 (class 0 OID 0)
-- Dependencies: 617
-- Name: FUNCTION geometry_distance_box(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_distance_box(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5995 (class 0 OID 0)
-- Dependencies: 616
-- Name: FUNCTION geometry_distance_centroid(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_distance_centroid(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5996 (class 0 OID 0)
-- Dependencies: 639
-- Name: FUNCTION geometry_distance_centroid_nd(extensions.geometry, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_distance_centroid_nd(extensions.geometry, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5997 (class 0 OID 0)
-- Dependencies: 640
-- Name: FUNCTION geometry_distance_cpa(extensions.geometry, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_distance_cpa(extensions.geometry, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5998 (class 0 OID 0)
-- Dependencies: 593
-- Name: FUNCTION geometry_eq(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_eq(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 5999 (class 0 OID 0)
-- Dependencies: 592
-- Name: FUNCTION geometry_ge(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_ge(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6000 (class 0 OID 0)
-- Dependencies: 599
-- Name: FUNCTION geometry_gist_compress_2d(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_gist_compress_2d(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6001 (class 0 OID 0)
-- Dependencies: 629
-- Name: FUNCTION geometry_gist_compress_nd(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_gist_compress_nd(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6002 (class 0 OID 0)
-- Dependencies: 598
-- Name: FUNCTION geometry_gist_consistent_2d(internal, extensions.geometry, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_gist_consistent_2d(internal, extensions.geometry, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6003 (class 0 OID 0)
-- Dependencies: 628
-- Name: FUNCTION geometry_gist_consistent_nd(internal, extensions.geometry, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_gist_consistent_nd(internal, extensions.geometry, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6004 (class 0 OID 0)
-- Dependencies: 604
-- Name: FUNCTION geometry_gist_decompress_2d(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_gist_decompress_2d(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6005 (class 0 OID 0)
-- Dependencies: 634
-- Name: FUNCTION geometry_gist_decompress_nd(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_gist_decompress_nd(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6006 (class 0 OID 0)
-- Dependencies: 597
-- Name: FUNCTION geometry_gist_distance_2d(internal, extensions.geometry, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_gist_distance_2d(internal, extensions.geometry, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6007 (class 0 OID 0)
-- Dependencies: 641
-- Name: FUNCTION geometry_gist_distance_nd(internal, extensions.geometry, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_gist_distance_nd(internal, extensions.geometry, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6008 (class 0 OID 0)
-- Dependencies: 600
-- Name: FUNCTION geometry_gist_penalty_2d(internal, internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_gist_penalty_2d(internal, internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6009 (class 0 OID 0)
-- Dependencies: 630
-- Name: FUNCTION geometry_gist_penalty_nd(internal, internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_gist_penalty_nd(internal, internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6010 (class 0 OID 0)
-- Dependencies: 601
-- Name: FUNCTION geometry_gist_picksplit_2d(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_gist_picksplit_2d(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6011 (class 0 OID 0)
-- Dependencies: 631
-- Name: FUNCTION geometry_gist_picksplit_nd(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_gist_picksplit_nd(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6012 (class 0 OID 0)
-- Dependencies: 603
-- Name: FUNCTION geometry_gist_same_2d(geom1 extensions.geometry, geom2 extensions.geometry, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_gist_same_2d(geom1 extensions.geometry, geom2 extensions.geometry, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6013 (class 0 OID 0)
-- Dependencies: 633
-- Name: FUNCTION geometry_gist_same_nd(extensions.geometry, extensions.geometry, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_gist_same_nd(extensions.geometry, extensions.geometry, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6014 (class 0 OID 0)
-- Dependencies: 605
-- Name: FUNCTION geometry_gist_sortsupport_2d(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_gist_sortsupport_2d(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6015 (class 0 OID 0)
-- Dependencies: 602
-- Name: FUNCTION geometry_gist_union_2d(bytea, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_gist_union_2d(bytea, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6016 (class 0 OID 0)
-- Dependencies: 632
-- Name: FUNCTION geometry_gist_union_nd(bytea, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_gist_union_nd(bytea, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6017 (class 0 OID 0)
-- Dependencies: 591
-- Name: FUNCTION geometry_gt(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_gt(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6018 (class 0 OID 0)
-- Dependencies: 596
-- Name: FUNCTION geometry_hash(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_hash(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6019 (class 0 OID 0)
-- Dependencies: 590
-- Name: FUNCTION geometry_le(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_le(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6020 (class 0 OID 0)
-- Dependencies: 620
-- Name: FUNCTION geometry_left(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_left(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6021 (class 0 OID 0)
-- Dependencies: 589
-- Name: FUNCTION geometry_lt(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_lt(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6022 (class 0 OID 0)
-- Dependencies: 626
-- Name: FUNCTION geometry_overabove(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_overabove(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6023 (class 0 OID 0)
-- Dependencies: 623
-- Name: FUNCTION geometry_overbelow(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_overbelow(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6024 (class 0 OID 0)
-- Dependencies: 614
-- Name: FUNCTION geometry_overlaps(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_overlaps(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6025 (class 0 OID 0)
-- Dependencies: 1260
-- Name: FUNCTION geometry_overlaps_3d(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_overlaps_3d(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6026 (class 0 OID 0)
-- Dependencies: 635
-- Name: FUNCTION geometry_overlaps_nd(extensions.geometry, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_overlaps_nd(extensions.geometry, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6027 (class 0 OID 0)
-- Dependencies: 621
-- Name: FUNCTION geometry_overleft(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_overleft(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6028 (class 0 OID 0)
-- Dependencies: 624
-- Name: FUNCTION geometry_overright(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_overright(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6029 (class 0 OID 0)
-- Dependencies: 625
-- Name: FUNCTION geometry_right(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_right(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6030 (class 0 OID 0)
-- Dependencies: 615
-- Name: FUNCTION geometry_same(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_same(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6031 (class 0 OID 0)
-- Dependencies: 1263
-- Name: FUNCTION geometry_same_3d(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_same_3d(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6032 (class 0 OID 0)
-- Dependencies: 638
-- Name: FUNCTION geometry_same_nd(extensions.geometry, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_same_nd(extensions.geometry, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6033 (class 0 OID 0)
-- Dependencies: 595
-- Name: FUNCTION geometry_sortsupport(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_sortsupport(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6034 (class 0 OID 0)
-- Dependencies: 1255
-- Name: FUNCTION geometry_spgist_choose_2d(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_spgist_choose_2d(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6035 (class 0 OID 0)
-- Dependencies: 1265
-- Name: FUNCTION geometry_spgist_choose_3d(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_spgist_choose_3d(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6036 (class 0 OID 0)
-- Dependencies: 1271
-- Name: FUNCTION geometry_spgist_choose_nd(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_spgist_choose_nd(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6037 (class 0 OID 0)
-- Dependencies: 1259
-- Name: FUNCTION geometry_spgist_compress_2d(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_spgist_compress_2d(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6038 (class 0 OID 0)
-- Dependencies: 1269
-- Name: FUNCTION geometry_spgist_compress_3d(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_spgist_compress_3d(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6039 (class 0 OID 0)
-- Dependencies: 1275
-- Name: FUNCTION geometry_spgist_compress_nd(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_spgist_compress_nd(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6040 (class 0 OID 0)
-- Dependencies: 1254
-- Name: FUNCTION geometry_spgist_config_2d(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_spgist_config_2d(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6041 (class 0 OID 0)
-- Dependencies: 1264
-- Name: FUNCTION geometry_spgist_config_3d(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_spgist_config_3d(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6042 (class 0 OID 0)
-- Dependencies: 1270
-- Name: FUNCTION geometry_spgist_config_nd(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_spgist_config_nd(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6043 (class 0 OID 0)
-- Dependencies: 1257
-- Name: FUNCTION geometry_spgist_inner_consistent_2d(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_spgist_inner_consistent_2d(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6044 (class 0 OID 0)
-- Dependencies: 1267
-- Name: FUNCTION geometry_spgist_inner_consistent_3d(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_spgist_inner_consistent_3d(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6045 (class 0 OID 0)
-- Dependencies: 1273
-- Name: FUNCTION geometry_spgist_inner_consistent_nd(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_spgist_inner_consistent_nd(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6046 (class 0 OID 0)
-- Dependencies: 1258
-- Name: FUNCTION geometry_spgist_leaf_consistent_2d(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_spgist_leaf_consistent_2d(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6047 (class 0 OID 0)
-- Dependencies: 1268
-- Name: FUNCTION geometry_spgist_leaf_consistent_3d(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_spgist_leaf_consistent_3d(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6048 (class 0 OID 0)
-- Dependencies: 1274
-- Name: FUNCTION geometry_spgist_leaf_consistent_nd(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_spgist_leaf_consistent_nd(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6049 (class 0 OID 0)
-- Dependencies: 1256
-- Name: FUNCTION geometry_spgist_picksplit_2d(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_spgist_picksplit_2d(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6050 (class 0 OID 0)
-- Dependencies: 1266
-- Name: FUNCTION geometry_spgist_picksplit_3d(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_spgist_picksplit_3d(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6051 (class 0 OID 0)
-- Dependencies: 1272
-- Name: FUNCTION geometry_spgist_picksplit_nd(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_spgist_picksplit_nd(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6052 (class 0 OID 0)
-- Dependencies: 619
-- Name: FUNCTION geometry_within(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_within(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6053 (class 0 OID 0)
-- Dependencies: 637
-- Name: FUNCTION geometry_within_nd(extensions.geometry, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_within_nd(extensions.geometry, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6054 (class 0 OID 0)
-- Dependencies: 1177
-- Name: FUNCTION geometrytype(extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometrytype(extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6055 (class 0 OID 0)
-- Dependencies: 1014
-- Name: FUNCTION geometrytype(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometrytype(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6056 (class 0 OID 0)
-- Dependencies: 723
-- Name: FUNCTION geomfromewkb(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geomfromewkb(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6057 (class 0 OID 0)
-- Dependencies: 726
-- Name: FUNCTION geomfromewkt(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geomfromewkt(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6058 (class 0 OID 0)
-- Dependencies: 786
-- Name: FUNCTION get_proj4_from_srid(integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.get_proj4_from_srid(integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6059 (class 0 OID 0)
-- Dependencies: 1097
-- Name: FUNCTION gettransactionid(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gettransactionid() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6061 (class 0 OID 0)
-- Dependencies: 500
-- Name: FUNCTION grant_pg_cron_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION extensions.grant_pg_cron_access() FROM supabase_admin;
GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO supabase_admin WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO dashboard_user;


--
-- TOC entry 6063 (class 0 OID 0)
-- Dependencies: 504
-- Name: FUNCTION grant_pg_graphql_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.grant_pg_graphql_access() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6065 (class 0 OID 0)
-- Dependencies: 501
-- Name: FUNCTION grant_pg_net_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION extensions.grant_pg_net_access() FROM supabase_admin;
GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO supabase_admin WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO dashboard_user;


--
-- TOC entry 6066 (class 0 OID 0)
-- Dependencies: 612
-- Name: FUNCTION gserialized_gist_joinsel_2d(internal, oid, internal, smallint); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gserialized_gist_joinsel_2d(internal, oid, internal, smallint) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6067 (class 0 OID 0)
-- Dependencies: 613
-- Name: FUNCTION gserialized_gist_joinsel_nd(internal, oid, internal, smallint); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gserialized_gist_joinsel_nd(internal, oid, internal, smallint) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6068 (class 0 OID 0)
-- Dependencies: 610
-- Name: FUNCTION gserialized_gist_sel_2d(internal, oid, internal, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gserialized_gist_sel_2d(internal, oid, internal, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6069 (class 0 OID 0)
-- Dependencies: 611
-- Name: FUNCTION gserialized_gist_sel_nd(internal, oid, internal, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gserialized_gist_sel_nd(internal, oid, internal, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6070 (class 0 OID 0)
-- Dependencies: 464
-- Name: FUNCTION hmac(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.hmac(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.hmac(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.hmac(bytea, bytea, text) TO dashboard_user;


--
-- TOC entry 6071 (class 0 OID 0)
-- Dependencies: 463
-- Name: FUNCTION hmac(text, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.hmac(text, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.hmac(text, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.hmac(text, text, text) TO dashboard_user;


--
-- TOC entry 6072 (class 0 OID 0)
-- Dependencies: 1238
-- Name: FUNCTION is_contained_2d(extensions.box2df, extensions.box2df); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.is_contained_2d(extensions.box2df, extensions.box2df) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6073 (class 0 OID 0)
-- Dependencies: 1234
-- Name: FUNCTION is_contained_2d(extensions.box2df, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.is_contained_2d(extensions.box2df, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6074 (class 0 OID 0)
-- Dependencies: 1240
-- Name: FUNCTION is_contained_2d(extensions.geometry, extensions.box2df); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.is_contained_2d(extensions.geometry, extensions.box2df) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6075 (class 0 OID 0)
-- Dependencies: 1091
-- Name: FUNCTION lockrow(text, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.lockrow(text, text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6076 (class 0 OID 0)
-- Dependencies: 1090
-- Name: FUNCTION lockrow(text, text, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.lockrow(text, text, text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6077 (class 0 OID 0)
-- Dependencies: 1092
-- Name: FUNCTION lockrow(text, text, text, timestamp without time zone); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.lockrow(text, text, text, timestamp without time zone) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6078 (class 0 OID 0)
-- Dependencies: 1089
-- Name: FUNCTION lockrow(text, text, text, text, timestamp without time zone); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.lockrow(text, text, text, text, timestamp without time zone) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6079 (class 0 OID 0)
-- Dependencies: 1099
-- Name: FUNCTION longtransactionsenabled(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.longtransactionsenabled() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6080 (class 0 OID 0)
-- Dependencies: 1236
-- Name: FUNCTION overlaps_2d(extensions.box2df, extensions.box2df); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.overlaps_2d(extensions.box2df, extensions.box2df) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6081 (class 0 OID 0)
-- Dependencies: 1235
-- Name: FUNCTION overlaps_2d(extensions.box2df, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.overlaps_2d(extensions.box2df, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6082 (class 0 OID 0)
-- Dependencies: 1241
-- Name: FUNCTION overlaps_2d(extensions.geometry, extensions.box2df); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.overlaps_2d(extensions.geometry, extensions.box2df) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6083 (class 0 OID 0)
-- Dependencies: 1134
-- Name: FUNCTION overlaps_geog(extensions.geography, extensions.gidx); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.overlaps_geog(extensions.geography, extensions.gidx) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6084 (class 0 OID 0)
-- Dependencies: 1132
-- Name: FUNCTION overlaps_geog(extensions.gidx, extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.overlaps_geog(extensions.gidx, extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6085 (class 0 OID 0)
-- Dependencies: 1133
-- Name: FUNCTION overlaps_geog(extensions.gidx, extensions.gidx); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.overlaps_geog(extensions.gidx, extensions.gidx) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6086 (class 0 OID 0)
-- Dependencies: 1244
-- Name: FUNCTION overlaps_nd(extensions.geometry, extensions.gidx); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.overlaps_nd(extensions.geometry, extensions.gidx) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6087 (class 0 OID 0)
-- Dependencies: 1242
-- Name: FUNCTION overlaps_nd(extensions.gidx, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.overlaps_nd(extensions.gidx, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6088 (class 0 OID 0)
-- Dependencies: 1243
-- Name: FUNCTION overlaps_nd(extensions.gidx, extensions.gidx); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.overlaps_nd(extensions.gidx, extensions.gidx) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6089 (class 0 OID 0)
-- Dependencies: 449
-- Name: FUNCTION pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone) FROM postgres;
GRANT ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone) TO dashboard_user;


--
-- TOC entry 6090 (class 0 OID 0)
-- Dependencies: 448
-- Name: FUNCTION pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) FROM postgres;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO dashboard_user;


--
-- TOC entry 6091 (class 0 OID 0)
-- Dependencies: 450
-- Name: FUNCTION pg_stat_statements_reset(userid oid, dbid oid, queryid bigint, minmax_only boolean); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint, minmax_only boolean) FROM postgres;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint, minmax_only boolean) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint, minmax_only boolean) TO dashboard_user;


--
-- TOC entry 6092 (class 0 OID 0)
-- Dependencies: 998
-- Name: FUNCTION pgis_asflatgeobuf_finalfn(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_asflatgeobuf_finalfn(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6093 (class 0 OID 0)
-- Dependencies: 995
-- Name: FUNCTION pgis_asflatgeobuf_transfn(internal, anyelement); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_asflatgeobuf_transfn(internal, anyelement) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6094 (class 0 OID 0)
-- Dependencies: 996
-- Name: FUNCTION pgis_asflatgeobuf_transfn(internal, anyelement, boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_asflatgeobuf_transfn(internal, anyelement, boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6095 (class 0 OID 0)
-- Dependencies: 997
-- Name: FUNCTION pgis_asflatgeobuf_transfn(internal, anyelement, boolean, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_asflatgeobuf_transfn(internal, anyelement, boolean, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6096 (class 0 OID 0)
-- Dependencies: 994
-- Name: FUNCTION pgis_asgeobuf_finalfn(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_asgeobuf_finalfn(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6097 (class 0 OID 0)
-- Dependencies: 992
-- Name: FUNCTION pgis_asgeobuf_transfn(internal, anyelement); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_asgeobuf_transfn(internal, anyelement) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6098 (class 0 OID 0)
-- Dependencies: 993
-- Name: FUNCTION pgis_asgeobuf_transfn(internal, anyelement, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_asgeobuf_transfn(internal, anyelement, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6099 (class 0 OID 0)
-- Dependencies: 987
-- Name: FUNCTION pgis_asmvt_combinefn(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_asmvt_combinefn(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6100 (class 0 OID 0)
-- Dependencies: 989
-- Name: FUNCTION pgis_asmvt_deserialfn(bytea, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_asmvt_deserialfn(bytea, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6101 (class 0 OID 0)
-- Dependencies: 986
-- Name: FUNCTION pgis_asmvt_finalfn(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_asmvt_finalfn(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6102 (class 0 OID 0)
-- Dependencies: 988
-- Name: FUNCTION pgis_asmvt_serialfn(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_asmvt_serialfn(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6103 (class 0 OID 0)
-- Dependencies: 981
-- Name: FUNCTION pgis_asmvt_transfn(internal, anyelement); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_asmvt_transfn(internal, anyelement) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6104 (class 0 OID 0)
-- Dependencies: 982
-- Name: FUNCTION pgis_asmvt_transfn(internal, anyelement, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_asmvt_transfn(internal, anyelement, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6105 (class 0 OID 0)
-- Dependencies: 983
-- Name: FUNCTION pgis_asmvt_transfn(internal, anyelement, text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_asmvt_transfn(internal, anyelement, text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6106 (class 0 OID 0)
-- Dependencies: 984
-- Name: FUNCTION pgis_asmvt_transfn(internal, anyelement, text, integer, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_asmvt_transfn(internal, anyelement, text, integer, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6107 (class 0 OID 0)
-- Dependencies: 985
-- Name: FUNCTION pgis_asmvt_transfn(internal, anyelement, text, integer, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_asmvt_transfn(internal, anyelement, text, integer, text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6108 (class 0 OID 0)
-- Dependencies: 893
-- Name: FUNCTION pgis_geometry_accum_transfn(internal, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_geometry_accum_transfn(internal, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6109 (class 0 OID 0)
-- Dependencies: 894
-- Name: FUNCTION pgis_geometry_accum_transfn(internal, extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_geometry_accum_transfn(internal, extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6110 (class 0 OID 0)
-- Dependencies: 895
-- Name: FUNCTION pgis_geometry_accum_transfn(internal, extensions.geometry, double precision, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_geometry_accum_transfn(internal, extensions.geometry, double precision, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6111 (class 0 OID 0)
-- Dependencies: 898
-- Name: FUNCTION pgis_geometry_clusterintersecting_finalfn(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_geometry_clusterintersecting_finalfn(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6112 (class 0 OID 0)
-- Dependencies: 899
-- Name: FUNCTION pgis_geometry_clusterwithin_finalfn(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_geometry_clusterwithin_finalfn(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6113 (class 0 OID 0)
-- Dependencies: 896
-- Name: FUNCTION pgis_geometry_collect_finalfn(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_geometry_collect_finalfn(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6114 (class 0 OID 0)
-- Dependencies: 900
-- Name: FUNCTION pgis_geometry_makeline_finalfn(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_geometry_makeline_finalfn(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6115 (class 0 OID 0)
-- Dependencies: 897
-- Name: FUNCTION pgis_geometry_polygonize_finalfn(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_geometry_polygonize_finalfn(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6116 (class 0 OID 0)
-- Dependencies: 903
-- Name: FUNCTION pgis_geometry_union_parallel_combinefn(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_geometry_union_parallel_combinefn(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6117 (class 0 OID 0)
-- Dependencies: 905
-- Name: FUNCTION pgis_geometry_union_parallel_deserialfn(bytea, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_geometry_union_parallel_deserialfn(bytea, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6118 (class 0 OID 0)
-- Dependencies: 906
-- Name: FUNCTION pgis_geometry_union_parallel_finalfn(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_geometry_union_parallel_finalfn(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6119 (class 0 OID 0)
-- Dependencies: 904
-- Name: FUNCTION pgis_geometry_union_parallel_serialfn(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_geometry_union_parallel_serialfn(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6120 (class 0 OID 0)
-- Dependencies: 901
-- Name: FUNCTION pgis_geometry_union_parallel_transfn(internal, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_geometry_union_parallel_transfn(internal, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6121 (class 0 OID 0)
-- Dependencies: 902
-- Name: FUNCTION pgis_geometry_union_parallel_transfn(internal, extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_geometry_union_parallel_transfn(internal, extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6122 (class 0 OID 0)
-- Dependencies: 496
-- Name: FUNCTION pgp_armor_headers(text, OUT key text, OUT value text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) TO dashboard_user;


--
-- TOC entry 6123 (class 0 OID 0)
-- Dependencies: 492
-- Name: FUNCTION pgp_key_id(bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_key_id(bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_key_id(bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_key_id(bytea) TO dashboard_user;


--
-- TOC entry 6124 (class 0 OID 0)
-- Dependencies: 486
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) TO dashboard_user;


--
-- TOC entry 6125 (class 0 OID 0)
-- Dependencies: 488
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) TO dashboard_user;


--
-- TOC entry 6126 (class 0 OID 0)
-- Dependencies: 490
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) TO dashboard_user;


--
-- TOC entry 6127 (class 0 OID 0)
-- Dependencies: 487
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) TO dashboard_user;


--
-- TOC entry 6128 (class 0 OID 0)
-- Dependencies: 489
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) TO dashboard_user;


--
-- TOC entry 6129 (class 0 OID 0)
-- Dependencies: 491
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO dashboard_user;


--
-- TOC entry 6130 (class 0 OID 0)
-- Dependencies: 482
-- Name: FUNCTION pgp_pub_encrypt(text, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) TO dashboard_user;


--
-- TOC entry 6131 (class 0 OID 0)
-- Dependencies: 484
-- Name: FUNCTION pgp_pub_encrypt(text, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) TO dashboard_user;


--
-- TOC entry 6132 (class 0 OID 0)
-- Dependencies: 483
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) TO dashboard_user;


--
-- TOC entry 6133 (class 0 OID 0)
-- Dependencies: 485
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) TO dashboard_user;


--
-- TOC entry 6134 (class 0 OID 0)
-- Dependencies: 478
-- Name: FUNCTION pgp_sym_decrypt(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) TO dashboard_user;


--
-- TOC entry 6135 (class 0 OID 0)
-- Dependencies: 480
-- Name: FUNCTION pgp_sym_decrypt(bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) TO dashboard_user;


--
-- TOC entry 6136 (class 0 OID 0)
-- Dependencies: 479
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) TO dashboard_user;


--
-- TOC entry 6137 (class 0 OID 0)
-- Dependencies: 481
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) TO dashboard_user;


--
-- TOC entry 6138 (class 0 OID 0)
-- Dependencies: 474
-- Name: FUNCTION pgp_sym_encrypt(text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) TO dashboard_user;


--
-- TOC entry 6139 (class 0 OID 0)
-- Dependencies: 476
-- Name: FUNCTION pgp_sym_encrypt(text, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) TO dashboard_user;


--
-- TOC entry 6140 (class 0 OID 0)
-- Dependencies: 475
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) TO dashboard_user;


--
-- TOC entry 6141 (class 0 OID 0)
-- Dependencies: 477
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) TO dashboard_user;


--
-- TOC entry 6142 (class 0 OID 0)
-- Dependencies: 502
-- Name: FUNCTION pgrst_ddl_watch(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgrst_ddl_watch() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6143 (class 0 OID 0)
-- Dependencies: 503
-- Name: FUNCTION pgrst_drop_watch(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgrst_drop_watch() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6144 (class 0 OID 0)
-- Dependencies: 771
-- Name: FUNCTION populate_geometry_columns(use_typmod boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.populate_geometry_columns(use_typmod boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6145 (class 0 OID 0)
-- Dependencies: 772
-- Name: FUNCTION populate_geometry_columns(tbl_oid oid, use_typmod boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.populate_geometry_columns(tbl_oid oid, use_typmod boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6146 (class 0 OID 0)
-- Dependencies: 659
-- Name: FUNCTION postgis_addbbox(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_addbbox(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6147 (class 0 OID 0)
-- Dependencies: 728
-- Name: FUNCTION postgis_cache_bbox(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_cache_bbox() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6148 (class 0 OID 0)
-- Dependencies: 1207
-- Name: FUNCTION postgis_constraint_dims(geomschema text, geomtable text, geomcolumn text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_constraint_dims(geomschema text, geomtable text, geomcolumn text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6149 (class 0 OID 0)
-- Dependencies: 1206
-- Name: FUNCTION postgis_constraint_srid(geomschema text, geomtable text, geomcolumn text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_constraint_srid(geomschema text, geomtable text, geomcolumn text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6150 (class 0 OID 0)
-- Dependencies: 1208
-- Name: FUNCTION postgis_constraint_type(geomschema text, geomtable text, geomcolumn text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_constraint_type(geomschema text, geomtable text, geomcolumn text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6151 (class 0 OID 0)
-- Dependencies: 660
-- Name: FUNCTION postgis_dropbbox(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_dropbbox(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6152 (class 0 OID 0)
-- Dependencies: 809
-- Name: FUNCTION postgis_extensions_upgrade(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_extensions_upgrade() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6153 (class 0 OID 0)
-- Dependencies: 810
-- Name: FUNCTION postgis_full_version(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_full_version() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6154 (class 0 OID 0)
-- Dependencies: 710
-- Name: FUNCTION postgis_geos_noop(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_geos_noop(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6155 (class 0 OID 0)
-- Dependencies: 801
-- Name: FUNCTION postgis_geos_version(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_geos_version() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6156 (class 0 OID 0)
-- Dependencies: 652
-- Name: FUNCTION postgis_getbbox(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_getbbox(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6157 (class 0 OID 0)
-- Dependencies: 661
-- Name: FUNCTION postgis_hasbbox(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_hasbbox(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6158 (class 0 OID 0)
-- Dependencies: 930
-- Name: FUNCTION postgis_index_supportfn(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_index_supportfn(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6159 (class 0 OID 0)
-- Dependencies: 806
-- Name: FUNCTION postgis_lib_build_date(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_lib_build_date() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6160 (class 0 OID 0)
-- Dependencies: 802
-- Name: FUNCTION postgis_lib_revision(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_lib_revision() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6161 (class 0 OID 0)
-- Dependencies: 799
-- Name: FUNCTION postgis_lib_version(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_lib_version() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6162 (class 0 OID 0)
-- Dependencies: 969
-- Name: FUNCTION postgis_libjson_version(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_libjson_version() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6163 (class 0 OID 0)
-- Dependencies: 795
-- Name: FUNCTION postgis_liblwgeom_version(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_liblwgeom_version() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6164 (class 0 OID 0)
-- Dependencies: 991
-- Name: FUNCTION postgis_libprotobuf_version(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_libprotobuf_version() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6165 (class 0 OID 0)
-- Dependencies: 804
-- Name: FUNCTION postgis_libxml_version(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_libxml_version() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6166 (class 0 OID 0)
-- Dependencies: 709
-- Name: FUNCTION postgis_noop(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_noop(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6167 (class 0 OID 0)
-- Dependencies: 796
-- Name: FUNCTION postgis_proj_version(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_proj_version() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6168 (class 0 OID 0)
-- Dependencies: 805
-- Name: FUNCTION postgis_scripts_build_date(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_scripts_build_date() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6169 (class 0 OID 0)
-- Dependencies: 798
-- Name: FUNCTION postgis_scripts_installed(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_scripts_installed() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6170 (class 0 OID 0)
-- Dependencies: 800
-- Name: FUNCTION postgis_scripts_released(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_scripts_released() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6171 (class 0 OID 0)
-- Dependencies: 803
-- Name: FUNCTION postgis_svn_version(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_svn_version() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6172 (class 0 OID 0)
-- Dependencies: 789
-- Name: FUNCTION postgis_transform_geometry(geom extensions.geometry, text, text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_transform_geometry(geom extensions.geometry, text, text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6173 (class 0 OID 0)
-- Dependencies: 1205
-- Name: FUNCTION postgis_type_name(geomname character varying, coord_dimension integer, use_new_name boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_type_name(geomname character varying, coord_dimension integer, use_new_name boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6174 (class 0 OID 0)
-- Dependencies: 1117
-- Name: FUNCTION postgis_typmod_dims(integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_typmod_dims(integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6175 (class 0 OID 0)
-- Dependencies: 1118
-- Name: FUNCTION postgis_typmod_srid(integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_typmod_srid(integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6176 (class 0 OID 0)
-- Dependencies: 1119
-- Name: FUNCTION postgis_typmod_type(integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_typmod_type(integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6177 (class 0 OID 0)
-- Dependencies: 794
-- Name: FUNCTION postgis_version(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_version() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6178 (class 0 OID 0)
-- Dependencies: 797
-- Name: FUNCTION postgis_wagyu_version(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_wagyu_version() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6180 (class 0 OID 0)
-- Dependencies: 505
-- Name: FUNCTION set_graphql_placeholder(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.set_graphql_placeholder() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6181 (class 0 OID 0)
-- Dependencies: 1211
-- Name: FUNCTION st_3dclosestpoint(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_3dclosestpoint(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6182 (class 0 OID 0)
-- Dependencies: 944
-- Name: FUNCTION st_3ddfullywithin(geom1 extensions.geometry, geom2 extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_3ddfullywithin(geom1 extensions.geometry, geom2 extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6183 (class 0 OID 0)
-- Dependencies: 1209
-- Name: FUNCTION st_3ddistance(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_3ddistance(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6184 (class 0 OID 0)
-- Dependencies: 943
-- Name: FUNCTION st_3ddwithin(geom1 extensions.geometry, geom2 extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_3ddwithin(geom1 extensions.geometry, geom2 extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6185 (class 0 OID 0)
-- Dependencies: 945
-- Name: FUNCTION st_3dintersects(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_3dintersects(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6186 (class 0 OID 0)
-- Dependencies: 667
-- Name: FUNCTION st_3dlength(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_3dlength(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6187 (class 0 OID 0)
-- Dependencies: 1253
-- Name: FUNCTION st_3dlineinterpolatepoint(extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_3dlineinterpolatepoint(extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6188 (class 0 OID 0)
-- Dependencies: 1213
-- Name: FUNCTION st_3dlongestline(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_3dlongestline(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6189 (class 0 OID 0)
-- Dependencies: 733
-- Name: FUNCTION st_3dmakebox(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_3dmakebox(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6190 (class 0 OID 0)
-- Dependencies: 1210
-- Name: FUNCTION st_3dmaxdistance(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_3dmaxdistance(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6191 (class 0 OID 0)
-- Dependencies: 672
-- Name: FUNCTION st_3dperimeter(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_3dperimeter(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6192 (class 0 OID 0)
-- Dependencies: 1212
-- Name: FUNCTION st_3dshortestline(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_3dshortestline(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6193 (class 0 OID 0)
-- Dependencies: 839
-- Name: FUNCTION st_addmeasure(extensions.geometry, double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_addmeasure(extensions.geometry, double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6194 (class 0 OID 0)
-- Dependencies: 737
-- Name: FUNCTION st_addpoint(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_addpoint(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6195 (class 0 OID 0)
-- Dependencies: 738
-- Name: FUNCTION st_addpoint(geom1 extensions.geometry, geom2 extensions.geometry, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_addpoint(geom1 extensions.geometry, geom2 extensions.geometry, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6196 (class 0 OID 0)
-- Dependencies: 753
-- Name: FUNCTION st_affine(extensions.geometry, double precision, double precision, double precision, double precision, double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_affine(extensions.geometry, double precision, double precision, double precision, double precision, double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6197 (class 0 OID 0)
-- Dependencies: 752
-- Name: FUNCTION st_affine(extensions.geometry, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_affine(extensions.geometry, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6198 (class 0 OID 0)
-- Dependencies: 1252
-- Name: FUNCTION st_angle(line1 extensions.geometry, line2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_angle(line1 extensions.geometry, line2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6199 (class 0 OID 0)
-- Dependencies: 684
-- Name: FUNCTION st_angle(pt1 extensions.geometry, pt2 extensions.geometry, pt3 extensions.geometry, pt4 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_angle(pt1 extensions.geometry, pt2 extensions.geometry, pt3 extensions.geometry, pt4 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6200 (class 0 OID 0)
-- Dependencies: 676
-- Name: FUNCTION st_area(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_area(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6201 (class 0 OID 0)
-- Dependencies: 1162
-- Name: FUNCTION st_area(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_area(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6202 (class 0 OID 0)
-- Dependencies: 1161
-- Name: FUNCTION st_area(geog extensions.geography, use_spheroid boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_area(geog extensions.geography, use_spheroid boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6203 (class 0 OID 0)
-- Dependencies: 675
-- Name: FUNCTION st_area2d(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_area2d(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6204 (class 0 OID 0)
-- Dependencies: 1172
-- Name: FUNCTION st_asbinary(extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asbinary(extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6205 (class 0 OID 0)
-- Dependencies: 1024
-- Name: FUNCTION st_asbinary(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asbinary(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6206 (class 0 OID 0)
-- Dependencies: 1173
-- Name: FUNCTION st_asbinary(extensions.geography, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asbinary(extensions.geography, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6207 (class 0 OID 0)
-- Dependencies: 1023
-- Name: FUNCTION st_asbinary(extensions.geometry, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asbinary(extensions.geometry, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6208 (class 0 OID 0)
-- Dependencies: 971
-- Name: FUNCTION st_asencodedpolyline(geom extensions.geometry, nprecision integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asencodedpolyline(geom extensions.geometry, nprecision integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6209 (class 0 OID 0)
-- Dependencies: 718
-- Name: FUNCTION st_asewkb(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asewkb(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6210 (class 0 OID 0)
-- Dependencies: 721
-- Name: FUNCTION st_asewkb(extensions.geometry, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asewkb(extensions.geometry, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6211 (class 0 OID 0)
-- Dependencies: 1174
-- Name: FUNCTION st_asewkt(extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asewkt(extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6212 (class 0 OID 0)
-- Dependencies: 714
-- Name: FUNCTION st_asewkt(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asewkt(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6213 (class 0 OID 0)
-- Dependencies: 1176
-- Name: FUNCTION st_asewkt(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asewkt(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6214 (class 0 OID 0)
-- Dependencies: 1175
-- Name: FUNCTION st_asewkt(extensions.geography, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asewkt(extensions.geography, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6215 (class 0 OID 0)
-- Dependencies: 715
-- Name: FUNCTION st_asewkt(extensions.geometry, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asewkt(extensions.geometry, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6216 (class 0 OID 0)
-- Dependencies: 1150
-- Name: FUNCTION st_asgeojson(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asgeojson(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6217 (class 0 OID 0)
-- Dependencies: 1149
-- Name: FUNCTION st_asgeojson(geog extensions.geography, maxdecimaldigits integer, options integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asgeojson(geog extensions.geography, maxdecimaldigits integer, options integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6218 (class 0 OID 0)
-- Dependencies: 977
-- Name: FUNCTION st_asgeojson(geom extensions.geometry, maxdecimaldigits integer, options integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asgeojson(geom extensions.geometry, maxdecimaldigits integer, options integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6219 (class 0 OID 0)
-- Dependencies: 978
-- Name: FUNCTION st_asgeojson(r record, geom_column text, maxdecimaldigits integer, pretty_bool boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asgeojson(r record, geom_column text, maxdecimaldigits integer, pretty_bool boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6220 (class 0 OID 0)
-- Dependencies: 1146
-- Name: FUNCTION st_asgml(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asgml(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6221 (class 0 OID 0)
-- Dependencies: 974
-- Name: FUNCTION st_asgml(geom extensions.geometry, maxdecimaldigits integer, options integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asgml(geom extensions.geometry, maxdecimaldigits integer, options integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6222 (class 0 OID 0)
-- Dependencies: 1145
-- Name: FUNCTION st_asgml(geog extensions.geography, maxdecimaldigits integer, options integer, nprefix text, id text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asgml(geog extensions.geography, maxdecimaldigits integer, options integer, nprefix text, id text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6223 (class 0 OID 0)
-- Dependencies: 1144
-- Name: FUNCTION st_asgml(version integer, geog extensions.geography, maxdecimaldigits integer, options integer, nprefix text, id text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asgml(version integer, geog extensions.geography, maxdecimaldigits integer, options integer, nprefix text, id text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6224 (class 0 OID 0)
-- Dependencies: 975
-- Name: FUNCTION st_asgml(version integer, geom extensions.geometry, maxdecimaldigits integer, options integer, nprefix text, id text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asgml(version integer, geom extensions.geometry, maxdecimaldigits integer, options integer, nprefix text, id text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6225 (class 0 OID 0)
-- Dependencies: 719
-- Name: FUNCTION st_ashexewkb(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_ashexewkb(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6226 (class 0 OID 0)
-- Dependencies: 720
-- Name: FUNCTION st_ashexewkb(extensions.geometry, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_ashexewkb(extensions.geometry, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6227 (class 0 OID 0)
-- Dependencies: 1148
-- Name: FUNCTION st_askml(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_askml(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6228 (class 0 OID 0)
-- Dependencies: 1147
-- Name: FUNCTION st_askml(geog extensions.geography, maxdecimaldigits integer, nprefix text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_askml(geog extensions.geography, maxdecimaldigits integer, nprefix text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6229 (class 0 OID 0)
-- Dependencies: 976
-- Name: FUNCTION st_askml(geom extensions.geometry, maxdecimaldigits integer, nprefix text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_askml(geom extensions.geometry, maxdecimaldigits integer, nprefix text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6230 (class 0 OID 0)
-- Dependencies: 722
-- Name: FUNCTION st_aslatlontext(geom extensions.geometry, tmpl text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_aslatlontext(geom extensions.geometry, tmpl text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6231 (class 0 OID 0)
-- Dependencies: 965
-- Name: FUNCTION st_asmarc21(geom extensions.geometry, format text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asmarc21(geom extensions.geometry, format text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6232 (class 0 OID 0)
-- Dependencies: 990
-- Name: FUNCTION st_asmvtgeom(geom extensions.geometry, bounds extensions.box2d, extent integer, buffer integer, clip_geom boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asmvtgeom(geom extensions.geometry, bounds extensions.box2d, extent integer, buffer integer, clip_geom boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6233 (class 0 OID 0)
-- Dependencies: 1143
-- Name: FUNCTION st_assvg(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_assvg(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6234 (class 0 OID 0)
-- Dependencies: 1142
-- Name: FUNCTION st_assvg(geog extensions.geography, rel integer, maxdecimaldigits integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_assvg(geog extensions.geography, rel integer, maxdecimaldigits integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6235 (class 0 OID 0)
-- Dependencies: 972
-- Name: FUNCTION st_assvg(geom extensions.geometry, rel integer, maxdecimaldigits integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_assvg(geom extensions.geometry, rel integer, maxdecimaldigits integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6236 (class 0 OID 0)
-- Dependencies: 1111
-- Name: FUNCTION st_astext(extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_astext(extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6237 (class 0 OID 0)
-- Dependencies: 1025
-- Name: FUNCTION st_astext(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_astext(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6238 (class 0 OID 0)
-- Dependencies: 1113
-- Name: FUNCTION st_astext(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_astext(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6239 (class 0 OID 0)
-- Dependencies: 1112
-- Name: FUNCTION st_astext(extensions.geography, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_astext(extensions.geography, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6240 (class 0 OID 0)
-- Dependencies: 1026
-- Name: FUNCTION st_astext(extensions.geometry, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_astext(extensions.geometry, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6241 (class 0 OID 0)
-- Dependencies: 716
-- Name: FUNCTION st_astwkb(geom extensions.geometry, prec integer, prec_z integer, prec_m integer, with_sizes boolean, with_boxes boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_astwkb(geom extensions.geometry, prec integer, prec_z integer, prec_m integer, with_sizes boolean, with_boxes boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6242 (class 0 OID 0)
-- Dependencies: 717
-- Name: FUNCTION st_astwkb(geom extensions.geometry[], ids bigint[], prec integer, prec_z integer, prec_m integer, with_sizes boolean, with_boxes boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_astwkb(geom extensions.geometry[], ids bigint[], prec integer, prec_z integer, prec_m integer, with_sizes boolean, with_boxes boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6243 (class 0 OID 0)
-- Dependencies: 1251
-- Name: FUNCTION st_asx3d(geom extensions.geometry, maxdecimaldigits integer, options integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asx3d(geom extensions.geometry, maxdecimaldigits integer, options integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6244 (class 0 OID 0)
-- Dependencies: 1166
-- Name: FUNCTION st_azimuth(geog1 extensions.geography, geog2 extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_azimuth(geog1 extensions.geography, geog2 extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6245 (class 0 OID 0)
-- Dependencies: 683
-- Name: FUNCTION st_azimuth(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_azimuth(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6246 (class 0 OID 0)
-- Dependencies: 1087
-- Name: FUNCTION st_bdmpolyfromtext(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_bdmpolyfromtext(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6247 (class 0 OID 0)
-- Dependencies: 1086
-- Name: FUNCTION st_bdpolyfromtext(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_bdpolyfromtext(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6248 (class 0 OID 0)
-- Dependencies: 864
-- Name: FUNCTION st_boundary(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_boundary(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6249 (class 0 OID 0)
-- Dependencies: 703
-- Name: FUNCTION st_boundingdiagonal(geom extensions.geometry, fits boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_boundingdiagonal(geom extensions.geometry, fits boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6250 (class 0 OID 0)
-- Dependencies: 1003
-- Name: FUNCTION st_box2dfromgeohash(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_box2dfromgeohash(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6251 (class 0 OID 0)
-- Dependencies: 1191
-- Name: FUNCTION st_buffer(extensions.geography, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_buffer(extensions.geography, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6252 (class 0 OID 0)
-- Dependencies: 1194
-- Name: FUNCTION st_buffer(text, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_buffer(text, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6253 (class 0 OID 0)
-- Dependencies: 1192
-- Name: FUNCTION st_buffer(extensions.geography, double precision, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_buffer(extensions.geography, double precision, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6254 (class 0 OID 0)
-- Dependencies: 1193
-- Name: FUNCTION st_buffer(extensions.geography, double precision, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_buffer(extensions.geography, double precision, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6255 (class 0 OID 0)
-- Dependencies: 846
-- Name: FUNCTION st_buffer(geom extensions.geometry, radius double precision, quadsegs integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_buffer(geom extensions.geometry, radius double precision, quadsegs integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6256 (class 0 OID 0)
-- Dependencies: 845
-- Name: FUNCTION st_buffer(geom extensions.geometry, radius double precision, options text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_buffer(geom extensions.geometry, radius double precision, options text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6257 (class 0 OID 0)
-- Dependencies: 1195
-- Name: FUNCTION st_buffer(text, double precision, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_buffer(text, double precision, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6258 (class 0 OID 0)
-- Dependencies: 1196
-- Name: FUNCTION st_buffer(text, double precision, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_buffer(text, double precision, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6259 (class 0 OID 0)
-- Dependencies: 745
-- Name: FUNCTION st_buildarea(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_buildarea(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6260 (class 0 OID 0)
-- Dependencies: 951
-- Name: FUNCTION st_centroid(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_centroid(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6261 (class 0 OID 0)
-- Dependencies: 1183
-- Name: FUNCTION st_centroid(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_centroid(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6262 (class 0 OID 0)
-- Dependencies: 1182
-- Name: FUNCTION st_centroid(extensions.geography, use_spheroid boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_centroid(extensions.geography, use_spheroid boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6263 (class 0 OID 0)
-- Dependencies: 829
-- Name: FUNCTION st_chaikinsmoothing(extensions.geometry, integer, boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_chaikinsmoothing(extensions.geometry, integer, boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6264 (class 0 OID 0)
-- Dependencies: 877
-- Name: FUNCTION st_cleangeometry(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_cleangeometry(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6265 (class 0 OID 0)
-- Dependencies: 872
-- Name: FUNCTION st_clipbybox2d(geom extensions.geometry, box extensions.box2d); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_clipbybox2d(geom extensions.geometry, box extensions.box2d) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6266 (class 0 OID 0)
-- Dependencies: 1080
-- Name: FUNCTION st_closestpoint(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_closestpoint(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6267 (class 0 OID 0)
-- Dependencies: 840
-- Name: FUNCTION st_closestpointofapproach(extensions.geometry, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_closestpointofapproach(extensions.geometry, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6268 (class 0 OID 0)
-- Dependencies: 749
-- Name: FUNCTION st_clusterdbscan(extensions.geometry, eps double precision, minpoints integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_clusterdbscan(extensions.geometry, eps double precision, minpoints integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6269 (class 0 OID 0)
-- Dependencies: 747
-- Name: FUNCTION st_clusterintersecting(extensions.geometry[]); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_clusterintersecting(extensions.geometry[]) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6270 (class 0 OID 0)
-- Dependencies: 908
-- Name: FUNCTION st_clusterkmeans(geom extensions.geometry, k integer, max_radius double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_clusterkmeans(geom extensions.geometry, k integer, max_radius double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6271 (class 0 OID 0)
-- Dependencies: 748
-- Name: FUNCTION st_clusterwithin(extensions.geometry[], double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_clusterwithin(extensions.geometry[], double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6272 (class 0 OID 0)
-- Dependencies: 892
-- Name: FUNCTION st_collect(extensions.geometry[]); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_collect(extensions.geometry[]) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6273 (class 0 OID 0)
-- Dependencies: 891
-- Name: FUNCTION st_collect(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_collect(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6274 (class 0 OID 0)
-- Dependencies: 692
-- Name: FUNCTION st_collectionextract(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_collectionextract(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6275 (class 0 OID 0)
-- Dependencies: 691
-- Name: FUNCTION st_collectionextract(extensions.geometry, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_collectionextract(extensions.geometry, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6276 (class 0 OID 0)
-- Dependencies: 693
-- Name: FUNCTION st_collectionhomogenize(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_collectionhomogenize(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6277 (class 0 OID 0)
-- Dependencies: 890
-- Name: FUNCTION st_combinebbox(extensions.box2d, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_combinebbox(extensions.box2d, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6278 (class 0 OID 0)
-- Dependencies: 889
-- Name: FUNCTION st_combinebbox(extensions.box3d, extensions.box3d); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_combinebbox(extensions.box3d, extensions.box3d) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6279 (class 0 OID 0)
-- Dependencies: 888
-- Name: FUNCTION st_combinebbox(extensions.box3d, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_combinebbox(extensions.box3d, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6280 (class 0 OID 0)
-- Dependencies: 1249
-- Name: FUNCTION st_concavehull(param_geom extensions.geometry, param_pctconvex double precision, param_allow_holes boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_concavehull(param_geom extensions.geometry, param_pctconvex double precision, param_allow_holes boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6281 (class 0 OID 0)
-- Dependencies: 936
-- Name: FUNCTION st_contains(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_contains(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6282 (class 0 OID 0)
-- Dependencies: 937
-- Name: FUNCTION st_containsproperly(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_containsproperly(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6283 (class 0 OID 0)
-- Dependencies: 853
-- Name: FUNCTION st_convexhull(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_convexhull(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6284 (class 0 OID 0)
-- Dependencies: 1214
-- Name: FUNCTION st_coorddim(geometry extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_coorddim(geometry extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6285 (class 0 OID 0)
-- Dependencies: 1189
-- Name: FUNCTION st_coveredby(geog1 extensions.geography, geog2 extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_coveredby(geog1 extensions.geography, geog2 extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6286 (class 0 OID 0)
-- Dependencies: 940
-- Name: FUNCTION st_coveredby(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_coveredby(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6287 (class 0 OID 0)
-- Dependencies: 1200
-- Name: FUNCTION st_coveredby(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_coveredby(text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6288 (class 0 OID 0)
-- Dependencies: 1187
-- Name: FUNCTION st_covers(geog1 extensions.geography, geog2 extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_covers(geog1 extensions.geography, geog2 extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6289 (class 0 OID 0)
-- Dependencies: 939
-- Name: FUNCTION st_covers(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_covers(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6290 (class 0 OID 0)
-- Dependencies: 1199
-- Name: FUNCTION st_covers(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_covers(text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6291 (class 0 OID 0)
-- Dependencies: 842
-- Name: FUNCTION st_cpawithin(extensions.geometry, extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_cpawithin(extensions.geometry, extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6292 (class 0 OID 0)
-- Dependencies: 935
-- Name: FUNCTION st_crosses(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_crosses(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6293 (class 0 OID 0)
-- Dependencies: 1215
-- Name: FUNCTION st_curvetoline(geom extensions.geometry, tol double precision, toltype integer, flags integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_curvetoline(geom extensions.geometry, tol double precision, toltype integer, flags integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6294 (class 0 OID 0)
-- Dependencies: 883
-- Name: FUNCTION st_delaunaytriangles(g1 extensions.geometry, tolerance double precision, flags integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_delaunaytriangles(g1 extensions.geometry, tolerance double precision, flags integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6295 (class 0 OID 0)
-- Dependencies: 942
-- Name: FUNCTION st_dfullywithin(geom1 extensions.geometry, geom2 extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_dfullywithin(geom1 extensions.geometry, geom2 extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6296 (class 0 OID 0)
-- Dependencies: 863
-- Name: FUNCTION st_difference(geom1 extensions.geometry, geom2 extensions.geometry, gridsize double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_difference(geom1 extensions.geometry, geom2 extensions.geometry, gridsize double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6297 (class 0 OID 0)
-- Dependencies: 1009
-- Name: FUNCTION st_dimension(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_dimension(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6298 (class 0 OID 0)
-- Dependencies: 912
-- Name: FUNCTION st_disjoint(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_disjoint(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6299 (class 0 OID 0)
-- Dependencies: 681
-- Name: FUNCTION st_distance(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_distance(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6300 (class 0 OID 0)
-- Dependencies: 1152
-- Name: FUNCTION st_distance(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_distance(text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6301 (class 0 OID 0)
-- Dependencies: 1151
-- Name: FUNCTION st_distance(geog1 extensions.geography, geog2 extensions.geography, use_spheroid boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_distance(geog1 extensions.geography, geog2 extensions.geography, use_spheroid boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6302 (class 0 OID 0)
-- Dependencies: 841
-- Name: FUNCTION st_distancecpa(extensions.geometry, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_distancecpa(extensions.geometry, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6303 (class 0 OID 0)
-- Dependencies: 1203
-- Name: FUNCTION st_distancesphere(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_distancesphere(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6304 (class 0 OID 0)
-- Dependencies: 1204
-- Name: FUNCTION st_distancesphere(geom1 extensions.geometry, geom2 extensions.geometry, radius double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_distancesphere(geom1 extensions.geometry, geom2 extensions.geometry, radius double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6305 (class 0 OID 0)
-- Dependencies: 680
-- Name: FUNCTION st_distancespheroid(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_distancespheroid(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6306 (class 0 OID 0)
-- Dependencies: 679
-- Name: FUNCTION st_distancespheroid(geom1 extensions.geometry, geom2 extensions.geometry, extensions.spheroid); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_distancespheroid(geom1 extensions.geometry, geom2 extensions.geometry, extensions.spheroid) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6307 (class 0 OID 0)
-- Dependencies: 767
-- Name: FUNCTION st_dump(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_dump(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6308 (class 0 OID 0)
-- Dependencies: 769
-- Name: FUNCTION st_dumppoints(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_dumppoints(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6309 (class 0 OID 0)
-- Dependencies: 768
-- Name: FUNCTION st_dumprings(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_dumprings(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6310 (class 0 OID 0)
-- Dependencies: 770
-- Name: FUNCTION st_dumpsegments(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_dumpsegments(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6311 (class 0 OID 0)
-- Dependencies: 932
-- Name: FUNCTION st_dwithin(geom1 extensions.geometry, geom2 extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_dwithin(geom1 extensions.geometry, geom2 extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6312 (class 0 OID 0)
-- Dependencies: 1201
-- Name: FUNCTION st_dwithin(text, text, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_dwithin(text, text, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6313 (class 0 OID 0)
-- Dependencies: 1188
-- Name: FUNCTION st_dwithin(geog1 extensions.geography, geog2 extensions.geography, tolerance double precision, use_spheroid boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_dwithin(geog1 extensions.geography, geog2 extensions.geography, tolerance double precision, use_spheroid boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6314 (class 0 OID 0)
-- Dependencies: 1020
-- Name: FUNCTION st_endpoint(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_endpoint(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6315 (class 0 OID 0)
-- Dependencies: 702
-- Name: FUNCTION st_envelope(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_envelope(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6316 (class 0 OID 0)
-- Dependencies: 947
-- Name: FUNCTION st_equals(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_equals(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6317 (class 0 OID 0)
-- Dependencies: 656
-- Name: FUNCTION st_estimatedextent(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_estimatedextent(text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6318 (class 0 OID 0)
-- Dependencies: 655
-- Name: FUNCTION st_estimatedextent(text, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_estimatedextent(text, text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6319 (class 0 OID 0)
-- Dependencies: 654
-- Name: FUNCTION st_estimatedextent(text, text, text, boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_estimatedextent(text, text, text, boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6320 (class 0 OID 0)
-- Dependencies: 650
-- Name: FUNCTION st_expand(extensions.box2d, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_expand(extensions.box2d, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6321 (class 0 OID 0)
-- Dependencies: 698
-- Name: FUNCTION st_expand(extensions.box3d, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_expand(extensions.box3d, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6322 (class 0 OID 0)
-- Dependencies: 700
-- Name: FUNCTION st_expand(extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_expand(extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6323 (class 0 OID 0)
-- Dependencies: 651
-- Name: FUNCTION st_expand(box extensions.box2d, dx double precision, dy double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_expand(box extensions.box2d, dx double precision, dy double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6324 (class 0 OID 0)
-- Dependencies: 699
-- Name: FUNCTION st_expand(box extensions.box3d, dx double precision, dy double precision, dz double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_expand(box extensions.box3d, dx double precision, dy double precision, dz double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6325 (class 0 OID 0)
-- Dependencies: 701
-- Name: FUNCTION st_expand(geom extensions.geometry, dx double precision, dy double precision, dz double precision, dm double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_expand(geom extensions.geometry, dx double precision, dy double precision, dz double precision, dm double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6326 (class 0 OID 0)
-- Dependencies: 1010
-- Name: FUNCTION st_exteriorring(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_exteriorring(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6327 (class 0 OID 0)
-- Dependencies: 828
-- Name: FUNCTION st_filterbym(extensions.geometry, double precision, double precision, boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_filterbym(extensions.geometry, double precision, double precision, boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6328 (class 0 OID 0)
-- Dependencies: 658
-- Name: FUNCTION st_findextent(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_findextent(text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6329 (class 0 OID 0)
-- Dependencies: 657
-- Name: FUNCTION st_findextent(text, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_findextent(text, text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6330 (class 0 OID 0)
-- Dependencies: 1085
-- Name: FUNCTION st_flipcoordinates(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_flipcoordinates(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6331 (class 0 OID 0)
-- Dependencies: 685
-- Name: FUNCTION st_force2d(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_force2d(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6332 (class 0 OID 0)
-- Dependencies: 687
-- Name: FUNCTION st_force3d(geom extensions.geometry, zvalue double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_force3d(geom extensions.geometry, zvalue double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6333 (class 0 OID 0)
-- Dependencies: 688
-- Name: FUNCTION st_force3dm(geom extensions.geometry, mvalue double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_force3dm(geom extensions.geometry, mvalue double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6334 (class 0 OID 0)
-- Dependencies: 686
-- Name: FUNCTION st_force3dz(geom extensions.geometry, zvalue double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_force3dz(geom extensions.geometry, zvalue double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6335 (class 0 OID 0)
-- Dependencies: 689
-- Name: FUNCTION st_force4d(geom extensions.geometry, zvalue double precision, mvalue double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_force4d(geom extensions.geometry, zvalue double precision, mvalue double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6336 (class 0 OID 0)
-- Dependencies: 690
-- Name: FUNCTION st_forcecollection(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_forcecollection(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6337 (class 0 OID 0)
-- Dependencies: 695
-- Name: FUNCTION st_forcecurve(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_forcecurve(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6338 (class 0 OID 0)
-- Dependencies: 707
-- Name: FUNCTION st_forcepolygonccw(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_forcepolygonccw(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6339 (class 0 OID 0)
-- Dependencies: 706
-- Name: FUNCTION st_forcepolygoncw(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_forcepolygoncw(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6340 (class 0 OID 0)
-- Dependencies: 708
-- Name: FUNCTION st_forcerhr(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_forcerhr(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6341 (class 0 OID 0)
-- Dependencies: 696
-- Name: FUNCTION st_forcesfs(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_forcesfs(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6342 (class 0 OID 0)
-- Dependencies: 697
-- Name: FUNCTION st_forcesfs(extensions.geometry, version text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_forcesfs(extensions.geometry, version text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6343 (class 0 OID 0)
-- Dependencies: 861
-- Name: FUNCTION st_frechetdistance(geom1 extensions.geometry, geom2 extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_frechetdistance(geom1 extensions.geometry, geom2 extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6344 (class 0 OID 0)
-- Dependencies: 1000
-- Name: FUNCTION st_fromflatgeobuf(anyelement, bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_fromflatgeobuf(anyelement, bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6345 (class 0 OID 0)
-- Dependencies: 999
-- Name: FUNCTION st_fromflatgeobuftotable(text, text, bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_fromflatgeobuftotable(text, text, bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6346 (class 0 OID 0)
-- Dependencies: 851
-- Name: FUNCTION st_generatepoints(area extensions.geometry, npoints integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_generatepoints(area extensions.geometry, npoints integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6347 (class 0 OID 0)
-- Dependencies: 852
-- Name: FUNCTION st_generatepoints(area extensions.geometry, npoints integer, seed integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_generatepoints(area extensions.geometry, npoints integer, seed integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6348 (class 0 OID 0)
-- Dependencies: 1115
-- Name: FUNCTION st_geogfromtext(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geogfromtext(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6349 (class 0 OID 0)
-- Dependencies: 1116
-- Name: FUNCTION st_geogfromwkb(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geogfromwkb(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6350 (class 0 OID 0)
-- Dependencies: 1114
-- Name: FUNCTION st_geographyfromtext(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geographyfromtext(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6351 (class 0 OID 0)
-- Dependencies: 1179
-- Name: FUNCTION st_geohash(geog extensions.geography, maxchars integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geohash(geog extensions.geography, maxchars integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6352 (class 0 OID 0)
-- Dependencies: 1001
-- Name: FUNCTION st_geohash(geom extensions.geometry, maxchars integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geohash(geom extensions.geometry, maxchars integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6353 (class 0 OID 0)
-- Dependencies: 1052
-- Name: FUNCTION st_geomcollfromtext(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomcollfromtext(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6354 (class 0 OID 0)
-- Dependencies: 1051
-- Name: FUNCTION st_geomcollfromtext(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomcollfromtext(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6355 (class 0 OID 0)
-- Dependencies: 1077
-- Name: FUNCTION st_geomcollfromwkb(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomcollfromwkb(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6356 (class 0 OID 0)
-- Dependencies: 1076
-- Name: FUNCTION st_geomcollfromwkb(bytea, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomcollfromwkb(bytea, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6357 (class 0 OID 0)
-- Dependencies: 952
-- Name: FUNCTION st_geometricmedian(g extensions.geometry, tolerance double precision, max_iter integer, fail_if_not_converged boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geometricmedian(g extensions.geometry, tolerance double precision, max_iter integer, fail_if_not_converged boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6358 (class 0 OID 0)
-- Dependencies: 1027
-- Name: FUNCTION st_geometryfromtext(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geometryfromtext(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6359 (class 0 OID 0)
-- Dependencies: 1028
-- Name: FUNCTION st_geometryfromtext(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geometryfromtext(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6360 (class 0 OID 0)
-- Dependencies: 1008
-- Name: FUNCTION st_geometryn(extensions.geometry, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geometryn(extensions.geometry, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6361 (class 0 OID 0)
-- Dependencies: 1015
-- Name: FUNCTION st_geometrytype(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geometrytype(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6362 (class 0 OID 0)
-- Dependencies: 724
-- Name: FUNCTION st_geomfromewkb(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomfromewkb(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6363 (class 0 OID 0)
-- Dependencies: 727
-- Name: FUNCTION st_geomfromewkt(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomfromewkt(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6364 (class 0 OID 0)
-- Dependencies: 1005
-- Name: FUNCTION st_geomfromgeohash(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomfromgeohash(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6365 (class 0 OID 0)
-- Dependencies: 967
-- Name: FUNCTION st_geomfromgeojson(json); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomfromgeojson(json) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6366 (class 0 OID 0)
-- Dependencies: 968
-- Name: FUNCTION st_geomfromgeojson(jsonb); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomfromgeojson(jsonb) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6367 (class 0 OID 0)
-- Dependencies: 966
-- Name: FUNCTION st_geomfromgeojson(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomfromgeojson(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6368 (class 0 OID 0)
-- Dependencies: 960
-- Name: FUNCTION st_geomfromgml(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomfromgml(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6369 (class 0 OID 0)
-- Dependencies: 959
-- Name: FUNCTION st_geomfromgml(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomfromgml(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6370 (class 0 OID 0)
-- Dependencies: 963
-- Name: FUNCTION st_geomfromkml(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomfromkml(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6371 (class 0 OID 0)
-- Dependencies: 964
-- Name: FUNCTION st_geomfrommarc21(marc21xml text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomfrommarc21(marc21xml text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6372 (class 0 OID 0)
-- Dependencies: 1029
-- Name: FUNCTION st_geomfromtext(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomfromtext(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6373 (class 0 OID 0)
-- Dependencies: 1030
-- Name: FUNCTION st_geomfromtext(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomfromtext(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6374 (class 0 OID 0)
-- Dependencies: 725
-- Name: FUNCTION st_geomfromtwkb(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomfromtwkb(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6375 (class 0 OID 0)
-- Dependencies: 1053
-- Name: FUNCTION st_geomfromwkb(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomfromwkb(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6376 (class 0 OID 0)
-- Dependencies: 1054
-- Name: FUNCTION st_geomfromwkb(bytea, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomfromwkb(bytea, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6377 (class 0 OID 0)
-- Dependencies: 961
-- Name: FUNCTION st_gmltosql(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_gmltosql(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6378 (class 0 OID 0)
-- Dependencies: 962
-- Name: FUNCTION st_gmltosql(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_gmltosql(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6379 (class 0 OID 0)
-- Dependencies: 1216
-- Name: FUNCTION st_hasarc(geometry extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_hasarc(geometry extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6380 (class 0 OID 0)
-- Dependencies: 859
-- Name: FUNCTION st_hausdorffdistance(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_hausdorffdistance(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6381 (class 0 OID 0)
-- Dependencies: 860
-- Name: FUNCTION st_hausdorffdistance(geom1 extensions.geometry, geom2 extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_hausdorffdistance(geom1 extensions.geometry, geom2 extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6382 (class 0 OID 0)
-- Dependencies: 1229
-- Name: FUNCTION st_hexagon(size double precision, cell_i integer, cell_j integer, origin extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_hexagon(size double precision, cell_i integer, cell_j integer, origin extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6383 (class 0 OID 0)
-- Dependencies: 1231
-- Name: FUNCTION st_hexagongrid(size double precision, bounds extensions.geometry, OUT geom extensions.geometry, OUT i integer, OUT j integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_hexagongrid(size double precision, bounds extensions.geometry, OUT geom extensions.geometry, OUT i integer, OUT j integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6384 (class 0 OID 0)
-- Dependencies: 1013
-- Name: FUNCTION st_interiorringn(extensions.geometry, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_interiorringn(extensions.geometry, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6385 (class 0 OID 0)
-- Dependencies: 1228
-- Name: FUNCTION st_interpolatepoint(line extensions.geometry, point extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_interpolatepoint(line extensions.geometry, point extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6386 (class 0 OID 0)
-- Dependencies: 1197
-- Name: FUNCTION st_intersection(extensions.geography, extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_intersection(extensions.geography, extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6387 (class 0 OID 0)
-- Dependencies: 1198
-- Name: FUNCTION st_intersection(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_intersection(text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6388 (class 0 OID 0)
-- Dependencies: 844
-- Name: FUNCTION st_intersection(geom1 extensions.geometry, geom2 extensions.geometry, gridsize double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_intersection(geom1 extensions.geometry, geom2 extensions.geometry, gridsize double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6389 (class 0 OID 0)
-- Dependencies: 1190
-- Name: FUNCTION st_intersects(geog1 extensions.geography, geog2 extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_intersects(geog1 extensions.geography, geog2 extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6390 (class 0 OID 0)
-- Dependencies: 934
-- Name: FUNCTION st_intersects(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_intersects(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6391 (class 0 OID 0)
-- Dependencies: 1202
-- Name: FUNCTION st_intersects(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_intersects(text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6392 (class 0 OID 0)
-- Dependencies: 1021
-- Name: FUNCTION st_isclosed(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_isclosed(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6393 (class 0 OID 0)
-- Dependencies: 956
-- Name: FUNCTION st_iscollection(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_iscollection(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6394 (class 0 OID 0)
-- Dependencies: 1022
-- Name: FUNCTION st_isempty(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_isempty(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6395 (class 0 OID 0)
-- Dependencies: 678
-- Name: FUNCTION st_ispolygonccw(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_ispolygonccw(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6396 (class 0 OID 0)
-- Dependencies: 677
-- Name: FUNCTION st_ispolygoncw(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_ispolygoncw(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6397 (class 0 OID 0)
-- Dependencies: 953
-- Name: FUNCTION st_isring(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_isring(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6398 (class 0 OID 0)
-- Dependencies: 955
-- Name: FUNCTION st_issimple(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_issimple(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6399 (class 0 OID 0)
-- Dependencies: 948
-- Name: FUNCTION st_isvalid(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_isvalid(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6400 (class 0 OID 0)
-- Dependencies: 858
-- Name: FUNCTION st_isvalid(extensions.geometry, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_isvalid(extensions.geometry, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6401 (class 0 OID 0)
-- Dependencies: 856
-- Name: FUNCTION st_isvaliddetail(geom extensions.geometry, flags integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_isvaliddetail(geom extensions.geometry, flags integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6402 (class 0 OID 0)
-- Dependencies: 855
-- Name: FUNCTION st_isvalidreason(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_isvalidreason(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6403 (class 0 OID 0)
-- Dependencies: 857
-- Name: FUNCTION st_isvalidreason(extensions.geometry, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_isvalidreason(extensions.geometry, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6404 (class 0 OID 0)
-- Dependencies: 843
-- Name: FUNCTION st_isvalidtrajectory(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_isvalidtrajectory(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6405 (class 0 OID 0)
-- Dependencies: 669
-- Name: FUNCTION st_length(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_length(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6406 (class 0 OID 0)
-- Dependencies: 1164
-- Name: FUNCTION st_length(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_length(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6407 (class 0 OID 0)
-- Dependencies: 1163
-- Name: FUNCTION st_length(geog extensions.geography, use_spheroid boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_length(geog extensions.geography, use_spheroid boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6408 (class 0 OID 0)
-- Dependencies: 668
-- Name: FUNCTION st_length2d(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_length2d(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6409 (class 0 OID 0)
-- Dependencies: 671
-- Name: FUNCTION st_length2dspheroid(extensions.geometry, extensions.spheroid); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_length2dspheroid(extensions.geometry, extensions.spheroid) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6410 (class 0 OID 0)
-- Dependencies: 670
-- Name: FUNCTION st_lengthspheroid(extensions.geometry, extensions.spheroid); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_lengthspheroid(extensions.geometry, extensions.spheroid) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6411 (class 0 OID 0)
-- Dependencies: 1282
-- Name: FUNCTION st_letters(letters text, font json); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_letters(letters text, font json) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6412 (class 0 OID 0)
-- Dependencies: 931
-- Name: FUNCTION st_linecrossingdirection(line1 extensions.geometry, line2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_linecrossingdirection(line1 extensions.geometry, line2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6413 (class 0 OID 0)
-- Dependencies: 970
-- Name: FUNCTION st_linefromencodedpolyline(txtin text, nprecision integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_linefromencodedpolyline(txtin text, nprecision integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6414 (class 0 OID 0)
-- Dependencies: 735
-- Name: FUNCTION st_linefrommultipoint(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_linefrommultipoint(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6415 (class 0 OID 0)
-- Dependencies: 1034
-- Name: FUNCTION st_linefromtext(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_linefromtext(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6416 (class 0 OID 0)
-- Dependencies: 1035
-- Name: FUNCTION st_linefromtext(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_linefromtext(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6417 (class 0 OID 0)
-- Dependencies: 1058
-- Name: FUNCTION st_linefromwkb(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_linefromwkb(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6418 (class 0 OID 0)
-- Dependencies: 1057
-- Name: FUNCTION st_linefromwkb(bytea, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_linefromwkb(bytea, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6419 (class 0 OID 0)
-- Dependencies: 835
-- Name: FUNCTION st_lineinterpolatepoint(extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_lineinterpolatepoint(extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6420 (class 0 OID 0)
-- Dependencies: 836
-- Name: FUNCTION st_lineinterpolatepoints(extensions.geometry, double precision, repeat boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_lineinterpolatepoints(extensions.geometry, double precision, repeat boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6421 (class 0 OID 0)
-- Dependencies: 838
-- Name: FUNCTION st_linelocatepoint(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_linelocatepoint(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6422 (class 0 OID 0)
-- Dependencies: 750
-- Name: FUNCTION st_linemerge(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_linemerge(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6423 (class 0 OID 0)
-- Dependencies: 751
-- Name: FUNCTION st_linemerge(extensions.geometry, boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_linemerge(extensions.geometry, boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6424 (class 0 OID 0)
-- Dependencies: 1060
-- Name: FUNCTION st_linestringfromwkb(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_linestringfromwkb(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6425 (class 0 OID 0)
-- Dependencies: 1059
-- Name: FUNCTION st_linestringfromwkb(bytea, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_linestringfromwkb(bytea, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6426 (class 0 OID 0)
-- Dependencies: 837
-- Name: FUNCTION st_linesubstring(extensions.geometry, double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_linesubstring(extensions.geometry, double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6427 (class 0 OID 0)
-- Dependencies: 1217
-- Name: FUNCTION st_linetocurve(geometry extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_linetocurve(geometry extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6428 (class 0 OID 0)
-- Dependencies: 1226
-- Name: FUNCTION st_locatealong(geometry extensions.geometry, measure double precision, leftrightoffset double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_locatealong(geometry extensions.geometry, measure double precision, leftrightoffset double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6429 (class 0 OID 0)
-- Dependencies: 1225
-- Name: FUNCTION st_locatebetween(geometry extensions.geometry, frommeasure double precision, tomeasure double precision, leftrightoffset double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_locatebetween(geometry extensions.geometry, frommeasure double precision, tomeasure double precision, leftrightoffset double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6430 (class 0 OID 0)
-- Dependencies: 1227
-- Name: FUNCTION st_locatebetweenelevations(geometry extensions.geometry, fromelevation double precision, toelevation double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_locatebetweenelevations(geometry extensions.geometry, fromelevation double precision, toelevation double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6431 (class 0 OID 0)
-- Dependencies: 1083
-- Name: FUNCTION st_longestline(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_longestline(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6432 (class 0 OID 0)
-- Dependencies: 580
-- Name: FUNCTION st_m(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_m(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6433 (class 0 OID 0)
-- Dependencies: 653
-- Name: FUNCTION st_makebox2d(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_makebox2d(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6434 (class 0 OID 0)
-- Dependencies: 741
-- Name: FUNCTION st_makeenvelope(double precision, double precision, double precision, double precision, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_makeenvelope(double precision, double precision, double precision, double precision, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6435 (class 0 OID 0)
-- Dependencies: 734
-- Name: FUNCTION st_makeline(extensions.geometry[]); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_makeline(extensions.geometry[]) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6436 (class 0 OID 0)
-- Dependencies: 736
-- Name: FUNCTION st_makeline(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_makeline(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6437 (class 0 OID 0)
-- Dependencies: 729
-- Name: FUNCTION st_makepoint(double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_makepoint(double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6438 (class 0 OID 0)
-- Dependencies: 730
-- Name: FUNCTION st_makepoint(double precision, double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_makepoint(double precision, double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6439 (class 0 OID 0)
-- Dependencies: 731
-- Name: FUNCTION st_makepoint(double precision, double precision, double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_makepoint(double precision, double precision, double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6440 (class 0 OID 0)
-- Dependencies: 732
-- Name: FUNCTION st_makepointm(double precision, double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_makepointm(double precision, double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6441 (class 0 OID 0)
-- Dependencies: 744
-- Name: FUNCTION st_makepolygon(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_makepolygon(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6442 (class 0 OID 0)
-- Dependencies: 743
-- Name: FUNCTION st_makepolygon(extensions.geometry, extensions.geometry[]); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_makepolygon(extensions.geometry, extensions.geometry[]) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6443 (class 0 OID 0)
-- Dependencies: 875
-- Name: FUNCTION st_makevalid(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_makevalid(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6444 (class 0 OID 0)
-- Dependencies: 876
-- Name: FUNCTION st_makevalid(geom extensions.geometry, params text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_makevalid(geom extensions.geometry, params text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6445 (class 0 OID 0)
-- Dependencies: 1079
-- Name: FUNCTION st_maxdistance(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_maxdistance(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6446 (class 0 OID 0)
-- Dependencies: 862
-- Name: FUNCTION st_maximuminscribedcircle(extensions.geometry, OUT center extensions.geometry, OUT nearest extensions.geometry, OUT radius double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_maximuminscribedcircle(extensions.geometry, OUT center extensions.geometry, OUT nearest extensions.geometry, OUT radius double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6447 (class 0 OID 0)
-- Dependencies: 663
-- Name: FUNCTION st_memsize(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_memsize(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6448 (class 0 OID 0)
-- Dependencies: 848
-- Name: FUNCTION st_minimumboundingcircle(inputgeom extensions.geometry, segs_per_quarter integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_minimumboundingcircle(inputgeom extensions.geometry, segs_per_quarter integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6449 (class 0 OID 0)
-- Dependencies: 847
-- Name: FUNCTION st_minimumboundingradius(extensions.geometry, OUT center extensions.geometry, OUT radius double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_minimumboundingradius(extensions.geometry, OUT center extensions.geometry, OUT radius double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6450 (class 0 OID 0)
-- Dependencies: 949
-- Name: FUNCTION st_minimumclearance(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_minimumclearance(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6451 (class 0 OID 0)
-- Dependencies: 950
-- Name: FUNCTION st_minimumclearanceline(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_minimumclearanceline(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6452 (class 0 OID 0)
-- Dependencies: 1041
-- Name: FUNCTION st_mlinefromtext(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_mlinefromtext(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6453 (class 0 OID 0)
-- Dependencies: 1040
-- Name: FUNCTION st_mlinefromtext(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_mlinefromtext(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6454 (class 0 OID 0)
-- Dependencies: 1071
-- Name: FUNCTION st_mlinefromwkb(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_mlinefromwkb(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6455 (class 0 OID 0)
-- Dependencies: 1070
-- Name: FUNCTION st_mlinefromwkb(bytea, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_mlinefromwkb(bytea, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6456 (class 0 OID 0)
-- Dependencies: 1045
-- Name: FUNCTION st_mpointfromtext(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_mpointfromtext(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6457 (class 0 OID 0)
-- Dependencies: 1044
-- Name: FUNCTION st_mpointfromtext(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_mpointfromtext(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6458 (class 0 OID 0)
-- Dependencies: 1066
-- Name: FUNCTION st_mpointfromwkb(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_mpointfromwkb(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6459 (class 0 OID 0)
-- Dependencies: 1065
-- Name: FUNCTION st_mpointfromwkb(bytea, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_mpointfromwkb(bytea, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6460 (class 0 OID 0)
-- Dependencies: 1048
-- Name: FUNCTION st_mpolyfromtext(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_mpolyfromtext(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6461 (class 0 OID 0)
-- Dependencies: 1047
-- Name: FUNCTION st_mpolyfromtext(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_mpolyfromtext(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6462 (class 0 OID 0)
-- Dependencies: 1073
-- Name: FUNCTION st_mpolyfromwkb(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_mpolyfromwkb(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6463 (class 0 OID 0)
-- Dependencies: 1072
-- Name: FUNCTION st_mpolyfromwkb(bytea, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_mpolyfromwkb(bytea, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6464 (class 0 OID 0)
-- Dependencies: 694
-- Name: FUNCTION st_multi(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_multi(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6465 (class 0 OID 0)
-- Dependencies: 1069
-- Name: FUNCTION st_multilinefromwkb(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_multilinefromwkb(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6466 (class 0 OID 0)
-- Dependencies: 1042
-- Name: FUNCTION st_multilinestringfromtext(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_multilinestringfromtext(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6467 (class 0 OID 0)
-- Dependencies: 1043
-- Name: FUNCTION st_multilinestringfromtext(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_multilinestringfromtext(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6468 (class 0 OID 0)
-- Dependencies: 1046
-- Name: FUNCTION st_multipointfromtext(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_multipointfromtext(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6469 (class 0 OID 0)
-- Dependencies: 1068
-- Name: FUNCTION st_multipointfromwkb(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_multipointfromwkb(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6470 (class 0 OID 0)
-- Dependencies: 1067
-- Name: FUNCTION st_multipointfromwkb(bytea, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_multipointfromwkb(bytea, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6471 (class 0 OID 0)
-- Dependencies: 1075
-- Name: FUNCTION st_multipolyfromwkb(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_multipolyfromwkb(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6472 (class 0 OID 0)
-- Dependencies: 1074
-- Name: FUNCTION st_multipolyfromwkb(bytea, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_multipolyfromwkb(bytea, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6473 (class 0 OID 0)
-- Dependencies: 1050
-- Name: FUNCTION st_multipolygonfromtext(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_multipolygonfromtext(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6474 (class 0 OID 0)
-- Dependencies: 1049
-- Name: FUNCTION st_multipolygonfromtext(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_multipolygonfromtext(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6475 (class 0 OID 0)
-- Dependencies: 713
-- Name: FUNCTION st_ndims(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_ndims(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6476 (class 0 OID 0)
-- Dependencies: 882
-- Name: FUNCTION st_node(g extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_node(g extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6477 (class 0 OID 0)
-- Dependencies: 711
-- Name: FUNCTION st_normalize(geom extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_normalize(geom extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6478 (class 0 OID 0)
-- Dependencies: 665
-- Name: FUNCTION st_npoints(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_npoints(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6479 (class 0 OID 0)
-- Dependencies: 666
-- Name: FUNCTION st_nrings(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_nrings(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6480 (class 0 OID 0)
-- Dependencies: 1007
-- Name: FUNCTION st_numgeometries(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_numgeometries(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6481 (class 0 OID 0)
-- Dependencies: 1012
-- Name: FUNCTION st_numinteriorring(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_numinteriorring(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6482 (class 0 OID 0)
-- Dependencies: 1011
-- Name: FUNCTION st_numinteriorrings(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_numinteriorrings(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6483 (class 0 OID 0)
-- Dependencies: 1017
-- Name: FUNCTION st_numpatches(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_numpatches(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6484 (class 0 OID 0)
-- Dependencies: 1006
-- Name: FUNCTION st_numpoints(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_numpoints(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6485 (class 0 OID 0)
-- Dependencies: 850
-- Name: FUNCTION st_offsetcurve(line extensions.geometry, distance double precision, params text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_offsetcurve(line extensions.geometry, distance double precision, params text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6486 (class 0 OID 0)
-- Dependencies: 946
-- Name: FUNCTION st_orderingequals(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_orderingequals(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6487 (class 0 OID 0)
-- Dependencies: 849
-- Name: FUNCTION st_orientedenvelope(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_orientedenvelope(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6488 (class 0 OID 0)
-- Dependencies: 941
-- Name: FUNCTION st_overlaps(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_overlaps(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6489 (class 0 OID 0)
-- Dependencies: 1018
-- Name: FUNCTION st_patchn(extensions.geometry, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_patchn(extensions.geometry, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6490 (class 0 OID 0)
-- Dependencies: 674
-- Name: FUNCTION st_perimeter(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_perimeter(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6491 (class 0 OID 0)
-- Dependencies: 1167
-- Name: FUNCTION st_perimeter(geog extensions.geography, use_spheroid boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_perimeter(geog extensions.geography, use_spheroid boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6492 (class 0 OID 0)
-- Dependencies: 673
-- Name: FUNCTION st_perimeter2d(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_perimeter2d(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6493 (class 0 OID 0)
-- Dependencies: 1218
-- Name: FUNCTION st_point(double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_point(double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6494 (class 0 OID 0)
-- Dependencies: 1219
-- Name: FUNCTION st_point(double precision, double precision, srid integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_point(double precision, double precision, srid integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6495 (class 0 OID 0)
-- Dependencies: 1004
-- Name: FUNCTION st_pointfromgeohash(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_pointfromgeohash(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6496 (class 0 OID 0)
-- Dependencies: 1032
-- Name: FUNCTION st_pointfromtext(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_pointfromtext(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6497 (class 0 OID 0)
-- Dependencies: 1033
-- Name: FUNCTION st_pointfromtext(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_pointfromtext(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6498 (class 0 OID 0)
-- Dependencies: 1056
-- Name: FUNCTION st_pointfromwkb(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_pointfromwkb(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6499 (class 0 OID 0)
-- Dependencies: 1055
-- Name: FUNCTION st_pointfromwkb(bytea, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_pointfromwkb(bytea, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6500 (class 0 OID 0)
-- Dependencies: 682
-- Name: FUNCTION st_pointinsidecircle(extensions.geometry, double precision, double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_pointinsidecircle(extensions.geometry, double precision, double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6501 (class 0 OID 0)
-- Dependencies: 1221
-- Name: FUNCTION st_pointm(xcoordinate double precision, ycoordinate double precision, mcoordinate double precision, srid integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_pointm(xcoordinate double precision, ycoordinate double precision, mcoordinate double precision, srid integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6502 (class 0 OID 0)
-- Dependencies: 1016
-- Name: FUNCTION st_pointn(extensions.geometry, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_pointn(extensions.geometry, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6503 (class 0 OID 0)
-- Dependencies: 954
-- Name: FUNCTION st_pointonsurface(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_pointonsurface(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6504 (class 0 OID 0)
-- Dependencies: 865
-- Name: FUNCTION st_points(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_points(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6505 (class 0 OID 0)
-- Dependencies: 1220
-- Name: FUNCTION st_pointz(xcoordinate double precision, ycoordinate double precision, zcoordinate double precision, srid integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_pointz(xcoordinate double precision, ycoordinate double precision, zcoordinate double precision, srid integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6506 (class 0 OID 0)
-- Dependencies: 1222
-- Name: FUNCTION st_pointzm(xcoordinate double precision, ycoordinate double precision, zcoordinate double precision, mcoordinate double precision, srid integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_pointzm(xcoordinate double precision, ycoordinate double precision, zcoordinate double precision, mcoordinate double precision, srid integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6507 (class 0 OID 0)
-- Dependencies: 1036
-- Name: FUNCTION st_polyfromtext(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_polyfromtext(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6508 (class 0 OID 0)
-- Dependencies: 1037
-- Name: FUNCTION st_polyfromtext(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_polyfromtext(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6509 (class 0 OID 0)
-- Dependencies: 1062
-- Name: FUNCTION st_polyfromwkb(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_polyfromwkb(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6510 (class 0 OID 0)
-- Dependencies: 1061
-- Name: FUNCTION st_polyfromwkb(bytea, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_polyfromwkb(bytea, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6511 (class 0 OID 0)
-- Dependencies: 1223
-- Name: FUNCTION st_polygon(extensions.geometry, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_polygon(extensions.geometry, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6512 (class 0 OID 0)
-- Dependencies: 1039
-- Name: FUNCTION st_polygonfromtext(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_polygonfromtext(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6513 (class 0 OID 0)
-- Dependencies: 1038
-- Name: FUNCTION st_polygonfromtext(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_polygonfromtext(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6514 (class 0 OID 0)
-- Dependencies: 1064
-- Name: FUNCTION st_polygonfromwkb(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_polygonfromwkb(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6515 (class 0 OID 0)
-- Dependencies: 1063
-- Name: FUNCTION st_polygonfromwkb(bytea, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_polygonfromwkb(bytea, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6516 (class 0 OID 0)
-- Dependencies: 746
-- Name: FUNCTION st_polygonize(extensions.geometry[]); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_polygonize(extensions.geometry[]) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6517 (class 0 OID 0)
-- Dependencies: 1165
-- Name: FUNCTION st_project(geog extensions.geography, distance double precision, azimuth double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_project(geog extensions.geography, distance double precision, azimuth double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6518 (class 0 OID 0)
-- Dependencies: 662
-- Name: FUNCTION st_quantizecoordinates(g extensions.geometry, prec_x integer, prec_y integer, prec_z integer, prec_m integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_quantizecoordinates(g extensions.geometry, prec_x integer, prec_y integer, prec_z integer, prec_m integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6519 (class 0 OID 0)
-- Dependencies: 874
-- Name: FUNCTION st_reduceprecision(geom extensions.geometry, gridsize double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_reduceprecision(geom extensions.geometry, gridsize double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6520 (class 0 OID 0)
-- Dependencies: 909
-- Name: FUNCTION st_relate(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_relate(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6521 (class 0 OID 0)
-- Dependencies: 910
-- Name: FUNCTION st_relate(geom1 extensions.geometry, geom2 extensions.geometry, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_relate(geom1 extensions.geometry, geom2 extensions.geometry, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6522 (class 0 OID 0)
-- Dependencies: 911
-- Name: FUNCTION st_relate(geom1 extensions.geometry, geom2 extensions.geometry, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_relate(geom1 extensions.geometry, geom2 extensions.geometry, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6523 (class 0 OID 0)
-- Dependencies: 881
-- Name: FUNCTION st_relatematch(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_relatematch(text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6524 (class 0 OID 0)
-- Dependencies: 739
-- Name: FUNCTION st_removepoint(extensions.geometry, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_removepoint(extensions.geometry, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6525 (class 0 OID 0)
-- Dependencies: 871
-- Name: FUNCTION st_removerepeatedpoints(geom extensions.geometry, tolerance double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_removerepeatedpoints(geom extensions.geometry, tolerance double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6526 (class 0 OID 0)
-- Dependencies: 704
-- Name: FUNCTION st_reverse(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_reverse(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6527 (class 0 OID 0)
-- Dependencies: 754
-- Name: FUNCTION st_rotate(extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_rotate(extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6528 (class 0 OID 0)
-- Dependencies: 756
-- Name: FUNCTION st_rotate(extensions.geometry, double precision, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_rotate(extensions.geometry, double precision, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6529 (class 0 OID 0)
-- Dependencies: 755
-- Name: FUNCTION st_rotate(extensions.geometry, double precision, double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_rotate(extensions.geometry, double precision, double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6530 (class 0 OID 0)
-- Dependencies: 758
-- Name: FUNCTION st_rotatex(extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_rotatex(extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6531 (class 0 OID 0)
-- Dependencies: 759
-- Name: FUNCTION st_rotatey(extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_rotatey(extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6532 (class 0 OID 0)
-- Dependencies: 757
-- Name: FUNCTION st_rotatez(extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_rotatez(extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6533 (class 0 OID 0)
-- Dependencies: 762
-- Name: FUNCTION st_scale(extensions.geometry, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_scale(extensions.geometry, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6534 (class 0 OID 0)
-- Dependencies: 763
-- Name: FUNCTION st_scale(extensions.geometry, extensions.geometry, origin extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_scale(extensions.geometry, extensions.geometry, origin extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6535 (class 0 OID 0)
-- Dependencies: 765
-- Name: FUNCTION st_scale(extensions.geometry, double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_scale(extensions.geometry, double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6536 (class 0 OID 0)
-- Dependencies: 764
-- Name: FUNCTION st_scale(extensions.geometry, double precision, double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_scale(extensions.geometry, double precision, double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6537 (class 0 OID 0)
-- Dependencies: 705
-- Name: FUNCTION st_scroll(extensions.geometry, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_scroll(extensions.geometry, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6538 (class 0 OID 0)
-- Dependencies: 1169
-- Name: FUNCTION st_segmentize(geog extensions.geography, max_segment_length double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_segmentize(geog extensions.geography, max_segment_length double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6539 (class 0 OID 0)
-- Dependencies: 834
-- Name: FUNCTION st_segmentize(extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_segmentize(extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6540 (class 0 OID 0)
-- Dependencies: 827
-- Name: FUNCTION st_seteffectivearea(extensions.geometry, double precision, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_seteffectivearea(extensions.geometry, double precision, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6541 (class 0 OID 0)
-- Dependencies: 740
-- Name: FUNCTION st_setpoint(extensions.geometry, integer, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_setpoint(extensions.geometry, integer, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6542 (class 0 OID 0)
-- Dependencies: 1181
-- Name: FUNCTION st_setsrid(geog extensions.geography, srid integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_setsrid(geog extensions.geography, srid integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6543 (class 0 OID 0)
-- Dependencies: 787
-- Name: FUNCTION st_setsrid(geom extensions.geometry, srid integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_setsrid(geom extensions.geometry, srid integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6544 (class 0 OID 0)
-- Dependencies: 879
-- Name: FUNCTION st_sharedpaths(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_sharedpaths(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6545 (class 0 OID 0)
-- Dependencies: 642
-- Name: FUNCTION st_shiftlongitude(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_shiftlongitude(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6546 (class 0 OID 0)
-- Dependencies: 1081
-- Name: FUNCTION st_shortestline(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_shortestline(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6547 (class 0 OID 0)
-- Dependencies: 824
-- Name: FUNCTION st_simplify(extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_simplify(extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6548 (class 0 OID 0)
-- Dependencies: 825
-- Name: FUNCTION st_simplify(extensions.geometry, double precision, boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_simplify(extensions.geometry, double precision, boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6549 (class 0 OID 0)
-- Dependencies: 1248
-- Name: FUNCTION st_simplifypolygonhull(geom extensions.geometry, vertex_fraction double precision, is_outer boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_simplifypolygonhull(geom extensions.geometry, vertex_fraction double precision, is_outer boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6550 (class 0 OID 0)
-- Dependencies: 854
-- Name: FUNCTION st_simplifypreservetopology(extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_simplifypreservetopology(extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6551 (class 0 OID 0)
-- Dependencies: 826
-- Name: FUNCTION st_simplifyvw(extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_simplifyvw(extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6552 (class 0 OID 0)
-- Dependencies: 880
-- Name: FUNCTION st_snap(geom1 extensions.geometry, geom2 extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_snap(geom1 extensions.geometry, geom2 extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6553 (class 0 OID 0)
-- Dependencies: 832
-- Name: FUNCTION st_snaptogrid(extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_snaptogrid(extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6554 (class 0 OID 0)
-- Dependencies: 831
-- Name: FUNCTION st_snaptogrid(extensions.geometry, double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_snaptogrid(extensions.geometry, double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6555 (class 0 OID 0)
-- Dependencies: 830
-- Name: FUNCTION st_snaptogrid(extensions.geometry, double precision, double precision, double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_snaptogrid(extensions.geometry, double precision, double precision, double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6556 (class 0 OID 0)
-- Dependencies: 833
-- Name: FUNCTION st_snaptogrid(geom1 extensions.geometry, geom2 extensions.geometry, double precision, double precision, double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_snaptogrid(geom1 extensions.geometry, geom2 extensions.geometry, double precision, double precision, double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6557 (class 0 OID 0)
-- Dependencies: 878
-- Name: FUNCTION st_split(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_split(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6558 (class 0 OID 0)
-- Dependencies: 1230
-- Name: FUNCTION st_square(size double precision, cell_i integer, cell_j integer, origin extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_square(size double precision, cell_i integer, cell_j integer, origin extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6559 (class 0 OID 0)
-- Dependencies: 1232
-- Name: FUNCTION st_squaregrid(size double precision, bounds extensions.geometry, OUT geom extensions.geometry, OUT i integer, OUT j integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_squaregrid(size double precision, bounds extensions.geometry, OUT geom extensions.geometry, OUT i integer, OUT j integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6560 (class 0 OID 0)
-- Dependencies: 1180
-- Name: FUNCTION st_srid(geog extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_srid(geog extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6561 (class 0 OID 0)
-- Dependencies: 788
-- Name: FUNCTION st_srid(geom extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_srid(geom extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6562 (class 0 OID 0)
-- Dependencies: 1019
-- Name: FUNCTION st_startpoint(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_startpoint(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6563 (class 0 OID 0)
-- Dependencies: 873
-- Name: FUNCTION st_subdivide(geom extensions.geometry, maxvertices integer, gridsize double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_subdivide(geom extensions.geometry, maxvertices integer, gridsize double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6564 (class 0 OID 0)
-- Dependencies: 1178
-- Name: FUNCTION st_summary(extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_summary(extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6565 (class 0 OID 0)
-- Dependencies: 664
-- Name: FUNCTION st_summary(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_summary(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6566 (class 0 OID 0)
-- Dependencies: 1084
-- Name: FUNCTION st_swapordinates(geom extensions.geometry, ords cstring); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_swapordinates(geom extensions.geometry, ords cstring) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6567 (class 0 OID 0)
-- Dependencies: 866
-- Name: FUNCTION st_symdifference(geom1 extensions.geometry, geom2 extensions.geometry, gridsize double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_symdifference(geom1 extensions.geometry, geom2 extensions.geometry, gridsize double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6568 (class 0 OID 0)
-- Dependencies: 867
-- Name: FUNCTION st_symmetricdifference(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_symmetricdifference(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6569 (class 0 OID 0)
-- Dependencies: 742
-- Name: FUNCTION st_tileenvelope(zoom integer, x integer, y integer, bounds extensions.geometry, margin double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_tileenvelope(zoom integer, x integer, y integer, bounds extensions.geometry, margin double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6570 (class 0 OID 0)
-- Dependencies: 933
-- Name: FUNCTION st_touches(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_touches(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6571 (class 0 OID 0)
-- Dependencies: 790
-- Name: FUNCTION st_transform(extensions.geometry, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_transform(extensions.geometry, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6572 (class 0 OID 0)
-- Dependencies: 791
-- Name: FUNCTION st_transform(geom extensions.geometry, to_proj text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_transform(geom extensions.geometry, to_proj text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6573 (class 0 OID 0)
-- Dependencies: 793
-- Name: FUNCTION st_transform(geom extensions.geometry, from_proj text, to_srid integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_transform(geom extensions.geometry, from_proj text, to_srid integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6574 (class 0 OID 0)
-- Dependencies: 792
-- Name: FUNCTION st_transform(geom extensions.geometry, from_proj text, to_proj text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_transform(geom extensions.geometry, from_proj text, to_proj text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6575 (class 0 OID 0)
-- Dependencies: 761
-- Name: FUNCTION st_translate(extensions.geometry, double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_translate(extensions.geometry, double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6576 (class 0 OID 0)
-- Dependencies: 760
-- Name: FUNCTION st_translate(extensions.geometry, double precision, double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_translate(extensions.geometry, double precision, double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6577 (class 0 OID 0)
-- Dependencies: 766
-- Name: FUNCTION st_transscale(extensions.geometry, double precision, double precision, double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_transscale(extensions.geometry, double precision, double precision, double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6578 (class 0 OID 0)
-- Dependencies: 884
-- Name: FUNCTION st_triangulatepolygon(g1 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_triangulatepolygon(g1 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6579 (class 0 OID 0)
-- Dependencies: 870
-- Name: FUNCTION st_unaryunion(extensions.geometry, gridsize double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_unaryunion(extensions.geometry, gridsize double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6580 (class 0 OID 0)
-- Dependencies: 907
-- Name: FUNCTION st_union(extensions.geometry[]); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_union(extensions.geometry[]) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6581 (class 0 OID 0)
-- Dependencies: 868
-- Name: FUNCTION st_union(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_union(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6582 (class 0 OID 0)
-- Dependencies: 869
-- Name: FUNCTION st_union(geom1 extensions.geometry, geom2 extensions.geometry, gridsize double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_union(geom1 extensions.geometry, geom2 extensions.geometry, gridsize double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6583 (class 0 OID 0)
-- Dependencies: 887
-- Name: FUNCTION st_voronoilines(g1 extensions.geometry, tolerance double precision, extend_to extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_voronoilines(g1 extensions.geometry, tolerance double precision, extend_to extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6584 (class 0 OID 0)
-- Dependencies: 886
-- Name: FUNCTION st_voronoipolygons(g1 extensions.geometry, tolerance double precision, extend_to extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_voronoipolygons(g1 extensions.geometry, tolerance double precision, extend_to extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6585 (class 0 OID 0)
-- Dependencies: 938
-- Name: FUNCTION st_within(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_within(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6586 (class 0 OID 0)
-- Dependencies: 1224
-- Name: FUNCTION st_wkbtosql(wkb bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_wkbtosql(wkb bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6587 (class 0 OID 0)
-- Dependencies: 1031
-- Name: FUNCTION st_wkttosql(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_wkttosql(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6588 (class 0 OID 0)
-- Dependencies: 643
-- Name: FUNCTION st_wrapx(geom extensions.geometry, wrap double precision, move double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_wrapx(geom extensions.geometry, wrap double precision, move double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6589 (class 0 OID 0)
-- Dependencies: 577
-- Name: FUNCTION st_x(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_x(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6590 (class 0 OID 0)
-- Dependencies: 647
-- Name: FUNCTION st_xmax(extensions.box3d); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_xmax(extensions.box3d) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6591 (class 0 OID 0)
-- Dependencies: 644
-- Name: FUNCTION st_xmin(extensions.box3d); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_xmin(extensions.box3d) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6592 (class 0 OID 0)
-- Dependencies: 578
-- Name: FUNCTION st_y(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_y(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6593 (class 0 OID 0)
-- Dependencies: 648
-- Name: FUNCTION st_ymax(extensions.box3d); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_ymax(extensions.box3d) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6594 (class 0 OID 0)
-- Dependencies: 645
-- Name: FUNCTION st_ymin(extensions.box3d); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_ymin(extensions.box3d) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6595 (class 0 OID 0)
-- Dependencies: 579
-- Name: FUNCTION st_z(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_z(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6596 (class 0 OID 0)
-- Dependencies: 649
-- Name: FUNCTION st_zmax(extensions.box3d); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_zmax(extensions.box3d) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6597 (class 0 OID 0)
-- Dependencies: 712
-- Name: FUNCTION st_zmflag(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_zmflag(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6598 (class 0 OID 0)
-- Dependencies: 646
-- Name: FUNCTION st_zmin(extensions.box3d); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_zmin(extensions.box3d) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6599 (class 0 OID 0)
-- Dependencies: 1088
-- Name: FUNCTION unlockrows(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.unlockrows(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6600 (class 0 OID 0)
-- Dependencies: 784
-- Name: FUNCTION updategeometrysrid(character varying, character varying, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.updategeometrysrid(character varying, character varying, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6601 (class 0 OID 0)
-- Dependencies: 783
-- Name: FUNCTION updategeometrysrid(character varying, character varying, character varying, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.updategeometrysrid(character varying, character varying, character varying, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6602 (class 0 OID 0)
-- Dependencies: 782
-- Name: FUNCTION updategeometrysrid(catalogn_name character varying, schema_name character varying, table_name character varying, column_name character varying, new_srid_in integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.updategeometrysrid(catalogn_name character varying, schema_name character varying, table_name character varying, column_name character varying, new_srid_in integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6603 (class 0 OID 0)
-- Dependencies: 456
-- Name: FUNCTION uuid_generate_v1(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v1() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1() TO dashboard_user;


--
-- TOC entry 6604 (class 0 OID 0)
-- Dependencies: 457
-- Name: FUNCTION uuid_generate_v1mc(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v1mc() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1mc() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1mc() TO dashboard_user;


--
-- TOC entry 6605 (class 0 OID 0)
-- Dependencies: 458
-- Name: FUNCTION uuid_generate_v3(namespace uuid, name text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) TO dashboard_user;


--
-- TOC entry 6606 (class 0 OID 0)
-- Dependencies: 459
-- Name: FUNCTION uuid_generate_v4(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v4() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v4() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v4() TO dashboard_user;


--
-- TOC entry 6607 (class 0 OID 0)
-- Dependencies: 460
-- Name: FUNCTION uuid_generate_v5(namespace uuid, name text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) TO dashboard_user;


--
-- TOC entry 6608 (class 0 OID 0)
-- Dependencies: 451
-- Name: FUNCTION uuid_nil(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_nil() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_nil() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_nil() TO dashboard_user;


--
-- TOC entry 6609 (class 0 OID 0)
-- Dependencies: 452
-- Name: FUNCTION uuid_ns_dns(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_ns_dns() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_dns() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_dns() TO dashboard_user;


--
-- TOC entry 6610 (class 0 OID 0)
-- Dependencies: 454
-- Name: FUNCTION uuid_ns_oid(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_ns_oid() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_oid() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_oid() TO dashboard_user;


--
-- TOC entry 6611 (class 0 OID 0)
-- Dependencies: 453
-- Name: FUNCTION uuid_ns_url(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_ns_url() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_url() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_url() TO dashboard_user;


--
-- TOC entry 6612 (class 0 OID 0)
-- Dependencies: 455
-- Name: FUNCTION uuid_ns_x500(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_ns_x500() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_x500() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_x500() TO dashboard_user;


--
-- TOC entry 6613 (class 0 OID 0)
-- Dependencies: 517
-- Name: FUNCTION graphql("operationName" text, query text, variables jsonb, extensions jsonb); Type: ACL; Schema: graphql_public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO postgres;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO anon;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO authenticated;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO service_role;


--
-- TOC entry 6614 (class 0 OID 0)
-- Dependencies: 435
-- Name: FUNCTION pg_reload_conf(); Type: ACL; Schema: pg_catalog; Owner: supabase_admin
--

GRANT ALL ON FUNCTION pg_catalog.pg_reload_conf() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6615 (class 0 OID 0)
-- Dependencies: 447
-- Name: FUNCTION get_auth(p_usename text); Type: ACL; Schema: pgbouncer; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION pgbouncer.get_auth(p_usename text) FROM PUBLIC;
GRANT ALL ON FUNCTION pgbouncer.get_auth(p_usename text) TO pgbouncer;


--
-- TOC entry 6616 (class 0 OID 0)
-- Dependencies: 434
-- Name: TABLE gift_codes; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.gift_codes TO anon;
GRANT ALL ON TABLE public.gift_codes TO authenticated;
GRANT ALL ON TABLE public.gift_codes TO service_role;


--
-- TOC entry 6617 (class 0 OID 0)
-- Dependencies: 1340
-- Name: FUNCTION admin_create_gift_code(p_amount_iqd bigint, p_code text, p_memo text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.admin_create_gift_code(p_amount_iqd bigint, p_code text, p_memo text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.admin_create_gift_code(p_amount_iqd bigint, p_code text, p_memo text) TO anon;
GRANT ALL ON FUNCTION public.admin_create_gift_code(p_amount_iqd bigint, p_code text, p_memo text) TO authenticated;
GRANT ALL ON FUNCTION public.admin_create_gift_code(p_amount_iqd bigint, p_code text, p_memo text) TO service_role;


--
-- TOC entry 6618 (class 0 OID 0)
-- Dependencies: 1339
-- Name: FUNCTION admin_record_ride_refund(p_ride_id uuid, p_refund_amount_iqd integer, p_reason text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.admin_record_ride_refund(p_ride_id uuid, p_refund_amount_iqd integer, p_reason text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.admin_record_ride_refund(p_ride_id uuid, p_refund_amount_iqd integer, p_reason text) TO anon;
GRANT ALL ON FUNCTION public.admin_record_ride_refund(p_ride_id uuid, p_refund_amount_iqd integer, p_reason text) TO authenticated;
GRANT ALL ON FUNCTION public.admin_record_ride_refund(p_ride_id uuid, p_refund_amount_iqd integer, p_reason text) TO service_role;


--
-- TOC entry 6619 (class 0 OID 0)
-- Dependencies: 1296
-- Name: FUNCTION admin_update_ride_incident(p_incident_id uuid, p_status public.incident_status, p_assigned_to uuid, p_resolution_note text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.admin_update_ride_incident(p_incident_id uuid, p_status public.incident_status, p_assigned_to uuid, p_resolution_note text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.admin_update_ride_incident(p_incident_id uuid, p_status public.incident_status, p_assigned_to uuid, p_resolution_note text) TO anon;
GRANT ALL ON FUNCTION public.admin_update_ride_incident(p_incident_id uuid, p_status public.incident_status, p_assigned_to uuid, p_resolution_note text) TO authenticated;
GRANT ALL ON FUNCTION public.admin_update_ride_incident(p_incident_id uuid, p_status public.incident_status, p_assigned_to uuid, p_resolution_note text) TO service_role;


--
-- TOC entry 6620 (class 0 OID 0)
-- Dependencies: 1308
-- Name: FUNCTION admin_wallet_integrity_snapshot(p_limit integer, p_hold_age_seconds integer, p_topup_age_seconds integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.admin_wallet_integrity_snapshot(p_limit integer, p_hold_age_seconds integer, p_topup_age_seconds integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.admin_wallet_integrity_snapshot(p_limit integer, p_hold_age_seconds integer, p_topup_age_seconds integer) TO anon;
GRANT ALL ON FUNCTION public.admin_wallet_integrity_snapshot(p_limit integer, p_hold_age_seconds integer, p_topup_age_seconds integer) TO authenticated;
GRANT ALL ON FUNCTION public.admin_wallet_integrity_snapshot(p_limit integer, p_hold_age_seconds integer, p_topup_age_seconds integer) TO service_role;


--
-- TOC entry 6621 (class 0 OID 0)
-- Dependencies: 1336
-- Name: FUNCTION admin_withdraw_approve(p_request_id uuid, p_note text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.admin_withdraw_approve(p_request_id uuid, p_note text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.admin_withdraw_approve(p_request_id uuid, p_note text) TO anon;
GRANT ALL ON FUNCTION public.admin_withdraw_approve(p_request_id uuid, p_note text) TO authenticated;
GRANT ALL ON FUNCTION public.admin_withdraw_approve(p_request_id uuid, p_note text) TO service_role;


--
-- TOC entry 6622 (class 0 OID 0)
-- Dependencies: 1338
-- Name: FUNCTION admin_withdraw_mark_paid(p_request_id uuid, p_payout_reference text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.admin_withdraw_mark_paid(p_request_id uuid, p_payout_reference text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.admin_withdraw_mark_paid(p_request_id uuid, p_payout_reference text) TO anon;
GRANT ALL ON FUNCTION public.admin_withdraw_mark_paid(p_request_id uuid, p_payout_reference text) TO authenticated;
GRANT ALL ON FUNCTION public.admin_withdraw_mark_paid(p_request_id uuid, p_payout_reference text) TO service_role;


--
-- TOC entry 6623 (class 0 OID 0)
-- Dependencies: 1337
-- Name: FUNCTION admin_withdraw_reject(p_request_id uuid, p_note text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.admin_withdraw_reject(p_request_id uuid, p_note text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.admin_withdraw_reject(p_request_id uuid, p_note text) TO anon;
GRANT ALL ON FUNCTION public.admin_withdraw_reject(p_request_id uuid, p_note text) TO authenticated;
GRANT ALL ON FUNCTION public.admin_withdraw_reject(p_request_id uuid, p_note text) TO service_role;


--
-- TOC entry 6624 (class 0 OID 0)
-- Dependencies: 1293
-- Name: FUNCTION apply_rating_aggregate(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.apply_rating_aggregate() TO anon;
GRANT ALL ON FUNCTION public.apply_rating_aggregate() TO authenticated;
GRANT ALL ON FUNCTION public.apply_rating_aggregate() TO service_role;


--
-- TOC entry 6625 (class 0 OID 0)
-- Dependencies: 1291
-- Name: FUNCTION create_receipt_from_payment(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.create_receipt_from_payment() TO anon;
GRANT ALL ON FUNCTION public.create_receipt_from_payment() TO authenticated;
GRANT ALL ON FUNCTION public.create_receipt_from_payment() TO service_role;


--
-- TOC entry 6626 (class 0 OID 0)
-- Dependencies: 1294
-- Name: FUNCTION create_ride_incident(p_ride_id uuid, p_category text, p_description text, p_severity public.incident_severity); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.create_ride_incident(p_ride_id uuid, p_category text, p_description text, p_severity public.incident_severity) FROM PUBLIC;
GRANT ALL ON FUNCTION public.create_ride_incident(p_ride_id uuid, p_category text, p_description text, p_severity public.incident_severity) TO anon;
GRANT ALL ON FUNCTION public.create_ride_incident(p_ride_id uuid, p_category text, p_description text, p_severity public.incident_severity) TO authenticated;
GRANT ALL ON FUNCTION public.create_ride_incident(p_ride_id uuid, p_category text, p_description text, p_severity public.incident_severity) TO service_role;


--
-- TOC entry 6627 (class 0 OID 0)
-- Dependencies: 1303
-- Name: FUNCTION dispatch_accept_ride(p_request_id uuid, p_driver_id uuid); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.dispatch_accept_ride(p_request_id uuid, p_driver_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION public.dispatch_accept_ride(p_request_id uuid, p_driver_id uuid) TO anon;
GRANT ALL ON FUNCTION public.dispatch_accept_ride(p_request_id uuid, p_driver_id uuid) TO service_role;


--
-- TOC entry 6628 (class 0 OID 0)
-- Dependencies: 1306
-- Name: FUNCTION dispatch_match_ride(p_request_id uuid, p_rider_id uuid, p_radius_m numeric, p_limit_n integer, p_match_ttl_seconds integer, p_stale_after_seconds integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.dispatch_match_ride(p_request_id uuid, p_rider_id uuid, p_radius_m numeric, p_limit_n integer, p_match_ttl_seconds integer, p_stale_after_seconds integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.dispatch_match_ride(p_request_id uuid, p_rider_id uuid, p_radius_m numeric, p_limit_n integer, p_match_ttl_seconds integer, p_stale_after_seconds integer) TO anon;
GRANT ALL ON FUNCTION public.dispatch_match_ride(p_request_id uuid, p_rider_id uuid, p_radius_m numeric, p_limit_n integer, p_match_ttl_seconds integer, p_stale_after_seconds integer) TO service_role;


--
-- TOC entry 6629 (class 0 OID 0)
-- Dependencies: 1298
-- Name: FUNCTION ensure_wallet_account(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.ensure_wallet_account() TO anon;
GRANT ALL ON FUNCTION public.ensure_wallet_account() TO authenticated;
GRANT ALL ON FUNCTION public.ensure_wallet_account() TO service_role;


--
-- TOC entry 6630 (class 0 OID 0)
-- Dependencies: 1286
-- Name: FUNCTION estimate_ride_quote_iqd(_pickup extensions.geography, _dropoff extensions.geography); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.estimate_ride_quote_iqd(_pickup extensions.geography, _dropoff extensions.geography) TO anon;
GRANT ALL ON FUNCTION public.estimate_ride_quote_iqd(_pickup extensions.geography, _dropoff extensions.geography) TO authenticated;
GRANT ALL ON FUNCTION public.estimate_ride_quote_iqd(_pickup extensions.geography, _dropoff extensions.geography) TO service_role;


--
-- TOC entry 6631 (class 0 OID 0)
-- Dependencies: 1284
-- Name: FUNCTION handle_new_user(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.handle_new_user() TO anon;
GRANT ALL ON FUNCTION public.handle_new_user() TO authenticated;
GRANT ALL ON FUNCTION public.handle_new_user() TO service_role;


--
-- TOC entry 6632 (class 0 OID 0)
-- Dependencies: 1295
-- Name: FUNCTION is_admin(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.is_admin() FROM PUBLIC;
GRANT ALL ON FUNCTION public.is_admin() TO anon;
GRANT ALL ON FUNCTION public.is_admin() TO authenticated;
GRANT ALL ON FUNCTION public.is_admin() TO service_role;


--
-- TOC entry 6633 (class 0 OID 0)
-- Dependencies: 1330
-- Name: FUNCTION notify_user(p_user_id uuid, p_kind text, p_title text, p_body text, p_data jsonb); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.notify_user(p_user_id uuid, p_kind text, p_title text, p_body text, p_data jsonb) FROM PUBLIC;
GRANT ALL ON FUNCTION public.notify_user(p_user_id uuid, p_kind text, p_title text, p_body text, p_data jsonb) TO anon;
GRANT ALL ON FUNCTION public.notify_user(p_user_id uuid, p_kind text, p_title text, p_body text, p_data jsonb) TO authenticated;
GRANT ALL ON FUNCTION public.notify_user(p_user_id uuid, p_kind text, p_title text, p_body text, p_data jsonb) TO service_role;


--
-- TOC entry 6634 (class 0 OID 0)
-- Dependencies: 1329
-- Name: FUNCTION profile_kyc_init(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.profile_kyc_init() FROM PUBLIC;
GRANT ALL ON FUNCTION public.profile_kyc_init() TO anon;
GRANT ALL ON FUNCTION public.profile_kyc_init() TO authenticated;
GRANT ALL ON FUNCTION public.profile_kyc_init() TO service_role;


--
-- TOC entry 6635 (class 0 OID 0)
-- Dependencies: 1290
-- Name: FUNCTION rate_limit_consume(p_key text, p_window_seconds integer, p_limit integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.rate_limit_consume(p_key text, p_window_seconds integer, p_limit integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.rate_limit_consume(p_key text, p_window_seconds integer, p_limit integer) TO anon;
GRANT ALL ON FUNCTION public.rate_limit_consume(p_key text, p_window_seconds integer, p_limit integer) TO authenticated;
GRANT ALL ON FUNCTION public.rate_limit_consume(p_key text, p_window_seconds integer, p_limit integer) TO service_role;


--
-- TOC entry 6636 (class 0 OID 0)
-- Dependencies: 1341
-- Name: FUNCTION redeem_gift_code(p_code text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.redeem_gift_code(p_code text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.redeem_gift_code(p_code text) TO anon;
GRANT ALL ON FUNCTION public.redeem_gift_code(p_code text) TO authenticated;
GRANT ALL ON FUNCTION public.redeem_gift_code(p_code text) TO service_role;


--
-- TOC entry 6637 (class 0 OID 0)
-- Dependencies: 1288
-- Name: FUNCTION ride_requests_clear_match_fields(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.ride_requests_clear_match_fields() TO anon;
GRANT ALL ON FUNCTION public.ride_requests_clear_match_fields() TO authenticated;
GRANT ALL ON FUNCTION public.ride_requests_clear_match_fields() TO service_role;


--
-- TOC entry 6638 (class 0 OID 0)
-- Dependencies: 1289
-- Name: FUNCTION ride_requests_release_driver_on_unmatch(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.ride_requests_release_driver_on_unmatch() TO anon;
GRANT ALL ON FUNCTION public.ride_requests_release_driver_on_unmatch() TO authenticated;
GRANT ALL ON FUNCTION public.ride_requests_release_driver_on_unmatch() TO service_role;


--
-- TOC entry 6639 (class 0 OID 0)
-- Dependencies: 1287
-- Name: FUNCTION ride_requests_set_quote(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.ride_requests_set_quote() TO anon;
GRANT ALL ON FUNCTION public.ride_requests_set_quote() TO authenticated;
GRANT ALL ON FUNCTION public.ride_requests_set_quote() TO service_role;


--
-- TOC entry 6640 (class 0 OID 0)
-- Dependencies: 1285
-- Name: FUNCTION ride_requests_set_status_timestamps(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.ride_requests_set_status_timestamps() TO anon;
GRANT ALL ON FUNCTION public.ride_requests_set_status_timestamps() TO authenticated;
GRANT ALL ON FUNCTION public.ride_requests_set_status_timestamps() TO service_role;


--
-- TOC entry 6641 (class 0 OID 0)
-- Dependencies: 1283
-- Name: FUNCTION set_updated_at(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.set_updated_at() TO anon;
GRANT ALL ON FUNCTION public.set_updated_at() TO authenticated;
GRANT ALL ON FUNCTION public.set_updated_at() TO service_role;


--
-- TOC entry 6642 (class 0 OID 0)
-- Dependencies: 1342
-- Name: FUNCTION st_dwithin(extensions.geography, extensions.geography, numeric); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_dwithin(extensions.geography, extensions.geography, numeric) TO anon;
GRANT ALL ON FUNCTION public.st_dwithin(extensions.geography, extensions.geography, numeric) TO authenticated;
GRANT ALL ON FUNCTION public.st_dwithin(extensions.geography, extensions.geography, numeric) TO service_role;


--
-- TOC entry 6643 (class 0 OID 0)
-- Dependencies: 1292
-- Name: FUNCTION submit_ride_rating(p_ride_id uuid, p_rating smallint, p_comment text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.submit_ride_rating(p_ride_id uuid, p_rating smallint, p_comment text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.submit_ride_rating(p_ride_id uuid, p_rating smallint, p_comment text) TO anon;
GRANT ALL ON FUNCTION public.submit_ride_rating(p_ride_id uuid, p_rating smallint, p_comment text) TO authenticated;
GRANT ALL ON FUNCTION public.submit_ride_rating(p_ride_id uuid, p_rating smallint, p_comment text) TO service_role;


--
-- TOC entry 6644 (class 0 OID 0)
-- Dependencies: 395
-- Name: TABLE rides; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.rides TO anon;
GRANT ALL ON TABLE public.rides TO authenticated;
GRANT ALL ON TABLE public.rides TO service_role;


--
-- TOC entry 6645 (class 0 OID 0)
-- Dependencies: 1304
-- Name: FUNCTION transition_ride_v2(p_ride_id uuid, p_to_status public.ride_status, p_actor_id uuid, p_actor_type public.ride_actor_type, p_expected_version integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.transition_ride_v2(p_ride_id uuid, p_to_status public.ride_status, p_actor_id uuid, p_actor_type public.ride_actor_type, p_expected_version integer) TO anon;
GRANT ALL ON FUNCTION public.transition_ride_v2(p_ride_id uuid, p_to_status public.ride_status, p_actor_id uuid, p_actor_type public.ride_actor_type, p_expected_version integer) TO service_role;


--
-- TOC entry 6646 (class 0 OID 0)
-- Dependencies: 1328
-- Name: FUNCTION try_get_vault_secret(p_name text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.try_get_vault_secret(p_name text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.try_get_vault_secret(p_name text) TO anon;
GRANT ALL ON FUNCTION public.try_get_vault_secret(p_name text) TO authenticated;
GRANT ALL ON FUNCTION public.try_get_vault_secret(p_name text) TO service_role;


--
-- TOC entry 6647 (class 0 OID 0)
-- Dependencies: 1297
-- Name: FUNCTION update_receipt_on_refund(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_receipt_on_refund() TO anon;
GRANT ALL ON FUNCTION public.update_receipt_on_refund() TO authenticated;
GRANT ALL ON FUNCTION public.update_receipt_on_refund() TO service_role;


--
-- TOC entry 6648 (class 0 OID 0)
-- Dependencies: 1332
-- Name: FUNCTION user_notifications_mark_all_read(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.user_notifications_mark_all_read() FROM PUBLIC;
GRANT ALL ON FUNCTION public.user_notifications_mark_all_read() TO anon;
GRANT ALL ON FUNCTION public.user_notifications_mark_all_read() TO authenticated;
GRANT ALL ON FUNCTION public.user_notifications_mark_all_read() TO service_role;


--
-- TOC entry 6649 (class 0 OID 0)
-- Dependencies: 1331
-- Name: FUNCTION user_notifications_mark_read(p_notification_id uuid); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.user_notifications_mark_read(p_notification_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION public.user_notifications_mark_read(p_notification_id uuid) TO anon;
GRANT ALL ON FUNCTION public.user_notifications_mark_read(p_notification_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.user_notifications_mark_read(p_notification_id uuid) TO service_role;


--
-- TOC entry 6650 (class 0 OID 0)
-- Dependencies: 1335
-- Name: FUNCTION wallet_cancel_withdraw(p_request_id uuid); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.wallet_cancel_withdraw(p_request_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION public.wallet_cancel_withdraw(p_request_id uuid) TO anon;
GRANT ALL ON FUNCTION public.wallet_cancel_withdraw(p_request_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.wallet_cancel_withdraw(p_request_id uuid) TO service_role;


--
-- TOC entry 6651 (class 0 OID 0)
-- Dependencies: 1307
-- Name: FUNCTION wallet_capture_ride_hold(p_ride_id uuid); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.wallet_capture_ride_hold(p_ride_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION public.wallet_capture_ride_hold(p_ride_id uuid) TO anon;
GRANT ALL ON FUNCTION public.wallet_capture_ride_hold(p_ride_id uuid) TO service_role;


--
-- TOC entry 6652 (class 0 OID 0)
-- Dependencies: 412
-- Name: TABLE topup_intents; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.topup_intents TO anon;
GRANT ALL ON TABLE public.topup_intents TO authenticated;
GRANT ALL ON TABLE public.topup_intents TO service_role;


--
-- TOC entry 6653 (class 0 OID 0)
-- Dependencies: 1300
-- Name: FUNCTION wallet_fail_topup(p_intent_id uuid, p_failure_reason text, p_provider_payload jsonb); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.wallet_fail_topup(p_intent_id uuid, p_failure_reason text, p_provider_payload jsonb) FROM PUBLIC;
GRANT ALL ON FUNCTION public.wallet_fail_topup(p_intent_id uuid, p_failure_reason text, p_provider_payload jsonb) TO anon;
GRANT ALL ON FUNCTION public.wallet_fail_topup(p_intent_id uuid, p_failure_reason text, p_provider_payload jsonb) TO authenticated;
GRANT ALL ON FUNCTION public.wallet_fail_topup(p_intent_id uuid, p_failure_reason text, p_provider_payload jsonb) TO service_role;


--
-- TOC entry 6654 (class 0 OID 0)
-- Dependencies: 1305
-- Name: FUNCTION wallet_finalize_topup(p_intent_id uuid, p_provider_tx_id text, p_provider_payload jsonb); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.wallet_finalize_topup(p_intent_id uuid, p_provider_tx_id text, p_provider_payload jsonb) FROM PUBLIC;
GRANT ALL ON FUNCTION public.wallet_finalize_topup(p_intent_id uuid, p_provider_tx_id text, p_provider_payload jsonb) TO anon;
GRANT ALL ON FUNCTION public.wallet_finalize_topup(p_intent_id uuid, p_provider_tx_id text, p_provider_payload jsonb) TO authenticated;
GRANT ALL ON FUNCTION public.wallet_finalize_topup(p_intent_id uuid, p_provider_tx_id text, p_provider_payload jsonb) TO service_role;


--
-- TOC entry 6655 (class 0 OID 0)
-- Dependencies: 406
-- Name: TABLE wallet_accounts; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.wallet_accounts TO anon;
GRANT ALL ON TABLE public.wallet_accounts TO authenticated;
GRANT ALL ON TABLE public.wallet_accounts TO service_role;


--
-- TOC entry 6656 (class 0 OID 0)
-- Dependencies: 1299
-- Name: FUNCTION wallet_get_my_account(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.wallet_get_my_account() FROM PUBLIC;
GRANT ALL ON FUNCTION public.wallet_get_my_account() TO anon;
GRANT ALL ON FUNCTION public.wallet_get_my_account() TO authenticated;
GRANT ALL ON FUNCTION public.wallet_get_my_account() TO service_role;


--
-- TOC entry 6657 (class 0 OID 0)
-- Dependencies: 1301
-- Name: FUNCTION wallet_hold_upsert_for_ride(p_user_id uuid, p_ride_id uuid, p_amount_iqd bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.wallet_hold_upsert_for_ride(p_user_id uuid, p_ride_id uuid, p_amount_iqd bigint) TO anon;
GRANT ALL ON FUNCTION public.wallet_hold_upsert_for_ride(p_user_id uuid, p_ride_id uuid, p_amount_iqd bigint) TO service_role;


--
-- TOC entry 6658 (class 0 OID 0)
-- Dependencies: 1302
-- Name: FUNCTION wallet_release_ride_hold(p_ride_id uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.wallet_release_ride_hold(p_ride_id uuid) TO anon;
GRANT ALL ON FUNCTION public.wallet_release_ride_hold(p_ride_id uuid) TO service_role;


--
-- TOC entry 6659 (class 0 OID 0)
-- Dependencies: 1334
-- Name: FUNCTION wallet_request_withdraw(p_amount_iqd bigint, p_payout_kind public.withdraw_payout_kind, p_destination jsonb, p_idempotency_key text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.wallet_request_withdraw(p_amount_iqd bigint, p_payout_kind public.withdraw_payout_kind, p_destination jsonb, p_idempotency_key text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.wallet_request_withdraw(p_amount_iqd bigint, p_payout_kind public.withdraw_payout_kind, p_destination jsonb, p_idempotency_key text) TO anon;
GRANT ALL ON FUNCTION public.wallet_request_withdraw(p_amount_iqd bigint, p_payout_kind public.withdraw_payout_kind, p_destination jsonb, p_idempotency_key text) TO authenticated;
GRANT ALL ON FUNCTION public.wallet_request_withdraw(p_amount_iqd bigint, p_payout_kind public.withdraw_payout_kind, p_destination jsonb, p_idempotency_key text) TO service_role;


--
-- TOC entry 6660 (class 0 OID 0)
-- Dependencies: 1333
-- Name: FUNCTION wallet_validate_withdraw_destination(p_payout_kind public.withdraw_payout_kind, p_destination jsonb); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.wallet_validate_withdraw_destination(p_payout_kind public.withdraw_payout_kind, p_destination jsonb) FROM PUBLIC;
GRANT ALL ON FUNCTION public.wallet_validate_withdraw_destination(p_payout_kind public.withdraw_payout_kind, p_destination jsonb) TO anon;
GRANT ALL ON FUNCTION public.wallet_validate_withdraw_destination(p_payout_kind public.withdraw_payout_kind, p_destination jsonb) TO authenticated;
GRANT ALL ON FUNCTION public.wallet_validate_withdraw_destination(p_payout_kind public.withdraw_payout_kind, p_destination jsonb) TO service_role;


--
-- TOC entry 6661 (class 0 OID 0)
-- Dependencies: 524
-- Name: FUNCTION apply_rls(wal jsonb, max_record_bytes integer); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO postgres;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO anon;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO authenticated;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO service_role;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO supabase_realtime_admin;


--
-- TOC entry 6662 (class 0 OID 0)
-- Dependencies: 530
-- Name: FUNCTION broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) TO postgres;
GRANT ALL ON FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) TO dashboard_user;


--
-- TOC entry 6663 (class 0 OID 0)
-- Dependencies: 526
-- Name: FUNCTION build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO postgres;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO anon;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO authenticated;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO service_role;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO supabase_realtime_admin;


--
-- TOC entry 6664 (class 0 OID 0)
-- Dependencies: 522
-- Name: FUNCTION "cast"(val text, type_ regtype); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO postgres;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO dashboard_user;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO anon;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO authenticated;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO service_role;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO supabase_realtime_admin;


--
-- TOC entry 6665 (class 0 OID 0)
-- Dependencies: 521
-- Name: FUNCTION check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO postgres;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO anon;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO authenticated;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO service_role;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO supabase_realtime_admin;


--
-- TOC entry 6666 (class 0 OID 0)
-- Dependencies: 525
-- Name: FUNCTION is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO postgres;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO anon;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO authenticated;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO service_role;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO supabase_realtime_admin;


--
-- TOC entry 6667 (class 0 OID 0)
-- Dependencies: 527
-- Name: FUNCTION list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO postgres;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO anon;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO authenticated;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO service_role;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO supabase_realtime_admin;


--
-- TOC entry 6668 (class 0 OID 0)
-- Dependencies: 520
-- Name: FUNCTION quote_wal2json(entity regclass); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO postgres;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO anon;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO authenticated;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO service_role;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO supabase_realtime_admin;


--
-- TOC entry 6669 (class 0 OID 0)
-- Dependencies: 529
-- Name: FUNCTION send(payload jsonb, event text, topic text, private boolean); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) TO postgres;
GRANT ALL ON FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) TO dashboard_user;


--
-- TOC entry 6670 (class 0 OID 0)
-- Dependencies: 519
-- Name: FUNCTION subscription_check_filters(); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO postgres;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO dashboard_user;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO anon;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO authenticated;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO service_role;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO supabase_realtime_admin;


--
-- TOC entry 6671 (class 0 OID 0)
-- Dependencies: 523
-- Name: FUNCTION to_regrole(role_name text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO postgres;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO anon;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO authenticated;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO service_role;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO supabase_realtime_admin;


--
-- TOC entry 6672 (class 0 OID 0)
-- Dependencies: 528
-- Name: FUNCTION topic(); Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON FUNCTION realtime.topic() TO postgres;
GRANT ALL ON FUNCTION realtime.topic() TO dashboard_user;


--
-- TOC entry 6673 (class 0 OID 0)
-- Dependencies: 507
-- Name: FUNCTION _crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea); Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT ALL ON FUNCTION vault._crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION vault._crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea) TO service_role;


--
-- TOC entry 6674 (class 0 OID 0)
-- Dependencies: 509
-- Name: FUNCTION create_secret(new_secret text, new_name text, new_description text, new_key_id uuid); Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT ALL ON FUNCTION vault.create_secret(new_secret text, new_name text, new_description text, new_key_id uuid) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION vault.create_secret(new_secret text, new_name text, new_description text, new_key_id uuid) TO service_role;


--
-- TOC entry 6675 (class 0 OID 0)
-- Dependencies: 510
-- Name: FUNCTION update_secret(secret_id uuid, new_secret text, new_name text, new_description text, new_key_id uuid); Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT ALL ON FUNCTION vault.update_secret(secret_id uuid, new_secret text, new_name text, new_description text, new_key_id uuid) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION vault.update_secret(secret_id uuid, new_secret text, new_name text, new_description text, new_key_id uuid) TO service_role;


--
-- TOC entry 6676 (class 0 OID 0)
-- Dependencies: 2299
-- Name: FUNCTION st_3dextent(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_3dextent(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6677 (class 0 OID 0)
-- Dependencies: 2315
-- Name: FUNCTION st_asflatgeobuf(anyelement); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asflatgeobuf(anyelement) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6678 (class 0 OID 0)
-- Dependencies: 2316
-- Name: FUNCTION st_asflatgeobuf(anyelement, boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asflatgeobuf(anyelement, boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6679 (class 0 OID 0)
-- Dependencies: 2317
-- Name: FUNCTION st_asflatgeobuf(anyelement, boolean, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asflatgeobuf(anyelement, boolean, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6680 (class 0 OID 0)
-- Dependencies: 2313
-- Name: FUNCTION st_asgeobuf(anyelement); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asgeobuf(anyelement) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6681 (class 0 OID 0)
-- Dependencies: 2314
-- Name: FUNCTION st_asgeobuf(anyelement, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asgeobuf(anyelement, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6682 (class 0 OID 0)
-- Dependencies: 2308
-- Name: FUNCTION st_asmvt(anyelement); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asmvt(anyelement) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6683 (class 0 OID 0)
-- Dependencies: 2309
-- Name: FUNCTION st_asmvt(anyelement, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asmvt(anyelement, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6684 (class 0 OID 0)
-- Dependencies: 2310
-- Name: FUNCTION st_asmvt(anyelement, text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asmvt(anyelement, text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6685 (class 0 OID 0)
-- Dependencies: 2311
-- Name: FUNCTION st_asmvt(anyelement, text, integer, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asmvt(anyelement, text, integer, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6686 (class 0 OID 0)
-- Dependencies: 2312
-- Name: FUNCTION st_asmvt(anyelement, text, integer, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asmvt(anyelement, text, integer, text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6687 (class 0 OID 0)
-- Dependencies: 2304
-- Name: FUNCTION st_clusterintersecting(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_clusterintersecting(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6688 (class 0 OID 0)
-- Dependencies: 2305
-- Name: FUNCTION st_clusterwithin(extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_clusterwithin(extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6689 (class 0 OID 0)
-- Dependencies: 2303
-- Name: FUNCTION st_collect(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_collect(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6690 (class 0 OID 0)
-- Dependencies: 2298
-- Name: FUNCTION st_extent(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_extent(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6691 (class 0 OID 0)
-- Dependencies: 2307
-- Name: FUNCTION st_makeline(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_makeline(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6692 (class 0 OID 0)
-- Dependencies: 2300
-- Name: FUNCTION st_memcollect(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_memcollect(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6693 (class 0 OID 0)
-- Dependencies: 2297
-- Name: FUNCTION st_memunion(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_memunion(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6694 (class 0 OID 0)
-- Dependencies: 2306
-- Name: FUNCTION st_polygonize(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_polygonize(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6695 (class 0 OID 0)
-- Dependencies: 2301
-- Name: FUNCTION st_union(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_union(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6696 (class 0 OID 0)
-- Dependencies: 2302
-- Name: FUNCTION st_union(extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_union(extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6698 (class 0 OID 0)
-- Dependencies: 349
-- Name: TABLE audit_log_entries; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.audit_log_entries TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.audit_log_entries TO postgres;
GRANT SELECT ON TABLE auth.audit_log_entries TO postgres WITH GRANT OPTION;


--
-- TOC entry 6700 (class 0 OID 0)
-- Dependencies: 363
-- Name: TABLE flow_state; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.flow_state TO postgres;
GRANT SELECT ON TABLE auth.flow_state TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.flow_state TO dashboard_user;


--
-- TOC entry 6703 (class 0 OID 0)
-- Dependencies: 354
-- Name: TABLE identities; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.identities TO postgres;
GRANT SELECT ON TABLE auth.identities TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.identities TO dashboard_user;


--
-- TOC entry 6705 (class 0 OID 0)
-- Dependencies: 348
-- Name: TABLE instances; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.instances TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.instances TO postgres;
GRANT SELECT ON TABLE auth.instances TO postgres WITH GRANT OPTION;


--
-- TOC entry 6707 (class 0 OID 0)
-- Dependencies: 358
-- Name: TABLE mfa_amr_claims; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.mfa_amr_claims TO postgres;
GRANT SELECT ON TABLE auth.mfa_amr_claims TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_amr_claims TO dashboard_user;


--
-- TOC entry 6709 (class 0 OID 0)
-- Dependencies: 357
-- Name: TABLE mfa_challenges; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.mfa_challenges TO postgres;
GRANT SELECT ON TABLE auth.mfa_challenges TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_challenges TO dashboard_user;


--
-- TOC entry 6712 (class 0 OID 0)
-- Dependencies: 356
-- Name: TABLE mfa_factors; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.mfa_factors TO postgres;
GRANT SELECT ON TABLE auth.mfa_factors TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_factors TO dashboard_user;


--
-- TOC entry 6713 (class 0 OID 0)
-- Dependencies: 366
-- Name: TABLE oauth_authorizations; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.oauth_authorizations TO postgres;
GRANT ALL ON TABLE auth.oauth_authorizations TO dashboard_user;


--
-- TOC entry 6715 (class 0 OID 0)
-- Dependencies: 368
-- Name: TABLE oauth_client_states; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.oauth_client_states TO postgres;
GRANT ALL ON TABLE auth.oauth_client_states TO dashboard_user;


--
-- TOC entry 6716 (class 0 OID 0)
-- Dependencies: 365
-- Name: TABLE oauth_clients; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.oauth_clients TO postgres;
GRANT ALL ON TABLE auth.oauth_clients TO dashboard_user;


--
-- TOC entry 6717 (class 0 OID 0)
-- Dependencies: 367
-- Name: TABLE oauth_consents; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.oauth_consents TO postgres;
GRANT ALL ON TABLE auth.oauth_consents TO dashboard_user;


--
-- TOC entry 6718 (class 0 OID 0)
-- Dependencies: 364
-- Name: TABLE one_time_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.one_time_tokens TO postgres;
GRANT SELECT ON TABLE auth.one_time_tokens TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.one_time_tokens TO dashboard_user;


--
-- TOC entry 6720 (class 0 OID 0)
-- Dependencies: 347
-- Name: TABLE refresh_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.refresh_tokens TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.refresh_tokens TO postgres;
GRANT SELECT ON TABLE auth.refresh_tokens TO postgres WITH GRANT OPTION;


--
-- TOC entry 6722 (class 0 OID 0)
-- Dependencies: 346
-- Name: SEQUENCE refresh_tokens_id_seq; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO dashboard_user;
GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO postgres;


--
-- TOC entry 6724 (class 0 OID 0)
-- Dependencies: 361
-- Name: TABLE saml_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.saml_providers TO postgres;
GRANT SELECT ON TABLE auth.saml_providers TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.saml_providers TO dashboard_user;


--
-- TOC entry 6726 (class 0 OID 0)
-- Dependencies: 362
-- Name: TABLE saml_relay_states; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.saml_relay_states TO postgres;
GRANT SELECT ON TABLE auth.saml_relay_states TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.saml_relay_states TO dashboard_user;


--
-- TOC entry 6728 (class 0 OID 0)
-- Dependencies: 350
-- Name: TABLE schema_migrations; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT SELECT ON TABLE auth.schema_migrations TO postgres WITH GRANT OPTION;


--
-- TOC entry 6733 (class 0 OID 0)
-- Dependencies: 355
-- Name: TABLE sessions; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.sessions TO postgres;
GRANT SELECT ON TABLE auth.sessions TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sessions TO dashboard_user;


--
-- TOC entry 6735 (class 0 OID 0)
-- Dependencies: 360
-- Name: TABLE sso_domains; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.sso_domains TO postgres;
GRANT SELECT ON TABLE auth.sso_domains TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sso_domains TO dashboard_user;


--
-- TOC entry 6738 (class 0 OID 0)
-- Dependencies: 359
-- Name: TABLE sso_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.sso_providers TO postgres;
GRANT SELECT ON TABLE auth.sso_providers TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sso_providers TO dashboard_user;


--
-- TOC entry 6741 (class 0 OID 0)
-- Dependencies: 345
-- Name: TABLE users; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.users TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.users TO postgres;
GRANT SELECT ON TABLE auth.users TO postgres WITH GRANT OPTION;


--
-- TOC entry 6742 (class 0 OID 0)
-- Dependencies: 416
-- Name: TABLE job; Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT SELECT ON TABLE cron.job TO postgres WITH GRANT OPTION;


--
-- TOC entry 6743 (class 0 OID 0)
-- Dependencies: 418
-- Name: TABLE job_run_details; Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON TABLE cron.job_run_details TO postgres WITH GRANT OPTION;


--
-- TOC entry 6744 (class 0 OID 0)
-- Dependencies: 344
-- Name: TABLE pg_stat_statements; Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON TABLE extensions.pg_stat_statements FROM postgres;
GRANT ALL ON TABLE extensions.pg_stat_statements TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE extensions.pg_stat_statements TO dashboard_user;


--
-- TOC entry 6745 (class 0 OID 0)
-- Dependencies: 343
-- Name: TABLE pg_stat_statements_info; Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON TABLE extensions.pg_stat_statements_info FROM postgres;
GRANT ALL ON TABLE extensions.pg_stat_statements_info TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE extensions.pg_stat_statements_info TO dashboard_user;


--
-- TOC entry 6746 (class 0 OID 0)
-- Dependencies: 402
-- Name: TABLE api_rate_limits; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.api_rate_limits TO anon;
GRANT ALL ON TABLE public.api_rate_limits TO authenticated;
GRANT ALL ON TABLE public.api_rate_limits TO service_role;


--
-- TOC entry 6747 (class 0 OID 0)
-- Dependencies: 401
-- Name: TABLE app_events; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.app_events TO anon;
GRANT ALL ON TABLE public.app_events TO authenticated;
GRANT ALL ON TABLE public.app_events TO service_role;


--
-- TOC entry 6748 (class 0 OID 0)
-- Dependencies: 393
-- Name: TABLE driver_locations; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.driver_locations TO anon;
GRANT ALL ON TABLE public.driver_locations TO authenticated;
GRANT ALL ON TABLE public.driver_locations TO service_role;


--
-- TOC entry 6749 (class 0 OID 0)
-- Dependencies: 392
-- Name: TABLE driver_vehicles; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.driver_vehicles TO anon;
GRANT ALL ON TABLE public.driver_vehicles TO authenticated;
GRANT ALL ON TABLE public.driver_vehicles TO service_role;


--
-- TOC entry 6750 (class 0 OID 0)
-- Dependencies: 391
-- Name: TABLE drivers; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.drivers TO anon;
GRANT ALL ON TABLE public.drivers TO authenticated;
GRANT ALL ON TABLE public.drivers TO service_role;


--
-- TOC entry 6751 (class 0 OID 0)
-- Dependencies: 400
-- Name: TABLE payment_intents; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.payment_intents TO anon;
GRANT ALL ON TABLE public.payment_intents TO authenticated;
GRANT ALL ON TABLE public.payment_intents TO service_role;


--
-- TOC entry 6752 (class 0 OID 0)
-- Dependencies: 410
-- Name: TABLE payment_providers; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.payment_providers TO anon;
GRANT ALL ON TABLE public.payment_providers TO authenticated;
GRANT ALL ON TABLE public.payment_providers TO service_role;


--
-- TOC entry 6753 (class 0 OID 0)
-- Dependencies: 398
-- Name: TABLE payments; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.payments TO anon;
GRANT ALL ON TABLE public.payments TO authenticated;
GRANT ALL ON TABLE public.payments TO service_role;


--
-- TOC entry 6754 (class 0 OID 0)
-- Dependencies: 399
-- Name: TABLE pricing_configs; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.pricing_configs TO anon;
GRANT ALL ON TABLE public.pricing_configs TO authenticated;
GRANT ALL ON TABLE public.pricing_configs TO service_role;


--
-- TOC entry 6755 (class 0 OID 0)
-- Dependencies: 425
-- Name: TABLE profile_kyc; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.profile_kyc TO anon;
GRANT ALL ON TABLE public.profile_kyc TO authenticated;
GRANT ALL ON TABLE public.profile_kyc TO service_role;


--
-- TOC entry 6756 (class 0 OID 0)
-- Dependencies: 390
-- Name: TABLE profiles; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.profiles TO anon;
GRANT ALL ON TABLE public.profiles TO authenticated;
GRANT ALL ON TABLE public.profiles TO service_role;


--
-- TOC entry 6757 (class 0 OID 0)
-- Dependencies: 414
-- Name: TABLE provider_events; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.provider_events TO anon;
GRANT ALL ON TABLE public.provider_events TO authenticated;
GRANT ALL ON TABLE public.provider_events TO service_role;


--
-- TOC entry 6759 (class 0 OID 0)
-- Dependencies: 413
-- Name: SEQUENCE provider_events_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.provider_events_id_seq TO anon;
GRANT ALL ON SEQUENCE public.provider_events_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.provider_events_id_seq TO service_role;


--
-- TOC entry 6760 (class 0 OID 0)
-- Dependencies: 397
-- Name: TABLE ride_events; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.ride_events TO anon;
GRANT ALL ON TABLE public.ride_events TO authenticated;
GRANT ALL ON TABLE public.ride_events TO service_role;


--
-- TOC entry 6762 (class 0 OID 0)
-- Dependencies: 396
-- Name: SEQUENCE ride_events_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.ride_events_id_seq TO anon;
GRANT ALL ON SEQUENCE public.ride_events_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.ride_events_id_seq TO service_role;


--
-- TOC entry 6763 (class 0 OID 0)
-- Dependencies: 405
-- Name: TABLE ride_incidents; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.ride_incidents TO anon;
GRANT ALL ON TABLE public.ride_incidents TO authenticated;
GRANT ALL ON TABLE public.ride_incidents TO service_role;


--
-- TOC entry 6764 (class 0 OID 0)
-- Dependencies: 404
-- Name: TABLE ride_ratings; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.ride_ratings TO anon;
GRANT ALL ON TABLE public.ride_ratings TO authenticated;
GRANT ALL ON TABLE public.ride_ratings TO service_role;


--
-- TOC entry 6765 (class 0 OID 0)
-- Dependencies: 403
-- Name: TABLE ride_receipts; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.ride_receipts TO anon;
GRANT ALL ON TABLE public.ride_receipts TO authenticated;
GRANT ALL ON TABLE public.ride_receipts TO service_role;


--
-- TOC entry 6766 (class 0 OID 0)
-- Dependencies: 394
-- Name: TABLE ride_requests; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.ride_requests TO anon;
GRANT ALL ON TABLE public.ride_requests TO authenticated;
GRANT ALL ON TABLE public.ride_requests TO service_role;


--
-- TOC entry 6767 (class 0 OID 0)
-- Dependencies: 411
-- Name: TABLE topup_packages; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.topup_packages TO anon;
GRANT ALL ON TABLE public.topup_packages TO authenticated;
GRANT ALL ON TABLE public.topup_packages TO service_role;


--
-- TOC entry 6768 (class 0 OID 0)
-- Dependencies: 428
-- Name: TABLE user_notifications; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.user_notifications TO anon;
GRANT ALL ON TABLE public.user_notifications TO authenticated;
GRANT ALL ON TABLE public.user_notifications TO service_role;


--
-- TOC entry 6769 (class 0 OID 0)
-- Dependencies: 408
-- Name: TABLE wallet_entries; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.wallet_entries TO anon;
GRANT ALL ON TABLE public.wallet_entries TO authenticated;
GRANT ALL ON TABLE public.wallet_entries TO service_role;


--
-- TOC entry 6771 (class 0 OID 0)
-- Dependencies: 407
-- Name: SEQUENCE wallet_entries_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.wallet_entries_id_seq TO anon;
GRANT ALL ON SEQUENCE public.wallet_entries_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.wallet_entries_id_seq TO service_role;


--
-- TOC entry 6772 (class 0 OID 0)
-- Dependencies: 409
-- Name: TABLE wallet_holds; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.wallet_holds TO anon;
GRANT ALL ON TABLE public.wallet_holds TO authenticated;
GRANT ALL ON TABLE public.wallet_holds TO service_role;


--
-- TOC entry 6773 (class 0 OID 0)
-- Dependencies: 427
-- Name: TABLE wallet_withdraw_payout_methods; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.wallet_withdraw_payout_methods TO anon;
GRANT ALL ON TABLE public.wallet_withdraw_payout_methods TO authenticated;
GRANT ALL ON TABLE public.wallet_withdraw_payout_methods TO service_role;


--
-- TOC entry 6774 (class 0 OID 0)
-- Dependencies: 424
-- Name: TABLE wallet_withdraw_requests; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.wallet_withdraw_requests TO anon;
GRANT ALL ON TABLE public.wallet_withdraw_requests TO authenticated;
GRANT ALL ON TABLE public.wallet_withdraw_requests TO service_role;


--
-- TOC entry 6775 (class 0 OID 0)
-- Dependencies: 426
-- Name: TABLE wallet_withdrawal_policy; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.wallet_withdrawal_policy TO anon;
GRANT ALL ON TABLE public.wallet_withdrawal_policy TO authenticated;
GRANT ALL ON TABLE public.wallet_withdrawal_policy TO service_role;


--
-- TOC entry 6776 (class 0 OID 0)
-- Dependencies: 375
-- Name: TABLE messages; Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON TABLE realtime.messages TO postgres;
GRANT ALL ON TABLE realtime.messages TO dashboard_user;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO anon;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO authenticated;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO service_role;


--
-- TOC entry 6777 (class 0 OID 0)
-- Dependencies: 429
-- Name: TABLE messages_2026_01_20; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.messages_2026_01_20 TO postgres;
GRANT ALL ON TABLE realtime.messages_2026_01_20 TO dashboard_user;


--
-- TOC entry 6778 (class 0 OID 0)
-- Dependencies: 430
-- Name: TABLE messages_2026_01_21; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.messages_2026_01_21 TO postgres;
GRANT ALL ON TABLE realtime.messages_2026_01_21 TO dashboard_user;


--
-- TOC entry 6779 (class 0 OID 0)
-- Dependencies: 431
-- Name: TABLE messages_2026_01_22; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.messages_2026_01_22 TO postgres;
GRANT ALL ON TABLE realtime.messages_2026_01_22 TO dashboard_user;


--
-- TOC entry 6780 (class 0 OID 0)
-- Dependencies: 432
-- Name: TABLE messages_2026_01_23; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.messages_2026_01_23 TO postgres;
GRANT ALL ON TABLE realtime.messages_2026_01_23 TO dashboard_user;


--
-- TOC entry 6781 (class 0 OID 0)
-- Dependencies: 433
-- Name: TABLE messages_2026_01_24; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.messages_2026_01_24 TO postgres;
GRANT ALL ON TABLE realtime.messages_2026_01_24 TO dashboard_user;


--
-- TOC entry 6782 (class 0 OID 0)
-- Dependencies: 369
-- Name: TABLE schema_migrations; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.schema_migrations TO postgres;
GRANT ALL ON TABLE realtime.schema_migrations TO dashboard_user;
GRANT SELECT ON TABLE realtime.schema_migrations TO anon;
GRANT SELECT ON TABLE realtime.schema_migrations TO authenticated;
GRANT SELECT ON TABLE realtime.schema_migrations TO service_role;
GRANT ALL ON TABLE realtime.schema_migrations TO supabase_realtime_admin;


--
-- TOC entry 6783 (class 0 OID 0)
-- Dependencies: 372
-- Name: TABLE subscription; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.subscription TO postgres;
GRANT ALL ON TABLE realtime.subscription TO dashboard_user;
GRANT SELECT ON TABLE realtime.subscription TO anon;
GRANT SELECT ON TABLE realtime.subscription TO authenticated;
GRANT SELECT ON TABLE realtime.subscription TO service_role;
GRANT ALL ON TABLE realtime.subscription TO supabase_realtime_admin;


--
-- TOC entry 6784 (class 0 OID 0)
-- Dependencies: 371
-- Name: SEQUENCE subscription_id_seq; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO postgres;
GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO dashboard_user;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO anon;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO authenticated;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO service_role;
GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO supabase_realtime_admin;


--
-- TOC entry 6786 (class 0 OID 0)
-- Dependencies: 377
-- Name: TABLE buckets; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

REVOKE ALL ON TABLE storage.buckets FROM supabase_storage_admin;
GRANT ALL ON TABLE storage.buckets TO supabase_storage_admin WITH GRANT OPTION;
GRANT ALL ON TABLE storage.buckets TO service_role;
GRANT ALL ON TABLE storage.buckets TO authenticated;
GRANT ALL ON TABLE storage.buckets TO anon;
GRANT ALL ON TABLE storage.buckets TO postgres WITH GRANT OPTION;


--
-- TOC entry 6787 (class 0 OID 0)
-- Dependencies: 382
-- Name: TABLE buckets_analytics; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.buckets_analytics TO service_role;
GRANT ALL ON TABLE storage.buckets_analytics TO authenticated;
GRANT ALL ON TABLE storage.buckets_analytics TO anon;


--
-- TOC entry 6788 (class 0 OID 0)
-- Dependencies: 383
-- Name: TABLE buckets_vectors; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT SELECT ON TABLE storage.buckets_vectors TO service_role;
GRANT SELECT ON TABLE storage.buckets_vectors TO authenticated;
GRANT SELECT ON TABLE storage.buckets_vectors TO anon;


--
-- TOC entry 6790 (class 0 OID 0)
-- Dependencies: 378
-- Name: TABLE objects; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

REVOKE ALL ON TABLE storage.objects FROM supabase_storage_admin;
GRANT ALL ON TABLE storage.objects TO supabase_storage_admin WITH GRANT OPTION;
GRANT ALL ON TABLE storage.objects TO service_role;
GRANT ALL ON TABLE storage.objects TO authenticated;
GRANT ALL ON TABLE storage.objects TO anon;
GRANT ALL ON TABLE storage.objects TO postgres WITH GRANT OPTION;


--
-- TOC entry 6791 (class 0 OID 0)
-- Dependencies: 381
-- Name: TABLE prefixes; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.prefixes TO service_role;
GRANT ALL ON TABLE storage.prefixes TO authenticated;
GRANT ALL ON TABLE storage.prefixes TO anon;


--
-- TOC entry 6792 (class 0 OID 0)
-- Dependencies: 379
-- Name: TABLE s3_multipart_uploads; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.s3_multipart_uploads TO service_role;
GRANT SELECT ON TABLE storage.s3_multipart_uploads TO authenticated;
GRANT SELECT ON TABLE storage.s3_multipart_uploads TO anon;


--
-- TOC entry 6793 (class 0 OID 0)
-- Dependencies: 380
-- Name: TABLE s3_multipart_uploads_parts; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.s3_multipart_uploads_parts TO service_role;
GRANT SELECT ON TABLE storage.s3_multipart_uploads_parts TO authenticated;
GRANT SELECT ON TABLE storage.s3_multipart_uploads_parts TO anon;


--
-- TOC entry 6794 (class 0 OID 0)
-- Dependencies: 384
-- Name: TABLE vector_indexes; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT SELECT ON TABLE storage.vector_indexes TO service_role;
GRANT SELECT ON TABLE storage.vector_indexes TO authenticated;
GRANT SELECT ON TABLE storage.vector_indexes TO anon;


--
-- TOC entry 6795 (class 0 OID 0)
-- Dependencies: 351
-- Name: TABLE secrets; Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT SELECT,REFERENCES,DELETE,TRUNCATE ON TABLE vault.secrets TO postgres WITH GRANT OPTION;
GRANT SELECT,DELETE ON TABLE vault.secrets TO service_role;


--
-- TOC entry 6796 (class 0 OID 0)
-- Dependencies: 352
-- Name: TABLE decrypted_secrets; Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT SELECT,REFERENCES,DELETE,TRUNCATE ON TABLE vault.decrypted_secrets TO postgres WITH GRANT OPTION;
GRANT SELECT,DELETE ON TABLE vault.decrypted_secrets TO service_role;


--
-- TOC entry 3600 (class 826 OID 16553)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES TO dashboard_user;


--
-- TOC entry 3601 (class 826 OID 16554)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS TO dashboard_user;


--
-- TOC entry 3599 (class 826 OID 16552)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON TABLES TO dashboard_user;


--
-- TOC entry 3614 (class 826 OID 23809)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: cron; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA cron GRANT ALL ON SEQUENCES TO postgres WITH GRANT OPTION;


--
-- TOC entry 3616 (class 826 OID 23808)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: cron; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA cron GRANT ALL ON FUNCTIONS TO postgres WITH GRANT OPTION;


--
-- TOC entry 3615 (class 826 OID 23807)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: cron; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA cron GRANT ALL ON TABLES TO postgres WITH GRANT OPTION;


--
-- TOC entry 3610 (class 826 OID 16632)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON SEQUENCES TO postgres WITH GRANT OPTION;


--
-- TOC entry 3609 (class 826 OID 16631)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON FUNCTIONS TO postgres WITH GRANT OPTION;


--
-- TOC entry 3608 (class 826 OID 16630)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON TABLES TO postgres WITH GRANT OPTION;


--
-- TOC entry 3613 (class 826 OID 16587)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO service_role;


--
-- TOC entry 3612 (class 826 OID 16586)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO service_role;


--
-- TOC entry 3611 (class 826 OID 16585)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO service_role;


--
-- TOC entry 3605 (class 826 OID 16567)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO service_role;


--
-- TOC entry 3607 (class 826 OID 16566)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO service_role;


--
-- TOC entry 3606 (class 826 OID 16565)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO service_role;


--
-- TOC entry 3592 (class 826 OID 16490)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- TOC entry 3593 (class 826 OID 16491)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- TOC entry 3591 (class 826 OID 16489)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- TOC entry 3595 (class 826 OID 16493)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- TOC entry 3590 (class 826 OID 16488)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO service_role;


--
-- TOC entry 3594 (class 826 OID 16492)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES TO service_role;


--
-- TOC entry 3603 (class 826 OID 16557)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON SEQUENCES TO dashboard_user;


--
-- TOC entry 3604 (class 826 OID 16558)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON FUNCTIONS TO dashboard_user;


--
-- TOC entry 3602 (class 826 OID 16556)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON TABLES TO dashboard_user;


--
-- TOC entry 3598 (class 826 OID 16546)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO service_role;


--
-- TOC entry 3597 (class 826 OID 16545)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO service_role;


--
-- TOC entry 3596 (class 826 OID 16544)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO service_role;


--
-- TOC entry 4810 (class 3466 OID 16571)
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_graphql_placeholder ON sql_drop
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION extensions.set_graphql_placeholder();


ALTER EVENT TRIGGER issue_graphql_placeholder OWNER TO supabase_admin;

--
-- TOC entry 4815 (class 3466 OID 16650)
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_cron_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_cron_access();


ALTER EVENT TRIGGER issue_pg_cron_access OWNER TO supabase_admin;

--
-- TOC entry 4809 (class 3466 OID 16569)
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_graphql_access ON ddl_command_end
         WHEN TAG IN ('CREATE FUNCTION')
   EXECUTE FUNCTION extensions.grant_pg_graphql_access();


ALTER EVENT TRIGGER issue_pg_graphql_access OWNER TO supabase_admin;

--
-- TOC entry 4816 (class 3466 OID 16653)
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_net_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_net_access();


ALTER EVENT TRIGGER issue_pg_net_access OWNER TO supabase_admin;

--
-- TOC entry 4811 (class 3466 OID 16572)
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER pgrst_ddl_watch ON ddl_command_end
   EXECUTE FUNCTION extensions.pgrst_ddl_watch();


ALTER EVENT TRIGGER pgrst_ddl_watch OWNER TO supabase_admin;

--
-- TOC entry 4812 (class 3466 OID 16573)
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER pgrst_drop_watch ON sql_drop
   EXECUTE FUNCTION extensions.pgrst_drop_watch();


ALTER EVENT TRIGGER pgrst_drop_watch OWNER TO supabase_admin;

-- Completed on 2026-01-22 03:45:23

--
-- PostgreSQL database dump complete
--

\unrestrict 2uGOZkE6AKCJUJtrdnxZbySpRBEeaf3QLf9l8bWzElj3FzCsfAirch5hvjqh4uY

