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
-- Name: stimmen2009; Type: SCHEMA; Schema: -; Owner: alexx
--

CREATE SCHEMA stimmen2009;


ALTER SCHEMA stimmen2009 OWNER TO alexx;

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
-- Name: create_uebrige_direktkandidaten(integer); Type: FUNCTION; Schema: public; Owner: alexx
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


ALTER FUNCTION public.create_uebrige_direktkandidaten(p_jahr integer) OWNER TO alexx;

--
-- Name: get_bundesland_id_by_name(character varying, integer); Type: FUNCTION; Schema: public; Owner: alexx
--

CREATE FUNCTION get_bundesland_id_by_name(bundesland_name character varying, jahr integer) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT l.id FROM public."land" l WHERE l.name = $1 AND l.jahr = $2 LIMIT 1;$_$;


ALTER FUNCTION public.get_bundesland_id_by_name(bundesland_name character varying, jahr integer) OWNER TO alexx;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: direktkandidat; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE direktkandidat (
    id integer NOT NULL,
    vorname character varying(50),
    nachname character varying(50),
    wahlkreis_id integer,
    partei_id integer
);


ALTER TABLE public.direktkandidat OWNER TO postgres;

--
-- Name: get_direktkandidat_by_wahlkreis_partei_jahr(character varying, character varying, integer); Type: FUNCTION; Schema: public; Owner: alexx
--

CREATE FUNCTION get_direktkandidat_by_wahlkreis_partei_jahr(character varying, character varying, integer) RETURNS direktkandidat
    LANGUAGE sql
    AS $_$
SELECT * 
	FROM "direktkandidat" 
	WHERE wahlkreis_id = (SELECT id FROM get_wahlkreis_by_jahr_and_name($3, $1))
	AND partei_id = get_partei_id_by_name($2)
$_$;


ALTER FUNCTION public.get_direktkandidat_by_wahlkreis_partei_jahr(character varying, character varying, integer) OWNER TO alexx;

--
-- Name: get_direktkandidat_id_by_wahlkreis_partei_jahr(character varying, character varying, integer); Type: FUNCTION; Schema: public; Owner: alexx
--

CREATE FUNCTION get_direktkandidat_id_by_wahlkreis_partei_jahr(character varying, character varying, integer) RETURNS integer
    LANGUAGE sql
    AS $_$
SELECT id 
	FROM "direktkandidat" 
	WHERE wahlkreis_id = (SELECT id FROM get_wahlkreis_by_jahr_and_name($3, $1))
	AND partei_id = get_partei_id_by_name($2)
$_$;


ALTER FUNCTION public.get_direktkandidat_id_by_wahlkreis_partei_jahr(character varying, character varying, integer) OWNER TO alexx;

--
-- Name: land; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE land (
    id integer NOT NULL,
    name character varying(30),
    jahr integer
);


ALTER TABLE public.land OWNER TO postgres;

--
-- Name: get_laender_by_jahr(integer); Type: FUNCTION; Schema: public; Owner: alexx
--

CREATE FUNCTION get_laender_by_jahr(integer) RETURNS SETOF land
    LANGUAGE sql
    AS $_$
SELECT * FROM "land" WHERE jahr = $1;$_$;


ALTER FUNCTION public.get_laender_by_jahr(integer) OWNER TO alexx;

--
-- Name: landesliste; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE landesliste (
    id integer NOT NULL,
    listenplatz integer,
    land_id integer,
    partei_id integer
);


ALTER TABLE public.landesliste OWNER TO postgres;

--
-- Name: get_landesliste_by_jahr(integer); Type: FUNCTION; Schema: public; Owner: alexx
--

CREATE FUNCTION get_landesliste_by_jahr(integer) RETURNS SETOF landesliste
    LANGUAGE sql
    AS $_$SELECT * FROM "landesliste" WHERE land_id IN (SELECT id FROM "land" WHERE jahr = $1);$_$;


ALTER FUNCTION public.get_landesliste_by_jahr(integer) OWNER TO alexx;

--
-- Name: get_landesliste_id_by_wahlkreis_partei_jahr(character varying, character varying, integer); Type: FUNCTION; Schema: public; Owner: alexx
--

CREATE FUNCTION get_landesliste_id_by_wahlkreis_partei_jahr(character varying, character varying, integer) RETURNS integer
    LANGUAGE sql
    AS $_$
SELECT id 
	FROM landesliste 
	WHERE land_id = (SELECT land_id FROM get_wahlkreis_by_jahr_and_name($3, $1))
	AND partei_id = get_partei_id_by_name($2)
$_$;


ALTER FUNCTION public.get_landesliste_id_by_wahlkreis_partei_jahr(character varying, character varying, integer) OWNER TO alexx;

--
-- Name: get_partei_id_by_name(character varying); Type: FUNCTION; Schema: public; Owner: alexx
--

CREATE FUNCTION get_partei_id_by_name(partei_name character varying) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT p.id FROM public."partei" p WHERE p.name = $1 LIMIT 1;$_$;


ALTER FUNCTION public.get_partei_id_by_name(partei_name character varying) OWNER TO alexx;

--
-- Name: wahlkreis; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE wahlkreis (
    id integer NOT NULL,
    name character varying(100),
    land_id integer
);


ALTER TABLE public.wahlkreis OWNER TO postgres;

--
-- Name: get_wahlkreis_by_jahr(integer); Type: FUNCTION; Schema: public; Owner: alexx
--

CREATE FUNCTION get_wahlkreis_by_jahr(integer) RETURNS SETOF wahlkreis
    LANGUAGE sql
    AS $_$
SELECT * FROM "wahlkreis" WHERE land_id IN (SELECT id FROM "land" WHERE jahr = $1);$_$;


