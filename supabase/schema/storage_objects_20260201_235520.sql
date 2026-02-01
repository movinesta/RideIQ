--
-- PostgreSQL database dump
--

\restrict U3jN6vLeIIaBnFKj2t9zOBVz7gNWz3Ecqljaios3oOvXE9htqgZqW9FUDC1k9Wf

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.7

-- Started on 2026-02-02 00:04:45

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
-- TOC entry 5441 (class 0 OID 17274)
-- Dependencies: 392
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata, version, owner_id, user_metadata, level) FROM stdin;
\.


-- Completed on 2026-02-02 00:05:18

--
-- PostgreSQL database dump complete
--

\unrestrict U3jN6vLeIIaBnFKj2t9zOBVz7gNWz3Ecqljaios3oOvXE9htqgZqW9FUDC1k9Wf

