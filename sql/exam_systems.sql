--
-- PostgreSQL database dump
--
begin work;
drop table if exists exam_systems;
SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

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
-- Name: id; Type: DEFAULT; Schema: public; Owner: hom
--

ALTER TABLE ONLY exam_systems ALTER COLUMN id SET DEFAULT nextval('exam_systems_id_seq'::regclass);


--
-- Name: macaddr_payloadsum_un; Type: CONSTRAINT; Schema: public; Owner: hom; Tablespace: 
--

ALTER TABLE ONLY exam_systems
    ADD CONSTRAINT macaddr_payloadsum_un UNIQUE (mac_address, payloadsum);


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
-- PostgreSQL database dump complete
--

commit;