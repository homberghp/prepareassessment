--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- Name: questions_per_cand; Type: VIEW; Schema: public; Owner: hom
--

CREATE VIEW questions_per_cand AS
    SELECT cr.event, cr.username, assessment_question_count.qcount FROM (candidate_repos cr JOIN assessment_question_count USING (event));


ALTER TABLE public.questions_per_cand OWNER TO hom;

--
-- PostgreSQL database dump complete
--

