--
-- PostgreSQL database dump
--

\restrict gHNtbuLoiqgvm2dt4W1OnFwOunQyP9YO45rsJQp4mVGo9pD5048pTHyxdQunvkW

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.7

-- Started on 2026-02-01 12:55:25

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
-- TOC entry 5439 (class 0 OID 17274)
-- Dependencies: 392
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version, owner_id, user_metadata, level) FROM stdin;
\.


-- Completed on 2026-02-01 12:55:57

--
-- PostgreSQL database dump complete
--

\unrestrict gHNtbuLoiqgvm2dt4W1OnFwOunQyP9YO45rsJQp4mVGo9pD5048pTHyxdQunvkW

