UPDATE erststimmen_aggregation ea 
SET stimmen_vorperiode = s5ei.stimmen
FROM stimmen2005.erststimme_insges s5ei
WHERE s5ei.kandidat_id = ea.direktkandidat_id
AND s5ei.wahlkreis_id = ea.wahlkreis_id;

