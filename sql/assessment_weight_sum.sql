--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- Name: assessment_weight_sum; Type: VIEW; Schema: public; Owner: hom
--

CREATE VIEW assessment_weight_sum AS
 SELECT assessment_questions.event,
    sum(assessment_questions.max_points) AS weight_sum
   FROM assessment_questions
  GROUP BY assessment_questions.event;


ALTER TABLE public.assessment_weight_sum OWNER TO hom;

--
-- Name: assessment_weight_sum; Type: ACL; Schema: public; Owner: hom
--

REVOKE ALL ON TABLE assessment_weight_sum FROM PUBLIC;
REVOKE ALL ON TABLE assessment_weight_sum FROM hom;
GRANT ALL ON TABLE assessment_weight_sum TO hom;
GRANT SELECT,REFERENCES ON TABLE assessment_weight_sum TO wwwrun;


--
-- PostgreSQL database dump complete
--

