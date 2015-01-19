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
ALTER TABLE ONLY public.media DROP CONSTRAINT media_pkey;
ALTER TABLE ONLY public.data DROP CONSTRAINT data_pkey;
DROP TABLE public.sync_data;
DROP TABLE public.media;
DROP TABLE public.devices;
DROP TABLE public.data;
DROP FUNCTION public.bytea_import(p_path text, OUT p_result bytea);
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
-- PostgreSQL database dump complete
--

