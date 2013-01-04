UPDATE zweitstimmen_aggregation za
SET stimmen_vorperiode = s5zi.stimmen
FROM stimmen2005.zweitstimme_insges s5zi , landesliste l
WHERE s5zi.landesliste_id = l.id
AND l.partei_id = za.partei_id
AND s5zi.wahlkreis_id = za.wahlkreis_id;
