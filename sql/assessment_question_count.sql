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
-- Name: assessment_question_count; Type: VIEW; Schema: public; Owner: hom
--

CREATE VIEW assessment_question_count AS
    SELECT assessment_questions.event, count(*) AS qcount FROM assessment_questions GROUP BY assessment_questions.event;


ALTER TABLE public.assessment_question_count OWNER TO hom;

--
-- PostgreSQL database dump complete
--