ALTER FUNCTION public.get_wahlkreis_by_jahr(integer) OWNER TO alexx;

--
-- Name: get_wahlkreis_by_jahr_and_name(integer, character varying); Type: FUNCTION; Schema: public; Owner: alexx
--

CREATE FUNCTION get_wahlkreis_by_jahr_and_name(integer, character varying) RETURNS wahlkreis
    LANGUAGE sql
    AS $_$
SELECT * 
	FROM "wahlkreis" 
	WHERE land_id IN (SELECT id FROM "land" WHERE jahr = $1)
	AND "name" = $2;
$_$;


ALTER FUNCTION public.get_wahlkreis_by_jahr_and_name(integer, character varying) OWNER TO alexx;

--
-- Name: get_wahlkreis_id_by_jahr_and_name(integer, character varying); Type: FUNCTION; Schema: public; Owner: alexx
--

CREATE FUNCTION get_wahlkreis_id_by_jahr_and_name(integer, character varying) RETURNS integer
    LANGUAGE sql
    AS $_$
SELECT id 
	FROM "wahlkreis" 
	WHERE land_id IN (SELECT id FROM "land" WHERE jahr = $1)
	AND "name" = $2;
$_$;


ALTER FUNCTION public.get_wahlkreis_id_by_jahr_and_name(integer, character varying) OWNER TO alexx;

--
-- Name: initialize_db(); Type: FUNCTION; Schema: public; Owner: alexx
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


ALTER FUNCTION public.initialize_db() OWNER TO alexx;

--
-- Name: reset_db(); Type: FUNCTION; Schema: public; Owner: alexx
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


ALTER FUNCTION public.reset_db() OWNER TO alexx;

--
-- Name: scherper_faktoren(); Type: FUNCTION; Schema: public; Owner: alexx
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


ALTER FUNCTION public.scherper_faktoren() OWNER TO alexx;

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

--
-- Name: import_parteien(); Type: FUNCTION; Schema: raw2005; Owner: alexx
--

CREATE FUNCTION import_parteien() RETURNS void
    LANGUAGE sql
    AS $$
INSERT INTO "Partei" ("name") SELECT * FROM
(
	SELECT DISTINCT trim("Partei") FROM raw2005.wahlbewerber WHERE "Partei" IS NOT NULL AND trim("Partei") NOT IN
		(SELECT "name" FROM "Partei")
) p;
$$;


ALTER FUNCTION raw2005.import_parteien() OWNER TO alexx;

--
-- Name: import_wahlkreise(); Type: FUNCTION; Schema: raw2005; Owner: alexx
--

CREATE FUNCTION import_wahlkreise() RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE
	rec record;

	newid integer;
BEGIN

	EXECUTE 'DROP TABLE IF EXISTS raw2005.mapid_wahlkreise';
	EXECUTE 'CREATE TABLE raw2005.mapid_wahlkreise ( id_old INTEGER PRIMARY KEY, id_new INTEGER );';

	DELETE FROM "Wahlkreis" WHERE land_id IN (SELECT id FROM "Land" WHERE jahr=2005); --Alte 2005er einträge löschen

	FOR rec IN SELECT 
			"Nummer" wknr, 
			"Name" n , 
			get_bundesland_id_by_name("Land", 2005) blnr
		FROM raw2005.wahlkreise 
	LOOP

		INSERT INTO "Wahlkreis" ("name", "land_id") 
			VALUES ( rec.n, rec.blnr ) 
			RETURNING "id" INTO newid;

		INSERT INTO raw2005."mapid_wahlkreise"  ( "id_old", "id_new" )
			VALUES  ( rec.wknr, newid );


		
	END LOOP;

	EXECUTE 'CREATE OR REPLACE FUNCTION raw2005.map_wahlkreis(integer)
  RETURNS integer AS
''SELECT id_new FROM raw2005.mapid_wahlkreise WHERE id_old = $1 LIMIT 1;''
  LANGUAGE sql VOLATILE
  COST 100;';
	 
END;
$_$;


ALTER FUNCTION raw2005.import_wahlkreise() OWNER TO alexx;

--
-- Name: map_wahlkreis(integer); Type: FUNCTION; Schema: raw2005; Owner: alexx
--

CREATE FUNCTION map_wahlkreis(integer) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT id_new FROM raw2005.mapid_wahlkreise WHERE id_old = $1 LIMIT 1;$_$;


ALTER FUNCTION raw2005.map_wahlkreis(integer) OWNER TO alexx;

SET search_path = raw2009, pg_catalog;

--
-- Name: import_bundeslaender(); Type: FUNCTION; Schema: raw2009; Owner: alexx
--

CREATE FUNCTION import_bundeslaender() RETURNS void
    LANGUAGE sql
    AS $$
INSERT INTO "land" ("name", "jahr") SELECT DISTINCT "Bundesland", 2009 FROM raw2009.landeslisten;
$$;


ALTER FUNCTION raw2009.import_bundeslaender() OWNER TO alexx;

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

	DELETE FROM "direktkandidat" WHERE wahlkreis_id IN (SELECT id FROM get_wahlkreis_by_jahr(2009)); --Alte 2009er wahlkreise löschen

	FOR rec IN SELECT 
			"Kandidatennummer",
			"Vorname",
			"Nachname", 
			"Wahlkreis",
			"partei_id"
		FROM raw2009."wahlbewerber_direktkandidat"
	LOOP

		INSERT INTO "direktkandidat" ("vorname", "nachname", "wahlkreis_id", "partei_id") 
			VALUES ( rec."Vorname", rec."Nachname", raw2009.map_wahlkreis( rec."Wahlkreis" ), rec.partei_id )
			RETURNING "id" INTO newid;

		INSERT INTO raw2009."mapid_direktkandidaten"  ( "id_old", "id_new" )
			VALUES  ( rec."Kandidatennummer", newid );

	END LOOP;

	EXECUTE 'CREATE OR REPLACE FUNCTION raw2009.map_direktkandidat(integer)
  RETURNS integer AS
