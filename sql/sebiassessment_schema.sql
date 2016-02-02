--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: tablefunc; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS tablefunc WITH SCHEMA public;


--
-- Name: EXTENSION tablefunc; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION tablefunc IS 'functions that manipulate whole tables, including crosstab';


SET search_path = public, pg_catalog;

--
-- Name: armor(bytea); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION armor(bytea) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_armor';


--
-- Name: assessment_score_query(text); Type: FUNCTION; Schema: public; Owner: -
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


--
-- Name: assessment_score_query2(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION assessment_score_query2(myevent text) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare
  th text;
begin
  select array_agg('q'||question||' numeric') into strict th from (select question from assessment_questions where event=myevent order by question) qq;
  th := 'crosstab(
  ''select stick_nr,stick_event_repo_id,question,score from stick_event_repo car join assessment_scores assc using(stick_event_repo_id) where car.event='''''||myevent||''''' and youngest > 1 order by snummer,question'',
  ''select question from assessment_questions aqs where aqs.event='''''||myevent||''''' order by question''
  ) as ct(stick_nr integer,stick_event_repo_id integer,'||regexp_replace(th,'[}"{]','','g')||') ';
  return th;
end; $$;


--
-- Name: assessment_score_query3(text, character); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION assessment_score_query3(myevent text, mycategory character) RETURNS text
    LANGUAGE plpgsql
    AS $$
declare
  th text;
begin
  select array_agg('q'||question||' numeric') into strict th 
  from (select question from assessment_questions where event=myevent and category=mycategory order by question) qq;
  th := 'crosstab(
  ''select snummer, stick_nr,stick_event_repo_id,question,score 
  from stick_event_repo car 
  join assessment_scores assc using(event,stick_event_repo_id)
  join assessment_questions qst using(event,question)
  join candidate_stick cs using(stick_event_repo_id)
  join student using(snummer)
  where car.event='''''||myevent||''''' and qst.category='''''||mycategory||''''' order by stick_nr,question'',
  ''select question from assessment_questions aqs where aqs.event='''''||myevent||''''' and aqs.category='''''||mycategory||''''' order by question''
  ) as ct(snummer integer,stick_nr integer,stick_event_repo_id integer,'||regexp_replace(th,'[}"{]','','g')||') ';
  return th;
end; $$;


--
-- Name: crypt(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION crypt(text, text) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_crypt';


--
-- Name: dearmor(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION dearmor(text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_dearmor';


--
-- Name: decrypt(bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION decrypt(bytea, bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_decrypt';


--
-- Name: decrypt_iv(bytea, bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION decrypt_iv(bytea, bytea, bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_decrypt_iv';


--
-- Name: digest(bytea, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION digest(bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_digest';


--
-- Name: digest(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION digest(text, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_digest';


--
-- Name: encrypt(bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION encrypt(bytea, bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_encrypt';


--
-- Name: encrypt_iv(bytea, bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION encrypt_iv(bytea, bytea, bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_encrypt_iv';


--
-- Name: gen_random_bytes(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION gen_random_bytes(integer) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pg_random_bytes';


--
-- Name: gen_salt(text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION gen_salt(text) RETURNS text
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pg_gen_salt';


--
-- Name: gen_salt(text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION gen_salt(text, integer) RETURNS text
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pg_gen_salt_rounds';


--
-- Name: hmac(bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION hmac(bytea, bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_hmac';


--
-- Name: hmac(text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION hmac(text, text, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pg_hmac';


--
-- Name: pgp_key_id(bytea); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION pgp_key_id(bytea) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_key_id_w';


--
-- Name: pgp_pub_decrypt(bytea, bytea); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION pgp_pub_decrypt(bytea, bytea) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_decrypt_text';


--
-- Name: pgp_pub_decrypt(bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION pgp_pub_decrypt(bytea, bytea, text) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_decrypt_text';


--
-- Name: pgp_pub_decrypt(bytea, bytea, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION pgp_pub_decrypt(bytea, bytea, text, text) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_decrypt_text';


--
-- Name: pgp_pub_decrypt_bytea(bytea, bytea); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION pgp_pub_decrypt_bytea(bytea, bytea) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_decrypt_bytea';


--
-- Name: pgp_pub_decrypt_bytea(bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_decrypt_bytea';


--
-- Name: pgp_pub_decrypt_bytea(bytea, bytea, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_decrypt_bytea';


--
-- Name: pgp_pub_encrypt(text, bytea); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION pgp_pub_encrypt(text, bytea) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_encrypt_text';


--
-- Name: pgp_pub_encrypt(text, bytea, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION pgp_pub_encrypt(text, bytea, text) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_encrypt_text';


--
-- Name: pgp_pub_encrypt_bytea(bytea, bytea); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION pgp_pub_encrypt_bytea(bytea, bytea) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_encrypt_bytea';


--
-- Name: pgp_pub_encrypt_bytea(bytea, bytea, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_pub_encrypt_bytea';


--
-- Name: pgp_sym_decrypt(bytea, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION pgp_sym_decrypt(bytea, text) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_decrypt_text';


--
-- Name: pgp_sym_decrypt(bytea, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION pgp_sym_decrypt(bytea, text, text) RETURNS text
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_decrypt_text';


--
-- Name: pgp_sym_decrypt_bytea(bytea, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION pgp_sym_decrypt_bytea(bytea, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_decrypt_bytea';


--
-- Name: pgp_sym_decrypt_bytea(bytea, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION pgp_sym_decrypt_bytea(bytea, text, text) RETURNS bytea
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_decrypt_bytea';


--
-- Name: pgp_sym_encrypt(text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION pgp_sym_encrypt(text, text) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_encrypt_text';


--
-- Name: pgp_sym_encrypt(text, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION pgp_sym_encrypt(text, text, text) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_encrypt_text';


--
-- Name: pgp_sym_encrypt_bytea(bytea, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION pgp_sym_encrypt_bytea(bytea, text) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_encrypt_bytea';


--
-- Name: pgp_sym_encrypt_bytea(bytea, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION pgp_sym_encrypt_bytea(bytea, text, text) RETURNS bytea
    LANGUAGE c STRICT
    AS '$libdir/pgcrypto', 'pgp_sym_encrypt_bytea';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: accesslog; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE accesslog (
    _id integer NOT NULL,
    accessfrom text,
    accessuname text,
    accesspass text,
    accessdate text,
    accessuri text
);


--
-- Name: accesslog__id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE accesslog__id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: accesslog__id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE accesslog__id_seq OWNED BY accesslog._id;


--
-- Name: assessment_questions; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE assessment_questions (
    event text NOT NULL,
    question character varying(40) NOT NULL,
    max_points integer,
    description text,
    filepath text,
    category character(1) DEFAULT '1'::bpchar
);


--
-- Name: assessment_scores; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE assessment_scores (
    event text NOT NULL,
    question character varying(40) NOT NULL,
    score numeric(3,1),
    operator character varying(3),
    update_ts timestamp without time zone DEFAULT now(),
    remark text,
    stick_event_repo_id integer
);


--
-- Name: assessment_final_score3; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW assessment_final_score3 AS
 SELECT q.event,
    s.stick_event_repo_id,
    q.category,
    sum((s.score * (q.max_points)::numeric)) AS weighted_sum
   FROM (assessment_questions q
     JOIN assessment_scores s USING (event, question))
  GROUP BY q.event, s.stick_event_repo_id, q.category;


--
-- Name: assessment_weight_sum; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW assessment_weight_sum AS
 SELECT assessment_questions.event,
    assessment_questions.category,
    sum(assessment_questions.max_points) AS weight_sum
   FROM assessment_questions
  GROUP BY assessment_questions.event, assessment_questions.category;


--
-- Name: assement_category_final_score; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW assement_category_final_score AS
 SELECT assessment_final_score3.event,
    assessment_final_score3.category,
    assessment_final_score3.stick_event_repo_id,
    (assessment_final_score3.weighted_sum / (assessment_weight_sum.weight_sum)::numeric) AS final
   FROM (assessment_final_score3
     JOIN assessment_weight_sum USING (event, category));


--
-- Name: assessment_events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE assessment_events (
    event text NOT NULL,
    description text,
    compensation_points integer DEFAULT 0,
    compensation_reason character varying(250)
);


--
-- Name: assessment_scores_temp; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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


--
-- Name: assessment_student; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE assessment_student (
    snummer integer,
    username text,
    password text,
    uid integer,
    gid integer,
    achternaam character varying(40),
    roepnaam character varying(20),
    voorvoegsel character varying(10),
    opl character(4),
    cohort smallint,
    email1 text,
    pcn integer,
    sclass character(10),
    lang character(2),
    hoofdgrp text
);


--
-- Name: available_event; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE available_event (
    _id integer NOT NULL,
    event text NOT NULL,
    event_date date DEFAULT (now())::date,
    active boolean DEFAULT false
);


--
-- Name: available_event__id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE available_event__id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: available_event__id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE available_event__id_seq OWNED BY available_event._id;


--
-- Name: candidate_repos_table; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE candidate_repos_table (
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


--
-- Name: candidate_repos__id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE candidate_repos__id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: candidate_repos__id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE candidate_repos__id_seq OWNED BY candidate_repos_table._id;


--
-- Name: candidate_repos_table_backup; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE candidate_repos_table_backup (
    _id integer,
    event text,
    username character varying(10),
    password character varying(64),
    active boolean,
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


--
-- Name: candidate_stick; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE candidate_stick (
    stick_event_repo_id bigint,
    snummer integer
);


--
-- Name: tutor_pw; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE tutor_pw (
    username character varying(10) NOT NULL,
    password character varying(64)
);


--
-- Name: doc_users; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW doc_users AS
 SELECT tutor_pw.username,
    tutor_pw.password,
    'tutor'::text AS event
   FROM tutor_pw
UNION
 SELECT candidate_repos_table.username,
    candidate_repos_table.password,
    candidate_repos_table.event
   FROM candidate_repos_table;


--
-- Name: et_calls; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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


--
-- Name: et_calls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE et_calls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: et_calls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE et_calls_id_seq OWNED BY et_calls.id;


--
-- Name: event; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE event (
    event text,
    event_date date,
    active boolean DEFAULT true
);


--
-- Name: event_candidate; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE event_candidate (
    event text,
    snummer integer,
    username character varying(10),
    lastname text,
    firstname text,
    tussenvoegsel text,
    ou character varying(10),
    cohort integer,
    email text,
    pcn integer,
    sclass character varying(10)
);


--
-- Name: event_password; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE event_password (
    _id integer NOT NULL,
    event text NOT NULL,
    snummer integer,
    password character varying(64)
);


--
-- Name: event_password__id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE event_password__id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: event_password__id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE event_password__id_seq OWNED BY event_password._id;


--
-- Name: exam_systems; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE exam_systems (
    id integer NOT NULL,
    mac_address macaddr,
    payload text,
    payloadsum text,
    entry_time timestamp without time zone DEFAULT now()
);


--
-- Name: exam_systems_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE exam_systems_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exam_systems_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE exam_systems_id_seq OWNED BY exam_systems.id;


--
-- Name: fake_mail_address; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE fake_mail_address (
    email1 text
);


--
-- Name: present; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE present (
    event text,
    snummer integer NOT NULL
);


--
-- Name: qr; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE qr (
    question_remark_id integer,
    event text,
    question character varying(40),
    remark text
);


--
-- Name: question_remark; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE question_remark (
    question_remark_id integer NOT NULL,
    event text NOT NULL,
    question character varying(40) NOT NULL,
    remark text
);


--
-- Name: question_remark_question_remark_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE question_remark_question_remark_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: question_remark_question_remark_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE question_remark_question_remark_id_seq OWNED BY question_remark.question_remark_id;


--
-- Name: stick_event_repo; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE stick_event_repo (
    stick_event_repo_id bigint NOT NULL,
    event text NOT NULL,
    stick_nr integer
);


--
-- Name: stick_event_repo_stick_event_repo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE stick_event_repo_stick_event_repo_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: stick_event_repo_stick_event_repo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE stick_event_repo_stick_event_repo_id_seq OWNED BY stick_event_repo.stick_event_repo_id;


--
-- Name: stick_grade_sum; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW stick_grade_sum AS
 SELECT sum((assessment_scores.score * (assessment_questions.max_points)::numeric)) AS summed_score,
    assessment_scores.stick_event_repo_id
   FROM (assessment_scores
     JOIN assessment_questions USING (event, question))
  GROUP BY assessment_scores.stick_event_repo_id;


--
-- Name: sticks; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE sticks (
    sticknr smallint NOT NULL,
    since date DEFAULT (now())::date
);


--
-- Name: student; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE student (
    snummer integer NOT NULL,
    username text,
    password text,
    uid integer,
    gid integer,
    achternaam character varying(40),
    roepnaam character varying(20),
    voorvoegsel character varying(10),
    opl character(4),
    cohort smallint,
    email1 text,
    pcn integer,
    sclass character(10),
    lang character(2),
    hoofdgrp text
);


--
-- Name: svn_users; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW svn_users AS
 SELECT tutor_pw.username,
    tutor_pw.password,
    'tutor'::text AS event
   FROM tutor_pw
UNION
 SELECT candidate_repos_table.username,
    candidate_repos_table.password,
    candidate_repos_table.event
   FROM candidate_repos_table
  WHERE (candidate_repos_table.active = true);


--
-- Name: temp_assessment_scores; Type: TABLE; Schema: public; Owner: -; Tablespace: 
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


--
-- Name: _id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY accesslog ALTER COLUMN _id SET DEFAULT nextval('accesslog__id_seq'::regclass);


--
-- Name: _id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY available_event ALTER COLUMN _id SET DEFAULT nextval('available_event__id_seq'::regclass);


--
-- Name: _id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY candidate_repos_table ALTER COLUMN _id SET DEFAULT nextval('candidate_repos__id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY et_calls ALTER COLUMN id SET DEFAULT nextval('et_calls_id_seq'::regclass);


--
-- Name: _id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY event_password ALTER COLUMN _id SET DEFAULT nextval('event_password__id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY exam_systems ALTER COLUMN id SET DEFAULT nextval('exam_systems_id_seq'::regclass);


--
-- Name: question_remark_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_remark ALTER COLUMN question_remark_id SET DEFAULT nextval('question_remark_question_remark_id_seq'::regclass);


--
-- Name: stick_event_repo_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY stick_event_repo ALTER COLUMN stick_event_repo_id SET DEFAULT nextval('stick_event_repo_stick_event_repo_id_seq'::regclass);


--
-- Name: assessment_questions_pk; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY assessment_questions
    ADD CONSTRAINT assessment_questions_pk PRIMARY KEY (event, question);


--
-- Name: available_event_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY available_event
    ADD CONSTRAINT available_event_pkey PRIMARY KEY (event);


--
-- Name: candidate_repos_event_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY candidate_repos_table
    ADD CONSTRAINT candidate_repos_event_key UNIQUE (event, username);


--
-- Name: candidate_repos_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY candidate_repos_table
    ADD CONSTRAINT candidate_repos_pkey PRIMARY KEY (_id);


--
-- Name: candidate_repos_reposroot_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY candidate_repos_table
    ADD CONSTRAINT candidate_repos_reposroot_key UNIQUE (reposroot);


--
-- Name: candidate_repos_reposuri_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY candidate_repos_table
    ADD CONSTRAINT candidate_repos_reposuri_key UNIQUE (reposuri);


--
-- Name: candidate_stick_stick_event_repo_id_snummer_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY candidate_stick
    ADD CONSTRAINT candidate_stick_stick_event_repo_id_snummer_key UNIQUE (stick_event_repo_id, snummer);


--
-- Name: eqstick_un; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY assessment_scores
    ADD CONSTRAINT eqstick_un UNIQUE (event, question, stick_event_repo_id);


--
-- Name: et_calls_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY et_calls
    ADD CONSTRAINT et_calls_pkey PRIMARY KEY (id);


--
-- Name: event_password_event_snummer_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY event_password
    ADD CONSTRAINT event_password_event_snummer_key UNIQUE (event, snummer);


--
-- Name: event_password_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY event_password
    ADD CONSTRAINT event_password_pkey PRIMARY KEY (_id);


--
-- Name: event_pk; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY assessment_events
    ADD CONSTRAINT event_pk PRIMARY KEY (event);


--
-- Name: macaddr_payloadsum_un; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY exam_systems
    ADD CONSTRAINT macaddr_payloadsum_un UNIQUE (mac_address, payloadsum);


--
-- Name: question_remark_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY question_remark
    ADD CONSTRAINT question_remark_pkey PRIMARY KEY (question_remark_id);


--
-- Name: stick_event_repo_event_stick_nr_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY stick_event_repo
    ADD CONSTRAINT stick_event_repo_event_stick_nr_key UNIQUE (event, stick_nr);


--
-- Name: stick_event_repo_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY stick_event_repo
    ADD CONSTRAINT stick_event_repo_pkey PRIMARY KEY (stick_event_repo_id);


--
-- Name: sticks_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY sticks
    ADD CONSTRAINT sticks_pkey PRIMARY KEY (sticknr);


--
-- Name: student_pk; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY student
    ADD CONSTRAINT student_pk PRIMARY KEY (snummer);


--
-- Name: tutor_pw_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY tutor_pw
    ADD CONSTRAINT tutor_pw_pkey PRIMARY KEY (username);


--
-- Name: assessment_questions_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY assessment_questions
    ADD CONSTRAINT assessment_questions_fk FOREIGN KEY (event) REFERENCES assessment_events(event) ON DELETE CASCADE;


--
-- Name: assessment_scores_stick_event_repo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY assessment_scores
    ADD CONSTRAINT assessment_scores_stick_event_repo_id_fkey FOREIGN KEY (stick_event_repo_id) REFERENCES stick_event_repo(stick_event_repo_id) ON DELETE CASCADE;


--
-- Name: candidate_repos_sticknr_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY candidate_repos_table
    ADD CONSTRAINT candidate_repos_sticknr_fkey FOREIGN KEY (sticknr) REFERENCES sticks(sticknr);


--
-- Name: candidate_stick_stick_event_repo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY candidate_stick
    ADD CONSTRAINT candidate_stick_stick_event_repo_id_fkey FOREIGN KEY (stick_event_repo_id) REFERENCES stick_event_repo(stick_event_repo_id) ON DELETE CASCADE;


--
-- Name: event_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY assessment_scores
    ADD CONSTRAINT event_fk FOREIGN KEY (event) REFERENCES assessment_events(event) ON DELETE CASCADE;


--
-- Name: event_question; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY assessment_scores
    ADD CONSTRAINT event_question FOREIGN KEY (event, question) REFERENCES assessment_questions(event, question) ON UPDATE CASCADE;


--
-- Name: present_event_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY present
    ADD CONSTRAINT present_event_fkey FOREIGN KEY (event) REFERENCES available_event(event);


--
-- Name: question_remark_event_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY question_remark
    ADD CONSTRAINT question_remark_event_fk FOREIGN KEY (event, question) REFERENCES assessment_questions(event, question) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: public; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: accesslog; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE accesslog FROM PUBLIC;
REVOKE ALL ON TABLE accesslog FROM hom;
GRANT ALL ON TABLE accesslog TO hom;
GRANT ALL ON TABLE accesslog TO wwwrun;
GRANT ALL ON TABLE accesslog TO hvd;


--
-- Name: assessment_questions; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE assessment_questions FROM PUBLIC;
REVOKE ALL ON TABLE assessment_questions FROM hom;
GRANT ALL ON TABLE assessment_questions TO hom;
GRANT ALL ON TABLE assessment_questions TO hvd;
GRANT ALL ON TABLE assessment_questions TO wwwrun;


--
-- Name: assessment_scores; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE assessment_scores FROM PUBLIC;
REVOKE ALL ON TABLE assessment_scores FROM hom;
GRANT ALL ON TABLE assessment_scores TO hom;
GRANT ALL ON TABLE assessment_scores TO hvd;
GRANT ALL ON TABLE assessment_scores TO wwwrun;


--
-- Name: assessment_final_score3; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE assessment_final_score3 FROM PUBLIC;
REVOKE ALL ON TABLE assessment_final_score3 FROM hom;
GRANT ALL ON TABLE assessment_final_score3 TO hom;
GRANT ALL ON TABLE assessment_final_score3 TO wwwrun;


--
-- Name: assessment_weight_sum; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE assessment_weight_sum FROM PUBLIC;
REVOKE ALL ON TABLE assessment_weight_sum FROM hom;
GRANT ALL ON TABLE assessment_weight_sum TO hom;
GRANT SELECT,REFERENCES ON TABLE assessment_weight_sum TO wwwrun;


--
-- Name: assement_category_final_score; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE assement_category_final_score FROM PUBLIC;
REVOKE ALL ON TABLE assement_category_final_score FROM hom;
GRANT ALL ON TABLE assement_category_final_score TO hom;
GRANT SELECT,REFERENCES ON TABLE assement_category_final_score TO wwwrun;


--
-- Name: assessment_events; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE assessment_events FROM PUBLIC;
REVOKE ALL ON TABLE assessment_events FROM hom;
GRANT ALL ON TABLE assessment_events TO hom;
GRANT ALL ON TABLE assessment_events TO hvd;
GRANT ALL ON TABLE assessment_events TO wwwrun;


--
-- Name: assessment_scores_temp; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE assessment_scores_temp FROM PUBLIC;
REVOKE ALL ON TABLE assessment_scores_temp FROM hom;
GRANT ALL ON TABLE assessment_scores_temp TO hom;
GRANT SELECT,REFERENCES ON TABLE assessment_scores_temp TO wwwrun;


--
-- Name: assessment_student; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE assessment_student FROM PUBLIC;
REVOKE ALL ON TABLE assessment_student FROM hom;
GRANT ALL ON TABLE assessment_student TO hom;
GRANT SELECT,REFERENCES ON TABLE assessment_student TO wwwrun;


--
-- Name: available_event; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE available_event FROM PUBLIC;
REVOKE ALL ON TABLE available_event FROM hom;
GRANT ALL ON TABLE available_event TO hom;
GRANT SELECT,REFERENCES ON TABLE available_event TO wwwrun;


--
-- Name: candidate_repos_table; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE candidate_repos_table FROM PUBLIC;
REVOKE ALL ON TABLE candidate_repos_table FROM hom;
GRANT ALL ON TABLE candidate_repos_table TO hom;
GRANT ALL ON TABLE candidate_repos_table TO wwwrun;
GRANT ALL ON TABLE candidate_repos_table TO hvd;


--
-- Name: candidate_repos_table_backup; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE candidate_repos_table_backup FROM PUBLIC;
REVOKE ALL ON TABLE candidate_repos_table_backup FROM hom;
GRANT ALL ON TABLE candidate_repos_table_backup TO hom;
GRANT SELECT,REFERENCES ON TABLE candidate_repos_table_backup TO wwwrun;


--
-- Name: candidate_stick; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE candidate_stick FROM PUBLIC;
REVOKE ALL ON TABLE candidate_stick FROM hom;
GRANT ALL ON TABLE candidate_stick TO hom;
GRANT ALL ON TABLE candidate_stick TO wwwrun;


--
-- Name: tutor_pw; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE tutor_pw FROM PUBLIC;
REVOKE ALL ON TABLE tutor_pw FROM hom;
GRANT ALL ON TABLE tutor_pw TO hom;
GRANT ALL ON TABLE tutor_pw TO wwwrun;
GRANT ALL ON TABLE tutor_pw TO hvd;


--
-- Name: doc_users; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE doc_users FROM PUBLIC;
REVOKE ALL ON TABLE doc_users FROM hom;
GRANT ALL ON TABLE doc_users TO hom;
GRANT ALL ON TABLE doc_users TO wwwrun;
GRANT ALL ON TABLE doc_users TO hvd;


--
-- Name: et_calls; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE et_calls FROM PUBLIC;
REVOKE ALL ON TABLE et_calls FROM hom;
GRANT ALL ON TABLE et_calls TO hom;
GRANT ALL ON TABLE et_calls TO wwwrun;


--
-- Name: et_calls_id_seq; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON SEQUENCE et_calls_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE et_calls_id_seq FROM hom;
GRANT ALL ON SEQUENCE et_calls_id_seq TO hom;
GRANT ALL ON SEQUENCE et_calls_id_seq TO wwwrun;


--
-- Name: event; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE event FROM PUBLIC;
REVOKE ALL ON TABLE event FROM hom;
GRANT ALL ON TABLE event TO hom;
GRANT ALL ON TABLE event TO wwwrun;


--
-- Name: event_candidate; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE event_candidate FROM PUBLIC;
REVOKE ALL ON TABLE event_candidate FROM hom;
GRANT ALL ON TABLE event_candidate TO hom;
GRANT SELECT,REFERENCES ON TABLE event_candidate TO wwwrun;


--
-- Name: event_password; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE event_password FROM PUBLIC;
REVOKE ALL ON TABLE event_password FROM hom;
GRANT ALL ON TABLE event_password TO hom;
GRANT SELECT,REFERENCES ON TABLE event_password TO wwwrun;


--
-- Name: exam_systems; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE exam_systems FROM PUBLIC;
REVOKE ALL ON TABLE exam_systems FROM hom;
GRANT ALL ON TABLE exam_systems TO hom;
GRANT SELECT,INSERT,REFERENCES ON TABLE exam_systems TO wwwrun;


--
-- Name: exam_systems_id_seq; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON SEQUENCE exam_systems_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE exam_systems_id_seq FROM hom;
GRANT ALL ON SEQUENCE exam_systems_id_seq TO hom;
GRANT ALL ON SEQUENCE exam_systems_id_seq TO wwwrun;


--
-- Name: fake_mail_address; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE fake_mail_address FROM PUBLIC;
REVOKE ALL ON TABLE fake_mail_address FROM hom;
GRANT ALL ON TABLE fake_mail_address TO hom;
GRANT SELECT,REFERENCES ON TABLE fake_mail_address TO wwwrun;


--
-- Name: present; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE present FROM PUBLIC;
REVOKE ALL ON TABLE present FROM hom;
GRANT ALL ON TABLE present TO hom;
GRANT ALL ON TABLE present TO wwwrun;


--
-- Name: qr; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE qr FROM PUBLIC;
REVOKE ALL ON TABLE qr FROM hom;
GRANT ALL ON TABLE qr TO hom;
GRANT SELECT,REFERENCES ON TABLE qr TO wwwrun;


--
-- Name: question_remark; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE question_remark FROM PUBLIC;
REVOKE ALL ON TABLE question_remark FROM hom;
GRANT ALL ON TABLE question_remark TO hom;
GRANT SELECT,INSERT,REFERENCES,UPDATE ON TABLE question_remark TO wwwrun;


--
-- Name: question_remark_question_remark_id_seq; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON SEQUENCE question_remark_question_remark_id_seq FROM PUBLIC;
REVOKE ALL ON SEQUENCE question_remark_question_remark_id_seq FROM hom;
GRANT ALL ON SEQUENCE question_remark_question_remark_id_seq TO hom;
GRANT ALL ON SEQUENCE question_remark_question_remark_id_seq TO wwwrun;


--
-- Name: stick_event_repo; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE stick_event_repo FROM PUBLIC;
REVOKE ALL ON TABLE stick_event_repo FROM hom;
GRANT ALL ON TABLE stick_event_repo TO hom;
GRANT ALL ON TABLE stick_event_repo TO wwwrun;


--
-- Name: stick_grade_sum; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE stick_grade_sum FROM PUBLIC;
REVOKE ALL ON TABLE stick_grade_sum FROM hom;
GRANT ALL ON TABLE stick_grade_sum TO hom;
GRANT SELECT,REFERENCES ON TABLE stick_grade_sum TO wwwrun;


--
-- Name: sticks; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE sticks FROM PUBLIC;
REVOKE ALL ON TABLE sticks FROM hom;
GRANT ALL ON TABLE sticks TO hom;
GRANT SELECT,REFERENCES ON TABLE sticks TO wwwrun;


--
-- Name: student; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE student FROM PUBLIC;
REVOKE ALL ON TABLE student FROM hom;
GRANT ALL ON TABLE student TO hom;
GRANT ALL ON TABLE student TO wwwrun;


--
-- Name: svn_users; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE svn_users FROM PUBLIC;
REVOKE ALL ON TABLE svn_users FROM hom;
GRANT ALL ON TABLE svn_users TO hom;
GRANT ALL ON TABLE svn_users TO wwwrun;
GRANT ALL ON TABLE svn_users TO hvd;


--
-- Name: temp_assessment_scores; Type: ACL; Schema: public; Owner: -
--

REVOKE ALL ON TABLE temp_assessment_scores FROM PUBLIC;
REVOKE ALL ON TABLE temp_assessment_scores FROM hom;
GRANT ALL ON TABLE temp_assessment_scores TO hom;
GRANT SELECT,REFERENCES ON TABLE temp_assessment_scores TO wwwrun;


--
-- PostgreSQL database dump complete
--

