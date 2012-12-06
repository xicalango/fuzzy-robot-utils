SELECT g.* FROM wahl_gewinner g, direktkandidat d, landeskandidat k, landesliste l
WHERE g.kandidat_id = d.id AND g.land_id = 16
AND d.vorname = k.vorname AND d.nachname = k.nachname 
AND k.landesliste_id = l.id AND l.land_id = g.land_id AND g.partei_id = l.partei_id