''SELECT id_new FROM raw2009.mapid_direktkandidaten WHERE id_old = $1 LIMIT 1;''
  LANGUAGE sql VOLATILE
  COST 100;';

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

	DELETE FROM "landeskandidat" WHERE landesliste_id IN (SELECT id FROM get_landesliste_by_jahr(2009)); --Alte 2009er einträge löschen

	FOR rec IN SELECT 
			"Kandidatennummer",
			"VornameTitel",
			"Nachname", 
			"Position",
			"Landesliste"
		FROM raw2009."wahlbewerber_landesliste"
	LOOP

		INSERT INTO "landeskandidat" ("vorname", "nachname", "listenrang", "landesliste_id") 
			VALUES ( rec."VornameTitel", rec."Nachname", rec."Position", raw2009.map_landesliste(rec."Landesliste") )
			RETURNING "id" INTO newid;

		INSERT INTO raw2009."mapid_landeskandidaten"  ( "id_old", "id_new" )
			VALUES  ( rec."Kandidatennummer", newid );
		
	END LOOP;

	EXECUTE 'CREATE OR REPLACE FUNCTION raw2009.map_landeskandidat(integer)
  RETURNS integer AS
''SELECT id_new FROM raw2009.mapid_landeskandidaten WHERE id_old = $1 LIMIT 1;''
  LANGUAGE sql VOLATILE
  COST 100;';

END;

$_$;


ALTER FUNCTION raw2009.import_landeskandidaten() OWNER TO alexx;

--
-- Name: import_landeslisten(); Type: FUNCTION; Schema: raw2009; Owner: alexx
--

CREATE FUNCTION import_landeslisten() RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE
	rec record;

	newid integer;
BEGIN

	EXECUTE 'DROP TABLE IF EXISTS raw2009.mapid_landeslisten';
	EXECUTE 'CREATE TABLE raw2009.mapid_landeslisten ( id_old INTEGER PRIMARY KEY, id_new INTEGER );';

	DELETE FROM "landesliste" WHERE land_id IN (SELECT id FROM "land" WHERE jahr=2009); --Alte 2009er landesliste löschen

	FOR rec IN SELECT 
			"Listennummer" listen_nr,
			get_bundesland_id_by_name("Bundesland", 2009) land_id,
			get_partei_id_by_name("Partei") partei_id
		FROM raw2009."landeslisten"
	LOOP

		INSERT INTO "landesliste" ("listenplatz", "land_id", "partei_id") 
			VALUES ( rec.listen_nr, rec.land_id, rec.partei_id ) 
			RETURNING "id" INTO newid;

		INSERT INTO raw2009."mapid_landeslisten"  ( "id_old", "id_new" )
			VALUES  ( rec.listen_nr, newid );
		
	END LOOP;

	EXECUTE 'CREATE OR REPLACE FUNCTION raw2009.map_landesliste(integer)
  RETURNS integer AS
''SELECT id_new FROM raw2009.mapid_landeslisten WHERE id_old = $1 LIMIT 1;''
  LANGUAGE sql VOLATILE
  COST 100;';
	
END;
$_$;


ALTER FUNCTION raw2009.import_landeslisten() OWNER TO alexx;

--
-- Name: import_parteien(); Type: FUNCTION; Schema: raw2009; Owner: alexx
--

CREATE FUNCTION import_parteien() RETURNS void
    LANGUAGE sql
    AS $$
--DELETE FROM "Partei";
INSERT INTO "partei" ("name") SELECT * FROM
(
	SELECT DISTINCT trim("Partei") partei FROM raw2009.landeslisten
	UNION
	SELECT DISTINCT trim("Partei") partei FROM raw2009.wahlbewerber WHERE "Partei" IS NOT NULL
) p
WHERE p.partei NOT IN (SELECT "name" FROM "partei");
$$;


ALTER FUNCTION raw2009.import_parteien() OWNER TO alexx;

--
-- Name: import_wahlkreise(); Type: FUNCTION; Schema: raw2009; Owner: alexx
--

CREATE FUNCTION import_wahlkreise() RETURNS void
    LANGUAGE plpgsql
    AS $_$
DECLARE
	rec record;

	newid integer;
BEGIN

	EXECUTE 'DROP TABLE IF EXISTS raw2009.mapid_wahlkreise';
	EXECUTE 'CREATE TABLE raw2009.mapid_wahlkreise ( id_old INTEGER PRIMARY KEY, id_new INTEGER );';

	DELETE FROM "wahlkreis" WHERE land_id IN (SELECT id FROM "land" WHERE jahr=2009); --Alte 2009er wahlkreise löschen

	FOR rec IN SELECT 
			"WahlkreisNr" wknr, 
			"Name" n , 
			get_bundesland_id_by_name("Land", 2009) blnr,
			"Wahlberechtigte" ber
		FROM raw2009.wahlkreise 
		WHERE "WahlkreisNr" < 900 --WahlkreisNr >=900 sind "Insgesamt Werte"
	LOOP

		INSERT INTO "wahlkreis" ("name", "land_id") 
			VALUES ( rec.n, rec.blnr ) 
			RETURNING "id" INTO newid;

		INSERT INTO raw2009."mapid_wahlkreise"  ( "id_old", "id_new" )
			VALUES  ( rec.wknr, newid );
		
	END LOOP;

	EXECUTE 'CREATE OR REPLACE FUNCTION raw2009.map_wahlkreis(integer)
  RETURNS integer AS
''SELECT id_new FROM raw2009.mapid_wahlkreise WHERE id_old = $1 LIMIT 1;''
  LANGUAGE sql VOLATILE
  COST 100;';
	 
