--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

ALTER TABLE ONLY public.user_lock DROP CONSTRAINT user_user_lock_fk;
ALTER TABLE ONLY public.food_product_record DROP CONSTRAINT user_food_product_record_fk;
ALTER TABLE ONLY public.food_product DROP CONSTRAINT origin_food_product_fk;
ALTER TABLE ONLY public.food_product DROP CONSTRAINT nasa_user_food_product_fk;
ALTER TABLE ONLY public.food_product_filter DROP CONSTRAINT nasa_user_food_product_filter_fk;
ALTER TABLE ONLY public.nasa_user DROP CONSTRAINT media_nasa_user_fk;
ALTER TABLE ONLY public.media_record DROP CONSTRAINT media_media_record_fk;
ALTER TABLE ONLY public.food_product DROP CONSTRAINT media_food_product_fk;
ALTER TABLE ONLY public.media_record DROP CONSTRAINT food_product_record_media_record_fk;
ALTER TABLE ONLY public.food_product_record DROP CONSTRAINT food_product_food_product_record_fk;
ALTER TABLE ONLY public.user_lock DROP CONSTRAINT devices_user_lock_fk;
DROP INDEX public.user_full_name_key;
DROP INDEX public.origin_value_key;
DROP INDEX public.food_product_name_origin_idx;
DROP INDEX public.category_value_key;
ALTER TABLE ONLY public.user_tmp_table DROP CONSTRAINT user_tmp_table_pkey;
ALTER TABLE ONLY public.user_lock DROP CONSTRAINT user_lock_pkey;
ALTER TABLE ONLY public.origin DROP CONSTRAINT origin_pkey;
ALTER TABLE ONLY public.nasa_user DROP CONSTRAINT nasa_user_pkey;
ALTER TABLE ONLY public.nasa_user DROP CONSTRAINT nasa_user_full_name_key;
ALTER TABLE ONLY public.media_record DROP CONSTRAINT media_record_pkey;
ALTER TABLE ONLY public.media DROP CONSTRAINT media_pkey;
ALTER TABLE ONLY public.food_tmp_table DROP CONSTRAINT food_tmp_table_pkey;
ALTER TABLE ONLY public.food_product_record DROP CONSTRAINT food_product_record_pkey;
ALTER TABLE ONLY public.food_product DROP CONSTRAINT food_product_pkey;
ALTER TABLE ONLY public.food_product_filter DROP CONSTRAINT food_product_filter_pkey;
ALTER TABLE ONLY public.devices DROP CONSTRAINT devices_pkey;
ALTER TABLE ONLY public.category DROP CONSTRAINT category_pkey;
ALTER TABLE public.user_tmp_table ALTER COLUMN id DROP DEFAULT;
ALTER TABLE public.food_tmp_table ALTER COLUMN id DROP DEFAULT;
DROP SEQUENCE public.user_tmp_table_id_seq;
DROP TABLE public.user_tmp_table;
DROP TABLE public.user_lock;
DROP VIEW public.summary_view;
DROP TABLE public.nasa_user;
DROP TABLE public.media_record;
DROP TABLE public.media;
DROP VIEW public.food_tmp_view;
DROP TABLE public.origin;
DROP SEQUENCE public.food_tmp_table_id_seq;
DROP TABLE public.food_tmp_table;
DROP TABLE public.food_product_record;
DROP TABLE public.food_product_filter;
DROP TABLE public.food_product;
DROP TABLE public.devices;
DROP TABLE public.category;
DROP FUNCTION public.trim_array(in_array text[]);
DROP FUNCTION public.normalize(input text);
DROP FUNCTION public.login(_username text, _pwd text, OUT _email text);
DROP EXTENSION "uuid-ossp";
DROP EXTENSION pgcrypto;
DROP EXTENSION plpgsql;
DROP SCHEMA public;
--
-- Name: public; Type: SCHEMA; Schema: -; Owner: pl_fit_db
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pl_fit_db;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pl_fit_db
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


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = public, pg_catalog;

--
-- Name: login(text, text); Type: FUNCTION; Schema: public; Owner: pl_fit_db
--

