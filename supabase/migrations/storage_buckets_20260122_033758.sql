--
-- PostgreSQL database dump
--

\restrict sN3n2JF5xfxuB4rUs3rEt1OgAaOjkz2bM2a6eaBdZwS1Febgsqzldcwsel1kT10

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.7

-- Started on 2026-01-22 03:45:23

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
-- TOC entry 4881 (class 0 OID 17264)
-- Dependencies: 377
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.buckets (id, name, owner, created_at, updated_at, public, avif_autodetection, file_size_limit, allowed_mime_types, owner_id, type) FROM stdin;
\.


-- Completed on 2026-01-22 03:45:55

--
-- PostgreSQL database dump complete
--

\unrestrict sN3n2JF5xfxuB4rUs3rEt1OgAaOjkz2bM2a6eaBdZwS1Febgsqzldcwsel1kT10