END;
$_$;


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

ALTER SEQUENCE "Direktkandidat_id_seq" OWNED BY direktkandidat.id;


--
-- Name: erststimme; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE erststimme (
    id integer NOT NULL,
    wahlkreis_id integer,
    direktkandidat_id integer
);


ALTER TABLE public.erststimme OWNER TO postgres;

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

ALTER SEQUENCE "Erststimme_id_seq" OWNED BY erststimme.id;


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

ALTER SEQUENCE "Land_id_seq" OWNED BY land.id;


--
-- Name: landeskandidat; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE landeskandidat (
    id integer NOT NULL,
    vorname character varying(50),
    nachname character varying(50),
    listenrang integer,
    landesliste_id integer
);


ALTER TABLE public.landeskandidat OWNER TO postgres;

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

ALTER SEQUENCE "Landeskandidat_id_seq" OWNED BY landeskandidat.id;


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

ALTER SEQUENCE "Landesliste_id_seq" OWNED BY landesliste.id;


--
-- Name: partei; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE partei (
    name character varying(150),
    id integer NOT NULL
);


ALTER TABLE public.partei OWNER TO postgres;

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

ALTER SEQUENCE "Partei_id_seq" OWNED BY partei.id;


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

ALTER SEQUENCE "Wahlkreis_id_seq" OWNED BY wahlkreis.id;


--
-- Name: zweitstimme; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE zweitstimme (
    id integer NOT NULL,
    wahlkreis_id integer,
    landesliste_id integer
);


ALTER TABLE public.zweitstimme OWNER TO postgres;

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

ALTER SEQUENCE "Zweitstimme_id_seq" OWNED BY zweitstimme.id;


SET search_path = stimmen2009, pg_catalog;

--
-- Name: ErststimmenEndgueltig; Type: TABLE; Schema: stimmen2009; Owner: alexx; Tablespace: 
--

CREATE TABLE "ErststimmenEndgueltig" (
    "Nr" integer,
    "GehoertZu" integer,
    "Partei" character varying(100),
    "Gebiet" character varying(100),
    "Stimmen" integer
);


ALTER TABLE stimmen2009."ErststimmenEndgueltig" OWNER TO alexx;

--
-- Name: direktkandidat_stimmen; Type: VIEW; Schema: stimmen2009; Owner: alexx
--

CREATE VIEW direktkandidat_stimmen AS
    SELECT public.get_direktkandidat_id_by_wahlkreis_partei_jahr("ErststimmenEndgueltig"."Gebiet", "ErststimmenEndgueltig"."Partei", 2009) AS kandidat_id, "ErststimmenEndgueltig"."Stimmen" AS stimmen, public.get_wahlkreis_id_by_jahr_and_name(2009, "ErststimmenEndgueltig"."Gebiet") AS wahlkreis_id FROM "ErststimmenEndgueltig" WHERE ((((("ErststimmenEndgueltig"."Partei")::text IN (SELECT partei.name FROM public.partei)) AND ("ErststimmenEndgueltig"."GehoertZu" IS NOT NULL)) AND (("ErststimmenEndgueltig"."Gebiet")::text IN (SELECT get_wahlkreis_by_jahr.name FROM public.get_wahlkreis_by_jahr(2009) get_wahlkreis_by_jahr(id, name, land_id)))) AND ("ErststimmenEndgueltig"."Stimmen" IS NOT NULL));


ALTER TABLE stimmen2009.direktkandidat_stimmen OWNER TO alexx;

--
-- Name: erststimme_ungueltige; Type: VIEW; Schema: stimmen2009; Owner: alexx
--

CREATE VIEW erststimme_ungueltige AS
    SELECT public.get_wahlkreis_id_by_jahr_and_name(2009, "ErststimmenEndgueltig"."Gebiet") AS wahlkreis_id, "ErststimmenEndgueltig"."Stimmen" AS stimmen FROM "ErststimmenEndgueltig" WHERE ((((("ErststimmenEndgueltig"."Partei")::text = 'Ungültige'::text) AND ("ErststimmenEndgueltig"."GehoertZu" IS NOT NULL)) AND (("ErststimmenEndgueltig"."Gebiet")::text IN (SELECT get_wahlkreis_by_jahr.name FROM public.get_wahlkreis_by_jahr(2009) get_wahlkreis_by_jahr(id, name, land_id)))) AND ("ErststimmenEndgueltig"."Stimmen" IS NOT NULL));


ALTER TABLE stimmen2009.erststimme_ungueltige OWNER TO alexx;

--
-- Name: erststimme_insges; Type: VIEW; Schema: stimmen2009; Owner: alexx
--

CREATE VIEW erststimme_insges AS
    SELECT direktkandidat_stimmen.kandidat_id, direktkandidat_stimmen.stimmen, direktkandidat_stimmen.wahlkreis_id FROM direktkandidat_stimmen UNION ALL SELECT NULL::integer AS kandidat_id, erststimme_ungueltige.stimmen, erststimme_ungueltige.wahlkreis_id FROM erststimme_ungueltige;


ALTER TABLE stimmen2009.erststimme_insges OWNER TO alexx;

SET search_path = public, pg_catalog;

--
-- Name: erststimmen_aggregation; Type: VIEW; Schema: public; Owner: alexx
--

CREATE VIEW erststimmen_aggregation AS
    SELECT erststimme_insges.kandidat_id AS direktkandidat_id, erststimme_insges.stimmen, erststimme_insges.wahlkreis_id FROM stimmen2009.erststimme_insges;


ALTER TABLE public.erststimmen_aggregation OWNER TO alexx;

--
-- Name: direktkandidat_gewinner; Type: VIEW; Schema: public; Owner: alexx
--