CREATE FUNCTION login(_username text, _pwd text, OUT _email text) RETURNS text
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
 SELECT email INTO _email FROM public.users
 WHERE users.username = lower(_username)
 AND pwdhash = crypt(_pwd, users.pwdhash);
END;
$$;


ALTER FUNCTION public.login(_username text, _pwd text, OUT _email text) OWNER TO pl_fit_db;

--
-- Name: normalize(text); Type: FUNCTION; Schema: public; Owner: pl_fit_db
--

CREATE FUNCTION normalize(input text) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$SELECT regexp_replace(lower(regexp_replace(regexp_replace(input, 'w/', 'with','gi'), '&', 'and', 'g')), '\s+', '', 'g') 
$$;


ALTER FUNCTION public.normalize(input text) OWNER TO pl_fit_db;

--
-- Name: trim_array(text[]); Type: FUNCTION; Schema: public; Owner: pl_fit_db
--

CREATE FUNCTION trim_array(in_array text[]) RETURNS text[]
    LANGUAGE plpgsql STABLE STRICT
    AS $$
DECLARE
    r TEXT[];
BEGIN
    FOR i IN array_lower(in_array, 1) .. array_upper(in_array, 1) LOOP
        r[i]:=TRIM(in_array[i]);
    END LOOP;
RETURN r;
END;
$$;


ALTER FUNCTION public.trim_array(in_array text[]) OWNER TO pl_fit_db;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: category; Type: TABLE; Schema: public; Owner: pl_fit_db; Tablespace: 
--

CREATE TABLE category (
    uuid character varying(36) NOT NULL,
    value text NOT NULL
);


ALTER TABLE public.category OWNER TO pl_fit_db;

--
-- Name: devices; Type: TABLE; Schema: public; Owner: pl_fit_db; Tablespace: 
--

CREATE TABLE devices (
    uuid character varying(36) NOT NULL,
    device_uuid character varying(64) NOT NULL
);


ALTER TABLE public.devices OWNER TO pl_fit_db;

--
-- Name: food_product; Type: TABLE; Schema: public; Owner: pl_fit_db; Tablespace: 
--

CREATE TABLE food_product (
    uuid character varying(36) NOT NULL,
    active boolean DEFAULT true,
    barcode character varying(64),
    carb integer NOT NULL,
    energy integer NOT NULL,
    fat integer NOT NULL,
    fluid integer NOT NULL,
    protein integer NOT NULL,
    sodium integer NOT NULL,
    name character varying NOT NULL,
    quantity real DEFAULT 1 NOT NULL,
    user_uuid character varying(36),
    origin_uuid character varying(36),
    image_media_uuid character varying(36),
    category_uuids text,
    removed boolean DEFAULT false NOT NULL,
    synchronized boolean DEFAULT false NOT NULL,
    created_date timestamp with time zone NOT NULL,
    modified_date timestamp with time zone NOT NULL
);


ALTER TABLE public.food_product OWNER TO pl_fit_db;

--
-- Name: food_product_filter; Type: TABLE; Schema: public; Owner: pl_fit_db; Tablespace: 
--

CREATE TABLE food_product_filter (
    uuid character varying(36) NOT NULL,
    name text,
    adhoc_only boolean,
    favorite integer,
    fetch_all boolean,
    sort_option integer,
    user_uuid character varying(36),
    modified_date timestamp with time zone NOT NULL,
    created_date timestamp with time zone NOT NULL,
    synchronized boolean DEFAULT false NOT NULL,
    removed boolean DEFAULT false NOT NULL,
    category_uuids text,
    origin_uuids text
);


ALTER TABLE public.food_product_filter OWNER TO pl_fit_db;

--
-- Name: food_product_record; Type: TABLE; Schema: public; Owner: pl_fit_db; Tablespace: 
--

CREATE TABLE food_product_record (
    uuid character varying(36) NOT NULL,
    carb integer NOT NULL,
    fat integer NOT NULL,
    energy integer NOT NULL,
    protein integer NOT NULL,
    sodium integer NOT NULL,
    fluid integer NOT NULL,
    adhoc_only boolean DEFAULT false NOT NULL,
    quantity real DEFAULT 1 NOT NULL,
    comments text,
    "timestamp" timestamp with time zone NOT NULL,
    food_product_uuid character varying(36) NOT NULL,
    user_uuid character varying(36) NOT NULL,
    removed boolean DEFAULT false NOT NULL,
    synchronized boolean DEFAULT false NOT NULL,
    created_date timestamp with time zone NOT NULL,
    modified_date timestamp with time zone NOT NULL
);


