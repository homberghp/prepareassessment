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
-- Name: correction_completion; Type: VIEW; Schema: public; Owner: hom
--

CREATE VIEW correction_completion AS
    SELECT assessment_scores.event, assessment_scores.student AS username, count(*) AS complete FROM assessment_scores WHERE (assessment_scores.score IS NOT NULL) GROUP BY assessment_scores.event, assessment_scores.student;


ALTER TABLE public.correction_completion OWNER TO hom;

--
-- PostgreSQL database dump complete
--