CREATE VIEW direktkandidat_gewinner AS
    WITH max_stimmen_per_wahlkreis AS (SELECT ea2.wahlkreis_id, max(ea2.stimmen) AS max_stimmen FROM erststimmen_aggregation ea2 GROUP BY ea2.wahlkreis_id) SELECT ea.wahlkreis_id, ea.direktkandidat_id, ea.stimmen FROM erststimmen_aggregation ea, max_stimmen_per_wahlkreis mspw WHERE ((ea.wahlkreis_id = mspw.wahlkreis_id) AND (ea.stimmen = mspw.max_stimmen));


ALTER TABLE public.direktkandidat_gewinner OWNER TO alexx;

--
-- Name: direktkandidaten_pro_partei; Type: VIEW; Schema: public; Owner: alexx
--

CREATE VIEW direktkandidaten_pro_partei AS
    SELECT d.partei_id, count(*) AS count FROM direktkandidat_gewinner dg, direktkandidat d WHERE (dg.direktkandidat_id = d.id) GROUP BY d.partei_id;


ALTER TABLE public.direktkandidaten_pro_partei OWNER TO alexx;

--
-- Name: jahr; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE jahr (
    jahr integer NOT NULL
);


ALTER TABLE public.jahr OWNER TO postgres;

SET search_path = stimmen2009, pg_catalog;

--
-- Name: ZweitstimmenEndgueltig; Type: TABLE; Schema: stimmen2009; Owner: alexx; Tablespace: 
--

CREATE TABLE "ZweitstimmenEndgueltig" (
    "Nr" integer,
    "GehoertZu" integer,
    "Partei" character varying(100),
    "Gebiet" character varying(100),
    "Stimmen" integer
);


ALTER TABLE stimmen2009."ZweitstimmenEndgueltig" OWNER TO alexx;

--
-- Name: landesliste_stimmen; Type: VIEW; Schema: stimmen2009; Owner: alexx
--

CREATE VIEW landesliste_stimmen AS
    SELECT public.get_landesliste_id_by_wahlkreis_partei_jahr(ee."Gebiet", ee."Partei", 2009) AS landesliste_id, ee."Stimmen" AS stimmen, public.get_wahlkreis_id_by_jahr_and_name(2009, ee."Gebiet") AS wahlkreis_id FROM "ZweitstimmenEndgueltig" ee WHERE (((((ee."Partei")::text IN (SELECT partei.name FROM public.partei)) AND (ee."GehoertZu" IS NOT NULL)) AND ((ee."Gebiet")::text IN (SELECT get_wahlkreis_by_jahr.name FROM public.get_wahlkreis_by_jahr(2009) get_wahlkreis_by_jahr(id, name, land_id)))) AND (ee."Stimmen" IS NOT NULL));


ALTER TABLE stimmen2009.landesliste_stimmen OWNER TO alexx;

SET search_path = public, pg_catalog;

--
-- Name: partei_zweitstimmen_alexx; Type: VIEW; Schema: public; Owner: alexx
--

CREATE VIEW partei_zweitstimmen_alexx AS
    SELECT l.partei_id, sum(st.stimmen) AS stimmen FROM stimmen2009.landesliste_stimmen st, landesliste l WHERE (st.landesliste_id = l.id) GROUP BY l.partei_id;


ALTER TABLE public.partei_zweitstimmen_alexx OWNER TO alexx;

SET search_path = stimmen2009, pg_catalog;

--
-- Name: zweitstimme_ungueltige; Type: VIEW; Schema: stimmen2009; Owner: alexx
--

CREATE VIEW zweitstimme_ungueltige AS
    SELECT public.get_wahlkreis_id_by_jahr_and_name(2009, "ZweitstimmenEndgueltig"."Gebiet") AS wahlkreis_id, "ZweitstimmenEndgueltig"."Stimmen" AS stimmen FROM "ZweitstimmenEndgueltig" WHERE ((((("ZweitstimmenEndgueltig"."Partei")::text = 'Ungültige'::text) AND ("ZweitstimmenEndgueltig"."GehoertZu" IS NOT NULL)) AND (("ZweitstimmenEndgueltig"."Gebiet")::text IN (SELECT get_wahlkreis_by_jahr.name FROM public.get_wahlkreis_by_jahr(2009) get_wahlkreis_by_jahr(id, name, land_id)))) AND ("ZweitstimmenEndgueltig"."Stimmen" IS NOT NULL));


ALTER TABLE stimmen2009.zweitstimme_ungueltige OWNER TO alexx;

SET search_path = public, pg_catalog;

--
-- Name: zweitstimmen_aggregation; Type: VIEW; Schema: public; Owner: alexx
--

CREATE VIEW zweitstimmen_aggregation AS
    SELECT ll.partei_id, s.wahlkreis_id, s.stimmen FROM stimmen2009.landesliste_stimmen s, landesliste ll WHERE (s.landesliste_id = ll.id) UNION ALL SELECT NULL::integer AS partei_id, s.wahlkreis_id, s.stimmen FROM stimmen2009.zweitstimme_ungueltige s;


ALTER TABLE public.zweitstimmen_aggregation OWNER TO alexx;

--
-- Name: zweitstimmen_prozent; Type: VIEW; Schema: public; Owner: alexx
--

CREATE VIEW zweitstimmen_prozent AS
    WITH zweitstimmen_pro_partei AS (SELECT zweitstimmen_aggregation.partei_id, sum(zweitstimmen_aggregation.stimmen) AS stimmen FROM zweitstimmen_aggregation GROUP BY zweitstimmen_aggregation.partei_id), zweitstimmen_gesamt AS (SELECT sum(zweitstimmen_aggregation.stimmen) AS gesamtstimmen FROM zweitstimmen_aggregation WHERE (zweitstimmen_aggregation.partei_id IS NOT NULL)) SELECT zspp.partei_id, (((100 * zspp.stimmen))::numeric / (ges.gesamtstimmen)::numeric) AS prozent FROM zweitstimmen_pro_partei zspp, zweitstimmen_gesamt ges ORDER BY (((100 * zspp.stimmen))::numeric / (ges.gesamtstimmen)::numeric) DESC;


