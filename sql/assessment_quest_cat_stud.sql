--
-- PostgreSQL database dump
--
begin work;
SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- Name: quest_cat_stud; Type: VIEW; Schema: public; Owner: hom
--
drop view quest_cat_stud;
CREATE VIEW quest_cat_stud AS
    SELECT assc.event, 
    	    assc.question || ':'|| candidate_repos.lastname  || ':' || candidate_repos.firstname || ':' || assc.student AS qs 
    FROM (assessment_scores assc JOIN candidate_repos USING (snummer, event)) where candidate_repos.youngest>1;


ALTER TABLE public.quest_cat_stud OWNER TO hom;

--
-- Name: quest_cat_stud; Type: ACL; Schema: public; Owner: hom
--

REVOKE ALL ON TABLE quest_cat_stud FROM PUBLIC;
REVOKE ALL ON TABLE quest_cat_stud FROM hom;
GRANT ALL ON TABLE quest_cat_stud TO hom;
GRANT ALL ON TABLE quest_cat_stud TO PUBLIC;


--
-- PostgreSQL database dump complete
--

commit;