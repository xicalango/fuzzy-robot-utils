--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: raw2005; Type: SCHEMA; Schema: -; Owner: alexx
--

CREATE SCHEMA raw2005;


ALTER SCHEMA raw2005 OWNER TO alexx;

--
-- Name: raw2009; Type: SCHEMA; Schema: -; Owner: alexx
--

CREATE SCHEMA raw2009;


ALTER SCHEMA raw2009 OWNER TO alexx;

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
-- Name: get_bundesland_id_by_name(character varying, integer); Type: FUNCTION; Schema: public; Owner: alexx
--

CREATE FUNCTION get_bundesland_id_by_name(bundesland_name character varying, jahr integer) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT l.id FROM public."Land" l WHERE l.name = $1 AND l.jahr = $2 LIMIT 1;$_$;


ALTER FUNCTION public.get_bundesland_id_by_name(bundesland_name character varying, jahr integer) OWNER TO alexx;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: Land; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Land" (
    id integer NOT NULL,
    name character varying(30),
    jahr integer
);


ALTER TABLE public."Land" OWNER TO postgres;

--
-- Name: get_laender_by_jahr(integer); Type: FUNCTION; Schema: public; Owner: alexx
--

CREATE FUNCTION get_laender_by_jahr(integer) RETURNS SETOF "Land"
    LANGUAGE sql
    AS $_$
SELECT * FROM "Land" WHERE jahr = $1;$_$;


ALTER FUNCTION public.get_laender_by_jahr(integer) OWNER TO alexx;

--
-- Name: Landesliste; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Landesliste" (
    id integer NOT NULL,
    listenplatz integer,
    land_id integer,
    partei_id integer
);


ALTER TABLE public."Landesliste" OWNER TO postgres;

--
-- Name: get_landesliste_by_jahr(integer); Type: FUNCTION; Schema: public; Owner: alexx
--

CREATE FUNCTION get_landesliste_by_jahr(integer) RETURNS SETOF "Landesliste"
    LANGUAGE sql
    AS $_$SELECT * FROM "Landesliste" WHERE land_id IN (SELECT id FROM "Land" WHERE jahr = $1);$_$;


ALTER FUNCTION public.get_landesliste_by_jahr(integer) OWNER TO alexx;

--
-- Name: get_partei_id_by_name(character varying); Type: FUNCTION; Schema: public; Owner: alexx
--

CREATE FUNCTION get_partei_id_by_name(partei_name character varying) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT p.id FROM public."Partei" p WHERE p.name = $1 LIMIT 1;$_$;


ALTER FUNCTION public.get_partei_id_by_name(partei_name character varying) OWNER TO alexx;

--
-- Name: Wahlkreis; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Wahlkreis" (
    id integer NOT NULL,
    name character varying(100),
    land_id integer
);


ALTER TABLE public."Wahlkreis" OWNER TO postgres;

--
-- Name: get_wahlkreis_by_jahr(integer); Type: FUNCTION; Schema: public; Owner: alexx
--

CREATE FUNCTION get_wahlkreis_by_jahr(integer) RETURNS SETOF "Wahlkreis"
    LANGUAGE sql
    AS $_$
SELECT * FROM "Wahlkreis" WHERE land_id IN (SELECT id FROM "Land" WHERE jahr = $1);$_$;


ALTER FUNCTION public.get_wahlkreis_by_jahr(integer) OWNER TO alexx;

--
-- Name: reset_db(); Type: FUNCTION; Schema: public; Owner: alexx
--

CREATE FUNCTION reset_db() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE 
	rec record;
BEGIN
EXECUTE 'DELETE FROM "Erststimme"';
EXECUTE 'DELETE FROM "Zweitstimme"';

EXECUTE 'DELETE FROM "Direktkandidat"';
EXECUTE 'DELETE FROM "Landeskandidat"';
EXECUTE 'DELETE FROM "Landesliste"';

EXECUTE 'DELETE FROM "Wahlbezirk"';
EXECUTE 'DELETE FROM "Wahlkreis"';
EXECUTE 'DELETE FROM "Land"';
EXECUTE 'DELETE FROM "Jahr"';