ALTER TABLE public.zweitstimmen_prozent OWNER TO alexx;

--
-- Name: parteien_einzug; Type: VIEW; Schema: public; Owner: siggi
--

CREATE VIEW parteien_einzug AS
    SELECT zweitstimmen_prozent.partei_id FROM zweitstimmen_prozent WHERE (zweitstimmen_prozent.prozent > (5)::numeric) UNION SELECT direktkandidaten_pro_partei.partei_id FROM direktkandidaten_pro_partei WHERE (direktkandidaten_pro_partei.count > 2);


ALTER TABLE public.parteien_einzug OWNER TO siggi;

--
-- Name: scherperfaktoren; Type: TABLE; Schema: public; Owner: alexx; Tablespace: 
--

CREATE TABLE scherperfaktoren (
    faktor numeric NOT NULL
);


ALTER TABLE public.scherperfaktoren OWNER TO alexx;

--
-- Name: scherper_auswertung_alexx; Type: VIEW; Schema: public; Owner: alexx
--

CREATE VIEW scherper_auswertung_alexx AS
    SELECT pza.partei_id, ((pza.stimmen)::numeric / s.faktor) AS gewicht FROM partei_zweitstimmen_alexx pza, scherperfaktoren s WHERE (((pza.stimmen)::numeric / (SELECT sum(partei_zweitstimmen_alexx.stimmen) AS sum FROM partei_zweitstimmen_alexx)) >= 0.05) ORDER BY ((pza.stimmen)::numeric / s.faktor) DESC;


ALTER TABLE public.scherper_auswertung_alexx OWNER TO alexx;

--
-- Name: scherper_auswertung_final; Type: VIEW; Schema: public; Owner: siggi
--

CREATE VIEW scherper_auswertung_final AS
    SELECT pza.partei_id, ((pza.stimmen)::numeric / s.faktor) AS gewicht FROM partei_zweitstimmen_alexx pza, scherperfaktoren s WHERE (pza.partei_id IN (SELECT parteien_einzug.partei_id FROM parteien_einzug)) ORDER BY ((pza.stimmen)::numeric / s.faktor) DESC;


ALTER TABLE public.scherper_auswertung_final OWNER TO siggi;

--
-- Name: sitzverteilung_partei_alexx; Type: VIEW; Schema: public; Owner: alexx
--

CREATE VIEW sitzverteilung_partei_alexx AS
    WITH auswetung AS (SELECT scherper_auswertung_alexx.partei_id, scherper_auswertung_alexx.gewicht FROM scherper_auswertung_alexx, partei p WHERE (scherper_auswertung_alexx.partei_id = p.id) LIMIT 598) SELECT auswetung.partei_id, p.name, count(*) AS count FROM auswetung, partei p WHERE (auswetung.partei_id = p.id) GROUP BY auswetung.partei_id, p.name ORDER BY count(*) DESC;


ALTER TABLE public.sitzverteilung_partei_alexx OWNER TO alexx;

--
-- Name: sitzeParteiBundesland_alexx; Type: VIEW; Schema: public; Owner: alexx
--

CREATE VIEW "sitzeParteiBundesland_alexx" AS
    WITH wahlkreise_pro_land AS (SELECT get_wahlkreis_by_jahr.land_id, count(*) AS wk_count FROM get_wahlkreis_by_jahr(2009) get_wahlkreis_by_jahr(id, name, land_id) GROUP BY get_wahlkreis_by_jahr.land_id) SELECT sv.partei_id, round((((((sv.count * wpl.wk_count) * 2))::double precision / (598)::double precision))::numeric, 0) AS sitze, wpl.land_id FROM sitzverteilung_partei_alexx sv, wahlkreise_pro_land wpl;


ALTER TABLE public."sitzeParteiBundesland_alexx" OWNER TO alexx;

SET search_path = raw2005, pg_catalog;

--
-- Name: bundeslandkuerzel; Type: TABLE; Schema: raw2005; Owner: alexx; Tablespace: 
--

CREATE TABLE bundeslandkuerzel (
    name character varying(100),
    kuerzel_5 character varying(5),
    kuerzel_2 character varying(2) NOT NULL
);


ALTER TABLE raw2005.bundeslandkuerzel OWNER TO alexx;

--
-- Name: mapid_wahlkreise; Type: TABLE; Schema: raw2005; Owner: alexx; Tablespace: 
--

CREATE TABLE mapid_wahlkreise (
    id_old integer NOT NULL,
    id_new integer
);


ALTER TABLE raw2005.mapid_wahlkreise OWNER TO alexx;

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
-- Name: wahlbewerber_mit_land; Type: VIEW; Schema: raw2005; Owner: alexx
--

CREATE VIEW wahlbewerber_mit_land AS
    SELECT wb."Vorname", wb."Name", wb."Partei", wb."Wahlkreis", wb."Land", wb."Platz", wb.id, kz.name AS land_name FROM wahlbewerber wb, bundeslandkuerzel kz WHERE ((wb."Land")::text = (kz.kuerzel_2)::text);


ALTER TABLE raw2005.wahlbewerber_mit_land OWNER TO alexx;

--
-- Name: wahlbewerber_direktkandidat; Type: VIEW; Schema: raw2005; Owner: alexx
--

