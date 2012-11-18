--
-- PostgreSQL database dump
--

-- Dumped from database version 9.1.6
-- Dumped by pg_dump version 9.2.0
-- Started on 2012-11-18 23:24:41

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
-- TOC entry 218 (class 3079 OID 11645)
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- TOC entry 2171 (class 0 OID 0)
-- Dependencies: 218
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

--
-- TOC entry 245 (class 1255 OID 25113)
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
-- TOC entry 232 (class 1255 OID 16388)
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
-- TOC entry 251 (class 1255 OID 24952)
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
-- TOC entry 252 (class 1255 OID 24980)
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
-- TOC entry 244 (class 1255 OID 16717)
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
-- TOC entry 254 (class 1255 OID 16668)
-- Name: get_landesliste_by_jahr(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_landesliste_by_jahr(integer) RETURNS SETOF landesliste
    LANGUAGE sql
    AS $_$SELECT * FROM "landesliste" WHERE land_id IN (SELECT id FROM "land" WHERE jahr = $1);$_$;


--
-- TOC entry 250 (class 1255 OID 25137)
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
-- TOC entry 235 (class 1255 OID 16389)
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
-- TOC entry 233 (class 1255 OID 16642)
-- Name: get_wahlkreis_by_jahr(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION get_wahlkreis_by_jahr(integer) RETURNS SETOF wahlkreis
    LANGUAGE sql
    AS $_$
SELECT * FROM "wahlkreis" WHERE land_id IN (SELECT id FROM "land" WHERE jahr = $1);$_$;


--
-- TOC entry 249 (class 1255 OID 24950)
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
-- TOC entry 253 (class 1255 OID 25000)
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
-- TOC entry 246 (class 1255 OID 16722)
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
-- TOC entry 239 (class 1255 OID 16583)
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
-- TOC entry 248 (class 1255 OID 25198)
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


SET search_path = raw2005, pg_catalog;

--
-- TOC entry 231 (class 1255 OID 16716)
-- Name: import_bundeslaender(); Type: FUNCTION; Schema: raw2005; Owner: -
--

CREATE FUNCTION import_bundeslaender() RETURNS void
    LANGUAGE sql
    AS $$
INSERT INTO "Land" ("name", "jahr") SELECT DISTINCT "Land", 2005 FROM raw2005.wahlkreise;
$$;


--
-- TOC entry 230 (class 1255 OID 16719)
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
-- TOC entry 238 (class 1255 OID 16865)
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
-- TOC entry 247 (class 1255 OID 16900)
-- Name: map_wahlkreis(integer); Type: FUNCTION; Schema: raw2005; Owner: -
--

CREATE FUNCTION map_wahlkreis(integer) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT id_new FROM raw2005.mapid_wahlkreise WHERE id_old = $1 LIMIT 1;$_$;


SET search_path = raw2009, pg_catalog;

--
-- TOC entry 240 (class 1255 OID 16720)
-- Name: import_bundeslaender(); Type: FUNCTION; Schema: raw2009; Owner: -
--

CREATE FUNCTION import_bundeslaender() RETURNS void
    LANGUAGE sql
    AS $$
INSERT INTO "land" ("name", "jahr") SELECT DISTINCT "Bundesland", 2009 FROM raw2009.landeslisten;
$$;


--
-- TOC entry 241 (class 1255 OID 16391)
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


--
-- TOC entry 255 (class 1255 OID 16392)
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


--
-- TOC entry 237 (class 1255 OID 16635)
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


--
-- TOC entry 234 (class 1255 OID 16394)
-- Name: import_parteien(); Type: FUNCTION; Schema: raw2009; Owner: -
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


--
-- TOC entry 242 (class 1255 OID 16589)
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


--
-- TOC entry 257 (class 1255 OID 16662)
-- Name: map_direktkandidat(integer); Type: FUNCTION; Schema: raw2009; Owner: -
--

CREATE FUNCTION map_direktkandidat(integer) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT id_new FROM raw2009.mapid_direktkandidaten WHERE id_old = $1 LIMIT 1;$_$;


--
-- TOC entry 256 (class 1255 OID 16689)
-- Name: map_landeskandidat(integer); Type: FUNCTION; Schema: raw2009; Owner: -
--

CREATE FUNCTION map_landeskandidat(integer) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT id_new FROM raw2009.mapid_landeskandidaten WHERE id_old = $1 LIMIT 1;$_$;


--
-- TOC entry 243 (class 1255 OID 16645)
-- Name: map_landesliste(integer); Type: FUNCTION; Schema: raw2009; Owner: -
--

CREATE FUNCTION map_landesliste(integer) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT id_new FROM raw2009.mapid_landeslisten WHERE id_old = $1 LIMIT 1;$_$;


--
-- TOC entry 236 (class 1255 OID 16646)
-- Name: map_wahlkreis(integer); Type: FUNCTION; Schema: raw2009; Owner: -
--

CREATE FUNCTION map_wahlkreis(integer) RETURNS integer
    LANGUAGE sql
    AS $_$SELECT id_new FROM raw2009.mapid_wahlkreise WHERE id_old = $1 LIMIT 1;$_$;


SET search_path = public, pg_catalog;

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
-- TOC entry 2172 (class 0 OID 0)
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
-- TOC entry 2173 (class 0 OID 0)
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
-- TOC entry 2174 (class 0 OID 0)
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
-- TOC entry 2175 (class 0 OID 0)
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
-- TOC entry 2176 (class 0 OID 0)
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
-- TOC entry 2177 (class 0 OID 0)
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
-- TOC entry 2178 (class 0 OID 0)
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
-- TOC entry 2179 (class 0 OID 0)
-- Dependencies: 180
-- Name: Zweitstimme_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE "Zweitstimme_id_seq" OWNED BY zweitstimme.id;


--
-- TOC entry 212 (class 1259 OID 25191)
-- Name: erststimmenassoziation; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE erststimmenassoziation (
    direktkandidat_id integer,
    wahlkreis_id integer,
    stimmen bigint
);


--
-- TOC entry 168 (class 1259 OID 16406)
-- Name: jahr; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE jahr (
    jahr integer NOT NULL
);


SET search_path = stimmen2009, pg_catalog;

--
-- TOC entry 198 (class 1259 OID 24989)
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
-- TOC entry 205 (class 1259 OID 25150)
-- Name: landesliste_stimmen; Type: VIEW; Schema: stimmen2009; Owner: -
--

CREATE VIEW landesliste_stimmen AS
    SELECT public.get_landesliste_id_by_wahlkreis_partei_jahr(ee."Gebiet", ee."Partei", 2009) AS landesliste_id, ee."Stimmen" AS stimmen, public.get_wahlkreis_id_by_jahr_and_name(2009, ee."Gebiet") AS wahlkreis_id FROM "ZweitstimmenEndgueltig" ee WHERE (((((ee."Partei")::text IN (SELECT partei.name FROM public.partei)) AND (ee."GehoertZu" IS NOT NULL)) AND ((ee."Gebiet")::text IN (SELECT get_wahlkreis_by_jahr.name FROM public.get_wahlkreis_by_jahr(2009) get_wahlkreis_by_jahr(id, name, land_id)))) AND (ee."Stimmen" IS NOT NULL));


SET search_path = public, pg_catalog;

--
-- TOC entry 214 (class 1259 OID 25223)
-- Name: partei_zweitstimmen_alexx; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW partei_zweitstimmen_alexx AS
    SELECT l.partei_id, sum(st.stimmen) AS stimmen FROM stimmen2009.landesliste_stimmen st, landesliste l WHERE (st.landesliste_id = l.id) GROUP BY l.partei_id;


--
-- TOC entry 213 (class 1259 OID 25211)
-- Name: scherperfaktoren; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE scherperfaktoren (
    faktor numeric NOT NULL
);


--
-- TOC entry 215 (class 1259 OID 25227)
-- Name: scherper_auswertung_alexx; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW scherper_auswertung_alexx AS
    SELECT pza.partei_id, ((pza.stimmen)::numeric / s.faktor) AS gewicht FROM partei_zweitstimmen_alexx pza, scherperfaktoren s WHERE (((pza.stimmen)::numeric / (SELECT sum(partei_zweitstimmen_alexx.stimmen) AS sum FROM partei_zweitstimmen_alexx)) >= 0.05) ORDER BY ((pza.stimmen)::numeric / s.faktor) DESC;


--
-- TOC entry 216 (class 1259 OID 25231)
-- Name: sitzverteilung_partei_alexx; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW sitzverteilung_partei_alexx AS
    WITH auswetung AS (SELECT scherper_auswertung_alexx.partei_id, scherper_auswertung_alexx.gewicht FROM scherper_auswertung_alexx, partei p WHERE (scherper_auswertung_alexx.partei_id = p.id) LIMIT 598) SELECT auswetung.partei_id, p.name, count(*) AS count FROM auswetung, partei p WHERE (auswetung.partei_id = p.id) GROUP BY auswetung.partei_id, p.name ORDER BY count(*) DESC;


--
-- TOC entry 217 (class 1259 OID 25243)
-- Name: sitzeParteiBundesland_alexx; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW "sitzeParteiBundesland_alexx" AS
    WITH wahlkreise_pro_land AS (SELECT get_wahlkreis_by_jahr.land_id, count(*) AS wk_count FROM get_wahlkreis_by_jahr(2009) get_wahlkreis_by_jahr(id, name, land_id) GROUP BY get_wahlkreis_by_jahr.land_id) SELECT sv.partei_id, round((((((sv.count * wpl.wk_count) * 2))::double precision / (598)::double precision))::numeric, 0) AS sitze, wpl.land_id FROM sitzverteilung_partei_alexx sv, wahlkreise_pro_land wpl;


SET search_path = raw2005, pg_catalog;

--
-- TOC entry 191 (class 1259 OID 16866)
-- Name: bundeslandkuerzel; Type: TABLE; Schema: raw2005; Owner: -; Tablespace: 
--

CREATE TABLE bundeslandkuerzel (
    name character varying(100),
    kuerzel_5 character varying(5),
    kuerzel_2 character varying(2) NOT NULL
);


--
-- TOC entry 193 (class 1259 OID 16895)
-- Name: mapid_wahlkreise; Type: TABLE; Schema: raw2005; Owner: -; Tablespace: 
--

CREATE TABLE mapid_wahlkreise (
    id_old integer NOT NULL,
    id_new integer
);


--
-- TOC entry 188 (class 1259 OID 16697)
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
-- Name: wahlbewerber_mit_land; Type: VIEW; Schema: raw2005; Owner: -
--

CREATE VIEW wahlbewerber_mit_land AS
    SELECT wb."Vorname", wb."Name", wb."Partei", wb."Wahlkreis", wb."Land", wb."Platz", wb.id, kz.name AS land_name FROM wahlbewerber wb, bundeslandkuerzel kz WHERE ((wb."Land")::text = (kz.kuerzel_2)::text);


--
-- TOC entry 194 (class 1259 OID 24910)
-- Name: wahlbewerber_direktkandidat; Type: VIEW; Schema: raw2005; Owner: -
--

CREATE VIEW wahlbewerber_direktkandidat AS
    SELECT w.id, w."Vorname", w."Name", w."Wahlkreis", public.get_partei_id_by_name(w."Partei") AS partei_id FROM wahlbewerber_mit_land w WHERE (w."Wahlkreis" IS NOT NULL);


--
-- TOC entry 189 (class 1259 OID 16701)
-- Name: wahlbewerber_id_seq; Type: SEQUENCE; Schema: raw2005; Owner: -
--

CREATE SEQUENCE wahlbewerber_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 2180 (class 0 OID 0)
-- Dependencies: 189
-- Name: wahlbewerber_id_seq; Type: SEQUENCE OWNED BY; Schema: raw2005; Owner: -
--

ALTER SEQUENCE wahlbewerber_id_seq OWNED BY wahlbewerber.id;


--
-- TOC entry 195 (class 1259 OID 24914)
-- Name: wahlbewerber_landesliste; Type: VIEW; Schema: raw2005; Owner: -
--

CREATE VIEW wahlbewerber_landesliste AS
    SELECT w.id, w."Vorname", w."Name", w."Wahlkreis", public.get_partei_id_by_name(w."Partei") AS partei_id FROM wahlbewerber_mit_land w WHERE (w."Wahlkreis" IS NULL);


--
-- TOC entry 190 (class 1259 OID 16709)
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
-- Name: landeslisten; Type: TABLE; Schema: raw2009; Owner: -; Tablespace: 
--

CREATE TABLE landeslisten (
    "Listennummer" integer NOT NULL,
    "Bundesland" character varying(100),
    "Partei" character varying(100)
);


--
-- TOC entry 182 (class 1259 OID 16447)
-- Name: listenplaetze; Type: TABLE; Schema: raw2009; Owner: -; Tablespace: 
--

CREATE TABLE listenplaetze (
    "Landesliste" integer NOT NULL,
    "Kandidat" integer NOT NULL,
    "Position" integer
);


--
-- TOC entry 209 (class 1259 OID 25169)
-- Name: mapid_direktkandidaten; Type: TABLE; Schema: raw2009; Owner: -; Tablespace: 
--

CREATE TABLE mapid_direktkandidaten (
    id_old integer NOT NULL,
    id_new integer
);


--
-- TOC entry 208 (class 1259 OID 25164)
-- Name: mapid_landeskandidaten; Type: TABLE; Schema: raw2009; Owner: -; Tablespace: 
--

CREATE TABLE mapid_landeskandidaten (
    id_old integer NOT NULL,
    id_new integer
);


--
-- TOC entry 207 (class 1259 OID 25159)
-- Name: mapid_landeslisten; Type: TABLE; Schema: raw2009; Owner: -; Tablespace: 
--

CREATE TABLE mapid_landeslisten (
    id_old integer NOT NULL,
    id_new integer
);


--
-- TOC entry 206 (class 1259 OID 25154)
-- Name: mapid_wahlkreise; Type: TABLE; Schema: raw2009; Owner: -; Tablespace: 
--

CREATE TABLE mapid_wahlkreise (
    id_old integer NOT NULL,
    id_new integer
);


--
-- TOC entry 183 (class 1259 OID 16450)
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
-- Name: wahlbewerber_mit_titel; Type: VIEW; Schema: raw2009; Owner: -
--

CREATE VIEW wahlbewerber_mit_titel AS
    SELECT CASE WHEN (w."Titel" IS NULL) THEN (w."Vorname")::text ELSE (((w."Titel")::text || ' '::text) || (w."Vorname")::text) END AS "Vorname", w."Nachname", w."Partei", w."Jahrgang", w."Kandidatennummer" FROM wahlbewerber w;


--
-- TOC entry 184 (class 1259 OID 16453)
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
-- Name: wahlbewerber_direktkandidat; Type: VIEW; Schema: raw2009; Owner: -
--

CREATE VIEW wahlbewerber_direktkandidat AS
    SELECT w."Kandidatennummer", ww."Vorname", ww."Nachname", ww."Wahlkreis", public.get_partei_id_by_name(ww."Partei") AS partei_id FROM wahlbewerber_mit_wahlkreis ww, wahlbewerber_mit_titel w WHERE (((((ww."Vorname")::text = w."Vorname") AND ((ww."Nachname")::text = (w."Nachname")::text)) AND (ww."Jahrgang" = w."Jahrgang")) AND ((public.get_partei_id_by_name(ww."Partei") IS NULL) OR ((ww."Partei")::text = (w."Partei")::text)));


--
-- TOC entry 186 (class 1259 OID 16460)
-- Name: wahlbewerber_landesliste; Type: VIEW; Schema: raw2009; Owner: -
--

CREATE VIEW wahlbewerber_landesliste AS
    SELECT CASE WHEN (w."Titel" IS NULL) THEN (w."Vorname")::text ELSE (((w."Titel")::text || ' '::text) || (w."Vorname")::text) END AS "VornameTitel", w."Nachname", w."Partei", w."Jahrgang", w."Kandidatennummer", lp."Landesliste", lp."Position" FROM wahlbewerber w, listenplaetze lp WHERE (w."Kandidatennummer" = lp."Kandidat");


--
-- TOC entry 187 (class 1259 OID 16464)
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
-- TOC entry 200 (class 1259 OID 25025)
-- Name: direktkandidat_stimmen; Type: VIEW; Schema: stimmen2009; Owner: -
--

CREATE VIEW direktkandidat_stimmen AS
    SELECT public.get_direktkandidat_id_by_wahlkreis_partei_jahr("ErststimmenEndgueltig"."Gebiet", "ErststimmenEndgueltig"."Partei", 2009) AS kandidat_id, "ErststimmenEndgueltig"."Stimmen" AS stimmen, public.get_wahlkreis_id_by_jahr_and_name(2009, "ErststimmenEndgueltig"."Gebiet") AS wahlkreis_id FROM "ErststimmenEndgueltig" WHERE ((((("ErststimmenEndgueltig"."Partei")::text IN (SELECT partei.name FROM public.partei)) AND ("ErststimmenEndgueltig"."GehoertZu" IS NOT NULL)) AND (("ErststimmenEndgueltig"."Gebiet")::text IN (SELECT get_wahlkreis_by_jahr.name FROM public.get_wahlkreis_by_jahr(2009) get_wahlkreis_by_jahr(id, name, land_id)))) AND ("ErststimmenEndgueltig"."Stimmen" IS NOT NULL));


--
-- TOC entry 201 (class 1259 OID 25108)
-- Name: direktkandidat_uebrige; Type: VIEW; Schema: stimmen2009; Owner: -
--

CREATE VIEW direktkandidat_uebrige AS
    SELECT public.get_wahlkreis_id_by_jahr_and_name(2009, "ErststimmenEndgueltig"."Gebiet") AS wahlkreis_id, "ErststimmenEndgueltig"."Stimmen" AS stimmen FROM "ErststimmenEndgueltig" WHERE ((((("ErststimmenEndgueltig"."Partei")::text = 'Übrige'::text) AND ("ErststimmenEndgueltig"."GehoertZu" IS NOT NULL)) AND (("ErststimmenEndgueltig"."Gebiet")::text IN (SELECT get_wahlkreis_by_jahr.name FROM public.get_wahlkreis_by_jahr(2009) get_wahlkreis_by_jahr(id, name, land_id)))) AND ("ErststimmenEndgueltig"."Stimmen" IS NOT NULL));


--
-- TOC entry 199 (class 1259 OID 25001)
-- Name: erststimme_ungueltige; Type: VIEW; Schema: stimmen2009; Owner: -
--

CREATE VIEW erststimme_ungueltige AS
    SELECT public.get_wahlkreis_id_by_jahr_and_name(2009, "ErststimmenEndgueltig"."Gebiet") AS wahlkreis_id, "ErststimmenEndgueltig"."Stimmen" AS stimmen FROM "ErststimmenEndgueltig" WHERE ((((("ErststimmenEndgueltig"."Partei")::text = 'Ungültige'::text) AND ("ErststimmenEndgueltig"."GehoertZu" IS NOT NULL)) AND (("ErststimmenEndgueltig"."Gebiet")::text IN (SELECT get_wahlkreis_by_jahr.name FROM public.get_wahlkreis_by_jahr(2009) get_wahlkreis_by_jahr(id, name, land_id)))) AND ("ErststimmenEndgueltig"."Stimmen" IS NOT NULL));


--
-- TOC entry 210 (class 1259 OID 25180)
-- Name: erststimme_insges; Type: VIEW; Schema: stimmen2009; Owner: -
--

CREATE VIEW erststimme_insges AS
    SELECT direktkandidat_stimmen.kandidat_id, direktkandidat_stimmen.stimmen, direktkandidat_stimmen.wahlkreis_id FROM direktkandidat_stimmen UNION ALL SELECT NULL::integer AS kandidat_id, erststimme_ungueltige.stimmen, erststimme_ungueltige.wahlkreis_id FROM erststimme_ungueltige;


--
-- TOC entry 203 (class 1259 OID 25142)
-- Name: erststimmen_statistik; Type: VIEW; Schema: stimmen2009; Owner: -
--

CREATE VIEW erststimmen_statistik AS
    SELECT "ErststimmenEndgueltig"."Nr", "ErststimmenEndgueltig"."GehoertZu", "ErststimmenEndgueltig"."Partei", "ErststimmenEndgueltig"."Gebiet", "ErststimmenEndgueltig"."Stimmen" FROM "ErststimmenEndgueltig" WHERE ("ErststimmenEndgueltig"."GehoertZu" IS NULL);


--
-- TOC entry 202 (class 1259 OID 25138)
-- Name: zweitstimme_ungueltige; Type: VIEW; Schema: stimmen2009; Owner: -
--

CREATE VIEW zweitstimme_ungueltige AS
    SELECT public.get_wahlkreis_id_by_jahr_and_name(2009, "ZweitstimmenEndgueltig"."Gebiet") AS wahlkreis_id, "ZweitstimmenEndgueltig"."Stimmen" AS stimmen FROM "ZweitstimmenEndgueltig" WHERE ((((("ZweitstimmenEndgueltig"."Partei")::text = 'Ungültige'::text) AND ("ZweitstimmenEndgueltig"."GehoertZu" IS NOT NULL)) AND (("ZweitstimmenEndgueltig"."Gebiet")::text IN (SELECT get_wahlkreis_by_jahr.name FROM public.get_wahlkreis_by_jahr(2009) get_wahlkreis_by_jahr(id, name, land_id)))) AND ("ZweitstimmenEndgueltig"."Stimmen" IS NOT NULL));


--
-- TOC entry 211 (class 1259 OID 25184)
-- Name: zweitstimme_insges; Type: VIEW; Schema: stimmen2009; Owner: -
--

CREATE VIEW zweitstimme_insges AS
    SELECT landesliste_stimmen.landesliste_id, landesliste_stimmen.stimmen, landesliste_stimmen.wahlkreis_id FROM landesliste_stimmen UNION ALL SELECT NULL::integer AS landesliste_id, zweitstimme_ungueltige.stimmen, zweitstimme_ungueltige.wahlkreis_id FROM zweitstimme_ungueltige;


--
-- TOC entry 204 (class 1259 OID 25146)
-- Name: zweitstimmen_statistik; Type: VIEW; Schema: stimmen2009; Owner: -
--

CREATE VIEW zweitstimmen_statistik AS
    SELECT "ZweitstimmenEndgueltig"."Nr", "ZweitstimmenEndgueltig"."GehoertZu", "ZweitstimmenEndgueltig"."Partei", "ZweitstimmenEndgueltig"."Gebiet", "ZweitstimmenEndgueltig"."Stimmen" FROM "ZweitstimmenEndgueltig" WHERE ("ZweitstimmenEndgueltig"."GehoertZu" IS NULL);


SET search_path = public, pg_catalog;

--
-- TOC entry 2095 (class 2604 OID 16467)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY direktkandidat ALTER COLUMN id SET DEFAULT nextval('"Direktkandidat_id_seq"'::regclass);


--
-- TOC entry 2096 (class 2604 OID 16468)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY erststimme ALTER COLUMN id SET DEFAULT nextval('"Erststimme_id_seq"'::regclass);


--
-- TOC entry 2097 (class 2604 OID 16469)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY land ALTER COLUMN id SET DEFAULT nextval('"Land_id_seq"'::regclass);


--
-- TOC entry 2098 (class 2604 OID 16470)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY landeskandidat ALTER COLUMN id SET DEFAULT nextval('"Landeskandidat_id_seq"'::regclass);


--
-- TOC entry 2099 (class 2604 OID 16471)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY landesliste ALTER COLUMN id SET DEFAULT nextval('"Landesliste_id_seq"'::regclass);


--
-- TOC entry 2100 (class 2604 OID 16472)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY partei ALTER COLUMN id SET DEFAULT nextval('"Partei_id_seq"'::regclass);


--
-- TOC entry 2101 (class 2604 OID 16474)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY wahlkreis ALTER COLUMN id SET DEFAULT nextval('"Wahlkreis_id_seq"'::regclass);


--
-- TOC entry 2102 (class 2604 OID 16475)
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY zweitstimme ALTER COLUMN id SET DEFAULT nextval('"Zweitstimme_id_seq"'::regclass);


SET search_path = raw2005, pg_catalog;

--
-- TOC entry 2103 (class 2604 OID 16703)
-- Name: id; Type: DEFAULT; Schema: raw2005; Owner: -
--

ALTER TABLE ONLY wahlbewerber ALTER COLUMN id SET DEFAULT nextval('wahlbewerber_id_seq'::regclass);


SET search_path = public, pg_catalog;

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
-- TOC entry 2151 (class 2606 OID 25218)
-- Name: scherperfaktoren_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY scherperfaktoren
    ADD CONSTRAINT scherperfaktoren_pkey PRIMARY KEY (faktor);


SET search_path = raw2005, pg_catalog;

--
-- TOC entry 2137 (class 2606 OID 16713)
-- Name: Wahlkreise2005_pkey; Type: CONSTRAINT; Schema: raw2005; Owner: -; Tablespace: 
--

ALTER TABLE ONLY wahlkreise
    ADD CONSTRAINT "Wahlkreise2005_pkey" PRIMARY KEY ("Nummer");


--
-- TOC entry 2139 (class 2606 OID 16870)
-- Name: bundeslandkuerzel_pkey; Type: CONSTRAINT; Schema: raw2005; Owner: -; Tablespace: 
--

ALTER TABLE ONLY bundeslandkuerzel
    ADD CONSTRAINT bundeslandkuerzel_pkey PRIMARY KEY (kuerzel_2);


--
-- TOC entry 2141 (class 2606 OID 16899)
-- Name: mapid_wahlkreise_pkey; Type: CONSTRAINT; Schema: raw2005; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mapid_wahlkreise
    ADD CONSTRAINT mapid_wahlkreise_pkey PRIMARY KEY (id_old);


--
-- TOC entry 2135 (class 2606 OID 16708)
-- Name: wahlbewerber_pkey; Type: CONSTRAINT; Schema: raw2005; Owner: -; Tablespace: 
--

ALTER TABLE ONLY wahlbewerber
    ADD CONSTRAINT wahlbewerber_pkey PRIMARY KEY (id);


SET search_path = raw2009, pg_catalog;

--
-- TOC entry 2127 (class 2606 OID 16497)
-- Name: landeslisten_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: -; Tablespace: 
--

ALTER TABLE ONLY landeslisten
    ADD CONSTRAINT landeslisten_pkey PRIMARY KEY ("Listennummer");


--
-- TOC entry 2129 (class 2606 OID 16499)
-- Name: listenplaetze_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: -; Tablespace: 
--

ALTER TABLE ONLY listenplaetze
    ADD CONSTRAINT listenplaetze_pkey PRIMARY KEY ("Landesliste", "Kandidat");


--
-- TOC entry 2149 (class 2606 OID 25173)
-- Name: mapid_direktkandidaten_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mapid_direktkandidaten
    ADD CONSTRAINT mapid_direktkandidaten_pkey PRIMARY KEY (id_old);


--
-- TOC entry 2147 (class 2606 OID 25168)
-- Name: mapid_landeskandidaten_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mapid_landeskandidaten
    ADD CONSTRAINT mapid_landeskandidaten_pkey PRIMARY KEY (id_old);


--
-- TOC entry 2145 (class 2606 OID 25163)
-- Name: mapid_landeslisten_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mapid_landeslisten
    ADD CONSTRAINT mapid_landeslisten_pkey PRIMARY KEY (id_old);


--
-- TOC entry 2143 (class 2606 OID 25158)
-- Name: mapid_wahlkreise_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: -; Tablespace: 
--

ALTER TABLE ONLY mapid_wahlkreise
    ADD CONSTRAINT mapid_wahlkreise_pkey PRIMARY KEY (id_old);


--
-- TOC entry 2131 (class 2606 OID 16501)
-- Name: wahlbewerber_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: -; Tablespace: 
--

ALTER TABLE ONLY wahlbewerber
    ADD CONSTRAINT wahlbewerber_pkey PRIMARY KEY ("Kandidatennummer");


--
-- TOC entry 2133 (class 2606 OID 16503)
-- Name: wahlkreise_pkey; Type: CONSTRAINT; Schema: raw2009; Owner: -; Tablespace: 
--

ALTER TABLE ONLY wahlkreise
    ADD CONSTRAINT wahlkreise_pkey PRIMARY KEY ("WahlkreisNr");


SET search_path = public, pg_catalog;

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
-- TOC entry 2152 (class 2606 OID 16504)
-- Name: Direktkandidat_partei_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY direktkandidat
    ADD CONSTRAINT "Direktkandidat_partei_id_fkey" FOREIGN KEY (partei_id) REFERENCES partei(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2153 (class 2606 OID 16509)
-- Name: Direktkandidat_wahlkreis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY direktkandidat
    ADD CONSTRAINT "Direktkandidat_wahlkreis_id_fkey" FOREIGN KEY (wahlkreis_id) REFERENCES wahlkreis(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2154 (class 2606 OID 25005)
-- Name: Erststimme_direktkandidat_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY erststimme
    ADD CONSTRAINT "Erststimme_direktkandidat_id_fkey" FOREIGN KEY (direktkandidat_id) REFERENCES direktkandidat(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2155 (class 2606 OID 25010)
-- Name: Erststimme_wahlkreis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY erststimme
    ADD CONSTRAINT "Erststimme_wahlkreis_id_fkey" FOREIGN KEY (wahlkreis_id) REFERENCES wahlkreis(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2156 (class 2606 OID 16524)
-- Name: Land_jahr_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY land
    ADD CONSTRAINT "Land_jahr_fkey" FOREIGN KEY (jahr) REFERENCES jahr(jahr) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- TOC entry 2157 (class 2606 OID 16529)
-- Name: Landeskandidat_landesliste_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY landeskandidat
    ADD CONSTRAINT "Landeskandidat_landesliste_id_fkey" FOREIGN KEY (landesliste_id) REFERENCES landesliste(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2158 (class 2606 OID 16534)
-- Name: Landesliste_land_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY landesliste
    ADD CONSTRAINT "Landesliste_land_id_fkey" FOREIGN KEY (land_id) REFERENCES land(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2159 (class 2606 OID 16539)
-- Name: Landesliste_partei_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY landesliste
    ADD CONSTRAINT "Landesliste_partei_id_fkey" FOREIGN KEY (partei_id) REFERENCES partei(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2160 (class 2606 OID 16549)
-- Name: Wahlkreis_land_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY wahlkreis
    ADD CONSTRAINT "Wahlkreis_land_id_fkey" FOREIGN KEY (land_id) REFERENCES land(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2161 (class 2606 OID 25015)
-- Name: Zweitstimme_landesliste_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY zweitstimme
    ADD CONSTRAINT "Zweitstimme_landesliste_id_fkey" FOREIGN KEY (landesliste_id) REFERENCES landesliste(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- TOC entry 2162 (class 2606 OID 25020)
-- Name: Zweitstimme_wahlkreis_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY zweitstimme
    ADD CONSTRAINT "Zweitstimme_wahlkreis_id_fkey" FOREIGN KEY (wahlkreis_id) REFERENCES wahlkreis(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


SET search_path = raw2009, pg_catalog;

--
-- TOC entry 2163 (class 2606 OID 16564)
-- Name: listenplaetze_Kandidat_fkey; Type: FK CONSTRAINT; Schema: raw2009; Owner: -
--

ALTER TABLE ONLY listenplaetze
    ADD CONSTRAINT "listenplaetze_Kandidat_fkey" FOREIGN KEY ("Kandidat") REFERENCES wahlbewerber("Kandidatennummer");


--
-- TOC entry 2164 (class 2606 OID 16569)
-- Name: listenplaetze_Landesliste_fkey; Type: FK CONSTRAINT; Schema: raw2009; Owner: -
--

ALTER TABLE ONLY listenplaetze
    ADD CONSTRAINT "listenplaetze_Landesliste_fkey" FOREIGN KEY ("Landesliste") REFERENCES landeslisten("Listennummer");


-- Completed on 2012-11-18 23:24:42

--
-- PostgreSQL database dump complete
--

