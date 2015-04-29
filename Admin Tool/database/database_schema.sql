--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

DROP RULE syncdata_update_rule ON public.data;
DROP RULE syncdata_rule ON public.data;
DROP RULE syncdata_media_rule ON public.media;
DROP INDEX public.syncdata_deviceid_idx;
ALTER TABLE ONLY public.users DROP CONSTRAINT users_pkey;
ALTER TABLE ONLY public.users DROP CONSTRAINT users_email_key;
ALTER TABLE ONLY public.media DROP CONSTRAINT media_pkey;
ALTER TABLE ONLY public.data DROP CONSTRAINT data_pkey;
DROP TABLE public.users;
DROP TABLE public.sync_data;
DROP TABLE public.media;
DROP TABLE public.devices;
DROP TABLE public.data;
DROP FUNCTION public.login(_username text, _pwd text, OUT _email text);
DROP FUNCTION public.bytea_import(p_path text, OUT p_result bytea);
DROP EXTENSION pgcrypto;
DROP EXTENSION plpgsql;
DROP SCHEMA public;
--
-- Name: public; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO postgres;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: postgres
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET search_path = public, pg_catalog;

--
-- Name: bytea_import(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION bytea_import(p_path text, OUT p_result bytea) RETURNS bytea
    LANGUAGE plpgsql
    AS $$
declare
  l_oid oid;
  r record;
begin
  p_result := '';
  select lo_import(p_path) into l_oid;
  for r in ( select data 
             from pg_largeobject 
             where loid = l_oid 
             order by pageno ) loop
    p_result = p_result || r.data;
  end loop;
  perform lo_unlink(l_oid);
end;$$;


ALTER FUNCTION public.bytea_import(p_path text, OUT p_result bytea) OWNER TO postgres;

--
-- Name: login(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION login(_username text, _pwd text, OUT _email text) RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
 SELECT email INTO _email FROM users
 WHERE users.username = lower(_username)
 AND pwdhash = crypt(_pwd, users.pwdhash);
END;
$$;


ALTER FUNCTION public.login(_username text, _pwd text, OUT _email text) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: data; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE data (
    id character varying(64) NOT NULL,
    name character varying(64) NOT NULL,
    value character varying(65536) NOT NULL,
    createdate timestamp without time zone NOT NULL,
    modifieddate timestamp without time zone NOT NULL,
    modifiedby character varying(64) NOT NULL
);


ALTER TABLE public.data OWNER TO postgres;

--
-- Name: devices; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE devices (
    deviceid character varying(64) NOT NULL
);


ALTER TABLE public.devices OWNER TO postgres;

--
-- Name: media; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE media (
    filename character varying(64) NOT NULL,
    data bytea NOT NULL,
    modifiedby character varying(64)
);


ALTER TABLE public.media OWNER TO postgres;

--
-- Name: sync_data; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE sync_data (
    id character varying(64) NOT NULL,
    deviceid character varying(64) NOT NULL,
    type character varying(64) NOT NULL
);


ALTER TABLE public.sync_data OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE users (
    username text NOT NULL,
    email character varying(90) NOT NULL,
    pwdhash text NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY data
    ADD CONSTRAINT data_pkey PRIMARY KEY (id);


--
-- Name: media_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY media
    ADD CONSTRAINT media_pkey PRIMARY KEY (filename);


--
-- Name: users_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_email_key UNIQUE (email);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (username);


--
-- Name: syncdata_deviceid_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX syncdata_deviceid_idx ON sync_data USING btree (deviceid);


--
-- Name: syncdata_media_rule; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE syncdata_media_rule AS ON INSERT TO media DO INSERT INTO sync_data (id, deviceid, type) SELECT new.filename, devices.deviceid, 'media' FROM devices WHERE ((devices.deviceid)::text <> (new.modifiedby)::text);


--
-- Name: syncdata_rule; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE syncdata_rule AS ON INSERT TO data DO INSERT INTO sync_data (id, deviceid, type) SELECT new.id, devices.deviceid, 'object' FROM devices WHERE ((devices.deviceid)::text <> (new.modifiedby)::text);


--
-- Name: syncdata_update_rule; Type: RULE; Schema: public; Owner: postgres
--

CREATE RULE syncdata_update_rule AS ON UPDATE TO data DO INSERT INTO sync_data (id, deviceid, type) SELECT new.id, devices.deviceid, 'object' FROM devices WHERE ((devices.deviceid)::text <> (new.modifiedby)::text);


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: users; Type: ACL; Schema: public; Owner: postgres
--

REVOKE ALL ON TABLE users FROM PUBLIC;
REVOKE ALL ON TABLE users FROM postgres;


--
-- PostgreSQL database dump complete
--