ALTER TABLE public.food_product_record OWNER TO pl_fit_db;

--
-- Name: food_tmp_table; Type: TABLE; Schema: public; Owner: pl_fit_db; Tablespace: 
--

CREATE TABLE food_tmp_table (
    id integer NOT NULL,
    name text NOT NULL,
    categories text NOT NULL,
    origin text NOT NULL,
    barcode text,
    fluid double precision NOT NULL,
    energy double precision NOT NULL,
    sodium double precision NOT NULL,
    protein double precision NOT NULL,
    carb double precision NOT NULL,
    fat double precision NOT NULL,
    image text,
    deleted boolean DEFAULT false NOT NULL,
    version integer
);


ALTER TABLE public.food_tmp_table OWNER TO pl_fit_db;

--
-- Name: food_tmp_table_id_seq; Type: SEQUENCE; Schema: public; Owner: pl_fit_db
--

CREATE SEQUENCE food_tmp_table_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.food_tmp_table_id_seq OWNER TO pl_fit_db;

--
-- Name: food_tmp_table_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pl_fit_db
--

ALTER SEQUENCE food_tmp_table_id_seq OWNED BY food_tmp_table.id;


--
-- Name: origin; Type: TABLE; Schema: public; Owner: pl_fit_db; Tablespace: 
--

CREATE TABLE origin (
    uuid character varying(36) NOT NULL,
    value text NOT NULL
);


ALTER TABLE public.origin OWNER TO pl_fit_db;

--
-- Name: food_tmp_view; Type: VIEW; Schema: public; Owner: pl_fit_db
--

CREATE VIEW food_tmp_view AS
    SELECT f.id, btrim(f.name) AS name, (('['::text || (SELECT string_agg((('"'::text || (category.uuid)::text) || '"'::text), ','::text) AS string_agg FROM category WHERE (category.value = ANY (trim_array(string_to_array(f.categories, ';'::text)))))) || ']'::text) AS categories, (SELECT origin.uuid FROM origin WHERE (btrim(origin.value) = btrim(f.origin))) AS origin, btrim(f.barcode) AS barcode, f.fluid, f.energy, f.sodium, f.protein, f.carb, f.fat, f.deleted AS removed FROM food_tmp_table f;


ALTER TABLE public.food_tmp_view OWNER TO pl_fit_db;

--
-- Name: media; Type: TABLE; Schema: public; Owner: pl_fit_db; Tablespace: 
--

CREATE TABLE media (
    uuid character varying(36) NOT NULL,
    filename text NOT NULL,
    data bytea,
    created_date timestamp with time zone NOT NULL,
    modified_date timestamp with time zone NOT NULL,
    removed boolean DEFAULT false NOT NULL,
    synchronized boolean DEFAULT false NOT NULL
);


ALTER TABLE public.media OWNER TO pl_fit_db;

--
-- Name: media_record; Type: TABLE; Schema: public; Owner: pl_fit_db; Tablespace: 
--

CREATE TABLE media_record (
    uuid character varying(36) NOT NULL,
    media_uuid character varying(36) NOT NULL,
    food_record_uuid character varying(36) NOT NULL
);


ALTER TABLE public.media_record OWNER TO pl_fit_db;

--
-- Name: nasa_user; Type: TABLE; Schema: public; Owner: pl_fit_db; Tablespace: 
--

CREATE TABLE nasa_user (
    uuid character varying(36) NOT NULL,
    admin boolean DEFAULT false NOT NULL,
    carb integer NOT NULL,
    fat integer NOT NULL,
    energy integer NOT NULL,
    protein integer NOT NULL,
    sodium integer NOT NULL,
    fluid integer NOT NULL,
    full_name text NOT NULL,
    packets_per_day integer,
    use_last_filter boolean DEFAULT false NOT NULL,
    weight real NOT NULL,
    image_media_uuid character varying(36),
    removed boolean DEFAULT false NOT NULL,
    synchronized boolean DEFAULT false NOT NULL,
    created_date timestamp with time zone NOT NULL,
    modified_date timestamp with time zone NOT NULL
);


