--
-- PostgreSQL database dump
--

\restrict cA5EKjNgR9CFftfdRb3SWJcX1HtzVTQaVfmsLGacWEQai4cCEWskv46EIPDUwEI

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.7

-- Started on 2026-01-24 18:34:57

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
-- TOC entry 39 (class 2615 OID 16494)
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
-- TOC entry 6520 (class 0 OID 0)
-- Dependencies: 8
-- Name: EXTENSION pg_cron; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_cron IS 'Job scheduler for PostgreSQL';


--
-- TOC entry 25 (class 2615 OID 16388)
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA extensions;


ALTER SCHEMA extensions OWNER TO postgres;

--
-- TOC entry 37 (class 2615 OID 16574)
-- Name: graphql; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA graphql;


ALTER SCHEMA graphql OWNER TO supabase_admin;

--
-- TOC entry 36 (class 2615 OID 16563)
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
-- TOC entry 6523 (class 0 OID 0)
-- Dependencies: 9
-- Name: EXTENSION pg_net; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_net IS 'Async HTTP';


--
-- TOC entry 14 (class 2615 OID 16386)
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: pgbouncer
--

CREATE SCHEMA pgbouncer;


ALTER SCHEMA pgbouncer OWNER TO pgbouncer;

--
-- TOC entry 136 (class 2615 OID 32478)
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

-- *not* creating schema, since initdb creates it


ALTER SCHEMA public OWNER TO postgres;

--
-- TOC entry 6525 (class 0 OID 0)
-- Dependencies: 136
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS '';


--
-- TOC entry 12 (class 2615 OID 16555)
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA realtime;


ALTER SCHEMA realtime OWNER TO supabase_admin;

--
-- TOC entry 40 (class 2615 OID 16542)
-- Name: storage; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA storage;


ALTER SCHEMA storage OWNER TO supabase_admin;

--
-- TOC entry 137 (class 2615 OID 16603)
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
-- TOC entry 6530 (class 0 OID 0)
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
-- TOC entry 6531 (class 0 OID 0)
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
-- TOC entry 6532 (class 0 OID 0)
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
-- TOC entry 6533 (class 0 OID 0)
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
-- TOC entry 6534 (class 0 OID 0)
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
-- TOC entry 6535 (class 0 OID 0)
-- Dependencies: 3
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- TOC entry 2068 (class 1247 OID 16738)
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


ALTER TYPE auth.aal_level OWNER TO supabase_auth_admin;

--
-- TOC entry 2092 (class 1247 OID 16879)
-- Name: code_challenge_method; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.code_challenge_method AS ENUM (
    's256',
    'plain'
);


ALTER TYPE auth.code_challenge_method OWNER TO supabase_auth_admin;

--
-- TOC entry 2065 (class 1247 OID 16732)
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


ALTER TYPE auth.factor_status OWNER TO supabase_auth_admin;

--
-- TOC entry 2062 (class 1247 OID 16727)
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn',
    'phone'
);


ALTER TYPE auth.factor_type OWNER TO supabase_auth_admin;

--
-- TOC entry 2110 (class 1247 OID 16982)
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
-- TOC entry 2122 (class 1247 OID 17055)
-- Name: oauth_client_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.oauth_client_type AS ENUM (
    'public',
    'confidential'
);


ALTER TYPE auth.oauth_client_type OWNER TO supabase_auth_admin;

--
-- TOC entry 2104 (class 1247 OID 16960)
-- Name: oauth_registration_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.oauth_registration_type AS ENUM (
    'dynamic',
    'manual'
);


ALTER TYPE auth.oauth_registration_type OWNER TO supabase_auth_admin;

--
-- TOC entry 2113 (class 1247 OID 16992)
-- Name: oauth_response_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.oauth_response_type AS ENUM (
    'code'
);


ALTER TYPE auth.oauth_response_type OWNER TO supabase_auth_admin;

--
-- TOC entry 2098 (class 1247 OID 16921)
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
-- TOC entry 2238 (class 1247 OID 39588)
-- Name: app_event_level; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.app_event_level AS ENUM (
    'info',
    'warn',
    'error'
);


ALTER TYPE public.app_event_level OWNER TO postgres;

--
-- TOC entry 2241 (class 1247 OID 39596)
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
-- TOC entry 2244 (class 1247 OID 39608)
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
-- TOC entry 2247 (class 1247 OID 39618)
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
-- TOC entry 2250 (class 1247 OID 39628)
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
-- TOC entry 2253 (class 1247 OID 39638)
-- Name: party_role; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.party_role AS ENUM (
    'rider',
    'driver'
);


ALTER TYPE public.party_role OWNER TO postgres;

--
-- TOC entry 2256 (class 1247 OID 39644)
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
-- TOC entry 2259 (class 1247 OID 39660)
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
-- TOC entry 2262 (class 1247 OID 39670)
-- Name: ride_actor_type; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.ride_actor_type AS ENUM (
    'rider',
    'driver',
    'system'
);


ALTER TYPE public.ride_actor_type OWNER TO postgres;

--
-- TOC entry 2265 (class 1247 OID 39678)
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
-- TOC entry 2268 (class 1247 OID 39692)
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
-- TOC entry 2271 (class 1247 OID 39704)
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
-- TOC entry 2274 (class 1247 OID 39714)
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
-- TOC entry 2277 (class 1247 OID 39724)
-- Name: wallet_hold_kind; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.wallet_hold_kind AS ENUM (
    'ride',
    'withdraw'
);


ALTER TYPE public.wallet_hold_kind OWNER TO postgres;

--
-- TOC entry 2280 (class 1247 OID 39730)
-- Name: wallet_hold_status; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.wallet_hold_status AS ENUM (
    'active',
    'captured',
    'released'
);


ALTER TYPE public.wallet_hold_status OWNER TO postgres;

--
-- TOC entry 2283 (class 1247 OID 39738)
-- Name: withdraw_payout_kind; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.withdraw_payout_kind AS ENUM (
    'qicard',
    'asiapay',
    'zaincash'
);


ALTER TYPE public.withdraw_payout_kind OWNER TO postgres;

--
-- TOC entry 2286 (class 1247 OID 39746)
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
-- TOC entry 2164 (class 1247 OID 17122)
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
-- TOC entry 2131 (class 1247 OID 17082)
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
-- TOC entry 2134 (class 1247 OID 17097)
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.user_defined_filter AS (
	column_name text,
	op realtime.equality_op,
	value text
);


ALTER TYPE realtime.user_defined_filter OWNER TO supabase_admin;

--
-- TOC entry 2170 (class 1247 OID 17164)
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
-- TOC entry 2167 (class 1247 OID 17135)
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
-- TOC entry 2197 (class 1247 OID 17416)
-- Name: buckettype; Type: TYPE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TYPE storage.buckettype AS ENUM (
    'STANDARD',
    'ANALYTICS',
    'VECTOR'
);


ALTER TYPE storage.buckettype OWNER TO supabase_storage_admin;

--
-- TOC entry 1135 (class 1255 OID 16540)
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
-- TOC entry 6586 (class 0 OID 0)
-- Dependencies: 1135
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- TOC entry 1382 (class 1255 OID 16709)
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
-- TOC entry 505 (class 1255 OID 16539)
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
-- TOC entry 6589 (class 0 OID 0)
-- Dependencies: 505
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- TOC entry 1043 (class 1255 OID 16538)
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
-- TOC entry 6591 (class 0 OID 0)
-- Dependencies: 1043
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- TOC entry 641 (class 1255 OID 16547)
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
-- TOC entry 6779 (class 0 OID 0)
-- Dependencies: 641
-- Name: FUNCTION grant_pg_cron_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_cron_access() IS 'Grants access to pg_cron';


--
-- TOC entry 1350 (class 1255 OID 16568)
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
-- TOC entry 6781 (class 0 OID 0)
-- Dependencies: 1350
-- Name: FUNCTION grant_pg_graphql_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_graphql_access() IS 'Grants access to pg_graphql';


--
-- TOC entry 972 (class 1255 OID 16549)
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
-- TOC entry 6783 (class 0 OID 0)
-- Dependencies: 972
-- Name: FUNCTION grant_pg_net_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_net_access() IS 'Grants access to pg_net';


--
-- TOC entry 952 (class 1255 OID 16559)
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
-- TOC entry 1387 (class 1255 OID 16560)
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
-- TOC entry 1344 (class 1255 OID 16570)
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
-- TOC entry 6898 (class 0 OID 0)
-- Dependencies: 1344
-- Name: FUNCTION set_graphql_placeholder(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.set_graphql_placeholder() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- TOC entry 1138 (class 1255 OID 16387)
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

--
-- TOC entry 623 (class 1255 OID 40721)
-- Name: achievement_claim(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.achievement_claim(p_key text) RETURNS TABLE(achievement_key text, claimed boolean, reward_iqd integer)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
declare
  v_uid uuid := (select auth.uid());
  v_a public.achievements%rowtype;
  v_p public.achievement_progress%rowtype;
  v_reward integer;
  v_key text := trim(coalesce(p_key, ''));
  v_idem text;
begin
  if v_uid is null then
    raise exception 'unauthorized';
  end if;
  if v_key = '' then
    raise exception 'invalid_key';
  end if;

  select * into v_a from public.achievements where key = v_key and active;
  if not found then
    raise exception 'achievement_not_found';
  end if;

  select * into v_p
  from public.achievement_progress
  where user_id = v_uid and achievement_id = v_a.id
  for update;

  if not found or v_p.completed_at is null then
    raise exception 'achievement_not_completed';
  end if;

  if v_p.claimed_at is not null then
    return query select v_key, true, v_a.reward_iqd;
    return;
  end if;

  v_reward := coalesce(v_a.reward_iqd, 0);

  if v_reward > 0 then
    v_idem := 'achievement:' || v_key || ':' || v_uid::text;

    insert into public.wallet_accounts(user_id)
    values (v_uid)
    on conflict (user_id) do nothing;

    insert into public.wallet_entries(
      user_id, delta_iqd, kind, memo, source_type, source_id, metadata, idempotency_key
    )
    values (
      v_uid,
      v_reward::bigint,
      'reward',
      'Achievement reward',
      'achievement',
      v_a.id,
      jsonb_build_object('achievement_key', v_key),
      v_idem
    )
    on conflict (user_id, idempotency_key) where idempotency_key is not null do nothing;

    update public.wallet_accounts
      set balance_iqd = balance_iqd + v_reward::bigint,
          updated_at = now()
    where user_id = v_uid;
  end if;

  update public.achievement_progress
    set claimed_at = now(),
        updated_at = now()
  where id = v_p.id;

  perform public.notify_user(v_uid, 'achievement_claimed', 'Achievement unlocked', 'Reward claimed successfully.', jsonb_build_object('achievement_key', v_key, 'reward_iqd', v_reward));

  return query select v_key, true, v_reward;
end;
$$;


ALTER FUNCTION public.achievement_claim(p_key text) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 411 (class 1259 OID 39757)
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
-- TOC entry 693 (class 1255 OID 39764)
-- Name: admin_create_gift_code(bigint, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.admin_create_gift_code(p_amount_iqd bigint, p_code text DEFAULT NULL::text, p_memo text DEFAULT NULL::text) RETURNS public.gift_codes
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
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
-- TOC entry 1079 (class 1255 OID 39765)
-- Name: admin_mark_stale_drivers_offline(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.admin_mark_stale_drivers_offline(p_stale_after_seconds integer DEFAULT 120, p_limit integer DEFAULT 500) RETURNS integer
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog'
    AS $$
DECLARE
  v_count integer := 0;
  v_limit integer;
BEGIN
  v_limit := greatest(1, least(coalesce(p_limit, 500), 5000));

  WITH stale AS (
    SELECT d.id
    FROM public.drivers d
    JOIN public.driver_locations dl ON dl.driver_id = d.id
    WHERE d.status = 'available'
      AND dl.updated_at < now() - make_interval(secs => greatest(1, coalesce(p_stale_after_seconds, 120)))
    ORDER BY dl.updated_at ASC
    LIMIT v_limit
  )
  UPDATE public.drivers d
  SET status = 'offline'
  WHERE d.id IN (SELECT id FROM stale);

  GET DIAGNOSTICS v_count = ROW_COUNT;
  RETURN v_count;
END;
$$;


ALTER FUNCTION public.admin_mark_stale_drivers_offline(p_stale_after_seconds integer, p_limit integer) OWNER TO postgres;

--
-- TOC entry 1100 (class 1255 OID 39766)
-- Name: admin_record_ride_refund(uuid, integer, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.admin_record_ride_refund(p_ride_id uuid, p_refund_amount_iqd integer DEFAULT NULL::integer, p_reason text DEFAULT NULL::text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
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
-- TOC entry 695 (class 1255 OID 39767)
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
-- TOC entry 900 (class 1255 OID 39768)
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
-- TOC entry 1355 (class 1255 OID 39770)
-- Name: admin_withdraw_approve(uuid, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.admin_withdraw_approve(p_request_id uuid, p_note text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
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
-- TOC entry 620 (class 1255 OID 39771)
-- Name: admin_withdraw_mark_paid(uuid, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.admin_withdraw_mark_paid(p_request_id uuid, p_payout_reference text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
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
-- TOC entry 556 (class 1255 OID 39772)
-- Name: admin_withdraw_reject(uuid, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.admin_withdraw_reject(p_request_id uuid, p_note text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
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
-- TOC entry 742 (class 1255 OID 39773)
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
-- TOC entry 509 (class 1255 OID 40785)
-- Name: apply_referral_rewards(uuid, uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.apply_referral_rewards(p_referred_id uuid, p_ride_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
declare
  v_redemption public.referral_redemptions%rowtype;
  v_campaign public.referral_campaigns%rowtype;
  v_first boolean;
  v_ref_reward int;
  v_new_reward int;
  v_idem text;
begin
  if p_referred_id is null or p_ride_id is null then
    return;
  end if;

  -- First completed ride check
  select not exists (
    select 1 from public.rides r
    where r.rider_id = p_referred_id
      and r.status = 'completed'
      and r.id <> p_ride_id
  ) into v_first;

  if not v_first then
    return;
  end if;

  select * into v_redemption
  from public.referral_redemptions
  where referred_id = p_referred_id
    and status = 'pending'
  for update;

  if not found then
    return;
  end if;

  select * into v_campaign
  from public.referral_campaigns
  where id = v_redemption.campaign_id and active;

  if not found then
    update public.referral_redemptions
      set status = 'invalid',
          earned_at = now(),
          rewarded_at = now(),
          ride_id = p_ride_id
    where id = v_redemption.id;
    return;
  end if;

  v_ref_reward := coalesce(v_campaign.referrer_reward_iqd, 0);
  v_new_reward := coalesce(v_campaign.referred_reward_iqd, 0);

  -- Idempotency via wallet_entries idempotency_key
  if v_ref_reward > 0 then
    insert into public.wallet_accounts(user_id)
    values (v_redemption.referrer_id)
    on conflict (user_id) do nothing;

    v_idem := 'referral:' || v_redemption.id::text || ':referrer';
    insert into public.wallet_entries(user_id, delta_iqd, kind, memo, source_type, source_id, metadata, idempotency_key)
    values (
      v_redemption.referrer_id,
      v_ref_reward::bigint,
      'reward',
      'Referral reward',
      'referral',
      v_redemption.id,
      jsonb_build_object('referred_id', p_referred_id, 'ride_id', p_ride_id),
      v_idem
    )
    on conflict (user_id, idempotency_key) where idempotency_key is not null do nothing;

    update public.wallet_accounts
      set balance_iqd = balance_iqd + v_ref_reward::bigint,
          updated_at = now()
    where user_id = v_redemption.referrer_id;
  end if;

  if v_new_reward > 0 then
    insert into public.wallet_accounts(user_id)
    values (p_referred_id)
    on conflict (user_id) do nothing;

    v_idem := 'referral:' || v_redemption.id::text || ':referred';
    insert into public.wallet_entries(user_id, delta_iqd, kind, memo, source_type, source_id, metadata, idempotency_key)
    values (
      p_referred_id,
      v_new_reward::bigint,
      'reward',
      'Referral reward',
      'referral',
      v_redemption.id,
      jsonb_build_object('referrer_id', v_redemption.referrer_id, 'ride_id', p_ride_id),
      v_idem
    )
    on conflict (user_id, idempotency_key) where idempotency_key is not null do nothing;

    update public.wallet_accounts
      set balance_iqd = balance_iqd + v_new_reward::bigint,
          updated_at = now()
    where user_id = p_referred_id;
  end if;

  update public.referral_redemptions
    set status = 'rewarded',
        earned_at = now(),
        rewarded_at = now(),
        ride_id = p_ride_id
  where id = v_redemption.id;

  perform public.notify_user(v_redemption.referrer_id, 'referral_reward', 'Referral reward earned', 'Your referral completed their first ride. Reward added to your wallet.', jsonb_build_object('reward_iqd', v_ref_reward, 'referred_id', p_referred_id));
  perform public.notify_user(p_referred_id, 'referral_reward', 'Welcome reward', 'You completed your first ride. Reward added to your wallet.', jsonb_build_object('reward_iqd', v_new_reward, 'referrer_id', v_redemption.referrer_id));
end;
$$;


ALTER FUNCTION public.apply_referral_rewards(p_referred_id uuid, p_ride_id uuid) OWNER TO postgres;

--
-- TOC entry 902 (class 1255 OID 39774)
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
-- TOC entry 1338 (class 1255 OID 39775)
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
-- TOC entry 874 (class 1255 OID 41368)
-- Name: dispatch_accept_ride(uuid, uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.dispatch_accept_ride(p_request_id uuid, p_driver_id uuid) RETURNS TABLE(ride_id uuid, ride_status public.ride_status, request_status public.ride_request_status, wallet_hold_id uuid, rider_id uuid, driver_id uuid, started_at timestamp with time zone, completed_at timestamp with time zone, fare_amount_iqd integer, currency text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
    AS $$
#variable_conflict use_column
declare
  rr record;
  r record;
  v_hold_id uuid;
  v_quote bigint;
begin
  select * into rr
  from public.ride_requests req
  where req.id = p_request_id
  for update;

  if not found then
    raise exception 'ride_request_not_found';
  end if;

  if rr.assigned_driver_id is distinct from p_driver_id then
    raise exception 'forbidden';
  end if;

  if rr.status <> 'matched' then
    raise exception 'request_not_matched';
  end if;

  -- ensure driver is reserved
  if not exists (select 1 from public.drivers d where d.id = p_driver_id and d.status = 'reserved') then
    raise exception 'driver_not_reserved';
  end if;

  v_quote := coalesce(rr.quote_amount_iqd, 0)::bigint;
  if v_quote <= 0 then
    v_quote := public.estimate_ride_quote_iqd_v2(rr.pickup_loc, rr.dropoff_loc, rr.product_code)::bigint;
    if v_quote <= 0 then
      raise exception 'invalid_quote';
    end if;
  end if;

  -- Mark accepted
  update public.ride_requests
    set status = 'accepted',
        quote_amount_iqd = v_quote::int
  where id = rr.id and status = 'matched';

  -- Create ride (idempotent)
  insert into public.rides (request_id, rider_id, driver_id, status, version, started_at, completed_at, fare_amount_iqd, currency, product_code)
  values (rr.id, rr.rider_id, p_driver_id, 'assigned', 0, null, null, v_quote::int, rr.currency, rr.product_code)
  on conflict (request_id) do update
    set driver_id = excluded.driver_id,
        fare_amount_iqd = excluded.fare_amount_iqd,
        currency = excluded.currency,
        product_code = excluded.product_code
  returning * into r;

  -- Reserve fare amount from rider wallet (hold)
  v_hold_id := public.wallet_hold_upsert_for_ride(r.rider_id, r.id, r.fare_amount_iqd::bigint);

  -- Driver is now on-trip
  update public.drivers
    set status = 'on_trip'
  where id = p_driver_id;

  return query
    select r.id, r.status, 'accepted'::public.ride_request_status, v_hold_id, r.rider_id, r.driver_id, r.started_at, r.completed_at, r.fare_amount_iqd, r.currency;
end;
$$;


ALTER FUNCTION public.dispatch_accept_ride(p_request_id uuid, p_driver_id uuid) OWNER TO postgres;

--
-- TOC entry 1253 (class 1255 OID 39777)
-- Name: dispatch_match_ride(uuid, uuid, numeric, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.dispatch_match_ride(p_request_id uuid, p_rider_id uuid, p_radius_m numeric DEFAULT 5000, p_limit_n integer DEFAULT 20, p_match_ttl_seconds integer DEFAULT 120, p_stale_after_seconds integer DEFAULT 30) RETURNS TABLE(id uuid, status public.ride_request_status, assigned_driver_id uuid, match_deadline timestamp with time zone, match_attempts integer, matched_at timestamp with time zone)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
    AS $$
#variable_conflict use_column
declare
  rr record;
  candidate uuid;
  up record;
  tried uuid[] := '{}'::uuid[];
  v_balance bigint;
  v_held bigint;
  v_available bigint;
  v_quote bigint;
  v_req_capacity int := 4;
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
    where id = rr.assigned_driver_id and status = 'reserved';

    update public.ride_requests
      set status = 'requested',
          assigned_driver_id = null,
          match_deadline = null
    where id = rr.id and status = 'matched';
    rr.status := 'requested';
    rr.assigned_driver_id := null;
    rr.match_deadline := null;
  end if;

  if rr.status <> 'requested' then
    return query select rr.id, rr.status, rr.assigned_driver_id, rr.match_deadline, rr.match_attempts, rr.matched_at;
    return;
  end if;

  select capacity_min into v_req_capacity
  from public.ride_products
  where code = rr.product_code;

  v_req_capacity := coalesce(v_req_capacity, 4);

  v_quote := coalesce(rr.quote_amount_iqd, 0)::bigint;
  if v_quote <= 0 then
    v_quote := public.estimate_ride_quote_iqd_v2(rr.pickup_loc, rr.dropoff_loc, rr.product_code)::bigint;
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
        and exists (
          select 1 from public.driver_vehicles v
          where v.driver_id = d.id
            and coalesce(v.is_active, true) = true
            and coalesce(v.capacity, 4) >= v_req_capacity
        )
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
        into up;

      if found then
        return query select up.id, up.status, up.assigned_driver_id, up.match_deadline, up.match_attempts, up.matched_at;
        return;
      end if;
    exception when others then
      update public.drivers
        set status = 'available'
      where id = candidate and status = 'reserved';
      raise;
    end;

    tried := array_append(tried, candidate);

    update public.drivers
      set status = 'available'
    where id = candidate and status = 'reserved';
  end loop;

  return query select rr.id, rr.status, rr.assigned_driver_id, rr.match_deadline, rr.match_attempts, rr.matched_at;
end;
$$;


ALTER FUNCTION public.dispatch_match_ride(p_request_id uuid, p_rider_id uuid, p_radius_m numeric, p_limit_n integer, p_match_ttl_seconds integer, p_stale_after_seconds integer) OWNER TO postgres;

--
-- TOC entry 1335 (class 1255 OID 41844)
-- Name: driver_leaderboard_refresh_day(date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.driver_leaderboard_refresh_day(p_day date DEFAULT NULL::date) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'extensions', 'pg_temp'
    AS $$
declare
  v_day date := coalesce(p_day, (now() at time zone 'utc')::date);
begin
  -- Ensure stats exist
  perform public.driver_stats_rollup_day(v_day);

  -- Score: trips + (earnings in thousands)
  with base as (
    select
      day,
      driver_id,
      trips_count,
      earnings_iqd,
      (trips_count::numeric + (earnings_iqd::numeric / 1000.0)) as score
    from public.driver_stats_daily
    where day = v_day
  ),
  ranked as (
    select
      b.*,
      dense_rank() over (order by b.score desc, b.trips_count desc, b.earnings_iqd desc, b.driver_id) as rnk
    from base b
  )
  insert into public.driver_leaderboard_daily (day, driver_id, trips_count, earnings_iqd, score, rank, updated_at)
  select day, driver_id, trips_count, earnings_iqd, score, rnk, now()
  from ranked
  on conflict (day, driver_id) do update
    set trips_count = excluded.trips_count,
        earnings_iqd = excluded.earnings_iqd,
        score = excluded.score,
        rank = excluded.rank,
        updated_at = now();
end;
$$;


ALTER FUNCTION public.driver_leaderboard_refresh_day(p_day date) OWNER TO postgres;

--
-- TOC entry 799 (class 1255 OID 41824)
-- Name: driver_stats_rollup_day(date); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.driver_stats_rollup_day(p_day date DEFAULT NULL::date) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'extensions', 'pg_temp'
    AS $$
declare
  v_day date := coalesce(p_day, (now() at time zone 'utc')::date);
begin
  -- Aggregate completed rides for each driver on v_day using wallet entries (driver credit)
  insert into public.driver_stats_daily (day, driver_id, trips_count, earnings_iqd, updated_at)
  select
    v_day as day,
    r.driver_id,
    count(*)::int as trips_count,
    coalesce(sum(we.delta_iqd),0)::bigint as earnings_iqd,
    now()
  from public.rides r
  left join public.wallet_entries we
    on we.source_type = 'ride'
   and we.source_id = r.id
   and we.user_id = r.driver_id
   and we.kind = 'ride_fare'
   and we.delta_iqd > 0
  where r.status = 'completed'
    and (r.completed_at at time zone 'utc')::date = v_day
  group by r.driver_id
  on conflict (day, driver_id) do update
    set trips_count = excluded.trips_count,
        earnings_iqd = excluded.earnings_iqd,
        updated_at = now();
end;
$$;


ALTER FUNCTION public.driver_stats_rollup_day(p_day date) OWNER TO postgres;

--
-- TOC entry 532 (class 1255 OID 42211)
-- Name: drivers_force_id_from_auth_uid(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.drivers_force_id_from_auth_uid() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_catalog'
    AS $$
begin
  if (select auth.uid()) is not null then
    new.id := (select auth.uid());
  end if;
  return new;
end;
$$;


ALTER FUNCTION public.drivers_force_id_from_auth_uid() OWNER TO postgres;

--
-- TOC entry 619 (class 1255 OID 40629)
-- Name: enqueue_notification_outbox(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.enqueue_notification_outbox() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'pg_temp'
    AS $$
begin
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


ALTER FUNCTION public.enqueue_notification_outbox() OWNER TO postgres;

--
-- TOC entry 795 (class 1255 OID 40783)
-- Name: ensure_referral_code(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ensure_referral_code(p_user_id uuid DEFAULT NULL::uuid) RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
declare
  v_uid uuid := coalesce(p_user_id, (select auth.uid()));
  v_code text;
  v_try int := 0;
begin
  if v_uid is null then
    raise exception 'unauthorized';
  end if;

  select code into v_code from public.referral_codes where user_id = v_uid;
  if found then
    return v_code;
  end if;

  loop
    v_try := v_try + 1;
    v_code := upper(substring(replace(encode(gen_random_bytes(6), 'base32'), '=', '') from 1 for 8));

    begin
      insert into public.referral_codes(code, user_id)
      values (v_code, v_uid);
      return v_code;
    exception when unique_violation then
      if v_try > 10 then
        raise exception 'could_not_generate_code';
      end if;
    end;
  end loop;
end;
$$;


ALTER FUNCTION public.ensure_referral_code(p_user_id uuid) OWNER TO postgres;

--
-- TOC entry 996 (class 1255 OID 39779)
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
-- TOC entry 518 (class 1255 OID 39780)
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
-- TOC entry 906 (class 1255 OID 41228)
-- Name: estimate_ride_quote_iqd_v2(extensions.geography, extensions.geography, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.estimate_ride_quote_iqd_v2(_pickup extensions.geography, _dropoff extensions.geography, _product_code text DEFAULT 'standard'::text) RETURNS integer
    LANGUAGE plpgsql STABLE
    SET search_path TO 'pg_catalog, extensions'
    AS $$
declare
  cfg record;
  dist_m double precision;
  dist_km numeric;
  base_quote numeric;
  mult numeric := 1.000;
begin
  select currency, base_fare_iqd, per_km_iqd, per_min_iqd, minimum_fare_iqd
    into cfg
  from public.pricing_configs
  where active = true
  order by created_at desc
  limit 1;

  select price_multiplier into mult
  from public.ride_products
  where code = _product_code and is_active = true;

  mult := coalesce(mult, 1.000);

  dist_m := extensions.st_distance(_pickup::extensions.geometry, _dropoff::extensions.geometry);
  dist_km := greatest(0, dist_m / 1000.0);

  base_quote := (cfg.base_fare_iqd + ceil(dist_km * cfg.per_km_iqd));
  base_quote := greatest(base_quote, cfg.minimum_fare_iqd);

  return greatest(0, ceil(base_quote * mult))::integer;
end;
$$;


ALTER FUNCTION public.estimate_ride_quote_iqd_v2(_pickup extensions.geography, _dropoff extensions.geography, _product_code text) OWNER TO postgres;

--
-- TOC entry 1014 (class 1255 OID 40788)
-- Name: get_assigned_driver(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_assigned_driver(p_ride_id uuid) RETURNS TABLE(driver_id uuid, display_name text, rating_avg numeric, rating_count integer, vehicle_make text, vehicle_model text, vehicle_color text, plate_number text)
    LANGUAGE plpgsql STABLE SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
declare
  v_uid uuid := (select auth.uid());
  v_ride record;
begin
  if v_uid is null then
    raise exception 'unauthorized';
  end if;

  select r.id, r.rider_id, r.driver_id into v_ride
  from public.rides r
  where r.id = p_ride_id;

  if not found then
    raise exception 'ride_not_found';
  end if;

  if v_ride.rider_id <> v_uid and v_ride.driver_id <> v_uid and not (select public.is_admin()) then
    raise exception 'forbidden';
  end if;

  return query
  select
    d.id,
    pp.display_name,
    d.rating_avg,
    d.rating_count,
    dv.make,
    dv.model,
    dv.color,
    dv.plate_number
  from public.drivers d
  left join public.public_profiles pp on pp.id = d.id
  left join lateral (
    select make, model, color, plate_number
    from public.driver_vehicles
    where driver_id = d.id
    order by updated_at desc nulls last, created_at desc
    limit 1
  ) dv on true
  where d.id = v_ride.driver_id;
end;
$$;


ALTER FUNCTION public.get_assigned_driver(p_ride_id uuid) OWNER TO postgres;

--
-- TOC entry 651 (class 1255 OID 40680)
-- Name: get_driver_leaderboard(text, date, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_driver_leaderboard(p_period text, p_period_start date DEFAULT NULL::date, p_limit integer DEFAULT 50) RETURNS TABLE(rank integer, driver_id uuid, display_name text, rating_avg numeric, score_iqd bigint, rides_completed integer)
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
  with params as (
    select
      lower(coalesce(p_period, 'weekly')) as period,
      coalesce(
        p_period_start,
        case
          when lower(coalesce(p_period, 'weekly')) = 'weekly' then date_trunc('week', now())::date
          else date_trunc('month', now())::date
        end
      ) as period_start,
      greatest(1, least(coalesce(p_limit, 50), 200)) as lim
  )
  select
    s.rank,
    s.driver_id,
    pp.display_name,
    d.rating_avg,
    s.score_iqd,
    s.rides_completed
  from params p
  join public.driver_rank_snapshots s
    on s.period = p.period and s.period_start = p.period_start
  join public.drivers d on d.id = s.driver_id
  left join public.public_profiles pp on pp.id = s.driver_id
  order by s.rank
  limit (select lim from params);
$$;


ALTER FUNCTION public.get_driver_leaderboard(p_period text, p_period_start date, p_limit integer) OWNER TO postgres;

--
-- TOC entry 1074 (class 1255 OID 39781)
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
-- TOC entry 662 (class 1255 OID 39782)
-- Name: is_admin(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.is_admin() RETURNS boolean
    LANGUAGE sql STABLE SECURITY DEFINER
    SET search_path TO 'pg_catalog'
    AS $$
  select coalesce((select p.is_admin from public.profiles p where p.id = auth.uid()), false);
$$;


ALTER FUNCTION public.is_admin() OWNER TO postgres;

--
-- TOC entry 752 (class 1255 OID 40631)
-- Name: notification_outbox_claim(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.notification_outbox_claim(p_limit integer DEFAULT 50) RETURNS TABLE(id bigint, notification_id uuid, user_id uuid, attempts integer)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
begin
  return query
  with picked as (
    select o.id
    from public.notification_outbox o
    where o.status = 'pending'
    order by o.id
    limit greatest(1, least(coalesce(p_limit, 50), 200))
    for update skip locked
  )
  update public.notification_outbox o
    set status = 'processing',
        attempts = o.attempts + 1,
        last_attempt_at = now()
  where o.id in (select id from picked)
  returning o.id, o.notification_id, o.user_id, o.attempts;
end;
$$;


ALTER FUNCTION public.notification_outbox_claim(p_limit integer) OWNER TO postgres;

--
-- TOC entry 515 (class 1255 OID 40632)
-- Name: notification_outbox_mark(bigint, text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.notification_outbox_mark(p_outbox_id bigint, p_status text, p_error text DEFAULT NULL::text) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
declare
  v_status text := lower(coalesce(p_status, 'failed'));
begin
  if v_status not in ('sent','failed','skipped') then
    raise exception 'invalid_status';
  end if;

  update public.notification_outbox
    set status = v_status,
        last_error = case when v_status in ('failed') then left(coalesce(p_error,''), 1000) else null end
  where id = p_outbox_id;
end;
$$;


ALTER FUNCTION public.notification_outbox_mark(p_outbox_id bigint, p_status text, p_error text) OWNER TO postgres;

--
-- TOC entry 686 (class 1255 OID 39783)
-- Name: notify_user(uuid, text, text, text, jsonb); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.notify_user(p_user_id uuid, p_kind text, p_title text, p_body text DEFAULT NULL::text, p_data jsonb DEFAULT '{}'::jsonb) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
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
-- TOC entry 1358 (class 1255 OID 40786)
-- Name: on_ride_completed_side_effects(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.on_ride_completed_side_effects() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
declare
  v_day date;
  v_amount bigint;
begin
  -- only for transitions into completed
  if new.status <> 'completed' or old.status = 'completed' then
    return new;
  end if;

  v_day := (coalesce(new.completed_at, now()) at time zone 'UTC')::date;
  v_amount := coalesce(new.fare_amount_iqd, 0)::bigint;

  -- trips_count on drivers
  update public.drivers
    set trips_count = trips_count + 1,
        updated_at = now()
  where id = new.driver_id;

  -- counters
  insert into public.driver_counters(driver_id, completed_rides, earnings_iqd, updated_at)
  values (new.driver_id, 1, v_amount, now())
  on conflict (driver_id) do update
    set completed_rides = public.driver_counters.completed_rides + 1,
        earnings_iqd = public.driver_counters.earnings_iqd + excluded.earnings_iqd,
        updated_at = now();

  -- daily stats
  insert into public.driver_stats_daily(driver_id, day, rides_completed, earnings_iqd, updated_at)
  values (new.driver_id, v_day, 1, v_amount, now())
  on conflict (driver_id, day) do update
    set rides_completed = public.driver_stats_daily.rides_completed + 1,
        earnings_iqd = public.driver_stats_daily.earnings_iqd + excluded.earnings_iqd,
        updated_at = now();

  -- achievements
  perform public.update_driver_achievements(new.driver_id);

  -- referrals (first ride reward)
  perform public.apply_referral_rewards(new.rider_id, new.id);

  -- optional notifications
  perform public.notify_user(new.driver_id, 'driver_trip_completed', 'Trip completed', 'Your earnings were added to your wallet.', jsonb_build_object('ride_id', new.id, 'amount_iqd', v_amount));
  perform public.notify_user(new.rider_id, 'rider_trip_completed', 'Trip completed', 'Thanks for riding with RideIQ.', jsonb_build_object('ride_id', new.id));

  return new;
end;
$$;


ALTER FUNCTION public.on_ride_completed_side_effects() OWNER TO postgres;

--
-- TOC entry 690 (class 1255 OID 41728)
-- Name: on_ride_completed_v1(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.on_ride_completed_v1(p_ride_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
    AS $$
declare
  v_ride public.rides;
  v_day date;
  v_first_driver_completed boolean := false;
  v_total_driver_completed int;
  v_a record;
  v_progress int;
  v_rewarded boolean := false;
  v_redemption public.referral_redemptions;
  v_campaign public.referral_campaigns;
  v_driver_reward bigint;
  v_referred_reward bigint;
begin
  -- idempotency guard
  insert into public.ride_completion_log (ride_id) values (p_ride_id)
  on conflict (ride_id) do nothing;

  if not found then
    return;
  end if;

  select * into v_ride from public.rides where id = p_ride_id;
  if not found then
    return;
  end if;

  if v_ride.status <> 'completed'::public.ride_status then
    return;
  end if;

  v_day := (v_ride.completed_at at time zone 'UTC')::date;

  -- Driver aggregate counters
  update public.drivers
    set trips_count = trips_count + 1,
        updated_at = now()
  where id = v_ride.driver_id;

  -- Driver daily stats
  insert into public.driver_stats_daily (driver_id, day, rides_completed, earnings_iqd)
  values (v_ride.driver_id, v_day, 1, coalesce(v_ride.fare_amount_iqd, 0))
  on conflict (driver_id, day) do update
    set rides_completed = public.driver_stats_daily.rides_completed + 1,
        earnings_iqd = public.driver_stats_daily.earnings_iqd + coalesce(v_ride.fare_amount_iqd, 0),
        updated_at = now();

  -- Achievement progress (driver rides completed)
  select trips_count into v_total_driver_completed from public.drivers where id = v_ride.driver_id;
  if v_total_driver_completed is null then
    v_total_driver_completed := 0;
  end if;

  for v_a in
    select a.key, a.target_value, a.reward_iqd
    from public.achievements a
    where a.audience = 'driver'
  loop
    v_progress := least(v_total_driver_completed, v_a.target_value);

    insert into public.user_achievement_progress (user_id, achievement_key, progress_value)
    values (v_ride.driver_id, v_a.key, v_progress)
    on conflict (user_id, achievement_key) do update
      set progress_value = excluded.progress_value,
          updated_at = now();

    -- Auto-grant reward when reaching target (idempotent via unique claim)
    if v_progress >= v_a.target_value then
      begin
        insert into public.achievement_claims (user_id, achievement_key, reward_iqd, idempotency_key)
        values (v_ride.driver_id, v_a.key, v_a.reward_iqd, concat('ach:', v_ride.driver_id::text, ':', v_a.key))
        on conflict (user_id, achievement_key) do nothing;

        if found and v_a.reward_iqd > 0 then
          perform public.wallet_adjust_v1(
            v_ride.driver_id,
            v_a.reward_iqd,
            'Achievement reward',
            'achievement',
            v_ride.id,
            concat('ach_reward:', v_ride.driver_id::text, ':', v_a.key),
            jsonb_build_object('achievement_key', v_a.key, 'ride_id', v_ride.id)
          );

          perform public.notify_user(
            v_ride.driver_id,
            'achievement',
            'Achievement unlocked!',
            v_a.key,
            jsonb_build_object('achievement_key', v_a.key)
          );
        end if;
      exception when others then
        -- do not break completion path
        null;
      end;
    end if;
  end loop;

  -- Referrals: when rider completes their first ride
  -- Determine first completed ride for the rider
  if v_ride.rider_id is not null then
    perform 1;
    if (select count(1) from public.rides r where r.rider_id = v_ride.rider_id and r.status = 'completed') = 1 then
      select * into v_redemption
      from public.referral_redemptions rr
      where rr.referred_user_id = v_ride.rider_id and rr.status = 'pending'
      limit 1;

      if found then
        select * into v_campaign
        from public.referral_campaigns c
        where c.id = v_redemption.campaign_id
        limit 1;

        if not found then
          -- fallback: first active campaign
          select * into v_campaign
          from public.referral_campaigns c
          where c.active = true
          order by c.created_at desc
          limit 1;
        end if;

        v_driver_reward := coalesce(v_campaign.reward_referrer_iqd, 0);
        v_referred_reward := coalesce(v_campaign.reward_referred_iqd, 0);

        update public.referral_redemptions
          set status = 'rewarded',
              rewarded_at = now()
        where id = v_redemption.id and status = 'pending';

        if found then
          if v_driver_reward > 0 then
            perform public.wallet_adjust_v1(
              v_redemption.referrer_user_id,
              v_driver_reward,
              'Referral reward',
              'referral',
              v_ride.id,
              concat('ref_reward_referrer:', v_redemption.id::text),
              jsonb_build_object('redemption_id', v_redemption.id, 'role', 'referrer')
            );
            perform public.notify_user(
              v_redemption.referrer_user_id,
              'referral',
              'Referral reward earned',
              null,
              jsonb_build_object('amount_iqd', v_driver_reward)
            );
          end if;

          if v_referred_reward > 0 then
            perform public.wallet_adjust_v1(
              v_redemption.referred_user_id,
              v_referred_reward,
              'Welcome bonus',
              'referral',
              v_ride.id,
              concat('ref_reward_referred:', v_redemption.id::text),
              jsonb_build_object('redemption_id', v_redemption.id, 'role', 'referred')
            );
            perform public.notify_user(
              v_redemption.referred_user_id,
              'referral',
              'Welcome bonus received',
              null,
              jsonb_build_object('amount_iqd', v_referred_reward)
            );
          end if;
        end if;
      end if;
    end if;
  end if;

end;
$$;


ALTER FUNCTION public.on_ride_completed_v1(p_ride_id uuid) OWNER TO postgres;

--
-- TOC entry 981 (class 1255 OID 39784)
-- Name: profile_kyc_init(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.profile_kyc_init() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
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
-- TOC entry 854 (class 1255 OID 41229)
-- Name: quote_products_iqd(double precision, double precision, double precision, double precision); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.quote_products_iqd(p_pickup_lat double precision, p_pickup_lng double precision, p_dropoff_lat double precision, p_dropoff_lng double precision) RETURNS TABLE(product_code text, product_name text, capacity_min integer, price_multiplier numeric, quote_amount_iqd integer)
    LANGUAGE sql STABLE
    SET search_path TO 'pg_catalog, extensions'
    AS $$
with pts as (
  select
    (extensions.st_setsrid(extensions.st_makepoint(p_pickup_lng, p_pickup_lat), 4326))::extensions.geography as pickup,
    (extensions.st_setsrid(extensions.st_makepoint(p_dropoff_lng, p_dropoff_lat), 4326))::extensions.geography as dropoff
)
select
  rp.code,
  rp.name,
  rp.capacity_min,
  rp.price_multiplier,
  public.estimate_ride_quote_iqd_v2(pts.pickup, pts.dropoff, rp.code) as quote_amount_iqd
from public.ride_products rp
cross join pts
where rp.is_active = true
order by rp.sort_order, rp.code;
$$;


ALTER FUNCTION public.quote_products_iqd(p_pickup_lat double precision, p_pickup_lng double precision, p_dropoff_lat double precision, p_dropoff_lng double precision) OWNER TO postgres;

--
-- TOC entry 1368 (class 1255 OID 39785)
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
-- TOC entry 1024 (class 1255 OID 39786)
-- Name: redeem_gift_code(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.redeem_gift_code(p_code text) RETURNS public.gift_codes
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
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
-- TOC entry 1088 (class 1255 OID 40784)
-- Name: referral_apply_code(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.referral_apply_code(p_code text) RETURNS TABLE(applied boolean, referrer_id uuid, campaign_key text)
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
declare
  v_uid uuid := (select auth.uid());
  v_code text := upper(trim(coalesce(p_code, '')));
  v_referrer uuid;
  v_campaign public.referral_campaigns%rowtype;
  v_existing uuid;
begin
  if v_uid is null then
    raise exception 'unauthorized';
  end if;
  if v_code = '' then
    raise exception 'invalid_code';
  end if;

  select user_id into v_referrer from public.referral_codes where code = v_code;
  if not found then
    raise exception 'code_not_found';
  end if;
  if v_referrer = v_uid then
    raise exception 'self_referral_not_allowed';
  end if;

  select * into v_campaign from public.referral_campaigns where key = 'default' and active;
  if not found then
    raise exception 'campaign_not_found';
  end if;

  select referred_id into v_existing from public.referral_redemptions where referred_id = v_uid;
  if found then
    -- already referred (idempotent)
    return query select false, v_referrer, v_campaign.key;
    return;
  end if;

  insert into public.referral_redemptions(campaign_id, referrer_id, referred_id, code, status)
  values (v_campaign.id, v_referrer, v_uid, v_code, 'pending');

  perform public.notify_user(v_uid, 'referral_applied', 'Referral applied', 'Referral code applied successfully.', jsonb_build_object('code', v_code));
  perform public.notify_user(v_referrer, 'referral_pending', 'New referral', 'A new user joined with your referral code.', jsonb_build_object('code', v_code, 'referred_id', v_uid));

  return query select true, v_referrer, v_campaign.key;
end;
$$;


ALTER FUNCTION public.referral_apply_code(p_code text) OWNER TO postgres;

--
-- TOC entry 973 (class 1255 OID 41819)
-- Name: referral_apply_rewards_for_ride(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.referral_apply_rewards_for_ride(p_ride_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'extensions', 'pg_temp'
    AS $$
declare
  r record;
  inv record;
  cfg record;
  v_rides int;
begin
  select * into r from public.rides where id = p_ride_id;
  if not found then
    return;
  end if;

  -- Find pending invite for rider
  select * into inv
  from public.referral_invites
  where referred_user_id = r.rider_id and status = 'pending'
  for update;

  if not found then
    return;
  end if;

  select * into cfg from public.referral_settings where id = 1;

  -- Check completed rides count for the referred user
  select count(*) into v_rides
  from public.rides
  where rider_id = r.rider_id and status = 'completed';

  if v_rides < cfg.min_completed_rides then
    return;
  end if;

  update public.referral_invites
  set status = 'qualified', qualified_at = now()
  where id = inv.id and status = 'pending';

  -- Credit referee
  insert into public.wallet_accounts(user_id) values (r.rider_id)
  on conflict (user_id) do nothing;

  update public.wallet_accounts
  set balance_iqd = balance_iqd + cfg.reward_referee_iqd,
      updated_at = now()
  where user_id = r.rider_id;

  insert into public.wallet_entries (user_id, delta_iqd, kind, memo, source_type, source_id, metadata, idempotency_key)
  values (
    r.rider_id, cfg.reward_referee_iqd, 'adjustment', 'Referral reward', 'referral', inv.id,
    jsonb_build_object('invite_id', inv.id, 'ride_id', p_ride_id, 'role', 'referee'),
    'referral:' || inv.id::text || ':referee'
  )
  on conflict (user_id, idempotency_key) where idempotency_key is not null do nothing;

  -- Credit referrer
  insert into public.wallet_accounts(user_id) values (inv.referrer_id)
  on conflict (user_id) do nothing;

  update public.wallet_accounts
  set balance_iqd = balance_iqd + cfg.reward_referrer_iqd,
      updated_at = now()
  where user_id = inv.referrer_id;

  insert into public.wallet_entries (user_id, delta_iqd, kind, memo, source_type, source_id, metadata, idempotency_key)
  values (
    inv.referrer_id, cfg.reward_referrer_iqd, 'adjustment', 'Referral reward', 'referral', inv.id,
    jsonb_build_object('invite_id', inv.id, 'ride_id', p_ride_id, 'role', 'referrer'),
    'referral:' || inv.id::text || ':referrer'
  )
  on conflict (user_id, idempotency_key) where idempotency_key is not null do nothing;

  update public.referral_invites
  set status = 'rewarded', rewarded_at = now()
  where id = inv.id and status in ('pending','qualified');

  perform public.notify_user(r.rider_id, 'referral_reward', 'Reward unlocked', 'Your referral reward has been added to your wallet', jsonb_build_object('amount_iqd', cfg.reward_referee_iqd, 'invite_id', inv.id));
  perform public.notify_user(inv.referrer_id, 'referral_reward', 'Reward unlocked', 'Your referral reward has been added to your wallet', jsonb_build_object('amount_iqd', cfg.reward_referrer_iqd, 'invite_id', inv.id));
end;
$$;


ALTER FUNCTION public.referral_apply_rewards_for_ride(p_ride_id uuid) OWNER TO postgres;

--
-- TOC entry 655 (class 1255 OID 41817)
-- Name: referral_claim(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.referral_claim(p_code text) RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'extensions', 'pg_temp'
    AS $$
declare
  v_uid uuid;
  v_referrer uuid;
  v_exists uuid;
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'not_authenticated';
  end if;

  select user_id into v_referrer
  from public.referral_codes
  where code = upper(p_code);

  if not found then
    raise exception 'invalid_code';
  end if;

  if v_referrer = v_uid then
    raise exception 'cannot_self_refer';
  end if;

  select id into v_exists
  from public.referral_invites
  where referred_user_id = v_uid;

  if found then
    raise exception 'already_claimed';
  end if;

  insert into public.referral_invites (referrer_id, referred_user_id, code_used, status)
  values (v_referrer, v_uid, upper(p_code), 'pending');

  perform public.notify_user(v_referrer, 'referral_new', 'New referral', 'A new user joined using your code', jsonb_build_object('referred_user_id', v_uid));
  perform public.notify_user(v_uid, 'referral_applied', 'Referral applied', 'Complete your first ride to unlock your reward', jsonb_build_object('referrer_id', v_referrer));

  return jsonb_build_object('ok', true, 'referrer_id', v_referrer);
end;
$$;


ALTER FUNCTION public.referral_claim(p_code text) OWNER TO postgres;

--
-- TOC entry 1219 (class 1255 OID 41815)
-- Name: referral_code_init(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.referral_code_init() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'extensions', 'pg_temp'
    AS $$
begin
  insert into public.referral_codes (user_id, code)
  values (new.id, public.referral_generate_code())
  on conflict (user_id) do nothing;
  return new;
end;
$$;


ALTER FUNCTION public.referral_code_init() OWNER TO postgres;

--
-- TOC entry 1010 (class 1255 OID 41814)
-- Name: referral_generate_code(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.referral_generate_code() RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'extensions', 'pg_temp'
    AS $$
declare
  v text;
begin
  loop
    v := upper(regexp_replace(substr(encode(gen_random_bytes(12),'base64'), 1, 12), '[^A-Z0-9]', '', 'g'));
    v := substr(v, 1, 8);
    exit when length(v) = 8 and not exists (select 1 from public.referral_codes where code = v);
  end loop;
  return v;
end;
$$;


ALTER FUNCTION public.referral_generate_code() OWNER TO postgres;

--
-- TOC entry 828 (class 1255 OID 41820)
-- Name: referral_on_ride_completed(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.referral_on_ride_completed() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'extensions', 'pg_temp'
    AS $$
begin
  if (tg_op = 'UPDATE') and new.status = 'completed' and old.status is distinct from new.status then
    perform public.referral_apply_rewards_for_ride(new.id);
  end if;
  return new;
end;
$$;


ALTER FUNCTION public.referral_on_ride_completed() OWNER TO postgres;

--
-- TOC entry 718 (class 1255 OID 41818)
-- Name: referral_status(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.referral_status() RETURNS jsonb
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'extensions', 'pg_temp'
    AS $$
declare
  v_uid uuid;
  v_code text;
  v_pending int;
  v_rewarded int;
  v_earned bigint;
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'not_authenticated';
  end if;

  select code into v_code
  from public.referral_codes
  where user_id = v_uid;

  select count(*) into v_pending
  from public.referral_invites
  where referrer_id = v_uid and status in ('pending','qualified');

  select count(*) into v_rewarded
  from public.referral_invites
  where referrer_id = v_uid and status = 'rewarded';

  select coalesce(sum(delta_iqd),0) into v_earned
  from public.wallet_entries
  where user_id = v_uid and source_type = 'referral';

  return jsonb_build_object(
    'code', v_code,
    'pending', v_pending,
    'rewarded', v_rewarded,
    'earned_iqd', v_earned
  );
end;
$$;


ALTER FUNCTION public.referral_status() OWNER TO postgres;

--
-- TOC entry 737 (class 1255 OID 40679)
-- Name: refresh_driver_rank_snapshots(text, date, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.refresh_driver_rank_snapshots(p_period text, p_period_start date, p_limit integer DEFAULT 200) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
declare
  v_period text := lower(coalesce(p_period, 'weekly'));
  v_start date := p_period_start;
  v_end date;
  v_limit integer := greatest(1, least(coalesce(p_limit, 200), 1000));
begin
  if v_period not in ('weekly','monthly') then
    raise exception 'invalid_period';
  end if;

  if v_start is null then
    raise exception 'period_start_required';
  end if;

  if v_period = 'weekly' then
    v_end := (v_start + interval '7 days')::date;
  else
    v_end := (date_trunc('month', v_start::timestamptz) + interval '1 month')::date;
  end if;

  delete from public.driver_rank_snapshots
  where period = v_period and period_start = v_start;

  insert into public.driver_rank_snapshots(period, period_start, period_end, driver_id, rank, score_iqd, rides_completed)
  select
    v_period,
    v_start,
    v_end,
    s.driver_id,
    row_number() over (order by s.earnings_iqd desc, s.rides_completed desc, s.driver_id)::int as rank,
    s.earnings_iqd,
    s.rides_completed
  from (
    select dsd.driver_id,
           sum(dsd.earnings_iqd)::bigint as earnings_iqd,
           sum(dsd.rides_completed)::int as rides_completed
    from public.driver_stats_daily dsd
    where dsd.day >= v_start and dsd.day < v_end
    group by dsd.driver_id
  ) s
  order by s.earnings_iqd desc, s.rides_completed desc, s.driver_id
  limit v_limit;
end;
$$;


ALTER FUNCTION public.refresh_driver_rank_snapshots(p_period text, p_period_start date, p_limit integer) OWNER TO postgres;

--
-- TOC entry 1028 (class 1255 OID 40987)
-- Name: revoke_trip_share_tokens_on_ride_end(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.revoke_trip_share_tokens_on_ride_end() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
begin
  if new.status in ('completed', 'canceled') then
    update public.trip_share_tokens
       set revoked_at = now()
     where ride_id = new.id
       and revoked_at is null;
  end if;
  return new;
end;
$$;


ALTER FUNCTION public.revoke_trip_share_tokens_on_ride_end() OWNER TO postgres;

--
-- TOC entry 1227 (class 1255 OID 41774)
-- Name: ride_chat_get_or_create_thread(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ride_chat_get_or_create_thread(p_ride_id uuid) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'extensions', 'pg_temp'
    AS $$
declare
  v_uid uuid;
  r record;
  v_thread uuid;
begin
  v_uid := auth.uid();
  if v_uid is null then
    raise exception 'not_authenticated';
  end if;

  select id, rider_id, driver_id into r
  from public.rides
  where id = p_ride_id
    and (rider_id = v_uid or driver_id = v_uid);

  if not found then
    raise exception 'not_a_participant';
  end if;

  insert into public.ride_chat_threads (ride_id, rider_id, driver_id)
  values (p_ride_id, r.rider_id, r.driver_id)
  on conflict (ride_id) do update
    set updated_at = now()
  returning id into v_thread;

  return v_thread;
end;
$$;


ALTER FUNCTION public.ride_chat_get_or_create_thread(p_ride_id uuid) OWNER TO postgres;

--
-- TOC entry 1057 (class 1255 OID 41775)
-- Name: ride_chat_notify_on_message(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ride_chat_notify_on_message() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'public', 'extensions', 'pg_temp'
    AS $$
declare
  t record;
  v_to uuid;
begin
  select ride_id, rider_id, driver_id into t
  from public.ride_chat_threads
  where id = new.thread_id;

  if not found then
    return new;
  end if;

  if new.sender_id = t.rider_id then
    v_to := t.driver_id;
  else
    v_to := t.rider_id;
  end if;

  perform public.notify_user(
    v_to,
    'chat_message',
    'New message',
    case when new.kind = 'text' then left(coalesce(new.body,''), 140) else 'Attachment' end,
    jsonb_build_object('ride_id', t.ride_id, 'thread_id', new.thread_id, 'message_id', new.id)
  );

  return new;
end;
$$;


ALTER FUNCTION public.ride_chat_notify_on_message() OWNER TO postgres;

--
-- TOC entry 1292 (class 1255 OID 39787)
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
-- TOC entry 1050 (class 1255 OID 39788)
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
-- TOC entry 1263 (class 1255 OID 39789)
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
-- TOC entry 771 (class 1255 OID 39790)
-- Name: ride_requests_set_status_timestamps(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.ride_requests_set_status_timestamps() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog'
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
-- TOC entry 648 (class 1255 OID 39791)
-- Name: set_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog'
    AS $$
begin
  new.updated_at = now();
  return new;
end;
$$;


ALTER FUNCTION public.set_updated_at() OWNER TO postgres;

--
-- TOC entry 971 (class 1255 OID 39792)
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
-- TOC entry 820 (class 1255 OID 39793)
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
-- TOC entry 703 (class 1255 OID 40888)
-- Name: support_ticket_touch_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.support_ticket_touch_updated_at() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
begin
  update public.support_tickets
     set updated_at = now()
   where id = new.ticket_id;
  return new;
end;
$$;


ALTER FUNCTION public.support_ticket_touch_updated_at() OWNER TO postgres;

--
-- TOC entry 776 (class 1255 OID 41428)
-- Name: sync_profile_kyc_from_submission(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sync_profile_kyc_from_submission() RETURNS trigger
    LANGUAGE plpgsql
    SET search_path TO 'pg_catalog, public, auth, extensions'
    AS $$
declare
  v_user uuid;
  v_new public.kyc_status;
begin
  v_user := coalesce(new.profile_id, new.user_id);

  if new.status in ('submitted','in_review') then
    v_new := 'pending';
  elsif new.status = 'approved' then
    v_new := 'verified';
  elsif new.status in ('rejected','resubmit_required') then
    v_new := 'rejected';
  else
    v_new := 'unverified';
  end if;

  insert into public.profile_kyc (user_id, status, updated_at)
  values (v_user, v_new, now())
  on conflict (user_id) do update
    set status = excluded.status,
        updated_at = excluded.updated_at;

  return new;
end;
$$;


ALTER FUNCTION public.sync_profile_kyc_from_submission() OWNER TO postgres;

--
-- TOC entry 938 (class 1255 OID 40579)
-- Name: sync_public_profile(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.sync_public_profile() RETURNS trigger
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
begin
  insert into public.public_profiles(id, display_name, rating_avg, rating_count, created_at, updated_at)
  values (
    new.id,
    new.display_name,
    coalesce(new.rating_avg, 5.00),
    coalesce(new.rating_count, 0),
    coalesce(new.created_at, now()),
    now()
  )
  on conflict (id) do update
    set display_name = excluded.display_name,
        rating_avg = excluded.rating_avg,
        rating_count = excluded.rating_count,
        updated_at = now();

  return new;
end;
$$;


ALTER FUNCTION public.sync_public_profile() OWNER TO postgres;

--
-- TOC entry 412 (class 1259 OID 39794)
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
    wallet_hold_id uuid,
    product_code text DEFAULT 'standard'::text NOT NULL
);

ALTER TABLE ONLY public.rides REPLICA IDENTITY FULL;


ALTER TABLE public.rides OWNER TO postgres;

--
-- TOC entry 501 (class 1255 OID 39806)
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
    -- new: post-completion processing (stats/referrals/achievements)
    perform public.on_ride_completed_v1(r.id);
  elsif p_to_status = 'canceled' then
    perform public.wallet_release_ride_hold(r.id);
  end if;

  return r;
end;
$$;


ALTER FUNCTION public.transition_ride_v2(p_ride_id uuid, p_to_status public.ride_status, p_actor_id uuid, p_actor_type public.ride_actor_type, p_expected_version integer) OWNER TO postgres;

--
-- TOC entry 1391 (class 1255 OID 39807)
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
-- TOC entry 595 (class 1255 OID 40720)
-- Name: update_driver_achievements(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.update_driver_achievements(p_driver_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
declare
  v record;
  v_cnt bigint;
begin
  select completed_rides into v_cnt
  from public.driver_counters
  where driver_id = p_driver_id;

  if v_cnt is null then
    v_cnt := 0;
  end if;

  for v in
    select a.id, a.target
    from public.achievements a
    where a.active and a.role = 'driver' and a.metric = 'completed_rides'
    order by a.sort_order
  loop
    insert into public.achievement_progress(user_id, achievement_id, progress, completed_at, updated_at)
    values (
      p_driver_id,
      v.id,
      least(v_cnt, v.target),
      case when v_cnt >= v.target then now() else null end,
      now()
    )
    on conflict (user_id, achievement_id) do update
      set progress = greatest(achievement_progress.progress, least(v_cnt, v.target)),
          completed_at = case
            when achievement_progress.completed_at is not null then achievement_progress.completed_at
            when v_cnt >= v.target then now()
            else null
          end,
          updated_at = now();
  end loop;
end;
$$;


ALTER FUNCTION public.update_driver_achievements(p_driver_id uuid) OWNER TO postgres;

--
-- TOC entry 1246 (class 1255 OID 39808)
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
-- TOC entry 671 (class 1255 OID 40606)
-- Name: upsert_device_token(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.upsert_device_token(p_token text, p_platform text DEFAULT 'android'::text) RETURNS bigint
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, public'
    AS $$
declare
  v_user uuid := (select auth.uid());
  v_id bigint;
  v_platform text := lower(coalesce(nullif(trim(p_platform), ''), 'android'));
  v_token text := trim(coalesce(p_token, ''));
begin
  if v_user is null then
    raise exception 'unauthorized';
  end if;

  if length(v_token) < 10 then
    raise exception 'invalid_token';
  end if;

  if v_platform not in ('android','ios','web') then
    raise exception 'invalid_platform';
  end if;

  insert into public.device_tokens(user_id, token, platform, created_at, last_seen_at)
  values (v_user, v_token, v_platform, now(), now())
  on conflict (token) do update
    set user_id = excluded.user_id,
        platform = excluded.platform,
        last_seen_at = now(),
        disabled_at = null
  returning id into v_id;

  return v_id;
end;
$$;


ALTER FUNCTION public.upsert_device_token(p_token text, p_platform text) OWNER TO postgres;

--
-- TOC entry 1059 (class 1255 OID 39809)
-- Name: user_notifications_mark_all_read(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.user_notifications_mark_all_read() RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
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
-- TOC entry 585 (class 1255 OID 39810)
-- Name: user_notifications_mark_read(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.user_notifications_mark_read(p_notification_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
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
-- TOC entry 1111 (class 1255 OID 39811)
-- Name: wallet_cancel_withdraw(uuid); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.wallet_cancel_withdraw(p_request_id uuid) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
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
-- TOC entry 1141 (class 1255 OID 39812)
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
-- TOC entry 413 (class 1259 OID 39813)
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

ALTER TABLE ONLY public.topup_intents REPLICA IDENTITY FULL;


ALTER TABLE public.topup_intents OWNER TO postgres;

--
-- TOC entry 867 (class 1255 OID 39826)
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
-- TOC entry 1013 (class 1255 OID 39827)
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
-- TOC entry 414 (class 1259 OID 39828)
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
-- TOC entry 909 (class 1255 OID 39837)
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
-- TOC entry 845 (class 1255 OID 39838)
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
-- TOC entry 821 (class 1255 OID 39839)
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
-- TOC entry 1215 (class 1255 OID 39840)
-- Name: wallet_request_withdraw(bigint, public.withdraw_payout_kind, jsonb, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.wallet_request_withdraw(p_amount_iqd bigint, p_payout_kind public.withdraw_payout_kind, p_destination jsonb DEFAULT '{}'::jsonb, p_idempotency_key text DEFAULT NULL::text) RETURNS uuid
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
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
-- TOC entry 843 (class 1255 OID 39842)
-- Name: wallet_validate_withdraw_destination(public.withdraw_payout_kind, jsonb); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.wallet_validate_withdraw_destination(p_payout_kind public.withdraw_payout_kind, p_destination jsonb) RETURNS void
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path TO 'pg_catalog, extensions'
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
-- TOC entry 502 (class 1255 OID 17157)
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
-- TOC entry 1328 (class 1255 OID 17236)
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
-- TOC entry 676 (class 1255 OID 17119)
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
-- TOC entry 1330 (class 1255 OID 17114)
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
-- TOC entry 1315 (class 1255 OID 17165)
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
-- TOC entry 537 (class 1255 OID 17176)
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
-- TOC entry 1174 (class 1255 OID 17113)
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
-- TOC entry 1255 (class 1255 OID 17235)
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
-- TOC entry 811 (class 1255 OID 17111)
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
-- TOC entry 559 (class 1255 OID 17146)
-- Name: to_regrole(text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.to_regrole(role_name text) RETURNS regrole
    LANGUAGE sql IMMUTABLE
    AS $$ select role_name::regrole $$;


ALTER FUNCTION realtime.to_regrole(role_name text) OWNER TO supabase_admin;

--
-- TOC entry 804 (class 1255 OID 17229)
-- Name: topic(); Type: FUNCTION; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE FUNCTION realtime.topic() RETURNS text
    LANGUAGE sql STABLE
    AS $$
select nullif(current_setting('realtime.topic', true), '')::text;
$$;


ALTER FUNCTION realtime.topic() OWNER TO supabase_realtime_admin;

--
-- TOC entry 1247 (class 1255 OID 17394)
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
-- TOC entry 687 (class 1255 OID 17320)
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
-- TOC entry 896 (class 1255 OID 17435)
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
-- TOC entry 868 (class 1255 OID 17395)
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
-- TOC entry 1029 (class 1255 OID 17398)
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
-- TOC entry 1048 (class 1255 OID 17413)
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
-- TOC entry 1311 (class 1255 OID 17294)
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
-- TOC entry 928 (class 1255 OID 17293)
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
-- TOC entry 1099 (class 1255 OID 17292)
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
-- TOC entry 538 (class 1255 OID 17376)
-- Name: get_level(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_level(name text) RETURNS integer
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
SELECT array_length(string_to_array("name", '/'), 1);
$$;


ALTER FUNCTION storage.get_level(name text) OWNER TO supabase_storage_admin;

--
-- TOC entry 1011 (class 1255 OID 17392)
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
-- TOC entry 1373 (class 1255 OID 17393)
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
-- TOC entry 1218 (class 1255 OID 17411)
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
-- TOC entry 836 (class 1255 OID 17359)
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
-- TOC entry 1044 (class 1255 OID 17322)
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
-- TOC entry 1363 (class 1255 OID 17434)
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
-- TOC entry 1284 (class 1255 OID 17436)
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
-- TOC entry 944 (class 1255 OID 17397)
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
-- TOC entry 872 (class 1255 OID 17437)
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
-- TOC entry 1112 (class 1255 OID 17442)
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
-- TOC entry 681 (class 1255 OID 17412)
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
-- TOC entry 669 (class 1255 OID 17375)
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
-- TOC entry 728 (class 1255 OID 17438)
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
-- TOC entry 1192 (class 1255 OID 17396)
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
-- TOC entry 545 (class 1255 OID 17309)
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
-- TOC entry 1153 (class 1255 OID 17409)
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
-- TOC entry 543 (class 1255 OID 17408)
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
-- TOC entry 813 (class 1255 OID 17433)
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
-- TOC entry 558 (class 1255 OID 17310)
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
-- TOC entry 355 (class 1259 OID 16525)
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
-- TOC entry 7448 (class 0 OID 0)
-- Dependencies: 355
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- TOC entry 369 (class 1259 OID 16883)
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
-- TOC entry 7450 (class 0 OID 0)
-- Dependencies: 369
-- Name: TABLE flow_state; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.flow_state IS 'stores metadata for pkce logins';


--
-- TOC entry 360 (class 1259 OID 16681)
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
-- TOC entry 7452 (class 0 OID 0)
-- Dependencies: 360
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- TOC entry 7453 (class 0 OID 0)
-- Dependencies: 360
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- TOC entry 354 (class 1259 OID 16518)
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
-- TOC entry 7455 (class 0 OID 0)
-- Dependencies: 354
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- TOC entry 364 (class 1259 OID 16770)
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
-- TOC entry 7457 (class 0 OID 0)
-- Dependencies: 364
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- TOC entry 363 (class 1259 OID 16758)
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
-- TOC entry 7459 (class 0 OID 0)
-- Dependencies: 363
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- TOC entry 362 (class 1259 OID 16745)
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
-- TOC entry 7461 (class 0 OID 0)
-- Dependencies: 362
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- TOC entry 7462 (class 0 OID 0)
-- Dependencies: 362
-- Name: COLUMN mfa_factors.last_webauthn_challenge_data; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.mfa_factors.last_webauthn_challenge_data IS 'Stores the latest WebAuthn challenge data including attestation/assertion for customer verification';


--
-- TOC entry 372 (class 1259 OID 16995)
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
-- TOC entry 374 (class 1259 OID 17068)
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
-- TOC entry 7465 (class 0 OID 0)
-- Dependencies: 374
-- Name: TABLE oauth_client_states; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.oauth_client_states IS 'Stores OAuth states for third-party provider authentication flows where Supabase acts as the OAuth client.';


--
-- TOC entry 371 (class 1259 OID 16965)
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
-- TOC entry 373 (class 1259 OID 17028)
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
-- TOC entry 370 (class 1259 OID 16933)
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
-- TOC entry 353 (class 1259 OID 16507)
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
-- TOC entry 7470 (class 0 OID 0)
-- Dependencies: 353
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- TOC entry 352 (class 1259 OID 16506)
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
-- TOC entry 7472 (class 0 OID 0)
-- Dependencies: 352
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: supabase_auth_admin
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- TOC entry 367 (class 1259 OID 16812)
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
-- TOC entry 7474 (class 0 OID 0)
-- Dependencies: 367
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- TOC entry 368 (class 1259 OID 16830)
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
-- TOC entry 7476 (class 0 OID 0)
-- Dependencies: 368
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- TOC entry 356 (class 1259 OID 16533)
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


ALTER TABLE auth.schema_migrations OWNER TO supabase_auth_admin;

--
-- TOC entry 7478 (class 0 OID 0)
-- Dependencies: 356
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- TOC entry 361 (class 1259 OID 16711)
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
-- TOC entry 7480 (class 0 OID 0)
-- Dependencies: 361
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- TOC entry 7481 (class 0 OID 0)
-- Dependencies: 361
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- TOC entry 7482 (class 0 OID 0)
-- Dependencies: 361
-- Name: COLUMN sessions.refresh_token_hmac_key; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sessions.refresh_token_hmac_key IS 'Holds a HMAC-SHA256 key used to sign refresh tokens for this session.';


--
-- TOC entry 7483 (class 0 OID 0)
-- Dependencies: 361
-- Name: COLUMN sessions.refresh_token_counter; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sessions.refresh_token_counter IS 'Holds the ID (counter) of the last issued refresh token.';


--
-- TOC entry 366 (class 1259 OID 16797)
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
-- TOC entry 7485 (class 0 OID 0)
-- Dependencies: 366
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- TOC entry 365 (class 1259 OID 16788)
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
-- TOC entry 7487 (class 0 OID 0)
-- Dependencies: 365
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- TOC entry 7488 (class 0 OID 0)
-- Dependencies: 365
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- TOC entry 351 (class 1259 OID 16495)
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
-- TOC entry 7490 (class 0 OID 0)
-- Dependencies: 351
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- TOC entry 7491 (class 0 OID 0)
-- Dependencies: 351
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- TOC entry 451 (class 1259 OID 40696)
-- Name: achievement_progress; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.achievement_progress (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    achievement_id uuid NOT NULL,
    progress bigint DEFAULT 0 NOT NULL,
    completed_at timestamp with time zone,
    claimed_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.achievement_progress OWNER TO postgres;

--
-- TOC entry 450 (class 1259 OID 40681)
-- Name: achievements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.achievements (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    key text NOT NULL,
    role text NOT NULL,
    metric text DEFAULT 'completed_rides'::text NOT NULL,
    target bigint NOT NULL,
    title text NOT NULL,
    description text,
    reward_iqd integer DEFAULT 0 NOT NULL,
    badge_icon text,
    sort_order integer DEFAULT 0 NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT achievements_role_check CHECK ((role = ANY (ARRAY['driver'::text, 'rider'::text])))
);


ALTER TABLE public.achievements OWNER TO postgres;

--
-- TOC entry 415 (class 1259 OID 39843)
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
-- TOC entry 416 (class 1259 OID 39849)
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
-- TOC entry 444 (class 1259 OID 40583)
-- Name: device_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.device_tokens (
    id bigint NOT NULL,
    user_id uuid NOT NULL,
    token text NOT NULL,
    platform text DEFAULT 'android'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    last_seen_at timestamp with time zone DEFAULT now() NOT NULL,
    disabled_at timestamp with time zone,
    enabled boolean DEFAULT true NOT NULL
);


ALTER TABLE public.device_tokens OWNER TO postgres;

--
-- TOC entry 443 (class 1259 OID 40582)
-- Name: device_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.device_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.device_tokens_id_seq OWNER TO postgres;

--
-- TOC entry 7502 (class 0 OID 0)
-- Dependencies: 443
-- Name: device_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.device_tokens_id_seq OWNED BY public.device_tokens.id;


--
-- TOC entry 447 (class 1259 OID 40633)
-- Name: driver_counters; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.driver_counters (
    driver_id uuid NOT NULL,
    completed_rides bigint DEFAULT 0 NOT NULL,
    earnings_iqd bigint DEFAULT 0 NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.driver_counters OWNER TO postgres;

--
-- TOC entry 475 (class 1259 OID 41825)
-- Name: driver_leaderboard_daily; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.driver_leaderboard_daily (
    day date NOT NULL,
    driver_id uuid NOT NULL,
    trips_count integer DEFAULT 0 NOT NULL,
    earnings_iqd bigint DEFAULT 0 NOT NULL,
    score numeric DEFAULT 0 NOT NULL,
    rank integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.driver_leaderboard_daily OWNER TO postgres;

--
-- TOC entry 417 (class 1259 OID 39858)
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

ALTER TABLE ONLY public.driver_locations REPLICA IDENTITY FULL;


ALTER TABLE public.driver_locations OWNER TO postgres;

--
-- TOC entry 449 (class 1259 OID 40660)
-- Name: driver_rank_snapshots; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.driver_rank_snapshots (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    period text NOT NULL,
    period_start date NOT NULL,
    period_end date NOT NULL,
    driver_id uuid NOT NULL,
    rank integer NOT NULL,
    score_iqd bigint NOT NULL,
    rides_completed integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    score numeric(12,2),
    earnings_iqd bigint,
    CONSTRAINT driver_rank_snapshots_period_check CHECK ((period = ANY (ARRAY['weekly'::text, 'monthly'::text])))
);


ALTER TABLE public.driver_rank_snapshots OWNER TO postgres;

--
-- TOC entry 448 (class 1259 OID 40646)
-- Name: driver_stats_daily; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.driver_stats_daily (
    driver_id uuid NOT NULL,
    day date NOT NULL,
    rides_completed integer DEFAULT 0 NOT NULL,
    earnings_iqd bigint DEFAULT 0 NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    trips_count integer,
    created_at timestamp with time zone
);

ALTER TABLE ONLY public.driver_stats_daily REPLICA IDENTITY FULL;


ALTER TABLE public.driver_stats_daily OWNER TO postgres;

--
-- TOC entry 418 (class 1259 OID 39868)
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
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    vehicle_type text,
    capacity integer,
    is_active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.driver_vehicles OWNER TO postgres;

--
-- TOC entry 419 (class 1259 OID 39876)
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
-- TOC entry 466 (class 1259 OID 41373)
-- Name: kyc_document_types; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kyc_document_types (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    key text NOT NULL,
    title text NOT NULL,
    description text,
    role_required text NOT NULL,
    is_required boolean DEFAULT true NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    enabled boolean DEFAULT true NOT NULL,
    country_code text,
    allowed_mime text[] DEFAULT ARRAY['image/jpeg'::text, 'image/png'::text, 'application/pdf'::text] NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT kyc_document_types_role_required_check CHECK ((role_required = ANY (ARRAY['rider'::text, 'driver'::text, 'both'::text])))
);


ALTER TABLE public.kyc_document_types OWNER TO postgres;

--
-- TOC entry 464 (class 1259 OID 41012)
-- Name: kyc_documents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kyc_documents (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    submission_id uuid NOT NULL,
    user_id uuid NOT NULL,
    doc_type text NOT NULL,
    storage_bucket text DEFAULT 'kyc-documents'::text NOT NULL,
    storage_object_key text NOT NULL,
    mime_type text,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    profile_id uuid,
    document_type_id uuid,
    object_key text,
    status text,
    rejection_reason text,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.kyc_documents OWNER TO postgres;

--
-- TOC entry 467 (class 1259 OID 41392)
-- Name: kyc_liveness_sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kyc_liveness_sessions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    submission_id uuid NOT NULL,
    profile_id uuid NOT NULL,
    provider text DEFAULT 'internal'::text NOT NULL,
    status text DEFAULT 'started'::text NOT NULL,
    provider_ref text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT kyc_liveness_sessions_status_check CHECK ((status = ANY (ARRAY['started'::text, 'passed'::text, 'failed'::text, 'expired'::text])))
);


ALTER TABLE public.kyc_liveness_sessions OWNER TO postgres;

--
-- TOC entry 463 (class 1259 OID 40989)
-- Name: kyc_submissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.kyc_submissions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    status text DEFAULT 'draft'::text NOT NULL,
    decision_note text,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    submitted_at timestamp with time zone,
    reviewed_at timestamp with time zone,
    reviewer_id uuid,
    profile_id uuid,
    role_context text,
    role text,
    notes text,
    reviewer_note text
);


ALTER TABLE public.kyc_submissions OWNER TO postgres;

--
-- TOC entry 446 (class 1259 OID 40608)
-- Name: notification_outbox; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notification_outbox (
    id bigint NOT NULL,
    notification_id uuid NOT NULL,
    user_id uuid NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    attempts integer DEFAULT 0 NOT NULL,
    last_attempt_at timestamp with time zone,
    last_error text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT notification_outbox_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'processing'::text, 'sent'::text, 'failed'::text, 'skipped'::text])))
);


ALTER TABLE public.notification_outbox OWNER TO postgres;

--
-- TOC entry 445 (class 1259 OID 40607)
-- Name: notification_outbox_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notification_outbox_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notification_outbox_id_seq OWNER TO postgres;

--
-- TOC entry 7516 (class 0 OID 0)
-- Dependencies: 445
-- Name: notification_outbox_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notification_outbox_id_seq OWNED BY public.notification_outbox.id;


--
-- TOC entry 420 (class 1259 OID 39887)
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
-- TOC entry 421 (class 1259 OID 39899)
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
-- TOC entry 422 (class 1259 OID 39909)
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

ALTER TABLE ONLY public.payments REPLICA IDENTITY FULL;


ALTER TABLE public.payments OWNER TO postgres;

--
-- TOC entry 423 (class 1259 OID 39919)
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
-- TOC entry 424 (class 1259 OID 39933)
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
-- TOC entry 425 (class 1259 OID 39940)
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
    is_admin boolean DEFAULT false NOT NULL,
    avatar_object_key text,
    locale text DEFAULT 'en'::text NOT NULL,
    active_role text DEFAULT 'rider'::text NOT NULL,
    CONSTRAINT profiles_active_role_check CHECK ((active_role = ANY (ARRAY['rider'::text, 'driver'::text])))
);


ALTER TABLE public.profiles OWNER TO postgres;

--
-- TOC entry 426 (class 1259 OID 39950)
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
-- TOC entry 427 (class 1259 OID 39957)
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
-- TOC entry 7525 (class 0 OID 0)
-- Dependencies: 427
-- Name: provider_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.provider_events_id_seq OWNED BY public.provider_events.id;


--
-- TOC entry 442 (class 1259 OID 40563)
-- Name: public_profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.public_profiles (
    id uuid NOT NULL,
    display_name text,
    rating_avg numeric(3,2) DEFAULT 5.00 NOT NULL,
    rating_count integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

ALTER TABLE ONLY public.public_profiles REPLICA IDENTITY FULL;


ALTER TABLE public.public_profiles OWNER TO postgres;

--
-- TOC entry 452 (class 1259 OID 40722)
-- Name: referral_campaigns; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.referral_campaigns (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    key text NOT NULL,
    referrer_reward_iqd integer DEFAULT 0 NOT NULL,
    referred_reward_iqd integer DEFAULT 0 NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.referral_campaigns OWNER TO postgres;

--
-- TOC entry 453 (class 1259 OID 40736)
-- Name: referral_codes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.referral_codes (
    code text NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.referral_codes OWNER TO postgres;

--
-- TOC entry 474 (class 1259 OID 41788)
-- Name: referral_invites; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.referral_invites (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    referrer_id uuid NOT NULL,
    referred_user_id uuid NOT NULL,
    code_used text NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    qualified_at timestamp with time zone,
    rewarded_at timestamp with time zone,
    CONSTRAINT referral_invites_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'qualified'::text, 'rewarded'::text, 'canceled'::text])))
);


ALTER TABLE public.referral_invites OWNER TO postgres;

--
-- TOC entry 454 (class 1259 OID 40752)
-- Name: referral_redemptions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.referral_redemptions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    campaign_id uuid NOT NULL,
    referrer_id uuid NOT NULL,
    referred_id uuid NOT NULL,
    code text NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    earned_at timestamp with time zone,
    rewarded_at timestamp with time zone,
    ride_id uuid,
    CONSTRAINT referral_redemptions_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'rewarded'::text, 'invalid'::text])))
);


ALTER TABLE public.referral_redemptions OWNER TO postgres;

--
-- TOC entry 473 (class 1259 OID 41777)
-- Name: referral_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.referral_settings (
    id integer DEFAULT 1 NOT NULL,
    reward_referrer_iqd integer DEFAULT 2000 NOT NULL,
    reward_referee_iqd integer DEFAULT 2000 NOT NULL,
    min_completed_rides integer DEFAULT 1 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.referral_settings OWNER TO postgres;

--
-- TOC entry 459 (class 1259 OID 40890)
-- Name: ride_chat_messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ride_chat_messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ride_id uuid NOT NULL,
    sender_id uuid NOT NULL,
    message_type text DEFAULT 'text'::text NOT NULL,
    body text,
    media_object_key text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    thread_id uuid,
    kind text,
    message text,
    attachments jsonb DEFAULT '[]'::jsonb NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    attachment_bucket text,
    attachment_key text,
    metadata jsonb
);


ALTER TABLE public.ride_chat_messages OWNER TO postgres;

--
-- TOC entry 460 (class 1259 OID 40914)
-- Name: ride_chat_read_receipts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ride_chat_read_receipts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ride_id uuid NOT NULL,
    message_id uuid NOT NULL,
    reader_id uuid NOT NULL,
    read_at timestamp with time zone DEFAULT now() NOT NULL,
    thread_id uuid,
    user_id uuid,
    last_read_at timestamp with time zone,
    last_read_message_id uuid,
    updated_at timestamp with time zone
);


ALTER TABLE public.ride_chat_read_receipts OWNER TO postgres;

--
-- TOC entry 472 (class 1259 OID 41740)
-- Name: ride_chat_threads; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ride_chat_threads (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ride_id uuid NOT NULL,
    rider_id uuid NOT NULL,
    driver_id uuid NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.ride_chat_threads OWNER TO postgres;

--
-- TOC entry 461 (class 1259 OID 40939)
-- Name: ride_chat_typing; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ride_chat_typing (
    ride_id uuid NOT NULL,
    profile_id uuid NOT NULL,
    is_typing boolean DEFAULT true NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.ride_chat_typing OWNER TO postgres;

--
-- TOC entry 471 (class 1259 OID 41717)
-- Name: ride_completion_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ride_completion_log (
    ride_id uuid NOT NULL,
    processed_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.ride_completion_log OWNER TO postgres;

--
-- TOC entry 428 (class 1259 OID 39958)
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
-- TOC entry 429 (class 1259 OID 39965)
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
-- TOC entry 7539 (class 0 OID 0)
-- Dependencies: 429
-- Name: ride_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ride_events_id_seq OWNED BY public.ride_events.id;


--
-- TOC entry 430 (class 1259 OID 39966)
-- Name: ride_incidents; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ride_incidents (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ride_id uuid,
    reporter_id uuid NOT NULL,
    severity public.incident_severity DEFAULT 'low'::public.incident_severity NOT NULL,
    status public.incident_status DEFAULT 'open'::public.incident_status NOT NULL,
    category text NOT NULL,
    description text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    assigned_to uuid,
    reviewed_at timestamp with time zone,
    resolution_note text,
    reporter_type text,
    lat double precision,
    lng double precision,
    loc extensions.geography(Point,4326) GENERATED ALWAYS AS ((extensions.st_setsrid(extensions.st_makepoint(lng, lat), 4326))::extensions.geography) STORED,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL
);


ALTER TABLE public.ride_incidents OWNER TO postgres;

--
-- TOC entry 465 (class 1259 OID 41198)
-- Name: ride_products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ride_products (
    code text NOT NULL,
    name text NOT NULL,
    description text,
    capacity_min integer DEFAULT 4 NOT NULL,
    price_multiplier numeric(6,3) DEFAULT 1.000 NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.ride_products OWNER TO postgres;

--
-- TOC entry 431 (class 1259 OID 39976)
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
-- TOC entry 432 (class 1259 OID 39984)
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
-- TOC entry 433 (class 1259 OID 39995)
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
    product_code text DEFAULT 'standard'::text NOT NULL,
    CONSTRAINT ride_requests_dropoff_lat_check CHECK (((dropoff_lat >= ('-90'::integer)::double precision) AND (dropoff_lat <= (90)::double precision))),
    CONSTRAINT ride_requests_dropoff_lng_check CHECK (((dropoff_lng >= ('-180'::integer)::double precision) AND (dropoff_lng <= (180)::double precision))),
    CONSTRAINT ride_requests_pickup_lat_check CHECK (((pickup_lat >= ('-90'::integer)::double precision) AND (pickup_lat <= (90)::double precision))),
    CONSTRAINT ride_requests_pickup_lng_check CHECK (((pickup_lng >= ('-180'::integer)::double precision) AND (pickup_lng <= (180)::double precision)))
);

ALTER TABLE ONLY public.ride_requests REPLICA IDENTITY FULL;


ALTER TABLE public.ride_requests OWNER TO postgres;

--
-- TOC entry 456 (class 1259 OID 40824)
-- Name: support_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.support_categories (
    code text NOT NULL,
    title text NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    id uuid DEFAULT gen_random_uuid(),
    description text,
    enabled boolean DEFAULT true NOT NULL,
    key text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.support_categories OWNER TO postgres;

--
-- TOC entry 458 (class 1259 OID 40861)
-- Name: support_messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.support_messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ticket_id uuid NOT NULL,
    sender_id uuid NOT NULL,
    message text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    sender_profile_id uuid,
    body text,
    attachments jsonb DEFAULT '[]'::jsonb NOT NULL
);


ALTER TABLE public.support_messages OWNER TO postgres;

--
-- TOC entry 457 (class 1259 OID 40833)
-- Name: support_tickets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.support_tickets (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    created_by uuid NOT NULL,
    category_code text,
    subject text NOT NULL,
    ride_id uuid,
    status text DEFAULT 'open'::text NOT NULL,
    priority text DEFAULT 'normal'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    role_context text,
    category_id uuid,
    notes text,
    assigned_to uuid,
    resolved_at timestamp with time zone
);


ALTER TABLE public.support_tickets OWNER TO postgres;

--
-- TOC entry 468 (class 1259 OID 41439)
-- Name: support_ticket_summaries; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.support_ticket_summaries WITH (security_invoker='on') AS
 SELECT id,
    category_code,
    subject,
    status,
    priority,
    ride_id,
    created_by,
    created_at,
    updated_at,
    ( SELECT m.message
           FROM public.support_messages m
          WHERE (m.ticket_id = t.id)
          ORDER BY m.created_at DESC
         LIMIT 1) AS last_message,
    ( SELECT m.created_at
           FROM public.support_messages m
          WHERE (m.ticket_id = t.id)
          ORDER BY m.created_at DESC
         LIMIT 1) AS last_message_at,
    ( SELECT (count(*))::integer AS count
           FROM public.support_messages m
          WHERE (m.ticket_id = t.id)) AS messages_count
   FROM public.support_tickets t;


ALTER VIEW public.support_ticket_summaries OWNER TO postgres;

--
-- TOC entry 434 (class 1259 OID 40013)
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
-- TOC entry 462 (class 1259 OID 40961)
-- Name: trip_share_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.trip_share_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    ride_id uuid NOT NULL,
    created_by uuid NOT NULL,
    token text NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    revoked_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    token_hash text
);


ALTER TABLE public.trip_share_tokens OWNER TO postgres;

--
-- TOC entry 455 (class 1259 OID 40790)
-- Name: trusted_contacts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.trusted_contacts (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    name text NOT NULL,
    phone text NOT NULL,
    relationship text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.trusted_contacts OWNER TO postgres;

--
-- TOC entry 470 (class 1259 OID 41699)
-- Name: user_device_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_device_tokens (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    user_id uuid NOT NULL,
    device_id text NOT NULL,
    platform text NOT NULL,
    token text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    last_seen_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.user_device_tokens OWNER TO postgres;

--
-- TOC entry 435 (class 1259 OID 40026)
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
-- TOC entry 436 (class 1259 OID 40034)
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
-- TOC entry 437 (class 1259 OID 40041)
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
-- TOC entry 7556 (class 0 OID 0)
-- Dependencies: 437
-- Name: wallet_entries_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.wallet_entries_id_seq OWNED BY public.wallet_entries.id;


--
-- TOC entry 438 (class 1259 OID 40042)
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
-- TOC entry 439 (class 1259 OID 40053)
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
-- TOC entry 440 (class 1259 OID 40059)
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
-- TOC entry 441 (class 1259 OID 40070)
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
-- TOC entry 381 (class 1259 OID 17239)
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
-- TOC entry 405 (class 1259 OID 24067)
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
-- TOC entry 406 (class 1259 OID 24079)
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
-- TOC entry 407 (class 1259 OID 24091)
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
-- TOC entry 408 (class 1259 OID 24103)
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
-- TOC entry 409 (class 1259 OID 24562)
-- Name: messages_2026_01_25; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2026_01_25 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2026_01_25 OWNER TO supabase_admin;

--
-- TOC entry 410 (class 1259 OID 24833)
-- Name: messages_2026_01_26; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2026_01_26 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2026_01_26 OWNER TO supabase_admin;

--
-- TOC entry 469 (class 1259 OID 41444)
-- Name: messages_2026_01_27; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.messages_2026_01_27 (
    topic text NOT NULL,
    extension text NOT NULL,
    payload jsonb,
    event text,
    private boolean DEFAULT false,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    inserted_at timestamp without time zone DEFAULT now() NOT NULL,
    id uuid DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE realtime.messages_2026_01_27 OWNER TO supabase_admin;

--
-- TOC entry 375 (class 1259 OID 17076)
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


ALTER TABLE realtime.schema_migrations OWNER TO supabase_admin;

--
-- TOC entry 378 (class 1259 OID 17099)
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
-- TOC entry 377 (class 1259 OID 17098)
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
-- TOC entry 383 (class 1259 OID 17264)
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
-- TOC entry 7573 (class 0 OID 0)
-- Dependencies: 383
-- Name: COLUMN buckets.owner; Type: COMMENT; Schema: storage; Owner: supabase_storage_admin
--

COMMENT ON COLUMN storage.buckets.owner IS 'Field is deprecated, use owner_id instead';


--
-- TOC entry 388 (class 1259 OID 17422)
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
-- TOC entry 389 (class 1259 OID 17449)
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
-- TOC entry 382 (class 1259 OID 17256)
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
-- TOC entry 384 (class 1259 OID 17274)
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
-- TOC entry 7577 (class 0 OID 0)
-- Dependencies: 384
-- Name: COLUMN objects.owner; Type: COMMENT; Schema: storage; Owner: supabase_storage_admin
--

COMMENT ON COLUMN storage.objects.owner IS 'Field is deprecated, use owner_id instead';


--
-- TOC entry 387 (class 1259 OID 17377)
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
-- TOC entry 385 (class 1259 OID 17324)
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
-- TOC entry 386 (class 1259 OID 17338)
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
-- TOC entry 390 (class 1259 OID 17459)
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
-- TOC entry 4995 (class 0 OID 0)
-- Name: messages_2026_01_21; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_01_21 FOR VALUES FROM ('2026-01-21 00:00:00') TO ('2026-01-22 00:00:00');


--
-- TOC entry 4996 (class 0 OID 0)
-- Name: messages_2026_01_22; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_01_22 FOR VALUES FROM ('2026-01-22 00:00:00') TO ('2026-01-23 00:00:00');


--
-- TOC entry 4997 (class 0 OID 0)
-- Name: messages_2026_01_23; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_01_23 FOR VALUES FROM ('2026-01-23 00:00:00') TO ('2026-01-24 00:00:00');


--
-- TOC entry 4998 (class 0 OID 0)
-- Name: messages_2026_01_24; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_01_24 FOR VALUES FROM ('2026-01-24 00:00:00') TO ('2026-01-25 00:00:00');


--
-- TOC entry 4999 (class 0 OID 0)
-- Name: messages_2026_01_25; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_01_25 FOR VALUES FROM ('2026-01-25 00:00:00') TO ('2026-01-26 00:00:00');


--
-- TOC entry 5000 (class 0 OID 0)
-- Name: messages_2026_01_26; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_01_26 FOR VALUES FROM ('2026-01-26 00:00:00') TO ('2026-01-27 00:00:00');


--
-- TOC entry 5001 (class 0 OID 0)
-- Name: messages_2026_01_27; Type: TABLE ATTACH; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages ATTACH PARTITION realtime.messages_2026_01_27 FOR VALUES FROM ('2026-01-27 00:00:00') TO ('2026-01-28 00:00:00');


--
-- TOC entry 5011 (class 2604 OID 16510)
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- TOC entry 5241 (class 2604 OID 40586)
-- Name: device_tokens id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_tokens ALTER COLUMN id SET DEFAULT nextval('public.device_tokens_id_seq'::regclass);


--
-- TOC entry 5246 (class 2604 OID 40611)
-- Name: notification_outbox id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_outbox ALTER COLUMN id SET DEFAULT nextval('public.notification_outbox_id_seq'::regclass);


--
-- TOC entry 5171 (class 2604 OID 40084)
-- Name: provider_events id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.provider_events ALTER COLUMN id SET DEFAULT nextval('public.provider_events_id_seq'::regclass);


--
-- TOC entry 5174 (class 2604 OID 40085)
-- Name: ride_events id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_events ALTER COLUMN id SET DEFAULT nextval('public.ride_events_id_seq'::regclass);


--
-- TOC entry 5211 (class 2604 OID 40086)
-- Name: wallet_entries id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallet_entries ALTER COLUMN id SET DEFAULT nextval('public.wallet_entries_id_seq'::regclass);


--
-- TOC entry 5462 (class 2606 OID 16783)
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- TOC entry 5431 (class 2606 OID 16531)
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- TOC entry 5485 (class 2606 OID 16889)
-- Name: flow_state flow_state_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.flow_state
    ADD CONSTRAINT flow_state_pkey PRIMARY KEY (id);


--
-- TOC entry 5440 (class 2606 OID 16907)
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (id);


--
-- TOC entry 5442 (class 2606 OID 16917)
-- Name: identities identities_provider_id_provider_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_provider_id_provider_unique UNIQUE (provider_id, provider);


--
-- TOC entry 5429 (class 2606 OID 16524)
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- TOC entry 5464 (class 2606 OID 16776)
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- TOC entry 5460 (class 2606 OID 16764)
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- TOC entry 5452 (class 2606 OID 16957)
-- Name: mfa_factors mfa_factors_last_challenged_at_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_last_challenged_at_key UNIQUE (last_challenged_at);


--
-- TOC entry 5454 (class 2606 OID 16751)
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- TOC entry 5498 (class 2606 OID 17016)
-- Name: oauth_authorizations oauth_authorizations_authorization_code_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_code_key UNIQUE (authorization_code);


--
-- TOC entry 5500 (class 2606 OID 17014)
-- Name: oauth_authorizations oauth_authorizations_authorization_id_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_authorization_id_key UNIQUE (authorization_id);


--
-- TOC entry 5502 (class 2606 OID 17012)
-- Name: oauth_authorizations oauth_authorizations_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_pkey PRIMARY KEY (id);


--
-- TOC entry 5512 (class 2606 OID 17074)
-- Name: oauth_client_states oauth_client_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_client_states
    ADD CONSTRAINT oauth_client_states_pkey PRIMARY KEY (id);


--
-- TOC entry 5495 (class 2606 OID 16976)
-- Name: oauth_clients oauth_clients_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_clients
    ADD CONSTRAINT oauth_clients_pkey PRIMARY KEY (id);


--
-- TOC entry 5506 (class 2606 OID 17038)
-- Name: oauth_consents oauth_consents_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_pkey PRIMARY KEY (id);


--
-- TOC entry 5508 (class 2606 OID 17040)
-- Name: oauth_consents oauth_consents_user_client_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_client_unique UNIQUE (user_id, client_id);


--
-- TOC entry 5489 (class 2606 OID 16942)
-- Name: one_time_tokens one_time_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_pkey PRIMARY KEY (id);


--
-- TOC entry 5423 (class 2606 OID 16514)
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- TOC entry 5426 (class 2606 OID 16694)
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- TOC entry 5474 (class 2606 OID 16823)
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- TOC entry 5476 (class 2606 OID 16821)
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- TOC entry 5481 (class 2606 OID 16837)
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- TOC entry 5434 (class 2606 OID 16537)
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- TOC entry 5447 (class 2606 OID 16715)
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- TOC entry 5471 (class 2606 OID 16804)
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- TOC entry 5466 (class 2606 OID 16795)
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- TOC entry 5416 (class 2606 OID 16877)
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- TOC entry 5418 (class 2606 OID 16501)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 5767 (class 2606 OID 40704)
-- Name: achievement_progress achievement_progress_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.achievement_progress
    ADD CONSTRAINT achievement_progress_pkey PRIMARY KEY (id);


--
-- TOC entry 5769 (class 2606 OID 40706)
-- Name: achievement_progress achievement_progress_user_id_achievement_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.achievement_progress
    ADD CONSTRAINT achievement_progress_user_id_achievement_id_key UNIQUE (user_id, achievement_id);


--
-- TOC entry 5762 (class 2606 OID 41850)
-- Name: achievements achievements_key_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.achievements
    ADD CONSTRAINT achievements_key_unique UNIQUE (key);


--
-- TOC entry 5764 (class 2606 OID 40693)
-- Name: achievements achievements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.achievements
    ADD CONSTRAINT achievements_pkey PRIMARY KEY (id);


--
-- TOC entry 5614 (class 2606 OID 40088)
-- Name: api_rate_limits api_rate_limits_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.api_rate_limits
    ADD CONSTRAINT api_rate_limits_pkey PRIMARY KEY (key, window_start, window_seconds);


--
-- TOC entry 5616 (class 2606 OID 40090)
-- Name: app_events app_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_events
    ADD CONSTRAINT app_events_pkey PRIMARY KEY (id);


--
-- TOC entry 5736 (class 2606 OID 40593)
-- Name: device_tokens device_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_tokens
    ADD CONSTRAINT device_tokens_pkey PRIMARY KEY (id);


--
-- TOC entry 5738 (class 2606 OID 40595)
-- Name: device_tokens device_tokens_token_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_tokens
    ADD CONSTRAINT device_tokens_token_key UNIQUE (token);


--
-- TOC entry 5749 (class 2606 OID 40640)
-- Name: driver_counters driver_counters_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.driver_counters
    ADD CONSTRAINT driver_counters_pkey PRIMARY KEY (driver_id);


--
-- TOC entry 5879 (class 2606 OID 41836)
-- Name: driver_leaderboard_daily driver_leaderboard_daily_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.driver_leaderboard_daily
    ADD CONSTRAINT driver_leaderboard_daily_pkey PRIMARY KEY (day, driver_id);


--
-- TOC entry 5625 (class 2606 OID 40092)
-- Name: driver_locations driver_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.driver_locations
    ADD CONSTRAINT driver_locations_pkey PRIMARY KEY (driver_id);


--
-- TOC entry 5755 (class 2606 OID 40671)
-- Name: driver_rank_snapshots driver_rank_snapshots_period_period_start_driver_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.driver_rank_snapshots
    ADD CONSTRAINT driver_rank_snapshots_period_period_start_driver_id_key UNIQUE (period, period_start, driver_id);


--
-- TOC entry 5757 (class 2606 OID 40669)
-- Name: driver_rank_snapshots driver_rank_snapshots_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.driver_rank_snapshots
    ADD CONSTRAINT driver_rank_snapshots_pkey PRIMARY KEY (id);


--
-- TOC entry 5751 (class 2606 OID 40653)
-- Name: driver_stats_daily driver_stats_daily_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.driver_stats_daily
    ADD CONSTRAINT driver_stats_daily_pkey PRIMARY KEY (driver_id, day);


--
-- TOC entry 5630 (class 2606 OID 40094)
-- Name: driver_vehicles driver_vehicles_driver_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.driver_vehicles
    ADD CONSTRAINT driver_vehicles_driver_id_key UNIQUE (driver_id);


--
-- TOC entry 5632 (class 2606 OID 40096)
-- Name: driver_vehicles driver_vehicles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.driver_vehicles
    ADD CONSTRAINT driver_vehicles_pkey PRIMARY KEY (id);


--
-- TOC entry 5635 (class 2606 OID 40098)
-- Name: drivers drivers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drivers
    ADD CONSTRAINT drivers_pkey PRIMARY KEY (id);


--
-- TOC entry 5580 (class 2606 OID 40100)
-- Name: gift_codes gift_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gift_codes
    ADD CONSTRAINT gift_codes_pkey PRIMARY KEY (code);


--
-- TOC entry 5848 (class 2606 OID 41388)
-- Name: kyc_document_types kyc_document_types_key_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kyc_document_types
    ADD CONSTRAINT kyc_document_types_key_key UNIQUE (key);


--
-- TOC entry 5850 (class 2606 OID 41386)
-- Name: kyc_document_types kyc_document_types_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kyc_document_types
    ADD CONSTRAINT kyc_document_types_pkey PRIMARY KEY (id);


--
-- TOC entry 5844 (class 2606 OID 41022)
-- Name: kyc_documents kyc_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kyc_documents
    ADD CONSTRAINT kyc_documents_pkey PRIMARY KEY (id);


--
-- TOC entry 5854 (class 2606 OID 41404)
-- Name: kyc_liveness_sessions kyc_liveness_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kyc_liveness_sessions
    ADD CONSTRAINT kyc_liveness_sessions_pkey PRIMARY KEY (id);


--
-- TOC entry 5837 (class 2606 OID 41000)
-- Name: kyc_submissions kyc_submissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kyc_submissions
    ADD CONSTRAINT kyc_submissions_pkey PRIMARY KEY (id);


--
-- TOC entry 5745 (class 2606 OID 40621)
-- Name: notification_outbox notification_outbox_notification_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_outbox
    ADD CONSTRAINT notification_outbox_notification_id_key UNIQUE (notification_id);


--
-- TOC entry 5747 (class 2606 OID 40619)
-- Name: notification_outbox notification_outbox_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_outbox
    ADD CONSTRAINT notification_outbox_pkey PRIMARY KEY (id);


--
-- TOC entry 5643 (class 2606 OID 40102)
-- Name: payment_intents payment_intents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_intents
    ADD CONSTRAINT payment_intents_pkey PRIMARY KEY (id);


--
-- TOC entry 5646 (class 2606 OID 40104)
-- Name: payment_providers payment_providers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_providers
    ADD CONSTRAINT payment_providers_pkey PRIMARY KEY (code);


--
-- TOC entry 5651 (class 2606 OID 40106)
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- TOC entry 5655 (class 2606 OID 40108)
-- Name: pricing_configs pricing_configs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pricing_configs
    ADD CONSTRAINT pricing_configs_pkey PRIMARY KEY (id);


--
-- TOC entry 5659 (class 2606 OID 40110)
-- Name: profile_kyc profile_kyc_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profile_kyc
    ADD CONSTRAINT profile_kyc_pkey PRIMARY KEY (user_id);


--
-- TOC entry 5663 (class 2606 OID 40112)
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (id);


--
-- TOC entry 5666 (class 2606 OID 40114)
-- Name: provider_events provider_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.provider_events
    ADD CONSTRAINT provider_events_pkey PRIMARY KEY (id);


--
-- TOC entry 5734 (class 2606 OID 40573)
-- Name: public_profiles public_profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.public_profiles
    ADD CONSTRAINT public_profiles_pkey PRIMARY KEY (id);


--
-- TOC entry 5773 (class 2606 OID 40735)
-- Name: referral_campaigns referral_campaigns_key_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.referral_campaigns
    ADD CONSTRAINT referral_campaigns_key_key UNIQUE (key);


--
-- TOC entry 5775 (class 2606 OID 40733)
-- Name: referral_campaigns referral_campaigns_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.referral_campaigns
    ADD CONSTRAINT referral_campaigns_pkey PRIMARY KEY (id);


--
-- TOC entry 5778 (class 2606 OID 40743)
-- Name: referral_codes referral_codes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.referral_codes
    ADD CONSTRAINT referral_codes_pkey PRIMARY KEY (code);


--
-- TOC entry 5780 (class 2606 OID 40745)
-- Name: referral_codes referral_codes_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.referral_codes
    ADD CONSTRAINT referral_codes_user_id_key UNIQUE (user_id);


--
-- TOC entry 5875 (class 2606 OID 41798)
-- Name: referral_invites referral_invites_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.referral_invites
    ADD CONSTRAINT referral_invites_pkey PRIMARY KEY (id);


--
-- TOC entry 5877 (class 2606 OID 41800)
-- Name: referral_invites referral_invites_referred_user_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.referral_invites
    ADD CONSTRAINT referral_invites_referred_user_id_key UNIQUE (referred_user_id);


--
-- TOC entry 5784 (class 2606 OID 40762)
-- Name: referral_redemptions referral_redemptions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.referral_redemptions
    ADD CONSTRAINT referral_redemptions_pkey PRIMARY KEY (id);


--
-- TOC entry 5786 (class 2606 OID 40764)
-- Name: referral_redemptions referral_redemptions_referred_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.referral_redemptions
    ADD CONSTRAINT referral_redemptions_referred_id_key UNIQUE (referred_id);


--
-- TOC entry 5872 (class 2606 OID 41787)
-- Name: referral_settings referral_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.referral_settings
    ADD CONSTRAINT referral_settings_pkey PRIMARY KEY (id);


--
-- TOC entry 5812 (class 2606 OID 40899)
-- Name: ride_chat_messages ride_chat_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_chat_messages
    ADD CONSTRAINT ride_chat_messages_pkey PRIMARY KEY (id);


--
-- TOC entry 5816 (class 2606 OID 40922)
-- Name: ride_chat_read_receipts ride_chat_read_receipts_message_id_reader_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_chat_read_receipts
    ADD CONSTRAINT ride_chat_read_receipts_message_id_reader_id_key UNIQUE (message_id, reader_id);


--
-- TOC entry 5818 (class 2606 OID 40920)
-- Name: ride_chat_read_receipts ride_chat_read_receipts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_chat_read_receipts
    ADD CONSTRAINT ride_chat_read_receipts_pkey PRIMARY KEY (id);


--
-- TOC entry 5868 (class 2606 OID 41747)
-- Name: ride_chat_threads ride_chat_threads_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_chat_threads
    ADD CONSTRAINT ride_chat_threads_pkey PRIMARY KEY (id);


--
-- TOC entry 5870 (class 2606 OID 41749)
-- Name: ride_chat_threads ride_chat_threads_ride_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_chat_threads
    ADD CONSTRAINT ride_chat_threads_ride_id_key UNIQUE (ride_id);


--
-- TOC entry 5822 (class 2606 OID 40945)
-- Name: ride_chat_typing ride_chat_typing_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_chat_typing
    ADD CONSTRAINT ride_chat_typing_pkey PRIMARY KEY (ride_id, profile_id);


--
-- TOC entry 5864 (class 2606 OID 41722)
-- Name: ride_completion_log ride_completion_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_completion_log
    ADD CONSTRAINT ride_completion_log_pkey PRIMARY KEY (ride_id);


--
-- TOC entry 5672 (class 2606 OID 40116)
-- Name: ride_events ride_events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_events
    ADD CONSTRAINT ride_events_pkey PRIMARY KEY (id);


--
-- TOC entry 5682 (class 2606 OID 40118)
-- Name: ride_incidents ride_incidents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_incidents
    ADD CONSTRAINT ride_incidents_pkey PRIMARY KEY (id);


--
-- TOC entry 5846 (class 2606 OID 41210)
-- Name: ride_products ride_products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_products
    ADD CONSTRAINT ride_products_pkey PRIMARY KEY (code);


--
-- TOC entry 5687 (class 2606 OID 40120)
-- Name: ride_ratings ride_ratings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_ratings
    ADD CONSTRAINT ride_ratings_pkey PRIMARY KEY (id);


--
-- TOC entry 5692 (class 2606 OID 40122)
-- Name: ride_receipts ride_receipts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_receipts
    ADD CONSTRAINT ride_receipts_pkey PRIMARY KEY (ride_id);


--
-- TOC entry 5699 (class 2606 OID 40124)
-- Name: ride_requests ride_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_requests
    ADD CONSTRAINT ride_requests_pkey PRIMARY KEY (id);


--
-- TOC entry 5598 (class 2606 OID 40126)
-- Name: rides rides_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rides
    ADD CONSTRAINT rides_pkey PRIMARY KEY (id);


--
-- TOC entry 5600 (class 2606 OID 40128)
-- Name: rides rides_request_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rides
    ADD CONSTRAINT rides_request_id_key UNIQUE (request_id);


--
-- TOC entry 5791 (class 2606 OID 41329)
-- Name: support_categories support_categories_id_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.support_categories
    ADD CONSTRAINT support_categories_id_unique UNIQUE (id);


--
-- TOC entry 5793 (class 2606 OID 41331)
-- Name: support_categories support_categories_key_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.support_categories
    ADD CONSTRAINT support_categories_key_unique UNIQUE (key);


--
-- TOC entry 5795 (class 2606 OID 40832)
-- Name: support_categories support_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.support_categories
    ADD CONSTRAINT support_categories_pkey PRIMARY KEY (code);


--
-- TOC entry 5807 (class 2606 OID 40869)
-- Name: support_messages support_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.support_messages
    ADD CONSTRAINT support_messages_pkey PRIMARY KEY (id);


--
-- TOC entry 5802 (class 2606 OID 40844)
-- Name: support_tickets support_tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.support_tickets
    ADD CONSTRAINT support_tickets_pkey PRIMARY KEY (id);


--
-- TOC entry 5608 (class 2606 OID 40130)
-- Name: topup_intents topup_intents_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.topup_intents
    ADD CONSTRAINT topup_intents_pkey PRIMARY KEY (id);


--
-- TOC entry 5702 (class 2606 OID 40132)
-- Name: topup_packages topup_packages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.topup_packages
    ADD CONSTRAINT topup_packages_pkey PRIMARY KEY (id);


--
-- TOC entry 5828 (class 2606 OID 40969)
-- Name: trip_share_tokens trip_share_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trip_share_tokens
    ADD CONSTRAINT trip_share_tokens_pkey PRIMARY KEY (id);


--
-- TOC entry 5830 (class 2606 OID 40971)
-- Name: trip_share_tokens trip_share_tokens_token_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trip_share_tokens
    ADD CONSTRAINT trip_share_tokens_token_key UNIQUE (token);


--
-- TOC entry 5789 (class 2606 OID 40799)
-- Name: trusted_contacts trusted_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trusted_contacts
    ADD CONSTRAINT trusted_contacts_pkey PRIMARY KEY (id);


--
-- TOC entry 5860 (class 2606 OID 41709)
-- Name: user_device_tokens user_device_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_device_tokens
    ADD CONSTRAINT user_device_tokens_pkey PRIMARY KEY (id);


--
-- TOC entry 5862 (class 2606 OID 41711)
-- Name: user_device_tokens user_device_tokens_user_id_device_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_device_tokens
    ADD CONSTRAINT user_device_tokens_user_id_device_id_key UNIQUE (user_id, device_id);


--
-- TOC entry 5707 (class 2606 OID 40134)
-- Name: user_notifications user_notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_notifications
    ADD CONSTRAINT user_notifications_pkey PRIMARY KEY (id);


--
-- TOC entry 5612 (class 2606 OID 40136)
-- Name: wallet_accounts wallet_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallet_accounts
    ADD CONSTRAINT wallet_accounts_pkey PRIMARY KEY (user_id);


--
-- TOC entry 5712 (class 2606 OID 40138)
-- Name: wallet_entries wallet_entries_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallet_entries
    ADD CONSTRAINT wallet_entries_pkey PRIMARY KEY (id);


--
-- TOC entry 5720 (class 2606 OID 40140)
-- Name: wallet_holds wallet_holds_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallet_holds
    ADD CONSTRAINT wallet_holds_pkey PRIMARY KEY (id);


--
-- TOC entry 5723 (class 2606 OID 40142)
-- Name: wallet_withdraw_payout_methods wallet_withdraw_payout_methods_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallet_withdraw_payout_methods
    ADD CONSTRAINT wallet_withdraw_payout_methods_pkey PRIMARY KEY (payout_kind);


--
-- TOC entry 5729 (class 2606 OID 40144)
-- Name: wallet_withdraw_requests wallet_withdraw_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallet_withdraw_requests
    ADD CONSTRAINT wallet_withdraw_requests_pkey PRIMARY KEY (id);


--
-- TOC entry 5732 (class 2606 OID 40146)
-- Name: wallet_withdrawal_policy wallet_withdrawal_policy_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallet_withdrawal_policy
    ADD CONSTRAINT wallet_withdrawal_policy_pkey PRIMARY KEY (id);


--
-- TOC entry 5521 (class 2606 OID 17253)
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE ONLY realtime.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (id, inserted_at);


--
-- TOC entry 5563 (class 2606 OID 24075)
-- Name: messages_2026_01_21 messages_2026_01_21_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2026_01_21
    ADD CONSTRAINT messages_2026_01_21_pkey PRIMARY KEY (id, inserted_at);


--
-- TOC entry 5566 (class 2606 OID 24087)
-- Name: messages_2026_01_22 messages_2026_01_22_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2026_01_22
    ADD CONSTRAINT messages_2026_01_22_pkey PRIMARY KEY (id, inserted_at);


--
-- TOC entry 5569 (class 2606 OID 24099)
-- Name: messages_2026_01_23 messages_2026_01_23_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2026_01_23
    ADD CONSTRAINT messages_2026_01_23_pkey PRIMARY KEY (id, inserted_at);


--
-- TOC entry 5572 (class 2606 OID 24111)
-- Name: messages_2026_01_24 messages_2026_01_24_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2026_01_24
    ADD CONSTRAINT messages_2026_01_24_pkey PRIMARY KEY (id, inserted_at);


--
-- TOC entry 5575 (class 2606 OID 24570)
-- Name: messages_2026_01_25 messages_2026_01_25_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2026_01_25
    ADD CONSTRAINT messages_2026_01_25_pkey PRIMARY KEY (id, inserted_at);


--
-- TOC entry 5578 (class 2606 OID 24841)
-- Name: messages_2026_01_26 messages_2026_01_26_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2026_01_26
    ADD CONSTRAINT messages_2026_01_26_pkey PRIMARY KEY (id, inserted_at);


--
-- TOC entry 5857 (class 2606 OID 41452)
-- Name: messages_2026_01_27 messages_2026_01_27_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.messages_2026_01_27
    ADD CONSTRAINT messages_2026_01_27_pkey PRIMARY KEY (id, inserted_at);


--
-- TOC entry 5517 (class 2606 OID 17107)
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);


--
-- TOC entry 5514 (class 2606 OID 17080)
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- TOC entry 5546 (class 2606 OID 17482)
-- Name: buckets_analytics buckets_analytics_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.buckets_analytics
    ADD CONSTRAINT buckets_analytics_pkey PRIMARY KEY (id);


--
-- TOC entry 5528 (class 2606 OID 17272)
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- TOC entry 5549 (class 2606 OID 17458)
-- Name: buckets_vectors buckets_vectors_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.buckets_vectors
    ADD CONSTRAINT buckets_vectors_pkey PRIMARY KEY (id);


--
-- TOC entry 5523 (class 2606 OID 17263)
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- TOC entry 5525 (class 2606 OID 17261)
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- TOC entry 5536 (class 2606 OID 17284)
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);


--
-- TOC entry 5544 (class 2606 OID 17386)
-- Name: prefixes prefixes_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.prefixes
    ADD CONSTRAINT prefixes_pkey PRIMARY KEY (bucket_id, level, name);


--
-- TOC entry 5541 (class 2606 OID 17347)
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_pkey PRIMARY KEY (id);


--
-- TOC entry 5539 (class 2606 OID 17332)
-- Name: s3_multipart_uploads s3_multipart_uploads_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_pkey PRIMARY KEY (id);


--
-- TOC entry 5552 (class 2606 OID 17468)
-- Name: vector_indexes vector_indexes_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_pkey PRIMARY KEY (id);


--
-- TOC entry 5432 (class 1259 OID 16532)
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- TOC entry 5406 (class 1259 OID 16704)
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- TOC entry 5407 (class 1259 OID 16706)
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- TOC entry 5408 (class 1259 OID 16707)
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- TOC entry 5450 (class 1259 OID 16785)
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- TOC entry 5483 (class 1259 OID 16893)
-- Name: flow_state_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX flow_state_created_at_idx ON auth.flow_state USING btree (created_at DESC);


--
-- TOC entry 5438 (class 1259 OID 16873)
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- TOC entry 7587 (class 0 OID 0)
-- Dependencies: 5438
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- TOC entry 5443 (class 1259 OID 16701)
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- TOC entry 5486 (class 1259 OID 16890)
-- Name: idx_auth_code; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_auth_code ON auth.flow_state USING btree (auth_code);


--
-- TOC entry 5510 (class 1259 OID 17075)
-- Name: idx_oauth_client_states_created_at; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_oauth_client_states_created_at ON auth.oauth_client_states USING btree (created_at);


--
-- TOC entry 5487 (class 1259 OID 16891)
-- Name: idx_user_id_auth_method; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX idx_user_id_auth_method ON auth.flow_state USING btree (user_id, authentication_method);


--
-- TOC entry 5458 (class 1259 OID 16896)
-- Name: mfa_challenge_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX mfa_challenge_created_at_idx ON auth.mfa_challenges USING btree (created_at DESC);


--
-- TOC entry 5455 (class 1259 OID 16757)
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- TOC entry 5456 (class 1259 OID 16902)
-- Name: mfa_factors_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX mfa_factors_user_id_idx ON auth.mfa_factors USING btree (user_id);


--
-- TOC entry 5496 (class 1259 OID 17027)
-- Name: oauth_auth_pending_exp_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_auth_pending_exp_idx ON auth.oauth_authorizations USING btree (expires_at) WHERE (status = 'pending'::auth.oauth_authorization_status);


--
-- TOC entry 5493 (class 1259 OID 16980)
-- Name: oauth_clients_deleted_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_clients_deleted_at_idx ON auth.oauth_clients USING btree (deleted_at);


--
-- TOC entry 5503 (class 1259 OID 17053)
-- Name: oauth_consents_active_client_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_consents_active_client_idx ON auth.oauth_consents USING btree (client_id) WHERE (revoked_at IS NULL);


--
-- TOC entry 5504 (class 1259 OID 17051)
-- Name: oauth_consents_active_user_client_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_consents_active_user_client_idx ON auth.oauth_consents USING btree (user_id, client_id) WHERE (revoked_at IS NULL);


--
-- TOC entry 5509 (class 1259 OID 17052)
-- Name: oauth_consents_user_order_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX oauth_consents_user_order_idx ON auth.oauth_consents USING btree (user_id, granted_at DESC);


--
-- TOC entry 5490 (class 1259 OID 16949)
-- Name: one_time_tokens_relates_to_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX one_time_tokens_relates_to_hash_idx ON auth.one_time_tokens USING hash (relates_to);


--
-- TOC entry 5491 (class 1259 OID 16948)
-- Name: one_time_tokens_token_hash_hash_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX one_time_tokens_token_hash_hash_idx ON auth.one_time_tokens USING hash (token_hash);


--
-- TOC entry 5492 (class 1259 OID 16950)
-- Name: one_time_tokens_user_id_token_type_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX one_time_tokens_user_id_token_type_key ON auth.one_time_tokens USING btree (user_id, token_type);


--
-- TOC entry 5409 (class 1259 OID 16708)
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- TOC entry 5410 (class 1259 OID 16705)
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- TOC entry 5419 (class 1259 OID 16515)
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- TOC entry 5420 (class 1259 OID 16516)
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- TOC entry 5421 (class 1259 OID 16700)
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- TOC entry 5424 (class 1259 OID 16787)
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- TOC entry 5427 (class 1259 OID 16892)
-- Name: refresh_tokens_updated_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_updated_at_idx ON auth.refresh_tokens USING btree (updated_at DESC);


--
-- TOC entry 5477 (class 1259 OID 16829)
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- TOC entry 5478 (class 1259 OID 16894)
-- Name: saml_relay_states_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_created_at_idx ON auth.saml_relay_states USING btree (created_at DESC);


--
-- TOC entry 5479 (class 1259 OID 16844)
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- TOC entry 5482 (class 1259 OID 16843)
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- TOC entry 5444 (class 1259 OID 16895)
-- Name: sessions_not_after_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_not_after_idx ON auth.sessions USING btree (not_after DESC);


--
-- TOC entry 5445 (class 1259 OID 17065)
-- Name: sessions_oauth_client_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_oauth_client_id_idx ON auth.sessions USING btree (oauth_client_id);


--
-- TOC entry 5448 (class 1259 OID 16786)
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- TOC entry 5469 (class 1259 OID 16811)
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- TOC entry 5472 (class 1259 OID 16810)
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- TOC entry 5467 (class 1259 OID 16796)
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- TOC entry 5468 (class 1259 OID 16958)
-- Name: sso_providers_resource_id_pattern_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sso_providers_resource_id_pattern_idx ON auth.sso_providers USING btree (resource_id text_pattern_ops);


--
-- TOC entry 5457 (class 1259 OID 16955)
-- Name: unique_phone_factor_per_user; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX unique_phone_factor_per_user ON auth.mfa_factors USING btree (user_id, phone);


--
-- TOC entry 5449 (class 1259 OID 16784)
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- TOC entry 5411 (class 1259 OID 16864)
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- TOC entry 7588 (class 0 OID 0)
-- Dependencies: 5411
-- Name: INDEX users_email_partial_key; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.users_email_partial_key IS 'Auth: A partial unique index that applies only when is_sso_user is false';


--
-- TOC entry 5412 (class 1259 OID 16702)
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- TOC entry 5413 (class 1259 OID 16505)
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- TOC entry 5414 (class 1259 OID 16919)
-- Name: users_is_anonymous_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_is_anonymous_idx ON auth.users USING btree (is_anonymous);


--
-- TOC entry 5765 (class 1259 OID 41855)
-- Name: achievements_unique_active_scope; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX achievements_unique_active_scope ON public.achievements USING btree (role, metric, target) WHERE (active = true);


--
-- TOC entry 5770 (class 1259 OID 42071)
-- Name: ix_achievement_progress_achievement_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_achievement_progress_achievement_id ON public.achievement_progress USING btree (achievement_id);


--
-- TOC entry 5771 (class 1259 OID 40717)
-- Name: ix_achievement_progress_user; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_achievement_progress_user ON public.achievement_progress USING btree (user_id);


--
-- TOC entry 5617 (class 1259 OID 40147)
-- Name: ix_app_events_actor_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_app_events_actor_id ON public.app_events USING btree (actor_id);


--
-- TOC entry 5618 (class 1259 OID 40148)
-- Name: ix_app_events_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_app_events_created_at ON public.app_events USING btree (created_at DESC);


--
-- TOC entry 5619 (class 1259 OID 40149)
-- Name: ix_app_events_event_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_app_events_event_type ON public.app_events USING btree (event_type);


--
-- TOC entry 5620 (class 1259 OID 40150)
-- Name: ix_app_events_level; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_app_events_level ON public.app_events USING btree (level);


--
-- TOC entry 5621 (class 1259 OID 40151)
-- Name: ix_app_events_payment_intent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_app_events_payment_intent_id ON public.app_events USING btree (payment_intent_id);


--
-- TOC entry 5622 (class 1259 OID 40152)
-- Name: ix_app_events_request_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_app_events_request_id ON public.app_events USING btree (request_id);


--
-- TOC entry 5623 (class 1259 OID 40153)
-- Name: ix_app_events_ride_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_app_events_ride_id ON public.app_events USING btree (ride_id);


--
-- TOC entry 5739 (class 1259 OID 41735)
-- Name: ix_device_tokens_user_enabled; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_device_tokens_user_enabled ON public.device_tokens USING btree (user_id, enabled) WHERE (enabled = true);


--
-- TOC entry 5740 (class 1259 OID 40601)
-- Name: ix_device_tokens_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_device_tokens_user_id ON public.device_tokens USING btree (user_id);


--
-- TOC entry 5880 (class 1259 OID 41842)
-- Name: ix_driver_leaderboard_daily_day_rank; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_driver_leaderboard_daily_day_rank ON public.driver_leaderboard_daily USING btree (day DESC, rank);


--
-- TOC entry 5881 (class 1259 OID 42072)
-- Name: ix_driver_leaderboard_daily_driver_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_driver_leaderboard_daily_driver_id ON public.driver_leaderboard_daily USING btree (driver_id);


--
-- TOC entry 5626 (class 1259 OID 40154)
-- Name: ix_driver_locations_driver_locations_driver_id_fkey_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_driver_locations_driver_locations_driver_id_fkey_fkey ON public.driver_locations USING btree (driver_id);


--
-- TOC entry 5627 (class 1259 OID 40155)
-- Name: ix_driver_locations_loc_gist; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_driver_locations_loc_gist ON public.driver_locations USING gist (loc);


--
-- TOC entry 5628 (class 1259 OID 40156)
-- Name: ix_driver_locations_updated_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_driver_locations_updated_at ON public.driver_locations USING btree (updated_at DESC);


--
-- TOC entry 5758 (class 1259 OID 42073)
-- Name: ix_driver_rank_snapshots_driver_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_driver_rank_snapshots_driver_id ON public.driver_rank_snapshots USING btree (driver_id);


--
-- TOC entry 5759 (class 1259 OID 40677)
-- Name: ix_driver_rank_snapshots_period; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_driver_rank_snapshots_period ON public.driver_rank_snapshots USING btree (period, period_start, rank);


--
-- TOC entry 5760 (class 1259 OID 41697)
-- Name: ix_driver_rank_snapshots_period_start; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_driver_rank_snapshots_period_start ON public.driver_rank_snapshots USING btree (period, period_start, score DESC);


--
-- TOC entry 5752 (class 1259 OID 40659)
-- Name: ix_driver_stats_daily_day; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_driver_stats_daily_day ON public.driver_stats_daily USING btree (day);


--
-- TOC entry 5753 (class 1259 OID 41822)
-- Name: ix_driver_stats_daily_driver_day; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_driver_stats_daily_driver_day ON public.driver_stats_daily USING btree (driver_id, day DESC);


--
-- TOC entry 5633 (class 1259 OID 40157)
-- Name: ix_driver_vehicles_driver_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_driver_vehicles_driver_id ON public.driver_vehicles USING btree (driver_id);


--
-- TOC entry 5636 (class 1259 OID 40158)
-- Name: ix_drivers_drivers_id_fkey_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_drivers_drivers_id_fkey_fkey ON public.drivers USING btree (id);


--
-- TOC entry 5637 (class 1259 OID 40159)
-- Name: ix_drivers_rating_avg; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_drivers_rating_avg ON public.drivers USING btree (rating_avg DESC);


--
-- TOC entry 5581 (class 1259 OID 40160)
-- Name: ix_gift_codes_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_gift_codes_created_at ON public.gift_codes USING btree (created_at DESC);


--
-- TOC entry 5582 (class 1259 OID 40161)
-- Name: ix_gift_codes_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_gift_codes_created_by ON public.gift_codes USING btree (created_by);


--
-- TOC entry 5583 (class 1259 OID 40162)
-- Name: ix_gift_codes_gift_codes_redeemed_by_fkey_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_gift_codes_gift_codes_redeemed_by_fkey_fkey ON public.gift_codes USING btree (redeemed_by);


--
-- TOC entry 5584 (class 1259 OID 40163)
-- Name: ix_gift_codes_redeemed_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_gift_codes_redeemed_by ON public.gift_codes USING btree (redeemed_by, redeemed_at DESC);


--
-- TOC entry 5585 (class 1259 OID 40164)
-- Name: ix_gift_codes_redeemed_entry_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_gift_codes_redeemed_entry_id ON public.gift_codes USING btree (redeemed_entry_id);


--
-- TOC entry 5838 (class 1259 OID 41427)
-- Name: ix_kyc_documents_document_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_kyc_documents_document_type_id ON public.kyc_documents USING btree (document_type_id);


--
-- TOC entry 5839 (class 1259 OID 41391)
-- Name: ix_kyc_documents_profile_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_kyc_documents_profile_id ON public.kyc_documents USING btree (profile_id);


--
-- TOC entry 5840 (class 1259 OID 41390)
-- Name: ix_kyc_documents_submission_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_kyc_documents_submission_id ON public.kyc_documents USING btree (submission_id);


--
-- TOC entry 5841 (class 1259 OID 41033)
-- Name: ix_kyc_documents_submission_id_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_kyc_documents_submission_id_created_at ON public.kyc_documents USING btree (submission_id, created_at);


--
-- TOC entry 5842 (class 1259 OID 41034)
-- Name: ix_kyc_documents_user_id_doc_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_kyc_documents_user_id_doc_type ON public.kyc_documents USING btree (user_id, doc_type);


--
-- TOC entry 5851 (class 1259 OID 41410)
-- Name: ix_kyc_liveness_profile_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_kyc_liveness_profile_id ON public.kyc_liveness_sessions USING btree (profile_id);


--
-- TOC entry 5852 (class 1259 OID 42074)
-- Name: ix_kyc_liveness_sessions_submission_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_kyc_liveness_sessions_submission_id ON public.kyc_liveness_sessions USING btree (submission_id);


--
-- TOC entry 5832 (class 1259 OID 41389)
-- Name: ix_kyc_submissions_profile_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_kyc_submissions_profile_id ON public.kyc_submissions USING btree (profile_id);


--
-- TOC entry 5833 (class 1259 OID 42075)
-- Name: ix_kyc_submissions_reviewer_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_kyc_submissions_reviewer_id ON public.kyc_submissions USING btree (reviewer_id);


--
-- TOC entry 5834 (class 1259 OID 41421)
-- Name: ix_kyc_submissions_role_context; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_kyc_submissions_role_context ON public.kyc_submissions USING btree (role_context);


--
-- TOC entry 5835 (class 1259 OID 41011)
-- Name: ix_kyc_submissions_user_id_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_kyc_submissions_user_id_created_at ON public.kyc_submissions USING btree (user_id, created_at DESC);


--
-- TOC entry 5742 (class 1259 OID 40627)
-- Name: ix_notification_outbox_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_notification_outbox_status ON public.notification_outbox USING btree (status, id);


--
-- TOC entry 5743 (class 1259 OID 40628)
-- Name: ix_notification_outbox_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_notification_outbox_user_id ON public.notification_outbox USING btree (user_id);


--
-- TOC entry 5638 (class 1259 OID 40165)
-- Name: ix_payment_intents_provider_charge_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_payment_intents_provider_charge_id ON public.payment_intents USING btree (provider_charge_id);


--
-- TOC entry 5639 (class 1259 OID 40166)
-- Name: ix_payment_intents_provider_payment_intent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_payment_intents_provider_payment_intent_id ON public.payment_intents USING btree (provider_payment_intent_id);


--
-- TOC entry 5640 (class 1259 OID 40167)
-- Name: ix_payment_intents_provider_session_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_payment_intents_provider_session_id ON public.payment_intents USING btree (provider_session_id);


--
-- TOC entry 5641 (class 1259 OID 40168)
-- Name: ix_payment_intents_ride_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_payment_intents_ride_id ON public.payment_intents USING btree (ride_id);


--
-- TOC entry 5647 (class 1259 OID 40169)
-- Name: ix_payments_payment_intent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_payments_payment_intent_id ON public.payments USING btree (payment_intent_id);


--
-- TOC entry 5648 (class 1259 OID 40170)
-- Name: ix_payments_provider_payment_intent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_payments_provider_payment_intent_id ON public.payments USING btree (provider_payment_intent_id);


--
-- TOC entry 5649 (class 1259 OID 40171)
-- Name: ix_payments_ride_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_payments_ride_id ON public.payments USING btree (ride_id);


--
-- TOC entry 5656 (class 1259 OID 40172)
-- Name: ix_profile_kyc_profile_kyc_user_id_fkey_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_profile_kyc_profile_kyc_user_id_fkey_fkey ON public.profile_kyc USING btree (user_id);


--
-- TOC entry 5657 (class 1259 OID 40173)
-- Name: ix_profile_kyc_updated_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_profile_kyc_updated_by ON public.profile_kyc USING btree (updated_by);


--
-- TOC entry 5660 (class 1259 OID 40174)
-- Name: ix_profiles_profiles_id_fkey_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_profiles_profiles_id_fkey_fkey ON public.profiles USING btree (id);


--
-- TOC entry 5661 (class 1259 OID 40175)
-- Name: ix_profiles_rating_avg; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_profiles_rating_avg ON public.profiles USING btree (rating_avg DESC);


--
-- TOC entry 5664 (class 1259 OID 40176)
-- Name: ix_provider_events_provider_events_provider_code_fkey_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_provider_events_provider_events_provider_code_fkey_fkey ON public.provider_events USING btree (provider_code);


--
-- TOC entry 5776 (class 1259 OID 40751)
-- Name: ix_referral_codes_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_referral_codes_user_id ON public.referral_codes USING btree (user_id);


--
-- TOC entry 5873 (class 1259 OID 41811)
-- Name: ix_referral_invites_referrer_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_referral_invites_referrer_created ON public.referral_invites USING btree (referrer_id, created_at DESC);


--
-- TOC entry 5781 (class 1259 OID 42076)
-- Name: ix_referral_redemptions_campaign_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_referral_redemptions_campaign_id ON public.referral_redemptions USING btree (campaign_id);


--
-- TOC entry 5782 (class 1259 OID 40780)
-- Name: ix_referral_redemptions_referrer; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_referral_redemptions_referrer ON public.referral_redemptions USING btree (referrer_id);


--
-- TOC entry 5808 (class 1259 OID 40910)
-- Name: ix_ride_chat_messages_ride_id_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_chat_messages_ride_id_created_at ON public.ride_chat_messages USING btree (ride_id, created_at DESC);


--
-- TOC entry 5809 (class 1259 OID 40911)
-- Name: ix_ride_chat_messages_sender_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_chat_messages_sender_id ON public.ride_chat_messages USING btree (sender_id);


--
-- TOC entry 5810 (class 1259 OID 41766)
-- Name: ix_ride_chat_messages_thread_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_chat_messages_thread_created ON public.ride_chat_messages USING btree (thread_id, created_at DESC);


--
-- TOC entry 5813 (class 1259 OID 42077)
-- Name: ix_ride_chat_read_receipts_reader_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_chat_read_receipts_reader_id ON public.ride_chat_read_receipts USING btree (reader_id);


--
-- TOC entry 5814 (class 1259 OID 40938)
-- Name: ix_ride_chat_read_receipts_ride_id_reader_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_chat_read_receipts_ride_id_reader_id ON public.ride_chat_read_receipts USING btree (ride_id, reader_id);


--
-- TOC entry 5865 (class 1259 OID 42078)
-- Name: ix_ride_chat_threads_driver_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_chat_threads_driver_id ON public.ride_chat_threads USING btree (driver_id);


--
-- TOC entry 5866 (class 1259 OID 42079)
-- Name: ix_ride_chat_threads_rider_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_chat_threads_rider_id ON public.ride_chat_threads USING btree (rider_id);


--
-- TOC entry 5819 (class 1259 OID 42080)
-- Name: ix_ride_chat_typing_profile_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_chat_typing_profile_id ON public.ride_chat_typing USING btree (profile_id);


--
-- TOC entry 5820 (class 1259 OID 40956)
-- Name: ix_ride_chat_typing_ride_id_updated_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_chat_typing_ride_id_updated_at ON public.ride_chat_typing USING btree (ride_id, updated_at DESC);


--
-- TOC entry 5669 (class 1259 OID 40177)
-- Name: ix_ride_events_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_events_created_at ON public.ride_events USING btree (created_at DESC);


--
-- TOC entry 5670 (class 1259 OID 40178)
-- Name: ix_ride_events_ride_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_events_ride_id ON public.ride_events USING btree (ride_id);


--
-- TOC entry 5673 (class 1259 OID 40179)
-- Name: ix_ride_incidents_assigned_to; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_incidents_assigned_to ON public.ride_incidents USING btree (assigned_to);


--
-- TOC entry 5674 (class 1259 OID 40180)
-- Name: ix_ride_incidents_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_incidents_created_at ON public.ride_incidents USING btree (created_at DESC);


--
-- TOC entry 5675 (class 1259 OID 40823)
-- Name: ix_ride_incidents_loc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_incidents_loc ON public.ride_incidents USING gist (loc);


--
-- TOC entry 5676 (class 1259 OID 40181)
-- Name: ix_ride_incidents_reporter_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_incidents_reporter_id ON public.ride_incidents USING btree (reporter_id);


--
-- TOC entry 5677 (class 1259 OID 40182)
-- Name: ix_ride_incidents_ride_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_incidents_ride_id ON public.ride_incidents USING btree (ride_id);


--
-- TOC entry 5678 (class 1259 OID 40822)
-- Name: ix_ride_incidents_ride_id_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_incidents_ride_id_created_at ON public.ride_incidents USING btree (ride_id, created_at DESC);


--
-- TOC entry 5679 (class 1259 OID 40183)
-- Name: ix_ride_incidents_severity; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_incidents_severity ON public.ride_incidents USING btree (severity);


--
-- TOC entry 5680 (class 1259 OID 40184)
-- Name: ix_ride_incidents_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_incidents_status ON public.ride_incidents USING btree (status);


--
-- TOC entry 5683 (class 1259 OID 40185)
-- Name: ix_ride_ratings_ratee_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_ratings_ratee_id ON public.ride_ratings USING btree (ratee_id);


--
-- TOC entry 5684 (class 1259 OID 40186)
-- Name: ix_ride_ratings_rater_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_ratings_rater_id ON public.ride_ratings USING btree (rater_id);


--
-- TOC entry 5685 (class 1259 OID 40187)
-- Name: ix_ride_ratings_ride_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_ratings_ride_id ON public.ride_ratings USING btree (ride_id);


--
-- TOC entry 5689 (class 1259 OID 40188)
-- Name: ix_ride_receipts_generated_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_receipts_generated_at ON public.ride_receipts USING btree (generated_at DESC);


--
-- TOC entry 5690 (class 1259 OID 40189)
-- Name: ix_ride_receipts_ride_receipts_ride_id_fkey_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_receipts_ride_receipts_ride_id_fkey_fkey ON public.ride_receipts USING btree (ride_id);


--
-- TOC entry 5693 (class 1259 OID 40190)
-- Name: ix_ride_requests_assigned_driver_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_requests_assigned_driver_id ON public.ride_requests USING btree (assigned_driver_id);


--
-- TOC entry 5694 (class 1259 OID 40191)
-- Name: ix_ride_requests_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_requests_created_at ON public.ride_requests USING btree (created_at DESC);


--
-- TOC entry 5695 (class 1259 OID 42081)
-- Name: ix_ride_requests_product_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_requests_product_code ON public.ride_requests USING btree (product_code);


--
-- TOC entry 5696 (class 1259 OID 40192)
-- Name: ix_ride_requests_rider_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_requests_rider_id ON public.ride_requests USING btree (rider_id);


--
-- TOC entry 5697 (class 1259 OID 40193)
-- Name: ix_ride_requests_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_ride_requests_status ON public.ride_requests USING btree (status);


--
-- TOC entry 5586 (class 1259 OID 40194)
-- Name: ix_rides_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_rides_created_at ON public.rides USING btree (created_at DESC);


--
-- TOC entry 5587 (class 1259 OID 40195)
-- Name: ix_rides_driver_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_rides_driver_created_at ON public.rides USING btree (driver_id, created_at DESC);


--
-- TOC entry 5588 (class 1259 OID 40196)
-- Name: ix_rides_driver_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_rides_driver_id ON public.rides USING btree (driver_id);


--
-- TOC entry 5589 (class 1259 OID 40197)
-- Name: ix_rides_paid_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_rides_paid_at ON public.rides USING btree (paid_at DESC);


--
-- TOC entry 5590 (class 1259 OID 40198)
-- Name: ix_rides_payment_intent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_rides_payment_intent_id ON public.rides USING btree (payment_intent_id);


--
-- TOC entry 5591 (class 1259 OID 42082)
-- Name: ix_rides_product_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_rides_product_code ON public.rides USING btree (product_code);


--
-- TOC entry 5592 (class 1259 OID 40199)
-- Name: ix_rides_rider_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_rides_rider_created_at ON public.rides USING btree (rider_id, created_at DESC);


--
-- TOC entry 5593 (class 1259 OID 40200)
-- Name: ix_rides_rider_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_rides_rider_id ON public.rides USING btree (rider_id);


--
-- TOC entry 5594 (class 1259 OID 40201)
-- Name: ix_rides_rides_request_id_fkey_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_rides_rides_request_id_fkey_fkey ON public.rides USING btree (request_id);


--
-- TOC entry 5595 (class 1259 OID 40202)
-- Name: ix_rides_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_rides_status ON public.rides USING btree (status);


--
-- TOC entry 5596 (class 1259 OID 40203)
-- Name: ix_rides_wallet_hold_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_rides_wallet_hold_id ON public.rides USING btree (wallet_hold_id);


--
-- TOC entry 5803 (class 1259 OID 41432)
-- Name: ix_support_messages_sender_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_support_messages_sender_id ON public.support_messages USING btree (sender_id);


--
-- TOC entry 5804 (class 1259 OID 41431)
-- Name: ix_support_messages_ticket_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_support_messages_ticket_id ON public.support_messages USING btree (ticket_id);


--
-- TOC entry 5805 (class 1259 OID 40880)
-- Name: ix_support_messages_ticket_id_created_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_support_messages_ticket_id_created_at ON public.support_messages USING btree (ticket_id, created_at);


--
-- TOC entry 5796 (class 1259 OID 42083)
-- Name: ix_support_tickets_category_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_support_tickets_category_code ON public.support_tickets USING btree (category_code);


--
-- TOC entry 5797 (class 1259 OID 42084)
-- Name: ix_support_tickets_category_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_support_tickets_category_id ON public.support_tickets USING btree (category_id);


--
-- TOC entry 5798 (class 1259 OID 41430)
-- Name: ix_support_tickets_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_support_tickets_created_by ON public.support_tickets USING btree (created_by);


--
-- TOC entry 5799 (class 1259 OID 40860)
-- Name: ix_support_tickets_created_by_status_updated_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_support_tickets_created_by_status_updated_at ON public.support_tickets USING btree (created_by, status, updated_at DESC);


--
-- TOC entry 5800 (class 1259 OID 42085)
-- Name: ix_support_tickets_ride_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_support_tickets_ride_id ON public.support_tickets USING btree (ride_id);


--
-- TOC entry 5602 (class 1259 OID 40204)
-- Name: ix_topup_intents_package_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_topup_intents_package_id ON public.topup_intents USING btree (package_id);


--
-- TOC entry 5603 (class 1259 OID 40205)
-- Name: ix_topup_intents_provider_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_topup_intents_provider_code ON public.topup_intents USING btree (provider_code);


--
-- TOC entry 5604 (class 1259 OID 40206)
-- Name: ix_topup_intents_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_topup_intents_status ON public.topup_intents USING btree (status);


--
-- TOC entry 5605 (class 1259 OID 40207)
-- Name: ix_topup_intents_topup_intents_user_id_fkey_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_topup_intents_topup_intents_user_id_fkey_fkey ON public.topup_intents USING btree (user_id);


--
-- TOC entry 5606 (class 1259 OID 40208)
-- Name: ix_topup_intents_user_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_topup_intents_user_created ON public.topup_intents USING btree (user_id, created_at DESC);


--
-- TOC entry 5823 (class 1259 OID 42086)
-- Name: ix_trip_share_tokens_created_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_trip_share_tokens_created_by ON public.trip_share_tokens USING btree (created_by);


--
-- TOC entry 5824 (class 1259 OID 41372)
-- Name: ix_trip_share_tokens_ride_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_trip_share_tokens_ride_id ON public.trip_share_tokens USING btree (ride_id);


--
-- TOC entry 5825 (class 1259 OID 40983)
-- Name: ix_trip_share_tokens_ride_id_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_trip_share_tokens_ride_id_active ON public.trip_share_tokens USING btree (ride_id, expires_at) WHERE (revoked_at IS NULL);


--
-- TOC entry 5826 (class 1259 OID 40982)
-- Name: ix_trip_share_tokens_token; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_trip_share_tokens_token ON public.trip_share_tokens USING btree (token);


--
-- TOC entry 5787 (class 1259 OID 40805)
-- Name: ix_trusted_contacts_user_id_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_trusted_contacts_user_id_active ON public.trusted_contacts USING btree (user_id, is_active);


--
-- TOC entry 5858 (class 1259 OID 41712)
-- Name: ix_user_device_tokens_user_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_user_device_tokens_user_id ON public.user_device_tokens USING btree (user_id);


--
-- TOC entry 5704 (class 1259 OID 40209)
-- Name: ix_user_notifications_user_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_user_notifications_user_created ON public.user_notifications USING btree (user_id, created_at DESC);


--
-- TOC entry 5705 (class 1259 OID 40210)
-- Name: ix_user_notifications_user_notifications_user_id_fkey_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_user_notifications_user_notifications_user_id_fkey_fkey ON public.user_notifications USING btree (user_id);


--
-- TOC entry 5610 (class 1259 OID 40211)
-- Name: ix_wallet_accounts_wallet_accounts_user_id_fkey_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_wallet_accounts_wallet_accounts_user_id_fkey_fkey ON public.wallet_accounts USING btree (user_id);


--
-- TOC entry 5708 (class 1259 OID 40212)
-- Name: ix_wallet_entries_user_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_wallet_entries_user_created ON public.wallet_entries USING btree (user_id, created_at DESC);


--
-- TOC entry 5709 (class 1259 OID 40213)
-- Name: ix_wallet_entries_wallet_entries_user_id_fkey_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_wallet_entries_wallet_entries_user_id_fkey_fkey ON public.wallet_entries USING btree (user_id);


--
-- TOC entry 5713 (class 1259 OID 40214)
-- Name: ix_wallet_holds_ride_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_wallet_holds_ride_id ON public.wallet_holds USING btree (ride_id);


--
-- TOC entry 5714 (class 1259 OID 40215)
-- Name: ix_wallet_holds_user_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_wallet_holds_user_created ON public.wallet_holds USING btree (user_id, created_at DESC);


--
-- TOC entry 5715 (class 1259 OID 40216)
-- Name: ix_wallet_holds_wallet_holds_user_id_fkey_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_wallet_holds_wallet_holds_user_id_fkey_fkey ON public.wallet_holds USING btree (user_id);


--
-- TOC entry 5716 (class 1259 OID 40217)
-- Name: ix_wallet_holds_withdraw_request; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_wallet_holds_withdraw_request ON public.wallet_holds USING btree (withdraw_request_id);


--
-- TOC entry 5721 (class 1259 OID 40218)
-- Name: ix_wallet_withdraw_payout_methods_updated_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_wallet_withdraw_payout_methods_updated_by ON public.wallet_withdraw_payout_methods USING btree (updated_by);


--
-- TOC entry 5724 (class 1259 OID 40219)
-- Name: ix_wallet_withdraw_requ_67e67264c160fa61_fkey; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_wallet_withdraw_requ_67e67264c160fa61_fkey ON public.wallet_withdraw_requests USING btree (user_id);


--
-- TOC entry 5725 (class 1259 OID 40220)
-- Name: ix_wallet_withdraw_requests_status_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_wallet_withdraw_requests_status_created ON public.wallet_withdraw_requests USING btree (status, created_at DESC);


--
-- TOC entry 5726 (class 1259 OID 40221)
-- Name: ix_wallet_withdraw_requests_user_created; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_wallet_withdraw_requests_user_created ON public.wallet_withdraw_requests USING btree (user_id, created_at DESC);


--
-- TOC entry 5730 (class 1259 OID 40222)
-- Name: ix_wallet_withdrawal_policy_updated_by; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_wallet_withdrawal_policy_updated_by ON public.wallet_withdrawal_policy USING btree (updated_by);


--
-- TOC entry 5667 (class 1259 OID 40223)
-- Name: provider_events_provider_code_provider_event_id_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX provider_events_provider_code_provider_event_id_key ON public.provider_events USING btree (provider_code, provider_event_id);


--
-- TOC entry 5668 (class 1259 OID 40224)
-- Name: provider_events_provider_code_received_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX provider_events_provider_code_received_at_idx ON public.provider_events USING btree (provider_code, received_at DESC);


--
-- TOC entry 5741 (class 1259 OID 41734)
-- Name: ux_device_tokens_user_token; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_device_tokens_user_token ON public.device_tokens USING btree (user_id, token);


--
-- TOC entry 5644 (class 1259 OID 40225)
-- Name: ux_payment_intents_ride_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_payment_intents_ride_active ON public.payment_intents USING btree (ride_id) WHERE (status = ANY (ARRAY['requires_payment_method'::public.payment_intent_status, 'requires_confirmation'::public.payment_intent_status, 'requires_capture'::public.payment_intent_status]));


--
-- TOC entry 5652 (class 1259 OID 40226)
-- Name: ux_payments_provider_refund_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_payments_provider_refund_id ON public.payments USING btree (provider_refund_id) WHERE (provider_refund_id IS NOT NULL);


--
-- TOC entry 5653 (class 1259 OID 40227)
-- Name: ux_payments_ride_succeeded; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_payments_ride_succeeded ON public.payments USING btree (ride_id) WHERE (status = 'succeeded'::text);


--
-- TOC entry 5688 (class 1259 OID 40228)
-- Name: ux_ride_ratings_ride_rater; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_ride_ratings_ride_rater ON public.ride_ratings USING btree (ride_id, rater_id);


--
-- TOC entry 5700 (class 1259 OID 40229)
-- Name: ux_ride_requests_driver_matched; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_ride_requests_driver_matched ON public.ride_requests USING btree (assigned_driver_id) WHERE ((status = 'matched'::public.ride_request_status) AND (assigned_driver_id IS NOT NULL));


--
-- TOC entry 5601 (class 1259 OID 40230)
-- Name: ux_rides_driver_active; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_rides_driver_active ON public.rides USING btree (driver_id) WHERE (status = ANY (ARRAY['assigned'::public.ride_status, 'arrived'::public.ride_status, 'in_progress'::public.ride_status]));


--
-- TOC entry 5609 (class 1259 OID 40231)
-- Name: ux_topup_intents_user_idempotency; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_topup_intents_user_idempotency ON public.topup_intents USING btree (user_id, idempotency_key) WHERE (idempotency_key IS NOT NULL);


--
-- TOC entry 5703 (class 1259 OID 40232)
-- Name: ux_topup_packages_label; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_topup_packages_label ON public.topup_packages USING btree (label);


--
-- TOC entry 5831 (class 1259 OID 41371)
-- Name: ux_trip_share_tokens_token_hash; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_trip_share_tokens_token_hash ON public.trip_share_tokens USING btree (token_hash) WHERE (token_hash IS NOT NULL);


--
-- TOC entry 5710 (class 1259 OID 40233)
-- Name: ux_wallet_entries_user_idempotency; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_wallet_entries_user_idempotency ON public.wallet_entries USING btree (user_id, idempotency_key) WHERE (idempotency_key IS NOT NULL);


--
-- TOC entry 5717 (class 1259 OID 40234)
-- Name: ux_wallet_holds_active_per_ride; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_wallet_holds_active_per_ride ON public.wallet_holds USING btree (ride_id) WHERE ((ride_id IS NOT NULL) AND (status = 'active'::public.wallet_hold_status));


--
-- TOC entry 5718 (class 1259 OID 40235)
-- Name: ux_wallet_holds_active_per_withdraw; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_wallet_holds_active_per_withdraw ON public.wallet_holds USING btree (withdraw_request_id) WHERE ((withdraw_request_id IS NOT NULL) AND (status = 'active'::public.wallet_hold_status));


--
-- TOC entry 5727 (class 1259 OID 40236)
-- Name: ux_wallet_withdraw_requests_user_idempotency; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_wallet_withdraw_requests_user_idempotency ON public.wallet_withdraw_requests USING btree (user_id, idempotency_key) WHERE (idempotency_key IS NOT NULL);


--
-- TOC entry 5515 (class 1259 OID 17254)
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING btree (entity);


--
-- TOC entry 5519 (class 1259 OID 17255)
-- Name: messages_inserted_at_topic_index; Type: INDEX; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE INDEX messages_inserted_at_topic_index ON ONLY realtime.messages USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- TOC entry 5561 (class 1259 OID 24076)
-- Name: messages_2026_01_21_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2026_01_21_inserted_at_topic_idx ON realtime.messages_2026_01_21 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- TOC entry 5564 (class 1259 OID 24088)
-- Name: messages_2026_01_22_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2026_01_22_inserted_at_topic_idx ON realtime.messages_2026_01_22 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- TOC entry 5567 (class 1259 OID 24100)
-- Name: messages_2026_01_23_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2026_01_23_inserted_at_topic_idx ON realtime.messages_2026_01_23 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- TOC entry 5570 (class 1259 OID 24112)
-- Name: messages_2026_01_24_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2026_01_24_inserted_at_topic_idx ON realtime.messages_2026_01_24 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- TOC entry 5573 (class 1259 OID 24571)
-- Name: messages_2026_01_25_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2026_01_25_inserted_at_topic_idx ON realtime.messages_2026_01_25 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- TOC entry 5576 (class 1259 OID 24842)
-- Name: messages_2026_01_26_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2026_01_26_inserted_at_topic_idx ON realtime.messages_2026_01_26 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- TOC entry 5855 (class 1259 OID 41453)
-- Name: messages_2026_01_27_inserted_at_topic_idx; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX messages_2026_01_27_inserted_at_topic_idx ON realtime.messages_2026_01_27 USING btree (inserted_at DESC, topic) WHERE ((extension = 'broadcast'::text) AND (private IS TRUE));


--
-- TOC entry 5518 (class 1259 OID 17156)
-- Name: subscription_subscription_id_entity_filters_key; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_key ON realtime.subscription USING btree (subscription_id, entity, filters);


--
-- TOC entry 5526 (class 1259 OID 17273)
-- Name: bname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);


--
-- TOC entry 5529 (class 1259 OID 17290)
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name);


--
-- TOC entry 5547 (class 1259 OID 17483)
-- Name: buckets_analytics_unique_name_idx; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX buckets_analytics_unique_name_idx ON storage.buckets_analytics USING btree (name) WHERE (deleted_at IS NULL);


--
-- TOC entry 5537 (class 1259 OID 17358)
-- Name: idx_multipart_uploads_list; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_multipart_uploads_list ON storage.s3_multipart_uploads USING btree (bucket_id, key, created_at);


--
-- TOC entry 5530 (class 1259 OID 17404)
-- Name: idx_name_bucket_level_unique; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX idx_name_bucket_level_unique ON storage.objects USING btree (name COLLATE "C", bucket_id, level);


--
-- TOC entry 5531 (class 1259 OID 17323)
-- Name: idx_objects_bucket_id_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_objects_bucket_id_name ON storage.objects USING btree (bucket_id, name COLLATE "C");


--
-- TOC entry 5532 (class 1259 OID 17406)
-- Name: idx_objects_lower_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_objects_lower_name ON storage.objects USING btree ((path_tokens[level]), lower(name) text_pattern_ops, bucket_id, level);


--
-- TOC entry 5542 (class 1259 OID 17407)
-- Name: idx_prefixes_lower_name; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX idx_prefixes_lower_name ON storage.prefixes USING btree (bucket_id, level, ((string_to_array(name, '/'::text))[level]), lower(name) text_pattern_ops);


--
-- TOC entry 5533 (class 1259 OID 17291)
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- TOC entry 5534 (class 1259 OID 17405)
-- Name: objects_bucket_id_level_idx; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX objects_bucket_id_level_idx ON storage.objects USING btree (bucket_id, level, name COLLATE "C");


--
-- TOC entry 5550 (class 1259 OID 17474)
-- Name: vector_indexes_name_bucket_id_idx; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX vector_indexes_name_bucket_id_idx ON storage.vector_indexes USING btree (name, bucket_id);


--
-- TOC entry 5882 (class 0 OID 0)
-- Name: messages_2026_01_21_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_01_21_inserted_at_topic_idx;


--
-- TOC entry 5883 (class 0 OID 0)
-- Name: messages_2026_01_21_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_01_21_pkey;


--
-- TOC entry 5884 (class 0 OID 0)
-- Name: messages_2026_01_22_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_01_22_inserted_at_topic_idx;


--
-- TOC entry 5885 (class 0 OID 0)
-- Name: messages_2026_01_22_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_01_22_pkey;


--
-- TOC entry 5886 (class 0 OID 0)
-- Name: messages_2026_01_23_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_01_23_inserted_at_topic_idx;


--
-- TOC entry 5887 (class 0 OID 0)
-- Name: messages_2026_01_23_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_01_23_pkey;


--
-- TOC entry 5888 (class 0 OID 0)
-- Name: messages_2026_01_24_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_01_24_inserted_at_topic_idx;


--
-- TOC entry 5889 (class 0 OID 0)
-- Name: messages_2026_01_24_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_01_24_pkey;


--
-- TOC entry 5890 (class 0 OID 0)
-- Name: messages_2026_01_25_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_01_25_inserted_at_topic_idx;


--
-- TOC entry 5891 (class 0 OID 0)
-- Name: messages_2026_01_25_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_01_25_pkey;


--
-- TOC entry 5892 (class 0 OID 0)
-- Name: messages_2026_01_26_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_01_26_inserted_at_topic_idx;


--
-- TOC entry 5893 (class 0 OID 0)
-- Name: messages_2026_01_26_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_01_26_pkey;


--
-- TOC entry 5894 (class 0 OID 0)
-- Name: messages_2026_01_27_inserted_at_topic_idx; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_inserted_at_topic_index ATTACH PARTITION realtime.messages_2026_01_27_inserted_at_topic_idx;


--
-- TOC entry 5895 (class 0 OID 0)
-- Name: messages_2026_01_27_pkey; Type: INDEX ATTACH; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER INDEX realtime.messages_pkey ATTACH PARTITION realtime.messages_2026_01_27_pkey;


--
-- TOC entry 6003 (class 2620 OID 42242)
-- Name: users on_auth_user_created; Type: TRIGGER; Schema: auth; Owner: supabase_auth_admin
--

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();


--
-- TOC entry 6018 (class 2620 OID 40237)
-- Name: driver_locations driver_locations_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER driver_locations_set_updated_at BEFORE UPDATE ON public.driver_locations FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6019 (class 2620 OID 40238)
-- Name: driver_vehicles driver_vehicles_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER driver_vehicles_set_updated_at BEFORE UPDATE ON public.driver_vehicles FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6020 (class 2620 OID 40239)
-- Name: drivers drivers_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER drivers_set_updated_at BEFORE UPDATE ON public.drivers FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6022 (class 2620 OID 40240)
-- Name: payment_intents payment_intents_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER payment_intents_set_updated_at BEFORE UPDATE ON public.payment_intents FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6023 (class 2620 OID 40241)
-- Name: payment_providers payment_providers_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER payment_providers_set_updated_at BEFORE UPDATE ON public.payment_providers FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6024 (class 2620 OID 40242)
-- Name: payments payments_generate_receipt; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER payments_generate_receipt AFTER INSERT ON public.payments FOR EACH ROW EXECUTE FUNCTION public.create_receipt_from_payment();


--
-- TOC entry 6025 (class 2620 OID 40243)
-- Name: payments payments_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER payments_set_updated_at BEFORE UPDATE ON public.payments FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6026 (class 2620 OID 40244)
-- Name: payments payments_update_receipt_on_refund; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER payments_update_receipt_on_refund AFTER UPDATE ON public.payments FOR EACH ROW EXECUTE FUNCTION public.update_receipt_on_refund();


--
-- TOC entry 6027 (class 2620 OID 40245)
-- Name: pricing_configs pricing_configs_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER pricing_configs_set_updated_at BEFORE UPDATE ON public.pricing_configs FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6028 (class 2620 OID 40246)
-- Name: profile_kyc profile_kyc_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER profile_kyc_set_updated_at BEFORE UPDATE ON public.profile_kyc FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6029 (class 2620 OID 40247)
-- Name: profiles profiles_after_insert_profile_kyc; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER profiles_after_insert_profile_kyc AFTER INSERT ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.profile_kyc_init();


--
-- TOC entry 6030 (class 2620 OID 41816)
-- Name: profiles profiles_after_insert_referral_code; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER profiles_after_insert_referral_code AFTER INSERT ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.referral_code_init();


--
-- TOC entry 6031 (class 2620 OID 40248)
-- Name: profiles profiles_ensure_wallet_account; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER profiles_ensure_wallet_account AFTER INSERT ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.ensure_wallet_account();


--
-- TOC entry 6032 (class 2620 OID 40249)
-- Name: profiles profiles_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER profiles_set_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6053 (class 2620 OID 41765)
-- Name: ride_chat_threads ride_chat_threads_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ride_chat_threads_set_updated_at BEFORE UPDATE ON public.ride_chat_threads FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6034 (class 2620 OID 40250)
-- Name: ride_incidents ride_incidents_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ride_incidents_set_updated_at BEFORE UPDATE ON public.ride_incidents FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6035 (class 2620 OID 40251)
-- Name: ride_ratings ride_ratings_apply_aggregate; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ride_ratings_apply_aggregate AFTER INSERT ON public.ride_ratings FOR EACH ROW EXECUTE FUNCTION public.apply_rating_aggregate();


--
-- TOC entry 6036 (class 2620 OID 40252)
-- Name: ride_requests ride_requests_clear_match_fields; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ride_requests_clear_match_fields BEFORE UPDATE ON public.ride_requests FOR EACH ROW EXECUTE FUNCTION public.ride_requests_clear_match_fields();


--
-- TOC entry 6037 (class 2620 OID 40253)
-- Name: ride_requests ride_requests_release_driver_on_unmatch; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ride_requests_release_driver_on_unmatch AFTER UPDATE ON public.ride_requests FOR EACH ROW EXECUTE FUNCTION public.ride_requests_release_driver_on_unmatch();


--
-- TOC entry 6038 (class 2620 OID 40254)
-- Name: ride_requests ride_requests_set_quote; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ride_requests_set_quote BEFORE INSERT ON public.ride_requests FOR EACH ROW EXECUTE FUNCTION public.ride_requests_set_quote();


--
-- TOC entry 6039 (class 2620 OID 40255)
-- Name: ride_requests ride_requests_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ride_requests_set_updated_at BEFORE UPDATE ON public.ride_requests FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6040 (class 2620 OID 40256)
-- Name: ride_requests ride_requests_status_timestamps; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER ride_requests_status_timestamps BEFORE UPDATE ON public.ride_requests FOR EACH ROW EXECUTE FUNCTION public.ride_requests_set_status_timestamps();


--
-- TOC entry 6012 (class 2620 OID 41821)
-- Name: rides rides_after_completed_referral; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER rides_after_completed_referral AFTER UPDATE ON public.rides FOR EACH ROW EXECUTE FUNCTION public.referral_on_ride_completed();


--
-- TOC entry 6013 (class 2620 OID 40257)
-- Name: rides rides_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER rides_set_updated_at BEFORE UPDATE ON public.rides FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6051 (class 2620 OID 41231)
-- Name: kyc_documents set_updated_at_kyc_documents; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_updated_at_kyc_documents BEFORE UPDATE ON public.kyc_documents FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6049 (class 2620 OID 41230)
-- Name: kyc_submissions set_updated_at_kyc_submissions; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_updated_at_kyc_submissions BEFORE UPDATE ON public.kyc_submissions FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6052 (class 2620 OID 41211)
-- Name: ride_products set_updated_at_ride_products; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_updated_at_ride_products BEFORE UPDATE ON public.ride_products FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6016 (class 2620 OID 40258)
-- Name: topup_intents topup_intents_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER topup_intents_set_updated_at BEFORE UPDATE ON public.topup_intents FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6041 (class 2620 OID 40259)
-- Name: topup_packages topup_packages_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER topup_packages_set_updated_at BEFORE UPDATE ON public.topup_packages FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6021 (class 2620 OID 42212)
-- Name: drivers trg_drivers_force_id_from_auth_uid; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_drivers_force_id_from_auth_uid BEFORE INSERT ON public.drivers FOR EACH ROW EXECUTE FUNCTION public.drivers_force_id_from_auth_uid();


--
-- TOC entry 6042 (class 2620 OID 41739)
-- Name: user_notifications trg_enqueue_notification_outbox; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_enqueue_notification_outbox AFTER INSERT ON public.user_notifications FOR EACH ROW EXECUTE FUNCTION public.enqueue_notification_outbox();


--
-- TOC entry 6014 (class 2620 OID 41316)
-- Name: rides trg_on_ride_completed_side_effects; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_on_ride_completed_side_effects AFTER UPDATE OF status ON public.rides FOR EACH ROW WHEN (((new.status = 'completed'::public.ride_status) AND (old.status IS DISTINCT FROM 'completed'::public.ride_status))) EXECUTE FUNCTION public.on_ride_completed_side_effects();


--
-- TOC entry 6015 (class 2620 OID 41357)
-- Name: rides trg_revoke_trip_share_tokens_on_ride_end; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_revoke_trip_share_tokens_on_ride_end AFTER UPDATE OF status ON public.rides FOR EACH ROW EXECUTE FUNCTION public.revoke_trip_share_tokens_on_ride_end();


--
-- TOC entry 6048 (class 2620 OID 41776)
-- Name: ride_chat_messages trg_ride_chat_notify_on_message; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_ride_chat_notify_on_message AFTER INSERT ON public.ride_chat_messages FOR EACH ROW EXECUTE FUNCTION public.ride_chat_notify_on_message();


--
-- TOC entry 6047 (class 2620 OID 41345)
-- Name: support_messages trg_support_ticket_touch; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_support_ticket_touch AFTER INSERT ON public.support_messages FOR EACH ROW EXECUTE FUNCTION public.support_ticket_touch_updated_at();


--
-- TOC entry 6050 (class 2620 OID 41429)
-- Name: kyc_submissions trg_sync_profile_kyc_from_submission; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_sync_profile_kyc_from_submission AFTER INSERT OR UPDATE OF status ON public.kyc_submissions FOR EACH ROW EXECUTE FUNCTION public.sync_profile_kyc_from_submission();


--
-- TOC entry 6033 (class 2620 OID 41309)
-- Name: profiles trg_sync_public_profile; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER trg_sync_public_profile AFTER INSERT OR UPDATE OF display_name, rating_avg, rating_count ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.sync_public_profile();


--
-- TOC entry 6017 (class 2620 OID 40260)
-- Name: wallet_accounts wallet_accounts_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER wallet_accounts_set_updated_at BEFORE UPDATE ON public.wallet_accounts FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6043 (class 2620 OID 40261)
-- Name: wallet_holds wallet_holds_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER wallet_holds_set_updated_at BEFORE UPDATE ON public.wallet_holds FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6044 (class 2620 OID 40262)
-- Name: wallet_withdraw_payout_methods wallet_withdraw_payout_methods_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER wallet_withdraw_payout_methods_set_updated_at BEFORE UPDATE ON public.wallet_withdraw_payout_methods FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6045 (class 2620 OID 40263)
-- Name: wallet_withdraw_requests wallet_withdraw_requests_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER wallet_withdraw_requests_set_updated_at BEFORE UPDATE ON public.wallet_withdraw_requests FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6046 (class 2620 OID 40264)
-- Name: wallet_withdrawal_policy wallet_withdrawal_policy_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER wallet_withdrawal_policy_set_updated_at BEFORE UPDATE ON public.wallet_withdrawal_policy FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- TOC entry 6004 (class 2620 OID 17112)
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: supabase_admin
--

CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECUTE FUNCTION realtime.subscription_check_filters();


--
-- TOC entry 6005 (class 2620 OID 17414)
-- Name: buckets enforce_bucket_name_length_trigger; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER enforce_bucket_name_length_trigger BEFORE INSERT OR UPDATE OF name ON storage.buckets FOR EACH ROW EXECUTE FUNCTION storage.enforce_bucket_name_length();


--
-- TOC entry 6006 (class 2620 OID 17445)
-- Name: objects objects_delete_delete_prefix; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER objects_delete_delete_prefix AFTER DELETE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.delete_prefix_hierarchy_trigger();


--
-- TOC entry 6007 (class 2620 OID 17400)
-- Name: objects objects_insert_create_prefix; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER objects_insert_create_prefix BEFORE INSERT ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.objects_insert_prefix_trigger();


--
-- TOC entry 6008 (class 2620 OID 17444)
-- Name: objects objects_update_create_prefix; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER objects_update_create_prefix BEFORE UPDATE ON storage.objects FOR EACH ROW WHEN (((new.name <> old.name) OR (new.bucket_id <> old.bucket_id))) EXECUTE FUNCTION storage.objects_update_prefix_trigger();


--
-- TOC entry 6010 (class 2620 OID 17410)
-- Name: prefixes prefixes_create_hierarchy; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER prefixes_create_hierarchy BEFORE INSERT ON storage.prefixes FOR EACH ROW WHEN ((pg_trigger_depth() < 1)) EXECUTE FUNCTION storage.prefixes_insert_trigger();


--
-- TOC entry 6011 (class 2620 OID 17446)
-- Name: prefixes prefixes_delete_hierarchy; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER prefixes_delete_hierarchy AFTER DELETE ON storage.prefixes FOR EACH ROW EXECUTE FUNCTION storage.delete_prefix_hierarchy_trigger();


--
-- TOC entry 6009 (class 2620 OID 17311)
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();


--
-- TOC entry 5897 (class 2606 OID 16688)
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- TOC entry 5902 (class 2606 OID 16777)
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- TOC entry 5901 (class 2606 OID 16765)
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- TOC entry 5900 (class 2606 OID 16752)
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- TOC entry 5908 (class 2606 OID 17017)
-- Name: oauth_authorizations oauth_authorizations_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- TOC entry 5909 (class 2606 OID 17022)
-- Name: oauth_authorizations oauth_authorizations_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_authorizations
    ADD CONSTRAINT oauth_authorizations_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- TOC entry 5910 (class 2606 OID 17046)
-- Name: oauth_consents oauth_consents_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_client_id_fkey FOREIGN KEY (client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- TOC entry 5911 (class 2606 OID 17041)
-- Name: oauth_consents oauth_consents_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.oauth_consents
    ADD CONSTRAINT oauth_consents_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- TOC entry 5907 (class 2606 OID 16943)
-- Name: one_time_tokens one_time_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.one_time_tokens
    ADD CONSTRAINT one_time_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- TOC entry 5896 (class 2606 OID 16721)
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- TOC entry 5904 (class 2606 OID 16824)
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- TOC entry 5905 (class 2606 OID 16897)
-- Name: saml_relay_states saml_relay_states_flow_state_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_flow_state_id_fkey FOREIGN KEY (flow_state_id) REFERENCES auth.flow_state(id) ON DELETE CASCADE;


--
-- TOC entry 5906 (class 2606 OID 16838)
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- TOC entry 5898 (class 2606 OID 17060)
-- Name: sessions sessions_oauth_client_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_oauth_client_id_fkey FOREIGN KEY (oauth_client_id) REFERENCES auth.oauth_clients(id) ON DELETE CASCADE;


--
-- TOC entry 5899 (class 2606 OID 16716)
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- TOC entry 5903 (class 2606 OID 16805)
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- TOC entry 5968 (class 2606 OID 40712)
-- Name: achievement_progress achievement_progress_achievement_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.achievement_progress
    ADD CONSTRAINT achievement_progress_achievement_id_fkey FOREIGN KEY (achievement_id) REFERENCES public.achievements(id) ON DELETE CASCADE;


--
-- TOC entry 5969 (class 2606 OID 40707)
-- Name: achievement_progress achievement_progress_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.achievement_progress
    ADD CONSTRAINT achievement_progress_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5931 (class 2606 OID 40265)
-- Name: app_events app_events_payment_intent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_events
    ADD CONSTRAINT app_events_payment_intent_id_fkey FOREIGN KEY (payment_intent_id) REFERENCES public.payment_intents(id) ON DELETE SET NULL;


--
-- TOC entry 5932 (class 2606 OID 40270)
-- Name: app_events app_events_ride_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_events
    ADD CONSTRAINT app_events_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE SET NULL;


--
-- TOC entry 5963 (class 2606 OID 40596)
-- Name: device_tokens device_tokens_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.device_tokens
    ADD CONSTRAINT device_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5965 (class 2606 OID 40641)
-- Name: driver_counters driver_counters_driver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.driver_counters
    ADD CONSTRAINT driver_counters_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(id) ON DELETE CASCADE;


--
-- TOC entry 6002 (class 2606 OID 41837)
-- Name: driver_leaderboard_daily driver_leaderboard_daily_driver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.driver_leaderboard_daily
    ADD CONSTRAINT driver_leaderboard_daily_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5933 (class 2606 OID 40275)
-- Name: driver_locations driver_locations_driver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.driver_locations
    ADD CONSTRAINT driver_locations_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(id) ON DELETE CASCADE;


--
-- TOC entry 5967 (class 2606 OID 40672)
-- Name: driver_rank_snapshots driver_rank_snapshots_driver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.driver_rank_snapshots
    ADD CONSTRAINT driver_rank_snapshots_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(id) ON DELETE CASCADE;


--
-- TOC entry 5966 (class 2606 OID 40654)
-- Name: driver_stats_daily driver_stats_daily_driver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.driver_stats_daily
    ADD CONSTRAINT driver_stats_daily_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(id) ON DELETE CASCADE;


--
-- TOC entry 5934 (class 2606 OID 40280)
-- Name: driver_vehicles driver_vehicles_driver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.driver_vehicles
    ADD CONSTRAINT driver_vehicles_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(id) ON DELETE CASCADE;


--
-- TOC entry 5935 (class 2606 OID 40285)
-- Name: drivers drivers_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.drivers
    ADD CONSTRAINT drivers_id_fkey FOREIGN KEY (id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5918 (class 2606 OID 40290)
-- Name: gift_codes gift_codes_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gift_codes
    ADD CONSTRAINT gift_codes_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id) ON DELETE SET NULL;


--
-- TOC entry 5919 (class 2606 OID 40295)
-- Name: gift_codes gift_codes_redeemed_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gift_codes
    ADD CONSTRAINT gift_codes_redeemed_by_fkey FOREIGN KEY (redeemed_by) REFERENCES public.profiles(id) ON DELETE SET NULL;


--
-- TOC entry 5920 (class 2606 OID 40300)
-- Name: gift_codes gift_codes_redeemed_entry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.gift_codes
    ADD CONSTRAINT gift_codes_redeemed_entry_id_fkey FOREIGN KEY (redeemed_entry_id) REFERENCES public.wallet_entries(id) ON DELETE SET NULL;


--
-- TOC entry 5992 (class 2606 OID 41422)
-- Name: kyc_documents kyc_documents_document_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kyc_documents
    ADD CONSTRAINT kyc_documents_document_type_id_fkey FOREIGN KEY (document_type_id) REFERENCES public.kyc_document_types(id) ON DELETE SET NULL;


--
-- TOC entry 5993 (class 2606 OID 41023)
-- Name: kyc_documents kyc_documents_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kyc_documents
    ADD CONSTRAINT kyc_documents_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.kyc_submissions(id) ON DELETE CASCADE;


--
-- TOC entry 5994 (class 2606 OID 41028)
-- Name: kyc_documents kyc_documents_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kyc_documents
    ADD CONSTRAINT kyc_documents_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5995 (class 2606 OID 41405)
-- Name: kyc_liveness_sessions kyc_liveness_sessions_submission_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kyc_liveness_sessions
    ADD CONSTRAINT kyc_liveness_sessions_submission_id_fkey FOREIGN KEY (submission_id) REFERENCES public.kyc_submissions(id) ON DELETE CASCADE;


--
-- TOC entry 5990 (class 2606 OID 41006)
-- Name: kyc_submissions kyc_submissions_reviewer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kyc_submissions
    ADD CONSTRAINT kyc_submissions_reviewer_id_fkey FOREIGN KEY (reviewer_id) REFERENCES public.profiles(id) ON DELETE SET NULL;


--
-- TOC entry 5991 (class 2606 OID 41001)
-- Name: kyc_submissions kyc_submissions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.kyc_submissions
    ADD CONSTRAINT kyc_submissions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5964 (class 2606 OID 40622)
-- Name: notification_outbox notification_outbox_notification_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_outbox
    ADD CONSTRAINT notification_outbox_notification_id_fkey FOREIGN KEY (notification_id) REFERENCES public.user_notifications(id) ON DELETE CASCADE;


--
-- TOC entry 5936 (class 2606 OID 40305)
-- Name: payment_intents payment_intents_ride_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_intents
    ADD CONSTRAINT payment_intents_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE CASCADE;


--
-- TOC entry 5937 (class 2606 OID 40310)
-- Name: payments payments_payment_intent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_payment_intent_id_fkey FOREIGN KEY (payment_intent_id) REFERENCES public.payment_intents(id) ON DELETE SET NULL;


--
-- TOC entry 5938 (class 2606 OID 40315)
-- Name: payments payments_ride_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE CASCADE;


--
-- TOC entry 5939 (class 2606 OID 40320)
-- Name: profile_kyc profile_kyc_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profile_kyc
    ADD CONSTRAINT profile_kyc_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.profiles(id) ON DELETE SET NULL;


--
-- TOC entry 5940 (class 2606 OID 40325)
-- Name: profile_kyc profile_kyc_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profile_kyc
    ADD CONSTRAINT profile_kyc_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5941 (class 2606 OID 40330)
-- Name: profiles profiles_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.profiles
    ADD CONSTRAINT profiles_id_fkey FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- TOC entry 5942 (class 2606 OID 40335)
-- Name: provider_events provider_events_provider_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.provider_events
    ADD CONSTRAINT provider_events_provider_code_fkey FOREIGN KEY (provider_code) REFERENCES public.payment_providers(code);


--
-- TOC entry 5962 (class 2606 OID 40574)
-- Name: public_profiles public_profiles_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.public_profiles
    ADD CONSTRAINT public_profiles_id_fkey FOREIGN KEY (id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5970 (class 2606 OID 40746)
-- Name: referral_codes referral_codes_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.referral_codes
    ADD CONSTRAINT referral_codes_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6000 (class 2606 OID 41806)
-- Name: referral_invites referral_invites_referred_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.referral_invites
    ADD CONSTRAINT referral_invites_referred_user_id_fkey FOREIGN KEY (referred_user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 6001 (class 2606 OID 41801)
-- Name: referral_invites referral_invites_referrer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.referral_invites
    ADD CONSTRAINT referral_invites_referrer_id_fkey FOREIGN KEY (referrer_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5971 (class 2606 OID 40765)
-- Name: referral_redemptions referral_redemptions_campaign_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.referral_redemptions
    ADD CONSTRAINT referral_redemptions_campaign_id_fkey FOREIGN KEY (campaign_id) REFERENCES public.referral_campaigns(id);


--
-- TOC entry 5972 (class 2606 OID 40775)
-- Name: referral_redemptions referral_redemptions_referred_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.referral_redemptions
    ADD CONSTRAINT referral_redemptions_referred_id_fkey FOREIGN KEY (referred_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5973 (class 2606 OID 40770)
-- Name: referral_redemptions referral_redemptions_referrer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.referral_redemptions
    ADD CONSTRAINT referral_redemptions_referrer_id_fkey FOREIGN KEY (referrer_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5981 (class 2606 OID 40900)
-- Name: ride_chat_messages ride_chat_messages_ride_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_chat_messages
    ADD CONSTRAINT ride_chat_messages_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE CASCADE;


--
-- TOC entry 5982 (class 2606 OID 40905)
-- Name: ride_chat_messages ride_chat_messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_chat_messages
    ADD CONSTRAINT ride_chat_messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5983 (class 2606 OID 40928)
-- Name: ride_chat_read_receipts ride_chat_read_receipts_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_chat_read_receipts
    ADD CONSTRAINT ride_chat_read_receipts_message_id_fkey FOREIGN KEY (message_id) REFERENCES public.ride_chat_messages(id) ON DELETE CASCADE;


--
-- TOC entry 5984 (class 2606 OID 40933)
-- Name: ride_chat_read_receipts ride_chat_read_receipts_reader_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_chat_read_receipts
    ADD CONSTRAINT ride_chat_read_receipts_reader_id_fkey FOREIGN KEY (reader_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5985 (class 2606 OID 40923)
-- Name: ride_chat_read_receipts ride_chat_read_receipts_ride_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_chat_read_receipts
    ADD CONSTRAINT ride_chat_read_receipts_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE CASCADE;


--
-- TOC entry 5997 (class 2606 OID 41760)
-- Name: ride_chat_threads ride_chat_threads_driver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_chat_threads
    ADD CONSTRAINT ride_chat_threads_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5998 (class 2606 OID 41750)
-- Name: ride_chat_threads ride_chat_threads_ride_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_chat_threads
    ADD CONSTRAINT ride_chat_threads_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE CASCADE;


--
-- TOC entry 5999 (class 2606 OID 41755)
-- Name: ride_chat_threads ride_chat_threads_rider_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_chat_threads
    ADD CONSTRAINT ride_chat_threads_rider_id_fkey FOREIGN KEY (rider_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5986 (class 2606 OID 40951)
-- Name: ride_chat_typing ride_chat_typing_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_chat_typing
    ADD CONSTRAINT ride_chat_typing_profile_id_fkey FOREIGN KEY (profile_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5987 (class 2606 OID 40946)
-- Name: ride_chat_typing ride_chat_typing_ride_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_chat_typing
    ADD CONSTRAINT ride_chat_typing_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE CASCADE;


--
-- TOC entry 5996 (class 2606 OID 41723)
-- Name: ride_completion_log ride_completion_log_ride_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_completion_log
    ADD CONSTRAINT ride_completion_log_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE CASCADE;


--
-- TOC entry 5943 (class 2606 OID 40340)
-- Name: ride_events ride_events_ride_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_events
    ADD CONSTRAINT ride_events_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE CASCADE;


--
-- TOC entry 5944 (class 2606 OID 40345)
-- Name: ride_incidents ride_incidents_assigned_to_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_incidents
    ADD CONSTRAINT ride_incidents_assigned_to_fkey FOREIGN KEY (assigned_to) REFERENCES public.profiles(id) ON DELETE SET NULL;


--
-- TOC entry 5945 (class 2606 OID 40350)
-- Name: ride_incidents ride_incidents_reporter_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_incidents
    ADD CONSTRAINT ride_incidents_reporter_id_fkey FOREIGN KEY (reporter_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5946 (class 2606 OID 40355)
-- Name: ride_incidents ride_incidents_ride_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_incidents
    ADD CONSTRAINT ride_incidents_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE CASCADE;


--
-- TOC entry 5947 (class 2606 OID 40360)
-- Name: ride_ratings ride_ratings_ratee_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_ratings
    ADD CONSTRAINT ride_ratings_ratee_id_fkey FOREIGN KEY (ratee_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5948 (class 2606 OID 40365)
-- Name: ride_ratings ride_ratings_rater_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_ratings
    ADD CONSTRAINT ride_ratings_rater_id_fkey FOREIGN KEY (rater_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5949 (class 2606 OID 40370)
-- Name: ride_ratings ride_ratings_ride_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_ratings
    ADD CONSTRAINT ride_ratings_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE CASCADE;


--
-- TOC entry 5950 (class 2606 OID 40375)
-- Name: ride_receipts ride_receipts_ride_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_receipts
    ADD CONSTRAINT ride_receipts_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE CASCADE;


--
-- TOC entry 5951 (class 2606 OID 40380)
-- Name: ride_requests ride_requests_assigned_driver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_requests
    ADD CONSTRAINT ride_requests_assigned_driver_id_fkey FOREIGN KEY (assigned_driver_id) REFERENCES public.drivers(id) ON DELETE SET NULL;


--
-- TOC entry 5952 (class 2606 OID 41213)
-- Name: ride_requests ride_requests_product_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_requests
    ADD CONSTRAINT ride_requests_product_code_fkey FOREIGN KEY (product_code) REFERENCES public.ride_products(code);


--
-- TOC entry 5953 (class 2606 OID 40385)
-- Name: ride_requests ride_requests_rider_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ride_requests
    ADD CONSTRAINT ride_requests_rider_id_fkey FOREIGN KEY (rider_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5921 (class 2606 OID 40390)
-- Name: rides rides_driver_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rides
    ADD CONSTRAINT rides_driver_id_fkey FOREIGN KEY (driver_id) REFERENCES public.drivers(id) ON DELETE CASCADE;


--
-- TOC entry 5922 (class 2606 OID 40395)
-- Name: rides rides_payment_intent_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rides
    ADD CONSTRAINT rides_payment_intent_id_fkey FOREIGN KEY (payment_intent_id) REFERENCES public.payment_intents(id) ON DELETE SET NULL;


--
-- TOC entry 5923 (class 2606 OID 41219)
-- Name: rides rides_product_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rides
    ADD CONSTRAINT rides_product_code_fkey FOREIGN KEY (product_code) REFERENCES public.ride_products(code);


--
-- TOC entry 5924 (class 2606 OID 40400)
-- Name: rides rides_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rides
    ADD CONSTRAINT rides_request_id_fkey FOREIGN KEY (request_id) REFERENCES public.ride_requests(id) ON DELETE CASCADE;


--
-- TOC entry 5925 (class 2606 OID 40405)
-- Name: rides rides_rider_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rides
    ADD CONSTRAINT rides_rider_id_fkey FOREIGN KEY (rider_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5926 (class 2606 OID 40410)
-- Name: rides rides_wallet_hold_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rides
    ADD CONSTRAINT rides_wallet_hold_id_fkey FOREIGN KEY (wallet_hold_id) REFERENCES public.wallet_holds(id) ON DELETE SET NULL;


--
-- TOC entry 5979 (class 2606 OID 40875)
-- Name: support_messages support_messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.support_messages
    ADD CONSTRAINT support_messages_sender_id_fkey FOREIGN KEY (sender_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5980 (class 2606 OID 40870)
-- Name: support_messages support_messages_ticket_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.support_messages
    ADD CONSTRAINT support_messages_ticket_id_fkey FOREIGN KEY (ticket_id) REFERENCES public.support_tickets(id) ON DELETE CASCADE;


--
-- TOC entry 5975 (class 2606 OID 40850)
-- Name: support_tickets support_tickets_category_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.support_tickets
    ADD CONSTRAINT support_tickets_category_code_fkey FOREIGN KEY (category_code) REFERENCES public.support_categories(code);


--
-- TOC entry 5976 (class 2606 OID 41332)
-- Name: support_tickets support_tickets_category_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.support_tickets
    ADD CONSTRAINT support_tickets_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.support_categories(id) ON DELETE SET NULL;


--
-- TOC entry 5977 (class 2606 OID 40845)
-- Name: support_tickets support_tickets_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.support_tickets
    ADD CONSTRAINT support_tickets_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5978 (class 2606 OID 40855)
-- Name: support_tickets support_tickets_ride_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.support_tickets
    ADD CONSTRAINT support_tickets_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE SET NULL;


--
-- TOC entry 5927 (class 2606 OID 40415)
-- Name: topup_intents topup_intents_package_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.topup_intents
    ADD CONSTRAINT topup_intents_package_id_fkey FOREIGN KEY (package_id) REFERENCES public.topup_packages(id);


--
-- TOC entry 5928 (class 2606 OID 40420)
-- Name: topup_intents topup_intents_provider_code_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.topup_intents
    ADD CONSTRAINT topup_intents_provider_code_fkey FOREIGN KEY (provider_code) REFERENCES public.payment_providers(code);


--
-- TOC entry 5929 (class 2606 OID 40425)
-- Name: topup_intents topup_intents_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.topup_intents
    ADD CONSTRAINT topup_intents_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5988 (class 2606 OID 40977)
-- Name: trip_share_tokens trip_share_tokens_created_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trip_share_tokens
    ADD CONSTRAINT trip_share_tokens_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5989 (class 2606 OID 40972)
-- Name: trip_share_tokens trip_share_tokens_ride_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trip_share_tokens
    ADD CONSTRAINT trip_share_tokens_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE CASCADE;


--
-- TOC entry 5974 (class 2606 OID 40800)
-- Name: trusted_contacts trusted_contacts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.trusted_contacts
    ADD CONSTRAINT trusted_contacts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5954 (class 2606 OID 40430)
-- Name: user_notifications user_notifications_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_notifications
    ADD CONSTRAINT user_notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5930 (class 2606 OID 40435)
-- Name: wallet_accounts wallet_accounts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallet_accounts
    ADD CONSTRAINT wallet_accounts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5955 (class 2606 OID 40440)
-- Name: wallet_entries wallet_entries_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallet_entries
    ADD CONSTRAINT wallet_entries_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5956 (class 2606 OID 40445)
-- Name: wallet_holds wallet_holds_ride_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallet_holds
    ADD CONSTRAINT wallet_holds_ride_id_fkey FOREIGN KEY (ride_id) REFERENCES public.rides(id) ON DELETE SET NULL;


--
-- TOC entry 5957 (class 2606 OID 40450)
-- Name: wallet_holds wallet_holds_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallet_holds
    ADD CONSTRAINT wallet_holds_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5958 (class 2606 OID 40455)
-- Name: wallet_holds wallet_holds_withdraw_request_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallet_holds
    ADD CONSTRAINT wallet_holds_withdraw_request_id_fkey FOREIGN KEY (withdraw_request_id) REFERENCES public.wallet_withdraw_requests(id) ON DELETE SET NULL;


--
-- TOC entry 5959 (class 2606 OID 40460)
-- Name: wallet_withdraw_payout_methods wallet_withdraw_payout_methods_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallet_withdraw_payout_methods
    ADD CONSTRAINT wallet_withdraw_payout_methods_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.profiles(id) ON DELETE SET NULL;


--
-- TOC entry 5960 (class 2606 OID 40465)
-- Name: wallet_withdraw_requests wallet_withdraw_requests_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallet_withdraw_requests
    ADD CONSTRAINT wallet_withdraw_requests_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE;


--
-- TOC entry 5961 (class 2606 OID 40470)
-- Name: wallet_withdrawal_policy wallet_withdrawal_policy_updated_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.wallet_withdrawal_policy
    ADD CONSTRAINT wallet_withdrawal_policy_updated_by_fkey FOREIGN KEY (updated_by) REFERENCES public.profiles(id) ON DELETE SET NULL;


--
-- TOC entry 5912 (class 2606 OID 17285)
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- TOC entry 5916 (class 2606 OID 17387)
-- Name: prefixes prefixes_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.prefixes
    ADD CONSTRAINT "prefixes_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- TOC entry 5913 (class 2606 OID 17333)
-- Name: s3_multipart_uploads s3_multipart_uploads_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads
    ADD CONSTRAINT s3_multipart_uploads_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- TOC entry 5914 (class 2606 OID 17353)
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- TOC entry 5915 (class 2606 OID 17348)
-- Name: s3_multipart_uploads_parts s3_multipart_uploads_parts_upload_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.s3_multipart_uploads_parts
    ADD CONSTRAINT s3_multipart_uploads_parts_upload_id_fkey FOREIGN KEY (upload_id) REFERENCES storage.s3_multipart_uploads(id) ON DELETE CASCADE;


--
-- TOC entry 5917 (class 2606 OID 17469)
-- Name: vector_indexes vector_indexes_bucket_id_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.vector_indexes
    ADD CONSTRAINT vector_indexes_bucket_id_fkey FOREIGN KEY (bucket_id) REFERENCES storage.buckets_vectors(id);


--
-- TOC entry 6211 (class 0 OID 16525)
-- Dependencies: 355
-- Name: audit_log_entries; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.audit_log_entries ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6222 (class 0 OID 16883)
-- Dependencies: 369
-- Name: flow_state; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.flow_state ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6213 (class 0 OID 16681)
-- Dependencies: 360
-- Name: identities; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.identities ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6210 (class 0 OID 16518)
-- Dependencies: 354
-- Name: instances; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.instances ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6217 (class 0 OID 16770)
-- Dependencies: 364
-- Name: mfa_amr_claims; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_amr_claims ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6216 (class 0 OID 16758)
-- Dependencies: 363
-- Name: mfa_challenges; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_challenges ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6215 (class 0 OID 16745)
-- Dependencies: 362
-- Name: mfa_factors; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.mfa_factors ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6223 (class 0 OID 16933)
-- Dependencies: 370
-- Name: one_time_tokens; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.one_time_tokens ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6209 (class 0 OID 16507)
-- Dependencies: 353
-- Name: refresh_tokens; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.refresh_tokens ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6220 (class 0 OID 16812)
-- Dependencies: 367
-- Name: saml_providers; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.saml_providers ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6221 (class 0 OID 16830)
-- Dependencies: 368
-- Name: saml_relay_states; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.saml_relay_states ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6212 (class 0 OID 16533)
-- Dependencies: 356
-- Name: schema_migrations; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.schema_migrations ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6214 (class 0 OID 16711)
-- Dependencies: 361
-- Name: sessions; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sessions ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6219 (class 0 OID 16797)
-- Dependencies: 366
-- Name: sso_domains; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sso_domains ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6218 (class 0 OID 16788)
-- Dependencies: 365
-- Name: sso_providers; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.sso_providers ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6208 (class 0 OID 16495)
-- Dependencies: 351
-- Name: users; Type: ROW SECURITY; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE auth.users ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6269 (class 0 OID 40696)
-- Dependencies: 451
-- Name: achievement_progress; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.achievement_progress ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6268 (class 0 OID 40681)
-- Dependencies: 450
-- Name: achievements; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.achievements ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6238 (class 0 OID 39843)
-- Dependencies: 415
-- Name: api_rate_limits; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.api_rate_limits ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6239 (class 0 OID 39849)
-- Dependencies: 416
-- Name: app_events; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.app_events ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6263 (class 0 OID 40583)
-- Dependencies: 444
-- Name: device_tokens; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.device_tokens ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6295 (class 3256 OID 42012)
-- Name: device_tokens device_tokens_delete_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY device_tokens_delete_own ON public.device_tokens FOR DELETE TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6293 (class 3256 OID 42010)
-- Name: device_tokens device_tokens_insert_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY device_tokens_insert_own ON public.device_tokens FOR INSERT TO authenticated WITH CHECK ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6292 (class 3256 OID 42009)
-- Name: device_tokens device_tokens_select_own_or_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY device_tokens_select_own_or_admin ON public.device_tokens FOR SELECT TO authenticated USING (((user_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6294 (class 3256 OID 42011)
-- Name: device_tokens device_tokens_update_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY device_tokens_update_own ON public.device_tokens FOR UPDATE TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid))) WITH CHECK ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6265 (class 0 OID 40633)
-- Dependencies: 447
-- Name: driver_counters; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.driver_counters ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6291 (class 0 OID 41825)
-- Dependencies: 475
-- Name: driver_leaderboard_daily; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.driver_leaderboard_daily ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6296 (class 3256 OID 42013)
-- Name: driver_leaderboard_daily driver_leaderboard_daily_select_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY driver_leaderboard_daily_select_all ON public.driver_leaderboard_daily FOR SELECT TO authenticated USING (true);


--
-- TOC entry 6240 (class 0 OID 39858)
-- Dependencies: 417
-- Name: driver_locations; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.driver_locations ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6267 (class 0 OID 40660)
-- Dependencies: 449
-- Name: driver_rank_snapshots; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.driver_rank_snapshots ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6297 (class 3256 OID 42014)
-- Name: driver_rank_snapshots driver_rank_snapshots_select_authenticated; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY driver_rank_snapshots_select_authenticated ON public.driver_rank_snapshots FOR SELECT TO authenticated USING (true);


--
-- TOC entry 6266 (class 0 OID 40646)
-- Dependencies: 448
-- Name: driver_stats_daily; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.driver_stats_daily ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6298 (class 3256 OID 42015)
-- Name: driver_stats_daily driver_stats_daily_select_own_or_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY driver_stats_daily_select_own_or_admin ON public.driver_stats_daily FOR SELECT TO authenticated USING (((driver_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6241 (class 0 OID 39868)
-- Dependencies: 418
-- Name: driver_vehicles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.driver_vehicles ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6242 (class 0 OID 39876)
-- Dependencies: 419
-- Name: drivers; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.drivers ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6462 (class 3256 OID 42214)
-- Name: drivers drivers_insert_self; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY drivers_insert_self ON public.drivers FOR INSERT TO authenticated WITH CHECK ((( SELECT auth.uid() AS uid) IS NOT NULL));


--
-- TOC entry 6461 (class 3256 OID 42213)
-- Name: drivers drivers_select_self; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY drivers_select_self ON public.drivers FOR SELECT TO authenticated USING ((id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6463 (class 3256 OID 42215)
-- Name: drivers drivers_update_self; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY drivers_update_self ON public.drivers FOR UPDATE TO authenticated USING ((id = ( SELECT auth.uid() AS uid))) WITH CHECK ((id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6234 (class 0 OID 39757)
-- Dependencies: 411
-- Name: gift_codes; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.gift_codes ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6303 (class 3256 OID 42019)
-- Name: gift_codes gift_codes_admin_delete; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY gift_codes_admin_delete ON public.gift_codes FOR DELETE TO authenticated USING (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6301 (class 3256 OID 42017)
-- Name: gift_codes gift_codes_admin_insert; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY gift_codes_admin_insert ON public.gift_codes FOR INSERT TO authenticated WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6302 (class 3256 OID 42018)
-- Name: gift_codes gift_codes_admin_update; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY gift_codes_admin_update ON public.gift_codes FOR UPDATE TO authenticated USING (( SELECT public.is_admin() AS is_admin)) WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6300 (class 3256 OID 42016)
-- Name: gift_codes gift_codes_select_admin_or_redeemer_or_creator; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY gift_codes_select_admin_or_redeemer_or_creator ON public.gift_codes FOR SELECT TO authenticated USING ((( SELECT public.is_admin() AS is_admin) OR (redeemed_by = ( SELECT auth.uid() AS uid)) OR (created_by = ( SELECT auth.uid() AS uid))));


--
-- TOC entry 6284 (class 0 OID 41373)
-- Dependencies: 466
-- Name: kyc_document_types; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.kyc_document_types ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6282 (class 0 OID 41012)
-- Dependencies: 464
-- Name: kyc_documents; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.kyc_documents ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6309 (class 3256 OID 42024)
-- Name: kyc_documents kyc_documents_delete_owner_or_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY kyc_documents_delete_owner_or_admin ON public.kyc_documents FOR DELETE TO authenticated USING (((user_id = ( SELECT auth.uid() AS uid)) OR (profile_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6305 (class 3256 OID 42021)
-- Name: kyc_documents kyc_documents_insert_owner; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY kyc_documents_insert_owner ON public.kyc_documents FOR INSERT TO authenticated WITH CHECK (((user_id = ( SELECT auth.uid() AS uid)) OR (profile_id = ( SELECT auth.uid() AS uid))));


--
-- TOC entry 6304 (class 3256 OID 42020)
-- Name: kyc_documents kyc_documents_select_owner_or_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY kyc_documents_select_owner_or_admin ON public.kyc_documents FOR SELECT TO authenticated USING (((user_id = ( SELECT auth.uid() AS uid)) OR (profile_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6307 (class 3256 OID 42022)
-- Name: kyc_documents kyc_documents_update_owner_or_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY kyc_documents_update_owner_or_admin ON public.kyc_documents FOR UPDATE TO authenticated USING (((user_id = ( SELECT auth.uid() AS uid)) OR (profile_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin))) WITH CHECK (((user_id = ( SELECT auth.uid() AS uid)) OR (profile_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6285 (class 0 OID 41392)
-- Dependencies: 467
-- Name: kyc_liveness_sessions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.kyc_liveness_sessions ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6281 (class 0 OID 40989)
-- Dependencies: 463
-- Name: kyc_submissions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.kyc_submissions ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6313 (class 3256 OID 42029)
-- Name: kyc_submissions kyc_submissions_delete_owner_or_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY kyc_submissions_delete_owner_or_admin ON public.kyc_submissions FOR DELETE TO authenticated USING (((user_id = ( SELECT auth.uid() AS uid)) OR (profile_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6311 (class 3256 OID 42026)
-- Name: kyc_submissions kyc_submissions_insert_owner; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY kyc_submissions_insert_owner ON public.kyc_submissions FOR INSERT TO authenticated WITH CHECK (((user_id = ( SELECT auth.uid() AS uid)) OR (profile_id = ( SELECT auth.uid() AS uid))));


--
-- TOC entry 6310 (class 3256 OID 42025)
-- Name: kyc_submissions kyc_submissions_select_owner_or_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY kyc_submissions_select_owner_or_admin ON public.kyc_submissions FOR SELECT TO authenticated USING (((user_id = ( SELECT auth.uid() AS uid)) OR (profile_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6312 (class 3256 OID 42027)
-- Name: kyc_submissions kyc_submissions_update_owner_or_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY kyc_submissions_update_owner_or_admin ON public.kyc_submissions FOR UPDATE TO authenticated USING (((user_id = ( SELECT auth.uid() AS uid)) OR (profile_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin))) WITH CHECK (((user_id = ( SELECT auth.uid() AS uid)) OR (profile_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6264 (class 0 OID 40608)
-- Dependencies: 446
-- Name: notification_outbox; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.notification_outbox ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6243 (class 0 OID 39887)
-- Dependencies: 420
-- Name: payment_intents; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.payment_intents ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6478 (class 3256 OID 42244)
-- Name: payment_intents payment_intents_select_anon_none; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY payment_intents_select_anon_none ON public.payment_intents FOR SELECT TO anon USING (false);


--
-- TOC entry 6477 (class 3256 OID 42243)
-- Name: payment_intents payment_intents_select_participants; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY payment_intents_select_participants ON public.payment_intents FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.rides r
  WHERE ((r.id = payment_intents.ride_id) AND ((r.rider_id = ( SELECT auth.uid() AS uid)) OR (r.driver_id = ( SELECT auth.uid() AS uid)))))));


--
-- TOC entry 6244 (class 0 OID 39899)
-- Dependencies: 421
-- Name: payment_providers; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.payment_providers ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6447 (class 3256 OID 42198)
-- Name: payment_providers payment_providers_delete_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY payment_providers_delete_admin ON public.payment_providers FOR DELETE TO authenticated USING (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6441 (class 3256 OID 42196)
-- Name: payment_providers payment_providers_insert_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY payment_providers_insert_admin ON public.payment_providers FOR INSERT TO authenticated WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6435 (class 3256 OID 42195)
-- Name: payment_providers payment_providers_select_public; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY payment_providers_select_public ON public.payment_providers FOR SELECT TO authenticated, anon USING (true);


--
-- TOC entry 6446 (class 3256 OID 42197)
-- Name: payment_providers payment_providers_update_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY payment_providers_update_admin ON public.payment_providers FOR UPDATE TO authenticated USING (( SELECT public.is_admin() AS is_admin)) WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6245 (class 0 OID 39909)
-- Dependencies: 422
-- Name: payments; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6480 (class 3256 OID 42246)
-- Name: payments payments_select_anon_none; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY payments_select_anon_none ON public.payments FOR SELECT TO anon USING (false);


--
-- TOC entry 6479 (class 3256 OID 42245)
-- Name: payments payments_select_participants; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY payments_select_participants ON public.payments FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.rides r
  WHERE ((r.id = payments.ride_id) AND ((r.rider_id = ( SELECT auth.uid() AS uid)) OR (r.driver_id = ( SELECT auth.uid() AS uid)))))));


--
-- TOC entry 6246 (class 0 OID 39919)
-- Dependencies: 423
-- Name: pricing_configs; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.pricing_configs ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6247 (class 0 OID 39933)
-- Dependencies: 424
-- Name: profile_kyc; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.profile_kyc ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6248 (class 0 OID 39940)
-- Dependencies: 425
-- Name: profiles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6314 (class 3256 OID 42030)
-- Name: profiles profiles_insert_self; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY profiles_insert_self ON public.profiles FOR INSERT TO authenticated WITH CHECK ((id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6315 (class 3256 OID 42031)
-- Name: profiles profiles_select_own_or_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY profiles_select_own_or_admin ON public.profiles FOR SELECT TO authenticated USING (((id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6316 (class 3256 OID 42032)
-- Name: profiles profiles_update_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY profiles_update_own ON public.profiles FOR UPDATE TO authenticated USING ((id = ( SELECT auth.uid() AS uid))) WITH CHECK ((id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6249 (class 0 OID 39950)
-- Dependencies: 426
-- Name: provider_events; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.provider_events ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6483 (class 3256 OID 42249)
-- Name: provider_events provider_events_admin_insert; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY provider_events_admin_insert ON public.provider_events FOR INSERT TO authenticated WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6453 (class 3256 OID 42203)
-- Name: provider_events provider_events_select_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY provider_events_select_admin ON public.provider_events FOR SELECT TO authenticated USING (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6454 (class 3256 OID 42204)
-- Name: provider_events provider_events_select_anon_none; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY provider_events_select_anon_none ON public.provider_events FOR SELECT TO anon USING (false);


--
-- TOC entry 6262 (class 0 OID 40563)
-- Dependencies: 442
-- Name: public_profiles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.public_profiles ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6317 (class 3256 OID 42033)
-- Name: public_profiles public_profiles_select_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY public_profiles_select_all ON public.public_profiles FOR SELECT TO authenticated USING (true);


--
-- TOC entry 6270 (class 0 OID 40722)
-- Dependencies: 452
-- Name: referral_campaigns; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.referral_campaigns ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6271 (class 0 OID 40736)
-- Dependencies: 453
-- Name: referral_codes; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.referral_codes ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6290 (class 0 OID 41788)
-- Dependencies: 474
-- Name: referral_invites; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.referral_invites ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6272 (class 0 OID 40752)
-- Dependencies: 454
-- Name: referral_redemptions; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.referral_redemptions ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6289 (class 0 OID 41777)
-- Dependencies: 473
-- Name: referral_settings; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.referral_settings ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6277 (class 0 OID 40890)
-- Dependencies: 459
-- Name: ride_chat_messages; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.ride_chat_messages ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6322 (class 3256 OID 42037)
-- Name: ride_chat_messages ride_chat_messages_delete_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY ride_chat_messages_delete_own ON public.ride_chat_messages FOR DELETE TO authenticated USING ((sender_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6320 (class 3256 OID 42035)
-- Name: ride_chat_messages ride_chat_messages_insert_sender; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY ride_chat_messages_insert_sender ON public.ride_chat_messages FOR INSERT TO authenticated WITH CHECK (((sender_id = ( SELECT auth.uid() AS uid)) AND (EXISTS ( SELECT 1
   FROM public.ride_chat_threads t
  WHERE ((t.id = ride_chat_messages.thread_id) AND (t.ride_id = ride_chat_messages.ride_id) AND ((t.rider_id = ( SELECT auth.uid() AS uid)) OR (t.driver_id = ( SELECT auth.uid() AS uid))))))));


--
-- TOC entry 6318 (class 3256 OID 42034)
-- Name: ride_chat_messages ride_chat_messages_select_participants; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY ride_chat_messages_select_participants ON public.ride_chat_messages FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.ride_chat_threads t
  WHERE ((t.id = ride_chat_messages.thread_id) AND ((t.rider_id = ( SELECT auth.uid() AS uid)) OR (t.driver_id = ( SELECT auth.uid() AS uid)))))));


--
-- TOC entry 6321 (class 3256 OID 42036)
-- Name: ride_chat_messages ride_chat_messages_update_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY ride_chat_messages_update_own ON public.ride_chat_messages FOR UPDATE TO authenticated USING ((sender_id = ( SELECT auth.uid() AS uid))) WITH CHECK ((sender_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6323 (class 3256 OID 42038)
-- Name: ride_chat_read_receipts ride_chat_read_insert_self; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY ride_chat_read_insert_self ON public.ride_chat_read_receipts FOR INSERT TO authenticated WITH CHECK (((reader_id = ( SELECT auth.uid() AS uid)) AND (EXISTS ( SELECT 1
   FROM (public.ride_chat_messages m
     JOIN public.rides r ON ((r.id = m.ride_id)))
  WHERE ((m.id = ride_chat_read_receipts.message_id) AND (m.ride_id = ride_chat_read_receipts.ride_id) AND ((r.rider_id = ( SELECT auth.uid() AS uid)) OR (r.driver_id = ( SELECT auth.uid() AS uid))))))));


--
-- TOC entry 6278 (class 0 OID 40914)
-- Dependencies: 460
-- Name: ride_chat_read_receipts; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.ride_chat_read_receipts ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6324 (class 3256 OID 42040)
-- Name: ride_chat_read_receipts ride_chat_read_select_participants; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY ride_chat_read_select_participants ON public.ride_chat_read_receipts FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.ride_chat_threads t
  WHERE ((t.id = ride_chat_read_receipts.thread_id) AND ((t.rider_id = ( SELECT auth.uid() AS uid)) OR (t.driver_id = ( SELECT auth.uid() AS uid)))))));


--
-- TOC entry 6288 (class 0 OID 41740)
-- Dependencies: 472
-- Name: ride_chat_threads; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.ride_chat_threads ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6279 (class 0 OID 40939)
-- Dependencies: 461
-- Name: ride_chat_typing; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.ride_chat_typing ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6287 (class 0 OID 41717)
-- Dependencies: 471
-- Name: ride_completion_log; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.ride_completion_log ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6250 (class 0 OID 39958)
-- Dependencies: 428
-- Name: ride_events; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.ride_events ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6251 (class 0 OID 39966)
-- Dependencies: 430
-- Name: ride_incidents; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.ride_incidents ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6458 (class 3256 OID 42208)
-- Name: ride_incidents ride_incidents_insert_reporter; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY ride_incidents_insert_reporter ON public.ride_incidents FOR INSERT TO authenticated WITH CHECK (((reporter_id = ( SELECT auth.uid() AS uid)) AND (EXISTS ( SELECT 1
   FROM public.rides r
  WHERE ((r.id = ride_incidents.ride_id) AND ((r.rider_id = ( SELECT auth.uid() AS uid)) OR (r.driver_id = ( SELECT auth.uid() AS uid))))))));


--
-- TOC entry 6460 (class 3256 OID 42210)
-- Name: ride_incidents ride_incidents_select_anon_none; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY ride_incidents_select_anon_none ON public.ride_incidents FOR SELECT TO anon USING (false);


--
-- TOC entry 6457 (class 3256 OID 42207)
-- Name: ride_incidents ride_incidents_select_participant; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY ride_incidents_select_participant ON public.ride_incidents FOR SELECT TO authenticated USING (((reporter_id = ( SELECT auth.uid() AS uid)) OR (assigned_to = ( SELECT auth.uid() AS uid)) OR (EXISTS ( SELECT 1
   FROM public.rides r
  WHERE ((r.id = ride_incidents.ride_id) AND ((r.rider_id = ( SELECT auth.uid() AS uid)) OR (r.driver_id = ( SELECT auth.uid() AS uid))))))));


--
-- TOC entry 6459 (class 3256 OID 42209)
-- Name: ride_incidents ride_incidents_update_reporter_or_assignee; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY ride_incidents_update_reporter_or_assignee ON public.ride_incidents FOR UPDATE TO authenticated USING (((reporter_id = ( SELECT auth.uid() AS uid)) OR (assigned_to = ( SELECT auth.uid() AS uid)))) WITH CHECK (((reporter_id = ( SELECT auth.uid() AS uid)) OR (assigned_to = ( SELECT auth.uid() AS uid))));


--
-- TOC entry 6283 (class 0 OID 41198)
-- Dependencies: 465
-- Name: ride_products; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.ride_products ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6252 (class 0 OID 39976)
-- Dependencies: 431
-- Name: ride_ratings; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.ride_ratings ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6482 (class 3256 OID 42248)
-- Name: ride_ratings ride_ratings_select_anon_none; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY ride_ratings_select_anon_none ON public.ride_ratings FOR SELECT TO anon USING (false);


--
-- TOC entry 6481 (class 3256 OID 42247)
-- Name: ride_ratings ride_ratings_select_participants; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY ride_ratings_select_participants ON public.ride_ratings FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.rides r
  WHERE ((r.id = ride_ratings.ride_id) AND ((r.rider_id = ( SELECT auth.uid() AS uid)) OR (r.driver_id = ( SELECT auth.uid() AS uid)))))));


--
-- TOC entry 6253 (class 0 OID 39984)
-- Dependencies: 432
-- Name: ride_receipts; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.ride_receipts ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6456 (class 3256 OID 42206)
-- Name: ride_receipts ride_receipts_select_anon_none; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY ride_receipts_select_anon_none ON public.ride_receipts FOR SELECT TO anon USING (false);


--
-- TOC entry 6455 (class 3256 OID 42205)
-- Name: ride_receipts ride_receipts_select_participant; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY ride_receipts_select_participant ON public.ride_receipts FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.rides r
  WHERE ((r.id = ride_receipts.ride_id) AND ((r.rider_id = ( SELECT auth.uid() AS uid)) OR (r.driver_id = ( SELECT auth.uid() AS uid)))))));


--
-- TOC entry 6254 (class 0 OID 39995)
-- Dependencies: 433
-- Name: ride_requests; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.ride_requests ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6325 (class 3256 OID 42041)
-- Name: ride_requests ride_requests_insert_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY ride_requests_insert_own ON public.ride_requests FOR INSERT TO authenticated WITH CHECK ((rider_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6326 (class 3256 OID 42042)
-- Name: ride_requests ride_requests_select_own_or_assigned_driver; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY ride_requests_select_own_or_assigned_driver ON public.ride_requests FOR SELECT TO authenticated USING (((rider_id = ( SELECT auth.uid() AS uid)) OR (assigned_driver_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6327 (class 3256 OID 42043)
-- Name: ride_requests ride_requests_update_own_cancel; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY ride_requests_update_own_cancel ON public.ride_requests FOR UPDATE TO authenticated USING (((rider_id = ( SELECT auth.uid() AS uid)) AND (status = ANY (ARRAY['requested'::public.ride_request_status, 'matched'::public.ride_request_status])))) WITH CHECK (((rider_id = ( SELECT auth.uid() AS uid)) AND (status = 'cancelled'::public.ride_request_status)));


--
-- TOC entry 6235 (class 0 OID 39794)
-- Dependencies: 412
-- Name: rides; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.rides ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6360 (class 3256 OID 42091)
-- Name: achievement_progress rls_delete; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_delete ON public.achievement_progress FOR DELETE TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6368 (class 3256 OID 42104)
-- Name: driver_locations rls_delete; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_delete ON public.driver_locations FOR DELETE TO authenticated USING ((driver_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6376 (class 3256 OID 42109)
-- Name: driver_vehicles rls_delete; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_delete ON public.driver_vehicles FOR DELETE TO authenticated USING ((driver_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6383 (class 3256 OID 42118)
-- Name: kyc_liveness_sessions rls_delete; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_delete ON public.kyc_liveness_sessions FOR DELETE TO authenticated USING ((profile_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6390 (class 3256 OID 42133)
-- Name: profile_kyc rls_delete; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_delete ON public.profile_kyc FOR DELETE TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6397 (class 3256 OID 42142)
-- Name: referral_codes rls_delete; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_delete ON public.referral_codes FOR DELETE TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6408 (class 3256 OID 42153)
-- Name: ride_chat_threads rls_delete; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_delete ON public.ride_chat_threads FOR DELETE TO authenticated USING (((driver_id = ( SELECT auth.uid() AS uid)) OR (rider_id = ( SELECT auth.uid() AS uid))));


--
-- TOC entry 6415 (class 3256 OID 42158)
-- Name: ride_chat_typing rls_delete; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_delete ON public.ride_chat_typing FOR DELETE TO authenticated USING ((profile_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6422 (class 3256 OID 42165)
-- Name: ride_events rls_delete; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_delete ON public.ride_events FOR DELETE TO authenticated USING ((actor_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6430 (class 3256 OID 42178)
-- Name: rides rls_delete; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_delete ON public.rides FOR DELETE TO authenticated USING (((driver_id = ( SELECT auth.uid() AS uid)) OR (rider_id = ( SELECT auth.uid() AS uid))));


--
-- TOC entry 6439 (class 3256 OID 42187)
-- Name: user_device_tokens rls_delete; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_delete ON public.user_device_tokens FOR DELETE TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6445 (class 3256 OID 42192)
-- Name: wallet_accounts rls_delete; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_delete ON public.wallet_accounts FOR DELETE TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6364 (class 3256 OID 42095)
-- Name: api_rate_limits rls_deny_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_deny_all ON public.api_rate_limits TO authenticated, anon USING (false) WITH CHECK (false);


--
-- TOC entry 6343 (class 3256 OID 42097)
-- Name: app_events rls_deny_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_deny_all ON public.app_events TO authenticated, anon USING (false) WITH CHECK (false);


--
-- TOC entry 6355 (class 3256 OID 42099)
-- Name: driver_counters rls_deny_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_deny_all ON public.driver_counters TO authenticated, anon USING (false) WITH CHECK (false);


--
-- TOC entry 6385 (class 3256 OID 42120)
-- Name: notification_outbox rls_deny_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_deny_all ON public.notification_outbox TO authenticated, anon USING (false) WITH CHECK (false);


--
-- TOC entry 6399 (class 3256 OID 42144)
-- Name: referral_invites rls_deny_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_deny_all ON public.referral_invites TO authenticated, anon USING (false) WITH CHECK (false);


--
-- TOC entry 6401 (class 3256 OID 42146)
-- Name: referral_redemptions rls_deny_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_deny_all ON public.referral_redemptions TO authenticated, anon USING (false) WITH CHECK (false);


--
-- TOC entry 6417 (class 3256 OID 42160)
-- Name: ride_completion_log rls_deny_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_deny_all ON public.ride_completion_log TO authenticated, anon USING (false) WITH CHECK (false);


--
-- TOC entry 6358 (class 3256 OID 42089)
-- Name: achievement_progress rls_insert; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_insert ON public.achievement_progress FOR INSERT TO authenticated WITH CHECK ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6366 (class 3256 OID 42102)
-- Name: driver_locations rls_insert; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_insert ON public.driver_locations FOR INSERT TO authenticated WITH CHECK ((driver_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6374 (class 3256 OID 42107)
-- Name: driver_vehicles rls_insert; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_insert ON public.driver_vehicles FOR INSERT TO authenticated WITH CHECK ((driver_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6381 (class 3256 OID 42116)
-- Name: kyc_liveness_sessions rls_insert; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_insert ON public.kyc_liveness_sessions FOR INSERT TO authenticated WITH CHECK ((profile_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6388 (class 3256 OID 42131)
-- Name: profile_kyc rls_insert; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_insert ON public.profile_kyc FOR INSERT TO authenticated WITH CHECK ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6395 (class 3256 OID 42140)
-- Name: referral_codes rls_insert; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_insert ON public.referral_codes FOR INSERT TO authenticated WITH CHECK ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6406 (class 3256 OID 42151)
-- Name: ride_chat_threads rls_insert; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_insert ON public.ride_chat_threads FOR INSERT TO authenticated WITH CHECK (((driver_id = ( SELECT auth.uid() AS uid)) OR (rider_id = ( SELECT auth.uid() AS uid))));


--
-- TOC entry 6413 (class 3256 OID 42156)
-- Name: ride_chat_typing rls_insert; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_insert ON public.ride_chat_typing FOR INSERT TO authenticated WITH CHECK ((profile_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6420 (class 3256 OID 42163)
-- Name: ride_events rls_insert; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_insert ON public.ride_events FOR INSERT TO authenticated WITH CHECK ((actor_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6428 (class 3256 OID 42176)
-- Name: rides rls_insert; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_insert ON public.rides FOR INSERT TO authenticated WITH CHECK (((driver_id = ( SELECT auth.uid() AS uid)) OR (rider_id = ( SELECT auth.uid() AS uid))));


--
-- TOC entry 6437 (class 3256 OID 42185)
-- Name: user_device_tokens rls_insert; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_insert ON public.user_device_tokens FOR INSERT TO authenticated WITH CHECK ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6443 (class 3256 OID 42190)
-- Name: wallet_accounts rls_insert; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_insert ON public.wallet_accounts FOR INSERT TO authenticated WITH CHECK ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6362 (class 3256 OID 42093)
-- Name: achievements rls_public_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_public_select ON public.achievements FOR SELECT TO authenticated, anon USING (true);


--
-- TOC entry 6379 (class 3256 OID 42113)
-- Name: kyc_document_types rls_public_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_public_select ON public.kyc_document_types FOR SELECT TO authenticated, anon USING (true);


--
-- TOC entry 6332 (class 3256 OID 42128)
-- Name: pricing_configs rls_public_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_public_select ON public.pricing_configs FOR SELECT TO authenticated, anon USING (true);


--
-- TOC entry 6393 (class 3256 OID 42137)
-- Name: referral_campaigns rls_public_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_public_select ON public.referral_campaigns FOR SELECT TO authenticated, anon USING (true);


--
-- TOC entry 6403 (class 3256 OID 42148)
-- Name: referral_settings rls_public_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_public_select ON public.referral_settings FOR SELECT TO authenticated, anon USING (true);


--
-- TOC entry 6425 (class 3256 OID 42169)
-- Name: ride_products rls_public_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_public_select ON public.ride_products FOR SELECT TO authenticated, anon USING (true);


--
-- TOC entry 6432 (class 3256 OID 42180)
-- Name: support_categories rls_public_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_public_select ON public.support_categories FOR SELECT TO authenticated, anon USING (true);


--
-- TOC entry 6357 (class 3256 OID 42088)
-- Name: achievement_progress rls_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_select ON public.achievement_progress FOR SELECT TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6365 (class 3256 OID 42101)
-- Name: driver_locations rls_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_select ON public.driver_locations FOR SELECT TO authenticated USING ((driver_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6373 (class 3256 OID 42106)
-- Name: driver_vehicles rls_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_select ON public.driver_vehicles FOR SELECT TO authenticated USING ((driver_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6380 (class 3256 OID 42115)
-- Name: kyc_liveness_sessions rls_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_select ON public.kyc_liveness_sessions FOR SELECT TO authenticated USING ((profile_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6387 (class 3256 OID 42130)
-- Name: profile_kyc rls_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_select ON public.profile_kyc FOR SELECT TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6394 (class 3256 OID 42139)
-- Name: referral_codes rls_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_select ON public.referral_codes FOR SELECT TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6405 (class 3256 OID 42150)
-- Name: ride_chat_threads rls_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_select ON public.ride_chat_threads FOR SELECT TO authenticated USING (((driver_id = ( SELECT auth.uid() AS uid)) OR (rider_id = ( SELECT auth.uid() AS uid))));


--
-- TOC entry 6412 (class 3256 OID 42155)
-- Name: ride_chat_typing rls_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_select ON public.ride_chat_typing FOR SELECT TO authenticated USING ((profile_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6419 (class 3256 OID 42162)
-- Name: ride_events rls_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_select ON public.ride_events FOR SELECT TO authenticated USING ((actor_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6427 (class 3256 OID 42175)
-- Name: rides rls_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_select ON public.rides FOR SELECT TO authenticated USING (((driver_id = ( SELECT auth.uid() AS uid)) OR (rider_id = ( SELECT auth.uid() AS uid))));


--
-- TOC entry 6436 (class 3256 OID 42184)
-- Name: user_device_tokens rls_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_select ON public.user_device_tokens FOR SELECT TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6442 (class 3256 OID 42189)
-- Name: wallet_accounts rls_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_select ON public.wallet_accounts FOR SELECT TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6330 (class 3256 OID 42087)
-- Name: achievement_progress rls_service_role_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_service_role_all ON public.achievement_progress TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6361 (class 3256 OID 42092)
-- Name: achievements rls_service_role_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_service_role_all ON public.achievements TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6363 (class 3256 OID 42094)
-- Name: api_rate_limits rls_service_role_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_service_role_all ON public.api_rate_limits TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6338 (class 3256 OID 42096)
-- Name: app_events rls_service_role_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_service_role_all ON public.app_events TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6344 (class 3256 OID 42098)
-- Name: driver_counters rls_service_role_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_service_role_all ON public.driver_counters TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6356 (class 3256 OID 42100)
-- Name: driver_locations rls_service_role_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_service_role_all ON public.driver_locations TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6369 (class 3256 OID 42105)
-- Name: driver_vehicles rls_service_role_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_service_role_all ON public.driver_vehicles TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6377 (class 3256 OID 42110)
-- Name: drivers rls_service_role_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_service_role_all ON public.drivers TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6378 (class 3256 OID 42112)
-- Name: kyc_document_types rls_service_role_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_service_role_all ON public.kyc_document_types TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6370 (class 3256 OID 42114)
-- Name: kyc_liveness_sessions rls_service_role_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_service_role_all ON public.kyc_liveness_sessions TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6384 (class 3256 OID 42119)
-- Name: notification_outbox rls_service_role_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_service_role_all ON public.notification_outbox TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6386 (class 3256 OID 42121)
-- Name: payment_intents rls_service_role_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_service_role_all ON public.payment_intents TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6299 (class 3256 OID 42123)
-- Name: payment_providers rls_service_role_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_service_role_all ON public.payment_providers TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6319 (class 3256 OID 42125)
-- Name: payments rls_service_role_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_service_role_all ON public.payments TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6331 (class 3256 OID 42127)
-- Name: pricing_configs rls_service_role_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_service_role_all ON public.pricing_configs TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6371 (class 3256 OID 42129)
-- Name: profile_kyc rls_service_role_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_service_role_all ON public.profile_kyc TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6391 (class 3256 OID 42134)
-- Name: provider_events rls_service_role_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_service_role_all ON public.provider_events TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6392 (class 3256 OID 42136)
-- Name: referral_campaigns rls_service_role_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_service_role_all ON public.referral_campaigns TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6372 (class 3256 OID 42138)
-- Name: referral_codes rls_service_role_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_service_role_all ON public.referral_codes TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6398 (class 3256 OID 42143)
-- Name: referral_invites rls_service_role_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_service_role_all ON public.referral_invites TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6400 (class 3256 OID 42145)
-- Name: referral_redemptions rls_service_role_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_service_role_all ON public.referral_redemptions TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6402 (class 3256 OID 42147)
-- Name: referral_settings rls_service_role_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_service_role_all ON public.referral_settings TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6404 (class 3256 OID 42149)
-- Name: ride_chat_threads rls_service_role_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_service_role_all ON public.ride_chat_threads TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6409 (class 3256 OID 42154)
-- Name: ride_chat_typing rls_service_role_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_service_role_all ON public.ride_chat_typing TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6416 (class 3256 OID 42159)
-- Name: ride_completion_log rls_service_role_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_service_role_all ON public.ride_completion_log TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6418 (class 3256 OID 42161)
-- Name: ride_events rls_service_role_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_service_role_all ON public.ride_events TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6423 (class 3256 OID 42166)
-- Name: ride_incidents rls_service_role_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_service_role_all ON public.ride_incidents TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6424 (class 3256 OID 42168)
-- Name: ride_products rls_service_role_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_service_role_all ON public.ride_products TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6410 (class 3256 OID 42170)
-- Name: ride_ratings rls_service_role_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_service_role_all ON public.ride_ratings TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6411 (class 3256 OID 42172)
-- Name: ride_receipts rls_service_role_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_service_role_all ON public.ride_receipts TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6426 (class 3256 OID 42174)
-- Name: rides rls_service_role_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_service_role_all ON public.rides TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6431 (class 3256 OID 42179)
-- Name: support_categories rls_service_role_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_service_role_all ON public.support_categories TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6433 (class 3256 OID 42181)
-- Name: topup_packages rls_service_role_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_service_role_all ON public.topup_packages TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6434 (class 3256 OID 42183)
-- Name: user_device_tokens rls_service_role_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_service_role_all ON public.user_device_tokens TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6440 (class 3256 OID 42188)
-- Name: wallet_accounts rls_service_role_all; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_service_role_all ON public.wallet_accounts TO service_role USING (true) WITH CHECK (true);


--
-- TOC entry 6359 (class 3256 OID 42090)
-- Name: achievement_progress rls_update; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_update ON public.achievement_progress FOR UPDATE TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid))) WITH CHECK ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6367 (class 3256 OID 42103)
-- Name: driver_locations rls_update; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_update ON public.driver_locations FOR UPDATE TO authenticated USING ((driver_id = ( SELECT auth.uid() AS uid))) WITH CHECK ((driver_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6375 (class 3256 OID 42108)
-- Name: driver_vehicles rls_update; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_update ON public.driver_vehicles FOR UPDATE TO authenticated USING ((driver_id = ( SELECT auth.uid() AS uid))) WITH CHECK ((driver_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6382 (class 3256 OID 42117)
-- Name: kyc_liveness_sessions rls_update; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_update ON public.kyc_liveness_sessions FOR UPDATE TO authenticated USING ((profile_id = ( SELECT auth.uid() AS uid))) WITH CHECK ((profile_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6389 (class 3256 OID 42132)
-- Name: profile_kyc rls_update; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_update ON public.profile_kyc FOR UPDATE TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid))) WITH CHECK ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6396 (class 3256 OID 42141)
-- Name: referral_codes rls_update; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_update ON public.referral_codes FOR UPDATE TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid))) WITH CHECK ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6407 (class 3256 OID 42152)
-- Name: ride_chat_threads rls_update; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_update ON public.ride_chat_threads FOR UPDATE TO authenticated USING (((driver_id = ( SELECT auth.uid() AS uid)) OR (rider_id = ( SELECT auth.uid() AS uid)))) WITH CHECK (((driver_id = ( SELECT auth.uid() AS uid)) OR (rider_id = ( SELECT auth.uid() AS uid))));


--
-- TOC entry 6414 (class 3256 OID 42157)
-- Name: ride_chat_typing rls_update; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_update ON public.ride_chat_typing FOR UPDATE TO authenticated USING ((profile_id = ( SELECT auth.uid() AS uid))) WITH CHECK ((profile_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6421 (class 3256 OID 42164)
-- Name: ride_events rls_update; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_update ON public.ride_events FOR UPDATE TO authenticated USING ((actor_id = ( SELECT auth.uid() AS uid))) WITH CHECK ((actor_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6429 (class 3256 OID 42177)
-- Name: rides rls_update; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_update ON public.rides FOR UPDATE TO authenticated USING (((driver_id = ( SELECT auth.uid() AS uid)) OR (rider_id = ( SELECT auth.uid() AS uid)))) WITH CHECK (((driver_id = ( SELECT auth.uid() AS uid)) OR (rider_id = ( SELECT auth.uid() AS uid))));


--
-- TOC entry 6438 (class 3256 OID 42186)
-- Name: user_device_tokens rls_update; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_update ON public.user_device_tokens FOR UPDATE TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid))) WITH CHECK ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6444 (class 3256 OID 42191)
-- Name: wallet_accounts rls_update; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY rls_update ON public.wallet_accounts FOR UPDATE TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid))) WITH CHECK ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6274 (class 0 OID 40824)
-- Dependencies: 456
-- Name: support_categories; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.support_categories ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6276 (class 0 OID 40861)
-- Dependencies: 458
-- Name: support_messages; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.support_messages ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6328 (class 3256 OID 42045)
-- Name: support_messages support_messages_insert_ticket_owner_or_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY support_messages_insert_ticket_owner_or_admin ON public.support_messages FOR INSERT TO authenticated WITH CHECK (((sender_id = ( SELECT auth.uid() AS uid)) AND (( SELECT public.is_admin() AS is_admin) OR (EXISTS ( SELECT 1
   FROM public.support_tickets t
  WHERE ((t.id = support_messages.ticket_id) AND (t.created_by = ( SELECT auth.uid() AS uid))))))));


--
-- TOC entry 6329 (class 3256 OID 42046)
-- Name: support_messages support_messages_select_ticket_owner_sender_or_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY support_messages_select_ticket_owner_sender_or_admin ON public.support_messages FOR SELECT TO authenticated USING ((( SELECT public.is_admin() AS is_admin) OR (sender_id = ( SELECT auth.uid() AS uid)) OR (EXISTS ( SELECT 1
   FROM public.support_tickets t
  WHERE ((t.id = support_messages.ticket_id) AND (t.created_by = ( SELECT auth.uid() AS uid)))))));


--
-- TOC entry 6275 (class 0 OID 40833)
-- Dependencies: 457
-- Name: support_tickets; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.support_tickets ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6333 (class 3256 OID 42047)
-- Name: support_tickets support_tickets_insert_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY support_tickets_insert_own ON public.support_tickets FOR INSERT TO authenticated WITH CHECK ((created_by = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6334 (class 3256 OID 42048)
-- Name: support_tickets support_tickets_select_own_or_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY support_tickets_select_own_or_admin ON public.support_tickets FOR SELECT TO authenticated USING (((created_by = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6335 (class 3256 OID 42049)
-- Name: support_tickets support_tickets_update_own_or_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY support_tickets_update_own_or_admin ON public.support_tickets FOR UPDATE TO authenticated USING (((created_by = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin))) WITH CHECK (((created_by = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6236 (class 0 OID 39813)
-- Dependencies: 413
-- Name: topup_intents; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.topup_intents ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6339 (class 3256 OID 42052)
-- Name: topup_intents topup_intents_admin_update; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY topup_intents_admin_update ON public.topup_intents FOR UPDATE TO authenticated USING (( SELECT public.is_admin() AS is_admin)) WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6336 (class 3256 OID 42050)
-- Name: topup_intents topup_intents_insert_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY topup_intents_insert_own ON public.topup_intents FOR INSERT TO authenticated WITH CHECK (((user_id = ( SELECT auth.uid() AS uid)) AND (status = 'created'::public.topup_status)));


--
-- TOC entry 6337 (class 3256 OID 42051)
-- Name: topup_intents topup_intents_select_own_or_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY topup_intents_select_own_or_admin ON public.topup_intents FOR SELECT TO authenticated USING (((user_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6255 (class 0 OID 40013)
-- Dependencies: 434
-- Name: topup_packages; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.topup_packages ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6452 (class 3256 OID 42202)
-- Name: topup_packages topup_packages_delete_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY topup_packages_delete_admin ON public.topup_packages FOR DELETE TO authenticated USING (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6449 (class 3256 OID 42200)
-- Name: topup_packages topup_packages_insert_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY topup_packages_insert_admin ON public.topup_packages FOR INSERT TO authenticated WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6448 (class 3256 OID 42199)
-- Name: topup_packages topup_packages_select_public_active; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY topup_packages_select_public_active ON public.topup_packages FOR SELECT TO authenticated, anon USING ((active = true));


--
-- TOC entry 6450 (class 3256 OID 42201)
-- Name: topup_packages topup_packages_update_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY topup_packages_update_admin ON public.topup_packages FOR UPDATE TO authenticated USING (( SELECT public.is_admin() AS is_admin)) WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6280 (class 0 OID 40961)
-- Dependencies: 462
-- Name: trip_share_tokens; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.trip_share_tokens ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6340 (class 3256 OID 42053)
-- Name: trip_share_tokens trip_share_tokens_insert_participant; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY trip_share_tokens_insert_participant ON public.trip_share_tokens FOR INSERT TO authenticated WITH CHECK (((created_by = ( SELECT auth.uid() AS uid)) AND (EXISTS ( SELECT 1
   FROM public.rides r
  WHERE ((r.id = trip_share_tokens.ride_id) AND ((r.rider_id = ( SELECT auth.uid() AS uid)) OR (r.driver_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)))))));


--
-- TOC entry 6342 (class 3256 OID 42055)
-- Name: trip_share_tokens trip_share_tokens_revoke_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY trip_share_tokens_revoke_own ON public.trip_share_tokens FOR UPDATE TO authenticated USING ((created_by = ( SELECT auth.uid() AS uid))) WITH CHECK ((created_by = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6341 (class 3256 OID 42054)
-- Name: trip_share_tokens trip_share_tokens_select_participant; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY trip_share_tokens_select_participant ON public.trip_share_tokens FOR SELECT TO authenticated USING ((EXISTS ( SELECT 1
   FROM public.rides r
  WHERE ((r.id = trip_share_tokens.ride_id) AND ((r.rider_id = ( SELECT auth.uid() AS uid)) OR (r.driver_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin))))));


--
-- TOC entry 6273 (class 0 OID 40790)
-- Dependencies: 455
-- Name: trusted_contacts; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.trusted_contacts ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6345 (class 3256 OID 42056)
-- Name: trusted_contacts trusted_contacts_write_own_or_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY trusted_contacts_write_own_or_admin ON public.trusted_contacts TO authenticated USING (((user_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin))) WITH CHECK (((user_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6286 (class 0 OID 41699)
-- Dependencies: 470
-- Name: user_device_tokens; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.user_device_tokens ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6256 (class 0 OID 40026)
-- Dependencies: 435
-- Name: user_notifications; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.user_notifications ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6346 (class 3256 OID 42057)
-- Name: user_notifications user_notifications_select_own_or_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY user_notifications_select_own_or_admin ON public.user_notifications FOR SELECT TO authenticated USING (((user_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6347 (class 3256 OID 42058)
-- Name: user_notifications user_notifications_update_own_or_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY user_notifications_update_own_or_admin ON public.user_notifications FOR UPDATE TO authenticated USING (((user_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin))) WITH CHECK (((user_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6237 (class 0 OID 39828)
-- Dependencies: 414
-- Name: wallet_accounts; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.wallet_accounts ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6257 (class 0 OID 40034)
-- Dependencies: 436
-- Name: wallet_entries; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.wallet_entries ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6348 (class 3256 OID 42059)
-- Name: wallet_entries wallet_entries_select_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY wallet_entries_select_own ON public.wallet_entries FOR SELECT TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6258 (class 0 OID 40042)
-- Dependencies: 438
-- Name: wallet_holds; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.wallet_holds ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6349 (class 3256 OID 42060)
-- Name: wallet_holds wallet_holds_select_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY wallet_holds_select_own ON public.wallet_holds FOR SELECT TO authenticated USING ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6259 (class 0 OID 40053)
-- Dependencies: 439
-- Name: wallet_withdraw_payout_methods; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.wallet_withdraw_payout_methods ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6260 (class 0 OID 40059)
-- Dependencies: 440
-- Name: wallet_withdraw_requests; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.wallet_withdraw_requests ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6261 (class 0 OID 40070)
-- Dependencies: 441
-- Name: wallet_withdrawal_policy; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE public.wallet_withdrawal_policy ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6350 (class 3256 OID 42061)
-- Name: wallet_withdraw_requests withdraw_insert_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY withdraw_insert_own ON public.wallet_withdraw_requests FOR INSERT TO authenticated WITH CHECK ((user_id = ( SELECT auth.uid() AS uid)));


--
-- TOC entry 6354 (class 3256 OID 42066)
-- Name: wallet_withdraw_payout_methods withdraw_payout_methods_admin_update; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY withdraw_payout_methods_admin_update ON public.wallet_withdraw_payout_methods FOR UPDATE TO authenticated USING (( SELECT public.is_admin() AS is_admin)) WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6353 (class 3256 OID 42065)
-- Name: wallet_withdraw_payout_methods withdraw_payout_methods_select; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY withdraw_payout_methods_select ON public.wallet_withdraw_payout_methods FOR SELECT TO authenticated USING ((( SELECT auth.uid() AS uid) IS NOT NULL));


--
-- TOC entry 6465 (class 3256 OID 42217)
-- Name: wallet_withdrawal_policy withdraw_policy_admin_update; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY withdraw_policy_admin_update ON public.wallet_withdrawal_policy FOR UPDATE TO authenticated USING (( SELECT public.is_admin() AS is_admin)) WITH CHECK (( SELECT public.is_admin() AS is_admin));


--
-- TOC entry 6464 (class 3256 OID 42216)
-- Name: wallet_withdrawal_policy withdraw_policy_select_public; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY withdraw_policy_select_public ON public.wallet_withdrawal_policy FOR SELECT TO authenticated, anon USING (true);


--
-- TOC entry 6351 (class 3256 OID 42062)
-- Name: wallet_withdraw_requests withdraw_select_own_or_admin; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY withdraw_select_own_or_admin ON public.wallet_withdraw_requests FOR SELECT TO authenticated USING (((user_id = ( SELECT auth.uid() AS uid)) OR ( SELECT public.is_admin() AS is_admin)));


--
-- TOC entry 6352 (class 3256 OID 42063)
-- Name: wallet_withdraw_requests withdraw_update_admin_or_cancel_own; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY withdraw_update_admin_or_cancel_own ON public.wallet_withdraw_requests FOR UPDATE TO authenticated USING ((( SELECT public.is_admin() AS is_admin) OR ((user_id = ( SELECT auth.uid() AS uid)) AND (status = 'requested'::public.withdraw_request_status)))) WITH CHECK ((( SELECT public.is_admin() AS is_admin) OR ((user_id = ( SELECT auth.uid() AS uid)) AND (status = ANY (ARRAY['requested'::public.withdraw_request_status, 'cancelled'::public.withdraw_request_status])))));


--
-- TOC entry 6224 (class 0 OID 17239)
-- Dependencies: 381
-- Name: messages; Type: ROW SECURITY; Schema: realtime; Owner: supabase_realtime_admin
--

ALTER TABLE realtime.messages ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6306 (class 3256 OID 24830)
-- Name: messages rt_driver_receive_own_loc; Type: POLICY; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE POLICY rt_driver_receive_own_loc ON realtime.messages FOR SELECT TO authenticated USING ((( SELECT realtime.topic() AS topic) = ('loc:driver:'::text || (( SELECT auth.uid() AS uid))::text)));


--
-- TOC entry 6308 (class 3256 OID 24831)
-- Name: messages rt_driver_send_own_loc; Type: POLICY; Schema: realtime; Owner: supabase_realtime_admin
--

CREATE POLICY rt_driver_send_own_loc ON realtime.messages FOR INSERT TO authenticated WITH CHECK ((( SELECT realtime.topic() AS topic) = ('loc:driver:'::text || (( SELECT auth.uid() AS uid))::text)));


--
-- TOC entry 6469 (class 3256 OID 42221)
-- Name: objects avatars_delete_own; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY avatars_delete_own ON storage.objects FOR DELETE TO authenticated USING (((bucket_id = 'avatars'::text) AND (owner = auth.uid()) AND (name ~~ ((auth.uid())::text || '/%'::text))));


--
-- TOC entry 6467 (class 3256 OID 42219)
-- Name: objects avatars_insert_own; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY avatars_insert_own ON storage.objects FOR INSERT TO authenticated WITH CHECK (((bucket_id = 'avatars'::text) AND (owner = auth.uid()) AND (name ~~ ((auth.uid())::text || '/%'::text))));


--
-- TOC entry 6466 (class 3256 OID 42218)
-- Name: objects avatars_public_read; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY avatars_public_read ON storage.objects FOR SELECT TO authenticated, anon USING ((bucket_id = 'avatars'::text));


--
-- TOC entry 6468 (class 3256 OID 42220)
-- Name: objects avatars_update_own; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY avatars_update_own ON storage.objects FOR UPDATE TO authenticated USING (((bucket_id = 'avatars'::text) AND (owner = auth.uid()) AND (name ~~ ((auth.uid())::text || '/%'::text)))) WITH CHECK (((bucket_id = 'avatars'::text) AND (owner = auth.uid()) AND (name ~~ ((auth.uid())::text || '/%'::text))));


--
-- TOC entry 6226 (class 0 OID 17264)
-- Dependencies: 383
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6231 (class 0 OID 17422)
-- Dependencies: 388
-- Name: buckets_analytics; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.buckets_analytics ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6232 (class 0 OID 17449)
-- Dependencies: 389
-- Name: buckets_vectors; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.buckets_vectors ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6476 (class 3256 OID 42229)
-- Name: objects chat_media_delete_own; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY chat_media_delete_own ON storage.objects FOR DELETE TO authenticated USING (((bucket_id = 'chat-media'::text) AND (owner = auth.uid())));


--
-- TOC entry 6474 (class 3256 OID 42227)
-- Name: objects chat_media_insert_thread_participants; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY chat_media_insert_thread_participants ON storage.objects FOR INSERT TO authenticated WITH CHECK (((bucket_id = 'chat-media'::text) AND (owner = auth.uid()) AND (name ~~ 'threads/%'::text) AND (EXISTS ( SELECT 1
   FROM public.ride_chat_threads t
  WHERE (((t.id)::text = split_part(objects.name, '/'::text, 2)) AND ((t.rider_id = auth.uid()) OR (t.driver_id = auth.uid())))))));


--
-- TOC entry 6473 (class 3256 OID 42226)
-- Name: objects chat_media_read_thread_participants; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY chat_media_read_thread_participants ON storage.objects FOR SELECT TO authenticated USING (((bucket_id = 'chat-media'::text) AND (name ~~ 'threads/%'::text) AND (EXISTS ( SELECT 1
   FROM public.ride_chat_threads t
  WHERE (((t.id)::text = split_part(objects.name, '/'::text, 2)) AND ((t.rider_id = auth.uid()) OR (t.driver_id = auth.uid())))))));


--
-- TOC entry 6475 (class 3256 OID 42228)
-- Name: objects chat_media_update_own; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY chat_media_update_own ON storage.objects FOR UPDATE TO authenticated USING (((bucket_id = 'chat-media'::text) AND (owner = auth.uid()))) WITH CHECK (((bucket_id = 'chat-media'::text) AND (owner = auth.uid())));


--
-- TOC entry 6472 (class 3256 OID 42225)
-- Name: objects kyc_delete_own; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY kyc_delete_own ON storage.objects FOR DELETE TO authenticated USING (((bucket_id = 'kyc-documents'::text) AND (owner = auth.uid())));


--
-- TOC entry 6470 (class 3256 OID 42223)
-- Name: objects kyc_insert_own; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY kyc_insert_own ON storage.objects FOR INSERT TO authenticated WITH CHECK (((bucket_id = 'kyc-documents'::text) AND (owner = auth.uid()) AND (name ~~ ((auth.uid())::text || '/%'::text))));


--
-- TOC entry 6451 (class 3256 OID 42222)
-- Name: objects kyc_read_own; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY kyc_read_own ON storage.objects FOR SELECT TO authenticated USING (((bucket_id = 'kyc-documents'::text) AND (owner = auth.uid())));


--
-- TOC entry 6471 (class 3256 OID 42224)
-- Name: objects kyc_update_own; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY kyc_update_own ON storage.objects FOR UPDATE TO authenticated USING (((bucket_id = 'kyc-documents'::text) AND (owner = auth.uid()))) WITH CHECK (((bucket_id = 'kyc-documents'::text) AND (owner = auth.uid()) AND (name ~~ ((auth.uid())::text || '/%'::text))));


--
-- TOC entry 6225 (class 0 OID 17256)
-- Dependencies: 382
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.migrations ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6227 (class 0 OID 17274)
-- Dependencies: 384
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6230 (class 0 OID 17377)
-- Dependencies: 387
-- Name: prefixes; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.prefixes ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6228 (class 0 OID 17324)
-- Dependencies: 385
-- Name: s3_multipart_uploads; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.s3_multipart_uploads ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6229 (class 0 OID 17338)
-- Dependencies: 386
-- Name: s3_multipart_uploads_parts; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.s3_multipart_uploads_parts ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6233 (class 0 OID 17459)
-- Dependencies: 390
-- Name: vector_indexes; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.vector_indexes ENABLE ROW LEVEL SECURITY;

--
-- TOC entry 6484 (class 6104 OID 16426)
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: postgres
--

CREATE PUBLICATION supabase_realtime WITH (publish = 'insert, update, delete, truncate');


ALTER PUBLICATION supabase_realtime OWNER TO postgres;

--
-- TOC entry 6485 (class 6104 OID 24115)
-- Name: supabase_realtime_messages_publication; Type: PUBLICATION; Schema: -; Owner: supabase_admin
--

CREATE PUBLICATION supabase_realtime_messages_publication WITH (publish = 'insert, update, delete, truncate');


ALTER PUBLICATION supabase_realtime_messages_publication OWNER TO supabase_admin;

--
-- TOC entry 6487 (class 6106 OID 40535)
-- Name: supabase_realtime driver_locations; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.driver_locations;


--
-- TOC entry 6499 (class 6106 OID 40789)
-- Name: supabase_realtime driver_stats_daily; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.driver_stats_daily;


--
-- TOC entry 6488 (class 6106 OID 40536)
-- Name: supabase_realtime drivers; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.drivers;


--
-- TOC entry 6508 (class 6106 OID 41049)
-- Name: supabase_realtime kyc_documents; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.kyc_documents;


--
-- TOC entry 6507 (class 6106 OID 41048)
-- Name: supabase_realtime kyc_submissions; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.kyc_submissions;


--
-- TOC entry 6513 (class 6106 OID 42234)
-- Name: supabase_realtime payment_intents; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.payment_intents;


--
-- TOC entry 6489 (class 6106 OID 40537)
-- Name: supabase_realtime payments; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.payments;


--
-- TOC entry 6512 (class 6106 OID 42233)
-- Name: supabase_realtime provider_events; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.provider_events;


--
-- TOC entry 6503 (class 6106 OID 41044)
-- Name: supabase_realtime ride_chat_messages; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.ride_chat_messages;


--
-- TOC entry 6504 (class 6106 OID 41045)
-- Name: supabase_realtime ride_chat_read_receipts; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.ride_chat_read_receipts;


--
-- TOC entry 6509 (class 6106 OID 42230)
-- Name: supabase_realtime ride_chat_threads; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.ride_chat_threads;


--
-- TOC entry 6505 (class 6106 OID 41046)
-- Name: supabase_realtime ride_chat_typing; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.ride_chat_typing;


--
-- TOC entry 6490 (class 6106 OID 40538)
-- Name: supabase_realtime ride_events; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.ride_events;


--
-- TOC entry 6511 (class 6106 OID 42232)
-- Name: supabase_realtime ride_incidents; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.ride_incidents;


--
-- TOC entry 6510 (class 6106 OID 42231)
-- Name: supabase_realtime ride_receipts; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.ride_receipts;


--
-- TOC entry 6491 (class 6106 OID 40539)
-- Name: supabase_realtime ride_requests; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.ride_requests;


--
-- TOC entry 6492 (class 6106 OID 40540)
-- Name: supabase_realtime rides; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.rides;


--
-- TOC entry 6502 (class 6106 OID 41043)
-- Name: supabase_realtime support_messages; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.support_messages;


--
-- TOC entry 6501 (class 6106 OID 41042)
-- Name: supabase_realtime support_tickets; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.support_tickets;


--
-- TOC entry 6493 (class 6106 OID 40541)
-- Name: supabase_realtime topup_intents; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.topup_intents;


--
-- TOC entry 6506 (class 6106 OID 41047)
-- Name: supabase_realtime trip_share_tokens; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.trip_share_tokens;


--
-- TOC entry 6500 (class 6106 OID 41041)
-- Name: supabase_realtime trusted_contacts; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.trusted_contacts;


--
-- TOC entry 6494 (class 6106 OID 40542)
-- Name: supabase_realtime user_notifications; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.user_notifications;


--
-- TOC entry 6495 (class 6106 OID 40543)
-- Name: supabase_realtime wallet_accounts; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.wallet_accounts;


--
-- TOC entry 6496 (class 6106 OID 40544)
-- Name: supabase_realtime wallet_entries; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.wallet_entries;


--
-- TOC entry 6497 (class 6106 OID 40545)
-- Name: supabase_realtime wallet_holds; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.wallet_holds;


--
-- TOC entry 6498 (class 6106 OID 40546)
-- Name: supabase_realtime wallet_withdraw_requests; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public.wallet_withdraw_requests;


--
-- TOC entry 6486 (class 6106 OID 24116)
-- Name: supabase_realtime_messages_publication messages; Type: PUBLICATION TABLE; Schema: realtime; Owner: supabase_admin
--

ALTER PUBLICATION supabase_realtime_messages_publication ADD TABLE ONLY realtime.messages;


--
-- TOC entry 6519 (class 0 OID 0)
-- Dependencies: 39
-- Name: SCHEMA auth; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA auth TO anon;
GRANT USAGE ON SCHEMA auth TO authenticated;
GRANT USAGE ON SCHEMA auth TO service_role;
GRANT ALL ON SCHEMA auth TO supabase_auth_admin;
GRANT ALL ON SCHEMA auth TO dashboard_user;
GRANT USAGE ON SCHEMA auth TO postgres;


--
-- TOC entry 6521 (class 0 OID 0)
-- Dependencies: 34
-- Name: SCHEMA cron; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA cron TO postgres WITH GRANT OPTION;


--
-- TOC entry 6522 (class 0 OID 0)
-- Dependencies: 25
-- Name: SCHEMA extensions; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA extensions TO anon;
GRANT USAGE ON SCHEMA extensions TO authenticated;
GRANT USAGE ON SCHEMA extensions TO service_role;
GRANT ALL ON SCHEMA extensions TO dashboard_user;


--
-- TOC entry 6524 (class 0 OID 0)
-- Dependencies: 46
-- Name: SCHEMA net; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA net TO supabase_functions_admin;
GRANT USAGE ON SCHEMA net TO postgres;
GRANT USAGE ON SCHEMA net TO anon;
GRANT USAGE ON SCHEMA net TO authenticated;
GRANT USAGE ON SCHEMA net TO service_role;


--
-- TOC entry 6526 (class 0 OID 0)
-- Dependencies: 136
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE USAGE ON SCHEMA public FROM PUBLIC;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT ALL ON SCHEMA public TO service_role;


--
-- TOC entry 6527 (class 0 OID 0)
-- Dependencies: 12
-- Name: SCHEMA realtime; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA realtime TO postgres;
GRANT USAGE ON SCHEMA realtime TO anon;
GRANT USAGE ON SCHEMA realtime TO authenticated;
GRANT USAGE ON SCHEMA realtime TO service_role;
GRANT ALL ON SCHEMA realtime TO supabase_realtime_admin;


--
-- TOC entry 6528 (class 0 OID 0)
-- Dependencies: 40
-- Name: SCHEMA storage; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA storage TO postgres WITH GRANT OPTION;
GRANT USAGE ON SCHEMA storage TO anon;
GRANT USAGE ON SCHEMA storage TO authenticated;
GRANT USAGE ON SCHEMA storage TO service_role;
GRANT ALL ON SCHEMA storage TO supabase_storage_admin WITH GRANT OPTION;
GRANT ALL ON SCHEMA storage TO dashboard_user;


--
-- TOC entry 6529 (class 0 OID 0)
-- Dependencies: 137
-- Name: SCHEMA vault; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA vault TO postgres WITH GRANT OPTION;
GRANT USAGE ON SCHEMA vault TO service_role;


--
-- TOC entry 6536 (class 0 OID 0)
-- Dependencies: 618
-- Name: FUNCTION box2d_in(cstring); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.box2d_in(cstring) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6537 (class 0 OID 0)
-- Dependencies: 1167
-- Name: FUNCTION box2d_out(extensions.box2d); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.box2d_out(extensions.box2d) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6538 (class 0 OID 0)
-- Dependencies: 700
-- Name: FUNCTION box2df_in(cstring); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.box2df_in(cstring) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6539 (class 0 OID 0)
-- Dependencies: 1185
-- Name: FUNCTION box2df_out(extensions.box2df); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.box2df_out(extensions.box2df) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6540 (class 0 OID 0)
-- Dependencies: 1395
-- Name: FUNCTION box3d_in(cstring); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.box3d_in(cstring) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6541 (class 0 OID 0)
-- Dependencies: 1269
-- Name: FUNCTION box3d_out(extensions.box3d); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.box3d_out(extensions.box3d) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6542 (class 0 OID 0)
-- Dependencies: 1414
-- Name: FUNCTION geography_analyze(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_analyze(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6543 (class 0 OID 0)
-- Dependencies: 1184
-- Name: FUNCTION geography_in(cstring, oid, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_in(cstring, oid, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6544 (class 0 OID 0)
-- Dependencies: 1076
-- Name: FUNCTION geography_out(extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_out(extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6545 (class 0 OID 0)
-- Dependencies: 704
-- Name: FUNCTION geography_recv(internal, oid, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_recv(internal, oid, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6546 (class 0 OID 0)
-- Dependencies: 921
-- Name: FUNCTION geography_send(extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_send(extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6547 (class 0 OID 0)
-- Dependencies: 593
-- Name: FUNCTION geography_typmod_in(cstring[]); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_typmod_in(cstring[]) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6548 (class 0 OID 0)
-- Dependencies: 1140
-- Name: FUNCTION geography_typmod_out(integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_typmod_out(integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6549 (class 0 OID 0)
-- Dependencies: 550
-- Name: FUNCTION geometry_analyze(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_analyze(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6550 (class 0 OID 0)
-- Dependencies: 1224
-- Name: FUNCTION geometry_in(cstring); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_in(cstring) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6551 (class 0 OID 0)
-- Dependencies: 841
-- Name: FUNCTION geometry_out(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_out(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6552 (class 0 OID 0)
-- Dependencies: 727
-- Name: FUNCTION geometry_recv(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_recv(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6553 (class 0 OID 0)
-- Dependencies: 495
-- Name: FUNCTION geometry_send(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_send(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6554 (class 0 OID 0)
-- Dependencies: 801
-- Name: FUNCTION geometry_typmod_in(cstring[]); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_typmod_in(cstring[]) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6555 (class 0 OID 0)
-- Dependencies: 1019
-- Name: FUNCTION geometry_typmod_out(integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_typmod_out(integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6556 (class 0 OID 0)
-- Dependencies: 1228
-- Name: FUNCTION gidx_in(cstring); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gidx_in(cstring) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6557 (class 0 OID 0)
-- Dependencies: 488
-- Name: FUNCTION gidx_out(extensions.gidx); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gidx_out(extensions.gidx) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6558 (class 0 OID 0)
-- Dependencies: 932
-- Name: FUNCTION spheroid_in(cstring); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.spheroid_in(cstring) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6559 (class 0 OID 0)
-- Dependencies: 660
-- Name: FUNCTION spheroid_out(extensions.spheroid); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.spheroid_out(extensions.spheroid) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6560 (class 0 OID 0)
-- Dependencies: 785
-- Name: FUNCTION box3d(extensions.box2d); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.box3d(extensions.box2d) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6561 (class 0 OID 0)
-- Dependencies: 762
-- Name: FUNCTION geometry(extensions.box2d); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry(extensions.box2d) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6562 (class 0 OID 0)
-- Dependencies: 1273
-- Name: FUNCTION box(extensions.box3d); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.box(extensions.box3d) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6563 (class 0 OID 0)
-- Dependencies: 1156
-- Name: FUNCTION box2d(extensions.box3d); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.box2d(extensions.box3d) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6564 (class 0 OID 0)
-- Dependencies: 879
-- Name: FUNCTION geometry(extensions.box3d); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry(extensions.box3d) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6565 (class 0 OID 0)
-- Dependencies: 1191
-- Name: FUNCTION geography(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6566 (class 0 OID 0)
-- Dependencies: 1183
-- Name: FUNCTION geometry(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6567 (class 0 OID 0)
-- Dependencies: 1094
-- Name: FUNCTION bytea(extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.bytea(extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6568 (class 0 OID 0)
-- Dependencies: 581
-- Name: FUNCTION geography(extensions.geography, integer, boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography(extensions.geography, integer, boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6569 (class 0 OID 0)
-- Dependencies: 1189
-- Name: FUNCTION geometry(extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry(extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6570 (class 0 OID 0)
-- Dependencies: 1392
-- Name: FUNCTION box(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.box(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6571 (class 0 OID 0)
-- Dependencies: 741
-- Name: FUNCTION box2d(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.box2d(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6572 (class 0 OID 0)
-- Dependencies: 1415
-- Name: FUNCTION box3d(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.box3d(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6573 (class 0 OID 0)
-- Dependencies: 881
-- Name: FUNCTION bytea(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.bytea(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6574 (class 0 OID 0)
-- Dependencies: 561
-- Name: FUNCTION geography(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6575 (class 0 OID 0)
-- Dependencies: 1369
-- Name: FUNCTION geometry(extensions.geometry, integer, boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry(extensions.geometry, integer, boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6576 (class 0 OID 0)
-- Dependencies: 679
-- Name: FUNCTION "json"(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions."json"(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6577 (class 0 OID 0)
-- Dependencies: 723
-- Name: FUNCTION jsonb(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.jsonb(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6578 (class 0 OID 0)
-- Dependencies: 722
-- Name: FUNCTION path(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.path(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6579 (class 0 OID 0)
-- Dependencies: 937
-- Name: FUNCTION point(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.point(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6580 (class 0 OID 0)
-- Dependencies: 764
-- Name: FUNCTION polygon(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.polygon(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6581 (class 0 OID 0)
-- Dependencies: 616
-- Name: FUNCTION text(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.text(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6582 (class 0 OID 0)
-- Dependencies: 1040
-- Name: FUNCTION geometry(path); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry(path) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6583 (class 0 OID 0)
-- Dependencies: 549
-- Name: FUNCTION geometry(point); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry(point) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6584 (class 0 OID 0)
-- Dependencies: 598
-- Name: FUNCTION geometry(polygon); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry(polygon) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6585 (class 0 OID 0)
-- Dependencies: 780
-- Name: FUNCTION geometry(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6587 (class 0 OID 0)
-- Dependencies: 1135
-- Name: FUNCTION email(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.email() TO dashboard_user;


--
-- TOC entry 6588 (class 0 OID 0)
-- Dependencies: 1382
-- Name: FUNCTION jwt(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.jwt() TO postgres;
GRANT ALL ON FUNCTION auth.jwt() TO dashboard_user;


--
-- TOC entry 6590 (class 0 OID 0)
-- Dependencies: 505
-- Name: FUNCTION role(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.role() TO dashboard_user;


--
-- TOC entry 6592 (class 0 OID 0)
-- Dependencies: 1043
-- Name: FUNCTION uid(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.uid() TO dashboard_user;


--
-- TOC entry 6593 (class 0 OID 0)
-- Dependencies: 885
-- Name: FUNCTION alter_job(job_id bigint, schedule text, command text, database text, username text, active boolean); Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON FUNCTION cron.alter_job(job_id bigint, schedule text, command text, database text, username text, active boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6594 (class 0 OID 0)
-- Dependencies: 802
-- Name: FUNCTION job_cache_invalidate(); Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON FUNCTION cron.job_cache_invalidate() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6595 (class 0 OID 0)
-- Dependencies: 968
-- Name: FUNCTION schedule(schedule text, command text); Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON FUNCTION cron.schedule(schedule text, command text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6596 (class 0 OID 0)
-- Dependencies: 1346
-- Name: FUNCTION schedule(job_name text, schedule text, command text); Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON FUNCTION cron.schedule(job_name text, schedule text, command text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6597 (class 0 OID 0)
-- Dependencies: 753
-- Name: FUNCTION schedule_in_database(job_name text, schedule text, command text, database text, username text, active boolean); Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON FUNCTION cron.schedule_in_database(job_name text, schedule text, command text, database text, username text, active boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6598 (class 0 OID 0)
-- Dependencies: 849
-- Name: FUNCTION unschedule(job_id bigint); Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON FUNCTION cron.unschedule(job_id bigint) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6599 (class 0 OID 0)
-- Dependencies: 586
-- Name: FUNCTION unschedule(job_name text); Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON FUNCTION cron.unschedule(job_name text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6600 (class 0 OID 0)
-- Dependencies: 809
-- Name: FUNCTION _postgis_deprecate(oldname text, newname text, version text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._postgis_deprecate(oldname text, newname text, version text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6601 (class 0 OID 0)
-- Dependencies: 632
-- Name: FUNCTION _postgis_index_extent(tbl regclass, col text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._postgis_index_extent(tbl regclass, col text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6602 (class 0 OID 0)
-- Dependencies: 814
-- Name: FUNCTION _postgis_join_selectivity(regclass, text, regclass, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._postgis_join_selectivity(regclass, text, regclass, text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6603 (class 0 OID 0)
-- Dependencies: 1006
-- Name: FUNCTION _postgis_pgsql_version(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._postgis_pgsql_version() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6604 (class 0 OID 0)
-- Dependencies: 796
-- Name: FUNCTION _postgis_scripts_pgsql_version(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._postgis_scripts_pgsql_version() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6605 (class 0 OID 0)
-- Dependencies: 706
-- Name: FUNCTION _postgis_selectivity(tbl regclass, att_name text, geom extensions.geometry, mode text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._postgis_selectivity(tbl regclass, att_name text, geom extensions.geometry, mode text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6606 (class 0 OID 0)
-- Dependencies: 953
-- Name: FUNCTION _postgis_stats(tbl regclass, att_name text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._postgis_stats(tbl regclass, att_name text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6607 (class 0 OID 0)
-- Dependencies: 948
-- Name: FUNCTION _st_3ddfullywithin(geom1 extensions.geometry, geom2 extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_3ddfullywithin(geom1 extensions.geometry, geom2 extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6608 (class 0 OID 0)
-- Dependencies: 1188
-- Name: FUNCTION _st_3ddwithin(geom1 extensions.geometry, geom2 extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_3ddwithin(geom1 extensions.geometry, geom2 extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6609 (class 0 OID 0)
-- Dependencies: 1139
-- Name: FUNCTION _st_3dintersects(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_3dintersects(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6610 (class 0 OID 0)
-- Dependencies: 533
-- Name: FUNCTION _st_asgml(integer, extensions.geometry, integer, integer, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_asgml(integer, extensions.geometry, integer, integer, text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6611 (class 0 OID 0)
-- Dependencies: 1259
-- Name: FUNCTION _st_asx3d(integer, extensions.geometry, integer, integer, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_asx3d(integer, extensions.geometry, integer, integer, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6612 (class 0 OID 0)
-- Dependencies: 1249
-- Name: FUNCTION _st_bestsrid(extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_bestsrid(extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6613 (class 0 OID 0)
-- Dependencies: 1306
-- Name: FUNCTION _st_bestsrid(extensions.geography, extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_bestsrid(extensions.geography, extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6614 (class 0 OID 0)
-- Dependencies: 1206
-- Name: FUNCTION _st_contains(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_contains(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6615 (class 0 OID 0)
-- Dependencies: 569
-- Name: FUNCTION _st_containsproperly(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_containsproperly(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6616 (class 0 OID 0)
-- Dependencies: 920
-- Name: FUNCTION _st_coveredby(geog1 extensions.geography, geog2 extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_coveredby(geog1 extensions.geography, geog2 extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6617 (class 0 OID 0)
-- Dependencies: 1108
-- Name: FUNCTION _st_coveredby(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_coveredby(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6618 (class 0 OID 0)
-- Dependencies: 481
-- Name: FUNCTION _st_covers(geog1 extensions.geography, geog2 extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_covers(geog1 extensions.geography, geog2 extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6619 (class 0 OID 0)
-- Dependencies: 1236
-- Name: FUNCTION _st_covers(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_covers(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6620 (class 0 OID 0)
-- Dependencies: 1051
-- Name: FUNCTION _st_crosses(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_crosses(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6621 (class 0 OID 0)
-- Dependencies: 1341
-- Name: FUNCTION _st_dfullywithin(geom1 extensions.geometry, geom2 extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_dfullywithin(geom1 extensions.geometry, geom2 extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6622 (class 0 OID 0)
-- Dependencies: 1058
-- Name: FUNCTION _st_distancetree(extensions.geography, extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_distancetree(extensions.geography, extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6623 (class 0 OID 0)
-- Dependencies: 797
-- Name: FUNCTION _st_distancetree(extensions.geography, extensions.geography, double precision, boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_distancetree(extensions.geography, extensions.geography, double precision, boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6624 (class 0 OID 0)
-- Dependencies: 988
-- Name: FUNCTION _st_distanceuncached(extensions.geography, extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_distanceuncached(extensions.geography, extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6625 (class 0 OID 0)
-- Dependencies: 1056
-- Name: FUNCTION _st_distanceuncached(extensions.geography, extensions.geography, boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_distanceuncached(extensions.geography, extensions.geography, boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6626 (class 0 OID 0)
-- Dependencies: 1072
-- Name: FUNCTION _st_distanceuncached(extensions.geography, extensions.geography, double precision, boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_distanceuncached(extensions.geography, extensions.geography, double precision, boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6627 (class 0 OID 0)
-- Dependencies: 1334
-- Name: FUNCTION _st_dwithin(geom1 extensions.geometry, geom2 extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_dwithin(geom1 extensions.geometry, geom2 extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6628 (class 0 OID 0)
-- Dependencies: 805
-- Name: FUNCTION _st_dwithin(geog1 extensions.geography, geog2 extensions.geography, tolerance double precision, use_spheroid boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_dwithin(geog1 extensions.geography, geog2 extensions.geography, tolerance double precision, use_spheroid boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6629 (class 0 OID 0)
-- Dependencies: 625
-- Name: FUNCTION _st_dwithinuncached(extensions.geography, extensions.geography, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_dwithinuncached(extensions.geography, extensions.geography, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6630 (class 0 OID 0)
-- Dependencies: 1299
-- Name: FUNCTION _st_dwithinuncached(extensions.geography, extensions.geography, double precision, boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_dwithinuncached(extensions.geography, extensions.geography, double precision, boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6631 (class 0 OID 0)
-- Dependencies: 846
-- Name: FUNCTION _st_equals(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_equals(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6632 (class 0 OID 0)
-- Dependencies: 748
-- Name: FUNCTION _st_expand(extensions.geography, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_expand(extensions.geography, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6633 (class 0 OID 0)
-- Dependencies: 1321
-- Name: FUNCTION _st_geomfromgml(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_geomfromgml(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6634 (class 0 OID 0)
-- Dependencies: 715
-- Name: FUNCTION _st_intersects(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_intersects(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6635 (class 0 OID 0)
-- Dependencies: 926
-- Name: FUNCTION _st_linecrossingdirection(line1 extensions.geometry, line2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_linecrossingdirection(line1 extensions.geometry, line2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6636 (class 0 OID 0)
-- Dependencies: 1225
-- Name: FUNCTION _st_longestline(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_longestline(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6637 (class 0 OID 0)
-- Dependencies: 750
-- Name: FUNCTION _st_maxdistance(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_maxdistance(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6638 (class 0 OID 0)
-- Dependencies: 1065
-- Name: FUNCTION _st_orderingequals(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_orderingequals(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6639 (class 0 OID 0)
-- Dependencies: 1217
-- Name: FUNCTION _st_overlaps(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_overlaps(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6640 (class 0 OID 0)
-- Dependencies: 760
-- Name: FUNCTION _st_pointoutside(extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_pointoutside(extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6641 (class 0 OID 0)
-- Dependencies: 1359
-- Name: FUNCTION _st_sortablehash(geom extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_sortablehash(geom extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6642 (class 0 OID 0)
-- Dependencies: 1280
-- Name: FUNCTION _st_touches(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_touches(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6643 (class 0 OID 0)
-- Dependencies: 844
-- Name: FUNCTION _st_voronoi(g1 extensions.geometry, clip extensions.geometry, tolerance double precision, return_polygons boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_voronoi(g1 extensions.geometry, clip extensions.geometry, tolerance double precision, return_polygons boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6644 (class 0 OID 0)
-- Dependencies: 887
-- Name: FUNCTION _st_within(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions._st_within(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6645 (class 0 OID 0)
-- Dependencies: 589
-- Name: FUNCTION addauth(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.addauth(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6646 (class 0 OID 0)
-- Dependencies: 578
-- Name: FUNCTION addgeometrycolumn(table_name character varying, column_name character varying, new_srid integer, new_type character varying, new_dim integer, use_typmod boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.addgeometrycolumn(table_name character varying, column_name character varying, new_srid integer, new_type character varying, new_dim integer, use_typmod boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6647 (class 0 OID 0)
-- Dependencies: 1303
-- Name: FUNCTION addgeometrycolumn(schema_name character varying, table_name character varying, column_name character varying, new_srid integer, new_type character varying, new_dim integer, use_typmod boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.addgeometrycolumn(schema_name character varying, table_name character varying, column_name character varying, new_srid integer, new_type character varying, new_dim integer, use_typmod boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6648 (class 0 OID 0)
-- Dependencies: 997
-- Name: FUNCTION addgeometrycolumn(catalog_name character varying, schema_name character varying, table_name character varying, column_name character varying, new_srid_in integer, new_type character varying, new_dim integer, use_typmod boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.addgeometrycolumn(catalog_name character varying, schema_name character varying, table_name character varying, column_name character varying, new_srid_in integer, new_type character varying, new_dim integer, use_typmod boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6649 (class 0 OID 0)
-- Dependencies: 1150
-- Name: FUNCTION armor(bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.armor(bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.armor(bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.armor(bytea) TO dashboard_user;


--
-- TOC entry 6650 (class 0 OID 0)
-- Dependencies: 1289
-- Name: FUNCTION armor(bytea, text[], text[]); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.armor(bytea, text[], text[]) FROM postgres;
GRANT ALL ON FUNCTION extensions.armor(bytea, text[], text[]) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.armor(bytea, text[], text[]) TO dashboard_user;


--
-- TOC entry 6651 (class 0 OID 0)
-- Dependencies: 1208
-- Name: FUNCTION box3dtobox(extensions.box3d); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.box3dtobox(extensions.box3d) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6652 (class 0 OID 0)
-- Dependencies: 1047
-- Name: FUNCTION checkauth(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.checkauth(text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6653 (class 0 OID 0)
-- Dependencies: 1211
-- Name: FUNCTION checkauth(text, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.checkauth(text, text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6654 (class 0 OID 0)
-- Dependencies: 1103
-- Name: FUNCTION checkauthtrigger(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.checkauthtrigger() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6655 (class 0 OID 0)
-- Dependencies: 1413
-- Name: FUNCTION contains_2d(extensions.box2df, extensions.box2df); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.contains_2d(extensions.box2df, extensions.box2df) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6656 (class 0 OID 0)
-- Dependencies: 1379
-- Name: FUNCTION contains_2d(extensions.box2df, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.contains_2d(extensions.box2df, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6657 (class 0 OID 0)
-- Dependencies: 1114
-- Name: FUNCTION contains_2d(extensions.geometry, extensions.box2df); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.contains_2d(extensions.geometry, extensions.box2df) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6658 (class 0 OID 0)
-- Dependencies: 1252
-- Name: FUNCTION crypt(text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.crypt(text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.crypt(text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.crypt(text, text) TO dashboard_user;


--
-- TOC entry 6659 (class 0 OID 0)
-- Dependencies: 734
-- Name: FUNCTION dearmor(text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.dearmor(text) FROM postgres;
GRANT ALL ON FUNCTION extensions.dearmor(text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.dearmor(text) TO dashboard_user;


--
-- TOC entry 6660 (class 0 OID 0)
-- Dependencies: 1213
-- Name: FUNCTION decrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) TO dashboard_user;


--
-- TOC entry 6661 (class 0 OID 0)
-- Dependencies: 1110
-- Name: FUNCTION decrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) TO dashboard_user;


--
-- TOC entry 6662 (class 0 OID 0)
-- Dependencies: 1337
-- Name: FUNCTION digest(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.digest(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.digest(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.digest(bytea, text) TO dashboard_user;


--
-- TOC entry 6663 (class 0 OID 0)
-- Dependencies: 793
-- Name: FUNCTION digest(text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.digest(text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.digest(text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.digest(text, text) TO dashboard_user;


--
-- TOC entry 6664 (class 0 OID 0)
-- Dependencies: 694
-- Name: FUNCTION disablelongtransactions(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.disablelongtransactions() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6665 (class 0 OID 0)
-- Dependencies: 1169
-- Name: FUNCTION dropgeometrycolumn(table_name character varying, column_name character varying); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.dropgeometrycolumn(table_name character varying, column_name character varying) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6666 (class 0 OID 0)
-- Dependencies: 478
-- Name: FUNCTION dropgeometrycolumn(schema_name character varying, table_name character varying, column_name character varying); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.dropgeometrycolumn(schema_name character varying, table_name character varying, column_name character varying) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6667 (class 0 OID 0)
-- Dependencies: 592
-- Name: FUNCTION dropgeometrycolumn(catalog_name character varying, schema_name character varying, table_name character varying, column_name character varying); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.dropgeometrycolumn(catalog_name character varying, schema_name character varying, table_name character varying, column_name character varying) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6668 (class 0 OID 0)
-- Dependencies: 1068
-- Name: FUNCTION dropgeometrytable(table_name character varying); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.dropgeometrytable(table_name character varying) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6669 (class 0 OID 0)
-- Dependencies: 643
-- Name: FUNCTION dropgeometrytable(schema_name character varying, table_name character varying); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.dropgeometrytable(schema_name character varying, table_name character varying) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6670 (class 0 OID 0)
-- Dependencies: 873
-- Name: FUNCTION dropgeometrytable(catalog_name character varying, schema_name character varying, table_name character varying); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.dropgeometrytable(catalog_name character varying, schema_name character varying, table_name character varying) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6671 (class 0 OID 0)
-- Dependencies: 548
-- Name: FUNCTION enablelongtransactions(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.enablelongtransactions() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6672 (class 0 OID 0)
-- Dependencies: 1086
-- Name: FUNCTION encrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) TO dashboard_user;


--
-- TOC entry 6673 (class 0 OID 0)
-- Dependencies: 529
-- Name: FUNCTION encrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) TO dashboard_user;


--
-- TOC entry 6674 (class 0 OID 0)
-- Dependencies: 564
-- Name: FUNCTION equals(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.equals(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6675 (class 0 OID 0)
-- Dependencies: 1041
-- Name: FUNCTION find_srid(character varying, character varying, character varying); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.find_srid(character varying, character varying, character varying) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6676 (class 0 OID 0)
-- Dependencies: 1279
-- Name: FUNCTION gen_random_bytes(integer); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.gen_random_bytes(integer) FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_random_bytes(integer) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_random_bytes(integer) TO dashboard_user;


--
-- TOC entry 6677 (class 0 OID 0)
-- Dependencies: 1005
-- Name: FUNCTION gen_random_uuid(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.gen_random_uuid() FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_random_uuid() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_random_uuid() TO dashboard_user;


--
-- TOC entry 6678 (class 0 OID 0)
-- Dependencies: 963
-- Name: FUNCTION gen_salt(text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.gen_salt(text) FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_salt(text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_salt(text) TO dashboard_user;


--
-- TOC entry 6679 (class 0 OID 0)
-- Dependencies: 1410
-- Name: FUNCTION gen_salt(text, integer); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.gen_salt(text, integer) FROM postgres;
GRANT ALL ON FUNCTION extensions.gen_salt(text, integer) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.gen_salt(text, integer) TO dashboard_user;


--
-- TOC entry 6680 (class 0 OID 0)
-- Dependencies: 733
-- Name: FUNCTION geog_brin_inclusion_add_value(internal, internal, internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geog_brin_inclusion_add_value(internal, internal, internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6681 (class 0 OID 0)
-- Dependencies: 513
-- Name: FUNCTION geography_cmp(extensions.geography, extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_cmp(extensions.geography, extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6682 (class 0 OID 0)
-- Dependencies: 1212
-- Name: FUNCTION geography_distance_knn(extensions.geography, extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_distance_knn(extensions.geography, extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6683 (class 0 OID 0)
-- Dependencies: 1200
-- Name: FUNCTION geography_eq(extensions.geography, extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_eq(extensions.geography, extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6684 (class 0 OID 0)
-- Dependencies: 958
-- Name: FUNCTION geography_ge(extensions.geography, extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_ge(extensions.geography, extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6685 (class 0 OID 0)
-- Dependencies: 624
-- Name: FUNCTION geography_gist_compress(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_gist_compress(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6686 (class 0 OID 0)
-- Dependencies: 936
-- Name: FUNCTION geography_gist_consistent(internal, extensions.geography, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_gist_consistent(internal, extensions.geography, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6687 (class 0 OID 0)
-- Dependencies: 697
-- Name: FUNCTION geography_gist_decompress(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_gist_decompress(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6688 (class 0 OID 0)
-- Dependencies: 658
-- Name: FUNCTION geography_gist_distance(internal, extensions.geography, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_gist_distance(internal, extensions.geography, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6689 (class 0 OID 0)
-- Dependencies: 1122
-- Name: FUNCTION geography_gist_penalty(internal, internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_gist_penalty(internal, internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6690 (class 0 OID 0)
-- Dependencies: 1385
-- Name: FUNCTION geography_gist_picksplit(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_gist_picksplit(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6691 (class 0 OID 0)
-- Dependencies: 852
-- Name: FUNCTION geography_gist_same(extensions.box2d, extensions.box2d, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_gist_same(extensions.box2d, extensions.box2d, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6692 (class 0 OID 0)
-- Dependencies: 1286
-- Name: FUNCTION geography_gist_union(bytea, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_gist_union(bytea, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6693 (class 0 OID 0)
-- Dependencies: 1308
-- Name: FUNCTION geography_gt(extensions.geography, extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_gt(extensions.geography, extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6694 (class 0 OID 0)
-- Dependencies: 1054
-- Name: FUNCTION geography_le(extensions.geography, extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_le(extensions.geography, extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6695 (class 0 OID 0)
-- Dependencies: 1268
-- Name: FUNCTION geography_lt(extensions.geography, extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_lt(extensions.geography, extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6696 (class 0 OID 0)
-- Dependencies: 1134
-- Name: FUNCTION geography_overlaps(extensions.geography, extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_overlaps(extensions.geography, extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6697 (class 0 OID 0)
-- Dependencies: 571
-- Name: FUNCTION geography_spgist_choose_nd(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_spgist_choose_nd(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6698 (class 0 OID 0)
-- Dependencies: 1234
-- Name: FUNCTION geography_spgist_compress_nd(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_spgist_compress_nd(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6699 (class 0 OID 0)
-- Dependencies: 1270
-- Name: FUNCTION geography_spgist_config_nd(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_spgist_config_nd(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6700 (class 0 OID 0)
-- Dependencies: 884
-- Name: FUNCTION geography_spgist_inner_consistent_nd(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_spgist_inner_consistent_nd(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6701 (class 0 OID 0)
-- Dependencies: 959
-- Name: FUNCTION geography_spgist_leaf_consistent_nd(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_spgist_leaf_consistent_nd(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6702 (class 0 OID 0)
-- Dependencies: 1285
-- Name: FUNCTION geography_spgist_picksplit_nd(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geography_spgist_picksplit_nd(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6703 (class 0 OID 0)
-- Dependencies: 1018
-- Name: FUNCTION geom2d_brin_inclusion_add_value(internal, internal, internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geom2d_brin_inclusion_add_value(internal, internal, internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6704 (class 0 OID 0)
-- Dependencies: 1294
-- Name: FUNCTION geom3d_brin_inclusion_add_value(internal, internal, internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geom3d_brin_inclusion_add_value(internal, internal, internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6705 (class 0 OID 0)
-- Dependencies: 668
-- Name: FUNCTION geom4d_brin_inclusion_add_value(internal, internal, internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geom4d_brin_inclusion_add_value(internal, internal, internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6706 (class 0 OID 0)
-- Dependencies: 905
-- Name: FUNCTION geometry_above(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_above(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6707 (class 0 OID 0)
-- Dependencies: 1081
-- Name: FUNCTION geometry_below(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_below(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6708 (class 0 OID 0)
-- Dependencies: 826
-- Name: FUNCTION geometry_cmp(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_cmp(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6709 (class 0 OID 0)
-- Dependencies: 512
-- Name: FUNCTION geometry_contained_3d(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_contained_3d(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6710 (class 0 OID 0)
-- Dependencies: 1205
-- Name: FUNCTION geometry_contains(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_contains(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6711 (class 0 OID 0)
-- Dependencies: 1037
-- Name: FUNCTION geometry_contains_3d(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_contains_3d(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6712 (class 0 OID 0)
-- Dependencies: 1223
-- Name: FUNCTION geometry_contains_nd(extensions.geometry, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_contains_nd(extensions.geometry, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6713 (class 0 OID 0)
-- Dependencies: 995
-- Name: FUNCTION geometry_distance_box(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_distance_box(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6714 (class 0 OID 0)
-- Dependencies: 1324
-- Name: FUNCTION geometry_distance_centroid(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_distance_centroid(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6715 (class 0 OID 0)
-- Dependencies: 710
-- Name: FUNCTION geometry_distance_centroid_nd(extensions.geometry, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_distance_centroid_nd(extensions.geometry, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6716 (class 0 OID 0)
-- Dependencies: 1097
-- Name: FUNCTION geometry_distance_cpa(extensions.geometry, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_distance_cpa(extensions.geometry, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6717 (class 0 OID 0)
-- Dependencies: 1327
-- Name: FUNCTION geometry_eq(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_eq(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6718 (class 0 OID 0)
-- Dependencies: 732
-- Name: FUNCTION geometry_ge(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_ge(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6719 (class 0 OID 0)
-- Dependencies: 588
-- Name: FUNCTION geometry_gist_compress_2d(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_gist_compress_2d(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6720 (class 0 OID 0)
-- Dependencies: 930
-- Name: FUNCTION geometry_gist_compress_nd(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_gist_compress_nd(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6721 (class 0 OID 0)
-- Dependencies: 544
-- Name: FUNCTION geometry_gist_consistent_2d(internal, extensions.geometry, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_gist_consistent_2d(internal, extensions.geometry, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6722 (class 0 OID 0)
-- Dependencies: 1091
-- Name: FUNCTION geometry_gist_consistent_nd(internal, extensions.geometry, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_gist_consistent_nd(internal, extensions.geometry, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6723 (class 0 OID 0)
-- Dependencies: 1242
-- Name: FUNCTION geometry_gist_decompress_2d(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_gist_decompress_2d(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6724 (class 0 OID 0)
-- Dependencies: 1265
-- Name: FUNCTION geometry_gist_decompress_nd(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_gist_decompress_nd(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6725 (class 0 OID 0)
-- Dependencies: 943
-- Name: FUNCTION geometry_gist_distance_2d(internal, extensions.geometry, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_gist_distance_2d(internal, extensions.geometry, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6726 (class 0 OID 0)
-- Dependencies: 499
-- Name: FUNCTION geometry_gist_distance_nd(internal, extensions.geometry, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_gist_distance_nd(internal, extensions.geometry, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6727 (class 0 OID 0)
-- Dependencies: 649
-- Name: FUNCTION geometry_gist_penalty_2d(internal, internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_gist_penalty_2d(internal, internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6728 (class 0 OID 0)
-- Dependencies: 903
-- Name: FUNCTION geometry_gist_penalty_nd(internal, internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_gist_penalty_nd(internal, internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6729 (class 0 OID 0)
-- Dependencies: 1197
-- Name: FUNCTION geometry_gist_picksplit_2d(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_gist_picksplit_2d(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6730 (class 0 OID 0)
-- Dependencies: 857
-- Name: FUNCTION geometry_gist_picksplit_nd(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_gist_picksplit_nd(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6731 (class 0 OID 0)
-- Dependencies: 608
-- Name: FUNCTION geometry_gist_same_2d(geom1 extensions.geometry, geom2 extensions.geometry, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_gist_same_2d(geom1 extensions.geometry, geom2 extensions.geometry, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6732 (class 0 OID 0)
-- Dependencies: 1132
-- Name: FUNCTION geometry_gist_same_nd(extensions.geometry, extensions.geometry, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_gist_same_nd(extensions.geometry, extensions.geometry, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6733 (class 0 OID 0)
-- Dependencies: 755
-- Name: FUNCTION geometry_gist_sortsupport_2d(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_gist_sortsupport_2d(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6734 (class 0 OID 0)
-- Dependencies: 1329
-- Name: FUNCTION geometry_gist_union_2d(bytea, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_gist_union_2d(bytea, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6735 (class 0 OID 0)
-- Dependencies: 630
-- Name: FUNCTION geometry_gist_union_nd(bytea, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_gist_union_nd(bytea, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6736 (class 0 OID 0)
-- Dependencies: 855
-- Name: FUNCTION geometry_gt(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_gt(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6737 (class 0 OID 0)
-- Dependencies: 1055
-- Name: FUNCTION geometry_hash(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_hash(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6738 (class 0 OID 0)
-- Dependencies: 1202
-- Name: FUNCTION geometry_le(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_le(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6739 (class 0 OID 0)
-- Dependencies: 835
-- Name: FUNCTION geometry_left(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_left(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6740 (class 0 OID 0)
-- Dependencies: 590
-- Name: FUNCTION geometry_lt(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_lt(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6741 (class 0 OID 0)
-- Dependencies: 781
-- Name: FUNCTION geometry_overabove(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_overabove(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6742 (class 0 OID 0)
-- Dependencies: 1181
-- Name: FUNCTION geometry_overbelow(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_overbelow(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6743 (class 0 OID 0)
-- Dependencies: 1133
-- Name: FUNCTION geometry_overlaps(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_overlaps(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6744 (class 0 OID 0)
-- Dependencies: 918
-- Name: FUNCTION geometry_overlaps_3d(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_overlaps_3d(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6745 (class 0 OID 0)
-- Dependencies: 1080
-- Name: FUNCTION geometry_overlaps_nd(extensions.geometry, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_overlaps_nd(extensions.geometry, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6746 (class 0 OID 0)
-- Dependencies: 1220
-- Name: FUNCTION geometry_overleft(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_overleft(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6747 (class 0 OID 0)
-- Dependencies: 1030
-- Name: FUNCTION geometry_overright(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_overright(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6748 (class 0 OID 0)
-- Dependencies: 942
-- Name: FUNCTION geometry_right(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_right(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6749 (class 0 OID 0)
-- Dependencies: 1367
-- Name: FUNCTION geometry_same(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_same(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6750 (class 0 OID 0)
-- Dependencies: 1147
-- Name: FUNCTION geometry_same_3d(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_same_3d(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6751 (class 0 OID 0)
-- Dependencies: 1209
-- Name: FUNCTION geometry_same_nd(extensions.geometry, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_same_nd(extensions.geometry, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6752 (class 0 OID 0)
-- Dependencies: 661
-- Name: FUNCTION geometry_sortsupport(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_sortsupport(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6753 (class 0 OID 0)
-- Dependencies: 882
-- Name: FUNCTION geometry_spgist_choose_2d(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_spgist_choose_2d(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6754 (class 0 OID 0)
-- Dependencies: 878
-- Name: FUNCTION geometry_spgist_choose_3d(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_spgist_choose_3d(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6755 (class 0 OID 0)
-- Dependencies: 743
-- Name: FUNCTION geometry_spgist_choose_nd(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_spgist_choose_nd(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6756 (class 0 OID 0)
-- Dependencies: 912
-- Name: FUNCTION geometry_spgist_compress_2d(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_spgist_compress_2d(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6757 (class 0 OID 0)
-- Dependencies: 1316
-- Name: FUNCTION geometry_spgist_compress_3d(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_spgist_compress_3d(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6758 (class 0 OID 0)
-- Dependencies: 510
-- Name: FUNCTION geometry_spgist_compress_nd(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_spgist_compress_nd(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6759 (class 0 OID 0)
-- Dependencies: 730
-- Name: FUNCTION geometry_spgist_config_2d(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_spgist_config_2d(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6760 (class 0 OID 0)
-- Dependencies: 1119
-- Name: FUNCTION geometry_spgist_config_3d(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_spgist_config_3d(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6761 (class 0 OID 0)
-- Dependencies: 653
-- Name: FUNCTION geometry_spgist_config_nd(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_spgist_config_nd(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6762 (class 0 OID 0)
-- Dependencies: 1402
-- Name: FUNCTION geometry_spgist_inner_consistent_2d(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_spgist_inner_consistent_2d(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6763 (class 0 OID 0)
-- Dependencies: 1201
-- Name: FUNCTION geometry_spgist_inner_consistent_3d(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_spgist_inner_consistent_3d(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6764 (class 0 OID 0)
-- Dependencies: 1239
-- Name: FUNCTION geometry_spgist_inner_consistent_nd(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_spgist_inner_consistent_nd(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6765 (class 0 OID 0)
-- Dependencies: 735
-- Name: FUNCTION geometry_spgist_leaf_consistent_2d(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_spgist_leaf_consistent_2d(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6766 (class 0 OID 0)
-- Dependencies: 747
-- Name: FUNCTION geometry_spgist_leaf_consistent_3d(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_spgist_leaf_consistent_3d(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6767 (class 0 OID 0)
-- Dependencies: 1101
-- Name: FUNCTION geometry_spgist_leaf_consistent_nd(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_spgist_leaf_consistent_nd(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6768 (class 0 OID 0)
-- Dependencies: 579
-- Name: FUNCTION geometry_spgist_picksplit_2d(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_spgist_picksplit_2d(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6769 (class 0 OID 0)
-- Dependencies: 983
-- Name: FUNCTION geometry_spgist_picksplit_3d(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_spgist_picksplit_3d(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6770 (class 0 OID 0)
-- Dependencies: 491
-- Name: FUNCTION geometry_spgist_picksplit_nd(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_spgist_picksplit_nd(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6771 (class 0 OID 0)
-- Dependencies: 1148
-- Name: FUNCTION geometry_within(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_within(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6772 (class 0 OID 0)
-- Dependencies: 576
-- Name: FUNCTION geometry_within_nd(extensions.geometry, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometry_within_nd(extensions.geometry, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6773 (class 0 OID 0)
-- Dependencies: 1309
-- Name: FUNCTION geometrytype(extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometrytype(extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6774 (class 0 OID 0)
-- Dependencies: 1319
-- Name: FUNCTION geometrytype(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geometrytype(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6775 (class 0 OID 0)
-- Dependencies: 1179
-- Name: FUNCTION geomfromewkb(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geomfromewkb(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6776 (class 0 OID 0)
-- Dependencies: 1243
-- Name: FUNCTION geomfromewkt(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.geomfromewkt(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6777 (class 0 OID 0)
-- Dependencies: 961
-- Name: FUNCTION get_proj4_from_srid(integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.get_proj4_from_srid(integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6778 (class 0 OID 0)
-- Dependencies: 1008
-- Name: FUNCTION gettransactionid(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gettransactionid() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6780 (class 0 OID 0)
-- Dependencies: 641
-- Name: FUNCTION grant_pg_cron_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION extensions.grant_pg_cron_access() FROM supabase_admin;
GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO supabase_admin WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO dashboard_user;


--
-- TOC entry 6782 (class 0 OID 0)
-- Dependencies: 1350
-- Name: FUNCTION grant_pg_graphql_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.grant_pg_graphql_access() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6784 (class 0 OID 0)
-- Dependencies: 972
-- Name: FUNCTION grant_pg_net_access(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION extensions.grant_pg_net_access() FROM supabase_admin;
GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO supabase_admin WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO dashboard_user;


--
-- TOC entry 6785 (class 0 OID 0)
-- Dependencies: 1016
-- Name: FUNCTION gserialized_gist_joinsel_2d(internal, oid, internal, smallint); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gserialized_gist_joinsel_2d(internal, oid, internal, smallint) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6786 (class 0 OID 0)
-- Dependencies: 1343
-- Name: FUNCTION gserialized_gist_joinsel_nd(internal, oid, internal, smallint); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gserialized_gist_joinsel_nd(internal, oid, internal, smallint) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6787 (class 0 OID 0)
-- Dependencies: 1376
-- Name: FUNCTION gserialized_gist_sel_2d(internal, oid, internal, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gserialized_gist_sel_2d(internal, oid, internal, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6788 (class 0 OID 0)
-- Dependencies: 680
-- Name: FUNCTION gserialized_gist_sel_nd(internal, oid, internal, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.gserialized_gist_sel_nd(internal, oid, internal, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6789 (class 0 OID 0)
-- Dependencies: 1023
-- Name: FUNCTION hmac(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.hmac(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.hmac(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.hmac(bytea, bytea, text) TO dashboard_user;


--
-- TOC entry 6790 (class 0 OID 0)
-- Dependencies: 910
-- Name: FUNCTION hmac(text, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.hmac(text, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.hmac(text, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.hmac(text, text, text) TO dashboard_user;


--
-- TOC entry 6791 (class 0 OID 0)
-- Dependencies: 1077
-- Name: FUNCTION is_contained_2d(extensions.box2df, extensions.box2df); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.is_contained_2d(extensions.box2df, extensions.box2df) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6792 (class 0 OID 0)
-- Dependencies: 1340
-- Name: FUNCTION is_contained_2d(extensions.box2df, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.is_contained_2d(extensions.box2df, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6793 (class 0 OID 0)
-- Dependencies: 484
-- Name: FUNCTION is_contained_2d(extensions.geometry, extensions.box2df); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.is_contained_2d(extensions.geometry, extensions.box2df) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6794 (class 0 OID 0)
-- Dependencies: 1170
-- Name: FUNCTION lockrow(text, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.lockrow(text, text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6795 (class 0 OID 0)
-- Dependencies: 1248
-- Name: FUNCTION lockrow(text, text, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.lockrow(text, text, text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6796 (class 0 OID 0)
-- Dependencies: 1182
-- Name: FUNCTION lockrow(text, text, text, timestamp without time zone); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.lockrow(text, text, text, timestamp without time zone) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6797 (class 0 OID 0)
-- Dependencies: 986
-- Name: FUNCTION lockrow(text, text, text, text, timestamp without time zone); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.lockrow(text, text, text, text, timestamp without time zone) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6798 (class 0 OID 0)
-- Dependencies: 969
-- Name: FUNCTION longtransactionsenabled(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.longtransactionsenabled() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6799 (class 0 OID 0)
-- Dependencies: 521
-- Name: FUNCTION overlaps_2d(extensions.box2df, extensions.box2df); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.overlaps_2d(extensions.box2df, extensions.box2df) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6800 (class 0 OID 0)
-- Dependencies: 1291
-- Name: FUNCTION overlaps_2d(extensions.box2df, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.overlaps_2d(extensions.box2df, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6801 (class 0 OID 0)
-- Dependencies: 922
-- Name: FUNCTION overlaps_2d(extensions.geometry, extensions.box2df); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.overlaps_2d(extensions.geometry, extensions.box2df) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6802 (class 0 OID 0)
-- Dependencies: 847
-- Name: FUNCTION overlaps_geog(extensions.geography, extensions.gidx); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.overlaps_geog(extensions.geography, extensions.gidx) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6803 (class 0 OID 0)
-- Dependencies: 577
-- Name: FUNCTION overlaps_geog(extensions.gidx, extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.overlaps_geog(extensions.gidx, extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6804 (class 0 OID 0)
-- Dependencies: 692
-- Name: FUNCTION overlaps_geog(extensions.gidx, extensions.gidx); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.overlaps_geog(extensions.gidx, extensions.gidx) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6805 (class 0 OID 0)
-- Dependencies: 1026
-- Name: FUNCTION overlaps_nd(extensions.geometry, extensions.gidx); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.overlaps_nd(extensions.geometry, extensions.gidx) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6806 (class 0 OID 0)
-- Dependencies: 565
-- Name: FUNCTION overlaps_nd(extensions.gidx, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.overlaps_nd(extensions.gidx, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6807 (class 0 OID 0)
-- Dependencies: 504
-- Name: FUNCTION overlaps_nd(extensions.gidx, extensions.gidx); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.overlaps_nd(extensions.gidx, extensions.gidx) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6808 (class 0 OID 0)
-- Dependencies: 1300
-- Name: FUNCTION pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone) FROM postgres;
GRANT ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT shared_blk_read_time double precision, OUT shared_blk_write_time double precision, OUT local_blk_read_time double precision, OUT local_blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision, OUT jit_deform_count bigint, OUT jit_deform_time double precision, OUT stats_since timestamp with time zone, OUT minmax_stats_since timestamp with time zone) TO dashboard_user;


--
-- TOC entry 6809 (class 0 OID 0)
-- Dependencies: 939
-- Name: FUNCTION pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) FROM postgres;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO dashboard_user;


--
-- TOC entry 6810 (class 0 OID 0)
-- Dependencies: 808
-- Name: FUNCTION pg_stat_statements_reset(userid oid, dbid oid, queryid bigint, minmax_only boolean); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint, minmax_only boolean) FROM postgres;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint, minmax_only boolean) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint, minmax_only boolean) TO dashboard_user;


--
-- TOC entry 6811 (class 0 OID 0)
-- Dependencies: 1045
-- Name: FUNCTION pgis_asflatgeobuf_finalfn(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_asflatgeobuf_finalfn(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6812 (class 0 OID 0)
-- Dependencies: 825
-- Name: FUNCTION pgis_asflatgeobuf_transfn(internal, anyelement); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_asflatgeobuf_transfn(internal, anyelement) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6813 (class 0 OID 0)
-- Dependencies: 670
-- Name: FUNCTION pgis_asflatgeobuf_transfn(internal, anyelement, boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_asflatgeobuf_transfn(internal, anyelement, boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6814 (class 0 OID 0)
-- Dependencies: 654
-- Name: FUNCTION pgis_asflatgeobuf_transfn(internal, anyelement, boolean, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_asflatgeobuf_transfn(internal, anyelement, boolean, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6815 (class 0 OID 0)
-- Dependencies: 1090
-- Name: FUNCTION pgis_asgeobuf_finalfn(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_asgeobuf_finalfn(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6816 (class 0 OID 0)
-- Dependencies: 1071
-- Name: FUNCTION pgis_asgeobuf_transfn(internal, anyelement); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_asgeobuf_transfn(internal, anyelement) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6817 (class 0 OID 0)
-- Dependencies: 738
-- Name: FUNCTION pgis_asgeobuf_transfn(internal, anyelement, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_asgeobuf_transfn(internal, anyelement, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6818 (class 0 OID 0)
-- Dependencies: 1287
-- Name: FUNCTION pgis_asmvt_combinefn(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_asmvt_combinefn(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6819 (class 0 OID 0)
-- Dependencies: 642
-- Name: FUNCTION pgis_asmvt_deserialfn(bytea, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_asmvt_deserialfn(bytea, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6820 (class 0 OID 0)
-- Dependencies: 779
-- Name: FUNCTION pgis_asmvt_finalfn(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_asmvt_finalfn(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6821 (class 0 OID 0)
-- Dependencies: 645
-- Name: FUNCTION pgis_asmvt_serialfn(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_asmvt_serialfn(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6822 (class 0 OID 0)
-- Dependencies: 1107
-- Name: FUNCTION pgis_asmvt_transfn(internal, anyelement); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_asmvt_transfn(internal, anyelement) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6823 (class 0 OID 0)
-- Dependencies: 1175
-- Name: FUNCTION pgis_asmvt_transfn(internal, anyelement, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_asmvt_transfn(internal, anyelement, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6824 (class 0 OID 0)
-- Dependencies: 823
-- Name: FUNCTION pgis_asmvt_transfn(internal, anyelement, text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_asmvt_transfn(internal, anyelement, text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6825 (class 0 OID 0)
-- Dependencies: 563
-- Name: FUNCTION pgis_asmvt_transfn(internal, anyelement, text, integer, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_asmvt_transfn(internal, anyelement, text, integer, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6826 (class 0 OID 0)
-- Dependencies: 1325
-- Name: FUNCTION pgis_asmvt_transfn(internal, anyelement, text, integer, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_asmvt_transfn(internal, anyelement, text, integer, text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6827 (class 0 OID 0)
-- Dependencies: 951
-- Name: FUNCTION pgis_geometry_accum_transfn(internal, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_geometry_accum_transfn(internal, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6828 (class 0 OID 0)
-- Dependencies: 1274
-- Name: FUNCTION pgis_geometry_accum_transfn(internal, extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_geometry_accum_transfn(internal, extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6829 (class 0 OID 0)
-- Dependencies: 622
-- Name: FUNCTION pgis_geometry_accum_transfn(internal, extensions.geometry, double precision, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_geometry_accum_transfn(internal, extensions.geometry, double precision, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6830 (class 0 OID 0)
-- Dependencies: 833
-- Name: FUNCTION pgis_geometry_clusterintersecting_finalfn(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_geometry_clusterintersecting_finalfn(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6831 (class 0 OID 0)
-- Dependencies: 531
-- Name: FUNCTION pgis_geometry_clusterwithin_finalfn(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_geometry_clusterwithin_finalfn(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6832 (class 0 OID 0)
-- Dependencies: 498
-- Name: FUNCTION pgis_geometry_collect_finalfn(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_geometry_collect_finalfn(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6833 (class 0 OID 0)
-- Dependencies: 897
-- Name: FUNCTION pgis_geometry_makeline_finalfn(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_geometry_makeline_finalfn(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6834 (class 0 OID 0)
-- Dependencies: 1356
-- Name: FUNCTION pgis_geometry_polygonize_finalfn(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_geometry_polygonize_finalfn(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6835 (class 0 OID 0)
-- Dependencies: 1105
-- Name: FUNCTION pgis_geometry_union_parallel_combinefn(internal, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_geometry_union_parallel_combinefn(internal, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6836 (class 0 OID 0)
-- Dependencies: 1128
-- Name: FUNCTION pgis_geometry_union_parallel_deserialfn(bytea, internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_geometry_union_parallel_deserialfn(bytea, internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6837 (class 0 OID 0)
-- Dependencies: 1061
-- Name: FUNCTION pgis_geometry_union_parallel_finalfn(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_geometry_union_parallel_finalfn(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6838 (class 0 OID 0)
-- Dependencies: 511
-- Name: FUNCTION pgis_geometry_union_parallel_serialfn(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_geometry_union_parallel_serialfn(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6839 (class 0 OID 0)
-- Dependencies: 898
-- Name: FUNCTION pgis_geometry_union_parallel_transfn(internal, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_geometry_union_parallel_transfn(internal, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6840 (class 0 OID 0)
-- Dependencies: 998
-- Name: FUNCTION pgis_geometry_union_parallel_transfn(internal, extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgis_geometry_union_parallel_transfn(internal, extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6841 (class 0 OID 0)
-- Dependencies: 647
-- Name: FUNCTION pgp_armor_headers(text, OUT key text, OUT value text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) TO dashboard_user;


--
-- TOC entry 6842 (class 0 OID 0)
-- Dependencies: 639
-- Name: FUNCTION pgp_key_id(bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_key_id(bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_key_id(bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_key_id(bytea) TO dashboard_user;


--
-- TOC entry 6843 (class 0 OID 0)
-- Dependencies: 893
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) TO dashboard_user;


--
-- TOC entry 6844 (class 0 OID 0)
-- Dependencies: 486
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) TO dashboard_user;


--
-- TOC entry 6845 (class 0 OID 0)
-- Dependencies: 1361
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) TO dashboard_user;


--
-- TOC entry 6846 (class 0 OID 0)
-- Dependencies: 1031
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) TO dashboard_user;


--
-- TOC entry 6847 (class 0 OID 0)
-- Dependencies: 1389
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) TO dashboard_user;


--
-- TOC entry 6848 (class 0 OID 0)
-- Dependencies: 915
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO dashboard_user;


--
-- TOC entry 6849 (class 0 OID 0)
-- Dependencies: 666
-- Name: FUNCTION pgp_pub_encrypt(text, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) TO dashboard_user;


--
-- TOC entry 6850 (class 0 OID 0)
-- Dependencies: 1131
-- Name: FUNCTION pgp_pub_encrypt(text, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) TO dashboard_user;


--
-- TOC entry 6851 (class 0 OID 0)
-- Dependencies: 1084
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) TO dashboard_user;


--
-- TOC entry 6852 (class 0 OID 0)
-- Dependencies: 889
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) TO dashboard_user;


--
-- TOC entry 6853 (class 0 OID 0)
-- Dependencies: 892
-- Name: FUNCTION pgp_sym_decrypt(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) TO dashboard_user;


--
-- TOC entry 6854 (class 0 OID 0)
-- Dependencies: 1136
-- Name: FUNCTION pgp_sym_decrypt(bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) TO dashboard_user;


--
-- TOC entry 6855 (class 0 OID 0)
-- Dependencies: 894
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) TO dashboard_user;


--
-- TOC entry 6856 (class 0 OID 0)
-- Dependencies: 890
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) TO dashboard_user;


--
-- TOC entry 6857 (class 0 OID 0)
-- Dependencies: 1412
-- Name: FUNCTION pgp_sym_encrypt(text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) TO dashboard_user;


--
-- TOC entry 6858 (class 0 OID 0)
-- Dependencies: 716
-- Name: FUNCTION pgp_sym_encrypt(text, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) TO dashboard_user;


--
-- TOC entry 6859 (class 0 OID 0)
-- Dependencies: 560
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) TO dashboard_user;


--
-- TOC entry 6860 (class 0 OID 0)
-- Dependencies: 904
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) FROM postgres;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) TO dashboard_user;


--
-- TOC entry 6861 (class 0 OID 0)
-- Dependencies: 952
-- Name: FUNCTION pgrst_ddl_watch(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgrst_ddl_watch() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6862 (class 0 OID 0)
-- Dependencies: 1387
-- Name: FUNCTION pgrst_drop_watch(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.pgrst_drop_watch() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6863 (class 0 OID 0)
-- Dependencies: 1386
-- Name: FUNCTION populate_geometry_columns(use_typmod boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.populate_geometry_columns(use_typmod boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6864 (class 0 OID 0)
-- Dependencies: 1049
-- Name: FUNCTION populate_geometry_columns(tbl_oid oid, use_typmod boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.populate_geometry_columns(tbl_oid oid, use_typmod boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6865 (class 0 OID 0)
-- Dependencies: 1258
-- Name: FUNCTION postgis_addbbox(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_addbbox(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6866 (class 0 OID 0)
-- Dependencies: 757
-- Name: FUNCTION postgis_cache_bbox(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_cache_bbox() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6867 (class 0 OID 0)
-- Dependencies: 546
-- Name: FUNCTION postgis_constraint_dims(geomschema text, geomtable text, geomcolumn text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_constraint_dims(geomschema text, geomtable text, geomcolumn text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6868 (class 0 OID 0)
-- Dependencies: 1342
-- Name: FUNCTION postgis_constraint_srid(geomschema text, geomtable text, geomcolumn text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_constraint_srid(geomschema text, geomtable text, geomcolumn text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6869 (class 0 OID 0)
-- Dependencies: 1261
-- Name: FUNCTION postgis_constraint_type(geomschema text, geomtable text, geomcolumn text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_constraint_type(geomschema text, geomtable text, geomcolumn text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6870 (class 0 OID 0)
-- Dependencies: 1267
-- Name: FUNCTION postgis_dropbbox(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_dropbbox(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6871 (class 0 OID 0)
-- Dependencies: 664
-- Name: FUNCTION postgis_extensions_upgrade(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_extensions_upgrade() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6872 (class 0 OID 0)
-- Dependencies: 609
-- Name: FUNCTION postgis_full_version(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_full_version() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6873 (class 0 OID 0)
-- Dependencies: 1083
-- Name: FUNCTION postgis_geos_noop(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_geos_noop(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6874 (class 0 OID 0)
-- Dependencies: 508
-- Name: FUNCTION postgis_geos_version(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_geos_version() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6875 (class 0 OID 0)
-- Dependencies: 1313
-- Name: FUNCTION postgis_getbbox(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_getbbox(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6876 (class 0 OID 0)
-- Dependencies: 614
-- Name: FUNCTION postgis_hasbbox(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_hasbbox(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6877 (class 0 OID 0)
-- Dependencies: 838
-- Name: FUNCTION postgis_index_supportfn(internal); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_index_supportfn(internal) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6878 (class 0 OID 0)
-- Dependencies: 895
-- Name: FUNCTION postgis_lib_build_date(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_lib_build_date() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6879 (class 0 OID 0)
-- Dependencies: 1190
-- Name: FUNCTION postgis_lib_revision(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_lib_revision() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6880 (class 0 OID 0)
-- Dependencies: 519
-- Name: FUNCTION postgis_lib_version(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_lib_version() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6881 (class 0 OID 0)
-- Dependencies: 1229
-- Name: FUNCTION postgis_libjson_version(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_libjson_version() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6882 (class 0 OID 0)
-- Dependencies: 984
-- Name: FUNCTION postgis_liblwgeom_version(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_liblwgeom_version() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6883 (class 0 OID 0)
-- Dependencies: 698
-- Name: FUNCTION postgis_libprotobuf_version(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_libprotobuf_version() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6884 (class 0 OID 0)
-- Dependencies: 1250
-- Name: FUNCTION postgis_libxml_version(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_libxml_version() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6885 (class 0 OID 0)
-- Dependencies: 927
-- Name: FUNCTION postgis_noop(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_noop(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6886 (class 0 OID 0)
-- Dependencies: 1093
-- Name: FUNCTION postgis_proj_version(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_proj_version() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6887 (class 0 OID 0)
-- Dependencies: 1102
-- Name: FUNCTION postgis_scripts_build_date(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_scripts_build_date() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6888 (class 0 OID 0)
-- Dependencies: 979
-- Name: FUNCTION postgis_scripts_installed(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_scripts_installed() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6889 (class 0 OID 0)
-- Dependencies: 1381
-- Name: FUNCTION postgis_scripts_released(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_scripts_released() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6890 (class 0 OID 0)
-- Dependencies: 701
-- Name: FUNCTION postgis_svn_version(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_svn_version() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6891 (class 0 OID 0)
-- Dependencies: 1075
-- Name: FUNCTION postgis_transform_geometry(geom extensions.geometry, text, text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_transform_geometry(geom extensions.geometry, text, text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6892 (class 0 OID 0)
-- Dependencies: 794
-- Name: FUNCTION postgis_type_name(geomname character varying, coord_dimension integer, use_new_name boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_type_name(geomname character varying, coord_dimension integer, use_new_name boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6893 (class 0 OID 0)
-- Dependencies: 754
-- Name: FUNCTION postgis_typmod_dims(integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_typmod_dims(integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6894 (class 0 OID 0)
-- Dependencies: 745
-- Name: FUNCTION postgis_typmod_srid(integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_typmod_srid(integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6895 (class 0 OID 0)
-- Dependencies: 1283
-- Name: FUNCTION postgis_typmod_type(integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_typmod_type(integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6896 (class 0 OID 0)
-- Dependencies: 530
-- Name: FUNCTION postgis_version(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_version() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6897 (class 0 OID 0)
-- Dependencies: 1066
-- Name: FUNCTION postgis_wagyu_version(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.postgis_wagyu_version() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6899 (class 0 OID 0)
-- Dependencies: 1344
-- Name: FUNCTION set_graphql_placeholder(); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.set_graphql_placeholder() TO postgres WITH GRANT OPTION;


--
-- TOC entry 6900 (class 0 OID 0)
-- Dependencies: 985
-- Name: FUNCTION st_3dclosestpoint(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_3dclosestpoint(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6901 (class 0 OID 0)
-- Dependencies: 1210
-- Name: FUNCTION st_3ddfullywithin(geom1 extensions.geometry, geom2 extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_3ddfullywithin(geom1 extensions.geometry, geom2 extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6902 (class 0 OID 0)
-- Dependencies: 832
-- Name: FUNCTION st_3ddistance(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_3ddistance(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6903 (class 0 OID 0)
-- Dependencies: 1160
-- Name: FUNCTION st_3ddwithin(geom1 extensions.geometry, geom2 extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_3ddwithin(geom1 extensions.geometry, geom2 extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6904 (class 0 OID 0)
-- Dependencies: 1354
-- Name: FUNCTION st_3dintersects(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_3dintersects(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6905 (class 0 OID 0)
-- Dependencies: 1000
-- Name: FUNCTION st_3dlength(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_3dlength(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6906 (class 0 OID 0)
-- Dependencies: 787
-- Name: FUNCTION st_3dlineinterpolatepoint(extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_3dlineinterpolatepoint(extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6907 (class 0 OID 0)
-- Dependencies: 990
-- Name: FUNCTION st_3dlongestline(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_3dlongestline(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6908 (class 0 OID 0)
-- Dependencies: 527
-- Name: FUNCTION st_3dmakebox(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_3dmakebox(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6909 (class 0 OID 0)
-- Dependencies: 1053
-- Name: FUNCTION st_3dmaxdistance(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_3dmaxdistance(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6910 (class 0 OID 0)
-- Dependencies: 1401
-- Name: FUNCTION st_3dperimeter(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_3dperimeter(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6911 (class 0 OID 0)
-- Dependencies: 1162
-- Name: FUNCTION st_3dshortestline(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_3dshortestline(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6912 (class 0 OID 0)
-- Dependencies: 767
-- Name: FUNCTION st_addmeasure(extensions.geometry, double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_addmeasure(extensions.geometry, double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6913 (class 0 OID 0)
-- Dependencies: 848
-- Name: FUNCTION st_addpoint(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_addpoint(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6914 (class 0 OID 0)
-- Dependencies: 574
-- Name: FUNCTION st_addpoint(geom1 extensions.geometry, geom2 extensions.geometry, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_addpoint(geom1 extensions.geometry, geom2 extensions.geometry, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6915 (class 0 OID 0)
-- Dependencies: 1145
-- Name: FUNCTION st_affine(extensions.geometry, double precision, double precision, double precision, double precision, double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_affine(extensions.geometry, double precision, double precision, double precision, double precision, double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6916 (class 0 OID 0)
-- Dependencies: 769
-- Name: FUNCTION st_affine(extensions.geometry, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_affine(extensions.geometry, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6917 (class 0 OID 0)
-- Dependencies: 525
-- Name: FUNCTION st_angle(line1 extensions.geometry, line2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_angle(line1 extensions.geometry, line2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6918 (class 0 OID 0)
-- Dependencies: 633
-- Name: FUNCTION st_angle(pt1 extensions.geometry, pt2 extensions.geometry, pt3 extensions.geometry, pt4 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_angle(pt1 extensions.geometry, pt2 extensions.geometry, pt3 extensions.geometry, pt4 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6919 (class 0 OID 0)
-- Dependencies: 913
-- Name: FUNCTION st_area(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_area(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6920 (class 0 OID 0)
-- Dependencies: 1396
-- Name: FUNCTION st_area(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_area(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6921 (class 0 OID 0)
-- Dependencies: 1295
-- Name: FUNCTION st_area(geog extensions.geography, use_spheroid boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_area(geog extensions.geography, use_spheroid boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6922 (class 0 OID 0)
-- Dependencies: 923
-- Name: FUNCTION st_area2d(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_area2d(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6923 (class 0 OID 0)
-- Dependencies: 1314
-- Name: FUNCTION st_asbinary(extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asbinary(extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6924 (class 0 OID 0)
-- Dependencies: 1186
-- Name: FUNCTION st_asbinary(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asbinary(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6925 (class 0 OID 0)
-- Dependencies: 572
-- Name: FUNCTION st_asbinary(extensions.geography, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asbinary(extensions.geography, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6926 (class 0 OID 0)
-- Dependencies: 1266
-- Name: FUNCTION st_asbinary(extensions.geometry, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asbinary(extensions.geometry, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6927 (class 0 OID 0)
-- Dependencies: 1276
-- Name: FUNCTION st_asencodedpolyline(geom extensions.geometry, nprecision integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asencodedpolyline(geom extensions.geometry, nprecision integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6928 (class 0 OID 0)
-- Dependencies: 759
-- Name: FUNCTION st_asewkb(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asewkb(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6929 (class 0 OID 0)
-- Dependencies: 562
-- Name: FUNCTION st_asewkb(extensions.geometry, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asewkb(extensions.geometry, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6930 (class 0 OID 0)
-- Dependencies: 597
-- Name: FUNCTION st_asewkt(extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asewkt(extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6931 (class 0 OID 0)
-- Dependencies: 1322
-- Name: FUNCTION st_asewkt(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asewkt(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6932 (class 0 OID 0)
-- Dependencies: 871
-- Name: FUNCTION st_asewkt(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asewkt(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6933 (class 0 OID 0)
-- Dependencies: 976
-- Name: FUNCTION st_asewkt(extensions.geography, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asewkt(extensions.geography, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6934 (class 0 OID 0)
-- Dependencies: 1199
-- Name: FUNCTION st_asewkt(extensions.geometry, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asewkt(extensions.geometry, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6935 (class 0 OID 0)
-- Dependencies: 917
-- Name: FUNCTION st_asgeojson(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asgeojson(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6936 (class 0 OID 0)
-- Dependencies: 773
-- Name: FUNCTION st_asgeojson(geog extensions.geography, maxdecimaldigits integer, options integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asgeojson(geog extensions.geography, maxdecimaldigits integer, options integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6937 (class 0 OID 0)
-- Dependencies: 612
-- Name: FUNCTION st_asgeojson(geom extensions.geometry, maxdecimaldigits integer, options integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asgeojson(geom extensions.geometry, maxdecimaldigits integer, options integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6938 (class 0 OID 0)
-- Dependencies: 1067
-- Name: FUNCTION st_asgeojson(r record, geom_column text, maxdecimaldigits integer, pretty_bool boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asgeojson(r record, geom_column text, maxdecimaldigits integer, pretty_bool boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6939 (class 0 OID 0)
-- Dependencies: 842
-- Name: FUNCTION st_asgml(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asgml(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6940 (class 0 OID 0)
-- Dependencies: 1272
-- Name: FUNCTION st_asgml(geom extensions.geometry, maxdecimaldigits integer, options integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asgml(geom extensions.geometry, maxdecimaldigits integer, options integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6941 (class 0 OID 0)
-- Dependencies: 782
-- Name: FUNCTION st_asgml(geog extensions.geography, maxdecimaldigits integer, options integer, nprefix text, id text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asgml(geog extensions.geography, maxdecimaldigits integer, options integer, nprefix text, id text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6942 (class 0 OID 0)
-- Dependencies: 1163
-- Name: FUNCTION st_asgml(version integer, geog extensions.geography, maxdecimaldigits integer, options integer, nprefix text, id text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asgml(version integer, geog extensions.geography, maxdecimaldigits integer, options integer, nprefix text, id text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6943 (class 0 OID 0)
-- Dependencies: 1216
-- Name: FUNCTION st_asgml(version integer, geom extensions.geometry, maxdecimaldigits integer, options integer, nprefix text, id text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asgml(version integer, geom extensions.geometry, maxdecimaldigits integer, options integer, nprefix text, id text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6944 (class 0 OID 0)
-- Dependencies: 941
-- Name: FUNCTION st_ashexewkb(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_ashexewkb(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6945 (class 0 OID 0)
-- Dependencies: 763
-- Name: FUNCTION st_ashexewkb(extensions.geometry, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_ashexewkb(extensions.geometry, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6946 (class 0 OID 0)
-- Dependencies: 977
-- Name: FUNCTION st_askml(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_askml(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6947 (class 0 OID 0)
-- Dependencies: 726
-- Name: FUNCTION st_askml(geog extensions.geography, maxdecimaldigits integer, nprefix text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_askml(geog extensions.geography, maxdecimaldigits integer, nprefix text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6948 (class 0 OID 0)
-- Dependencies: 1012
-- Name: FUNCTION st_askml(geom extensions.geometry, maxdecimaldigits integer, nprefix text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_askml(geom extensions.geometry, maxdecimaldigits integer, nprefix text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6949 (class 0 OID 0)
-- Dependencies: 1143
-- Name: FUNCTION st_aslatlontext(geom extensions.geometry, tmpl text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_aslatlontext(geom extensions.geometry, tmpl text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6950 (class 0 OID 0)
-- Dependencies: 719
-- Name: FUNCTION st_asmarc21(geom extensions.geometry, format text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asmarc21(geom extensions.geometry, format text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6951 (class 0 OID 0)
-- Dependencies: 1015
-- Name: FUNCTION st_asmvtgeom(geom extensions.geometry, bounds extensions.box2d, extent integer, buffer integer, clip_geom boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asmvtgeom(geom extensions.geometry, bounds extensions.box2d, extent integer, buffer integer, clip_geom boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6952 (class 0 OID 0)
-- Dependencies: 1251
-- Name: FUNCTION st_assvg(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_assvg(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6953 (class 0 OID 0)
-- Dependencies: 539
-- Name: FUNCTION st_assvg(geog extensions.geography, rel integer, maxdecimaldigits integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_assvg(geog extensions.geography, rel integer, maxdecimaldigits integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6954 (class 0 OID 0)
-- Dependencies: 1034
-- Name: FUNCTION st_assvg(geom extensions.geometry, rel integer, maxdecimaldigits integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_assvg(geom extensions.geometry, rel integer, maxdecimaldigits integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6955 (class 0 OID 0)
-- Dependencies: 517
-- Name: FUNCTION st_astext(extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_astext(extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6956 (class 0 OID 0)
-- Dependencies: 1187
-- Name: FUNCTION st_astext(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_astext(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6957 (class 0 OID 0)
-- Dependencies: 991
-- Name: FUNCTION st_astext(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_astext(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6958 (class 0 OID 0)
-- Dependencies: 1317
-- Name: FUNCTION st_astext(extensions.geography, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_astext(extensions.geography, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6959 (class 0 OID 0)
-- Dependencies: 834
-- Name: FUNCTION st_astext(extensions.geometry, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_astext(extensions.geometry, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6960 (class 0 OID 0)
-- Dependencies: 617
-- Name: FUNCTION st_astwkb(geom extensions.geometry, prec integer, prec_z integer, prec_m integer, with_sizes boolean, with_boxes boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_astwkb(geom extensions.geometry, prec integer, prec_z integer, prec_m integer, with_sizes boolean, with_boxes boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6961 (class 0 OID 0)
-- Dependencies: 1070
-- Name: FUNCTION st_astwkb(geom extensions.geometry[], ids bigint[], prec integer, prec_z integer, prec_m integer, with_sizes boolean, with_boxes boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_astwkb(geom extensions.geometry[], ids bigint[], prec integer, prec_z integer, prec_m integer, with_sizes boolean, with_boxes boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6962 (class 0 OID 0)
-- Dependencies: 636
-- Name: FUNCTION st_asx3d(geom extensions.geometry, maxdecimaldigits integer, options integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asx3d(geom extensions.geometry, maxdecimaldigits integer, options integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6963 (class 0 OID 0)
-- Dependencies: 870
-- Name: FUNCTION st_azimuth(geog1 extensions.geography, geog2 extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_azimuth(geog1 extensions.geography, geog2 extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6964 (class 0 OID 0)
-- Dependencies: 803
-- Name: FUNCTION st_azimuth(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_azimuth(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6965 (class 0 OID 0)
-- Dependencies: 1238
-- Name: FUNCTION st_bdmpolyfromtext(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_bdmpolyfromtext(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6966 (class 0 OID 0)
-- Dependencies: 911
-- Name: FUNCTION st_bdpolyfromtext(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_bdpolyfromtext(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6967 (class 0 OID 0)
-- Dependencies: 1310
-- Name: FUNCTION st_boundary(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_boundary(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6968 (class 0 OID 0)
-- Dependencies: 1347
-- Name: FUNCTION st_boundingdiagonal(geom extensions.geometry, fits boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_boundingdiagonal(geom extensions.geometry, fits boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6969 (class 0 OID 0)
-- Dependencies: 1226
-- Name: FUNCTION st_box2dfromgeohash(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_box2dfromgeohash(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6970 (class 0 OID 0)
-- Dependencies: 740
-- Name: FUNCTION st_buffer(extensions.geography, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_buffer(extensions.geography, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6971 (class 0 OID 0)
-- Dependencies: 1137
-- Name: FUNCTION st_buffer(text, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_buffer(text, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6972 (class 0 OID 0)
-- Dependencies: 1025
-- Name: FUNCTION st_buffer(extensions.geography, double precision, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_buffer(extensions.geography, double precision, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6973 (class 0 OID 0)
-- Dependencies: 582
-- Name: FUNCTION st_buffer(extensions.geography, double precision, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_buffer(extensions.geography, double precision, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6974 (class 0 OID 0)
-- Dependencies: 1277
-- Name: FUNCTION st_buffer(geom extensions.geometry, radius double precision, quadsegs integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_buffer(geom extensions.geometry, radius double precision, quadsegs integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6975 (class 0 OID 0)
-- Dependencies: 791
-- Name: FUNCTION st_buffer(geom extensions.geometry, radius double precision, options text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_buffer(geom extensions.geometry, radius double precision, options text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6976 (class 0 OID 0)
-- Dependencies: 1231
-- Name: FUNCTION st_buffer(text, double precision, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_buffer(text, double precision, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6977 (class 0 OID 0)
-- Dependencies: 899
-- Name: FUNCTION st_buffer(text, double precision, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_buffer(text, double precision, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6978 (class 0 OID 0)
-- Dependencies: 575
-- Name: FUNCTION st_buildarea(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_buildarea(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6979 (class 0 OID 0)
-- Dependencies: 566
-- Name: FUNCTION st_centroid(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_centroid(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6980 (class 0 OID 0)
-- Dependencies: 1360
-- Name: FUNCTION st_centroid(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_centroid(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6981 (class 0 OID 0)
-- Dependencies: 652
-- Name: FUNCTION st_centroid(extensions.geography, use_spheroid boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_centroid(extensions.geography, use_spheroid boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6982 (class 0 OID 0)
-- Dependencies: 975
-- Name: FUNCTION st_chaikinsmoothing(extensions.geometry, integer, boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_chaikinsmoothing(extensions.geometry, integer, boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6983 (class 0 OID 0)
-- Dependencies: 1113
-- Name: FUNCTION st_cleangeometry(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_cleangeometry(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6984 (class 0 OID 0)
-- Dependencies: 596
-- Name: FUNCTION st_clipbybox2d(geom extensions.geometry, box extensions.box2d); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_clipbybox2d(geom extensions.geometry, box extensions.box2d) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6985 (class 0 OID 0)
-- Dependencies: 659
-- Name: FUNCTION st_closestpoint(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_closestpoint(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6986 (class 0 OID 0)
-- Dependencies: 479
-- Name: FUNCTION st_closestpointofapproach(extensions.geometry, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_closestpointofapproach(extensions.geometry, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6987 (class 0 OID 0)
-- Dependencies: 717
-- Name: FUNCTION st_clusterdbscan(extensions.geometry, eps double precision, minpoints integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_clusterdbscan(extensions.geometry, eps double precision, minpoints integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6988 (class 0 OID 0)
-- Dependencies: 1353
-- Name: FUNCTION st_clusterintersecting(extensions.geometry[]); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_clusterintersecting(extensions.geometry[]) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6989 (class 0 OID 0)
-- Dependencies: 978
-- Name: FUNCTION st_clusterkmeans(geom extensions.geometry, k integer, max_radius double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_clusterkmeans(geom extensions.geometry, k integer, max_radius double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6990 (class 0 OID 0)
-- Dependencies: 587
-- Name: FUNCTION st_clusterwithin(extensions.geometry[], double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_clusterwithin(extensions.geometry[], double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6991 (class 0 OID 0)
-- Dependencies: 1035
-- Name: FUNCTION st_collect(extensions.geometry[]); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_collect(extensions.geometry[]) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6992 (class 0 OID 0)
-- Dependencies: 1320
-- Name: FUNCTION st_collect(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_collect(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6993 (class 0 OID 0)
-- Dependencies: 778
-- Name: FUNCTION st_collectionextract(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_collectionextract(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6994 (class 0 OID 0)
-- Dependencies: 1411
-- Name: FUNCTION st_collectionextract(extensions.geometry, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_collectionextract(extensions.geometry, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6995 (class 0 OID 0)
-- Dependencies: 1126
-- Name: FUNCTION st_collectionhomogenize(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_collectionhomogenize(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6996 (class 0 OID 0)
-- Dependencies: 1278
-- Name: FUNCTION st_combinebbox(extensions.box2d, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_combinebbox(extensions.box2d, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6997 (class 0 OID 0)
-- Dependencies: 993
-- Name: FUNCTION st_combinebbox(extensions.box3d, extensions.box3d); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_combinebbox(extensions.box3d, extensions.box3d) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6998 (class 0 OID 0)
-- Dependencies: 665
-- Name: FUNCTION st_combinebbox(extensions.box3d, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_combinebbox(extensions.box3d, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 6999 (class 0 OID 0)
-- Dependencies: 925
-- Name: FUNCTION st_concavehull(param_geom extensions.geometry, param_pctconvex double precision, param_allow_holes boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_concavehull(param_geom extensions.geometry, param_pctconvex double precision, param_allow_holes boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7000 (class 0 OID 0)
-- Dependencies: 1397
-- Name: FUNCTION st_contains(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_contains(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7001 (class 0 OID 0)
-- Dependencies: 1378
-- Name: FUNCTION st_containsproperly(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_containsproperly(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7002 (class 0 OID 0)
-- Dependencies: 553
-- Name: FUNCTION st_convexhull(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_convexhull(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7003 (class 0 OID 0)
-- Dependencies: 1195
-- Name: FUNCTION st_coorddim(geometry extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_coorddim(geometry extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7004 (class 0 OID 0)
-- Dependencies: 629
-- Name: FUNCTION st_coveredby(geog1 extensions.geography, geog2 extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_coveredby(geog1 extensions.geography, geog2 extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7005 (class 0 OID 0)
-- Dependencies: 1281
-- Name: FUNCTION st_coveredby(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_coveredby(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7006 (class 0 OID 0)
-- Dependencies: 1069
-- Name: FUNCTION st_coveredby(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_coveredby(text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7007 (class 0 OID 0)
-- Dependencies: 1305
-- Name: FUNCTION st_covers(geog1 extensions.geography, geog2 extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_covers(geog1 extensions.geography, geog2 extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7008 (class 0 OID 0)
-- Dependencies: 970
-- Name: FUNCTION st_covers(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_covers(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7009 (class 0 OID 0)
-- Dependencies: 674
-- Name: FUNCTION st_covers(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_covers(text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7010 (class 0 OID 0)
-- Dependencies: 628
-- Name: FUNCTION st_cpawithin(extensions.geometry, extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_cpawithin(extensions.geometry, extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7011 (class 0 OID 0)
-- Dependencies: 702
-- Name: FUNCTION st_crosses(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_crosses(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7012 (class 0 OID 0)
-- Dependencies: 503
-- Name: FUNCTION st_curvetoline(geom extensions.geometry, tol double precision, toltype integer, flags integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_curvetoline(geom extensions.geometry, tol double precision, toltype integer, flags integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7013 (class 0 OID 0)
-- Dependencies: 675
-- Name: FUNCTION st_delaunaytriangles(g1 extensions.geometry, tolerance double precision, flags integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_delaunaytriangles(g1 extensions.geometry, tolerance double precision, flags integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7014 (class 0 OID 0)
-- Dependencies: 1384
-- Name: FUNCTION st_dfullywithin(geom1 extensions.geometry, geom2 extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_dfullywithin(geom1 extensions.geometry, geom2 extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7015 (class 0 OID 0)
-- Dependencies: 573
-- Name: FUNCTION st_difference(geom1 extensions.geometry, geom2 extensions.geometry, gridsize double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_difference(geom1 extensions.geometry, geom2 extensions.geometry, gridsize double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7016 (class 0 OID 0)
-- Dependencies: 786
-- Name: FUNCTION st_dimension(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_dimension(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7017 (class 0 OID 0)
-- Dependencies: 599
-- Name: FUNCTION st_disjoint(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_disjoint(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7018 (class 0 OID 0)
-- Dependencies: 1302
-- Name: FUNCTION st_distance(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_distance(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7019 (class 0 OID 0)
-- Dependencies: 908
-- Name: FUNCTION st_distance(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_distance(text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7020 (class 0 OID 0)
-- Dependencies: 1038
-- Name: FUNCTION st_distance(geog1 extensions.geography, geog2 extensions.geography, use_spheroid boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_distance(geog1 extensions.geography, geog2 extensions.geography, use_spheroid boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7021 (class 0 OID 0)
-- Dependencies: 839
-- Name: FUNCTION st_distancecpa(extensions.geometry, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_distancecpa(extensions.geometry, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7022 (class 0 OID 0)
-- Dependencies: 864
-- Name: FUNCTION st_distancesphere(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_distancesphere(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7023 (class 0 OID 0)
-- Dependencies: 1406
-- Name: FUNCTION st_distancesphere(geom1 extensions.geometry, geom2 extensions.geometry, radius double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_distancesphere(geom1 extensions.geometry, geom2 extensions.geometry, radius double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7024 (class 0 OID 0)
-- Dependencies: 1178
-- Name: FUNCTION st_distancespheroid(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_distancespheroid(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7025 (class 0 OID 0)
-- Dependencies: 1245
-- Name: FUNCTION st_distancespheroid(geom1 extensions.geometry, geom2 extensions.geometry, extensions.spheroid); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_distancespheroid(geom1 extensions.geometry, geom2 extensions.geometry, extensions.spheroid) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7026 (class 0 OID 0)
-- Dependencies: 685
-- Name: FUNCTION st_dump(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_dump(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7027 (class 0 OID 0)
-- Dependencies: 758
-- Name: FUNCTION st_dumppoints(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_dumppoints(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7028 (class 0 OID 0)
-- Dependencies: 557
-- Name: FUNCTION st_dumprings(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_dumprings(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7029 (class 0 OID 0)
-- Dependencies: 1052
-- Name: FUNCTION st_dumpsegments(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_dumpsegments(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7030 (class 0 OID 0)
-- Dependencies: 775
-- Name: FUNCTION st_dwithin(geom1 extensions.geometry, geom2 extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_dwithin(geom1 extensions.geometry, geom2 extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7031 (class 0 OID 0)
-- Dependencies: 816
-- Name: FUNCTION st_dwithin(text, text, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_dwithin(text, text, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7032 (class 0 OID 0)
-- Dependencies: 1204
-- Name: FUNCTION st_dwithin(geog1 extensions.geography, geog2 extensions.geography, tolerance double precision, use_spheroid boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_dwithin(geog1 extensions.geography, geog2 extensions.geography, tolerance double precision, use_spheroid boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7033 (class 0 OID 0)
-- Dependencies: 663
-- Name: FUNCTION st_endpoint(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_endpoint(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7034 (class 0 OID 0)
-- Dependencies: 1348
-- Name: FUNCTION st_envelope(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_envelope(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7035 (class 0 OID 0)
-- Dependencies: 1118
-- Name: FUNCTION st_equals(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_equals(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7036 (class 0 OID 0)
-- Dependencies: 524
-- Name: FUNCTION st_estimatedextent(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_estimatedextent(text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7037 (class 0 OID 0)
-- Dependencies: 541
-- Name: FUNCTION st_estimatedextent(text, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_estimatedextent(text, text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7038 (class 0 OID 0)
-- Dependencies: 712
-- Name: FUNCTION st_estimatedextent(text, text, text, boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_estimatedextent(text, text, text, boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7039 (class 0 OID 0)
-- Dependencies: 677
-- Name: FUNCTION st_expand(extensions.box2d, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_expand(extensions.box2d, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7040 (class 0 OID 0)
-- Dependencies: 1394
-- Name: FUNCTION st_expand(extensions.box3d, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_expand(extensions.box3d, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7041 (class 0 OID 0)
-- Dependencies: 621
-- Name: FUNCTION st_expand(extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_expand(extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7042 (class 0 OID 0)
-- Dependencies: 772
-- Name: FUNCTION st_expand(box extensions.box2d, dx double precision, dy double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_expand(box extensions.box2d, dx double precision, dy double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7043 (class 0 OID 0)
-- Dependencies: 580
-- Name: FUNCTION st_expand(box extensions.box3d, dx double precision, dy double precision, dz double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_expand(box extensions.box3d, dx double precision, dy double precision, dz double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7044 (class 0 OID 0)
-- Dependencies: 1233
-- Name: FUNCTION st_expand(geom extensions.geometry, dx double precision, dy double precision, dz double precision, dm double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_expand(geom extensions.geometry, dx double precision, dy double precision, dz double precision, dm double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7045 (class 0 OID 0)
-- Dependencies: 875
-- Name: FUNCTION st_exteriorring(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_exteriorring(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7046 (class 0 OID 0)
-- Dependencies: 1290
-- Name: FUNCTION st_filterbym(extensions.geometry, double precision, double precision, boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_filterbym(extensions.geometry, double precision, double precision, boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7047 (class 0 OID 0)
-- Dependencies: 1082
-- Name: FUNCTION st_findextent(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_findextent(text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7048 (class 0 OID 0)
-- Dependencies: 1042
-- Name: FUNCTION st_findextent(text, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_findextent(text, text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7049 (class 0 OID 0)
-- Dependencies: 888
-- Name: FUNCTION st_flipcoordinates(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_flipcoordinates(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7050 (class 0 OID 0)
-- Dependencies: 818
-- Name: FUNCTION st_force2d(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_force2d(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7051 (class 0 OID 0)
-- Dependencies: 1154
-- Name: FUNCTION st_force3d(geom extensions.geometry, zvalue double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_force3d(geom extensions.geometry, zvalue double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7052 (class 0 OID 0)
-- Dependencies: 1098
-- Name: FUNCTION st_force3dm(geom extensions.geometry, mvalue double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_force3dm(geom extensions.geometry, mvalue double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7053 (class 0 OID 0)
-- Dependencies: 615
-- Name: FUNCTION st_force3dz(geom extensions.geometry, zvalue double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_force3dz(geom extensions.geometry, zvalue double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7054 (class 0 OID 0)
-- Dependencies: 992
-- Name: FUNCTION st_force4d(geom extensions.geometry, zvalue double precision, mvalue double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_force4d(geom extensions.geometry, zvalue double precision, mvalue double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7055 (class 0 OID 0)
-- Dependencies: 1207
-- Name: FUNCTION st_forcecollection(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_forcecollection(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7056 (class 0 OID 0)
-- Dependencies: 1164
-- Name: FUNCTION st_forcecurve(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_forcecurve(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7057 (class 0 OID 0)
-- Dependencies: 768
-- Name: FUNCTION st_forcepolygonccw(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_forcepolygonccw(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7058 (class 0 OID 0)
-- Dependencies: 688
-- Name: FUNCTION st_forcepolygoncw(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_forcepolygoncw(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7059 (class 0 OID 0)
-- Dependencies: 494
-- Name: FUNCTION st_forcerhr(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_forcerhr(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7060 (class 0 OID 0)
-- Dependencies: 1173
-- Name: FUNCTION st_forcesfs(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_forcesfs(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7061 (class 0 OID 0)
-- Dependencies: 865
-- Name: FUNCTION st_forcesfs(extensions.geometry, version text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_forcesfs(extensions.geometry, version text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7062 (class 0 OID 0)
-- Dependencies: 720
-- Name: FUNCTION st_frechetdistance(geom1 extensions.geometry, geom2 extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_frechetdistance(geom1 extensions.geometry, geom2 extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7063 (class 0 OID 0)
-- Dependencies: 1375
-- Name: FUNCTION st_fromflatgeobuf(anyelement, bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_fromflatgeobuf(anyelement, bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7064 (class 0 OID 0)
-- Dependencies: 999
-- Name: FUNCTION st_fromflatgeobuftotable(text, text, bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_fromflatgeobuftotable(text, text, bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7065 (class 0 OID 0)
-- Dependencies: 492
-- Name: FUNCTION st_generatepoints(area extensions.geometry, npoints integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_generatepoints(area extensions.geometry, npoints integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7066 (class 0 OID 0)
-- Dependencies: 950
-- Name: FUNCTION st_generatepoints(area extensions.geometry, npoints integer, seed integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_generatepoints(area extensions.geometry, npoints integer, seed integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7067 (class 0 OID 0)
-- Dependencies: 610
-- Name: FUNCTION st_geogfromtext(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geogfromtext(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7068 (class 0 OID 0)
-- Dependencies: 924
-- Name: FUNCTION st_geogfromwkb(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geogfromwkb(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7069 (class 0 OID 0)
-- Dependencies: 866
-- Name: FUNCTION st_geographyfromtext(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geographyfromtext(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7070 (class 0 OID 0)
-- Dependencies: 974
-- Name: FUNCTION st_geohash(geog extensions.geography, maxchars integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geohash(geog extensions.geography, maxchars integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7071 (class 0 OID 0)
-- Dependencies: 534
-- Name: FUNCTION st_geohash(geom extensions.geometry, maxchars integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geohash(geom extensions.geometry, maxchars integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7072 (class 0 OID 0)
-- Dependencies: 707
-- Name: FUNCTION st_geomcollfromtext(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomcollfromtext(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7073 (class 0 OID 0)
-- Dependencies: 496
-- Name: FUNCTION st_geomcollfromtext(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomcollfromtext(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7074 (class 0 OID 0)
-- Dependencies: 594
-- Name: FUNCTION st_geomcollfromwkb(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomcollfromwkb(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7075 (class 0 OID 0)
-- Dependencies: 946
-- Name: FUNCTION st_geomcollfromwkb(bytea, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomcollfromwkb(bytea, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7076 (class 0 OID 0)
-- Dependencies: 1001
-- Name: FUNCTION st_geometricmedian(g extensions.geometry, tolerance double precision, max_iter integer, fail_if_not_converged boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geometricmedian(g extensions.geometry, tolerance double precision, max_iter integer, fail_if_not_converged boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7077 (class 0 OID 0)
-- Dependencies: 1257
-- Name: FUNCTION st_geometryfromtext(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geometryfromtext(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7078 (class 0 OID 0)
-- Dependencies: 883
-- Name: FUNCTION st_geometryfromtext(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geometryfromtext(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7079 (class 0 OID 0)
-- Dependencies: 682
-- Name: FUNCTION st_geometryn(extensions.geometry, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geometryn(extensions.geometry, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7080 (class 0 OID 0)
-- Dependencies: 584
-- Name: FUNCTION st_geometrytype(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geometrytype(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7081 (class 0 OID 0)
-- Dependencies: 876
-- Name: FUNCTION st_geomfromewkb(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomfromewkb(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7082 (class 0 OID 0)
-- Dependencies: 858
-- Name: FUNCTION st_geomfromewkt(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomfromewkt(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7083 (class 0 OID 0)
-- Dependencies: 1002
-- Name: FUNCTION st_geomfromgeohash(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomfromgeohash(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7084 (class 0 OID 0)
-- Dependencies: 555
-- Name: FUNCTION st_geomfromgeojson(json); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomfromgeojson(json) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7085 (class 0 OID 0)
-- Dependencies: 1046
-- Name: FUNCTION st_geomfromgeojson(jsonb); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomfromgeojson(jsonb) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7086 (class 0 OID 0)
-- Dependencies: 476
-- Name: FUNCTION st_geomfromgeojson(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomfromgeojson(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7087 (class 0 OID 0)
-- Dependencies: 817
-- Name: FUNCTION st_geomfromgml(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomfromgml(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7088 (class 0 OID 0)
-- Dependencies: 947
-- Name: FUNCTION st_geomfromgml(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomfromgml(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7089 (class 0 OID 0)
-- Dependencies: 765
-- Name: FUNCTION st_geomfromkml(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomfromkml(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7090 (class 0 OID 0)
-- Dependencies: 1003
-- Name: FUNCTION st_geomfrommarc21(marc21xml text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomfrommarc21(marc21xml text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7091 (class 0 OID 0)
-- Dependencies: 1036
-- Name: FUNCTION st_geomfromtext(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomfromtext(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7092 (class 0 OID 0)
-- Dependencies: 547
-- Name: FUNCTION st_geomfromtext(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomfromtext(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7093 (class 0 OID 0)
-- Dependencies: 542
-- Name: FUNCTION st_geomfromtwkb(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomfromtwkb(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7094 (class 0 OID 0)
-- Dependencies: 822
-- Name: FUNCTION st_geomfromwkb(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomfromwkb(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7095 (class 0 OID 0)
-- Dependencies: 1288
-- Name: FUNCTION st_geomfromwkb(bytea, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_geomfromwkb(bytea, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7096 (class 0 OID 0)
-- Dependencies: 729
-- Name: FUNCTION st_gmltosql(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_gmltosql(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7097 (class 0 OID 0)
-- Dependencies: 1123
-- Name: FUNCTION st_gmltosql(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_gmltosql(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7098 (class 0 OID 0)
-- Dependencies: 880
-- Name: FUNCTION st_hasarc(geometry extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_hasarc(geometry extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7099 (class 0 OID 0)
-- Dependencies: 774
-- Name: FUNCTION st_hausdorffdistance(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_hausdorffdistance(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7100 (class 0 OID 0)
-- Dependencies: 789
-- Name: FUNCTION st_hausdorffdistance(geom1 extensions.geometry, geom2 extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_hausdorffdistance(geom1 extensions.geometry, geom2 extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7101 (class 0 OID 0)
-- Dependencies: 891
-- Name: FUNCTION st_hexagon(size double precision, cell_i integer, cell_j integer, origin extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_hexagon(size double precision, cell_i integer, cell_j integer, origin extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7102 (class 0 OID 0)
-- Dependencies: 1115
-- Name: FUNCTION st_hexagongrid(size double precision, bounds extensions.geometry, OUT geom extensions.geometry, OUT i integer, OUT j integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_hexagongrid(size double precision, bounds extensions.geometry, OUT geom extensions.geometry, OUT i integer, OUT j integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7103 (class 0 OID 0)
-- Dependencies: 877
-- Name: FUNCTION st_interiorringn(extensions.geometry, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_interiorringn(extensions.geometry, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7104 (class 0 OID 0)
-- Dependencies: 1180
-- Name: FUNCTION st_interpolatepoint(line extensions.geometry, point extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_interpolatepoint(line extensions.geometry, point extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7105 (class 0 OID 0)
-- Dependencies: 1172
-- Name: FUNCTION st_intersection(extensions.geography, extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_intersection(extensions.geography, extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7106 (class 0 OID 0)
-- Dependencies: 1060
-- Name: FUNCTION st_intersection(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_intersection(text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7107 (class 0 OID 0)
-- Dependencies: 1405
-- Name: FUNCTION st_intersection(geom1 extensions.geometry, geom2 extensions.geometry, gridsize double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_intersection(geom1 extensions.geometry, geom2 extensions.geometry, gridsize double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7108 (class 0 OID 0)
-- Dependencies: 631
-- Name: FUNCTION st_intersects(geog1 extensions.geography, geog2 extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_intersects(geog1 extensions.geography, geog2 extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7109 (class 0 OID 0)
-- Dependencies: 929
-- Name: FUNCTION st_intersects(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_intersects(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7110 (class 0 OID 0)
-- Dependencies: 705
-- Name: FUNCTION st_intersects(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_intersects(text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7111 (class 0 OID 0)
-- Dependencies: 1176
-- Name: FUNCTION st_isclosed(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_isclosed(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7112 (class 0 OID 0)
-- Dependencies: 965
-- Name: FUNCTION st_iscollection(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_iscollection(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7113 (class 0 OID 0)
-- Dependencies: 931
-- Name: FUNCTION st_isempty(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_isempty(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7114 (class 0 OID 0)
-- Dependencies: 1365
-- Name: FUNCTION st_ispolygonccw(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_ispolygonccw(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7115 (class 0 OID 0)
-- Dependencies: 994
-- Name: FUNCTION st_ispolygoncw(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_ispolygoncw(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7116 (class 0 OID 0)
-- Dependencies: 934
-- Name: FUNCTION st_isring(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_isring(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7117 (class 0 OID 0)
-- Dependencies: 1152
-- Name: FUNCTION st_issimple(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_issimple(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7118 (class 0 OID 0)
-- Dependencies: 1177
-- Name: FUNCTION st_isvalid(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_isvalid(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7119 (class 0 OID 0)
-- Dependencies: 551
-- Name: FUNCTION st_isvalid(extensions.geometry, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_isvalid(extensions.geometry, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7120 (class 0 OID 0)
-- Dependencies: 600
-- Name: FUNCTION st_isvaliddetail(geom extensions.geometry, flags integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_isvaliddetail(geom extensions.geometry, flags integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7121 (class 0 OID 0)
-- Dependencies: 1039
-- Name: FUNCTION st_isvalidreason(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_isvalidreason(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7122 (class 0 OID 0)
-- Dependencies: 1307
-- Name: FUNCTION st_isvalidreason(extensions.geometry, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_isvalidreason(extensions.geometry, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7123 (class 0 OID 0)
-- Dependencies: 1383
-- Name: FUNCTION st_isvalidtrajectory(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_isvalidtrajectory(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7124 (class 0 OID 0)
-- Dependencies: 1331
-- Name: FUNCTION st_length(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_length(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7125 (class 0 OID 0)
-- Dependencies: 1007
-- Name: FUNCTION st_length(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_length(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7126 (class 0 OID 0)
-- Dependencies: 1262
-- Name: FUNCTION st_length(geog extensions.geography, use_spheroid boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_length(geog extensions.geography, use_spheroid boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7127 (class 0 OID 0)
-- Dependencies: 956
-- Name: FUNCTION st_length2d(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_length2d(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7128 (class 0 OID 0)
-- Dependencies: 1124
-- Name: FUNCTION st_length2dspheroid(extensions.geometry, extensions.spheroid); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_length2dspheroid(extensions.geometry, extensions.spheroid) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7129 (class 0 OID 0)
-- Dependencies: 1095
-- Name: FUNCTION st_lengthspheroid(extensions.geometry, extensions.spheroid); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_lengthspheroid(extensions.geometry, extensions.spheroid) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7130 (class 0 OID 0)
-- Dependencies: 1349
-- Name: FUNCTION st_letters(letters text, font json); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_letters(letters text, font json) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7131 (class 0 OID 0)
-- Dependencies: 1096
-- Name: FUNCTION st_linecrossingdirection(line1 extensions.geometry, line2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_linecrossingdirection(line1 extensions.geometry, line2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7132 (class 0 OID 0)
-- Dependencies: 605
-- Name: FUNCTION st_linefromencodedpolyline(txtin text, nprecision integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_linefromencodedpolyline(txtin text, nprecision integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7133 (class 0 OID 0)
-- Dependencies: 635
-- Name: FUNCTION st_linefrommultipoint(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_linefrommultipoint(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7134 (class 0 OID 0)
-- Dependencies: 982
-- Name: FUNCTION st_linefromtext(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_linefromtext(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7135 (class 0 OID 0)
-- Dependencies: 957
-- Name: FUNCTION st_linefromtext(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_linefromtext(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7136 (class 0 OID 0)
-- Dependencies: 489
-- Name: FUNCTION st_linefromwkb(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_linefromwkb(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7137 (class 0 OID 0)
-- Dependencies: 1157
-- Name: FUNCTION st_linefromwkb(bytea, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_linefromwkb(bytea, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7138 (class 0 OID 0)
-- Dependencies: 831
-- Name: FUNCTION st_lineinterpolatepoint(extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_lineinterpolatepoint(extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7139 (class 0 OID 0)
-- Dependencies: 607
-- Name: FUNCTION st_lineinterpolatepoints(extensions.geometry, double precision, repeat boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_lineinterpolatepoints(extensions.geometry, double precision, repeat boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7140 (class 0 OID 0)
-- Dependencies: 1165
-- Name: FUNCTION st_linelocatepoint(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_linelocatepoint(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7141 (class 0 OID 0)
-- Dependencies: 966
-- Name: FUNCTION st_linemerge(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_linemerge(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7142 (class 0 OID 0)
-- Dependencies: 721
-- Name: FUNCTION st_linemerge(extensions.geometry, boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_linemerge(extensions.geometry, boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7143 (class 0 OID 0)
-- Dependencies: 1196
-- Name: FUNCTION st_linestringfromwkb(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_linestringfromwkb(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7144 (class 0 OID 0)
-- Dependencies: 528
-- Name: FUNCTION st_linestringfromwkb(bytea, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_linestringfromwkb(bytea, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7145 (class 0 OID 0)
-- Dependencies: 724
-- Name: FUNCTION st_linesubstring(extensions.geometry, double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_linesubstring(extensions.geometry, double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7146 (class 0 OID 0)
-- Dependencies: 1125
-- Name: FUNCTION st_linetocurve(geometry extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_linetocurve(geometry extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7147 (class 0 OID 0)
-- Dependencies: 1032
-- Name: FUNCTION st_locatealong(geometry extensions.geometry, measure double precision, leftrightoffset double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_locatealong(geometry extensions.geometry, measure double precision, leftrightoffset double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7148 (class 0 OID 0)
-- Dependencies: 1404
-- Name: FUNCTION st_locatebetween(geometry extensions.geometry, frommeasure double precision, tomeasure double precision, leftrightoffset double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_locatebetween(geometry extensions.geometry, frommeasure double precision, tomeasure double precision, leftrightoffset double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7149 (class 0 OID 0)
-- Dependencies: 935
-- Name: FUNCTION st_locatebetweenelevations(geometry extensions.geometry, fromelevation double precision, toelevation double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_locatebetweenelevations(geometry extensions.geometry, fromelevation double precision, toelevation double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7150 (class 0 OID 0)
-- Dependencies: 1357
-- Name: FUNCTION st_longestline(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_longestline(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7151 (class 0 OID 0)
-- Dependencies: 1372
-- Name: FUNCTION st_m(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_m(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7152 (class 0 OID 0)
-- Dependencies: 1221
-- Name: FUNCTION st_makebox2d(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_makebox2d(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7153 (class 0 OID 0)
-- Dependencies: 711
-- Name: FUNCTION st_makeenvelope(double precision, double precision, double precision, double precision, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_makeenvelope(double precision, double precision, double precision, double precision, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7154 (class 0 OID 0)
-- Dependencies: 1351
-- Name: FUNCTION st_makeline(extensions.geometry[]); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_makeline(extensions.geometry[]) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7155 (class 0 OID 0)
-- Dependencies: 477
-- Name: FUNCTION st_makeline(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_makeline(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7156 (class 0 OID 0)
-- Dependencies: 689
-- Name: FUNCTION st_makepoint(double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_makepoint(double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7157 (class 0 OID 0)
-- Dependencies: 907
-- Name: FUNCTION st_makepoint(double precision, double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_makepoint(double precision, double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7158 (class 0 OID 0)
-- Dependencies: 1352
-- Name: FUNCTION st_makepoint(double precision, double precision, double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_makepoint(double precision, double precision, double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7159 (class 0 OID 0)
-- Dependencies: 1109
-- Name: FUNCTION st_makepointm(double precision, double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_makepointm(double precision, double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7160 (class 0 OID 0)
-- Dependencies: 1087
-- Name: FUNCTION st_makepolygon(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_makepolygon(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7161 (class 0 OID 0)
-- Dependencies: 1158
-- Name: FUNCTION st_makepolygon(extensions.geometry, extensions.geometry[]); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_makepolygon(extensions.geometry, extensions.geometry[]) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7162 (class 0 OID 0)
-- Dependencies: 792
-- Name: FUNCTION st_makevalid(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_makevalid(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7163 (class 0 OID 0)
-- Dependencies: 989
-- Name: FUNCTION st_makevalid(geom extensions.geometry, params text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_makevalid(geom extensions.geometry, params text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7164 (class 0 OID 0)
-- Dependencies: 940
-- Name: FUNCTION st_maxdistance(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_maxdistance(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7165 (class 0 OID 0)
-- Dependencies: 644
-- Name: FUNCTION st_maximuminscribedcircle(extensions.geometry, OUT center extensions.geometry, OUT nearest extensions.geometry, OUT radius double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_maximuminscribedcircle(extensions.geometry, OUT center extensions.geometry, OUT nearest extensions.geometry, OUT radius double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7166 (class 0 OID 0)
-- Dependencies: 837
-- Name: FUNCTION st_memsize(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_memsize(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7167 (class 0 OID 0)
-- Dependencies: 1161
-- Name: FUNCTION st_minimumboundingcircle(inputgeom extensions.geometry, segs_per_quarter integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_minimumboundingcircle(inputgeom extensions.geometry, segs_per_quarter integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7168 (class 0 OID 0)
-- Dependencies: 901
-- Name: FUNCTION st_minimumboundingradius(extensions.geometry, OUT center extensions.geometry, OUT radius double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_minimumboundingradius(extensions.geometry, OUT center extensions.geometry, OUT radius double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7169 (class 0 OID 0)
-- Dependencies: 1166
-- Name: FUNCTION st_minimumclearance(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_minimumclearance(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7170 (class 0 OID 0)
-- Dependencies: 1304
-- Name: FUNCTION st_minimumclearanceline(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_minimumclearanceline(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7171 (class 0 OID 0)
-- Dependencies: 1033
-- Name: FUNCTION st_mlinefromtext(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_mlinefromtext(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7172 (class 0 OID 0)
-- Dependencies: 756
-- Name: FUNCTION st_mlinefromtext(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_mlinefromtext(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7173 (class 0 OID 0)
-- Dependencies: 770
-- Name: FUNCTION st_mlinefromwkb(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_mlinefromwkb(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7174 (class 0 OID 0)
-- Dependencies: 860
-- Name: FUNCTION st_mlinefromwkb(bytea, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_mlinefromwkb(bytea, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7175 (class 0 OID 0)
-- Dependencies: 1388
-- Name: FUNCTION st_mpointfromtext(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_mpointfromtext(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7176 (class 0 OID 0)
-- Dependencies: 1017
-- Name: FUNCTION st_mpointfromtext(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_mpointfromtext(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7177 (class 0 OID 0)
-- Dependencies: 1063
-- Name: FUNCTION st_mpointfromwkb(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_mpointfromwkb(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7178 (class 0 OID 0)
-- Dependencies: 1409
-- Name: FUNCTION st_mpointfromwkb(bytea, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_mpointfromwkb(bytea, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7179 (class 0 OID 0)
-- Dependencies: 1400
-- Name: FUNCTION st_mpolyfromtext(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_mpolyfromtext(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7180 (class 0 OID 0)
-- Dependencies: 672
-- Name: FUNCTION st_mpolyfromtext(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_mpolyfromtext(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7181 (class 0 OID 0)
-- Dependencies: 919
-- Name: FUNCTION st_mpolyfromwkb(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_mpolyfromwkb(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7182 (class 0 OID 0)
-- Dependencies: 638
-- Name: FUNCTION st_mpolyfromwkb(bytea, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_mpolyfromwkb(bytea, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7183 (class 0 OID 0)
-- Dependencies: 1193
-- Name: FUNCTION st_multi(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_multi(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7184 (class 0 OID 0)
-- Dependencies: 1298
-- Name: FUNCTION st_multilinefromwkb(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_multilinefromwkb(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7185 (class 0 OID 0)
-- Dependencies: 1168
-- Name: FUNCTION st_multilinestringfromtext(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_multilinestringfromtext(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7186 (class 0 OID 0)
-- Dependencies: 1240
-- Name: FUNCTION st_multilinestringfromtext(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_multilinestringfromtext(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7187 (class 0 OID 0)
-- Dependencies: 1333
-- Name: FUNCTION st_multipointfromtext(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_multipointfromtext(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7188 (class 0 OID 0)
-- Dependencies: 1151
-- Name: FUNCTION st_multipointfromwkb(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_multipointfromwkb(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7189 (class 0 OID 0)
-- Dependencies: 819
-- Name: FUNCTION st_multipointfromwkb(bytea, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_multipointfromwkb(bytea, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7190 (class 0 OID 0)
-- Dependencies: 567
-- Name: FUNCTION st_multipolyfromwkb(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_multipolyfromwkb(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7191 (class 0 OID 0)
-- Dependencies: 1130
-- Name: FUNCTION st_multipolyfromwkb(bytea, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_multipolyfromwkb(bytea, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7192 (class 0 OID 0)
-- Dependencies: 1203
-- Name: FUNCTION st_multipolygonfromtext(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_multipolygonfromtext(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7193 (class 0 OID 0)
-- Dependencies: 739
-- Name: FUNCTION st_multipolygonfromtext(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_multipolygonfromtext(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7194 (class 0 OID 0)
-- Dependencies: 806
-- Name: FUNCTION st_ndims(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_ndims(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7195 (class 0 OID 0)
-- Dependencies: 1232
-- Name: FUNCTION st_node(g extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_node(g extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7196 (class 0 OID 0)
-- Dependencies: 1106
-- Name: FUNCTION st_normalize(geom extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_normalize(geom extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7197 (class 0 OID 0)
-- Dependencies: 980
-- Name: FUNCTION st_npoints(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_npoints(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7198 (class 0 OID 0)
-- Dependencies: 1062
-- Name: FUNCTION st_nrings(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_nrings(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7199 (class 0 OID 0)
-- Dependencies: 1121
-- Name: FUNCTION st_numgeometries(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_numgeometries(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7200 (class 0 OID 0)
-- Dependencies: 1027
-- Name: FUNCTION st_numinteriorring(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_numinteriorring(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7201 (class 0 OID 0)
-- Dependencies: 611
-- Name: FUNCTION st_numinteriorrings(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_numinteriorrings(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7202 (class 0 OID 0)
-- Dependencies: 1366
-- Name: FUNCTION st_numpatches(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_numpatches(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7203 (class 0 OID 0)
-- Dependencies: 1332
-- Name: FUNCTION st_numpoints(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_numpoints(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7204 (class 0 OID 0)
-- Dependencies: 683
-- Name: FUNCTION st_offsetcurve(line extensions.geometry, distance double precision, params text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_offsetcurve(line extensions.geometry, distance double precision, params text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7205 (class 0 OID 0)
-- Dependencies: 1004
-- Name: FUNCTION st_orderingequals(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_orderingequals(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7206 (class 0 OID 0)
-- Dependencies: 840
-- Name: FUNCTION st_orientedenvelope(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_orientedenvelope(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7207 (class 0 OID 0)
-- Dependencies: 1407
-- Name: FUNCTION st_overlaps(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_overlaps(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7208 (class 0 OID 0)
-- Dependencies: 650
-- Name: FUNCTION st_patchn(extensions.geometry, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_patchn(extensions.geometry, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7209 (class 0 OID 0)
-- Dependencies: 583
-- Name: FUNCTION st_perimeter(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_perimeter(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7210 (class 0 OID 0)
-- Dependencies: 749
-- Name: FUNCTION st_perimeter(geog extensions.geography, use_spheroid boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_perimeter(geog extensions.geography, use_spheroid boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7211 (class 0 OID 0)
-- Dependencies: 507
-- Name: FUNCTION st_perimeter2d(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_perimeter2d(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7212 (class 0 OID 0)
-- Dependencies: 1244
-- Name: FUNCTION st_point(double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_point(double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7213 (class 0 OID 0)
-- Dependencies: 626
-- Name: FUNCTION st_point(double precision, double precision, srid integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_point(double precision, double precision, srid integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7214 (class 0 OID 0)
-- Dependencies: 829
-- Name: FUNCTION st_pointfromgeohash(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_pointfromgeohash(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7215 (class 0 OID 0)
-- Dependencies: 536
-- Name: FUNCTION st_pointfromtext(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_pointfromtext(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7216 (class 0 OID 0)
-- Dependencies: 657
-- Name: FUNCTION st_pointfromtext(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_pointfromtext(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7217 (class 0 OID 0)
-- Dependencies: 1120
-- Name: FUNCTION st_pointfromwkb(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_pointfromwkb(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7218 (class 0 OID 0)
-- Dependencies: 497
-- Name: FUNCTION st_pointfromwkb(bytea, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_pointfromwkb(bytea, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7219 (class 0 OID 0)
-- Dependencies: 967
-- Name: FUNCTION st_pointinsidecircle(extensions.geometry, double precision, double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_pointinsidecircle(extensions.geometry, double precision, double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7220 (class 0 OID 0)
-- Dependencies: 1297
-- Name: FUNCTION st_pointm(xcoordinate double precision, ycoordinate double precision, mcoordinate double precision, srid integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_pointm(xcoordinate double precision, ycoordinate double precision, mcoordinate double precision, srid integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7221 (class 0 OID 0)
-- Dependencies: 1149
-- Name: FUNCTION st_pointn(extensions.geometry, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_pointn(extensions.geometry, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7222 (class 0 OID 0)
-- Dependencies: 1408
-- Name: FUNCTION st_pointonsurface(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_pointonsurface(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7223 (class 0 OID 0)
-- Dependencies: 684
-- Name: FUNCTION st_points(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_points(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7224 (class 0 OID 0)
-- Dependencies: 487
-- Name: FUNCTION st_pointz(xcoordinate double precision, ycoordinate double precision, zcoordinate double precision, srid integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_pointz(xcoordinate double precision, ycoordinate double precision, zcoordinate double precision, srid integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7225 (class 0 OID 0)
-- Dependencies: 1374
-- Name: FUNCTION st_pointzm(xcoordinate double precision, ycoordinate double precision, zcoordinate double precision, mcoordinate double precision, srid integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_pointzm(xcoordinate double precision, ycoordinate double precision, zcoordinate double precision, mcoordinate double precision, srid integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7226 (class 0 OID 0)
-- Dependencies: 807
-- Name: FUNCTION st_polyfromtext(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_polyfromtext(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7227 (class 0 OID 0)
-- Dependencies: 1282
-- Name: FUNCTION st_polyfromtext(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_polyfromtext(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7228 (class 0 OID 0)
-- Dependencies: 1171
-- Name: FUNCTION st_polyfromwkb(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_polyfromwkb(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7229 (class 0 OID 0)
-- Dependencies: 1020
-- Name: FUNCTION st_polyfromwkb(bytea, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_polyfromwkb(bytea, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7230 (class 0 OID 0)
-- Dependencies: 949
-- Name: FUNCTION st_polygon(extensions.geometry, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_polygon(extensions.geometry, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7231 (class 0 OID 0)
-- Dependencies: 964
-- Name: FUNCTION st_polygonfromtext(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_polygonfromtext(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7232 (class 0 OID 0)
-- Dependencies: 1339
-- Name: FUNCTION st_polygonfromtext(text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_polygonfromtext(text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7233 (class 0 OID 0)
-- Dependencies: 678
-- Name: FUNCTION st_polygonfromwkb(bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_polygonfromwkb(bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7234 (class 0 OID 0)
-- Dependencies: 933
-- Name: FUNCTION st_polygonfromwkb(bytea, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_polygonfromwkb(bytea, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7235 (class 0 OID 0)
-- Dependencies: 1271
-- Name: FUNCTION st_polygonize(extensions.geometry[]); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_polygonize(extensions.geometry[]) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7236 (class 0 OID 0)
-- Dependencies: 554
-- Name: FUNCTION st_project(geog extensions.geography, distance double precision, azimuth double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_project(geog extensions.geography, distance double precision, azimuth double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7237 (class 0 OID 0)
-- Dependencies: 1336
-- Name: FUNCTION st_quantizecoordinates(g extensions.geometry, prec_x integer, prec_y integer, prec_z integer, prec_m integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_quantizecoordinates(g extensions.geometry, prec_x integer, prec_y integer, prec_z integer, prec_m integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7238 (class 0 OID 0)
-- Dependencies: 1222
-- Name: FUNCTION st_reduceprecision(geom extensions.geometry, gridsize double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_reduceprecision(geom extensions.geometry, gridsize double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7239 (class 0 OID 0)
-- Dependencies: 637
-- Name: FUNCTION st_relate(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_relate(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7240 (class 0 OID 0)
-- Dependencies: 744
-- Name: FUNCTION st_relate(geom1 extensions.geometry, geom2 extensions.geometry, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_relate(geom1 extensions.geometry, geom2 extensions.geometry, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7241 (class 0 OID 0)
-- Dependencies: 540
-- Name: FUNCTION st_relate(geom1 extensions.geometry, geom2 extensions.geometry, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_relate(geom1 extensions.geometry, geom2 extensions.geometry, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7242 (class 0 OID 0)
-- Dependencies: 646
-- Name: FUNCTION st_relatematch(text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_relatematch(text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7243 (class 0 OID 0)
-- Dependencies: 1142
-- Name: FUNCTION st_removepoint(extensions.geometry, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_removepoint(extensions.geometry, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7244 (class 0 OID 0)
-- Dependencies: 1326
-- Name: FUNCTION st_removerepeatedpoints(geom extensions.geometry, tolerance double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_removerepeatedpoints(geom extensions.geometry, tolerance double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7245 (class 0 OID 0)
-- Dependencies: 520
-- Name: FUNCTION st_reverse(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_reverse(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7246 (class 0 OID 0)
-- Dependencies: 800
-- Name: FUNCTION st_rotate(extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_rotate(extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7247 (class 0 OID 0)
-- Dependencies: 604
-- Name: FUNCTION st_rotate(extensions.geometry, double precision, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_rotate(extensions.geometry, double precision, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7248 (class 0 OID 0)
-- Dependencies: 500
-- Name: FUNCTION st_rotate(extensions.geometry, double precision, double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_rotate(extensions.geometry, double precision, double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7249 (class 0 OID 0)
-- Dependencies: 746
-- Name: FUNCTION st_rotatex(extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_rotatex(extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7250 (class 0 OID 0)
-- Dependencies: 1089
-- Name: FUNCTION st_rotatey(extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_rotatey(extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7251 (class 0 OID 0)
-- Dependencies: 830
-- Name: FUNCTION st_rotatez(extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_rotatez(extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7252 (class 0 OID 0)
-- Dependencies: 851
-- Name: FUNCTION st_scale(extensions.geometry, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_scale(extensions.geometry, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7253 (class 0 OID 0)
-- Dependencies: 1296
-- Name: FUNCTION st_scale(extensions.geometry, extensions.geometry, origin extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_scale(extensions.geometry, extensions.geometry, origin extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7254 (class 0 OID 0)
-- Dependencies: 1275
-- Name: FUNCTION st_scale(extensions.geometry, double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_scale(extensions.geometry, double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7255 (class 0 OID 0)
-- Dependencies: 810
-- Name: FUNCTION st_scale(extensions.geometry, double precision, double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_scale(extensions.geometry, double precision, double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7256 (class 0 OID 0)
-- Dependencies: 603
-- Name: FUNCTION st_scroll(extensions.geometry, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_scroll(extensions.geometry, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7257 (class 0 OID 0)
-- Dependencies: 634
-- Name: FUNCTION st_segmentize(geog extensions.geography, max_segment_length double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_segmentize(geog extensions.geography, max_segment_length double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7258 (class 0 OID 0)
-- Dependencies: 601
-- Name: FUNCTION st_segmentize(extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_segmentize(extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7259 (class 0 OID 0)
-- Dependencies: 480
-- Name: FUNCTION st_seteffectivearea(extensions.geometry, double precision, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_seteffectivearea(extensions.geometry, double precision, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7260 (class 0 OID 0)
-- Dependencies: 914
-- Name: FUNCTION st_setpoint(extensions.geometry, integer, extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_setpoint(extensions.geometry, integer, extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7261 (class 0 OID 0)
-- Dependencies: 522
-- Name: FUNCTION st_setsrid(geog extensions.geography, srid integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_setsrid(geog extensions.geography, srid integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7262 (class 0 OID 0)
-- Dependencies: 696
-- Name: FUNCTION st_setsrid(geom extensions.geometry, srid integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_setsrid(geom extensions.geometry, srid integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7263 (class 0 OID 0)
-- Dependencies: 1377
-- Name: FUNCTION st_sharedpaths(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_sharedpaths(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7264 (class 0 OID 0)
-- Dependencies: 736
-- Name: FUNCTION st_shiftlongitude(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_shiftlongitude(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7265 (class 0 OID 0)
-- Dependencies: 1403
-- Name: FUNCTION st_shortestline(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_shortestline(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7266 (class 0 OID 0)
-- Dependencies: 1399
-- Name: FUNCTION st_simplify(extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_simplify(extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7267 (class 0 OID 0)
-- Dependencies: 516
-- Name: FUNCTION st_simplify(extensions.geometry, double precision, boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_simplify(extensions.geometry, double precision, boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7268 (class 0 OID 0)
-- Dependencies: 790
-- Name: FUNCTION st_simplifypolygonhull(geom extensions.geometry, vertex_fraction double precision, is_outer boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_simplifypolygonhull(geom extensions.geometry, vertex_fraction double precision, is_outer boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7269 (class 0 OID 0)
-- Dependencies: 1064
-- Name: FUNCTION st_simplifypreservetopology(extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_simplifypreservetopology(extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7270 (class 0 OID 0)
-- Dependencies: 691
-- Name: FUNCTION st_simplifyvw(extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_simplifyvw(extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7271 (class 0 OID 0)
-- Dependencies: 1116
-- Name: FUNCTION st_snap(geom1 extensions.geometry, geom2 extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_snap(geom1 extensions.geometry, geom2 extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7272 (class 0 OID 0)
-- Dependencies: 482
-- Name: FUNCTION st_snaptogrid(extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_snaptogrid(extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7273 (class 0 OID 0)
-- Dependencies: 1092
-- Name: FUNCTION st_snaptogrid(extensions.geometry, double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_snaptogrid(extensions.geometry, double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7274 (class 0 OID 0)
-- Dependencies: 1127
-- Name: FUNCTION st_snaptogrid(extensions.geometry, double precision, double precision, double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_snaptogrid(extensions.geometry, double precision, double precision, double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7275 (class 0 OID 0)
-- Dependencies: 962
-- Name: FUNCTION st_snaptogrid(geom1 extensions.geometry, geom2 extensions.geometry, double precision, double precision, double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_snaptogrid(geom1 extensions.geometry, geom2 extensions.geometry, double precision, double precision, double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7276 (class 0 OID 0)
-- Dependencies: 1155
-- Name: FUNCTION st_split(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_split(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7277 (class 0 OID 0)
-- Dependencies: 784
-- Name: FUNCTION st_square(size double precision, cell_i integer, cell_j integer, origin extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_square(size double precision, cell_i integer, cell_j integer, origin extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7278 (class 0 OID 0)
-- Dependencies: 713
-- Name: FUNCTION st_squaregrid(size double precision, bounds extensions.geometry, OUT geom extensions.geometry, OUT i integer, OUT j integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_squaregrid(size double precision, bounds extensions.geometry, OUT geom extensions.geometry, OUT i integer, OUT j integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7279 (class 0 OID 0)
-- Dependencies: 1198
-- Name: FUNCTION st_srid(geog extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_srid(geog extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7280 (class 0 OID 0)
-- Dependencies: 987
-- Name: FUNCTION st_srid(geom extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_srid(geom extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7281 (class 0 OID 0)
-- Dependencies: 955
-- Name: FUNCTION st_startpoint(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_startpoint(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7282 (class 0 OID 0)
-- Dependencies: 798
-- Name: FUNCTION st_subdivide(geom extensions.geometry, maxvertices integer, gridsize double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_subdivide(geom extensions.geometry, maxvertices integer, gridsize double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7283 (class 0 OID 0)
-- Dependencies: 1144
-- Name: FUNCTION st_summary(extensions.geography); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_summary(extensions.geography) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7284 (class 0 OID 0)
-- Dependencies: 812
-- Name: FUNCTION st_summary(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_summary(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7285 (class 0 OID 0)
-- Dependencies: 1312
-- Name: FUNCTION st_swapordinates(geom extensions.geometry, ords cstring); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_swapordinates(geom extensions.geometry, ords cstring) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7286 (class 0 OID 0)
-- Dependencies: 570
-- Name: FUNCTION st_symdifference(geom1 extensions.geometry, geom2 extensions.geometry, gridsize double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_symdifference(geom1 extensions.geometry, geom2 extensions.geometry, gridsize double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7287 (class 0 OID 0)
-- Dependencies: 1194
-- Name: FUNCTION st_symmetricdifference(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_symmetricdifference(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7288 (class 0 OID 0)
-- Dependencies: 1301
-- Name: FUNCTION st_tileenvelope(zoom integer, x integer, y integer, bounds extensions.geometry, margin double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_tileenvelope(zoom integer, x integer, y integer, bounds extensions.geometry, margin double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7289 (class 0 OID 0)
-- Dependencies: 1293
-- Name: FUNCTION st_touches(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_touches(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7290 (class 0 OID 0)
-- Dependencies: 714
-- Name: FUNCTION st_transform(extensions.geometry, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_transform(extensions.geometry, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7291 (class 0 OID 0)
-- Dependencies: 708
-- Name: FUNCTION st_transform(geom extensions.geometry, to_proj text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_transform(geom extensions.geometry, to_proj text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7292 (class 0 OID 0)
-- Dependencies: 1390
-- Name: FUNCTION st_transform(geom extensions.geometry, from_proj text, to_srid integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_transform(geom extensions.geometry, from_proj text, to_srid integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7293 (class 0 OID 0)
-- Dependencies: 945
-- Name: FUNCTION st_transform(geom extensions.geometry, from_proj text, to_proj text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_transform(geom extensions.geometry, from_proj text, to_proj text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7294 (class 0 OID 0)
-- Dependencies: 1021
-- Name: FUNCTION st_translate(extensions.geometry, double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_translate(extensions.geometry, double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7295 (class 0 OID 0)
-- Dependencies: 853
-- Name: FUNCTION st_translate(extensions.geometry, double precision, double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_translate(extensions.geometry, double precision, double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7296 (class 0 OID 0)
-- Dependencies: 1364
-- Name: FUNCTION st_transscale(extensions.geometry, double precision, double precision, double precision, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_transscale(extensions.geometry, double precision, double precision, double precision, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7297 (class 0 OID 0)
-- Dependencies: 1073
-- Name: FUNCTION st_triangulatepolygon(g1 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_triangulatepolygon(g1 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7298 (class 0 OID 0)
-- Dependencies: 699
-- Name: FUNCTION st_unaryunion(extensions.geometry, gridsize double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_unaryunion(extensions.geometry, gridsize double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7299 (class 0 OID 0)
-- Dependencies: 640
-- Name: FUNCTION st_union(extensions.geometry[]); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_union(extensions.geometry[]) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7300 (class 0 OID 0)
-- Dependencies: 916
-- Name: FUNCTION st_union(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_union(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7301 (class 0 OID 0)
-- Dependencies: 751
-- Name: FUNCTION st_union(geom1 extensions.geometry, geom2 extensions.geometry, gridsize double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_union(geom1 extensions.geometry, geom2 extensions.geometry, gridsize double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7302 (class 0 OID 0)
-- Dependencies: 862
-- Name: FUNCTION st_voronoilines(g1 extensions.geometry, tolerance double precision, extend_to extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_voronoilines(g1 extensions.geometry, tolerance double precision, extend_to extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7303 (class 0 OID 0)
-- Dependencies: 1022
-- Name: FUNCTION st_voronoipolygons(g1 extensions.geometry, tolerance double precision, extend_to extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_voronoipolygons(g1 extensions.geometry, tolerance double precision, extend_to extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7304 (class 0 OID 0)
-- Dependencies: 1256
-- Name: FUNCTION st_within(geom1 extensions.geometry, geom2 extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_within(geom1 extensions.geometry, geom2 extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7305 (class 0 OID 0)
-- Dependencies: 1362
-- Name: FUNCTION st_wkbtosql(wkb bytea); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_wkbtosql(wkb bytea) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7306 (class 0 OID 0)
-- Dependencies: 1254
-- Name: FUNCTION st_wkttosql(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_wkttosql(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7307 (class 0 OID 0)
-- Dependencies: 788
-- Name: FUNCTION st_wrapx(geom extensions.geometry, wrap double precision, move double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_wrapx(geom extensions.geometry, wrap double precision, move double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7308 (class 0 OID 0)
-- Dependencies: 506
-- Name: FUNCTION st_x(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_x(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7309 (class 0 OID 0)
-- Dependencies: 1230
-- Name: FUNCTION st_xmax(extensions.box3d); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_xmax(extensions.box3d) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7310 (class 0 OID 0)
-- Dependencies: 856
-- Name: FUNCTION st_xmin(extensions.box3d); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_xmin(extensions.box3d) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7311 (class 0 OID 0)
-- Dependencies: 1159
-- Name: FUNCTION st_y(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_y(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7312 (class 0 OID 0)
-- Dependencies: 861
-- Name: FUNCTION st_ymax(extensions.box3d); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_ymax(extensions.box3d) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7313 (class 0 OID 0)
-- Dependencies: 1318
-- Name: FUNCTION st_ymin(extensions.box3d); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_ymin(extensions.box3d) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7314 (class 0 OID 0)
-- Dependencies: 1380
-- Name: FUNCTION st_z(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_z(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7315 (class 0 OID 0)
-- Dependencies: 490
-- Name: FUNCTION st_zmax(extensions.box3d); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_zmax(extensions.box3d) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7316 (class 0 OID 0)
-- Dependencies: 656
-- Name: FUNCTION st_zmflag(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_zmflag(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7317 (class 0 OID 0)
-- Dependencies: 1323
-- Name: FUNCTION st_zmin(extensions.box3d); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_zmin(extensions.box3d) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7318 (class 0 OID 0)
-- Dependencies: 1214
-- Name: FUNCTION unlockrows(text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.unlockrows(text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7319 (class 0 OID 0)
-- Dependencies: 606
-- Name: FUNCTION updategeometrysrid(character varying, character varying, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.updategeometrysrid(character varying, character varying, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7320 (class 0 OID 0)
-- Dependencies: 1129
-- Name: FUNCTION updategeometrysrid(character varying, character varying, character varying, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.updategeometrysrid(character varying, character varying, character varying, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7321 (class 0 OID 0)
-- Dependencies: 613
-- Name: FUNCTION updategeometrysrid(catalogn_name character varying, schema_name character varying, table_name character varying, column_name character varying, new_srid_in integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.updategeometrysrid(catalogn_name character varying, schema_name character varying, table_name character varying, column_name character varying, new_srid_in integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7322 (class 0 OID 0)
-- Dependencies: 673
-- Name: FUNCTION uuid_generate_v1(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v1() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1() TO dashboard_user;


--
-- TOC entry 7323 (class 0 OID 0)
-- Dependencies: 859
-- Name: FUNCTION uuid_generate_v1mc(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v1mc() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1mc() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v1mc() TO dashboard_user;


--
-- TOC entry 7324 (class 0 OID 0)
-- Dependencies: 485
-- Name: FUNCTION uuid_generate_v3(namespace uuid, name text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) TO dashboard_user;


--
-- TOC entry 7325 (class 0 OID 0)
-- Dependencies: 552
-- Name: FUNCTION uuid_generate_v4(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v4() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v4() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v4() TO dashboard_user;


--
-- TOC entry 7326 (class 0 OID 0)
-- Dependencies: 1078
-- Name: FUNCTION uuid_generate_v5(namespace uuid, name text); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) TO dashboard_user;


--
-- TOC entry 7327 (class 0 OID 0)
-- Dependencies: 777
-- Name: FUNCTION uuid_nil(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_nil() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_nil() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_nil() TO dashboard_user;


--
-- TOC entry 7328 (class 0 OID 0)
-- Dependencies: 1085
-- Name: FUNCTION uuid_ns_dns(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_ns_dns() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_dns() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_dns() TO dashboard_user;


--
-- TOC entry 7329 (class 0 OID 0)
-- Dependencies: 1370
-- Name: FUNCTION uuid_ns_oid(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_ns_oid() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_oid() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_oid() TO dashboard_user;


--
-- TOC entry 7330 (class 0 OID 0)
-- Dependencies: 761
-- Name: FUNCTION uuid_ns_url(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_ns_url() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_url() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_url() TO dashboard_user;


--
-- TOC entry 7331 (class 0 OID 0)
-- Dependencies: 783
-- Name: FUNCTION uuid_ns_x500(); Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON FUNCTION extensions.uuid_ns_x500() FROM postgres;
GRANT ALL ON FUNCTION extensions.uuid_ns_x500() TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION extensions.uuid_ns_x500() TO dashboard_user;


--
-- TOC entry 7332 (class 0 OID 0)
-- Dependencies: 1371
-- Name: FUNCTION graphql("operationName" text, query text, variables jsonb, extensions jsonb); Type: ACL; Schema: graphql_public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO postgres;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO anon;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO authenticated;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO service_role;


--
-- TOC entry 7333 (class 0 OID 0)
-- Dependencies: 535
-- Name: FUNCTION pg_reload_conf(); Type: ACL; Schema: pg_catalog; Owner: supabase_admin
--

GRANT ALL ON FUNCTION pg_catalog.pg_reload_conf() TO postgres WITH GRANT OPTION;


--
-- TOC entry 7334 (class 0 OID 0)
-- Dependencies: 1138
-- Name: FUNCTION get_auth(p_usename text); Type: ACL; Schema: pgbouncer; Owner: supabase_admin
--

REVOKE ALL ON FUNCTION pgbouncer.get_auth(p_usename text) FROM PUBLIC;
GRANT ALL ON FUNCTION pgbouncer.get_auth(p_usename text) TO pgbouncer;


--
-- TOC entry 7335 (class 0 OID 0)
-- Dependencies: 623
-- Name: FUNCTION achievement_claim(p_key text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.achievement_claim(p_key text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.achievement_claim(p_key text) TO anon;
GRANT ALL ON FUNCTION public.achievement_claim(p_key text) TO authenticated;
GRANT ALL ON FUNCTION public.achievement_claim(p_key text) TO service_role;


--
-- TOC entry 7336 (class 0 OID 0)
-- Dependencies: 411
-- Name: TABLE gift_codes; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.gift_codes TO authenticated;
GRANT ALL ON TABLE public.gift_codes TO service_role;


--
-- TOC entry 7337 (class 0 OID 0)
-- Dependencies: 693
-- Name: FUNCTION admin_create_gift_code(p_amount_iqd bigint, p_code text, p_memo text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.admin_create_gift_code(p_amount_iqd bigint, p_code text, p_memo text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.admin_create_gift_code(p_amount_iqd bigint, p_code text, p_memo text) TO anon;
GRANT ALL ON FUNCTION public.admin_create_gift_code(p_amount_iqd bigint, p_code text, p_memo text) TO authenticated;
GRANT ALL ON FUNCTION public.admin_create_gift_code(p_amount_iqd bigint, p_code text, p_memo text) TO service_role;


--
-- TOC entry 7338 (class 0 OID 0)
-- Dependencies: 1079
-- Name: FUNCTION admin_mark_stale_drivers_offline(p_stale_after_seconds integer, p_limit integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.admin_mark_stale_drivers_offline(p_stale_after_seconds integer, p_limit integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.admin_mark_stale_drivers_offline(p_stale_after_seconds integer, p_limit integer) TO anon;
GRANT ALL ON FUNCTION public.admin_mark_stale_drivers_offline(p_stale_after_seconds integer, p_limit integer) TO authenticated;
GRANT ALL ON FUNCTION public.admin_mark_stale_drivers_offline(p_stale_after_seconds integer, p_limit integer) TO service_role;


--
-- TOC entry 7339 (class 0 OID 0)
-- Dependencies: 1100
-- Name: FUNCTION admin_record_ride_refund(p_ride_id uuid, p_refund_amount_iqd integer, p_reason text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.admin_record_ride_refund(p_ride_id uuid, p_refund_amount_iqd integer, p_reason text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.admin_record_ride_refund(p_ride_id uuid, p_refund_amount_iqd integer, p_reason text) TO anon;
GRANT ALL ON FUNCTION public.admin_record_ride_refund(p_ride_id uuid, p_refund_amount_iqd integer, p_reason text) TO authenticated;
GRANT ALL ON FUNCTION public.admin_record_ride_refund(p_ride_id uuid, p_refund_amount_iqd integer, p_reason text) TO service_role;


--
-- TOC entry 7340 (class 0 OID 0)
-- Dependencies: 695
-- Name: FUNCTION admin_update_ride_incident(p_incident_id uuid, p_status public.incident_status, p_assigned_to uuid, p_resolution_note text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.admin_update_ride_incident(p_incident_id uuid, p_status public.incident_status, p_assigned_to uuid, p_resolution_note text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.admin_update_ride_incident(p_incident_id uuid, p_status public.incident_status, p_assigned_to uuid, p_resolution_note text) TO anon;
GRANT ALL ON FUNCTION public.admin_update_ride_incident(p_incident_id uuid, p_status public.incident_status, p_assigned_to uuid, p_resolution_note text) TO authenticated;
GRANT ALL ON FUNCTION public.admin_update_ride_incident(p_incident_id uuid, p_status public.incident_status, p_assigned_to uuid, p_resolution_note text) TO service_role;


--
-- TOC entry 7341 (class 0 OID 0)
-- Dependencies: 900
-- Name: FUNCTION admin_wallet_integrity_snapshot(p_limit integer, p_hold_age_seconds integer, p_topup_age_seconds integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.admin_wallet_integrity_snapshot(p_limit integer, p_hold_age_seconds integer, p_topup_age_seconds integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.admin_wallet_integrity_snapshot(p_limit integer, p_hold_age_seconds integer, p_topup_age_seconds integer) TO anon;
GRANT ALL ON FUNCTION public.admin_wallet_integrity_snapshot(p_limit integer, p_hold_age_seconds integer, p_topup_age_seconds integer) TO authenticated;
GRANT ALL ON FUNCTION public.admin_wallet_integrity_snapshot(p_limit integer, p_hold_age_seconds integer, p_topup_age_seconds integer) TO service_role;


--
-- TOC entry 7342 (class 0 OID 0)
-- Dependencies: 1355
-- Name: FUNCTION admin_withdraw_approve(p_request_id uuid, p_note text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.admin_withdraw_approve(p_request_id uuid, p_note text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.admin_withdraw_approve(p_request_id uuid, p_note text) TO anon;
GRANT ALL ON FUNCTION public.admin_withdraw_approve(p_request_id uuid, p_note text) TO authenticated;
GRANT ALL ON FUNCTION public.admin_withdraw_approve(p_request_id uuid, p_note text) TO service_role;


--
-- TOC entry 7343 (class 0 OID 0)
-- Dependencies: 620
-- Name: FUNCTION admin_withdraw_mark_paid(p_request_id uuid, p_payout_reference text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.admin_withdraw_mark_paid(p_request_id uuid, p_payout_reference text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.admin_withdraw_mark_paid(p_request_id uuid, p_payout_reference text) TO anon;
GRANT ALL ON FUNCTION public.admin_withdraw_mark_paid(p_request_id uuid, p_payout_reference text) TO authenticated;
GRANT ALL ON FUNCTION public.admin_withdraw_mark_paid(p_request_id uuid, p_payout_reference text) TO service_role;


--
-- TOC entry 7344 (class 0 OID 0)
-- Dependencies: 556
-- Name: FUNCTION admin_withdraw_reject(p_request_id uuid, p_note text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.admin_withdraw_reject(p_request_id uuid, p_note text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.admin_withdraw_reject(p_request_id uuid, p_note text) TO anon;
GRANT ALL ON FUNCTION public.admin_withdraw_reject(p_request_id uuid, p_note text) TO authenticated;
GRANT ALL ON FUNCTION public.admin_withdraw_reject(p_request_id uuid, p_note text) TO service_role;


--
-- TOC entry 7345 (class 0 OID 0)
-- Dependencies: 742
-- Name: FUNCTION apply_rating_aggregate(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.apply_rating_aggregate() TO anon;
GRANT ALL ON FUNCTION public.apply_rating_aggregate() TO authenticated;
GRANT ALL ON FUNCTION public.apply_rating_aggregate() TO service_role;


--
-- TOC entry 7346 (class 0 OID 0)
-- Dependencies: 509
-- Name: FUNCTION apply_referral_rewards(p_referred_id uuid, p_ride_id uuid); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.apply_referral_rewards(p_referred_id uuid, p_ride_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION public.apply_referral_rewards(p_referred_id uuid, p_ride_id uuid) TO anon;
GRANT ALL ON FUNCTION public.apply_referral_rewards(p_referred_id uuid, p_ride_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.apply_referral_rewards(p_referred_id uuid, p_ride_id uuid) TO service_role;


--
-- TOC entry 7347 (class 0 OID 0)
-- Dependencies: 902
-- Name: FUNCTION create_receipt_from_payment(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.create_receipt_from_payment() TO anon;
GRANT ALL ON FUNCTION public.create_receipt_from_payment() TO authenticated;
GRANT ALL ON FUNCTION public.create_receipt_from_payment() TO service_role;


--
-- TOC entry 7348 (class 0 OID 0)
-- Dependencies: 1338
-- Name: FUNCTION create_ride_incident(p_ride_id uuid, p_category text, p_description text, p_severity public.incident_severity); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.create_ride_incident(p_ride_id uuid, p_category text, p_description text, p_severity public.incident_severity) FROM PUBLIC;
GRANT ALL ON FUNCTION public.create_ride_incident(p_ride_id uuid, p_category text, p_description text, p_severity public.incident_severity) TO anon;
GRANT ALL ON FUNCTION public.create_ride_incident(p_ride_id uuid, p_category text, p_description text, p_severity public.incident_severity) TO authenticated;
GRANT ALL ON FUNCTION public.create_ride_incident(p_ride_id uuid, p_category text, p_description text, p_severity public.incident_severity) TO service_role;


--
-- TOC entry 7349 (class 0 OID 0)
-- Dependencies: 874
-- Name: FUNCTION dispatch_accept_ride(p_request_id uuid, p_driver_id uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.dispatch_accept_ride(p_request_id uuid, p_driver_id uuid) TO anon;
GRANT ALL ON FUNCTION public.dispatch_accept_ride(p_request_id uuid, p_driver_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.dispatch_accept_ride(p_request_id uuid, p_driver_id uuid) TO service_role;


--
-- TOC entry 7350 (class 0 OID 0)
-- Dependencies: 1253
-- Name: FUNCTION dispatch_match_ride(p_request_id uuid, p_rider_id uuid, p_radius_m numeric, p_limit_n integer, p_match_ttl_seconds integer, p_stale_after_seconds integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.dispatch_match_ride(p_request_id uuid, p_rider_id uuid, p_radius_m numeric, p_limit_n integer, p_match_ttl_seconds integer, p_stale_after_seconds integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.dispatch_match_ride(p_request_id uuid, p_rider_id uuid, p_radius_m numeric, p_limit_n integer, p_match_ttl_seconds integer, p_stale_after_seconds integer) TO anon;
GRANT ALL ON FUNCTION public.dispatch_match_ride(p_request_id uuid, p_rider_id uuid, p_radius_m numeric, p_limit_n integer, p_match_ttl_seconds integer, p_stale_after_seconds integer) TO service_role;


--
-- TOC entry 7351 (class 0 OID 0)
-- Dependencies: 1335
-- Name: FUNCTION driver_leaderboard_refresh_day(p_day date); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.driver_leaderboard_refresh_day(p_day date) TO anon;
GRANT ALL ON FUNCTION public.driver_leaderboard_refresh_day(p_day date) TO authenticated;
GRANT ALL ON FUNCTION public.driver_leaderboard_refresh_day(p_day date) TO service_role;


--
-- TOC entry 7352 (class 0 OID 0)
-- Dependencies: 799
-- Name: FUNCTION driver_stats_rollup_day(p_day date); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.driver_stats_rollup_day(p_day date) TO anon;
GRANT ALL ON FUNCTION public.driver_stats_rollup_day(p_day date) TO authenticated;
GRANT ALL ON FUNCTION public.driver_stats_rollup_day(p_day date) TO service_role;


--
-- TOC entry 7353 (class 0 OID 0)
-- Dependencies: 532
-- Name: FUNCTION drivers_force_id_from_auth_uid(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.drivers_force_id_from_auth_uid() TO anon;
GRANT ALL ON FUNCTION public.drivers_force_id_from_auth_uid() TO authenticated;
GRANT ALL ON FUNCTION public.drivers_force_id_from_auth_uid() TO service_role;


--
-- TOC entry 7354 (class 0 OID 0)
-- Dependencies: 619
-- Name: FUNCTION enqueue_notification_outbox(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.enqueue_notification_outbox() TO anon;
GRANT ALL ON FUNCTION public.enqueue_notification_outbox() TO authenticated;
GRANT ALL ON FUNCTION public.enqueue_notification_outbox() TO service_role;


--
-- TOC entry 7355 (class 0 OID 0)
-- Dependencies: 795
-- Name: FUNCTION ensure_referral_code(p_user_id uuid); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.ensure_referral_code(p_user_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION public.ensure_referral_code(p_user_id uuid) TO anon;
GRANT ALL ON FUNCTION public.ensure_referral_code(p_user_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.ensure_referral_code(p_user_id uuid) TO service_role;


--
-- TOC entry 7356 (class 0 OID 0)
-- Dependencies: 996
-- Name: FUNCTION ensure_wallet_account(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.ensure_wallet_account() TO anon;
GRANT ALL ON FUNCTION public.ensure_wallet_account() TO authenticated;
GRANT ALL ON FUNCTION public.ensure_wallet_account() TO service_role;


--
-- TOC entry 7357 (class 0 OID 0)
-- Dependencies: 518
-- Name: FUNCTION estimate_ride_quote_iqd(_pickup extensions.geography, _dropoff extensions.geography); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.estimate_ride_quote_iqd(_pickup extensions.geography, _dropoff extensions.geography) TO anon;
GRANT ALL ON FUNCTION public.estimate_ride_quote_iqd(_pickup extensions.geography, _dropoff extensions.geography) TO authenticated;
GRANT ALL ON FUNCTION public.estimate_ride_quote_iqd(_pickup extensions.geography, _dropoff extensions.geography) TO service_role;


--
-- TOC entry 7358 (class 0 OID 0)
-- Dependencies: 906
-- Name: FUNCTION estimate_ride_quote_iqd_v2(_pickup extensions.geography, _dropoff extensions.geography, _product_code text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.estimate_ride_quote_iqd_v2(_pickup extensions.geography, _dropoff extensions.geography, _product_code text) TO anon;
GRANT ALL ON FUNCTION public.estimate_ride_quote_iqd_v2(_pickup extensions.geography, _dropoff extensions.geography, _product_code text) TO authenticated;
GRANT ALL ON FUNCTION public.estimate_ride_quote_iqd_v2(_pickup extensions.geography, _dropoff extensions.geography, _product_code text) TO service_role;


--
-- TOC entry 7359 (class 0 OID 0)
-- Dependencies: 1014
-- Name: FUNCTION get_assigned_driver(p_ride_id uuid); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.get_assigned_driver(p_ride_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION public.get_assigned_driver(p_ride_id uuid) TO anon;
GRANT ALL ON FUNCTION public.get_assigned_driver(p_ride_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.get_assigned_driver(p_ride_id uuid) TO service_role;


--
-- TOC entry 7360 (class 0 OID 0)
-- Dependencies: 651
-- Name: FUNCTION get_driver_leaderboard(p_period text, p_period_start date, p_limit integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.get_driver_leaderboard(p_period text, p_period_start date, p_limit integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.get_driver_leaderboard(p_period text, p_period_start date, p_limit integer) TO anon;
GRANT ALL ON FUNCTION public.get_driver_leaderboard(p_period text, p_period_start date, p_limit integer) TO authenticated;
GRANT ALL ON FUNCTION public.get_driver_leaderboard(p_period text, p_period_start date, p_limit integer) TO service_role;


--
-- TOC entry 7361 (class 0 OID 0)
-- Dependencies: 1074
-- Name: FUNCTION handle_new_user(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.handle_new_user() TO anon;
GRANT ALL ON FUNCTION public.handle_new_user() TO authenticated;
GRANT ALL ON FUNCTION public.handle_new_user() TO service_role;


--
-- TOC entry 7362 (class 0 OID 0)
-- Dependencies: 662
-- Name: FUNCTION is_admin(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.is_admin() FROM PUBLIC;
GRANT ALL ON FUNCTION public.is_admin() TO anon;
GRANT ALL ON FUNCTION public.is_admin() TO authenticated;
GRANT ALL ON FUNCTION public.is_admin() TO service_role;


--
-- TOC entry 7363 (class 0 OID 0)
-- Dependencies: 752
-- Name: FUNCTION notification_outbox_claim(p_limit integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.notification_outbox_claim(p_limit integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.notification_outbox_claim(p_limit integer) TO anon;
GRANT ALL ON FUNCTION public.notification_outbox_claim(p_limit integer) TO authenticated;
GRANT ALL ON FUNCTION public.notification_outbox_claim(p_limit integer) TO service_role;


--
-- TOC entry 7364 (class 0 OID 0)
-- Dependencies: 515
-- Name: FUNCTION notification_outbox_mark(p_outbox_id bigint, p_status text, p_error text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.notification_outbox_mark(p_outbox_id bigint, p_status text, p_error text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.notification_outbox_mark(p_outbox_id bigint, p_status text, p_error text) TO anon;
GRANT ALL ON FUNCTION public.notification_outbox_mark(p_outbox_id bigint, p_status text, p_error text) TO authenticated;
GRANT ALL ON FUNCTION public.notification_outbox_mark(p_outbox_id bigint, p_status text, p_error text) TO service_role;


--
-- TOC entry 7365 (class 0 OID 0)
-- Dependencies: 686
-- Name: FUNCTION notify_user(p_user_id uuid, p_kind text, p_title text, p_body text, p_data jsonb); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.notify_user(p_user_id uuid, p_kind text, p_title text, p_body text, p_data jsonb) FROM PUBLIC;
GRANT ALL ON FUNCTION public.notify_user(p_user_id uuid, p_kind text, p_title text, p_body text, p_data jsonb) TO anon;
GRANT ALL ON FUNCTION public.notify_user(p_user_id uuid, p_kind text, p_title text, p_body text, p_data jsonb) TO authenticated;
GRANT ALL ON FUNCTION public.notify_user(p_user_id uuid, p_kind text, p_title text, p_body text, p_data jsonb) TO service_role;


--
-- TOC entry 7366 (class 0 OID 0)
-- Dependencies: 1358
-- Name: FUNCTION on_ride_completed_side_effects(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.on_ride_completed_side_effects() TO anon;
GRANT ALL ON FUNCTION public.on_ride_completed_side_effects() TO authenticated;
GRANT ALL ON FUNCTION public.on_ride_completed_side_effects() TO service_role;


--
-- TOC entry 7367 (class 0 OID 0)
-- Dependencies: 690
-- Name: FUNCTION on_ride_completed_v1(p_ride_id uuid); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.on_ride_completed_v1(p_ride_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION public.on_ride_completed_v1(p_ride_id uuid) TO anon;
GRANT ALL ON FUNCTION public.on_ride_completed_v1(p_ride_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.on_ride_completed_v1(p_ride_id uuid) TO service_role;


--
-- TOC entry 7368 (class 0 OID 0)
-- Dependencies: 981
-- Name: FUNCTION profile_kyc_init(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.profile_kyc_init() FROM PUBLIC;
GRANT ALL ON FUNCTION public.profile_kyc_init() TO anon;
GRANT ALL ON FUNCTION public.profile_kyc_init() TO authenticated;
GRANT ALL ON FUNCTION public.profile_kyc_init() TO service_role;


--
-- TOC entry 7369 (class 0 OID 0)
-- Dependencies: 854
-- Name: FUNCTION quote_products_iqd(p_pickup_lat double precision, p_pickup_lng double precision, p_dropoff_lat double precision, p_dropoff_lng double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.quote_products_iqd(p_pickup_lat double precision, p_pickup_lng double precision, p_dropoff_lat double precision, p_dropoff_lng double precision) TO anon;
GRANT ALL ON FUNCTION public.quote_products_iqd(p_pickup_lat double precision, p_pickup_lng double precision, p_dropoff_lat double precision, p_dropoff_lng double precision) TO authenticated;
GRANT ALL ON FUNCTION public.quote_products_iqd(p_pickup_lat double precision, p_pickup_lng double precision, p_dropoff_lat double precision, p_dropoff_lng double precision) TO service_role;


--
-- TOC entry 7370 (class 0 OID 0)
-- Dependencies: 1368
-- Name: FUNCTION rate_limit_consume(p_key text, p_window_seconds integer, p_limit integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.rate_limit_consume(p_key text, p_window_seconds integer, p_limit integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.rate_limit_consume(p_key text, p_window_seconds integer, p_limit integer) TO anon;
GRANT ALL ON FUNCTION public.rate_limit_consume(p_key text, p_window_seconds integer, p_limit integer) TO authenticated;
GRANT ALL ON FUNCTION public.rate_limit_consume(p_key text, p_window_seconds integer, p_limit integer) TO service_role;


--
-- TOC entry 7371 (class 0 OID 0)
-- Dependencies: 1024
-- Name: FUNCTION redeem_gift_code(p_code text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.redeem_gift_code(p_code text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.redeem_gift_code(p_code text) TO anon;
GRANT ALL ON FUNCTION public.redeem_gift_code(p_code text) TO authenticated;
GRANT ALL ON FUNCTION public.redeem_gift_code(p_code text) TO service_role;


--
-- TOC entry 7372 (class 0 OID 0)
-- Dependencies: 1088
-- Name: FUNCTION referral_apply_code(p_code text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.referral_apply_code(p_code text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.referral_apply_code(p_code text) TO anon;
GRANT ALL ON FUNCTION public.referral_apply_code(p_code text) TO authenticated;
GRANT ALL ON FUNCTION public.referral_apply_code(p_code text) TO service_role;


--
-- TOC entry 7373 (class 0 OID 0)
-- Dependencies: 973
-- Name: FUNCTION referral_apply_rewards_for_ride(p_ride_id uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.referral_apply_rewards_for_ride(p_ride_id uuid) TO anon;
GRANT ALL ON FUNCTION public.referral_apply_rewards_for_ride(p_ride_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.referral_apply_rewards_for_ride(p_ride_id uuid) TO service_role;


--
-- TOC entry 7374 (class 0 OID 0)
-- Dependencies: 655
-- Name: FUNCTION referral_claim(p_code text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.referral_claim(p_code text) TO anon;
GRANT ALL ON FUNCTION public.referral_claim(p_code text) TO authenticated;
GRANT ALL ON FUNCTION public.referral_claim(p_code text) TO service_role;


--
-- TOC entry 7375 (class 0 OID 0)
-- Dependencies: 1219
-- Name: FUNCTION referral_code_init(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.referral_code_init() TO anon;
GRANT ALL ON FUNCTION public.referral_code_init() TO authenticated;
GRANT ALL ON FUNCTION public.referral_code_init() TO service_role;


--
-- TOC entry 7376 (class 0 OID 0)
-- Dependencies: 1010
-- Name: FUNCTION referral_generate_code(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.referral_generate_code() TO anon;
GRANT ALL ON FUNCTION public.referral_generate_code() TO authenticated;
GRANT ALL ON FUNCTION public.referral_generate_code() TO service_role;


--
-- TOC entry 7377 (class 0 OID 0)
-- Dependencies: 828
-- Name: FUNCTION referral_on_ride_completed(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.referral_on_ride_completed() TO anon;
GRANT ALL ON FUNCTION public.referral_on_ride_completed() TO authenticated;
GRANT ALL ON FUNCTION public.referral_on_ride_completed() TO service_role;


--
-- TOC entry 7378 (class 0 OID 0)
-- Dependencies: 718
-- Name: FUNCTION referral_status(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.referral_status() TO anon;
GRANT ALL ON FUNCTION public.referral_status() TO authenticated;
GRANT ALL ON FUNCTION public.referral_status() TO service_role;


--
-- TOC entry 7379 (class 0 OID 0)
-- Dependencies: 737
-- Name: FUNCTION refresh_driver_rank_snapshots(p_period text, p_period_start date, p_limit integer); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.refresh_driver_rank_snapshots(p_period text, p_period_start date, p_limit integer) FROM PUBLIC;
GRANT ALL ON FUNCTION public.refresh_driver_rank_snapshots(p_period text, p_period_start date, p_limit integer) TO anon;
GRANT ALL ON FUNCTION public.refresh_driver_rank_snapshots(p_period text, p_period_start date, p_limit integer) TO authenticated;
GRANT ALL ON FUNCTION public.refresh_driver_rank_snapshots(p_period text, p_period_start date, p_limit integer) TO service_role;


--
-- TOC entry 7380 (class 0 OID 0)
-- Dependencies: 1028
-- Name: FUNCTION revoke_trip_share_tokens_on_ride_end(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.revoke_trip_share_tokens_on_ride_end() TO anon;
GRANT ALL ON FUNCTION public.revoke_trip_share_tokens_on_ride_end() TO authenticated;
GRANT ALL ON FUNCTION public.revoke_trip_share_tokens_on_ride_end() TO service_role;


--
-- TOC entry 7381 (class 0 OID 0)
-- Dependencies: 1227
-- Name: FUNCTION ride_chat_get_or_create_thread(p_ride_id uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.ride_chat_get_or_create_thread(p_ride_id uuid) TO anon;
GRANT ALL ON FUNCTION public.ride_chat_get_or_create_thread(p_ride_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.ride_chat_get_or_create_thread(p_ride_id uuid) TO service_role;


--
-- TOC entry 7382 (class 0 OID 0)
-- Dependencies: 1057
-- Name: FUNCTION ride_chat_notify_on_message(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.ride_chat_notify_on_message() TO anon;
GRANT ALL ON FUNCTION public.ride_chat_notify_on_message() TO authenticated;
GRANT ALL ON FUNCTION public.ride_chat_notify_on_message() TO service_role;


--
-- TOC entry 7383 (class 0 OID 0)
-- Dependencies: 1292
-- Name: FUNCTION ride_requests_clear_match_fields(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.ride_requests_clear_match_fields() TO anon;
GRANT ALL ON FUNCTION public.ride_requests_clear_match_fields() TO authenticated;
GRANT ALL ON FUNCTION public.ride_requests_clear_match_fields() TO service_role;


--
-- TOC entry 7384 (class 0 OID 0)
-- Dependencies: 1050
-- Name: FUNCTION ride_requests_release_driver_on_unmatch(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.ride_requests_release_driver_on_unmatch() TO anon;
GRANT ALL ON FUNCTION public.ride_requests_release_driver_on_unmatch() TO authenticated;
GRANT ALL ON FUNCTION public.ride_requests_release_driver_on_unmatch() TO service_role;


--
-- TOC entry 7385 (class 0 OID 0)
-- Dependencies: 1263
-- Name: FUNCTION ride_requests_set_quote(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.ride_requests_set_quote() TO anon;
GRANT ALL ON FUNCTION public.ride_requests_set_quote() TO authenticated;
GRANT ALL ON FUNCTION public.ride_requests_set_quote() TO service_role;


--
-- TOC entry 7386 (class 0 OID 0)
-- Dependencies: 771
-- Name: FUNCTION ride_requests_set_status_timestamps(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.ride_requests_set_status_timestamps() TO anon;
GRANT ALL ON FUNCTION public.ride_requests_set_status_timestamps() TO authenticated;
GRANT ALL ON FUNCTION public.ride_requests_set_status_timestamps() TO service_role;


--
-- TOC entry 7387 (class 0 OID 0)
-- Dependencies: 648
-- Name: FUNCTION set_updated_at(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.set_updated_at() TO anon;
GRANT ALL ON FUNCTION public.set_updated_at() TO authenticated;
GRANT ALL ON FUNCTION public.set_updated_at() TO service_role;


--
-- TOC entry 7388 (class 0 OID 0)
-- Dependencies: 971
-- Name: FUNCTION st_dwithin(extensions.geography, extensions.geography, numeric); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_dwithin(extensions.geography, extensions.geography, numeric) TO anon;
GRANT ALL ON FUNCTION public.st_dwithin(extensions.geography, extensions.geography, numeric) TO authenticated;
GRANT ALL ON FUNCTION public.st_dwithin(extensions.geography, extensions.geography, numeric) TO service_role;


--
-- TOC entry 7389 (class 0 OID 0)
-- Dependencies: 820
-- Name: FUNCTION submit_ride_rating(p_ride_id uuid, p_rating smallint, p_comment text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.submit_ride_rating(p_ride_id uuid, p_rating smallint, p_comment text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.submit_ride_rating(p_ride_id uuid, p_rating smallint, p_comment text) TO anon;
GRANT ALL ON FUNCTION public.submit_ride_rating(p_ride_id uuid, p_rating smallint, p_comment text) TO authenticated;
GRANT ALL ON FUNCTION public.submit_ride_rating(p_ride_id uuid, p_rating smallint, p_comment text) TO service_role;


--
-- TOC entry 7390 (class 0 OID 0)
-- Dependencies: 703
-- Name: FUNCTION support_ticket_touch_updated_at(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.support_ticket_touch_updated_at() TO anon;
GRANT ALL ON FUNCTION public.support_ticket_touch_updated_at() TO authenticated;
GRANT ALL ON FUNCTION public.support_ticket_touch_updated_at() TO service_role;


--
-- TOC entry 7391 (class 0 OID 0)
-- Dependencies: 776
-- Name: FUNCTION sync_profile_kyc_from_submission(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.sync_profile_kyc_from_submission() TO anon;
GRANT ALL ON FUNCTION public.sync_profile_kyc_from_submission() TO authenticated;
GRANT ALL ON FUNCTION public.sync_profile_kyc_from_submission() TO service_role;


--
-- TOC entry 7392 (class 0 OID 0)
-- Dependencies: 938
-- Name: FUNCTION sync_public_profile(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.sync_public_profile() TO anon;
GRANT ALL ON FUNCTION public.sync_public_profile() TO authenticated;
GRANT ALL ON FUNCTION public.sync_public_profile() TO service_role;


--
-- TOC entry 7393 (class 0 OID 0)
-- Dependencies: 412
-- Name: TABLE rides; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.rides TO authenticated;
GRANT ALL ON TABLE public.rides TO service_role;


--
-- TOC entry 7394 (class 0 OID 0)
-- Dependencies: 501
-- Name: FUNCTION transition_ride_v2(p_ride_id uuid, p_to_status public.ride_status, p_actor_id uuid, p_actor_type public.ride_actor_type, p_expected_version integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.transition_ride_v2(p_ride_id uuid, p_to_status public.ride_status, p_actor_id uuid, p_actor_type public.ride_actor_type, p_expected_version integer) TO anon;
GRANT ALL ON FUNCTION public.transition_ride_v2(p_ride_id uuid, p_to_status public.ride_status, p_actor_id uuid, p_actor_type public.ride_actor_type, p_expected_version integer) TO service_role;


--
-- TOC entry 7395 (class 0 OID 0)
-- Dependencies: 1391
-- Name: FUNCTION try_get_vault_secret(p_name text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.try_get_vault_secret(p_name text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.try_get_vault_secret(p_name text) TO service_role;


--
-- TOC entry 7396 (class 0 OID 0)
-- Dependencies: 595
-- Name: FUNCTION update_driver_achievements(p_driver_id uuid); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.update_driver_achievements(p_driver_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION public.update_driver_achievements(p_driver_id uuid) TO anon;
GRANT ALL ON FUNCTION public.update_driver_achievements(p_driver_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.update_driver_achievements(p_driver_id uuid) TO service_role;


--
-- TOC entry 7397 (class 0 OID 0)
-- Dependencies: 1246
-- Name: FUNCTION update_receipt_on_refund(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.update_receipt_on_refund() TO anon;
GRANT ALL ON FUNCTION public.update_receipt_on_refund() TO authenticated;
GRANT ALL ON FUNCTION public.update_receipt_on_refund() TO service_role;


--
-- TOC entry 7398 (class 0 OID 0)
-- Dependencies: 671
-- Name: FUNCTION upsert_device_token(p_token text, p_platform text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.upsert_device_token(p_token text, p_platform text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.upsert_device_token(p_token text, p_platform text) TO anon;
GRANT ALL ON FUNCTION public.upsert_device_token(p_token text, p_platform text) TO authenticated;
GRANT ALL ON FUNCTION public.upsert_device_token(p_token text, p_platform text) TO service_role;


--
-- TOC entry 7399 (class 0 OID 0)
-- Dependencies: 1059
-- Name: FUNCTION user_notifications_mark_all_read(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.user_notifications_mark_all_read() FROM PUBLIC;
GRANT ALL ON FUNCTION public.user_notifications_mark_all_read() TO anon;
GRANT ALL ON FUNCTION public.user_notifications_mark_all_read() TO authenticated;
GRANT ALL ON FUNCTION public.user_notifications_mark_all_read() TO service_role;


--
-- TOC entry 7400 (class 0 OID 0)
-- Dependencies: 585
-- Name: FUNCTION user_notifications_mark_read(p_notification_id uuid); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.user_notifications_mark_read(p_notification_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION public.user_notifications_mark_read(p_notification_id uuid) TO anon;
GRANT ALL ON FUNCTION public.user_notifications_mark_read(p_notification_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.user_notifications_mark_read(p_notification_id uuid) TO service_role;


--
-- TOC entry 7401 (class 0 OID 0)
-- Dependencies: 1111
-- Name: FUNCTION wallet_cancel_withdraw(p_request_id uuid); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.wallet_cancel_withdraw(p_request_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION public.wallet_cancel_withdraw(p_request_id uuid) TO anon;
GRANT ALL ON FUNCTION public.wallet_cancel_withdraw(p_request_id uuid) TO authenticated;
GRANT ALL ON FUNCTION public.wallet_cancel_withdraw(p_request_id uuid) TO service_role;


--
-- TOC entry 7402 (class 0 OID 0)
-- Dependencies: 1141
-- Name: FUNCTION wallet_capture_ride_hold(p_ride_id uuid); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.wallet_capture_ride_hold(p_ride_id uuid) FROM PUBLIC;
GRANT ALL ON FUNCTION public.wallet_capture_ride_hold(p_ride_id uuid) TO anon;
GRANT ALL ON FUNCTION public.wallet_capture_ride_hold(p_ride_id uuid) TO service_role;


--
-- TOC entry 7403 (class 0 OID 0)
-- Dependencies: 413
-- Name: TABLE topup_intents; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.topup_intents TO authenticated;
GRANT ALL ON TABLE public.topup_intents TO service_role;


--
-- TOC entry 7404 (class 0 OID 0)
-- Dependencies: 867
-- Name: FUNCTION wallet_fail_topup(p_intent_id uuid, p_failure_reason text, p_provider_payload jsonb); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.wallet_fail_topup(p_intent_id uuid, p_failure_reason text, p_provider_payload jsonb) FROM PUBLIC;
GRANT ALL ON FUNCTION public.wallet_fail_topup(p_intent_id uuid, p_failure_reason text, p_provider_payload jsonb) TO anon;
GRANT ALL ON FUNCTION public.wallet_fail_topup(p_intent_id uuid, p_failure_reason text, p_provider_payload jsonb) TO authenticated;
GRANT ALL ON FUNCTION public.wallet_fail_topup(p_intent_id uuid, p_failure_reason text, p_provider_payload jsonb) TO service_role;


--
-- TOC entry 7405 (class 0 OID 0)
-- Dependencies: 1013
-- Name: FUNCTION wallet_finalize_topup(p_intent_id uuid, p_provider_tx_id text, p_provider_payload jsonb); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.wallet_finalize_topup(p_intent_id uuid, p_provider_tx_id text, p_provider_payload jsonb) FROM PUBLIC;
GRANT ALL ON FUNCTION public.wallet_finalize_topup(p_intent_id uuid, p_provider_tx_id text, p_provider_payload jsonb) TO anon;
GRANT ALL ON FUNCTION public.wallet_finalize_topup(p_intent_id uuid, p_provider_tx_id text, p_provider_payload jsonb) TO authenticated;
GRANT ALL ON FUNCTION public.wallet_finalize_topup(p_intent_id uuid, p_provider_tx_id text, p_provider_payload jsonb) TO service_role;


--
-- TOC entry 7406 (class 0 OID 0)
-- Dependencies: 414
-- Name: TABLE wallet_accounts; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.wallet_accounts TO authenticated;
GRANT ALL ON TABLE public.wallet_accounts TO service_role;


--
-- TOC entry 7407 (class 0 OID 0)
-- Dependencies: 909
-- Name: FUNCTION wallet_get_my_account(); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.wallet_get_my_account() FROM PUBLIC;
GRANT ALL ON FUNCTION public.wallet_get_my_account() TO anon;
GRANT ALL ON FUNCTION public.wallet_get_my_account() TO authenticated;
GRANT ALL ON FUNCTION public.wallet_get_my_account() TO service_role;


--
-- TOC entry 7408 (class 0 OID 0)
-- Dependencies: 845
-- Name: FUNCTION wallet_hold_upsert_for_ride(p_user_id uuid, p_ride_id uuid, p_amount_iqd bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.wallet_hold_upsert_for_ride(p_user_id uuid, p_ride_id uuid, p_amount_iqd bigint) TO anon;
GRANT ALL ON FUNCTION public.wallet_hold_upsert_for_ride(p_user_id uuid, p_ride_id uuid, p_amount_iqd bigint) TO service_role;


--
-- TOC entry 7409 (class 0 OID 0)
-- Dependencies: 821
-- Name: FUNCTION wallet_release_ride_hold(p_ride_id uuid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.wallet_release_ride_hold(p_ride_id uuid) TO anon;
GRANT ALL ON FUNCTION public.wallet_release_ride_hold(p_ride_id uuid) TO service_role;


--
-- TOC entry 7410 (class 0 OID 0)
-- Dependencies: 1215
-- Name: FUNCTION wallet_request_withdraw(p_amount_iqd bigint, p_payout_kind public.withdraw_payout_kind, p_destination jsonb, p_idempotency_key text); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.wallet_request_withdraw(p_amount_iqd bigint, p_payout_kind public.withdraw_payout_kind, p_destination jsonb, p_idempotency_key text) FROM PUBLIC;
GRANT ALL ON FUNCTION public.wallet_request_withdraw(p_amount_iqd bigint, p_payout_kind public.withdraw_payout_kind, p_destination jsonb, p_idempotency_key text) TO anon;
GRANT ALL ON FUNCTION public.wallet_request_withdraw(p_amount_iqd bigint, p_payout_kind public.withdraw_payout_kind, p_destination jsonb, p_idempotency_key text) TO authenticated;
GRANT ALL ON FUNCTION public.wallet_request_withdraw(p_amount_iqd bigint, p_payout_kind public.withdraw_payout_kind, p_destination jsonb, p_idempotency_key text) TO service_role;


--
-- TOC entry 7411 (class 0 OID 0)
-- Dependencies: 843
-- Name: FUNCTION wallet_validate_withdraw_destination(p_payout_kind public.withdraw_payout_kind, p_destination jsonb); Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON FUNCTION public.wallet_validate_withdraw_destination(p_payout_kind public.withdraw_payout_kind, p_destination jsonb) FROM PUBLIC;
GRANT ALL ON FUNCTION public.wallet_validate_withdraw_destination(p_payout_kind public.withdraw_payout_kind, p_destination jsonb) TO anon;
GRANT ALL ON FUNCTION public.wallet_validate_withdraw_destination(p_payout_kind public.withdraw_payout_kind, p_destination jsonb) TO authenticated;
GRANT ALL ON FUNCTION public.wallet_validate_withdraw_destination(p_payout_kind public.withdraw_payout_kind, p_destination jsonb) TO service_role;


--
-- TOC entry 7412 (class 0 OID 0)
-- Dependencies: 502
-- Name: FUNCTION apply_rls(wal jsonb, max_record_bytes integer); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO postgres;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO anon;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO authenticated;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO service_role;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO supabase_realtime_admin;


--
-- TOC entry 7413 (class 0 OID 0)
-- Dependencies: 1328
-- Name: FUNCTION broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) TO postgres;
GRANT ALL ON FUNCTION realtime.broadcast_changes(topic_name text, event_name text, operation text, table_name text, table_schema text, new record, old record, level text) TO dashboard_user;


--
-- TOC entry 7414 (class 0 OID 0)
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
-- TOC entry 7415 (class 0 OID 0)
-- Dependencies: 676
-- Name: FUNCTION "cast"(val text, type_ regtype); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO postgres;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO dashboard_user;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO anon;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO authenticated;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO service_role;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO supabase_realtime_admin;


--
-- TOC entry 7416 (class 0 OID 0)
-- Dependencies: 1330
-- Name: FUNCTION check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO postgres;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO anon;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO authenticated;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO service_role;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO supabase_realtime_admin;


--
-- TOC entry 7417 (class 0 OID 0)
-- Dependencies: 1315
-- Name: FUNCTION is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO postgres;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO anon;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO authenticated;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO service_role;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO supabase_realtime_admin;


--
-- TOC entry 7418 (class 0 OID 0)
-- Dependencies: 537
-- Name: FUNCTION list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO postgres;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO anon;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO authenticated;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO service_role;
GRANT ALL ON FUNCTION realtime.list_changes(publication name, slot_name name, max_changes integer, max_record_bytes integer) TO supabase_realtime_admin;


--
-- TOC entry 7419 (class 0 OID 0)
-- Dependencies: 1174
-- Name: FUNCTION quote_wal2json(entity regclass); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO postgres;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO anon;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO authenticated;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO service_role;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO supabase_realtime_admin;


--
-- TOC entry 7420 (class 0 OID 0)
-- Dependencies: 1255
-- Name: FUNCTION send(payload jsonb, event text, topic text, private boolean); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) TO postgres;
GRANT ALL ON FUNCTION realtime.send(payload jsonb, event text, topic text, private boolean) TO dashboard_user;


--
-- TOC entry 7421 (class 0 OID 0)
-- Dependencies: 811
-- Name: FUNCTION subscription_check_filters(); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO postgres;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO dashboard_user;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO anon;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO authenticated;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO service_role;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO supabase_realtime_admin;


--
-- TOC entry 7422 (class 0 OID 0)
-- Dependencies: 559
-- Name: FUNCTION to_regrole(role_name text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO postgres;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO dashboard_user;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO anon;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO authenticated;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO service_role;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO supabase_realtime_admin;


--
-- TOC entry 7423 (class 0 OID 0)
-- Dependencies: 804
-- Name: FUNCTION topic(); Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON FUNCTION realtime.topic() TO postgres;
GRANT ALL ON FUNCTION realtime.topic() TO dashboard_user;


--
-- TOC entry 7424 (class 0 OID 0)
-- Dependencies: 1146
-- Name: FUNCTION _crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea); Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT ALL ON FUNCTION vault._crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION vault._crypto_aead_det_decrypt(message bytea, additional bytea, key_id bigint, context bytea, nonce bytea) TO service_role;


--
-- TOC entry 7425 (class 0 OID 0)
-- Dependencies: 766
-- Name: FUNCTION create_secret(new_secret text, new_name text, new_description text, new_key_id uuid); Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT ALL ON FUNCTION vault.create_secret(new_secret text, new_name text, new_description text, new_key_id uuid) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION vault.create_secret(new_secret text, new_name text, new_description text, new_key_id uuid) TO service_role;


--
-- TOC entry 7426 (class 0 OID 0)
-- Dependencies: 483
-- Name: FUNCTION update_secret(secret_id uuid, new_secret text, new_name text, new_description text, new_key_id uuid); Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT ALL ON FUNCTION vault.update_secret(secret_id uuid, new_secret text, new_name text, new_description text, new_key_id uuid) TO postgres WITH GRANT OPTION;
GRANT ALL ON FUNCTION vault.update_secret(secret_id uuid, new_secret text, new_name text, new_description text, new_key_id uuid) TO service_role;


--
-- TOC entry 7427 (class 0 OID 0)
-- Dependencies: 2474
-- Name: FUNCTION st_3dextent(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_3dextent(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7428 (class 0 OID 0)
-- Dependencies: 2490
-- Name: FUNCTION st_asflatgeobuf(anyelement); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asflatgeobuf(anyelement) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7429 (class 0 OID 0)
-- Dependencies: 2491
-- Name: FUNCTION st_asflatgeobuf(anyelement, boolean); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asflatgeobuf(anyelement, boolean) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7430 (class 0 OID 0)
-- Dependencies: 2492
-- Name: FUNCTION st_asflatgeobuf(anyelement, boolean, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asflatgeobuf(anyelement, boolean, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7431 (class 0 OID 0)
-- Dependencies: 2488
-- Name: FUNCTION st_asgeobuf(anyelement); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asgeobuf(anyelement) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7432 (class 0 OID 0)
-- Dependencies: 2489
-- Name: FUNCTION st_asgeobuf(anyelement, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asgeobuf(anyelement, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7433 (class 0 OID 0)
-- Dependencies: 2483
-- Name: FUNCTION st_asmvt(anyelement); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asmvt(anyelement) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7434 (class 0 OID 0)
-- Dependencies: 2484
-- Name: FUNCTION st_asmvt(anyelement, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asmvt(anyelement, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7435 (class 0 OID 0)
-- Dependencies: 2485
-- Name: FUNCTION st_asmvt(anyelement, text, integer); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asmvt(anyelement, text, integer) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7436 (class 0 OID 0)
-- Dependencies: 2486
-- Name: FUNCTION st_asmvt(anyelement, text, integer, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asmvt(anyelement, text, integer, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7437 (class 0 OID 0)
-- Dependencies: 2487
-- Name: FUNCTION st_asmvt(anyelement, text, integer, text, text); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_asmvt(anyelement, text, integer, text, text) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7438 (class 0 OID 0)
-- Dependencies: 2479
-- Name: FUNCTION st_clusterintersecting(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_clusterintersecting(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7439 (class 0 OID 0)
-- Dependencies: 2480
-- Name: FUNCTION st_clusterwithin(extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_clusterwithin(extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7440 (class 0 OID 0)
-- Dependencies: 2478
-- Name: FUNCTION st_collect(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_collect(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7441 (class 0 OID 0)
-- Dependencies: 2473
-- Name: FUNCTION st_extent(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_extent(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7442 (class 0 OID 0)
-- Dependencies: 2482
-- Name: FUNCTION st_makeline(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_makeline(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7443 (class 0 OID 0)
-- Dependencies: 2475
-- Name: FUNCTION st_memcollect(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_memcollect(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7444 (class 0 OID 0)
-- Dependencies: 2472
-- Name: FUNCTION st_memunion(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_memunion(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7445 (class 0 OID 0)
-- Dependencies: 2481
-- Name: FUNCTION st_polygonize(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_polygonize(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7446 (class 0 OID 0)
-- Dependencies: 2476
-- Name: FUNCTION st_union(extensions.geometry); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_union(extensions.geometry) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7447 (class 0 OID 0)
-- Dependencies: 2477
-- Name: FUNCTION st_union(extensions.geometry, double precision); Type: ACL; Schema: extensions; Owner: supabase_admin
--

GRANT ALL ON FUNCTION extensions.st_union(extensions.geometry, double precision) TO postgres WITH GRANT OPTION;


--
-- TOC entry 7449 (class 0 OID 0)
-- Dependencies: 355
-- Name: TABLE audit_log_entries; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.audit_log_entries TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.audit_log_entries TO postgres;
GRANT SELECT ON TABLE auth.audit_log_entries TO postgres WITH GRANT OPTION;


--
-- TOC entry 7451 (class 0 OID 0)
-- Dependencies: 369
-- Name: TABLE flow_state; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.flow_state TO postgres;
GRANT SELECT ON TABLE auth.flow_state TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.flow_state TO dashboard_user;


--
-- TOC entry 7454 (class 0 OID 0)
-- Dependencies: 360
-- Name: TABLE identities; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.identities TO postgres;
GRANT SELECT ON TABLE auth.identities TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.identities TO dashboard_user;


--
-- TOC entry 7456 (class 0 OID 0)
-- Dependencies: 354
-- Name: TABLE instances; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.instances TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.instances TO postgres;
GRANT SELECT ON TABLE auth.instances TO postgres WITH GRANT OPTION;


--
-- TOC entry 7458 (class 0 OID 0)
-- Dependencies: 364
-- Name: TABLE mfa_amr_claims; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.mfa_amr_claims TO postgres;
GRANT SELECT ON TABLE auth.mfa_amr_claims TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_amr_claims TO dashboard_user;


--
-- TOC entry 7460 (class 0 OID 0)
-- Dependencies: 363
-- Name: TABLE mfa_challenges; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.mfa_challenges TO postgres;
GRANT SELECT ON TABLE auth.mfa_challenges TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_challenges TO dashboard_user;


--
-- TOC entry 7463 (class 0 OID 0)
-- Dependencies: 362
-- Name: TABLE mfa_factors; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.mfa_factors TO postgres;
GRANT SELECT ON TABLE auth.mfa_factors TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.mfa_factors TO dashboard_user;


--
-- TOC entry 7464 (class 0 OID 0)
-- Dependencies: 372
-- Name: TABLE oauth_authorizations; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.oauth_authorizations TO postgres;
GRANT ALL ON TABLE auth.oauth_authorizations TO dashboard_user;


--
-- TOC entry 7466 (class 0 OID 0)
-- Dependencies: 374
-- Name: TABLE oauth_client_states; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.oauth_client_states TO postgres;
GRANT ALL ON TABLE auth.oauth_client_states TO dashboard_user;


--
-- TOC entry 7467 (class 0 OID 0)
-- Dependencies: 371
-- Name: TABLE oauth_clients; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.oauth_clients TO postgres;
GRANT ALL ON TABLE auth.oauth_clients TO dashboard_user;


--
-- TOC entry 7468 (class 0 OID 0)
-- Dependencies: 373
-- Name: TABLE oauth_consents; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.oauth_consents TO postgres;
GRANT ALL ON TABLE auth.oauth_consents TO dashboard_user;


--
-- TOC entry 7469 (class 0 OID 0)
-- Dependencies: 370
-- Name: TABLE one_time_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.one_time_tokens TO postgres;
GRANT SELECT ON TABLE auth.one_time_tokens TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.one_time_tokens TO dashboard_user;


--
-- TOC entry 7471 (class 0 OID 0)
-- Dependencies: 353
-- Name: TABLE refresh_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.refresh_tokens TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.refresh_tokens TO postgres;
GRANT SELECT ON TABLE auth.refresh_tokens TO postgres WITH GRANT OPTION;


--
-- TOC entry 7473 (class 0 OID 0)
-- Dependencies: 352
-- Name: SEQUENCE refresh_tokens_id_seq; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO dashboard_user;
GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO postgres;


--
-- TOC entry 7475 (class 0 OID 0)
-- Dependencies: 367
-- Name: TABLE saml_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.saml_providers TO postgres;
GRANT SELECT ON TABLE auth.saml_providers TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.saml_providers TO dashboard_user;


--
-- TOC entry 7477 (class 0 OID 0)
-- Dependencies: 368
-- Name: TABLE saml_relay_states; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.saml_relay_states TO postgres;
GRANT SELECT ON TABLE auth.saml_relay_states TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.saml_relay_states TO dashboard_user;


--
-- TOC entry 7479 (class 0 OID 0)
-- Dependencies: 356
-- Name: TABLE schema_migrations; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT SELECT ON TABLE auth.schema_migrations TO postgres WITH GRANT OPTION;


--
-- TOC entry 7484 (class 0 OID 0)
-- Dependencies: 361
-- Name: TABLE sessions; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.sessions TO postgres;
GRANT SELECT ON TABLE auth.sessions TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sessions TO dashboard_user;


--
-- TOC entry 7486 (class 0 OID 0)
-- Dependencies: 366
-- Name: TABLE sso_domains; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.sso_domains TO postgres;
GRANT SELECT ON TABLE auth.sso_domains TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sso_domains TO dashboard_user;


--
-- TOC entry 7489 (class 0 OID 0)
-- Dependencies: 365
-- Name: TABLE sso_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.sso_providers TO postgres;
GRANT SELECT ON TABLE auth.sso_providers TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE auth.sso_providers TO dashboard_user;


--
-- TOC entry 7492 (class 0 OID 0)
-- Dependencies: 351
-- Name: TABLE users; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.users TO dashboard_user;
GRANT INSERT,REFERENCES,DELETE,TRIGGER,TRUNCATE,MAINTAIN,UPDATE ON TABLE auth.users TO postgres;
GRANT SELECT ON TABLE auth.users TO postgres WITH GRANT OPTION;


--
-- TOC entry 7493 (class 0 OID 0)
-- Dependencies: 397
-- Name: TABLE job; Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT SELECT ON TABLE cron.job TO postgres WITH GRANT OPTION;


--
-- TOC entry 7494 (class 0 OID 0)
-- Dependencies: 399
-- Name: TABLE job_run_details; Type: ACL; Schema: cron; Owner: supabase_admin
--

GRANT ALL ON TABLE cron.job_run_details TO postgres WITH GRANT OPTION;


--
-- TOC entry 7495 (class 0 OID 0)
-- Dependencies: 350
-- Name: TABLE pg_stat_statements; Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON TABLE extensions.pg_stat_statements FROM postgres;
GRANT ALL ON TABLE extensions.pg_stat_statements TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE extensions.pg_stat_statements TO dashboard_user;


--
-- TOC entry 7496 (class 0 OID 0)
-- Dependencies: 349
-- Name: TABLE pg_stat_statements_info; Type: ACL; Schema: extensions; Owner: postgres
--

REVOKE ALL ON TABLE extensions.pg_stat_statements_info FROM postgres;
GRANT ALL ON TABLE extensions.pg_stat_statements_info TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE extensions.pg_stat_statements_info TO dashboard_user;


--
-- TOC entry 7497 (class 0 OID 0)
-- Dependencies: 451
-- Name: TABLE achievement_progress; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.achievement_progress TO authenticated;
GRANT ALL ON TABLE public.achievement_progress TO service_role;


--
-- TOC entry 7498 (class 0 OID 0)
-- Dependencies: 450
-- Name: TABLE achievements; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.achievements TO service_role;


--
-- TOC entry 7499 (class 0 OID 0)
-- Dependencies: 415
-- Name: TABLE api_rate_limits; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.api_rate_limits TO service_role;


--
-- TOC entry 7500 (class 0 OID 0)
-- Dependencies: 416
-- Name: TABLE app_events; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.app_events TO service_role;


--
-- TOC entry 7501 (class 0 OID 0)
-- Dependencies: 444
-- Name: TABLE device_tokens; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.device_tokens TO authenticated;
GRANT ALL ON TABLE public.device_tokens TO service_role;


--
-- TOC entry 7503 (class 0 OID 0)
-- Dependencies: 443
-- Name: SEQUENCE device_tokens_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.device_tokens_id_seq TO anon;
GRANT ALL ON SEQUENCE public.device_tokens_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.device_tokens_id_seq TO service_role;


--
-- TOC entry 7504 (class 0 OID 0)
-- Dependencies: 447
-- Name: TABLE driver_counters; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.driver_counters TO authenticated;
GRANT ALL ON TABLE public.driver_counters TO service_role;


--
-- TOC entry 7505 (class 0 OID 0)
-- Dependencies: 475
-- Name: TABLE driver_leaderboard_daily; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.driver_leaderboard_daily TO authenticated;
GRANT ALL ON TABLE public.driver_leaderboard_daily TO service_role;


--
-- TOC entry 7506 (class 0 OID 0)
-- Dependencies: 417
-- Name: TABLE driver_locations; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.driver_locations TO authenticated;
GRANT ALL ON TABLE public.driver_locations TO service_role;


--
-- TOC entry 7507 (class 0 OID 0)
-- Dependencies: 449
-- Name: TABLE driver_rank_snapshots; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.driver_rank_snapshots TO authenticated;
GRANT ALL ON TABLE public.driver_rank_snapshots TO service_role;


--
-- TOC entry 7508 (class 0 OID 0)
-- Dependencies: 448
-- Name: TABLE driver_stats_daily; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.driver_stats_daily TO authenticated;
GRANT ALL ON TABLE public.driver_stats_daily TO service_role;


--
-- TOC entry 7509 (class 0 OID 0)
-- Dependencies: 418
-- Name: TABLE driver_vehicles; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.driver_vehicles TO authenticated;
GRANT ALL ON TABLE public.driver_vehicles TO service_role;


--
-- TOC entry 7510 (class 0 OID 0)
-- Dependencies: 419
-- Name: TABLE drivers; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.drivers TO authenticated;
GRANT ALL ON TABLE public.drivers TO service_role;


--
-- TOC entry 7511 (class 0 OID 0)
-- Dependencies: 466
-- Name: TABLE kyc_document_types; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.kyc_document_types TO service_role;


--
-- TOC entry 7512 (class 0 OID 0)
-- Dependencies: 464
-- Name: TABLE kyc_documents; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.kyc_documents TO authenticated;
GRANT ALL ON TABLE public.kyc_documents TO service_role;


--
-- TOC entry 7513 (class 0 OID 0)
-- Dependencies: 467
-- Name: TABLE kyc_liveness_sessions; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.kyc_liveness_sessions TO authenticated;
GRANT ALL ON TABLE public.kyc_liveness_sessions TO service_role;


--
-- TOC entry 7514 (class 0 OID 0)
-- Dependencies: 463
-- Name: TABLE kyc_submissions; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.kyc_submissions TO authenticated;
GRANT ALL ON TABLE public.kyc_submissions TO service_role;


--
-- TOC entry 7515 (class 0 OID 0)
-- Dependencies: 446
-- Name: TABLE notification_outbox; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.notification_outbox TO authenticated;
GRANT ALL ON TABLE public.notification_outbox TO service_role;


--
-- TOC entry 7517 (class 0 OID 0)
-- Dependencies: 445
-- Name: SEQUENCE notification_outbox_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.notification_outbox_id_seq TO anon;
GRANT ALL ON SEQUENCE public.notification_outbox_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.notification_outbox_id_seq TO service_role;


--
-- TOC entry 7518 (class 0 OID 0)
-- Dependencies: 420
-- Name: TABLE payment_intents; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.payment_intents TO service_role;
GRANT SELECT ON TABLE public.payment_intents TO authenticated;


--
-- TOC entry 7519 (class 0 OID 0)
-- Dependencies: 421
-- Name: TABLE payment_providers; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.payment_providers TO service_role;
GRANT SELECT ON TABLE public.payment_providers TO anon;
GRANT SELECT ON TABLE public.payment_providers TO authenticated;


--
-- TOC entry 7520 (class 0 OID 0)
-- Dependencies: 422
-- Name: TABLE payments; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.payments TO service_role;
GRANT SELECT ON TABLE public.payments TO authenticated;


--
-- TOC entry 7521 (class 0 OID 0)
-- Dependencies: 423
-- Name: TABLE pricing_configs; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.pricing_configs TO service_role;


--
-- TOC entry 7522 (class 0 OID 0)
-- Dependencies: 424
-- Name: TABLE profile_kyc; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.profile_kyc TO authenticated;
GRANT ALL ON TABLE public.profile_kyc TO service_role;


--
-- TOC entry 7523 (class 0 OID 0)
-- Dependencies: 425
-- Name: TABLE profiles; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.profiles TO authenticated;
GRANT ALL ON TABLE public.profiles TO service_role;


--
-- TOC entry 7524 (class 0 OID 0)
-- Dependencies: 426
-- Name: TABLE provider_events; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.provider_events TO service_role;
GRANT SELECT ON TABLE public.provider_events TO anon;
GRANT SELECT,INSERT ON TABLE public.provider_events TO authenticated;


--
-- TOC entry 7526 (class 0 OID 0)
-- Dependencies: 427
-- Name: SEQUENCE provider_events_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.provider_events_id_seq TO anon;
GRANT ALL ON SEQUENCE public.provider_events_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.provider_events_id_seq TO service_role;


--
-- TOC entry 7527 (class 0 OID 0)
-- Dependencies: 442
-- Name: TABLE public_profiles; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.public_profiles TO authenticated;
GRANT ALL ON TABLE public.public_profiles TO service_role;


--
-- TOC entry 7528 (class 0 OID 0)
-- Dependencies: 452
-- Name: TABLE referral_campaigns; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.referral_campaigns TO service_role;


--
-- TOC entry 7529 (class 0 OID 0)
-- Dependencies: 453
-- Name: TABLE referral_codes; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.referral_codes TO authenticated;
GRANT ALL ON TABLE public.referral_codes TO service_role;


--
-- TOC entry 7530 (class 0 OID 0)
-- Dependencies: 474
-- Name: TABLE referral_invites; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.referral_invites TO service_role;


--
-- TOC entry 7531 (class 0 OID 0)
-- Dependencies: 454
-- Name: TABLE referral_redemptions; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.referral_redemptions TO service_role;


--
-- TOC entry 7532 (class 0 OID 0)
-- Dependencies: 473
-- Name: TABLE referral_settings; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.referral_settings TO service_role;


--
-- TOC entry 7533 (class 0 OID 0)
-- Dependencies: 459
-- Name: TABLE ride_chat_messages; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.ride_chat_messages TO authenticated;
GRANT ALL ON TABLE public.ride_chat_messages TO service_role;


--
-- TOC entry 7534 (class 0 OID 0)
-- Dependencies: 460
-- Name: TABLE ride_chat_read_receipts; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.ride_chat_read_receipts TO authenticated;
GRANT ALL ON TABLE public.ride_chat_read_receipts TO service_role;


--
-- TOC entry 7535 (class 0 OID 0)
-- Dependencies: 472
-- Name: TABLE ride_chat_threads; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.ride_chat_threads TO authenticated;
GRANT ALL ON TABLE public.ride_chat_threads TO service_role;


--
-- TOC entry 7536 (class 0 OID 0)
-- Dependencies: 461
-- Name: TABLE ride_chat_typing; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.ride_chat_typing TO authenticated;
GRANT ALL ON TABLE public.ride_chat_typing TO service_role;


--
-- TOC entry 7537 (class 0 OID 0)
-- Dependencies: 471
-- Name: TABLE ride_completion_log; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.ride_completion_log TO service_role;


--
-- TOC entry 7538 (class 0 OID 0)
-- Dependencies: 428
-- Name: TABLE ride_events; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.ride_events TO service_role;


--
-- TOC entry 7540 (class 0 OID 0)
-- Dependencies: 429
-- Name: SEQUENCE ride_events_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.ride_events_id_seq TO anon;
GRANT ALL ON SEQUENCE public.ride_events_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.ride_events_id_seq TO service_role;


--
-- TOC entry 7541 (class 0 OID 0)
-- Dependencies: 430
-- Name: TABLE ride_incidents; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.ride_incidents TO service_role;
GRANT SELECT ON TABLE public.ride_incidents TO anon;
GRANT SELECT,INSERT,UPDATE ON TABLE public.ride_incidents TO authenticated;


--
-- TOC entry 7542 (class 0 OID 0)
-- Dependencies: 465
-- Name: TABLE ride_products; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.ride_products TO service_role;


--
-- TOC entry 7543 (class 0 OID 0)
-- Dependencies: 431
-- Name: TABLE ride_ratings; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.ride_ratings TO service_role;
GRANT SELECT ON TABLE public.ride_ratings TO authenticated;


--
-- TOC entry 7544 (class 0 OID 0)
-- Dependencies: 432
-- Name: TABLE ride_receipts; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.ride_receipts TO service_role;
GRANT SELECT ON TABLE public.ride_receipts TO anon;
GRANT SELECT ON TABLE public.ride_receipts TO authenticated;


--
-- TOC entry 7545 (class 0 OID 0)
-- Dependencies: 433
-- Name: TABLE ride_requests; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.ride_requests TO authenticated;
GRANT ALL ON TABLE public.ride_requests TO service_role;


--
-- TOC entry 7546 (class 0 OID 0)
-- Dependencies: 456
-- Name: TABLE support_categories; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.support_categories TO service_role;


--
-- TOC entry 7547 (class 0 OID 0)
-- Dependencies: 458
-- Name: TABLE support_messages; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.support_messages TO authenticated;
GRANT ALL ON TABLE public.support_messages TO service_role;


--
-- TOC entry 7548 (class 0 OID 0)
-- Dependencies: 457
-- Name: TABLE support_tickets; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.support_tickets TO authenticated;
GRANT ALL ON TABLE public.support_tickets TO service_role;


--
-- TOC entry 7549 (class 0 OID 0)
-- Dependencies: 468
-- Name: TABLE support_ticket_summaries; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.support_ticket_summaries TO anon;
GRANT ALL ON TABLE public.support_ticket_summaries TO authenticated;
GRANT ALL ON TABLE public.support_ticket_summaries TO service_role;


--
-- TOC entry 7550 (class 0 OID 0)
-- Dependencies: 434
-- Name: TABLE topup_packages; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.topup_packages TO service_role;
GRANT SELECT ON TABLE public.topup_packages TO anon;
GRANT SELECT ON TABLE public.topup_packages TO authenticated;


--
-- TOC entry 7551 (class 0 OID 0)
-- Dependencies: 462
-- Name: TABLE trip_share_tokens; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.trip_share_tokens TO authenticated;
GRANT ALL ON TABLE public.trip_share_tokens TO service_role;


--
-- TOC entry 7552 (class 0 OID 0)
-- Dependencies: 455
-- Name: TABLE trusted_contacts; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.trusted_contacts TO authenticated;
GRANT ALL ON TABLE public.trusted_contacts TO service_role;


--
-- TOC entry 7553 (class 0 OID 0)
-- Dependencies: 470
-- Name: TABLE user_device_tokens; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.user_device_tokens TO authenticated;
GRANT ALL ON TABLE public.user_device_tokens TO service_role;


--
-- TOC entry 7554 (class 0 OID 0)
-- Dependencies: 435
-- Name: TABLE user_notifications; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.user_notifications TO authenticated;
GRANT ALL ON TABLE public.user_notifications TO service_role;


--
-- TOC entry 7555 (class 0 OID 0)
-- Dependencies: 436
-- Name: TABLE wallet_entries; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.wallet_entries TO authenticated;
GRANT ALL ON TABLE public.wallet_entries TO service_role;


--
-- TOC entry 7557 (class 0 OID 0)
-- Dependencies: 437
-- Name: SEQUENCE wallet_entries_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.wallet_entries_id_seq TO anon;
GRANT ALL ON SEQUENCE public.wallet_entries_id_seq TO authenticated;
GRANT ALL ON SEQUENCE public.wallet_entries_id_seq TO service_role;


--
-- TOC entry 7558 (class 0 OID 0)
-- Dependencies: 438
-- Name: TABLE wallet_holds; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.wallet_holds TO authenticated;
GRANT ALL ON TABLE public.wallet_holds TO service_role;


--
-- TOC entry 7559 (class 0 OID 0)
-- Dependencies: 439
-- Name: TABLE wallet_withdraw_payout_methods; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.wallet_withdraw_payout_methods TO authenticated;
GRANT ALL ON TABLE public.wallet_withdraw_payout_methods TO service_role;


--
-- TOC entry 7560 (class 0 OID 0)
-- Dependencies: 440
-- Name: TABLE wallet_withdraw_requests; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.wallet_withdraw_requests TO authenticated;
GRANT ALL ON TABLE public.wallet_withdraw_requests TO service_role;


--
-- TOC entry 7561 (class 0 OID 0)
-- Dependencies: 441
-- Name: TABLE wallet_withdrawal_policy; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE public.wallet_withdrawal_policy TO authenticated;
GRANT ALL ON TABLE public.wallet_withdrawal_policy TO service_role;
GRANT SELECT ON TABLE public.wallet_withdrawal_policy TO anon;


--
-- TOC entry 7562 (class 0 OID 0)
-- Dependencies: 381
-- Name: TABLE messages; Type: ACL; Schema: realtime; Owner: supabase_realtime_admin
--

GRANT ALL ON TABLE realtime.messages TO postgres;
GRANT ALL ON TABLE realtime.messages TO dashboard_user;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO anon;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO authenticated;
GRANT SELECT,INSERT,UPDATE ON TABLE realtime.messages TO service_role;


--
-- TOC entry 7563 (class 0 OID 0)
-- Dependencies: 405
-- Name: TABLE messages_2026_01_21; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.messages_2026_01_21 TO postgres;
GRANT ALL ON TABLE realtime.messages_2026_01_21 TO dashboard_user;


--
-- TOC entry 7564 (class 0 OID 0)
-- Dependencies: 406
-- Name: TABLE messages_2026_01_22; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.messages_2026_01_22 TO postgres;
GRANT ALL ON TABLE realtime.messages_2026_01_22 TO dashboard_user;


--
-- TOC entry 7565 (class 0 OID 0)
-- Dependencies: 407
-- Name: TABLE messages_2026_01_23; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.messages_2026_01_23 TO postgres;
GRANT ALL ON TABLE realtime.messages_2026_01_23 TO dashboard_user;


--
-- TOC entry 7566 (class 0 OID 0)
-- Dependencies: 408
-- Name: TABLE messages_2026_01_24; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.messages_2026_01_24 TO postgres;
GRANT ALL ON TABLE realtime.messages_2026_01_24 TO dashboard_user;


--
-- TOC entry 7567 (class 0 OID 0)
-- Dependencies: 409
-- Name: TABLE messages_2026_01_25; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.messages_2026_01_25 TO postgres;
GRANT ALL ON TABLE realtime.messages_2026_01_25 TO dashboard_user;


--
-- TOC entry 7568 (class 0 OID 0)
-- Dependencies: 410
-- Name: TABLE messages_2026_01_26; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.messages_2026_01_26 TO postgres;
GRANT ALL ON TABLE realtime.messages_2026_01_26 TO dashboard_user;


--
-- TOC entry 7569 (class 0 OID 0)
-- Dependencies: 469
-- Name: TABLE messages_2026_01_27; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.messages_2026_01_27 TO postgres;
GRANT ALL ON TABLE realtime.messages_2026_01_27 TO dashboard_user;


--
-- TOC entry 7570 (class 0 OID 0)
-- Dependencies: 375
-- Name: TABLE schema_migrations; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.schema_migrations TO postgres;
GRANT ALL ON TABLE realtime.schema_migrations TO dashboard_user;
GRANT SELECT ON TABLE realtime.schema_migrations TO anon;
GRANT SELECT ON TABLE realtime.schema_migrations TO authenticated;
GRANT SELECT ON TABLE realtime.schema_migrations TO service_role;
GRANT ALL ON TABLE realtime.schema_migrations TO supabase_realtime_admin;


--
-- TOC entry 7571 (class 0 OID 0)
-- Dependencies: 378
-- Name: TABLE subscription; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.subscription TO postgres;
GRANT ALL ON TABLE realtime.subscription TO dashboard_user;
GRANT SELECT ON TABLE realtime.subscription TO anon;
GRANT SELECT ON TABLE realtime.subscription TO authenticated;
GRANT SELECT ON TABLE realtime.subscription TO service_role;
GRANT ALL ON TABLE realtime.subscription TO supabase_realtime_admin;


--
-- TOC entry 7572 (class 0 OID 0)
-- Dependencies: 377
-- Name: SEQUENCE subscription_id_seq; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO postgres;
GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO dashboard_user;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO anon;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO authenticated;
GRANT USAGE ON SEQUENCE realtime.subscription_id_seq TO service_role;
GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO supabase_realtime_admin;


--
-- TOC entry 7574 (class 0 OID 0)
-- Dependencies: 383
-- Name: TABLE buckets; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

REVOKE ALL ON TABLE storage.buckets FROM supabase_storage_admin;
GRANT ALL ON TABLE storage.buckets TO supabase_storage_admin WITH GRANT OPTION;
GRANT ALL ON TABLE storage.buckets TO service_role;
GRANT ALL ON TABLE storage.buckets TO authenticated;
GRANT ALL ON TABLE storage.buckets TO anon;
GRANT ALL ON TABLE storage.buckets TO postgres WITH GRANT OPTION;


--
-- TOC entry 7575 (class 0 OID 0)
-- Dependencies: 388
-- Name: TABLE buckets_analytics; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.buckets_analytics TO service_role;
GRANT ALL ON TABLE storage.buckets_analytics TO authenticated;
GRANT ALL ON TABLE storage.buckets_analytics TO anon;


--
-- TOC entry 7576 (class 0 OID 0)
-- Dependencies: 389
-- Name: TABLE buckets_vectors; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT SELECT ON TABLE storage.buckets_vectors TO service_role;
GRANT SELECT ON TABLE storage.buckets_vectors TO authenticated;
GRANT SELECT ON TABLE storage.buckets_vectors TO anon;


--
-- TOC entry 7578 (class 0 OID 0)
-- Dependencies: 384
-- Name: TABLE objects; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

REVOKE ALL ON TABLE storage.objects FROM supabase_storage_admin;
GRANT ALL ON TABLE storage.objects TO supabase_storage_admin WITH GRANT OPTION;
GRANT ALL ON TABLE storage.objects TO service_role;
GRANT ALL ON TABLE storage.objects TO authenticated;
GRANT ALL ON TABLE storage.objects TO anon;
GRANT ALL ON TABLE storage.objects TO postgres WITH GRANT OPTION;


--
-- TOC entry 7579 (class 0 OID 0)
-- Dependencies: 387
-- Name: TABLE prefixes; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.prefixes TO service_role;
GRANT ALL ON TABLE storage.prefixes TO authenticated;
GRANT ALL ON TABLE storage.prefixes TO anon;


--
-- TOC entry 7580 (class 0 OID 0)
-- Dependencies: 385
-- Name: TABLE s3_multipart_uploads; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.s3_multipart_uploads TO service_role;
GRANT SELECT ON TABLE storage.s3_multipart_uploads TO authenticated;
GRANT SELECT ON TABLE storage.s3_multipart_uploads TO anon;


--
-- TOC entry 7581 (class 0 OID 0)
-- Dependencies: 386
-- Name: TABLE s3_multipart_uploads_parts; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.s3_multipart_uploads_parts TO service_role;
GRANT SELECT ON TABLE storage.s3_multipart_uploads_parts TO authenticated;
GRANT SELECT ON TABLE storage.s3_multipart_uploads_parts TO anon;


--
-- TOC entry 7582 (class 0 OID 0)
-- Dependencies: 390
-- Name: TABLE vector_indexes; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT SELECT ON TABLE storage.vector_indexes TO service_role;
GRANT SELECT ON TABLE storage.vector_indexes TO authenticated;
GRANT SELECT ON TABLE storage.vector_indexes TO anon;


--
-- TOC entry 7583 (class 0 OID 0)
-- Dependencies: 357
-- Name: TABLE secrets; Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT SELECT,REFERENCES,DELETE,TRUNCATE ON TABLE vault.secrets TO postgres WITH GRANT OPTION;
GRANT SELECT,DELETE ON TABLE vault.secrets TO service_role;


--
-- TOC entry 7584 (class 0 OID 0)
-- Dependencies: 358
-- Name: TABLE decrypted_secrets; Type: ACL; Schema: vault; Owner: supabase_admin
--

GRANT SELECT,REFERENCES,DELETE,TRUNCATE ON TABLE vault.decrypted_secrets TO postgres WITH GRANT OPTION;
GRANT SELECT,DELETE ON TABLE vault.decrypted_secrets TO service_role;


--
-- TOC entry 3769 (class 826 OID 16553)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES TO dashboard_user;


--
-- TOC entry 3770 (class 826 OID 16554)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS TO dashboard_user;


--
-- TOC entry 3768 (class 826 OID 16552)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON TABLES TO dashboard_user;


--
-- TOC entry 3785 (class 826 OID 23809)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: cron; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA cron GRANT ALL ON SEQUENCES TO postgres WITH GRANT OPTION;


--
-- TOC entry 3787 (class 826 OID 23808)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: cron; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA cron GRANT ALL ON FUNCTIONS TO postgres WITH GRANT OPTION;


--
-- TOC entry 3786 (class 826 OID 23807)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: cron; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA cron GRANT ALL ON TABLES TO postgres WITH GRANT OPTION;


--
-- TOC entry 3780 (class 826 OID 16632)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON SEQUENCES TO postgres WITH GRANT OPTION;


--
-- TOC entry 3779 (class 826 OID 16631)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON FUNCTIONS TO postgres WITH GRANT OPTION;


--
-- TOC entry 3778 (class 826 OID 16630)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: extensions; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA extensions GRANT ALL ON TABLES TO postgres WITH GRANT OPTION;


--
-- TOC entry 3783 (class 826 OID 16587)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES TO service_role;


--
-- TOC entry 3782 (class 826 OID 16586)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS TO service_role;


--
-- TOC entry 3781 (class 826 OID 16585)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES TO service_role;


--
-- TOC entry 3774 (class 826 OID 16567)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES TO service_role;


--
-- TOC entry 3776 (class 826 OID 16566)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS TO service_role;


--
-- TOC entry 3775 (class 826 OID 16565)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES TO service_role;


--
-- TOC entry 3788 (class 826 OID 40558)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES TO service_role;


--
-- TOC entry 3777 (class 826 OID 40559)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS TO service_role;


--
-- TOC entry 3784 (class 826 OID 40560)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES TO service_role;


--
-- TOC entry 3772 (class 826 OID 16557)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON SEQUENCES TO dashboard_user;


--
-- TOC entry 3773 (class 826 OID 16558)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON FUNCTIONS TO dashboard_user;


--
-- TOC entry 3771 (class 826 OID 16556)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON TABLES TO dashboard_user;


--
-- TOC entry 3767 (class 826 OID 16546)
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES TO service_role;


--
-- TOC entry 3766 (class 826 OID 16545)
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS TO service_role;


--
-- TOC entry 3765 (class 826 OID 16544)
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES TO service_role;


--
-- TOC entry 4982 (class 3466 OID 16571)
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_graphql_placeholder ON sql_drop
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION extensions.set_graphql_placeholder();


ALTER EVENT TRIGGER issue_graphql_placeholder OWNER TO supabase_admin;

--
-- TOC entry 4987 (class 3466 OID 16650)
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_cron_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_cron_access();


ALTER EVENT TRIGGER issue_pg_cron_access OWNER TO supabase_admin;

--
-- TOC entry 4981 (class 3466 OID 16569)
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_graphql_access ON ddl_command_end
         WHEN TAG IN ('CREATE FUNCTION')
   EXECUTE FUNCTION extensions.grant_pg_graphql_access();


ALTER EVENT TRIGGER issue_pg_graphql_access OWNER TO supabase_admin;

--
-- TOC entry 4988 (class 3466 OID 16653)
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_net_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_net_access();


ALTER EVENT TRIGGER issue_pg_net_access OWNER TO supabase_admin;

--
-- TOC entry 4983 (class 3466 OID 16572)
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER pgrst_ddl_watch ON ddl_command_end
   EXECUTE FUNCTION extensions.pgrst_ddl_watch();


ALTER EVENT TRIGGER pgrst_ddl_watch OWNER TO supabase_admin;

--
-- TOC entry 4984 (class 3466 OID 16573)
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER pgrst_drop_watch ON sql_drop
   EXECUTE FUNCTION extensions.pgrst_drop_watch();


ALTER EVENT TRIGGER pgrst_drop_watch OWNER TO supabase_admin;

-- Completed on 2026-01-24 18:42:11

--
-- PostgreSQL database dump complete
--

\unrestrict cA5EKjNgR9CFftfdRb3SWJcX1HtzVTQaVfmsLGacWEQai4cCEWskv46EIPDUwEI

