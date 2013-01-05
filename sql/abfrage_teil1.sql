/*
WITH direktkandidaten_gewinner AS (
	SELECT g.partei_id FROM wahl_gewinner g, direktkandidat d, landeskandidat k, landesliste l
	WHERE g.kandidat_id = d.id AND g.land_id = 16
	AND d.vorname = k.vorname AND d.nachname = k.nachname 
	AND k.landesliste_id = l.id AND l.land_id = g.land_id AND g.partei_id = l.partei_id
),
*/
WITH parteien_dabei as (
	SELECT pspl.* FROM partei_stimmen_pro_land pspl, parteien_einzug pe
	WHERE pspl.partei_id = pe.partei_id
), 
scherper_gewicht as (

SELECT ps.partei_id, stimmen::numeric/f.faktor as gewicht
FROM parteien_dabei ps, scherperfaktoren f
WHERE ps.land_id = 16
--AND ps.partei_id NOT IN (SELECT * FROM direktkandidaten_gewinner)
ORDER BY gewicht DESC
--LIMIT (SELECT COUNT(*) FROM wahlkreis w WHERE w.land_id = 10)*2
)
SELECT * FROM scherper_gewicht;
--SELECT partei_id, count(partei_id) as sitze
--FROM scherper_gewicht
--GROUP BY partei_id;