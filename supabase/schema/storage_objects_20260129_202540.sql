--
-- PostgreSQL database dump
--

\restrict B4bh3XTfpph3aq9gdlgPfoUle8GvqJhPHL7XUeEoJdNyeeSZrgbMo7Y42xoBzs6

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.7

-- Started on 2026-01-29 20:34:50

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
-- TOC entry 5303 (class 0 OID 17274)
-- Dependencies: 389
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version, owner_id, user_metadata, level) FROM stdin;
\.


-- Completed on 2026-01-29 20:35:21

--
-- PostgreSQL database dump complete
--

\unrestrict B4bh3XTfpph3aq9gdlgPfoUle8GvqJhPHL7XUeEoJdNyeeSZrgbMo7Y42xoBzs6

