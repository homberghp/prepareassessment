--
-- PostgreSQL database dump
--
begin work;
SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;
drop view if exists assessment_final_score3;
--
-- Name: assessment_final_score3; Type: VIEW; Schema: public; Owner: hom
--

CREATE VIEW assessment_final_score3 AS
 SELECT q.event,
    s.stick_event_repo_id,
    category,
    sum((s.score * (q.max_points)::numeric)) AS weighted_sum
   FROM (assessment_questions q
     JOIN assessment_scores s USING (event, question))
  GROUP BY q.event, s.stick_event_repo_id,category;


ALTER TABLE public.assessment_final_score3 OWNER TO hom;

--
-- Name: assessment_final_score3; Type: ACL; Schema: public; Owner: hom
--

REVOKE ALL ON TABLE assessment_final_score3 FROM PUBLIC;
REVOKE ALL ON TABLE assessment_final_score3 FROM hom;
GRANT ALL ON TABLE assessment_final_score3 TO hom;
GRANT ALL ON TABLE assessment_final_score3 TO wwwrun;


--
-- PostgreSQL database dump complete
--

commit;