ALTER TABLE public.nasa_user OWNER TO pl_fit_db;

--
-- Name: summary_view; Type: VIEW; Schema: public; Owner: pl_fit_db
--

CREATE VIEW summary_view AS
    SELECT nasa_user.full_name, nasa_user.uuid, food.name, food.carb, food.energy, food.fat, food.fluid, food.protein, food.sodium, sum(record.quantity) AS quantity, record."timestamp", regexp_replace(record.comments, '[\n\r]+'::text, ' '::text, 'g'::text) AS comments, string_agg(((SELECT media.uuid FROM media WHERE (((media.uuid)::text = (media_record.media_uuid)::text) AND (media.filename ~~ '%.aac'::text))))::text, ','::text) AS voicerecordings, string_agg(((SELECT media.uuid FROM media WHERE (((media.uuid)::text = (food.image_media_uuid)::text) AND (media.filename ~~ '%.jpg'::text))))::text, ','::text) AS images FROM food_product food, nasa_user, (food_product_record record LEFT JOIN media_record ON (((media_record.food_record_uuid)::text = (record.uuid)::text))) WHERE ((((record.user_uuid)::text = (nasa_user.uuid)::text) AND ((record.food_product_uuid)::text = (food.uuid)::text)) AND (record.removed = false)) GROUP BY food.name, food.carb, food.energy, food.fat, food.fluid, food.protein, food.sodium, nasa_user.full_name, nasa_user.uuid, record."timestamp", record.comments ORDER BY record."timestamp";


ALTER TABLE public.summary_view OWNER TO pl_fit_db;

--
-- Name: user_lock; Type: TABLE; Schema: public; Owner: pl_fit_db; Tablespace: 
--

CREATE TABLE user_lock (
    uuid character varying(36) NOT NULL,
    device_uuid character varying(36) NOT NULL,
    user_uuid character varying(36) NOT NULL
);


ALTER TABLE public.user_lock OWNER TO pl_fit_db;

--
-- Name: user_tmp_table; Type: TABLE; Schema: public; Owner: pl_fit_db; Tablespace: 
--

CREATE TABLE user_tmp_table (
    id integer NOT NULL,
    full_name text NOT NULL,
    admin boolean DEFAULT false,
    fluid integer NOT NULL,
    energy integer NOT NULL,
    sodium integer NOT NULL,
    protein integer NOT NULL,
    carb integer NOT NULL,
    fat integer NOT NULL,
    packets_per_day integer,
    profile_image text,
    use_last_filter boolean,
    weight double precision NOT NULL
);


ALTER TABLE public.user_tmp_table OWNER TO pl_fit_db;

--
-- Name: user_tmp_table_id_seq; Type: SEQUENCE; Schema: public; Owner: pl_fit_db
--

CREATE SEQUENCE user_tmp_table_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_tmp_table_id_seq OWNER TO pl_fit_db;

--
-- Name: user_tmp_table_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: pl_fit_db
--

ALTER SEQUENCE user_tmp_table_id_seq OWNED BY user_tmp_table.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: pl_fit_db
--

