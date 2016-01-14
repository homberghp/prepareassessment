--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: tablefunc; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS tablefunc WITH SCHEMA public;


--
-- Name: EXTENSION tablefunc; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION tablefunc IS 'functions that manipulate whole tables, including crosstab';


SET search_path = public, pg_catalog;

--
-- Name: armor(bytea); Type: FUNCTION; Schema: public; Owner: hom
--

CREATE FUNCTION armor(bytea) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_armor';


ALTER FUNCTION public.armor(bytea) OWNER TO hom;

--
-- Name: assessment_score_query(text); Type: FUNCTION; Schema: public; Owner: hom
--

CREATE FUNCTION assessment_score_query(myevent text) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare
  th text;
begin
  select array_agg('q'||question||' numeric') into strict th from (select question from assessment_questions where event=myevent order by question) qq;
  th := 'select * from crosstab(
  ''select snummer,lastname,firstname,tussenvoegsel,email,question,score from candidate_repos car join assessment_scores assc using(snummer,event) where event='''''||myevent||''''' and youngest > 1 order by snummer,question'',
  ''select question from assessment_questions where event='''''||myevent||''''' order by question''
  ) as ct(snummer integer,lastname text,firstname text,tussenvoegsel text,email text,'||regexp_replace(th,'[}"{]','','g')||') order by lastname,firstname';
  return th;
end; $$;


ALTER FUNCTION public.assessment_score_query(myevent text) OWNER TO hom;

--
-- Name: crypt(text, text); Type: FUNCTION; Schema: public; Owner: hom
--

CREATE FUNCTION crypt(text, text) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_crypt';


ALTER FUNCTION public.crypt(text, text) OWNER TO hom;

--
-- Name: dearmor(text); Type: FUNCTION; Schema: public; Owner: hom
--

CREATE FUNCTION dearmor(text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_dearmor';


ALTER FUNCTION public.dearmor(text) OWNER TO hom;

--
-- Name: decrypt(bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: hom
--

CREATE FUNCTION decrypt(bytea, bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_decrypt';


ALTER FUNCTION public.decrypt(bytea, bytea, text) OWNER TO hom;

--
-- Name: decrypt_iv(bytea, bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: hom
--

CREATE FUNCTION decrypt_iv(bytea, bytea, bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_decrypt_iv';


ALTER FUNCTION public.decrypt_iv(bytea, bytea, bytea, text) OWNER TO hom;

--
-- Name: digest(text, text); Type: FUNCTION; Schema: public; Owner: hom
--

CREATE FUNCTION digest(text, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_digest';


ALTER FUNCTION public.digest(text, text) OWNER TO hom;

--
-- Name: digest(bytea, text); Type: FUNCTION; Schema: public; Owner: hom
--

CREATE FUNCTION digest(bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_digest';


ALTER FUNCTION public.digest(bytea, text) OWNER TO hom;

--
-- Name: encrypt(bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: hom
--

CREATE FUNCTION encrypt(bytea, bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_encrypt';


ALTER FUNCTION public.encrypt(bytea, bytea, text) OWNER TO hom;

--
-- Name: encrypt_iv(bytea, bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: hom
--

CREATE FUNCTION encrypt_iv(bytea, bytea, bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_encrypt_iv';


ALTER FUNCTION public.encrypt_iv(bytea, bytea, bytea, text) OWNER TO hom;

--
-- Name: gen_random_bytes(integer); Type: FUNCTION; Schema: public; Owner: hom
--

CREATE FUNCTION gen_random_bytes(integer) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pg_random_bytes';


ALTER FUNCTION public.gen_random_bytes(integer) OWNER TO hom;

--
-- Name: gen_salt(text); Type: FUNCTION; Schema: public; Owner: hom
--

CREATE FUNCTION gen_salt(text) RETURNS text
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pg_gen_salt';


ALTER FUNCTION public.gen_salt(text) OWNER TO hom;

--
-- Name: gen_salt(text, integer); Type: FUNCTION; Schema: public; Owner: hom
--

CREATE FUNCTION gen_salt(text, integer) RETURNS text
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pg_gen_salt_rounds';


ALTER FUNCTION public.gen_salt(text, integer) OWNER TO hom;

--
-- Name: hmac(text, text, text); Type: FUNCTION; Schema: public; Owner: hom
--

CREATE FUNCTION hmac(text, text, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_hmac';


ALTER FUNCTION public.hmac(text, text, text) OWNER TO hom;

--
-- Name: hmac(bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: hom
--

CREATE FUNCTION hmac(bytea, bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_hmac';


ALTER FUNCTION public.hmac(bytea, bytea, text) OWNER TO hom;

--
-- Name: pgp_key_id(bytea); Type: FUNCTION; Schema: public; Owner: hom
--

CREATE FUNCTION pgp_key_id(bytea) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_key_id_w';


ALTER FUNCTION public.pgp_key_id(bytea) OWNER TO hom;

--
-- Name: pgp_pub_decrypt(bytea, bytea); Type: FUNCTION; Schema: public; Owner: hom
--

CREATE FUNCTION pgp_pub_decrypt(bytea, bytea) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_decrypt_text';


ALTER FUNCTION public.pgp_pub_decrypt(bytea, bytea) OWNER TO hom;

--
-- Name: pgp_pub_decrypt(bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: hom
--

CREATE FUNCTION pgp_pub_decrypt(bytea, bytea, text) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_decrypt_text';


ALTER FUNCTION public.pgp_pub_decrypt(bytea, bytea, text) OWNER TO hom;

--
-- Name: pgp_pub_decrypt(bytea, bytea, text, text); Type: FUNCTION; Schema: public; Owner: hom
--

CREATE FUNCTION pgp_pub_decrypt(bytea, bytea, text, text) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_decrypt_text';


ALTER FUNCTION public.pgp_pub_decrypt(bytea, bytea, text, text) OWNER TO hom;

--
-- Name: pgp_pub_decrypt_bytea(bytea, bytea); Type: FUNCTION; Schema: public; Owner: hom
--

CREATE FUNCTION pgp_pub_decrypt_bytea(bytea, bytea) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_decrypt_bytea';


ALTER FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea) OWNER TO hom;

--
-- Name: pgp_pub_decrypt_bytea(bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: hom
--

CREATE FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_decrypt_bytea';


ALTER FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text) OWNER TO hom;

--
-- Name: pgp_pub_decrypt_bytea(bytea, bytea, text, text); Type: FUNCTION; Schema: public; Owner: hom
--

CREATE FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_decrypt_bytea';


ALTER FUNCTION public.pgp_pub_decrypt_bytea(bytea, bytea, text, text) OWNER TO hom;

--
-- Name: pgp_pub_encrypt(text, bytea); Type: FUNCTION; Schema: public; Owner: hom
--

CREATE FUNCTION pgp_pub_encrypt(text, bytea) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_encrypt_text';


ALTER FUNCTION public.pgp_pub_encrypt(text, bytea) OWNER TO hom;

--
-- Name: pgp_pub_encrypt(text, bytea, text); Type: FUNCTION; Schema: public; Owner: hom
--

CREATE FUNCTION pgp_pub_encrypt(text, bytea, text) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_encrypt_text';


ALTER FUNCTION public.pgp_pub_encrypt(text, bytea, text) OWNER TO hom;

--
-- Name: pgp_pub_encrypt_bytea(bytea, bytea); Type: FUNCTION; Schema: public; Owner: hom
--

CREATE FUNCTION pgp_pub_encrypt_bytea(bytea, bytea) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_encrypt_bytea';


ALTER FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea) OWNER TO hom;

--
-- Name: pgp_pub_encrypt_bytea(bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: hom
--

CREATE FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_encrypt_bytea';


ALTER FUNCTION public.pgp_pub_encrypt_bytea(bytea, bytea, text) OWNER TO hom;

--
-- Name: pgp_sym_decrypt(bytea, text); Type: FUNCTION; Schema: public; Owner: hom
--

CREATE FUNCTION pgp_sym_decrypt(bytea, text) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_decrypt_text';


ALTER FUNCTION public.pgp_sym_decrypt(bytea, text) OWNER TO hom;

--
-- Name: pgp_sym_decrypt(bytea, text, text); Type: FUNCTION; Schema: public; Owner: hom
--

CREATE FUNCTION pgp_sym_decrypt(bytea, text, text) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_decrypt_text';


ALTER FUNCTION public.pgp_sym_decrypt(bytea, text, text) OWNER TO hom;

--
-- Name: pgp_sym_decrypt_bytea(bytea, text); Type: FUNCTION; Schema: public; Owner: hom
--

CREATE FUNCTION pgp_sym_decrypt_bytea(bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_decrypt_bytea';


ALTER FUNCTION public.pgp_sym_decrypt_bytea(bytea, text) OWNER TO hom;

--
-- Name: pgp_sym_decrypt_bytea(bytea, text, text); Type: FUNCTION; Schema: public; Owner: hom
--

CREATE FUNCTION pgp_sym_decrypt_bytea(bytea, text, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_decrypt_bytea';


ALTER FUNCTION public.pgp_sym_decrypt_bytea(bytea, text, text) OWNER TO hom;

--
-- Name: pgp_sym_encrypt(text, text); Type: FUNCTION; Schema: public; Owner: hom
--

CREATE FUNCTION pgp_sym_encrypt(text, text) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_encrypt_text';


ALTER FUNCTION public.pgp_sym_encrypt(text, text) OWNER TO hom;

--
-- Name: pgp_sym_encrypt(text, text, text); Type: FUNCTION; Schema: public; Owner: hom
--

CREATE FUNCTION pgp_sym_encrypt(text, text, text) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_encrypt_text';


ALTER FUNCTION public.pgp_sym_encrypt(text, text, text) OWNER TO hom;

--
-- Name: pgp_sym_encrypt_bytea(bytea, text); Type: FUNCTION; Schema: public; Owner: hom
--

CREATE FUNCTION pgp_sym_encrypt_bytea(bytea, text) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_encrypt_bytea';


ALTER FUNCTION public.pgp_sym_encrypt_bytea(bytea, text) OWNER TO hom;

--
-- Name: pgp_sym_encrypt_bytea(bytea, text, text); Type: FUNCTION; Schema: public; Owner: hom
--

CREATE FUNCTION pgp_sym_encrypt_bytea(bytea, text, text) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_encrypt_bytea';


ALTER FUNCTION public.pgp_sym_encrypt_bytea(bytea, text, text) OWNER TO hom;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: accesslog; Type: TABLE; Schema: public; Owner: hom; Tablespace: 
--

CREATE TABLE accesslog (
    _id integer NOT NULL,
    accessfrom text,
    accessuname text,
    accesspass text,
    accessdate text,
    accessuri text
);


ALTER TABLE public.accesslog OWNER TO hom;

--
-- Name: accesslog__id_seq; Type: SEQUENCE; Schema: public; Owner: hom
--

CREATE SEQUENCE accesslog__id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.accesslog__id_seq OWNER TO hom;

--
-- Name: accesslog__id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hom
--

ALTER SEQUENCE accesslog__id_seq OWNED BY accesslog._id;


--
-- Name: assessment_events; Type: TABLE; Schema: public; Owner: hvd; Tablespace: 
--

CREATE TABLE assessment_events (
    event text NOT NULL,
    description text,
    compensation_points integer DEFAULT 0,
    compensation_reason character varying(250)
);


ALTER TABLE public.assessment_events OWNER TO hvd;

--
-- Name: assessment_questions; Type: TABLE; Schema: public; Owner: hvd; Tablespace: 
--

CREATE TABLE assessment_questions (
    event text NOT NULL,
    question character varying(40) NOT NULL,
    max_points integer,
    description text,
    filepath text
);


ALTER TABLE public.assessment_questions OWNER TO hvd;

--
-- Name: assessment_scores; Type: TABLE; Schema: public; Owner: hvd; Tablespace: 
--

CREATE TABLE assessment_scores (
    event text NOT NULL,
    student character varying(10) NOT NULL,
    question character varying(40) NOT NULL,
    score numeric(3,1),
    operator character varying(3),
    update_ts timestamp without time zone DEFAULT now(),
    remark text,
    snummer integer
);


ALTER TABLE public.assessment_scores OWNER TO hvd;

--
-- Name: assessment_final_score; Type: VIEW; Schema: public; Owner: hom
--

CREATE VIEW assessment_final_score AS
    SELECT q.event, s.snummer, sum((s.score * (q.max_points)::numeric)) AS weighted_sum FROM (assessment_questions q JOIN assessment_scores s USING (event, question)) WHERE (q.event = 'PRO2SEN120130703'::text) GROUP BY q.event, s.snummer;


ALTER TABLE public.assessment_final_score OWNER TO hom;

--
-- Name: assessment_questions_bck_20131101; Type: TABLE; Schema: public; Owner: hvd; Tablespace: 
--

CREATE TABLE assessment_questions_bck_20131101 (
    event text,
    question character varying(40),
    max_points integer,
    description text
);


ALTER TABLE public.assessment_questions_bck_20131101 OWNER TO hvd;

--
-- Name: assessment_questions_statistics; Type: VIEW; Schema: public; Owner: hvd
--

CREATE VIEW assessment_questions_statistics AS
    SELECT q.event, q.question, q.max_points, q.description, round((SELECT avg(assessment_scores.score) AS avg FROM assessment_scores WHERE (((assessment_scores.event = q.event) AND ((assessment_scores.question)::text = (q.question)::text)) AND (assessment_scores.score > 1.0))), 1) AS average_score, round((SELECT min(assessment_scores.score) AS min FROM assessment_scores WHERE (((assessment_scores.event = q.event) AND ((assessment_scores.question)::text = (q.question)::text)) AND (assessment_scores.score > 1.0))), 1) AS min_score, round((SELECT max(assessment_scores.score) AS max FROM assessment_scores WHERE ((assessment_scores.event = q.event) AND ((assessment_scores.question)::text = (q.question)::text))), 1) AS max_score, (SELECT count(assessment_scores.score) AS count FROM assessment_scores WHERE (((assessment_scores.event = q.event) AND ((assessment_scores.question)::text = (q.question)::text)) AND (assessment_scores.score > 1.0))) AS answered_by_no_students, round((((SELECT (count(assessment_scores.score))::numeric AS count FROM assessment_scores WHERE (((assessment_scores.event = q.event) AND ((assessment_scores.question)::text = (q.question)::text)) AND (assessment_scores.score > 1.0))) * (100)::numeric) / (SELECT (count(*))::numeric AS count FROM assessment_scores WHERE (((assessment_scores.event = q.event) AND ((assessment_scores.question)::text = (q.question)::text)) AND (assessment_scores.score IS NOT NULL)))), 0) AS answered_by_percentage_students FROM assessment_questions q ORDER BY q.event, q.question;


ALTER TABLE public.assessment_questions_statistics OWNER TO hvd;

--
-- Name: candidate_repos; Type: TABLE; Schema: public; Owner: hom; Tablespace: 
--

CREATE TABLE candidate_repos (
    _id integer NOT NULL,
    event text,
    username character varying(10),
    password character varying(64) NOT NULL,
    active boolean DEFAULT false,
    uid integer,
    gid integer,
    lastname text,
    firstname text,
    tussenvoegsel text,
    ou character varying(10),
    cohort integer,
    email text,
    pcn integer,
    sclass character varying(10),
    homedir text,
    shell text,
    afko text,
    reposroot text,
    reposuri text,
    examyear integer,
    examroom text,
    grp_num integer,
    youngest integer,
    youngestdate timestamp without time zone,
    snummer integer,
    sticknr integer
);


ALTER TABLE public.candidate_repos OWNER TO hom;

--
-- Name: assessment_results; Type: VIEW; Schema: public; Owner: hvd
--

CREATE VIEW assessment_results AS
    SELECT substr((cr.username)::text, 2, 7) AS studentno, cr.username, cr.firstname, cr.tussenvoegsel, cr.lastname, cr.email, cr.sclass AS class, cr.afko AS module, e.event, (SELECT (sum(assessment_questions.max_points) * 10) AS sum FROM assessment_questions WHERE (assessment_questions.event = e.event)) AS max_score, (SELECT assessment_events.compensation_points FROM assessment_events WHERE (assessment_events.event = e.event)) AS compensation_points, (SELECT sum((asco.score * (aq.max_points)::numeric)) AS sum FROM assessment_scores asco, assessment_questions aq WHERE (((((asco.question)::text = (aq.question)::text) AND (asco.event = aq.event)) AND (asco.event = e.event)) AND ((asco.student)::text = (cr.username)::text))) AS actual_score, round((((SELECT sum((asco.score * (aq.max_points)::numeric)) AS sum FROM assessment_scores asco, assessment_questions aq WHERE (((((asco.question)::text = (aq.question)::text) AND (asco.event = aq.event)) AND (asco.event = e.event)) AND ((asco.student)::text = (cr.username)::text))) / (((SELECT sum((assessment_questions.max_points * 10)) AS sum FROM assessment_questions WHERE (assessment_questions.event = e.event)) - (SELECT assessment_events.compensation_points FROM assessment_events WHERE (assessment_events.event = e.event))))::numeric) * (10)::numeric), 1) AS grade FROM candidate_repos cr, assessment_events e WHERE (cr.event = e.event) GROUP BY e.event, cr.username, substr((cr.username)::text, 2, 7), cr.firstname, cr.tussenvoegsel, cr.lastname, cr.email, cr.sclass, cr.afko ORDER BY e.event, round((((SELECT sum((asco.score * (aq.max_points)::numeric)) AS sum FROM assessment_scores asco, assessment_questions aq WHERE (((((asco.question)::text = (aq.question)::text) AND (asco.event = aq.event)) AND (asco.event = e.event)) AND ((asco.student)::text = (cr.username)::text))) / (((SELECT sum((assessment_questions.max_points * 10)) AS sum FROM assessment_questions WHERE (assessment_questions.event = e.event)) - (SELECT assessment_events.compensation_points FROM assessment_events WHERE (assessment_events.event = e.event))))::numeric) * (10)::numeric), 1) DESC;


ALTER TABLE public.assessment_results OWNER TO hvd;

--
-- Name: assessment_results_per_question; Type: VIEW; Schema: public; Owner: hvd
--

CREATE VIEW assessment_results_per_question AS
    SELECT asco.event, asco.student, cr.firstname, cr.lastname, asco.question, asco.score, aq.max_points AS weight, (asco.score * (aq.max_points)::numeric) AS points FROM assessment_scores asco, assessment_questions aq, candidate_repos cr WHERE ((((cr.event = asco.event) AND ((cr.username)::text = (asco.student)::text)) AND ((asco.question)::text = (aq.question)::text)) AND (asco.event = aq.event)) ORDER BY cr.username, aq.question;


ALTER TABLE public.assessment_results_per_question OWNER TO hvd;

--
-- Name: assessment_scores_bck_20131101; Type: TABLE; Schema: public; Owner: hvd; Tablespace: 
--

CREATE TABLE assessment_scores_bck_20131101 (
    event text,
    student character varying(10),
    question character varying(40),
    score numeric(3,1),
    operator character varying(3),
    update_ts timestamp without time zone,
    remark text,
    snummer integer
);


ALTER TABLE public.assessment_scores_bck_20131101 OWNER TO hvd;

--
-- Name: assessment_scores_temp; Type: TABLE; Schema: public; Owner: hvd; Tablespace: 
--

CREATE TABLE assessment_scores_temp (
    event text,
    student character varying(10),
    question character varying(40),
    score numeric(3,1),
    operator character varying(3),
    update_ts timestamp without time zone,
    remark text,
    snummer integer
);


ALTER TABLE public.assessment_scores_temp OWNER TO hvd;

--
-- Name: assessment_statistics; Type: VIEW; Schema: public; Owner: hvd
--

CREATE VIEW assessment_statistics AS
    SELECT r0.event, count(*) AS no_candidates, count(r0.actual_score) AS no_participants, round(avg(r0.grade), 1) AS average_grade, (SELECT count(*) AS count FROM assessment_results r1 WHERE (((r1.grade >= 0.0) AND (r1.grade <= 0.9)) AND (r1.event = r0.event))) AS "0=<1", (SELECT count(*) AS count FROM assessment_results r2 WHERE (((r2.grade >= 1.0) AND (r2.grade <= 1.9)) AND (r2.event = r0.event))) AS "1=<2", (SELECT count(*) AS count FROM assessment_results r3 WHERE (((r3.grade >= 2.0) AND (r3.grade <= 2.9)) AND (r3.event = r0.event))) AS "2=<3", (SELECT count(*) AS count FROM assessment_results r4 WHERE (((r4.grade >= 3.0) AND (r4.grade <= 3.9)) AND (r4.event = r0.event))) AS "3=<4", (SELECT count(*) AS count FROM assessment_results r5 WHERE (((r5.grade >= 4.0) AND (r5.grade <= 4.9)) AND (r5.event = r0.event))) AS "4=<5", (SELECT count(*) AS count FROM assessment_results r6 WHERE (((r6.grade >= 5.0) AND (r6.grade <= 5.9)) AND (r6.event = r0.event))) AS "5=<6", (SELECT count(*) AS count FROM assessment_results r7 WHERE (((r7.grade >= 6.0) AND (r7.grade <= 6.9)) AND (r7.event = r0.event))) AS "6=<7", (SELECT count(*) AS count FROM assessment_results r8 WHERE (((r8.grade >= 7.0) AND (r8.grade <= 7.9)) AND (r8.event = r0.event))) AS "7=<8", (SELECT count(*) AS count FROM assessment_results r9 WHERE (((r9.grade >= 8.0) AND (r9.grade <= 8.9)) AND (r9.event = r0.event))) AS "8=<9", (SELECT count(*) AS count FROM assessment_results r10 WHERE (((r10.grade >= 9.0) AND (r10.grade <= (10)::numeric)) AND (r10.event = r0.event))) AS "9=<=10" FROM assessment_results r0 GROUP BY r0.event;


ALTER TABLE public.assessment_statistics OWNER TO hvd;

--
-- Name: assessment_weight_sum; Type: VIEW; Schema: public; Owner: hom
--

CREATE VIEW assessment_weight_sum AS
    SELECT assessment_questions.event, sum(assessment_questions.max_points) AS weight_sum FROM assessment_questions GROUP BY assessment_questions.event;


ALTER TABLE public.assessment_weight_sum OWNER TO hom;

--
-- Name: available_event; Type: TABLE; Schema: public; Owner: hom; Tablespace: 
--

CREATE TABLE available_event (
    _id integer NOT NULL,
    event text NOT NULL,
    event_date date DEFAULT (now())::date,
    active boolean DEFAULT false
);


ALTER TABLE public.available_event OWNER TO hom;

--
-- Name: available_event__id_seq; Type: SEQUENCE; Schema: public; Owner: hom
--

CREATE SEQUENCE available_event__id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.available_event__id_seq OWNER TO hom;

--
-- Name: available_event__id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hom
--

ALTER SEQUENCE available_event__id_seq OWNED BY available_event._id;


--
-- Name: candidate_repos__id_seq; Type: SEQUENCE; Schema: public; Owner: hom
--

CREATE SEQUENCE candidate_repos__id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.candidate_repos__id_seq OWNER TO hom;

--
-- Name: candidate_repos__id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hom
--

ALTER SEQUENCE candidate_repos__id_seq OWNED BY candidate_repos._id;


--
-- Name: tutor_pw; Type: TABLE; Schema: public; Owner: hom; Tablespace: 
--

CREATE TABLE tutor_pw (
    username character varying(10) NOT NULL,
    password character varying(64)
);


ALTER TABLE public.tutor_pw OWNER TO hom;

--
-- Name: doc_users; Type: VIEW; Schema: public; Owner: hom
--

CREATE VIEW doc_users AS
    SELECT tutor_pw.username, tutor_pw.password, 'tutor'::text AS event FROM tutor_pw UNION SELECT candidate_repos.username, candidate_repos.password, candidate_repos.event FROM candidate_repos;


ALTER TABLE public.doc_users OWNER TO hom;

--
-- Name: et_calls; Type: TABLE; Schema: public; Owner: hom; Tablespace: 
--

CREATE TABLE et_calls (
    id integer NOT NULL,
    sticknr smallint,
    from_ip inet,
    mac_address macaddr,
    first_call_time timestamp without time zone,
    last_call_time timestamp without time zone,
    payload text,
    payload_name text
);


ALTER TABLE public.et_calls OWNER TO hom;

--
-- Name: et_calls_id_seq; Type: SEQUENCE; Schema: public; Owner: hom
--

CREATE SEQUENCE et_calls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.et_calls_id_seq OWNER TO hom;

--
-- Name: et_calls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hom
--

ALTER SEQUENCE et_calls_id_seq OWNED BY et_calls.id;


--
-- Name: exam_auth; Type: VIEW; Schema: public; Owner: hom
--

CREATE VIEW exam_auth AS
    SELECT candidate_repos.username, candidate_repos.password FROM candidate_repos WHERE (to_char(((now())::date)::timestamp with time zone, 'YYYYMMDD'::text) = "substring"(candidate_repos.event, (length(candidate_repos.event) - 7))) UNION SELECT tutor_pw.username, tutor_pw.password FROM tutor_pw;


ALTER TABLE public.exam_auth OWNER TO hom;

--
-- Name: exam_systems; Type: TABLE; Schema: public; Owner: hom; Tablespace: 
--

CREATE TABLE exam_systems (
    id integer NOT NULL,
    mac_address macaddr,
    payload text,
    payloadsum text,
    entry_time timestamp without time zone DEFAULT now()
);


ALTER TABLE public.exam_systems OWNER TO hom;

--
-- Name: exam_systems_id_seq; Type: SEQUENCE; Schema: public; Owner: hom
--

CREATE SEQUENCE exam_systems_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.exam_systems_id_seq OWNER TO hom;

--
-- Name: exam_systems_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: hom
--

ALTER SEQUENCE exam_systems_id_seq OWNED BY exam_systems.id;


--
-- Name: fake_mail_address; Type: TABLE; Schema: public; Owner: hom; Tablespace: 
--

CREATE TABLE fake_mail_address (
    email1 text
);


ALTER TABLE public.fake_mail_address OWNER TO hom;

--
-- Name: final_score; Type: VIEW; Schema: public; Owner: hom
--

CREATE VIEW final_score AS
    SELECT assessment_final_score.event, assessment_final_score.snummer, assessment_final_score.weighted_sum, assessment_weight_sum.weight_sum, round((assessment_final_score.weighted_sum / (assessment_weight_sum.weight_sum)::numeric), 2) AS fin FROM (assessment_final_score JOIN assessment_weight_sum USING (event));


ALTER TABLE public.final_score OWNER TO hom;

--
-- Name: present; Type: TABLE; Schema: public; Owner: hom; Tablespace: 
--

CREATE TABLE present (
    event text,
    snummer integer NOT NULL
);


ALTER TABLE public.present OWNER TO hom;

--
-- Name: pro2sen120130618; Type: VIEW; Schema: public; Owner: hom
--

CREATE VIEW pro2sen120130618 AS
    SELECT ct.snummer, ct.lastname, ct.firstname, ct.tussenvoegsel, ct.email, ct.qpro2_1, ct.qpro2_2, ct.qpro2_3, ct.qpro2sen1_1, ct.qpro2sen1_2, ct.qpro2sen1_3, ct.qpro2sen1_4, ct.qpro2sen1_5, ct.qsen1_1, ct.qsen1_2, ct.qsen1_3, ct.qsen1_4, ct.qsen1_5, ct.qsen1_6, ct.qsen1_7 FROM crosstab('select snummer,lastname,firstname,tussenvoegsel,email,question,score from candidate_repos car join assessment_scores assc using(snummer,event) where event=''PRO2SEN120130618'' order by snummer,question'::text, 'select question from assessment_questions where event=''PRO2SEN120130618'' order by question'::text) ct(snummer integer, lastname text, firstname text, tussenvoegsel text, email text, qpro2_1 numeric, qpro2_2 numeric, qpro2_3 numeric, qpro2sen1_1 numeric, qpro2sen1_2 numeric, qpro2sen1_3 numeric, qpro2sen1_4 numeric, qpro2sen1_5 numeric, qsen1_1 numeric, qsen1_2 numeric, qsen1_3 numeric, qsen1_4 numeric, qsen1_5 numeric, qsen1_6 numeric, qsen1_7 numeric) WHERE (ct.qsen1_1 IS NOT NULL) ORDER BY ct.lastname, ct.firstname;


ALTER TABLE public.pro2sen120130618 OWNER TO hom;

--
-- Name: pro2sen1_scores_20130410; Type: VIEW; Schema: public; Owner: hom
--

CREATE VIEW pro2sen1_scores_20130410 AS
    SELECT ct.snummer, ct.lastname, ct.firstname, ct.tussenvoegsel, ct.email, ct.qpro2_circle, ct.qpro2_drawing, ct.qpro2_rectangle, ct.qpro2_shape, ct.qpro2_shapeexception, ct.qpro2_square, ct.qpro2_triangle, ct.qsen1_1, ct.qsen1_2, ct.qsen1_3, ct.qsen1_4, ct.qsen1_5, ct.qsen1_6 FROM crosstab('select snummer,lastname,firstname,tussenvoegsel,email,question,score from candidate_repos car join assessment_scores assc using(snummer,event) where event=''PRO220130410'' order by snummer,question'::text, 'select question from assessment_questions where event=''PRO220130410'' order by question'::text) ct(snummer integer, lastname text, firstname text, tussenvoegsel text, email text, qpro2_circle numeric, qpro2_drawing numeric, qpro2_rectangle numeric, qpro2_shape numeric, qpro2_shapeexception numeric, qpro2_square numeric, qpro2_triangle numeric, qsen1_1 numeric, qsen1_2 numeric, qsen1_3 numeric, qsen1_4 numeric, qsen1_5 numeric, qsen1_6 numeric) ORDER BY ct.lastname, ct.firstname;


ALTER TABLE public.pro2sen1_scores_20130410 OWNER TO hom;

--
-- Name: pro2sen1_scores_20130410_pro2_part; Type: VIEW; Schema: public; Owner: hvd
--

CREATE VIEW pro2sen1_scores_20130410_pro2_part AS
    SELECT resultsview.studentno, resultsview.username, resultsview.firstname, resultsview.tussenvoegsel, resultsview.lastname, resultsview.email, resultsview.class, resultsview.module, resultsview.event, resultsview.max_score, resultsview.compensation_points, resultsview.actual_score, resultsview.grade, CASE WHEN (resultsview.actual_score IS NOT NULL) THEN LEAST(resultsview.grade, 10.0) ELSE NULL::numeric END AS final_result FROM (SELECT substr((cr.username)::text, 2, 7) AS studentno, cr.username, cr.firstname, cr.tussenvoegsel, cr.lastname, cr.email, cr.sclass AS class, cr.afko AS module, e.event, (SELECT sum(assessment_questions.max_points) AS sum FROM assessment_questions WHERE ((assessment_questions.event = e.event) AND ((assessment_questions.question)::text ~~ 'PRO2%'::text))) AS max_score, (SELECT assessment_events.compensation_points FROM assessment_events WHERE (assessment_events.event = e.event)) AS compensation_points, (SELECT sum(assessment_scores.score) AS sum FROM assessment_scores WHERE (((assessment_scores.event = e.event) AND ((assessment_scores.student)::text = (cr.username)::text)) AND ((assessment_scores.question)::text ~~ 'PRO2%'::text))) AS actual_score, round((((SELECT sum(assessment_scores.score) AS sum FROM assessment_scores WHERE (((assessment_scores.event = e.event) AND ((assessment_scores.student)::text = (cr.username)::text)) AND ((assessment_scores.question)::text ~~ 'PRO2%'::text))) * (9.0 / (((SELECT sum(assessment_questions.max_points) AS sum FROM assessment_questions WHERE ((assessment_questions.event = e.event) AND ((assessment_questions.question)::text ~~ 'PRO2%'::text))) - (SELECT assessment_events.compensation_points FROM assessment_events WHERE (assessment_events.event = e.event))))::numeric)) + 1.0), 1) AS grade FROM candidate_repos cr, assessment_events e WHERE ((cr.event = e.event) AND (e.event = 'PRO220130410'::text)) GROUP BY e.event, cr.username, substr((cr.username)::text, 2, 7), cr.firstname, cr.tussenvoegsel, cr.lastname, cr.email, cr.sclass, cr.afko ORDER BY e.event, cr.lastname) resultsview;


ALTER TABLE public.pro2sen1_scores_20130410_pro2_part OWNER TO hvd;

--
-- Name: quest_cat_stud; Type: VIEW; Schema: public; Owner: hvd
--

CREATE VIEW quest_cat_stud AS
    SELECT assc.event, (((((((assc.question)::text || ':'::text) || candidate_repos.lastname) || ':'::text) || candidate_repos.firstname) || ':'::text) || (assc.student)::text) AS qs FROM (assessment_scores assc JOIN candidate_repos USING (snummer, event)) WHERE (candidate_repos.youngest > 1);


ALTER TABLE public.quest_cat_stud OWNER TO hvd;

--
-- Name: sen1_result_20130410; Type: VIEW; Schema: public; Owner: hom
--

CREATE VIEW sen1_result_20130410 AS
    SELECT pro2sen1_scores_20130410.snummer, pro2sen1_scores_20130410.lastname, pro2sen1_scores_20130410.firstname, pro2sen1_scores_20130410.tussenvoegsel, pro2sen1_scores_20130410.email, pro2sen1_scores_20130410.qsen1_1, pro2sen1_scores_20130410.qsen1_2, pro2sen1_scores_20130410.qsen1_3, pro2sen1_scores_20130410.qsen1_4, pro2sen1_scores_20130410.qsen1_5, pro2sen1_scores_20130410.qsen1_6, round(((((((pro2sen1_scores_20130410.qsen1_1 + pro2sen1_scores_20130410.qsen1_2) + pro2sen1_scores_20130410.qsen1_3) + pro2sen1_scores_20130410.qsen1_4) + pro2sen1_scores_20130410.qsen1_5) + pro2sen1_scores_20130410.qsen1_6) / (6)::numeric), 1) AS final FROM pro2sen1_scores_20130410;


ALTER TABLE public.sen1_result_20130410 OWNER TO hom;

--
-- Name: sen1_score_20130410; Type: VIEW; Schema: public; Owner: hom
--

CREATE VIEW sen1_score_20130410 AS
    SELECT assessment_scores.snummer, round((sum(assessment_scores.score) / 6.0), 1) AS scores FROM assessment_scores WHERE ((assessment_scores.event = 'PRO220130410'::text) AND ((assessment_scores.question)::text ~~ 'SEN1%'::text)) GROUP BY assessment_scores.snummer ORDER BY assessment_scores.snummer;


ALTER TABLE public.sen1_score_20130410 OWNER TO hom;

--
-- Name: sen1pro2_combined_20130410; Type: VIEW; Schema: public; Owner: hom
--

CREATE VIEW sen1pro2_combined_20130410 AS
    SELECT s.lastname, s.final AS sen1_final, pro2sen1_scores_20130410_pro2_part.final_result AS pro2_final FROM (sen1_result_20130410 s JOIN pro2sen1_scores_20130410_pro2_part ON (((s.snummer)::text = pro2sen1_scores_20130410_pro2_part.studentno))) WHERE (s.final IS NOT NULL) ORDER BY s.lastname;


ALTER TABLE public.sen1pro2_combined_20130410 OWNER TO hom;

--
-- Name: sticks; Type: TABLE; Schema: public; Owner: hom; Tablespace: 
--

CREATE TABLE sticks (
    sticknr smallint NOT NULL,
    since date DEFAULT (now())::date
);


ALTER TABLE public.sticks OWNER TO hom;

--
-- Name: svn_users; Type: VIEW; Schema: public; Owner: hom
--

CREATE VIEW svn_users AS
    SELECT tutor_pw.username, tutor_pw.password, 'tutor'::text AS event FROM tutor_pw UNION SELECT candidate_repos.username, candidate_repos.password, candidate_repos.event FROM candidate_repos WHERE (candidate_repos.active = true);


ALTER TABLE public.svn_users OWNER TO hom;

--
-- Name: temp_assessment_scores; Type: TABLE; Schema: public; Owner: hvd; Tablespace: 
--

CREATE TABLE temp_assessment_scores (
    event text,
    student character varying(10),
    question character varying(10),
    score numeric(3,1),
    operator character varying(3),
    update_ts timestamp without time zone,
    snummer integer
);


ALTER TABLE public.temp_assessment_scores OWNER TO hvd;

--
-- Name: _id; Type: DEFAULT; Schema: public; Owner: hom
--

ALTER TABLE ONLY accesslog ALTER COLUMN _id SET DEFAULT nextval('accesslog__id_seq'::regclass);


--
-- Name: _id; Type: DEFAULT; Schema: public; Owner: hom
--

ALTER TABLE ONLY available_event ALTER COLUMN _id SET DEFAULT nextval('available_event__id_seq'::regclass);


--
-- Name: _id; Type: DEFAULT; Schema: public; Owner: hom
--

ALTER TABLE ONLY candidate_repos ALTER COLUMN _id SET DEFAULT nextval('candidate_repos__id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: hom
--

ALTER TABLE ONLY et_calls ALTER COLUMN id SET DEFAULT nextval('et_calls_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: hom
--

ALTER TABLE ONLY exam_systems ALTER COLUMN id SET DEFAULT nextval('exam_systems_id_seq'::regclass);


--
-- Name: assessment_questions_pk; Type: CONSTRAINT; Schema: public; Owner: hvd; Tablespace: 
--

ALTER TABLE ONLY assessment_questions
    ADD CONSTRAINT assessment_questions_pk PRIMARY KEY (event, question);


--
-- Name: assessment_scores_pk; Type: CONSTRAINT; Schema: public; Owner: hvd; Tablespace: 
--

ALTER TABLE ONLY assessment_scores
    ADD CONSTRAINT assessment_scores_pk PRIMARY KEY (event, student, question);


--
-- Name: available_event_pkey; Type: CONSTRAINT; Schema: public; Owner: hom; Tablespace: 
--

ALTER TABLE ONLY available_event
    ADD CONSTRAINT available_event_pkey PRIMARY KEY (event);


--
-- Name: candidate_repos_event_key; Type: CONSTRAINT; Schema: public; Owner: hom; Tablespace: 
--

ALTER TABLE ONLY candidate_repos
    ADD CONSTRAINT candidate_repos_event_key UNIQUE (event, username);


--
-- Name: candidate_repos_pkey; Type: CONSTRAINT; Schema: public; Owner: hom; Tablespace: 
--

ALTER TABLE ONLY candidate_repos
    ADD CONSTRAINT candidate_repos_pkey PRIMARY KEY (_id);


--
-- Name: candidate_repos_reposroot_key; Type: CONSTRAINT; Schema: public; Owner: hom; Tablespace: 
--

ALTER TABLE ONLY candidate_repos
    ADD CONSTRAINT candidate_repos_reposroot_key UNIQUE (reposroot);


--
-- Name: candidate_repos_reposuri_key; Type: CONSTRAINT; Schema: public; Owner: hom; Tablespace: 
--

ALTER TABLE ONLY candidate_repos
    ADD CONSTRAINT candidate_repos_reposuri_key UNIQUE (reposuri);


--
-- Name: et_calls_pkey; Type: CONSTRAINT; Schema: public; Owner: hom; Tablespace: 
--

ALTER TABLE ONLY et_calls
    ADD CONSTRAINT et_calls_pkey PRIMARY KEY (id);


--
-- Name: event_pk; Type: CONSTRAINT; Schema: public; Owner: hvd; Tablespace: 
--

ALTER TABLE ONLY assessment_events
    ADD CONSTRAINT event_pk PRIMARY KEY (event);


--
-- Name: macaddr_payloadsum_un; Type: CONSTRAINT; Schema: public; Owner: hom; Tablespace: 
--

ALTER TABLE ONLY exam_systems
    ADD CONSTRAINT macaddr_payloadsum_un UNIQUE (mac_address, payloadsum);


--
-- Name: sticks_pkey; Type: CONSTRAINT; Schema: public; Owner: hom; Tablespace: 
--

ALTER TABLE ONLY sticks
    ADD CONSTRAINT sticks_pkey PRIMARY KEY (sticknr);


--
-- Name: tutor_pw_pkey; Type: CONSTRAINT; Schema: public; Owner: hom; Tablespace: 
--

ALTER TABLE ONLY tutor_pw
    ADD CONSTRAINT tutor_pw_pkey PRIMARY KEY (username);


--
-- Name: assessment_questions_fk; Type: FK CONSTRAINT; Schema: public; Owner: hvd
--

ALTER TABLE ONLY assessment_questions
    ADD CONSTRAINT assessment_questions_fk FOREIGN KEY (event) REFERENCES assessment_events(event) ON DELETE CASCADE;


--
-- Name: candidate_repos_sticknr_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hom
--

ALTER TABLE ONLY candidate_repos
    ADD CONSTRAINT candidate_repos_sticknr_fkey FOREIGN KEY (sticknr) REFERENCES sticks(sticknr);


--
-- Name: event_fk; Type: FK CONSTRAINT; Schema: public; Owner: hvd
--

ALTER TABLE ONLY assessment_scores
    ADD CONSTRAINT event_fk FOREIGN KEY (event) REFERENCES assessment_events(event) ON DELETE CASCADE;


--
-- Name: event_question; Type: FK CONSTRAINT; Schema: public; Owner: hvd
--

ALTER TABLE ONLY assessment_scores
    ADD CONSTRAINT event_question FOREIGN KEY (event, question) REFERENCES assessment_questions(event, question);


--
-- Name: event_user_fk; Type: FK CONSTRAINT; Schema: public; Owner: hvd
--

ALTER TABLE ONLY assessment_scores
    ADD CONSTRAINT event_user_fk FOREIGN KEY (event, student) REFERENCES candidate_repos(event, username);


--
-- Name: present_event_fkey; Type: FK CONSTRAINT; Schema: public; Owner: hom
--

ALTER TABLE ONLY present
    ADD CONSTRAINT present_event_fkey FOREIGN KEY (event) REFERENCES available_event(event);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: accesslog; Type: ACL; Schema: public; Owner: hom
--

REVOKE ALL ON TABLE accesslog FROM PUBLIC;
REVOKE ALL ON TABLE accesslog FROM hom;
GRANT ALL ON TABLE accesslog TO hom;
GRANT ALL ON TABLE accesslog TO wwwrun;
GRANT ALL ON TABLE accesslog TO hvd;


--
-- Name: assessment_events; Type: ACL; Schema: public; Owner: hvd
--

REVOKE ALL ON TABLE assessment_events FROM PUBLIC;
REVOKE ALL ON TABLE assessment_events FROM hvd;
GRANT ALL ON TABLE assessment_events TO hvd;
GRANT ALL ON TABLE assessment_events TO wwwrun;
GRANT ALL ON TABLE assessment_events TO hom;


--
-- Name: assessment_questions; Type: ACL; Schema: public; Owner: hvd
--

REVOKE ALL ON TABLE assessment_questions FROM PUBLIC;
REVOKE ALL ON TABLE assessment_questions FROM hvd;
GRANT ALL ON TABLE assessment_questions TO hvd;
GRANT ALL ON TABLE assessment_questions TO wwwrun;
GRANT ALL ON TABLE assessment_questions TO hom;


--
-- Name: assessment_scores; Type: ACL; Schema: public; Owner: hvd
--

REVOKE ALL ON TABLE assessment_scores FROM PUBLIC;
REVOKE ALL ON TABLE assessment_scores FROM hvd;
GRANT ALL ON TABLE assessment_scores TO hvd;
GRANT ALL ON TABLE assessment_scores TO wwwrun;
GRANT ALL ON TABLE assessment_scores TO hom;


--
-- Name: assessment_questions_statistics; Type: ACL; Schema: public; Owner: hvd
--

REVOKE ALL ON TABLE assessment_questions_statistics FROM PUBLIC;
REVOKE ALL ON TABLE assessment_questions_statistics FROM hvd;
GRANT ALL ON TABLE assessment_questions_statistics TO hvd;
GRANT SELECT ON TABLE assessment_questions_statistics TO wwwrun;


--
-- Name: candidate_repos; Type: ACL; Schema: public; Owner: hom
--

REVOKE ALL ON TABLE candidate_repos FROM PUBLIC;
REVOKE ALL ON TABLE candidate_repos FROM hom;
GRANT ALL ON TABLE candidate_repos TO hom;
GRANT ALL ON TABLE candidate_repos TO wwwrun;
GRANT ALL ON TABLE candidate_repos TO hvd;


--
-- Name: assessment_results; Type: ACL; Schema: public; Owner: hvd
--

REVOKE ALL ON TABLE assessment_results FROM PUBLIC;
REVOKE ALL ON TABLE assessment_results FROM hvd;
GRANT ALL ON TABLE assessment_results TO hvd;
GRANT SELECT ON TABLE assessment_results TO wwwrun;


--
-- Name: assessment_results_per_question; Type: ACL; Schema: public; Owner: hvd
--

REVOKE ALL ON TABLE assessment_results_per_question FROM PUBLIC;
REVOKE ALL ON TABLE assessment_results_per_question FROM hvd;
GRANT ALL ON TABLE assessment_results_per_question TO hvd;
GRANT SELECT ON TABLE assessment_results_per_question TO wwwrun;


--
-- Name: assessment_statistics; Type: ACL; Schema: public; Owner: hvd
--

REVOKE ALL ON TABLE assessment_statistics FROM PUBLIC;
REVOKE ALL ON TABLE assessment_statistics FROM hvd;
GRANT ALL ON TABLE assessment_statistics TO hvd;
GRANT SELECT ON TABLE assessment_statistics TO wwwrun;


--
-- Name: available_event; Type: ACL; Schema: public; Owner: hom
--

REVOKE ALL ON TABLE available_event FROM PUBLIC;
REVOKE ALL ON TABLE available_event FROM hom;
GRANT ALL ON TABLE available_event TO hom;
GRANT SELECT,REFERENCES ON TABLE available_event TO wwwrun;


--
-- Name: tutor_pw; Type: ACL; Schema: public; Owner: hom
--

REVOKE ALL ON TABLE tutor_pw FROM PUBLIC;
REVOKE ALL ON TABLE tutor_pw FROM hom;
GRANT ALL ON TABLE tutor_pw TO hom;
GRANT ALL ON TABLE tutor_pw TO wwwrun;
GRANT ALL ON TABLE tutor_pw TO hvd;


--
-- Name: doc_users; Type: ACL; Schema: public; Owner: hom
--

REVOKE ALL ON TABLE doc_users FROM PUBLIC;
REVOKE ALL ON TABLE doc_users FROM hom;
GRANT ALL ON TABLE doc_users TO hom;
GRANT ALL ON TABLE doc_users TO wwwrun;
GRANT ALL ON TABLE doc_users TO hvd;


--
-- Name: et_calls; Type: ACL; Schema: public; Owner: hom
--

REVOKE ALL ON TABLE et_calls FROM PUBLIC;
REVOKE ALL ON TABLE et_calls FROM hom;
GRANT ALL ON TABLE et_calls TO hom;
GRANT ALL ON TABLE et_calls TO wwwrun;


--
-- Name: et_calls_id_seq; Type: ACL; Schema: public; Owner: hom
--

REVOKE ALL ON SEQUENCE et_calls_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE et_calls_id_seq FROM hom;
GRANT ALL ON SEQUENCE et_calls_id_seq TO hom;
GRANT ALL ON SEQUENCE et_calls_id_seq TO wwwrun;


--
-- Name: exam_auth; Type: ACL; Schema: public; Owner: hom
--

REVOKE ALL ON TABLE exam_auth FROM PUBLIC;
REVOKE ALL ON TABLE exam_auth FROM hom;
GRANT ALL ON TABLE exam_auth TO hom;
GRANT SELECT,REFERENCES ON TABLE exam_auth TO wwwrun;


--
-- Name: exam_systems; Type: ACL; Schema: public; Owner: hom
--

REVOKE ALL ON TABLE exam_systems FROM PUBLIC;
REVOKE ALL ON TABLE exam_systems FROM hom;
GRANT ALL ON TABLE exam_systems TO hom;
GRANT SELECT,INSERT,REFERENCES ON TABLE exam_systems TO wwwrun;


--
-- Name: exam_systems_id_seq; Type: ACL; Schema: public; Owner: hom
--

REVOKE ALL ON SEQUENCE exam_systems_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE exam_systems_id_seq FROM hom;
GRANT ALL ON SEQUENCE exam_systems_id_seq TO hom;
GRANT ALL ON SEQUENCE exam_systems_id_seq TO wwwrun;


--
-- Name: final_score; Type: ACL; Schema: public; Owner: hom
--

REVOKE ALL ON TABLE final_score FROM PUBLIC;
REVOKE ALL ON TABLE final_score FROM hom;
GRANT ALL ON TABLE final_score TO hom;
GRANT ALL ON TABLE final_score TO wwwrun;


--
-- Name: present; Type: ACL; Schema: public; Owner: hom
--

REVOKE ALL ON TABLE present FROM PUBLIC;
REVOKE ALL ON TABLE present FROM hom;
GRANT ALL ON TABLE present TO hom;
GRANT ALL ON TABLE present TO wwwrun;


--
-- Name: quest_cat_stud; Type: ACL; Schema: public; Owner: hvd
--

REVOKE ALL ON TABLE quest_cat_stud FROM PUBLIC;
REVOKE ALL ON TABLE quest_cat_stud FROM hvd;
GRANT ALL ON TABLE quest_cat_stud TO hvd;
GRANT SELECT ON TABLE quest_cat_stud TO wwwrun;


--
-- Name: sen1_result_20130410; Type: ACL; Schema: public; Owner: hom
--

REVOKE ALL ON TABLE sen1_result_20130410 FROM PUBLIC;
REVOKE ALL ON TABLE sen1_result_20130410 FROM hom;
GRANT ALL ON TABLE sen1_result_20130410 TO hom;
GRANT SELECT ON TABLE sen1_result_20130410 TO wwwrun;


--
-- Name: sticks; Type: ACL; Schema: public; Owner: hom
--

REVOKE ALL ON TABLE sticks FROM PUBLIC;
REVOKE ALL ON TABLE sticks FROM hom;
GRANT ALL ON TABLE sticks TO hom;
GRANT SELECT,REFERENCES ON TABLE sticks TO wwwrun;


--
-- Name: svn_users; Type: ACL; Schema: public; Owner: hom
--

REVOKE ALL ON TABLE svn_users FROM PUBLIC;
REVOKE ALL ON TABLE svn_users FROM hom;
GRANT ALL ON TABLE svn_users TO hom;
GRANT ALL ON TABLE svn_users TO wwwrun;
GRANT ALL ON TABLE svn_users TO hvd;


--
-- PostgreSQL database dump complete
--

