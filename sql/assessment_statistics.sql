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
-- Name: assessment_statistics; Type: VIEW; Schema: public; Owner: hvd
--

CREATE VIEW assessment_statistics AS
    SELECT assessment_results.event, count(*) AS no_candidates, count(assessment_results.actual_score) AS no_participants, round(avg(assessment_results.grade), 1) AS average_grade, (SELECT count(*) AS count FROM assessment_results WHERE ((assessment_results.grade >= 0.0) AND (assessment_results.grade <= 0.9))) AS "0=<1", (SELECT count(*) AS count FROM assessment_results WHERE ((assessment_results.grade >= 1.0) AND (assessment_results.grade <= 1.9))) AS "1=<2", (SELECT count(*) AS count FROM assessment_results WHERE ((assessment_results.grade >= 2.0) AND (assessment_results.grade <= 2.9))) AS "2=<3", (SELECT count(*) AS count FROM assessment_results WHERE ((assessment_results.grade >= 3.0) AND (assessment_results.grade <= 3.9))) AS "3=<4", (SELECT count(*) AS count FROM assessment_results WHERE ((assessment_results.grade >= 4.0) AND (assessment_results.grade <= 4.9))) AS "4=<5", (SELECT count(*) AS count FROM assessment_results WHERE ((assessment_results.grade >= 5.0) AND (assessment_results.grade <= 5.9))) AS "5=<6", (SELECT count(*) AS count FROM assessment_results WHERE ((assessment_results.grade >= 6.0) AND (assessment_results.grade <= 6.9))) AS "6=<7", (SELECT count(*) AS count FROM assessment_results WHERE ((assessment_results.grade >= 7.0) AND (assessment_results.grade <= 7.9))) AS "7=<8", (SELECT count(*) AS count FROM assessment_results WHERE ((assessment_results.grade >= 8.0) AND (assessment_results.grade <= 8.9))) AS "8=<9", (SELECT count(*) AS count FROM assessment_results WHERE ((assessment_results.grade >= 9.0) AND (assessment_results.grade <= (10)::numeric))) AS "9=<=10" FROM assessment_results GROUP BY assessment_results.event;


ALTER TABLE public.assessment_statistics OWNER TO hvd;

--
-- PostgreSQL database dump complete
--