ALTER TABLE ONLY food_tmp_table ALTER COLUMN id SET DEFAULT nextval('food_tmp_table_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: pl_fit_db
--

ALTER TABLE ONLY user_tmp_table ALTER COLUMN id SET DEFAULT nextval('user_tmp_table_id_seq'::regclass);


--
-- Name: category_pkey; Type: CONSTRAINT; Schema: public; Owner: pl_fit_db; Tablespace: 
--

ALTER TABLE ONLY category
    ADD CONSTRAINT category_pkey PRIMARY KEY (uuid);


--
-- Name: devices_pkey; Type: CONSTRAINT; Schema: public; Owner: pl_fit_db; Tablespace: 
--

ALTER TABLE ONLY devices
    ADD CONSTRAINT devices_pkey PRIMARY KEY (uuid);


--
-- Name: food_product_filter_pkey; Type: CONSTRAINT; Schema: public; Owner: pl_fit_db; Tablespace: 
--

ALTER TABLE ONLY food_product_filter
    ADD CONSTRAINT food_product_filter_pkey PRIMARY KEY (uuid);


--
-- Name: food_product_pkey; Type: CONSTRAINT; Schema: public; Owner: pl_fit_db; Tablespace: 
--

ALTER TABLE ONLY food_product
    ADD CONSTRAINT food_product_pkey PRIMARY KEY (uuid);


--
-- Name: food_product_record_pkey; Type: CONSTRAINT; Schema: public; Owner: pl_fit_db; Tablespace: 
--

ALTER TABLE ONLY food_product_record
    ADD CONSTRAINT food_product_record_pkey PRIMARY KEY (uuid);


--
-- Name: food_tmp_table_pkey; Type: CONSTRAINT; Schema: public; Owner: pl_fit_db; Tablespace: 
--

ALTER TABLE ONLY food_tmp_table
    ADD CONSTRAINT food_tmp_table_pkey PRIMARY KEY (id);


--
-- Name: media_pkey; Type: CONSTRAINT; Schema: public; Owner: pl_fit_db; Tablespace: 
--

ALTER TABLE ONLY media
    ADD CONSTRAINT media_pkey PRIMARY KEY (uuid);


--
-- Name: media_record_pkey; Type: CONSTRAINT; Schema: public; Owner: pl_fit_db; Tablespace: 
--

ALTER TABLE ONLY media_record
    ADD CONSTRAINT media_record_pkey PRIMARY KEY (uuid);


--
-- Name: nasa_user_full_name_key; Type: CONSTRAINT; Schema: public; Owner: pl_fit_db; Tablespace: 
--

ALTER TABLE ONLY nasa_user
    ADD CONSTRAINT nasa_user_full_name_key UNIQUE (full_name);


--
-- Name: nasa_user_pkey; Type: CONSTRAINT; Schema: public; Owner: pl_fit_db; Tablespace: 
--

ALTER TABLE ONLY nasa_user
    ADD CONSTRAINT nasa_user_pkey PRIMARY KEY (uuid);


--
-- Name: origin_pkey; Type: CONSTRAINT; Schema: public; Owner: pl_fit_db; Tablespace: 
--

ALTER TABLE ONLY origin
    ADD CONSTRAINT origin_pkey PRIMARY KEY (uuid);


--
-- Name: user_lock_pkey; Type: CONSTRAINT; Schema: public; Owner: pl_fit_db; Tablespace: 
--

ALTER TABLE ONLY user_lock
    ADD CONSTRAINT user_lock_pkey PRIMARY KEY (uuid);


--
-- Name: user_tmp_table_pkey; Type: CONSTRAINT; Schema: public; Owner: pl_fit_db; Tablespace: 
--

ALTER TABLE ONLY user_tmp_table
    ADD CONSTRAINT user_tmp_table_pkey PRIMARY KEY (id);


--
-- Name: category_value_key; Type: INDEX; Schema: public; Owner: pl_fit_db; Tablespace: 
--

CREATE UNIQUE INDEX category_value_key ON category USING btree (value);


--
-- Name: food_product_name_origin_idx; Type: INDEX; Schema: public; Owner: pl_fit_db; Tablespace: 
--

CREATE UNIQUE INDEX food_product_name_origin_idx ON food_product USING btree (name, origin_uuid);


--
-- Name: origin_value_key; Type: INDEX; Schema: public; Owner: pl_fit_db; Tablespace: 
--

CREATE UNIQUE INDEX origin_value_key ON origin USING btree (value);


--
-- Name: user_full_name_key; Type: INDEX; Schema: public; Owner: pl_fit_db; Tablespace: 
--

CREATE UNIQUE INDEX user_full_name_key ON nasa_user USING btree (full_name);


--
-- Name: devices_user_lock_fk; Type: FK CONSTRAINT; Schema: public; Owner: pl_fit_db
--

ALTER TABLE ONLY user_lock
    ADD CONSTRAINT devices_user_lock_fk FOREIGN KEY (device_uuid) REFERENCES devices(uuid);


--
-- Name: food_product_food_product_record_fk; Type: FK CONSTRAINT; Schema: public; Owner: pl_fit_db
--

ALTER TABLE ONLY food_product_record
    ADD CONSTRAINT food_product_food_product_record_fk FOREIGN KEY (food_product_uuid) REFERENCES food_product(uuid);


--
-- Name: food_product_record_media_record_fk; Type: FK CONSTRAINT; Schema: public; Owner: pl_fit_db
--

ALTER TABLE ONLY media_record
    ADD CONSTRAINT food_product_record_media_record_fk FOREIGN KEY (food_record_uuid) REFERENCES food_product_record(uuid);


--
-- Name: media_food_product_fk; Type: FK CONSTRAINT; Schema: public; Owner: pl_fit_db
--

ALTER TABLE ONLY food_product
    ADD CONSTRAINT media_food_product_fk FOREIGN KEY (image_media_uuid) REFERENCES media(uuid);


--
-- Name: media_media_record_fk; Type: FK CONSTRAINT; Schema: public; Owner: pl_fit_db
--

ALTER TABLE ONLY media_record
    ADD CONSTRAINT media_media_record_fk FOREIGN KEY (media_uuid) REFERENCES media(uuid);


--
-- Name: media_nasa_user_fk; Type: FK CONSTRAINT; Schema: public; Owner: pl_fit_db
--

ALTER TABLE ONLY nasa_user
    ADD CONSTRAINT media_nasa_user_fk FOREIGN KEY (image_media_uuid) REFERENCES media(uuid);


--
-- Name: nasa_user_food_product_filter_fk; Type: FK CONSTRAINT; Schema: public; Owner: pl_fit_db
--

ALTER TABLE ONLY food_product_filter
    ADD CONSTRAINT nasa_user_food_product_filter_fk FOREIGN KEY (user_uuid) REFERENCES nasa_user(uuid);


--
-- Name: nasa_user_food_product_fk; Type: FK CONSTRAINT; Schema: public; Owner: pl_fit_db
--

ALTER TABLE ONLY food_product
    ADD CONSTRAINT nasa_user_food_product_fk FOREIGN KEY (user_uuid) REFERENCES nasa_user(uuid);


--
-- Name: origin_food_product_fk; Type: FK CONSTRAINT; Schema: public; Owner: pl_fit_db
--

ALTER TABLE ONLY food_product
    ADD CONSTRAINT origin_food_product_fk FOREIGN KEY (origin_uuid) REFERENCES origin(uuid);


--
-- Name: user_food_product_record_fk; Type: FK CONSTRAINT; Schema: public; Owner: pl_fit_db
--

ALTER TABLE ONLY food_product_record
    ADD CONSTRAINT user_food_product_record_fk FOREIGN KEY (user_uuid) REFERENCES nasa_user(uuid);


--
-- Name: user_user_lock_fk; Type: FK CONSTRAINT; Schema: public; Owner: pl_fit_db
--

ALTER TABLE ONLY user_lock
    ADD CONSTRAINT user_user_lock_fk FOREIGN KEY (user_uuid) REFERENCES nasa_user(uuid);


--
-- Name: public; Type: ACL; Schema: -; Owner: pl_fit_db
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM pl_fit_db;
GRANT USAGE ON SCHEMA public TO pl_fit_db;


--
-- Name: login(text, text); Type: ACL; Schema: public; Owner: pl_fit_db
--

REVOKE ALL ON FUNCTION login(_username text, _pwd text, OUT _email text) FROM PUBLIC;
REVOKE ALL ON FUNCTION login(_username text, _pwd text, OUT _email text) FROM pl_fit_db;
GRANT ALL ON FUNCTION login(_username text, _pwd text, OUT _email text) TO pl_fit_db;
GRANT ALL ON FUNCTION login(_username text, _pwd text, OUT _email text) TO PUBLIC;


--
-- Name: category; Type: ACL; Schema: public; Owner: pl_fit_db
--

REVOKE ALL ON TABLE category FROM PUBLIC;
REVOKE ALL ON TABLE category FROM pl_fit_db;
GRANT ALL ON TABLE category TO pl_fit_db;


--
-- Name: devices; Type: ACL; Schema: public; Owner: pl_fit_db
--

REVOKE ALL ON TABLE devices FROM PUBLIC;
REVOKE ALL ON TABLE devices FROM pl_fit_db;
GRANT ALL ON TABLE devices TO pl_fit_db;


--
-- Name: food_product; Type: ACL; Schema: public; Owner: pl_fit_db
--

REVOKE ALL ON TABLE food_product FROM PUBLIC;
REVOKE ALL ON TABLE food_product FROM pl_fit_db;
GRANT ALL ON TABLE food_product TO pl_fit_db;


--
-- Name: food_product_filter; Type: ACL; Schema: public; Owner: pl_fit_db
--

REVOKE ALL ON TABLE food_product_filter FROM PUBLIC;
REVOKE ALL ON TABLE food_product_filter FROM pl_fit_db;
GRANT ALL ON TABLE food_product_filter TO pl_fit_db;


--
-- Name: food_product_record; Type: ACL; Schema: public; Owner: pl_fit_db
--

REVOKE ALL ON TABLE food_product_record FROM PUBLIC;
REVOKE ALL ON TABLE food_product_record FROM pl_fit_db;
GRANT ALL ON TABLE food_product_record TO pl_fit_db;


--
-- Name: food_tmp_table; Type: ACL; Schema: public; Owner: pl_fit_db
--

REVOKE ALL ON TABLE food_tmp_table FROM PUBLIC;
REVOKE ALL ON TABLE food_tmp_table FROM pl_fit_db;
GRANT ALL ON TABLE food_tmp_table TO pl_fit_db;


--
-- Name: origin; Type: ACL; Schema: public; Owner: pl_fit_db
--

REVOKE ALL ON TABLE origin FROM PUBLIC;
REVOKE ALL ON TABLE origin FROM pl_fit_db;
GRANT ALL ON TABLE origin TO pl_fit_db;


--
-- Name: food_tmp_view; Type: ACL; Schema: public; Owner: pl_fit_db
--

REVOKE ALL ON TABLE food_tmp_view FROM PUBLIC;
REVOKE ALL ON TABLE food_tmp_view FROM pl_fit_db;
GRANT ALL ON TABLE food_tmp_view TO pl_fit_db;


--
-- Name: media; Type: ACL; Schema: public; Owner: pl_fit_db
--

REVOKE ALL ON TABLE media FROM PUBLIC;
REVOKE ALL ON TABLE media FROM pl_fit_db;
GRANT ALL ON TABLE media TO pl_fit_db;


--
-- Name: media_record; Type: ACL; Schema: public; Owner: pl_fit_db
--

REVOKE ALL ON TABLE media_record FROM PUBLIC;
REVOKE ALL ON TABLE media_record FROM pl_fit_db;
GRANT ALL ON TABLE media_record TO pl_fit_db;


--
-- Name: nasa_user; Type: ACL; Schema: public; Owner: pl_fit_db
--

REVOKE ALL ON TABLE nasa_user FROM PUBLIC;
REVOKE ALL ON TABLE nasa_user FROM pl_fit_db;
GRANT ALL ON TABLE nasa_user TO pl_fit_db;


--
-- Name: summary_view; Type: ACL; Schema: public; Owner: pl_fit_db
--

REVOKE ALL ON TABLE summary_view FROM PUBLIC;
REVOKE ALL ON TABLE summary_view FROM pl_fit_db;
GRANT ALL ON TABLE summary_view TO pl_fit_db;


--
-- Name: user_lock; Type: ACL; Schema: public; Owner: pl_fit_db
--

REVOKE ALL ON TABLE user_lock FROM PUBLIC;
REVOKE ALL ON TABLE user_lock FROM pl_fit_db;
GRANT ALL ON TABLE user_lock TO pl_fit_db;


--
-- Name: user_tmp_table; Type: ACL; Schema: public; Owner: pl_fit_db
--

REVOKE ALL ON TABLE user_tmp_table FROM PUBLIC;
REVOKE ALL ON TABLE user_tmp_table FROM pl_fit_db;
GRANT ALL ON TABLE user_tmp_table TO pl_fit_db;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public REVOKE ALL ON TABLES  FROM PUBLIC;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public REVOKE ALL ON TABLES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES  TO pl_fit_db;


--
-- PostgreSQL database dump complete
--

