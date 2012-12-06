WITH bla AS (

WITH direkt_sitze AS
(
SELECT land_id, partei_id, COUNT(*) anzahl_direktkandidaten FROM wahl_gewinner wg
GROUP BY land_id, partei_id
)
SELECT sp.land_id, sp.partei_id, coalesce(sp.sitze,0) - coalesce(ds.anzahl_direktkandidaten,0) plaetze
FROM sitze_partei_bundesland_2009 sp LEFT OUTER JOIN direkt_sitze ds ON 
 (ds.land_id = sp.land_id AND ds.partei_id = sp.partei_id)
)
SELECT * FROM bla
--SELECT * FROM bla WHERE plaetze < 0 and partei_id not in (28, 7)




--SELECT * FROM sitze_partei_bundesland_2009;

--SELECT lk.*, l.partei_id, l.land_id FROM landeskandidat lk, landesliste l 
--WHERE lk.landesliste_id = l.id

--ORDER BY landesliste_id, listenrang