EXECUTE 'DELETE FROM "Partei"';

FOR rec IN SELECT * FROM information_schema.sequences WHERE sequence_catalog = 'btw2009' LOOP
	EXECUTE 'ALTER SEQUENCE "' || rec.sequence_name || '" RESTART 1';
END LOOP;


END;
$$;


ALTER FUNCTION public.reset_db() OWNER TO alexx;

SET search_path = raw2005, pg_catalog;

--
-- Name: import_bundeslaender(); Type: FUNCTION; Schema: raw2005; Owner: alexx
--

CREATE FUNCTION import_bundeslaender() RETURNS void
    LANGUAGE sql
    AS $$
INSERT INTO "Land" ("name", "jahr") SELECT DISTINCT "Land", 2005 FROM raw2005.wahlkreise;
$$;


ALTER FUNCTION raw2005.import_bundeslaender() OWNER TO alexx;

SET search_path = raw2009, pg_catalog;

--
-- Name: import_bundeslaender(integer); Type: FUNCTION; Schema: raw2009; Owner: alexx
--

CREATE FUNCTION import_bundeslaender(jahr integer) RETURNS void
    LANGUAGE sql
    AS $_$
INSERT INTO "Land" ("name", "jahr") SELECT DISTINCT "Bundesland", $1 FROM raw2009.landeslisten;
$_$;


ALTER FUNCTION raw2009.import_bundeslaender(jahr integer) OWNER TO alexx;

--
-- Name: import_direktkandidaten(); Type: FUNCTION; Schema: raw2009; Owner: alexx
--

CREATE FUNCTION import_direktkandidaten() RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE
	rec record;

	newid integer;
BEGIN

	EXECUTE 'DROP TABLE IF EXISTS raw2009.mapid_direktkandidaten';
	EXECUTE 'CREATE TABLE raw2009.mapid_direktkandidaten ( id_old INTEGER PRIMARY KEY, id_new INTEGER );';

	DELETE FROM "Direktkandidat" WHERE wahlkreis_id IN (SELECT id FROM get_wahlkreis_by_jahr(2009)); --Alte 2009er wahlkreise löschen

	FOR rec IN SELECT 
			"Kandidatennummer",
			"Vorname",
			"Nachname", 
			"Wahlkreis",
			"partei_id"
		FROM raw2009."wahlbewerber_direktkandidat"
	LOOP

		INSERT INTO "Direktkandidat" ("vorname", "nachname", "wahlkreis_id", "partei_id") 
			VALUES ( rec."Vorname", rec."Nachname", raw2009.map_wahlkreis( rec."Wahlkreis" ), rec.partei_id )
			RETURNING "id" INTO newid;

		INSERT INTO raw2009."mapid_direktkandidaten"  ( "id_old", "id_new" )
			VALUES  ( rec."Kandidatennummer", newid );

		EXECUTE 'CREATE OR REPLACE FUNCTION raw2009.map_direktkandidat(integer)
  RETURNS integer AS
''SELECT id_new FROM raw2009.mapid_direktkandidaten WHERE id_old = $1 LIMIT 1;''
  LANGUAGE sql VOLATILE
  COST 100;';
		
	END LOOP;

END;

$_$;


ALTER FUNCTION raw2009.import_direktkandidaten() OWNER TO alexx;

--
-- Name: import_landeskandidaten(); Type: FUNCTION; Schema: raw2009; Owner: alexx
--

CREATE FUNCTION import_landeskandidaten() RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE
	rec record;

	newid integer;
BEGIN

	EXECUTE 'DROP TABLE IF EXISTS raw2009.mapid_landeskandidaten';
	EXECUTE 'CREATE TABLE raw2009.mapid_landeskandidaten ( id_old INTEGER PRIMARY KEY, id_new INTEGER );';

	DELETE FROM "Landeskandidat" WHERE landesliste_id IN (SELECT id FROM get_landesliste_by_jahr(2009)); --Alte 2009er einträge löschen

	FOR rec IN SELECT 
			"Kandidatennummer",
			"VornameTitel",
			"Nachname", 
			"Position",
			"Landesliste"
		FROM raw2009."wahlbewerber_landesliste"
	LOOP

		INSERT INTO "Landeskandidat" ("vorname", "nachname", "listenrang", "landesliste_id") 
			VALUES ( rec."VornameTitel", rec."Nachname", rec."Position", raw2009.map_landesliste(rec."Landesliste") )
			RETURNING "id" INTO newid;

		INSERT INTO raw2009."mapid_landeskandidaten"  ( "id_old", "id_new" )
			VALUES  ( rec."Kandidatennummer", newid );

		EXECUTE 'CREATE OR REPLACE FUNCTION raw2009.map_landeskandidat(integer)
  RETURNS integer AS
