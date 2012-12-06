-- Function: sitze_partei_ein_land(integer)

-- DROP FUNCTION sitze_partei_ein_land(integer);

CREATE OR REPLACE FUNCTION sitze_partei_ein_land(land_id integer)
  RETURNS SETOF type_sitzverteilung AS
$BODY$

--Wählt direktkandidaten aus, die auch auf landesliste sind, und schon als direktkandidat gewonnen haben
WITH direktkandidaten_gewinner AS ( 
	SELECT g.partei_id FROM wahl_gewinner g, direktkandidat d, landeskandidat k, landesliste l
	WHERE g.kandidat_id = d.id AND g.land_id = $1
	AND d.vorname = k.vorname AND d.nachname = k.nachname 
	AND k.landesliste_id = l.id AND l.land_id = g.land_id AND g.partei_id = l.partei_id
),
--Wählt alle gültigen parteien (>5%, mehr als 2 direktkandidaten) aus
 parteien_dabei as (
	SELECT pspl.* FROM partei_stimmen_pro_land pspl, parteien_einzug pe
	WHERE pspl.partei_id = pe.partei_id
), 
scherper_gewicht as (

SELECT ps.partei_id, stimmen::numeric/f.faktor as gewicht
FROM parteien_dabei ps, scherperfaktoren f
WHERE ps.land_id = $1
AND ps.partei_id NOT IN (SELECT * FROM direktkandidaten_gewinner)
ORDER BY gewicht DESC
LIMIT (SELECT COUNT(*) FROM wahlkreis w WHERE w.land_id = $1)*2
)
SELECT partei_id, count(partei_id) as sitze
FROM scherper_gewicht
GROUP BY partei_id;

$BODY$
  LANGUAGE sql VOLATILE
  COST 100
  ROWS 10;
ALTER FUNCTION sitze_partei_ein_land(integer)
  OWNER TO alexx;
