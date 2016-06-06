--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

DROP INDEX public.origin_value_key;
DROP INDEX public.category_value_key;
ALTER TABLE ONLY public.origin DROP CONSTRAINT origin_pkey;
ALTER TABLE ONLY public.category DROP CONSTRAINT category_pkey;
DROP TABLE public.origin;
DROP TABLE public.category;
SET search_path = public, pg_catalog;

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
-- Name: origin; Type: TABLE; Schema: public; Owner: pl_fit_db; Tablespace: 
--

CREATE TABLE origin (
    uuid character varying(36) NOT NULL,
    value text NOT NULL
);


ALTER TABLE public.origin OWNER TO pl_fit_db;

--
-- Data for Name: category; Type: TABLE DATA; Schema: public; Owner: pl_fit_db
--

COPY category (uuid, value) FROM stdin;
b2060b5e-d100-42cc-b0cf-f36e3974ccc3	Vegetables / Sides
831bbd08-1247-41c3-8a07-8b32c97a7058	Fruit & Nuts
101a0b99-046c-46a7-99f8-c6b927307ad5	Dessert & Snacks
93c98c23-4ce7-44d3-9479-596e7f37da77	Drink
c1dac56b-c22e-43c4-a2fc-75d82e757200	Breakfast
ddd31ad6-129f-4843-ad95-0f43c65d4908	Meat / Fish
ab0fde6a-0331-46f4-88ea-9841b36c719e	Vitamins / Supplements
\.


--
-- Data for Name: origin; Type: TABLE DATA; Schema: public; Owner: pl_fit_db
--

COPY origin (uuid, value) FROM stdin;
1306e428-047b-4b59-9774-84c774a41de9	NASA Foods
143769bb-e9fc-425c-89be-12c4faa8eb78	Russian Foods
03f3ddc7-e73b-49b6-a681-c596cbcef412	CSA Foods
aca6afbd-e6c7-486c-8006-cabd292104bc	ESA Foods
9f827dbf-ab79-4224-9efa-f8071e4eb782	JAXA Foods
\.


--
-- Name: category_pkey; Type: CONSTRAINT; Schema: public; Owner: pl_fit_db; Tablespace: 
--

ALTER TABLE ONLY category
    ADD CONSTRAINT category_pkey PRIMARY KEY (uuid);


--
-- Name: origin_pkey; Type: CONSTRAINT; Schema: public; Owner: pl_fit_db; Tablespace: 
--

ALTER TABLE ONLY origin
    ADD CONSTRAINT origin_pkey PRIMARY KEY (uuid);


--
-- Name: category_value_key; Type: INDEX; Schema: public; Owner: pl_fit_db; Tablespace: 
--

CREATE UNIQUE INDEX category_value_key ON category USING btree (value);


--
-- Name: origin_value_key; Type: INDEX; Schema: public; Owner: pl_fit_db; Tablespace: 
--

CREATE UNIQUE INDEX origin_value_key ON origin USING btree (value);


--
-- PostgreSQL database dump complete
--