''SELECT id_new FROM raw2009.mapid_landeskandidaten WHERE id_old = $1 LIMIT 1;''
  LANGUAGE sql VOLATILE
  COST 100;';
		
	END LOOP;

END;

$_$;


ALTER FUNCTION raw2009.import_landeskandidaten() OWNER TO alexx;

--
-- Name: import_landeslisten(); Type: FUNCTION; Schema: raw2009; Owner: alexx
--

CREATE FUNCTION import_landeslisten() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	rec record;

	newid integer;
BEGIN

	EXECUTE 'DROP TABLE IF EXISTS raw2009.mapid_landeslisten';
	EXECUTE 'CREATE TABLE raw2009.mapid_landeslisten ( id_old INTEGER PRIMARY KEY, id_new INTEGER );';

	DELETE FROM "Landesliste" WHERE land_id IN (SELECT id FROM "Land" WHERE jahr=2009); --Alte 2009er landesliste löschen

	FOR rec IN SELECT 
			"Listennummer" listen_nr,
			get_bundesland_id_by_name("Bundesland", 2009) land_id,
			get_partei_id_by_name("Partei") partei_id
		FROM raw2009."landeslisten"
	LOOP

		INSERT INTO "Landesliste" ("listenplatz", "land_id", "partei_id") 
			VALUES ( rec.listen_nr, rec.land_id, rec.partei_id ) 
			RETURNING "id" INTO newid;

		INSERT INTO raw2009."mapid_landeslisten"  ( "id_old", "id_new" )
			VALUES  ( rec.listen_nr, newid );
		
	END LOOP;
END;
$$;


ALTER FUNCTION raw2009.import_landeslisten() OWNER TO alexx;

--
-- Name: import_parteien(); Type: FUNCTION; Schema: raw2009; Owner: alexx
--

CREATE FUNCTION import_parteien() RETURNS void
    LANGUAGE sql
    AS $$
DELETE FROM "Partei";
INSERT INTO "Partei" ("name") SELECT * FROM
(
	SELECT DISTINCT "Partei" FROM raw2009.landeslisten
	UNION
	SELECT DISTINCT "Partei" FROM raw2009.wahlbewerber WHERE "Partei" IS NOT NULL
) p;$$;


ALTER FUNCTION raw2009.import_parteien() OWNER TO alexx;

--
-- Name: import_wahlkreise(); Type: FUNCTION; Schema: raw2009; Owner: alexx
--

CREATE FUNCTION import_wahlkreise() RETURNS void
    LANGUAGE plpgsql
    AS $$
DECLARE
	rec record;

	newid integer;
BEGIN

	EXECUTE 'DROP TABLE IF EXISTS raw2009.mapid_wahlkreise';
	EXECUTE 'CREATE TABLE raw2009.mapid_wahlkreise ( id_old INTEGER PRIMARY KEY, id_new INTEGER );';

	DELETE FROM "Wahlkreis" WHERE land_id IN (SELECT id FROM "Land" WHERE jahr=2009); --Alte 2009er wahlkreise löschen

	FOR rec IN SELECT 
			"WahlkreisNr" wknr, 
			"Name" n , 
			get_bundesland_id_by_name("Land", 2009) blnr,
			"Wahlberechtigte" ber
		FROM raw2009.wahlkreise 
		WHERE "WahlkreisNr" < 900 --WahlkreisNr >=900 sind "Insgesamt Werte"
	LOOP

		INSERT INTO "Wahlkreis" ("name", "land_id") 
			VALUES ( rec.n, rec.blnr ) 
			RETURNING "id" INTO newid;

		INSERT INTO raw2009."mapid_wahlkreise"  ( "id_old", "id_new" )
			VALUES  ( rec.wknr, newid );
		
	END LOOP;
	 
