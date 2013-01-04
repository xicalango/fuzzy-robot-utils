--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.6
-- Dumped by pg_dump version 9.2.0
-- Started on 2012-11-25 15:41:44

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

--
-- TOC entry 251 (class 1255 OID 25113)
-- Name: create_uebrige_direktkandidaten(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION create_uebrige_direktkandidaten(p_jahr integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE 
	rec record;
BEGIN

	FOR rec IN SELECT * FROM wahlkreis WHERE land_id IN (SELECT id FROM land WHERE jahr = p_jahr) LOOP
		INSERT INTO direktkandidat (vorname, nachname , wahlkreis_id, partei_id)
			VALUES ( 'Übrige', 'Übrige', rec.id, get_partei_id_by_name('Übrige') );
	END LOOP;

END;
$$;


--
-- TOC entry 238 (class 1255 OID 16388)
-- Name: get_bundesland_id_by_name(character varying, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_bundesland_id_by_name(bundesland_name character varying, jahr integer) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT l.id FROM public."land" l WHERE l.name = $1 AND l.jahr = $2 LIMIT 1;$_$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 164 (class 1259 OID 16396)
-- Name: direktkandidat; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE direktkandidat (
    id integer NOT NULL,
    vorname character varying(50),
    nachname character varying(50),
    wahlkreis_id integer,
    partei_id integer
);


--
-- TOC entry 257 (class 1255 OID 24952)
-- Name: get_direktkandidat_by_wahlkreis_partei_jahr(character varying, character varying, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_direktkandidat_by_wahlkreis_partei_jahr(character varying, character varying, integer) RETURNS direktkandidat
    LANGUAGE sql
    AS $_$
SELECT * 
	FROM "direktkandidat" 
	WHERE wahlkreis_id = (SELECT id FROM get_wahlkreis_by_jahr_and_name($3, $1))
	AND partei_id = get_partei_id_by_name($2)
$_$;


--
-- TOC entry 258 (class 1255 OID 24980)
-- Name: get_direktkandidat_id_by_wahlkreis_partei_jahr(character varying, character varying, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_direktkandidat_id_by_wahlkreis_partei_jahr(character varying, character varying, integer) RETURNS integer
    LANGUAGE sql
    AS $_$
SELECT id 
	FROM "direktkandidat" 
	WHERE wahlkreis_id = (SELECT id FROM get_wahlkreis_by_jahr_and_name($3, $1))
	AND partei_id = get_partei_id_by_name($2)
$_$;


--
-- TOC entry 169 (class 1259 OID 16409)
-- Name: land; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE land (
    id integer NOT NULL,
    name character varying(30),
    jahr integer
);


--
-- TOC entry 250 (class 1255 OID 16717)
-- Name: get_laender_by_jahr(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_laender_by_jahr(integer) RETURNS SETOF land
    LANGUAGE sql
    AS $_$
SELECT * FROM "land" WHERE jahr = $1;$_$;


--
-- TOC entry 173 (class 1259 OID 16419)
-- Name: landesliste; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE landesliste (
    id integer NOT NULL,
    listenplatz integer,
    land_id integer,
    partei_id integer
);


--
-- TOC entry 260 (class 1255 OID 16668)
-- Name: get_landesliste_by_jahr(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_landesliste_by_jahr(integer) RETURNS SETOF landesliste
    LANGUAGE sql
    AS $_$SELECT * FROM "landesliste" WHERE land_id IN (SELECT id FROM "land" WHERE jahr = $1);$_$;


--
-- TOC entry 256 (class 1255 OID 25137)
-- Name: get_landesliste_id_by_wahlkreis_partei_jahr(character varying, character varying, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_landesliste_id_by_wahlkreis_partei_jahr(character varying, character varying, integer) RETURNS integer
    LANGUAGE sql
    AS $_$
SELECT id 
	FROM landesliste 
	WHERE land_id = (SELECT land_id FROM get_wahlkreis_by_jahr_and_name($3, $1))
	AND partei_id = get_partei_id_by_name($2)
$_$;


--
-- TOC entry 241 (class 1255 OID 16389)
-- Name: get_partei_id_by_name(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_partei_id_by_name(partei_name character varying) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT p.id FROM public."partei" p WHERE p.name = $1 LIMIT 1;$_$;


--
-- TOC entry 177 (class 1259 OID 16434)
-- Name: wahlkreis; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE wahlkreis (
    id integer NOT NULL,
    name character varying(100),
    land_id integer
);


--
-- TOC entry 239 (class 1255 OID 16642)
-- Name: get_wahlkreis_by_jahr(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_wahlkreis_by_jahr(integer) RETURNS SETOF wahlkreis
    LANGUAGE sql
    AS $_$
SELECT * FROM "wahlkreis" WHERE land_id IN (SELECT id FROM "land" WHERE jahr = $1);$_$;


--
-- TOC entry 255 (class 1255 OID 24950)
-- Name: get_wahlkreis_by_jahr_and_name(integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_wahlkreis_by_jahr_and_name(integer, character varying) RETURNS wahlkreis
    LANGUAGE sql
    AS $_$
SELECT * 
	FROM "wahlkreis" 
	WHERE land_id IN (SELECT id FROM "land" WHERE jahr = $1)
	AND "name" = $2;
$_$;


--
-- TOC entry 259 (class 1255 OID 25000)
-- Name: get_wahlkreis_id_by_jahr_and_name(integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_wahlkreis_id_by_jahr_and_name(integer, character varying) RETURNS integer
    LANGUAGE sql
    AS $_$
SELECT id 
	FROM "wahlkreis" 
	WHERE land_id IN (SELECT id FROM "land" WHERE jahr = $1)
	AND "name" = $2;
$_$;


--
-- TOC entry 252 (class 1255 OID 16722)
-- Name: initialize_db(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION initialize_db() RETURNS void
    LANGUAGE sql
    AS $$

--reset db to zero
SELECT reset_db();

INSERT INTO partei ("name") VALUES ('Übrige');

--2009
INSERT INTO "jahr" VALUES (2009);
SELECT raw2009.import_bundeslaender();
SELECT raw2009.import_parteien();
SELECT raw2009.import_wahlkreise();
SELECT raw2009.import_landeslisten();
SELECT raw2009.import_landeskandidaten();
SELECT raw2009.import_direktkandidaten();

SELECT create_uebrige_direktkandidaten(2009);

--2005
INSERT INTO "jahr" VALUES (2005);
--SELECT raw2005.import_bundeslaender();
--SELECT raw2005.import_parteien();
--SELECT raw2005.import_wahlkreise();

$$;


--
-- TOC entry 245 (class 1255 OID 16583)
-- Name: reset_db(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION reset_db() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE 
	rec record;
BEGIN
EXECUTE 'DELETE FROM "erststimme"';
EXECUTE 'DELETE FROM "zweitstimme"';

EXECUTE 'DELETE FROM "direktkandidat"';
EXECUTE 'DELETE FROM "landeskandidat"';
EXECUTE 'DELETE FROM "landesliste"';

EXECUTE 'DELETE FROM "wahlkreis"';
EXECUTE 'DELETE FROM "land"';
EXECUTE 'DELETE FROM "jahr"';

EXECUTE 'DELETE FROM "partei"';

FOR rec IN SELECT * FROM information_schema.sequences WHERE sequence_catalog = 'btw2009' AND sequence_schema = 'public' LOOP
	EXECUTE 'ALTER SEQUENCE "' || rec.sequence_name || '" RESTART 1';
END LOOP;


END;
$$;


--
-- TOC entry 254 (class 1255 OID 25198)
-- Name: scherper_faktoren(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION scherper_faktoren() RETURNS SETOF numeric
    LANGUAGE plpgsql
    AS $$
BEGIN

	FOR i IN 0..597 LOOP -- insges 598 zeilen
		RETURN NEXT i+0.5;
	END LOOP;



END;


$$;


--
-- TOC entry 165 (class 1259 OID 16399)
-- Name: Direktkandidat_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Direktkandidat_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2144 (class 0 OID 0)
-- Dependencies: 165
-- Name: Direktkandidat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Direktkandidat_id_seq" OWNED BY direktkandidat.id;


--
-- TOC entry 166 (class 1259 OID 16401)
-- Name: erststimme; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE erststimme (
    id integer NOT NULL,
    wahlkreis_id integer,
    direktkandidat_id integer
);


--
-- TOC entry 167 (class 1259 OID 16404)
-- Name: Erststimme_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Erststimme_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2145 (class 0 OID 0)
-- Dependencies: 167
-- Name: Erststimme_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Erststimme_id_seq" OWNED BY erststimme.id;


--
-- TOC entry 170 (class 1259 OID 16412)
-- Name: Land_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Land_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2146 (class 0 OID 0)
-- Dependencies: 170
-- Name: Land_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Land_id_seq" OWNED BY land.id;


--
-- TOC entry 171 (class 1259 OID 16414)
-- Name: landeskandidat; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE landeskandidat (
    id integer NOT NULL,
    vorname character varying(50),
    nachname character varying(50),
    listenrang integer,
    landesliste_id integer
);


--
-- TOC entry 172 (class 1259 OID 16417)
-- Name: Landeskandidat_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Landeskandidat_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2147 (class 0 OID 0)
-- Dependencies: 172
-- Name: Landeskandidat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Landeskandidat_id_seq" OWNED BY landeskandidat.id;


--
-- TOC entry 174 (class 1259 OID 16422)
-- Name: Landesliste_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Landesliste_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2148 (class 0 OID 0)
-- Dependencies: 174
-- Name: Landesliste_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Landesliste_id_seq" OWNED BY landesliste.id;


--
-- TOC entry 175 (class 1259 OID 16424)
-- Name: partei; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE partei (
    name character varying(150),
    id integer NOT NULL
);


--
-- TOC entry 176 (class 1259 OID 16427)
-- Name: Partei_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Partei_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2149 (class 0 OID 0)
-- Dependencies: 176
-- Name: Partei_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Partei_id_seq" OWNED BY partei.id;


--
-- TOC entry 178 (class 1259 OID 16437)
-- Name: Wahlkreis_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Wahlkreis_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2150 (class 0 OID 0)
-- Dependencies: 178
-- Name: Wahlkreis_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Wahlkreis_id_seq" OWNED BY wahlkreis.id;


--
-- TOC entry 179 (class 1259 OID 16439)
-- Name: zweitstimme; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE zweitstimme (
    id integer NOT NULL,
    wahlkreis_id integer,
    landesliste_id integer
);


--
-- TOC entry 180 (class 1259 OID 16442)
-- Name: Zweitstimme_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Zweitstimme_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2151 (class 0 OID 0)
-- Dependencies: 180
-- Name: Zweitstimme_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Zweitstimme_id_seq" OWNED BY zweitstimme.id;


--
-- TOC entry 218 (class 1259 OID 33447)
-- Name: erststimmen_aggregation; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW erststimmen_aggregation AS
    SELECT erststimme_insges.kandidat_id AS direktkandidat_id, erststimme_insges.stimmen, erststimme_insges.wahlkreis_id FROM stimmen2009.erststimme_insges;


--
-- TOC entry 219 (class 1259 OID 33451)
-- Name: direktkandidat_gewinner; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW direktkandidat_gewinner AS
    WITH max_stimmen_per_wahlkreis AS (SELECT ea2.wahlkreis_id, max(ea2.stimmen) AS max_stimmen FROM erststimmen_aggregation ea2 GROUP BY ea2.wahlkreis_id) SELECT ea.wahlkreis_id, ea.direktkandidat_id, ea.stimmen FROM erststimmen_aggregation ea, max_stimmen_per_wahlkreis mspw WHERE ((ea.wahlkreis_id = mspw.wahlkreis_id) AND (ea.stimmen = mspw.max_stimmen));


--
-- TOC entry 220 (class 1259 OID 33455)
-- Name: direktkandidaten_pro_partei; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW direktkandidaten_pro_partei AS
    SELECT d.partei_id, count(*) AS count FROM direktkandidat_gewinner dg, direktkandidat d WHERE (dg.direktkandidat_id = d.id) GROUP BY d.partei_id;


--
-- TOC entry 168 (class 1259 OID 16406)
-- Name: jahr; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE jahr (
    jahr integer NOT NULL
);


--
-- TOC entry 213 (class 1259 OID 25223)
-- Name: partei_zweitstimmen_alexx; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW partei_zweitstimmen_alexx AS
    SELECT l.partei_id, sum(st.stimmen) AS stimmen FROM stimmen2009.landesliste_stimmen st, landesliste l WHERE (st.landesliste_id = l.id) GROUP BY l.partei_id;


--
-- TOC entry 217 (class 1259 OID 33439)
-- Name: zweitstimmen_aggregation; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW zweitstimmen_aggregation AS
    SELECT ll.partei_id, s.wahlkreis_id, s.stimmen FROM stimmen2009.landesliste_stimmen s, landesliste ll WHERE (s.landesliste_id = ll.id) UNION ALL SELECT NULL::integer AS partei_id, s.wahlkreis_id, s.stimmen FROM stimmen2009.zweitstimme_ungueltige s;


--
-- TOC entry 221 (class 1259 OID 33459)
-- Name: zweitstimmen_prozent; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW zweitstimmen_prozent AS
    WITH zweitstimmen_pro_partei AS (SELECT zweitstimmen_aggregation.partei_id, sum(zweitstimmen_aggregation.stimmen) AS stimmen FROM zweitstimmen_aggregation GROUP BY zweitstimmen_aggregation.partei_id), zweitstimmen_gesamt AS (SELECT sum(zweitstimmen_aggregation.stimmen) AS gesamtstimmen FROM zweitstimmen_aggregation WHERE (zweitstimmen_aggregation.partei_id IS NOT NULL)) SELECT zspp.partei_id, (((100 * zspp.stimmen))::numeric / (ges.gesamtstimmen)::numeric) AS prozent FROM zweitstimmen_pro_partei zspp, zweitstimmen_gesamt ges ORDER BY (((100 * zspp.stimmen))::numeric / (ges.gesamtstimmen)::numeric) DESC;


--
-- TOC entry 222 (class 1259 OID 33463)
-- Name: parteien_einzug; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW parteien_einzug AS
    SELECT zweitstimmen_prozent.partei_id FROM zweitstimmen_prozent WHERE (zweitstimmen_prozent.prozent > (5)::numeric) UNION SELECT direktkandidaten_pro_partei.partei_id FROM direktkandidaten_pro_partei WHERE (direktkandidaten_pro_partei.count > 2);


--
-- TOC entry 212 (class 1259 OID 25211)
-- Name: scherperfaktoren; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scherperfaktoren (
    faktor numeric NOT NULL
);


--
-- TOC entry 214 (class 1259 OID 25227)
-- Name: scherper_auswertung_alexx; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW scherper_auswertung_alexx AS
    SELECT pza.partei_id, ((pza.stimmen)::numeric / s.faktor) AS gewicht FROM partei_zweitstimmen_alexx pza, scherperfaktoren s WHERE (((pza.stimmen)::numeric / (SELECT sum(partei_zweitstimmen_alexx.stimmen) AS sum FROM partei_zweitstimmen_alexx)) >= 0.05) ORDER BY ((pza.stimmen)::numeric / s.faktor) DESC;


--
-- TOC entry 223 (class 1259 OID 33467)
-- Name: scherper_auswertung_final; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW scherper_auswertung_final AS
    SELECT pza.partei_id, ((pza.stimmen)::numeric / s.faktor) AS gewicht FROM partei_zweitstimmen_alexx pza, scherperfaktoren s WHERE (pza.partei_id IN (SELECT parteien_einzug.partei_id FROM parteien_einzug)) ORDER BY ((pza.stimmen)::numeric / s.faktor) DESC;


--
-- TOC entry 215 (class 1259 OID 25231)
-- Name: sitzverteilung_partei_alexx; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW sitzverteilung_partei_alexx AS
    WITH auswetung AS (SELECT scherper_auswertung_alexx.partei_id, scherper_auswertung_alexx.gewicht FROM scherper_auswertung_alexx, partei p WHERE (scherper_auswertung_alexx.partei_id = p.id) LIMIT 598) SELECT auswetung.partei_id, p.name, count(*) AS count FROM auswetung, partei p WHERE (auswetung.partei_id = p.id) GROUP BY auswetung.partei_id, p.name ORDER BY count(*) DESC;


--
-- TOC entry 216 (class 1259 OID 25243)
-- Name: sitzeParteiBundesland_alexx; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW "sitzeParteiBundesland_alexx" AS
    WITH wahlkreise_pro_land AS (SELECT get_wahlkreis_by_jahr.land_id, count(*) AS wk_count FROM get_wahlkreis_by_jahr(2009) get_wahlkreis_by_jahr(id, name, land_id) GROUP BY get_wahlkreis_by_jahr.land_id) SELECT sv.partei_id, round((((((sv.count * wpl.wk_count) * 2))::double precision / (598)::double precision))::numeric, 0) AS sitze, wpl.land_id FROM sitzverteilung_partei_alexx sv, wahlkreise_pro_land wpl;


--
-- TOC entry 2096 (class 2604 OID 16467)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY direktkandidat ALTER COLUMN id SET DEFAULT nextval('"Direktkandidat_id_seq"'::regclass);


--
-- TOC entry 2097 (class 2604 OID 16468)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY erststimme ALTER COLUMN id SET DEFAULT nextval('"Erststimme_id_seq"'::regclass);


--
-- TOC entry 2098 (class 2604 OID 16469)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY land ALTER COLUMN id SET DEFAULT nextval('"Land_id_seq"'::regclass);


--
-- TOC entry 2099 (class 2604 OID 16470)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY landeskandidat ALTER COLUMN id SET DEFAULT nextval('"Landeskandidat_id_seq"'::regclass);


--
-- TOC entry 2100 (class 2604 OID 16471)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY landesliste ALTER COLUMN id SET DEFAULT nextval('"Landesliste_id_seq"'::regclass);


--
-- TOC entry 2101 (class 2604 OID 16472)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY partei ALTER COLUMN id SET DEFAULT nextval('"Partei_id_seq"'::regclass);


--
-- TOC entry 2102 (class 2604 OID 16474)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY wahlkreis ALTER COLUMN id SET DEFAULT nextval('"Wahlkreis_id_seq"'::regclass);


--
-- TOC entry 2103 (class 2604 OID 16475)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY zweitstimme ALTER COLUMN id SET DEFAULT nextval('"Zweitstimme_id_seq"'::regclass);


--
-- TOC entry 2105 (class 2606 OID 16477)
-- Name: Direktkandidat_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY direktkandidat
    ADD CONSTRAINT "Direktkandidat_pkey" PRIMARY KEY (id);


--
-- TOC entry 2107 (class 2606 OID 16479)
-- Name: Erststimme_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY erststimme
    ADD CONSTRAINT "Erststimme_pkey" PRIMARY KEY (id);


--
-- TOC entry 2111 (class 2606 OID 16481)
-- Name: Jahr_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY jahr
    ADD CONSTRAINT "Jahr_pkey" PRIMARY KEY (jahr);


--
-- TOC entry 2113 (class 2606 OID 16483)
-- Name: Land_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY land
    ADD CONSTRAINT "Land_pkey" PRIMARY KEY (id);


--
-- TOC entry 2115 (class 2606 OID 16485)
-- Name: Landeskandidat_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY landeskandidat
    ADD CONSTRAINT "Landeskandidat_pkey" PRIMARY KEY (id);


--
-- TOC entry 2117 (class 2606 OID 16487)
-- Name: Landesliste_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY landesliste
    ADD CONSTRAINT "Landesliste_pkey" PRIMARY KEY (id);


--
-- TOC entry 2119 (class 2606 OID 16631)
-- Name: Partei_name_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY partei
    ADD CONSTRAINT "Partei_name_key" UNIQUE (name);


--
-- TOC entry 2121 (class 2606 OID 16489)
-- Name: Partei_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY partei
    ADD CONSTRAINT "Partei_pkey" PRIMARY KEY (id);


--
-- TOC entry 2123 (class 2606 OID 16493)
-- Name: Wahlkreis_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY wahlkreis
    ADD CONSTRAINT "Wahlkreis_pkey" PRIMARY KEY (id);


--
-- TOC entry 2125 (class 2606 OID 16495)
-- Name: Zweitstimme_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY zweitstimme
    ADD CONSTRAINT "Zweitstimme_pkey" PRIMARY KEY (id);


--
-- TOC entry 2127 (class 2606 OID 25218)
-- Name: scherperfaktoren_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scherperfaktoren
    ADD CONSTRAINT scherperfaktoren_pkey PRIMARY KEY (faktor);


--
-- TOC entry 2108 (class 1259 OID 25179)
-- Name: erststimme_direktkandidat_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX erststimme_direktkandidat_id_idx ON erststimme USING btree (direktkandidat_id);


--
-- TOC entry 2109 (class 1259 OID 25178)
-- Name: erststimme_wahlkreis_id_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX erststimme_wahlkreis_id_idx ON erststimme USING btree (wahlkreis_id);


--
-- TOC entry 2128 (class 2606 OID 16504)
-- Name: Direktkandidat_partei_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY direktkandidat
    ADD CONSTRAINT "Direktkandidat_partei_id_fkey" FOREIGN KEY (partei_id) REFERENCES partei(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2129 (class 2606 OID 16509)
-- Name: Direktkandidat_wahlkreis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY direktkandidat
    ADD CONSTRAINT "Direktkandidat_wahlkreis_id_fkey" FOREIGN KEY (wahlkreis_id) REFERENCES wahlkreis(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2130 (class 2606 OID 25005)
-- Name: Erststimme_direktkandidat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY erststimme
    ADD CONSTRAINT "Erststimme_direktkandidat_id_fkey" FOREIGN KEY (direktkandidat_id) REFERENCES direktkandidat(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2131 (class 2606 OID 25010)
-- Name: Erststimme_wahlkreis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY erststimme
    ADD CONSTRAINT "Erststimme_wahlkreis_id_fkey" FOREIGN KEY (wahlkreis_id) REFERENCES wahlkreis(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2132 (class 2606 OID 16524)
-- Name: Land_jahr_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY land
    ADD CONSTRAINT "Land_jahr_fkey" FOREIGN KEY (jahr) REFERENCES jahr(jahr) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2133 (class 2606 OID 16529)
-- Name: Landeskandidat_landesliste_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY landeskandidat
    ADD CONSTRAINT "Landeskandidat_landesliste_id_fkey" FOREIGN KEY (landesliste_id) REFERENCES landesliste(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2134 (class 2606 OID 16534)
-- Name: Landesliste_land_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY landesliste
    ADD CONSTRAINT "Landesliste_land_id_fkey" FOREIGN KEY (land_id) REFERENCES land(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2135 (class 2606 OID 16539)
-- Name: Landesliste_partei_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY landesliste
    ADD CONSTRAINT "Landesliste_partei_id_fkey" FOREIGN KEY (partei_id) REFERENCES partei(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2136 (class 2606 OID 16549)
-- Name: Wahlkreis_land_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY wahlkreis
    ADD CONSTRAINT "Wahlkreis_land_id_fkey" FOREIGN KEY (land_id) REFERENCES land(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2137 (class 2606 OID 25015)
-- Name: Zweitstimme_landesliste_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY zweitstimme
    ADD CONSTRAINT "Zweitstimme_landesliste_id_fkey" FOREIGN KEY (landesliste_id) REFERENCES landesliste(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2138 (class 2606 OID 25020)
-- Name: Zweitstimme_wahlkreis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY zweitstimme
    ADD CONSTRAINT "Zweitstimme_wahlkreis_id_fkey" FOREIGN KEY (wahlkreis_id) REFERENCES wahlkreis(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


-- Completed on 2012-11-25 15:41:44

--
-- PostgreSQL database dump complete
--