CREATE VIEW wahlbewerber_direktkandidat AS
    SELECT w.id, w."Vorname", w."Name", w."Wahlkreis", public.get_partei_id_by_name(w."Partei") AS partei_id FROM wahlbewerber_mit_land w WHERE (w."Wahlkreis" IS NOT NULL);


ALTER TABLE raw2005.wahlbewerber_direktkandidat OWNER TO alexx;

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
-- Name: wahlbewerber_landesliste; Type: VIEW; Schema: raw2005; Owner: alexx
--

CREATE VIEW wahlbewerber_landesliste AS
    SELECT w.id, w."Vorname", w."Name", w."Wahlkreis", public.get_partei_id_by_name(w."Partei") AS partei_id FROM wahlbewerber_mit_land w WHERE (w."Wahlkreis" IS NULL);


ALTER TABLE raw2005.wahlbewerber_landesliste OWNER TO alexx;

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
-- Name: wahlbewerber_mit_titel; Type: VIEW; Schema: raw2009; Owner: alexx
--

CREATE VIEW wahlbewerber_mit_titel AS
    SELECT CASE WHEN (w."Titel" IS NULL) THEN (w."Vorname")::text ELSE (((w."Titel")::text || ' '::text) || (w."Vorname")::text) END AS "Vorname", w."Nachname", w."Partei", w."Jahrgang", w."Kandidatennummer" FROM wahlbewerber w;


ALTER TABLE raw2009.wahlbewerber_mit_titel OWNER TO alexx;

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
    SELECT w."Kandidatennummer", ww."Vorname", ww."Nachname", ww."Wahlkreis", public.get_partei_id_by_name(ww."Partei") AS partei_id FROM wahlbewerber_mit_wahlkreis ww, wahlbewerber_mit_titel w WHERE (((((ww."Vorname")::text = w."Vorname") AND ((ww."Nachname")::text = (w."Nachname")::text)) AND (ww."Jahrgang" = w."Jahrgang")) AND ((public.get_partei_id_by_name(ww."Partei") IS NULL) OR ((ww."Partei")::text = (w."Partei")::text)));


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

SET search_path = stimmen2009, pg_catalog;

--
-- Name: direktkandidat_uebrige; Type: VIEW; Schema: stimmen2009; Owner: alexx
--

CREATE VIEW direktkandidat_uebrige AS
    SELECT public.get_wahlkreis_id_by_jahr_and_name(2009, "ErststimmenEndgueltig"."Gebiet") AS wahlkreis_id, "ErststimmenEndgueltig"."Stimmen" AS stimmen FROM "ErststimmenEndgueltig" WHERE ((((("ErststimmenEndgueltig"."Partei")::text = 'Übrige'::text) AND ("ErststimmenEndgueltig"."GehoertZu" IS NOT NULL)) AND (("ErststimmenEndgueltig"."Gebiet")::text IN (SELECT get_wahlkreis_by_jahr.name FROM public.get_wahlkreis_by_jahr(2009) get_wahlkreis_by_jahr(id, name, land_id)))) AND ("ErststimmenEndgueltig"."Stimmen" IS NOT NULL));


ALTER TABLE stimmen2009.direktkandidat_uebrige OWNER TO alexx;

--
-- Name: erststimmen_statistik; Type: VIEW; Schema: stimmen2009; Owner: alexx
--

CREATE VIEW erststimmen_statistik AS
    SELECT "ErststimmenEndgueltig"."Nr", "ErststimmenEndgueltig"."GehoertZu", "ErststimmenEndgueltig"."Partei", "ErststimmenEndgueltig"."Gebiet", "ErststimmenEndgueltig"."Stimmen" FROM "ErststimmenEndgueltig" WHERE ("ErststimmenEndgueltig"."GehoertZu" IS NULL);


ALTER TABLE stimmen2009.erststimmen_statistik OWNER TO alexx;

--
-- Name: zweitstimme_insges; Type: VIEW; Schema: stimmen2009; Owner: alexx
--

CREATE VIEW zweitstimme_insges AS
    SELECT landesliste_stimmen.landesliste_id, landesliste_stimmen.stimmen, landesliste_stimmen.wahlkreis_id FROM landesliste_stimmen UNION ALL SELECT NULL::integer AS landesliste_id, zweitstimme_ungueltige.stimmen, zweitstimme_ungueltige.wahlkreis_id FROM zweitstimme_ungueltige;


ALTER TABLE stimmen2009.zweitstimme_insges OWNER TO alexx;

--
-- Name: zweitstimmen_statistik; Type: VIEW; Schema: stimmen2009; Owner: alexx
--

CREATE VIEW zweitstimmen_statistik AS
    SELECT "ZweitstimmenEndgueltig"."Nr", "ZweitstimmenEndgueltig"."GehoertZu", "ZweitstimmenEndgueltig"."Partei", "ZweitstimmenEndgueltig"."Gebiet", "ZweitstimmenEndgueltig"."Stimmen" FROM "ZweitstimmenEndgueltig" WHERE ("ZweitstimmenEndgueltig"."GehoertZu" IS NULL);


ALTER TABLE stimmen2009.zweitstimmen_statistik OWNER TO alexx;