END;
$$;


ALTER FUNCTION raw2009.import_wahlkreise() OWNER TO alexx;

--
-- Name: map_direktkandidat(integer); Type: FUNCTION; Schema: raw2009; Owner: alexx
--

CREATE FUNCTION map_direktkandidat(integer) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT id_new FROM raw2009.mapid_direktkandidaten WHERE id_old = $1 LIMIT 1;$_$;


ALTER FUNCTION raw2009.map_direktkandidat(integer) OWNER TO alexx;

--
-- Name: map_landeskandidat(integer); Type: FUNCTION; Schema: raw2009; Owner: alexx
--

CREATE FUNCTION map_landeskandidat(integer) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT id_new FROM raw2009.mapid_landeskandidaten WHERE id_old = $1 LIMIT 1;$_$;


ALTER FUNCTION raw2009.map_landeskandidat(integer) OWNER TO alexx;

--
-- Name: map_landesliste(integer); Type: FUNCTION; Schema: raw2009; Owner: alexx
--

CREATE FUNCTION map_landesliste(integer) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT id_new FROM raw2009.mapid_landeslisten WHERE id_old = $1 LIMIT 1;$_$;


ALTER FUNCTION raw2009.map_landesliste(integer) OWNER TO alexx;

--
-- Name: map_wahlkreis(integer); Type: FUNCTION; Schema: raw2009; Owner: alexx
--

CREATE FUNCTION map_wahlkreis(integer) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT id_new FROM raw2009.mapid_wahlkreise WHERE id_old = $1 LIMIT 1;$_$;


ALTER FUNCTION raw2009.map_wahlkreis(integer) OWNER TO alexx;

SET search_path = public, pg_catalog;

--
-- Name: Direktkandidat; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Direktkandidat" (
    id integer NOT NULL,
    vorname character varying(50),
    nachname character varying(50),
    wahlkreis_id integer,
    partei_id integer
);


ALTER TABLE public."Direktkandidat" OWNER TO postgres;

--
-- Name: Direktkandidat_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Direktkandidat_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Direktkandidat_id_seq" OWNER TO postgres;

--
-- Name: Direktkandidat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Direktkandidat_id_seq" OWNED BY "Direktkandidat".id;


--
-- Name: Erststimme; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Erststimme" (
    id integer NOT NULL,
    wahlbezirk_id integer,
    direktkandidat_id integer
);


ALTER TABLE public."Erststimme" OWNER TO postgres;

--
-- Name: Erststimme_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Erststimme_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Erststimme_id_seq" OWNER TO postgres;

--
-- Name: Erststimme_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Erststimme_id_seq" OWNED BY "Erststimme".id;


--
-- Name: Jahr; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Jahr" (
    jahr integer NOT NULL
);


ALTER TABLE public."Jahr" OWNER TO postgres;

--
-- Name: Land_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Land_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Land_id_seq" OWNER TO postgres;

--
-- Name: Land_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Land_id_seq" OWNED BY "Land".id;


--
-- Name: Landeskandidat; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Landeskandidat" (
    id integer NOT NULL,
    vorname character varying(50),
    nachname character varying(50),
    listenrang integer,
    landesliste_id integer
);


ALTER TABLE public."Landeskandidat" OWNER TO postgres;

--
-- Name: Landeskandidat_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Landeskandidat_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Landeskandidat_id_seq" OWNER TO postgres;

--
-- Name: Landeskandidat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Landeskandidat_id_seq" OWNED BY "Landeskandidat".id;


--
-- Name: Landesliste_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Landesliste_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Landesliste_id_seq" OWNER TO postgres;

--
-- Name: Landesliste_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Landesliste_id_seq" OWNED BY "Landesliste".id;


--
-- Name: Partei; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Partei" (
    name character varying(150),
    id integer NOT NULL
);


ALTER TABLE public."Partei" OWNER TO postgres;

--
-- Name: Partei_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Partei_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Partei_id_seq" OWNER TO postgres;

