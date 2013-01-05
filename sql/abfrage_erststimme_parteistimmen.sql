with ss as (
SELECT sum(stimmen) FROM stimmen2009.direktkandidat_stimmen
), partei_stimmen as (
SELECT partei_id, sum(stimmen) FROM stimmen2009.erststimme_insges s, direktkandidat d
WHERE 	s.kandidat_id = d.id
GROUP BY partei_id
)
SELECT ps.partei_id, ps."sum" stimmen, (ps."sum"*100/ss."sum"::double precision)::numeric(3,1) percent FROM partei_stimmen ps, ss
ORDER BY percent DESC