SET search_path = public, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY direktkandidat ALTER COLUMN id SET DEFAULT nextval('"Direktkandidat_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY erststimme ALTER COLUMN id SET DEFAULT nextval('"Erststimme_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY land ALTER COLUMN id SET DEFAULT nextval('"Land_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY landeskandidat ALTER COLUMN id SET DEFAULT nextval('"Landeskandidat_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY landesliste ALTER COLUMN id SET DEFAULT nextval('"Landesliste_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY partei ALTER COLUMN id SET DEFAULT nextval('"Partei_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY wahlkreis ALTER COLUMN id SET DEFAULT nextval('"Wahlkreis_id_seq"'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY zweitstimme ALTER COLUMN id SET DEFAULT nextval('"Zweitstimme_id_seq"'::regclass);


SET search_path = raw2005, pg_catalog;

--
-- Name: id; Type: DEFAULT; Schema: raw2005; Owner: alexx
--

ALTER TABLE ONLY wahlbewerber ALTER COLUMN id SET DEFAULT nextval('wahlbewerber_id_seq'::regclass);


SET search_path = public, pg_catalog;

--
-- Name: Direktkandidat_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY direktkandidat
    ADD CONSTRAINT "Direktkandidat_pkey" PRIMARY KEY (id);


--
-- Name: Erststimme_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY erststimme
    ADD CONSTRAINT "Erststimme_pkey" PRIMARY KEY (id);


--
-- Name: Jahr_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY jahr
    ADD CONSTRAINT "Jahr_pkey" PRIMARY KEY (jahr);


--
-- Name: Land_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY land
    ADD CONSTRAINT "Land_pkey" PRIMARY KEY (id);


--
-- Name: Landeskandidat_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY landeskandidat
    ADD CONSTRAINT "Landeskandidat_pkey" PRIMARY KEY (id);


--
-- Name: Landesliste_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY landesliste
    ADD CONSTRAINT "Landesliste_pkey" PRIMARY KEY (id);


--
-- Name: Partei_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY partei
    ADD CONSTRAINT "Partei_name_key" UNIQUE (name);


--
-- Name: Partei_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY partei
    ADD CONSTRAINT "Partei_pkey" PRIMARY KEY (id);


--
-- Name: Wahlkreis_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY wahlkreis
    ADD CONSTRAINT "Wahlkreis_pkey" PRIMARY KEY (id);


--
-- Name: Zweitstimme_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY zweitstimme
    ADD CONSTRAINT "Zweitstimme_pkey" PRIMARY KEY (id);


--
-- Name: scherperfaktoren_pkey; Type: CONSTRAINT; Schema: public; Owner: alexx; Tablespace: 
--

ALTER TABLE ONLY scherperfaktoren
    ADD CONSTRAINT scherperfaktoren_pkey PRIMARY KEY (faktor);


SET search_path = raw2005, pg_catalog;

--
-- Name: Wahlkreise2005_pkey; Type: CONSTRAINT; Schema: raw2005; Owner: alexx; Tablespace: 
--

ALTER TABLE ONLY wahlkreise
    ADD CONSTRAINT "Wahlkreise2005_pkey" PRIMARY KEY ("Nummer");


--
-- Name: bundeslandkuerzel_pkey; Type: CONSTRAINT; Schema: raw2005; Owner: alexx; Tablespace: 
--

ALTER TABLE ONLY bundeslandkuerzel
    ADD CONSTRAINT bundeslandkuerzel_pkey PRIMARY KEY (kuerzel_2);


--
-- Name: mapid_wahlkreise_pkey; Type: CONSTRAINT; Schema: raw2005; Owner: alexx; Tablespace: 
--

ALTER TABLE ONLY mapid_wahlkreise
    ADD CONSTRAINT mapid_wahlkreise_pkey PRIMARY KEY (id_old);


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
-- Name: erststimme_direktkandidat_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX erststimme_direktkandidat_id_idx ON erststimme USING btree (direktkandidat_id);


--
-- Name: erststimme_wahlkreis_id_idx; Type: INDEX; Schema: public; Owner: postgres; Tablespace: 
--

CREATE INDEX erststimme_wahlkreis_id_idx ON erststimme USING btree (wahlkreis_id);


--
-- Name: Direktkandidat_partei_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY direktkandidat
    ADD CONSTRAINT "Direktkandidat_partei_id_fkey" FOREIGN KEY (partei_id) REFERENCES partei(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: Direktkandidat_wahlkreis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY direktkandidat
    ADD CONSTRAINT "Direktkandidat_wahlkreis_id_fkey" FOREIGN KEY (wahlkreis_id) REFERENCES wahlkreis(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: Erststimme_direktkandidat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY erststimme
    ADD CONSTRAINT "Erststimme_direktkandidat_id_fkey" FOREIGN KEY (direktkandidat_id) REFERENCES direktkandidat(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: Erststimme_wahlkreis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY erststimme
    ADD CONSTRAINT "Erststimme_wahlkreis_id_fkey" FOREIGN KEY (wahlkreis_id) REFERENCES wahlkreis(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: Land_jahr_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY land
    ADD CONSTRAINT "Land_jahr_fkey" FOREIGN KEY (jahr) REFERENCES jahr(jahr) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: Landeskandidat_landesliste_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY landeskandidat
    ADD CONSTRAINT "Landeskandidat_landesliste_id_fkey" FOREIGN KEY (landesliste_id) REFERENCES landesliste(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: Landesliste_land_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY landesliste
    ADD CONSTRAINT "Landesliste_land_id_fkey" FOREIGN KEY (land_id) REFERENCES land(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: Landesliste_partei_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY landesliste
    ADD CONSTRAINT "Landesliste_partei_id_fkey" FOREIGN KEY (partei_id) REFERENCES partei(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: Wahlkreis_land_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY wahlkreis
    ADD CONSTRAINT "Wahlkreis_land_id_fkey" FOREIGN KEY (land_id) REFERENCES land(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: Zweitstimme_landesliste_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY zweitstimme
    ADD CONSTRAINT "Zweitstimme_landesliste_id_fkey" FOREIGN KEY (landesliste_id) REFERENCES landesliste(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: Zweitstimme_wahlkreis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY zweitstimme
    ADD CONSTRAINT "Zweitstimme_wahlkreis_id_fkey" FOREIGN KEY (wahlkreis_id) REFERENCES wahlkreis(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


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