--
-- Name: Partei_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Partei_id_seq" OWNED BY "Partei".id;


--
-- Name: Wahlbezirk; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Wahlbezirk" (
    id integer NOT NULL,
    wahlberechtigte integer,
    "ausgegebeneWahlscheine" integer,
    wahlkreis_id integer
);


ALTER TABLE public."Wahlbezirk" OWNER TO postgres;

--
-- Name: Wahlbezirk_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Wahlbezirk_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Wahlbezirk_id_seq" OWNER TO postgres;

--
-- Name: Wahlbezirk_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Wahlbezirk_id_seq" OWNED BY "Wahlbezirk".id;


--
-- Name: Wahlkreis_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Wahlkreis_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Wahlkreis_id_seq" OWNER TO postgres;

--
-- Name: Wahlkreis_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Wahlkreis_id_seq" OWNED BY "Wahlkreis".id;


--
-- Name: Zweitstimme; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE "Zweitstimme" (
    id integer NOT NULL,
    wahlbezirk_id integer,
    landesliste_id integer
);


ALTER TABLE public."Zweitstimme" OWNER TO postgres;

--
-- Name: Zweitstimme_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE "Zweitstimme_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public."Zweitstimme_id_seq" OWNER TO postgres;

--
-- Name: Zweitstimme_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE "Zweitstimme_id_seq" OWNED BY "Zweitstimme".id;


SET search_path = raw2005, pg_catalog;

--
-- Name: wahlbewerber; Type: TABLE; Schema: raw2005; Owner: alexx; Tablespace: 
--

CREATE TABLE wahlbewerber (
    "Vorname" character varying(100),
    "Name" character varying(100),
    "Partei" character varying(100),
    "Wahlkreis" integer,
    "Land" character varying(100),
    "Platz" integer,
    id integer NOT NULL
);


ALTER TABLE raw2005.wahlbewerber OWNER TO alexx;

--
-- Name: wahlbewerber_id_seq; Type: SEQUENCE; Schema: raw2005; Owner: alexx
--

CREATE SEQUENCE wahlbewerber_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE raw2005.wahlbewerber_id_seq OWNER TO alexx;

--
-- Name: wahlbewerber_id_seq; Type: SEQUENCE OWNED BY; Schema: raw2005; Owner: alexx
--

ALTER SEQUENCE wahlbewerber_id_seq OWNED BY wahlbewerber.id;


--
-- Name: wahlkreise; Type: TABLE; Schema: raw2005; Owner: alexx; Tablespace: 
--

CREATE TABLE wahlkreise (
    "Nummer" integer NOT NULL,
    "Land" character varying(100),
    "Name" character varying(100)
);


ALTER TABLE raw2005.wahlkreise OWNER TO alexx;

SET search_path = raw2009, pg_catalog;

--
-- Name: landeslisten; Type: TABLE; Schema: raw2009; Owner: alexx; Tablespace: 
--

CREATE TABLE landeslisten (
    "Listennummer" integer NOT NULL,
    "Bundesland" character varying(100),
    "Partei" character varying(100)
);


ALTER TABLE raw2009.landeslisten OWNER TO alexx;

--
-- Name: listenplaetze; Type: TABLE; Schema: raw2009; Owner: alexx; Tablespace: 
--

CREATE TABLE listenplaetze (
    "Landesliste" integer NOT NULL,
    "Kandidat" integer NOT NULL,
    "Position" integer
);


ALTER TABLE raw2009.listenplaetze OWNER TO alexx;

--
-- Name: mapid_direktkandidaten; Type: TABLE; Schema: raw2009; Owner: alexx; Tablespace: 
--

CREATE TABLE mapid_direktkandidaten (
    id_old integer NOT NULL,
    id_new integer
);


ALTER TABLE raw2009.mapid_direktkandidaten OWNER TO alexx;

--
-- Name: mapid_landeskandidaten; Type: TABLE; Schema: raw2009; Owner: alexx; Tablespace: 
--

CREATE TABLE mapid_landeskandidaten (
    id_old integer NOT NULL,
    id_new integer
);


ALTER TABLE raw2009.mapid_landeskandidaten OWNER TO alexx;

