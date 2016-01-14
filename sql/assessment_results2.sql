--
-- PostgreSQL database dump
--
begin work;


drop view if exists assessment_statistics2;
drop view if exists assessment_results2;
SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- Name: assessment_results; Type: VIEW; Schema: public; Owner: hvd
--

CREATE VIEW assessment_results2 AS
    SELECT s.snummer AS studentno,
	 cr.username,
	  s.roepnaam as firstname,
	 s.voorvoegsel as tussenvoegsel,
	 s.achternaam as .lastname,
	 s.email1 as email,
	 sclass AS class,
	 afko AS module,
	e.event,
	 (SELECT sum(assessment_questions.max_points) AS sum FROM assessment_questions WHERE (assessment_questions.event = e.event)) AS max_score,
	 (SELECT assessment_events.compensation_points FROM assessment_events WHERE (assessment_events.event = e.event)) AS compensation_points,
	 (SELECT sum(assessment_scores.score) AS sum FROM assessment_scores WHERE ((assessment_scores.event = e.event) AND ((assessment_scores.student)::text = (cr.username)::text))) AS actual_score,
	 round((((SELECT sum(assessment_scores.score) AS sum FROM assessment_scores WHERE ((assessment_scores.event = e.event) AND ((assessment_scores.student)::text = (cr.username)::text))) * (9.0 / (((SELECT sum(assessment_questions.max_points) AS sum FROM assessment_questions WHERE (assessment_questions.event = e.event)) - (SELECT assessment_events.compensation_points FROM assessment_events WHERE (assessment_events.event = e.event))))::numeric)) + 1.0),
	 1) AS grade FROM candidate_repos cr,
	 assessment_events e 
	 WHERE (cr.event = e.event) 
	 GROUP BY snummer, cr.username,
	 substr((cr.username)::text,
	 2,
	 7),
	 cr.firstname,
	 cr.tussenvoegsel,
	 cr.lastname,
	 cr.email,
	 cr.sclass,
	 cr.afko ORDER BY e.event,
	 s.achternaam;


ALTER TABLE public.assessment_results2 OWNER TO hvd;

--
-- Name: assessment_results; Type: ACL; Schema: public; Owner: hvd
--

REVOKE ALL ON TABLE assessment_results2 FROM PUBLIC;
REVOKE ALL ON TABLE assessment_results2 FROM hvd;
GRANT ALL ON TABLE assessment_results2 TO hvd;
GRANT SELECT ON TABLE assessment_results2 TO wwwrun;

--
-- Name: assessment_statistics; Type: VIEW; Schema: public; Owner: hvd
--

CREATE VIEW assessment_statistics2 AS
    SELECT assessment_results.event,
	 count(*) AS no_candidates,
	 count(assessment_results.actual_score) AS no_participants,
	 round(avg(assessment_results.grade),
	 1) AS average_grade,
	 (SELECT count(*) AS count FROM assessment_results WHERE ((assessment_results.grade >= 0.0) AND (assessment_results.grade <= 0.9))) AS "0=<1",
	 (SELECT count(*) AS count FROM assessment_results WHERE ((assessment_results.grade >= 1.0) AND (assessment_results.grade <= 1.9))) AS "1=<2",
	 (SELECT count(*) AS count FROM assessment_results WHERE ((assessment_results.grade >= 2.0) AND (assessment_results.grade <= 2.9))) AS "2=<3",
	 (SELECT count(*) AS count FROM assessment_results WHERE ((assessment_results.grade >= 3.0) AND (assessment_results.grade <= 3.9))) AS "3=<4",
	 (SELECT count(*) AS count FROM assessment_results WHERE ((assessment_results.grade >= 4.0) AND (assessment_results.grade <= 4.9))) AS "4=<5",
	 (SELECT count(*) AS count FROM assessment_results WHERE ((assessment_results.grade >= 5.0) AND (assessment_results.grade <= 5.9))) AS "5=<6",
	 (SELECT count(*) AS count FROM assessment_results WHERE ((assessment_results.grade >= 6.0) AND (assessment_results.grade <= 6.9))) AS "6=<7",
	 (SELECT count(*) AS count FROM assessment_results WHERE ((assessment_results.grade >= 7.0) AND (assessment_results.grade <= 7.9))) AS "7=<8",
	 (SELECT count(*) AS count FROM assessment_results WHERE ((assessment_results.grade >= 8.0) AND (assessment_results.grade <= 8.9))) AS "8=<9",
	 (SELECT count(*) AS count FROM assessment_results WHERE ((assessment_results.grade >= 9.0) AND (assessment_results.grade <= (10)::numeric))) AS "9=<=10" FROM assessment_results GROUP BY assessment_results.event;


ALTER TABLE public.assessment_statistics OWNER TO hvd;

--
-- PostgreSQL database dump complete
--


--
-- PostgreSQL database dump complete
--

commit;-- abort;