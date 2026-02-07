--
-- PostgreSQL database dump
--

\restrict SomBd44KxpgvwYf3iiT0xpoJuZlJ0yPIYxpq5AXqSerJfa9R7P9SDQvKENULsrf

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.7

-- Started on 2026-02-07 09:09:04

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
-- TOC entry 5771 (class 0 OID 17274)
-- Dependencies: 393
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version, owner_id, user_metadata, level) FROM stdin;
\.


-- Completed on 2026-02-07 09:09:35

--
-- PostgreSQL database dump complete
--

\unrestrict SomBd44KxpgvwYf3iiT0xpoJuZlJ0yPIYxpq5AXqSerJfa9R7P9SDQvKENULsrf