--
-- Name: mapid_landeslisten; Type: TABLE; Schema: raw2009; Owner: alexx; Tablespace: 
--

CREATE TABLE mapid_landeslisten (
    id_old integer NOT NULL,
    id_new integer
);


ALTER TABLE raw2009.mapid_landeslisten OWNER TO alexx;

--
-- Name: mapid_wahlkreise; Type: TABLE; Schema: raw2009; Owner: alexx; Tablespace: 
--

CREATE TABLE mapid_wahlkreise (
    id_old integer NOT NULL,
    id_new integer
);


ALTER TABLE raw2009.mapid_wahlkreise OWNER TO alexx;

--
-- Name: wahlbewerber; Type: TABLE; Schema: raw2009; Owner: alexx; Tablespace: 
--

CREATE TABLE wahlbewerber (
    "Titel" character varying(100),
    "Vorname" character varying(100),
    "Nachname" character varying(100),
    "Partei" character varying(100),
    "Jahrgang" integer,
    "Kandidatennummer" integer NOT NULL
);


ALTER TABLE raw2009.wahlbewerber OWNER TO alexx;

--
-- Name: wahlbewerber_mit_wahlkreis; Type: TABLE; Schema: raw2009; Owner: alexx; Tablespace: 
--

CREATE TABLE wahlbewerber_mit_wahlkreis (
    "Vorname" character varying(100),
    "Nachname" character varying(100),
    "Jahrgang" integer,
    "Partei" character varying(100),
    "Wahlkreis" integer
);


ALTER TABLE raw2009.wahlbewerber_mit_wahlkreis OWNER TO alexx;

--
-- Name: wahlbewerber_direktkandidat; Type: VIEW; Schema: raw2009; Owner: alexx
--

CREATE VIEW wahlbewerber_direktkandidat AS
    SELECT w."Kandidatennummer", ww."Vorname", ww."Nachname", ww."Wahlkreis", public.get_partei_id_by_name(ww."Partei") AS partei_id FROM wahlbewerber_mit_wahlkreis ww, wahlbewerber w WHERE (((((ww."Vorname")::text = (w."Vorname")::text) AND ((ww."Nachname")::text = (w."Nachname")::text)) AND (ww."Jahrgang" = w."Jahrgang")) AND ((public.get_partei_id_by_name(ww."Partei") IS NULL) OR ((ww."Partei")::text = (w."Partei")::text)));


ALTER TABLE raw2009.wahlbewerber_direktkandidat OWNER TO alexx;

--
-- Name: wahlbewerber_landesliste; Type: VIEW; Schema: raw2009; Owner: alexx
--

CREATE VIEW wahlbewerber_landesliste AS
    SELECT CASE WHEN (w."Titel" IS NULL) THEN (w."Vorname")::text ELSE (((w."Titel")::text || ' '::text) || (w."Vorname")::text) END AS "VornameTitel", w."Nachname", w."Partei", w."Jahrgang", w."Kandidatennummer", lp."Landesliste", lp."Position" FROM wahlbewerber w, listenplaetze lp WHERE (w."Kandidatennummer" = lp."Kandidat");


ALTER TABLE raw2009.wahlbewerber_landesliste OWNER TO alexx;

--
-- Name: wahlkreise; Type: TABLE; Schema: raw2009; Owner: alexx; Tablespace: 
--

CREATE TABLE wahlkreise (
    "Land" character varying(100),
    "WahlkreisNr" integer NOT NULL,
    "Name" character varying(200),
    "Wahlberechtigte" integer,
    "Vorperiode" integer
);


ALTER TABLE raw2009.wahlkreise OWNER TO alexx;

SET search_path = public, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Direktkandidat" ALTER COLUMN id SET DEFAULT nextval('"Direktkandidat_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Erststimme" ALTER COLUMN id SET DEFAULT nextval('"Erststimme_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Land" ALTER COLUMN id SET DEFAULT nextval('"Land_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Landeskandidat" ALTER COLUMN id SET DEFAULT nextval('"Landeskandidat_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Landesliste" ALTER COLUMN id SET DEFAULT nextval('"Landesliste_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Partei" ALTER COLUMN id SET DEFAULT nextval('"Partei_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Wahlbezirk" ALTER COLUMN id SET DEFAULT nextval('"Wahlbezirk_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Wahlkreis" ALTER COLUMN id SET DEFAULT nextval('"Wahlkreis_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Zweitstimme" ALTER COLUMN id SET DEFAULT nextval('"Zweitstimme_id_seq"'::regclass);


