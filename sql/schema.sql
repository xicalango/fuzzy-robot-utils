--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.6
-- Dumped by pg_dump version 9.1.6
-- Started on 2012-11-11 16:43:03 CET

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- TOC entry 8 (class 2615 OID 16693)
-- Name: raw2005; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA raw2005;


--
-- TOC entry 7 (class 2615 OID 16387)
-- Name: raw2009; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA raw2009;


--
-- TOC entry 9 (class 2615 OID 24942)
-- Name: stimmen2009; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA stimmen2009;


--
-- TOC entry 205 (class 3079 OID 11645)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2101 (class 0 OID 0)
-- Dependencies: 205
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- TOC entry 217 (class 1255 OID 16388)
-- Dependencies: 5
-- Name: get_bundesland_id_by_name(character varying, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_bundesland_id_by_name(bundesland_name character varying, jahr integer) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT l.id FROM public."Land" l WHERE l.name = $1 AND l.jahr = $2 LIMIT 1;$_$;


SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 164 (class 1259 OID 16396)
-- Dependencies: 5
-- Name: Direktkandidat; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Direktkandidat" (
    id integer NOT NULL,
    vorname character varying(50),
    nachname character varying(50),
    wahlkreis_id integer,
    partei_id integer
);


--
-- TOC entry 235 (class 1255 OID 24952)
-- Dependencies: 551 5
-- Name: get_direktkandidat_by_wahlkreis_partei_jahr(character varying, character varying, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_direktkandidat_by_wahlkreis_partei_jahr(character varying, character varying, integer) RETURNS "Direktkandidat"
    LANGUAGE sql
    AS $_$
SELECT * 
	FROM "Direktkandidat" 
	WHERE wahlkreis_id = (SELECT id FROM get_wahlkreis_by_jahr_and_name($3, $1))
	AND partei_id = get_partei_id_by_name($2)
$_$;


--
-- TOC entry 236 (class 1255 OID 24980)
-- Dependencies: 5
-- Name: get_direktkandidat_id_by_wahlkreis_partei_jahr(character varying, character varying, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_direktkandidat_id_by_wahlkreis_partei_jahr(character varying, character varying, integer) RETURNS integer
    LANGUAGE sql
    AS $_$
SELECT id 
	FROM "Direktkandidat" 
	WHERE wahlkreis_id = (SELECT id FROM get_wahlkreis_by_jahr_and_name($3, $1))
	AND partei_id = get_partei_id_by_name($2)
$_$;


--
-- TOC entry 169 (class 1259 OID 16409)
-- Dependencies: 5
-- Name: Land; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Land" (
    id integer NOT NULL,
    name character varying(30),
    jahr integer
);


--
-- TOC entry 224 (class 1255 OID 16717)
-- Dependencies: 562 5
-- Name: get_laender_by_jahr(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_laender_by_jahr(integer) RETURNS SETOF "Land"
    LANGUAGE sql
    AS $_$
SELECT * FROM "Land" WHERE jahr = $1;$_$;


--
-- TOC entry 173 (class 1259 OID 16419)
-- Dependencies: 5
-- Name: Landesliste; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Landesliste" (
    id integer NOT NULL,
    listenplatz integer,
    land_id integer,
    partei_id integer
);


--
-- TOC entry 239 (class 1255 OID 16668)
-- Dependencies: 570 5
-- Name: get_landesliste_by_jahr(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_landesliste_by_jahr(integer) RETURNS SETOF "Landesliste"
    LANGUAGE sql
    AS $_$SELECT * FROM "Landesliste" WHERE land_id IN (SELECT id FROM "Land" WHERE jahr = $1);$_$;


--
-- TOC entry 218 (class 1255 OID 16389)
-- Dependencies: 5
-- Name: get_partei_id_by_name(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_partei_id_by_name(partei_name character varying) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT p.id FROM public."Partei" p WHERE p.name = $1 LIMIT 1;$_$;


--
-- TOC entry 177 (class 1259 OID 16434)
-- Dependencies: 5
-- Name: Wahlkreis; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Wahlkreis" (
    id integer NOT NULL,
    name character varying(100),
    land_id integer
);


--
-- TOC entry 223 (class 1255 OID 16642)
-- Dependencies: 5 578
-- Name: get_wahlkreis_by_jahr(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_wahlkreis_by_jahr(integer) RETURNS SETOF "Wahlkreis"
    LANGUAGE sql
    AS $_$
SELECT * FROM "Wahlkreis" WHERE land_id IN (SELECT id FROM "Land" WHERE jahr = $1);$_$;


--
-- TOC entry 234 (class 1255 OID 24950)
-- Dependencies: 578 5
-- Name: get_wahlkreis_by_jahr_and_name(integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_wahlkreis_by_jahr_and_name(integer, character varying) RETURNS "Wahlkreis"
    LANGUAGE sql
    AS $_$
SELECT * 
	FROM "Wahlkreis" 
	WHERE land_id IN (SELECT id FROM "Land" WHERE jahr = $1)
	AND "name" = $2;
$_$;


--
-- TOC entry 237 (class 1255 OID 25000)
-- Dependencies: 5
-- Name: get_wahlkreis_id_by_jahr_and_name(integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_wahlkreis_id_by_jahr_and_name(integer, character varying) RETURNS integer
    LANGUAGE sql
    AS $_$
SELECT id 
	FROM "Wahlkreis" 
	WHERE land_id IN (SELECT id FROM "Land" WHERE jahr = $1)
	AND "name" = $2;
$_$;


--
-- TOC entry 233 (class 1255 OID 16722)
-- Dependencies: 5
-- Name: initialize_db(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION initialize_db() RETURNS void
    LANGUAGE sql
    AS $$

--reset db to zero
SELECT reset_db();

--2009
INSERT INTO "Jahr" VALUES (2009);
SELECT raw2009.import_bundeslaender();
SELECT raw2009.import_parteien();
SELECT raw2009.import_wahlkreise();
SELECT raw2009.import_landeslisten();
SELECT raw2009.import_landeskandidaten();
SELECT raw2009.import_direktkandidaten();

--2005
INSERT INTO "Jahr" VALUES (2005);
--SELECT raw2005.import_bundeslaender();
--SELECT raw2005.import_parteien();
--SELECT raw2005.import_wahlkreise();

$$;


--
-- TOC entry 226 (class 1255 OID 16583)
-- Dependencies: 656 5
-- Name: reset_db(); Type: FUNCTION; Schema: public; Owner: -
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

FOR rec IN SELECT * FROM information_schema.sequences WHERE sequence_catalog = 'btw2009' AND sequence_schema = 'public' LOOP
	EXECUTE 'ALTER SEQUENCE "' || rec.sequence_name || '" RESTART 1';
END LOOP;


END;
$$;


SET search_path = raw2005, pg_catalog;

--
-- TOC entry 221 (class 1255 OID 16716)
-- Dependencies: 8
-- Name: import_bundeslaender(); Type: FUNCTION; Schema: raw2005; Owner: -
--

CREATE FUNCTION import_bundeslaender() RETURNS void
    LANGUAGE sql
    AS $$
INSERT INTO "Land" ("name", "jahr") SELECT DISTINCT "Land", 2005 FROM raw2005.wahlkreise;
$$;


--
-- TOC entry 219 (class 1255 OID 16719)
-- Dependencies: 8
-- Name: import_parteien(); Type: FUNCTION; Schema: raw2005; Owner: -
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


--
-- TOC entry 227 (class 1255 OID 16865)
-- Dependencies: 8 656
-- Name: import_wahlkreise(); Type: FUNCTION; Schema: raw2005; Owner: -
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


--
-- TOC entry 232 (class 1255 OID 16900)
-- Dependencies: 8
-- Name: map_wahlkreis(integer); Type: FUNCTION; Schema: raw2005; Owner: -
--

CREATE FUNCTION map_wahlkreis(integer) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT id_new FROM raw2005.mapid_wahlkreise WHERE id_old = $1 LIMIT 1;$_$;


SET search_path = raw2009, pg_catalog;

--
-- TOC entry 225 (class 1255 OID 16720)
-- Dependencies: 7
-- Name: import_bundeslaender(); Type: FUNCTION; Schema: raw2009; Owner: -
--

CREATE FUNCTION import_bundeslaender() RETURNS void
    LANGUAGE sql
    AS $$
INSERT INTO "Land" ("name", "jahr") SELECT DISTINCT "Bundesland", 2009 FROM raw2009.landeslisten;
$$;


--
-- TOC entry 231 (class 1255 OID 16391)
-- Dependencies: 656 7
-- Name: import_direktkandidaten(); Type: FUNCTION; Schema: raw2009; Owner: -
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

	END LOOP;

	EXECUTE 'CREATE OR REPLACE FUNCTION raw2009.map_direktkandidat(integer)
  RETURNS integer AS
''SELECT id_new FROM raw2009.mapid_direktkandidaten WHERE id_old = $1 LIMIT 1;''
  LANGUAGE sql VOLATILE
  COST 100;';

END;

$_$;


--
-- TOC entry 238 (class 1255 OID 16392)
-- Dependencies: 7 656
-- Name: import_landeskandidaten(); Type: FUNCTION; Schema: raw2009; Owner: -
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
		
	END LOOP;

	EXECUTE 'CREATE OR REPLACE FUNCTION raw2009.map_landeskandidat(integer)
  RETURNS integer AS
''SELECT id_new FROM raw2009.mapid_landeskandidaten WHERE id_old = $1 LIMIT 1;''
  LANGUAGE sql VOLATILE
  COST 100;';

END;

$_$;


--
-- TOC entry 230 (class 1255 OID 16635)
-- Dependencies: 7 656
-- Name: import_landeslisten(); Type: FUNCTION; Schema: raw2009; Owner: -
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

	EXECUTE 'CREATE OR REPLACE FUNCTION raw2009.map_landesliste(integer)
  RETURNS integer AS
''SELECT id_new FROM raw2009.mapid_landeslisten WHERE id_old = $1 LIMIT 1;''
  LANGUAGE sql VOLATILE
  COST 100;';
	
END;
$_$;


--
-- TOC entry 220 (class 1255 OID 16394)
-- Dependencies: 7
-- Name: import_parteien(); Type: FUNCTION; Schema: raw2009; Owner: -
--

CREATE FUNCTION import_parteien() RETURNS void
    LANGUAGE sql
    AS $$
--DELETE FROM "Partei";
INSERT INTO "Partei" ("name") SELECT * FROM
(
	SELECT DISTINCT trim("Partei") partei FROM raw2009.landeslisten
	UNION
	SELECT DISTINCT trim("Partei") partei FROM raw2009.wahlbewerber WHERE "Partei" IS NOT NULL
) p
WHERE p.partei NOT IN (SELECT "name" FROM "Partei");
$$;


--
-- TOC entry 228 (class 1255 OID 16589)
-- Dependencies: 656 7
-- Name: import_wahlkreise(); Type: FUNCTION; Schema: raw2009; Owner: -
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

	EXECUTE 'CREATE OR REPLACE FUNCTION raw2009.map_wahlkreis(integer)
  RETURNS integer AS
''SELECT id_new FROM raw2009.mapid_wahlkreise WHERE id_old = $1 LIMIT 1;''
  LANGUAGE sql VOLATILE
  COST 100;';
	 
END;
$_$;


--
-- TOC entry 241 (class 1255 OID 16662)
-- Dependencies: 7
-- Name: map_direktkandidat(integer); Type: FUNCTION; Schema: raw2009; Owner: -
--

CREATE FUNCTION map_direktkandidat(integer) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT id_new FROM raw2009.mapid_direktkandidaten WHERE id_old = $1 LIMIT 1;$_$;


--
-- TOC entry 240 (class 1255 OID 16689)
-- Dependencies: 7
-- Name: map_landeskandidat(integer); Type: FUNCTION; Schema: raw2009; Owner: -
--

CREATE FUNCTION map_landeskandidat(integer) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT id_new FROM raw2009.mapid_landeskandidaten WHERE id_old = $1 LIMIT 1;$_$;


--
-- TOC entry 229 (class 1255 OID 16645)
-- Dependencies: 7
-- Name: map_landesliste(integer); Type: FUNCTION; Schema: raw2009; Owner: -
--

CREATE FUNCTION map_landesliste(integer) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT id_new FROM raw2009.mapid_landeslisten WHERE id_old = $1 LIMIT 1;$_$;


--
-- TOC entry 222 (class 1255 OID 16646)
-- Dependencies: 7
-- Name: map_wahlkreis(integer); Type: FUNCTION; Schema: raw2009; Owner: -
--

CREATE FUNCTION map_wahlkreis(integer) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT id_new FROM raw2009.mapid_wahlkreise WHERE id_old = $1 LIMIT 1;$_$;


SET search_path = public, pg_catalog;

--
-- TOC entry 165 (class 1259 OID 16399)
-- Dependencies: 164 5
-- Name: Direktkandidat_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Direktkandidat_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2102 (class 0 OID 0)
-- Dependencies: 165
-- Name: Direktkandidat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Direktkandidat_id_seq" OWNED BY "Direktkandidat".id;


--
-- TOC entry 166 (class 1259 OID 16401)
-- Dependencies: 5
-- Name: Erststimme; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Erststimme" (
    id integer NOT NULL,
    wahlkreis_id integer,
    direktkandidat_id integer
);


--
-- TOC entry 167 (class 1259 OID 16404)
-- Dependencies: 166 5
-- Name: Erststimme_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Erststimme_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2103 (class 0 OID 0)
-- Dependencies: 167
-- Name: Erststimme_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Erststimme_id_seq" OWNED BY "Erststimme".id;


--
-- TOC entry 168 (class 1259 OID 16406)
-- Dependencies: 5
-- Name: Jahr; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Jahr" (
    jahr integer NOT NULL
);


--
-- TOC entry 170 (class 1259 OID 16412)
-- Dependencies: 169 5
-- Name: Land_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Land_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2104 (class 0 OID 0)
-- Dependencies: 170
-- Name: Land_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Land_id_seq" OWNED BY "Land".id;


--
-- TOC entry 171 (class 1259 OID 16414)
-- Dependencies: 5
-- Name: Landeskandidat; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Landeskandidat" (
    id integer NOT NULL,
    vorname character varying(50),
    nachname character varying(50),
    listenrang integer,
    landesliste_id integer
);


--
-- TOC entry 172 (class 1259 OID 16417)
-- Dependencies: 5 171
-- Name: Landeskandidat_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Landeskandidat_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2105 (class 0 OID 0)
-- Dependencies: 172
-- Name: Landeskandidat_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Landeskandidat_id_seq" OWNED BY "Landeskandidat".id;


--
-- TOC entry 174 (class 1259 OID 16422)
-- Dependencies: 173 5
-- Name: Landesliste_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Landesliste_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2106 (class 0 OID 0)
-- Dependencies: 174
-- Name: Landesliste_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Landesliste_id_seq" OWNED BY "Landesliste".id;


--
-- TOC entry 175 (class 1259 OID 16424)
-- Dependencies: 5
-- Name: Partei; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Partei" (
    name character varying(150),
    id integer NOT NULL
);


--
-- TOC entry 176 (class 1259 OID 16427)
-- Dependencies: 5 175
-- Name: Partei_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Partei_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2107 (class 0 OID 0)
-- Dependencies: 176
-- Name: Partei_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Partei_id_seq" OWNED BY "Partei".id;


--
-- TOC entry 178 (class 1259 OID 16437)
-- Dependencies: 177 5
-- Name: Wahlkreis_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Wahlkreis_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2108 (class 0 OID 0)
-- Dependencies: 178
-- Name: Wahlkreis_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Wahlkreis_id_seq" OWNED BY "Wahlkreis".id;


--
-- TOC entry 179 (class 1259 OID 16439)
-- Dependencies: 5
-- Name: Zweitstimme; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE "Zweitstimme" (
    id integer NOT NULL,
    wahlkreis_id integer,
    landesliste_id integer
);


--
-- TOC entry 180 (class 1259 OID 16442)
-- Dependencies: 5 179
-- Name: Zweitstimme_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE "Zweitstimme_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2109 (class 0 OID 0)
-- Dependencies: 180
-- Name: Zweitstimme_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Zweitstimme_id_seq" OWNED BY "Zweitstimme".id;


SET search_path = raw2005, pg_catalog;

--
-- TOC entry 191 (class 1259 OID 16866)
-- Dependencies: 8
-- Name: bundeslandkuerzel; Type: TABLE; Schema: raw2005; Owner: -; Tablespace: 
--

CREATE TABLE bundeslandkuerzel (
    name character varying(100),
    kuerzel_5 character varying(5),
    kuerzel_2 character varying(2) NOT NULL
);


--
-- TOC entry 193 (class 1259 OID 16895)
-- Dependencies: 8
-- Name: mapid_wahlkreise; Type: TABLE; Schema: raw2005; Owner: -; Tablespace: 
--

CREATE TABLE mapid_wahlkreise (
    id_old integer NOT NULL,
    id_new integer
);


--
-- TOC entry 188 (class 1259 OID 16697)
-- Dependencies: 8
-- Name: wahlbewerber; Type: TABLE; Schema: raw2005; Owner: -; Tablespace: 
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


--
-- TOC entry 192 (class 1259 OID 16871)
-- Dependencies: 2022 8
-- Name: wahlbewerber_mit_land; Type: VIEW; Schema: raw2005; Owner: -
--

CREATE VIEW wahlbewerber_mit_land AS
    SELECT wb."Vorname", wb."Name", wb."Partei", wb."Wahlkreis", wb."Land", wb."Platz", wb.id, kz.name AS land_name FROM wahlbewerber wb, bundeslandkuerzel kz WHERE ((wb."Land")::text = (kz.kuerzel_2)::text);


--
-- TOC entry 194 (class 1259 OID 24910)
-- Dependencies: 2023 8
-- Name: wahlbewerber_direktkandidat; Type: VIEW; Schema: raw2005; Owner: -
--

CREATE VIEW wahlbewerber_direktkandidat AS
    SELECT w.id, w."Vorname", w."Name", w."Wahlkreis", public.get_partei_id_by_name(w."Partei") AS partei_id FROM wahlbewerber_mit_land w WHERE (w."Wahlkreis" IS NOT NULL);


--
-- TOC entry 189 (class 1259 OID 16701)
-- Dependencies: 8 188
-- Name: wahlbewerber_id_seq; Type: SEQUENCE; Schema: raw2005; Owner: -
--

CREATE SEQUENCE wahlbewerber_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2110 (class 0 OID 0)
-- Dependencies: 189
-- Name: wahlbewerber_id_seq; Type: SEQUENCE OWNED BY; Schema: raw2005; Owner: -
--

ALTER SEQUENCE wahlbewerber_id_seq OWNED BY wahlbewerber.id;


--
-- TOC entry 195 (class 1259 OID 24914)
-- Dependencies: 2024 8
-- Name: wahlbewerber_landesliste; Type: VIEW; Schema: raw2005; Owner: -
--

CREATE VIEW wahlbewerber_landesliste AS
    SELECT w.id, w."Vorname", w."Name", w."Wahlkreis", public.get_partei_id_by_name(w."Partei") AS partei_id FROM wahlbewerber_mit_land w WHERE (w."Wahlkreis" IS NULL);


--
-- TOC entry 190 (class 1259 OID 16709)
-- Dependencies: 8
-- Name: wahlkreise; Type: TABLE; Schema: raw2005; Owner: -; Tablespace: 
--

CREATE TABLE wahlkreise (
    "Nummer" integer NOT NULL,
    "Land" character varying(100),
    "Name" character varying(100)
);


SET search_path = raw2009, pg_catalog;

--
-- TOC entry 181 (class 1259 OID 16444)
-- Dependencies: 7
-- Name: landeslisten; Type: TABLE; Schema: raw2009; Owner: -; Tablespace: 
--

CREATE TABLE landeslisten (
    "Listennummer" integer NOT NULL,
    "Bundesland" character varying(100),
    "Partei" character varying(100)
);


--
-- TOC entry 182 (class 1259 OID 16447)
-- Dependencies: 7
-- Name: listenplaetze; Type: TABLE; Schema: raw2009; Owner: -; Tablespace: 
--

CREATE TABLE listenplaetze (
    "Landesliste" integer NOT NULL,
    "Kandidat" integer NOT NULL,
    "Position" integer
);


--
-- TOC entry 201 (class 1259 OID 24972)
-- Dependencies: 7
-- Name: mapid_direktkandidaten; Type: TABLE; Schema: raw2009; Owner: -; Tablespace: 
--

CREATE TABLE mapid_direktkandidaten (
    id_old integer NOT NULL,
    id_new integer
);


--
-- TOC entry 200 (class 1259 OID 24967)
-- Dependencies: 7
-- Name: mapid_landeskandidaten; Type: TABLE; Schema: raw2009; Owner: -; Tablespace: 
--

CREATE TABLE mapid_landeskandidaten (
    id_old integer NOT NULL,
    id_new integer
);


--
-- TOC entry 199 (class 1259 OID 24962)
-- Dependencies: 7
-- Name: mapid_landeslisten; Type: TABLE; Schema: raw2009; Owner: -; Tablespace: 
--

CREATE TABLE mapid_landeslisten (
    id_old integer NOT NULL,
    id_new integer
);


--
-- TOC entry 198 (class 1259 OID 24957)
-- Dependencies: 7
-- Name: mapid_wahlkreise; Type: TABLE; Schema: raw2009; Owner: -; Tablespace: 
--

CREATE TABLE mapid_wahlkreise (
    id_old integer NOT NULL,
    id_new integer
);


--
-- TOC entry 183 (class 1259 OID 16450)
-- Dependencies: 7
-- Name: wahlbewerber; Type: TABLE; Schema: raw2009; Owner: -; Tablespace: 
--

CREATE TABLE wahlbewerber (
    "Titel" character varying(100),
    "Vorname" character varying(100),
    "Nachname" character varying(100),
    "Partei" character varying(100),
    "Jahrgang" integer,
    "Kandidatennummer" integer NOT NULL
);


--
-- TOC entry 197 (class 1259 OID 24953)
-- Dependencies: 2025 7
-- Name: wahlbewerber_mit_titel; Type: VIEW; Schema: raw2009; Owner: -
--

CREATE VIEW wahlbewerber_mit_titel AS
    SELECT CASE WHEN (w."Titel" IS NULL) THEN (w."Vorname")::text ELSE (((w."Titel")::text || ' '::text) || (w."Vorname")::text) END AS "Vorname", w."Nachname", w."Partei", w."Jahrgang", w."Kandidatennummer" FROM wahlbewerber w;


--
-- TOC entry 184 (class 1259 OID 16453)
-- Dependencies: 7
-- Name: wahlbewerber_mit_wahlkreis; Type: TABLE; Schema: raw2009; Owner: -; Tablespace: 
--

CREATE TABLE wahlbewerber_mit_wahlkreis (
    "Vorname" character varying(100),
    "Nachname" character varying(100),
    "Jahrgang" integer,
    "Partei" character varying(100),
    "Wahlkreis" integer
);


--
-- TOC entry 185 (class 1259 OID 16456)
-- Dependencies: 2020 7
-- Name: wahlbewerber_direktkandidat; Type: VIEW; Schema: raw2009; Owner: -
--

CREATE VIEW wahlbewerber_direktkandidat AS
    SELECT w."Kandidatennummer", ww."Vorname", ww."Nachname", ww."Wahlkreis", public.get_partei_id_by_name(ww."Partei") AS partei_id FROM wahlbewerber_mit_wahlkreis ww, wahlbewerber_mit_titel w WHERE (((((ww."Vorname")::text = w."Vorname") AND ((ww."Nachname")::text = (w."Nachname")::text)) AND (ww."Jahrgang" = w."Jahrgang")) AND ((public.get_partei_id_by_name(ww."Partei") IS NULL) OR ((ww."Partei")::text = (w."Partei")::text)));


--
-- TOC entry 186 (class 1259 OID 16460)
-- Dependencies: 2021 7
-- Name: wahlbewerber_landesliste; Type: VIEW; Schema: raw2009; Owner: -
--

CREATE VIEW wahlbewerber_landesliste AS
    SELECT CASE WHEN (w."Titel" IS NULL) THEN (w."Vorname")::text ELSE (((w."Titel")::text || ' '::text) || (w."Vorname")::text) END AS "VornameTitel", w."Nachname", w."Partei", w."Jahrgang", w."Kandidatennummer", lp."Landesliste", lp."Position" FROM wahlbewerber w, listenplaetze lp WHERE (w."Kandidatennummer" = lp."Kandidat");


--
-- TOC entry 187 (class 1259 OID 16464)
-- Dependencies: 7
-- Name: wahlkreise; Type: TABLE; Schema: raw2009; Owner: -; Tablespace: 
--

CREATE TABLE wahlkreise (
    "Land" character varying(100),
    "WahlkreisNr" integer NOT NULL,
    "Name" character varying(200),
    "Wahlberechtigte" integer,
    "Vorperiode" integer
);


SET search_path = stimmen2009, pg_catalog;

--
-- TOC entry 196 (class 1259 OID 24943)
-- Dependencies: 9
-- Name: ErststimmenEndgueltig; Type: TABLE; Schema: stimmen2009; Owner: -; Tablespace: 
--

CREATE TABLE "ErststimmenEndgueltig" (
    "Nr" integer,
    "GehoertZu" integer,
    "Partei" character varying(100),
    "Gebiet" character varying(100),
    "Stimmen" integer
);


--
-- TOC entry 203 (class 1259 OID 24989)
-- Dependencies: 9
-- Name: ZweitstimmenEndgueltig; Type: TABLE; Schema: stimmen2009; Owner: -; Tablespace: 
--

CREATE TABLE "ZweitstimmenEndgueltig" (
    "Nr" integer,
    "GehoertZu" integer,
    "Partei" character varying(100),
    "Gebiet" character varying(100),
    "Stimmen" integer
);


--
-- TOC entry 202 (class 1259 OID 24985)
-- Dependencies: 2026 9
-- Name: direktkandidat_stimmen; Type: VIEW; Schema: stimmen2009; Owner: -
--

CREATE VIEW direktkandidat_stimmen AS
    SELECT public.get_direktkandidat_id_by_wahlkreis_partei_jahr("ErststimmenEndgueltig"."Gebiet", "ErststimmenEndgueltig"."Partei", 2009) AS kandidat_id, "ErststimmenEndgueltig"."Stimmen" AS stimmen FROM "ErststimmenEndgueltig" WHERE ((((("ErststimmenEndgueltig"."Partei")::text IN (SELECT "Partei".name FROM public."Partei")) AND ("ErststimmenEndgueltig"."GehoertZu" IS NOT NULL)) AND (("ErststimmenEndgueltig"."Gebiet")::text IN (SELECT get_wahlkreis_by_jahr.name FROM public.get_wahlkreis_by_jahr(2009) get_wahlkreis_by_jahr(id, name, land_id)))) AND ("ErststimmenEndgueltig"."Stimmen" IS NOT NULL));


--
-- TOC entry 204 (class 1259 OID 25001)
-- Dependencies: 2027 9
-- Name: erststimme_ungueltige; Type: VIEW; Schema: stimmen2009; Owner: -
--

CREATE VIEW erststimme_ungueltige AS
    SELECT public.get_wahlkreis_id_by_jahr_and_name(2009, "ErststimmenEndgueltig"."Gebiet") AS wahlkreis_id, "ErststimmenEndgueltig"."Stimmen" AS stimmen FROM "ErststimmenEndgueltig" WHERE ((((("ErststimmenEndgueltig"."Partei")::text = 'Ungültige'::text) AND ("ErststimmenEndgueltig"."GehoertZu" IS NOT NULL)) AND (("ErststimmenEndgueltig"."Gebiet")::text IN (SELECT get_wahlkreis_by_jahr.name FROM public.get_wahlkreis_by_jahr(2009) get_wahlkreis_by_jahr(id, name, land_id)))) AND ("ErststimmenEndgueltig"."Stimmen" IS NOT NULL));


SET search_path = public, pg_catalog;

--
-- TOC entry 2028 (class 2604 OID 16467)
-- Dependencies: 165 164
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "Direktkandidat" ALTER COLUMN id SET DEFAULT nextval('"Direktkandidat_id_seq"'::regclass);


--
-- TOC entry 2029 (class 2604 OID 16468)
-- Dependencies: 167 166
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "Erststimme" ALTER COLUMN id SET DEFAULT nextval('"Erststimme_id_seq"'::regclass);


--
-- TOC entry 2030 (class 2604 OID 16469)
-- Dependencies: 170 169
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "Land" ALTER COLUMN id SET DEFAULT nextval('"Land_id_seq"'::regclass);


--
-- TOC entry 2031 (class 2604 OID 16470)
-- Dependencies: 172 171
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "Landeskandidat" ALTER COLUMN id SET DEFAULT nextval('"Landeskandidat_id_seq"'::regclass);


--
-- TOC entry 2032 (class 2604 OID 16471)
-- Dependencies: 174 173
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "Landesliste" ALTER COLUMN id SET DEFAULT nextval('"Landesliste_id_seq"'::regclass);


--
-- TOC entry 2033 (class 2604 OID 16472)
-- Dependencies: 176 175
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "Partei" ALTER COLUMN id SET DEFAULT nextval('"Partei_id_seq"'::regclass);


--
-- TOC entry 2034 (class 2604 OID 16474)
-- Dependencies: 178 177
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "Wahlkreis" ALTER COLUMN id SET DEFAULT nextval('"Wahlkreis_id_seq"'::regclass);


--
-- TOC entry 2035 (class 2604 OID 16475)
-- Dependencies: 180 179
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY "Zweitstimme" ALTER COLUMN id SET DEFAULT nextval('"Zweitstimme_id_seq"'::regclass);


SET search_path = raw2005, pg_catalog;

--
-- TOC entry 2036 (class 2604 OID 16703)
-- Dependencies: 189 188
-- Name: id; Type: DEFAULT; Schema: raw2005; Owner: -
--

ALTER TABLE ONLY wahlbewerber ALTER COLUMN id SET DEFAULT nextval('wahlbewerber_id_seq'::regclass);


SET search_path = public, pg_catalog;

--
-- TOC entry 2038 (class 2606 OID 16477)
-- Dependencies: 164 164 2095
-- Name: Direktkandidat_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Direktkandidat"
    ADD CONSTRAINT "Direktkandidat_pkey" PRIMARY KEY (id);


--
-- TOC entry 2040 (class 2606 OID 16479)
-- Dependencies: 166 166 2095
-- Name: Erststimme_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Erststimme"
    ADD CONSTRAINT "Erststimme_pkey" PRIMARY KEY (id);


--
-- TOC entry 2042 (class 2606 OID 16481)
-- Dependencies: 168 168 2095
-- Name: Jahr_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Jahr"
    ADD CONSTRAINT "Jahr_pkey" PRIMARY KEY (jahr);


--
-- TOC entry 2044 (class 2606 OID 16483)
-- Dependencies: 169 169 2095
-- Name: Land_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Land"
    ADD CONSTRAINT "Land_pkey" PRIMARY KEY (id);


--
-- TOC entry 2046 (class 2606 OID 16485)
-- Dependencies: 171 171 2095
-- Name: Landeskandidat_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Landeskandidat"
    ADD CONSTRAINT "Landeskandidat_pkey" PRIMARY KEY (id);


--
-- TOC entry 2048 (class 2606 OID 16487)
-- Dependencies: 173 173 2095
-- Name: Landesliste_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Landesliste"
    ADD CONSTRAINT "Landesliste_pkey" PRIMARY KEY (id);


--
-- TOC entry 2050 (class 2606 OID 16631)
-- Dependencies: 175 175 2095
-- Name: Partei_name_key; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Partei"
    ADD CONSTRAINT "Partei_name_key" UNIQUE (name);


--
-- TOC entry 2052 (class 2606 OID 16489)
-- Dependencies: 175 175 2095
-- Name: Partei_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Partei"
    ADD CONSTRAINT "Partei_pkey" PRIMARY KEY (id);


--
-- TOC entry 2054 (class 2606 OID 16493)
-- Dependencies: 177 177 2095
-- Name: Wahlkreis_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Wahlkreis"
    ADD CONSTRAINT "Wahlkreis_pkey" PRIMARY KEY (id);


--
-- TOC entry 2056 (class 2606 OID 16495)
-- Dependencies: 179 179 2095
-- Name: Zweitstimme_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY "Zweitstimme"
    ADD CONSTRAINT "Zweitstimme_pkey" PRIMARY KEY (id);


SET search_path = raw2005, pg_catalog;

--
-- TOC entry 2068 (class 2606 OID 16713)
-- Dependencies: 190 190 2095
-- Name: Wahlkreise2005_pkey; Type: CONSTRAINT; Schema: raw2005; Owner: -; Tablespace: 
--

ALTER TABLE ONLY wahlkreise
    ADD CONSTRAINT "Wahlkreise2005_pkey" PRIMARY KEY ("Nummer");


--
-- TOC entry 2070 (class 2606 OID 16870)
-- Dependencies: 191 191 2095
-- Name: bundeslandkuerzel_pkey; Type: CONSTRAINT; Schema: raw2005; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bundeslandkuerzel
    ADD CONSTRAINT bundeslandkuerzel_pkey PRIMARY KEY (kuerzel_2);


--
-- TOC entry 2072 (class 2606 OID 16899)
-- Dependencies: 193 193 2095
-- Name: mapid_wahlkreise_pkey; Type: CONSTRAINT; Schema: raw2005; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mapid_wahlkreise
    ADD CONSTRAINT mapid_wahlkreise_pkey PRIMARY KEY (id_old);


--
-- TOC entry 2066 (class 2606 OID 16708)
-- Dependencies: 188 188 2095
-- Name: wahlbewerber_pkey; Type: CONSTRAINT; Schema: raw2005; Owner: -; Tablespace: 
--

ALTER TABLE ONLY wahlbewerber
    ADD CONSTRAINT wahlbewerber_pkey PRIMARY KEY (id);


SET search_path = raw2009, pg_catalog;

--
-- TOC entry 2058 (class 2606 OID 16497)
-- Dependencies: 181 181 2095
-- Name: landeslisten_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: -; Tablespace: 
--

ALTER TABLE ONLY landeslisten
    ADD CONSTRAINT landeslisten_pkey PRIMARY KEY ("Listennummer");


--
-- TOC entry 2060 (class 2606 OID 16499)
-- Dependencies: 182 182 182 2095
-- Name: listenplaetze_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: -; Tablespace: 
--

ALTER TABLE ONLY listenplaetze
    ADD CONSTRAINT listenplaetze_pkey PRIMARY KEY ("Landesliste", "Kandidat");


--
-- TOC entry 2080 (class 2606 OID 24976)
-- Dependencies: 201 201 2095
-- Name: mapid_direktkandidaten_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mapid_direktkandidaten
    ADD CONSTRAINT mapid_direktkandidaten_pkey PRIMARY KEY (id_old);


--
-- TOC entry 2078 (class 2606 OID 24971)
-- Dependencies: 200 200 2095
-- Name: mapid_landeskandidaten_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mapid_landeskandidaten
    ADD CONSTRAINT mapid_landeskandidaten_pkey PRIMARY KEY (id_old);


--
-- TOC entry 2076 (class 2606 OID 24966)
-- Dependencies: 199 199 2095
-- Name: mapid_landeslisten_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mapid_landeslisten
    ADD CONSTRAINT mapid_landeslisten_pkey PRIMARY KEY (id_old);


--
-- TOC entry 2074 (class 2606 OID 24961)
-- Dependencies: 198 198 2095
-- Name: mapid_wahlkreise_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mapid_wahlkreise
    ADD CONSTRAINT mapid_wahlkreise_pkey PRIMARY KEY (id_old);


--
-- TOC entry 2062 (class 2606 OID 16501)
-- Dependencies: 183 183 2095
-- Name: wahlbewerber_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: -; Tablespace: 
--

ALTER TABLE ONLY wahlbewerber
    ADD CONSTRAINT wahlbewerber_pkey PRIMARY KEY ("Kandidatennummer");


--
-- TOC entry 2064 (class 2606 OID 16503)
-- Dependencies: 187 187 2095
-- Name: wahlkreise_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: -; Tablespace: 
--

ALTER TABLE ONLY wahlkreise
    ADD CONSTRAINT wahlkreise_pkey PRIMARY KEY ("WahlkreisNr");


SET search_path = public, pg_catalog;

--
-- TOC entry 2081 (class 2606 OID 16504)
-- Dependencies: 164 175 2051 2095
-- Name: Direktkandidat_partei_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "Direktkandidat"
    ADD CONSTRAINT "Direktkandidat_partei_id_fkey" FOREIGN KEY (partei_id) REFERENCES "Partei"(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2082 (class 2606 OID 16509)
-- Dependencies: 2053 164 177 2095
-- Name: Direktkandidat_wahlkreis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "Direktkandidat"
    ADD CONSTRAINT "Direktkandidat_wahlkreis_id_fkey" FOREIGN KEY (wahlkreis_id) REFERENCES "Wahlkreis"(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2083 (class 2606 OID 25005)
-- Dependencies: 164 2037 166 2095
-- Name: Erststimme_direktkandidat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "Erststimme"
    ADD CONSTRAINT "Erststimme_direktkandidat_id_fkey" FOREIGN KEY (direktkandidat_id) REFERENCES "Direktkandidat"(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2084 (class 2606 OID 25010)
-- Dependencies: 177 166 2053 2095
-- Name: Erststimme_wahlkreis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "Erststimme"
    ADD CONSTRAINT "Erststimme_wahlkreis_id_fkey" FOREIGN KEY (wahlkreis_id) REFERENCES "Wahlkreis"(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2085 (class 2606 OID 16524)
-- Dependencies: 169 168 2041 2095
-- Name: Land_jahr_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "Land"
    ADD CONSTRAINT "Land_jahr_fkey" FOREIGN KEY (jahr) REFERENCES "Jahr"(jahr) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2086 (class 2606 OID 16529)
-- Dependencies: 171 2047 173 2095
-- Name: Landeskandidat_landesliste_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "Landeskandidat"
    ADD CONSTRAINT "Landeskandidat_landesliste_id_fkey" FOREIGN KEY (landesliste_id) REFERENCES "Landesliste"(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2087 (class 2606 OID 16534)
-- Dependencies: 169 2043 173 2095
-- Name: Landesliste_land_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "Landesliste"
    ADD CONSTRAINT "Landesliste_land_id_fkey" FOREIGN KEY (land_id) REFERENCES "Land"(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2088 (class 2606 OID 16539)
-- Dependencies: 173 175 2051 2095
-- Name: Landesliste_partei_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "Landesliste"
    ADD CONSTRAINT "Landesliste_partei_id_fkey" FOREIGN KEY (partei_id) REFERENCES "Partei"(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2089 (class 2606 OID 16549)
-- Dependencies: 169 2043 177 2095
-- Name: Wahlkreis_land_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "Wahlkreis"
    ADD CONSTRAINT "Wahlkreis_land_id_fkey" FOREIGN KEY (land_id) REFERENCES "Land"(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2090 (class 2606 OID 25015)
-- Dependencies: 173 179 2047 2095
-- Name: Zweitstimme_landesliste_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "Zweitstimme"
    ADD CONSTRAINT "Zweitstimme_landesliste_id_fkey" FOREIGN KEY (landesliste_id) REFERENCES "Landesliste"(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2091 (class 2606 OID 25020)
-- Dependencies: 2053 179 177 2095
-- Name: Zweitstimme_wahlkreis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY "Zweitstimme"
    ADD CONSTRAINT "Zweitstimme_wahlkreis_id_fkey" FOREIGN KEY (wahlkreis_id) REFERENCES "Wahlkreis"(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


SET search_path = raw2009, pg_catalog;

--
-- TOC entry 2092 (class 2606 OID 16564)
-- Dependencies: 2061 183 182 2095
-- Name: listenplaetze_Kandidat_fkey; Type: FK CONSTRAINT; Schema: raw2009; Owner: -
--

ALTER TABLE ONLY listenplaetze
    ADD CONSTRAINT "listenplaetze_Kandidat_fkey" FOREIGN KEY ("Kandidat") REFERENCES wahlbewerber("Kandidatennummer");


--
-- TOC entry 2093 (class 2606 OID 16569)
-- Dependencies: 182 181 2057 2095
-- Name: listenplaetze_Landesliste_fkey; Type: FK CONSTRAINT; Schema: raw2009; Owner: -
--

ALTER TABLE ONLY listenplaetze
    ADD CONSTRAINT "listenplaetze_Landesliste_fkey" FOREIGN KEY ("Landesliste") REFERENCES landeslisten("Listennummer");


--
-- TOC entry 2100 (class 0 OID 0)
-- Dependencies: 5
-- Name: public; Type: ACL; Schema: -; Owner: -
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2012-11-11 16:43:04 CET

--
-- PostgreSQL database dump complete
--

