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
-- Name: stick_grade_sum; Type: VIEW; Schema: public; Owner: hom
--

CREATE VIEW stick_grade_sum AS
 SELECT sum((assessment_scores.score * (assessment_questions.max_points)::numeric)) AS summed_score,
    assessment_scores.stick_event_repo_id
   FROM (assessment_scores
     JOIN assessment_questions USING (event, question))
  GROUP BY assessment_scores.stick_event_repo_id;


ALTER TABLE public.stick_grade_sum OWNER TO hom;

--
-- Name: stick_grade_sum; Type: ACL; Schema: public; Owner: hom
--

REVOKE ALL ON TABLE stick_grade_sum FROM PUBLIC;
REVOKE ALL ON TABLE stick_grade_sum FROM hom;
GRANT ALL ON TABLE stick_grade_sum TO hom;
GRANT SELECT,REFERENCES ON TABLE stick_grade_sum TO wwwrun;


--
-- PostgreSQL database dump complete
--