SET search_path = raw2005, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: raw2005; Owner: alexx
--

ALTER TABLE ONLY wahlbewerber ALTER COLUMN id SET DEFAULT nextval('wahlbewerber_id_seq'::regclass);


SET search_path = public, pg_catalog;

--
-- Name: Direktkandidat_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Direktkandidat"
    ADD CONSTRAINT "Direktkandidat_pkey" PRIMARY KEY (id);


--
-- Name: Erststimme_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Erststimme"
    ADD CONSTRAINT "Erststimme_pkey" PRIMARY KEY (id);


--
-- Name: Jahr_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Jahr"
    ADD CONSTRAINT "Jahr_pkey" PRIMARY KEY (jahr);


--
-- Name: Land_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Land"
    ADD CONSTRAINT "Land_pkey" PRIMARY KEY (id);


--
-- Name: Landeskandidat_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Landeskandidat"
    ADD CONSTRAINT "Landeskandidat_pkey" PRIMARY KEY (id);


--
-- Name: Landesliste_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Landesliste"
    ADD CONSTRAINT "Landesliste_pkey" PRIMARY KEY (id);


--
-- Name: Partei_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Partei"
    ADD CONSTRAINT "Partei_name_key" UNIQUE (name);


--
-- Name: Partei_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Partei"
    ADD CONSTRAINT "Partei_pkey" PRIMARY KEY (id);


--
-- Name: Wahlbezirk_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Wahlbezirk"
    ADD CONSTRAINT "Wahlbezirk_pkey" PRIMARY KEY (id);


--
-- Name: Wahlkreis_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Wahlkreis"
    ADD CONSTRAINT "Wahlkreis_pkey" PRIMARY KEY (id);


--
-- Name: Zweitstimme_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY "Zweitstimme"
    ADD CONSTRAINT "Zweitstimme_pkey" PRIMARY KEY (id);


SET search_path = raw2005, pg_catalog;

--
-- Name: Wahlkreise2005_pkey; Type: CONSTRAINT; Schema: raw2005; Owner: alexx; Tablespace: 
--

ALTER TABLE ONLY wahlkreise
    ADD CONSTRAINT "Wahlkreise2005_pkey" PRIMARY KEY ("Nummer");


--
-- Name: wahlbewerber_pkey; Type: CONSTRAINT; Schema: raw2005; Owner: alexx; Tablespace: 
--

ALTER TABLE ONLY wahlbewerber
    ADD CONSTRAINT wahlbewerber_pkey PRIMARY KEY (id);


SET search_path = raw2009, pg_catalog;

--
-- Name: landeslisten_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: alexx; Tablespace: 
--

ALTER TABLE ONLY landeslisten
    ADD CONSTRAINT landeslisten_pkey PRIMARY KEY ("Listennummer");


--
-- Name: listenplaetze_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: alexx; Tablespace: 
--

ALTER TABLE ONLY listenplaetze
    ADD CONSTRAINT listenplaetze_pkey PRIMARY KEY ("Landesliste", "Kandidat");


--
-- Name: mapid_direktkandidaten_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: alexx; Tablespace: 
--

ALTER TABLE ONLY mapid_direktkandidaten
    ADD CONSTRAINT mapid_direktkandidaten_pkey PRIMARY KEY (id_old);


--
-- Name: mapid_landeskandidaten_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: alexx; Tablespace: 
--

ALTER TABLE ONLY mapid_landeskandidaten
    ADD CONSTRAINT mapid_landeskandidaten_pkey PRIMARY KEY (id_old);


--
-- Name: mapid_landeslisten_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: alexx; Tablespace: 
--

ALTER TABLE ONLY mapid_landeslisten
    ADD CONSTRAINT mapid_landeslisten_pkey PRIMARY KEY (id_old);


--
-- Name: mapid_wahlkreise_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: alexx; Tablespace: 
--

ALTER TABLE ONLY mapid_wahlkreise
    ADD CONSTRAINT mapid_wahlkreise_pkey PRIMARY KEY (id_old);


--
-- Name: wahlbewerber_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: alexx; Tablespace: 
--

ALTER TABLE ONLY wahlbewerber
    ADD CONSTRAINT wahlbewerber_pkey PRIMARY KEY ("Kandidatennummer");


--
-- Name: wahlkreise_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: alexx; Tablespace: 
--

ALTER TABLE ONLY wahlkreise
    ADD CONSTRAINT wahlkreise_pkey PRIMARY KEY ("WahlkreisNr");


SET search_path = public, pg_catalog;

--
-- Name: Direktkandidat_partei_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Direktkandidat"
    ADD CONSTRAINT "Direktkandidat_partei_id_fkey" FOREIGN KEY (partei_id) REFERENCES "Partei"(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: Direktkandidat_wahlkreis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Direktkandidat"
    ADD CONSTRAINT "Direktkandidat_wahlkreis_id_fkey" FOREIGN KEY (wahlkreis_id) REFERENCES "Wahlkreis"(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: Erststimme_direktkandidat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Erststimme"
    ADD CONSTRAINT "Erststimme_direktkandidat_id_fkey" FOREIGN KEY (direktkandidat_id) REFERENCES "Direktkandidat"(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: Erststimme_wahlbezirk_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Erststimme"
    ADD CONSTRAINT "Erststimme_wahlbezirk_id_fkey" FOREIGN KEY (wahlbezirk_id) REFERENCES "Wahlbezirk"(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: Land_jahr_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Land"
    ADD CONSTRAINT "Land_jahr_fkey" FOREIGN KEY (jahr) REFERENCES "Jahr"(jahr) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Landeskandidat_landesliste_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Landeskandidat"
    ADD CONSTRAINT "Landeskandidat_landesliste_id_fkey" FOREIGN KEY (landesliste_id) REFERENCES "Landesliste"(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: Landesliste_land_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Landesliste"
    ADD CONSTRAINT "Landesliste_land_id_fkey" FOREIGN KEY (land_id) REFERENCES "Land"(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: Landesliste_partei_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Landesliste"
    ADD CONSTRAINT "Landesliste_partei_id_fkey" FOREIGN KEY (partei_id) REFERENCES "Partei"(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: Wahlbezirk_wahlkreis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Wahlbezirk"
    ADD CONSTRAINT "Wahlbezirk_wahlkreis_id_fkey" FOREIGN KEY (wahlkreis_id) REFERENCES "Wahlkreis"(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: Wahlkreis_land_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Wahlkreis"
    ADD CONSTRAINT "Wahlkreis_land_id_fkey" FOREIGN KEY (land_id) REFERENCES "Land"(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: Zweitstimme_landesliste_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Zweitstimme"
    ADD CONSTRAINT "Zweitstimme_landesliste_id_fkey" FOREIGN KEY (landesliste_id) REFERENCES "Landesliste"(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: Zweitstimme_wahlbezirk_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "Zweitstimme"
    ADD CONSTRAINT "Zweitstimme_wahlbezirk_id_fkey" FOREIGN KEY (wahlbezirk_id) REFERENCES "Wahlbezirk"(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


SET search_path = raw2009, pg_catalog;

--
-- Name: listenplaetze_Kandidat_fkey; Type: FK CONSTRAINT; Schema: raw2009; Owner: alexx
--

ALTER TABLE ONLY listenplaetze
    ADD CONSTRAINT "listenplaetze_Kandidat_fkey" FOREIGN KEY ("Kandidat") REFERENCES wahlbewerber("Kandidatennummer");


--
-- Name: listenplaetze_Landesliste_fkey; Type: FK CONSTRAINT; Schema: raw2009; Owner: alexx
--

ALTER TABLE ONLY listenplaetze
    ADD CONSTRAINT "listenplaetze_Landesliste_fkey" FOREIGN KEY ("Landesliste") REFERENCES landeslisten("Listennummer");


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

