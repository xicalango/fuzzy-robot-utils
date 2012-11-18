

--Assoziationstabelle für Zweitstimmen(ParteiId, Wahlkreis_id, Stimmenanzahl):

create table zweitstimmen_assoziation as(
select p.id as partei_id, zl.wahlkreis_id as wahlkreis_id, zl.stimmen as stimmen from partei p,
(select z.landesliste_id, z.wahlkreis_id, count(z) as stimmen from zweitstimme z, landesliste ll
where z.landesliste_id = ll.id
group by z.landesliste_id, z.wahlkreis_id) as zl, landesliste ll2
where ll2.id = zl.landesliste_id and p.id = ll2.partei_id
);
alter table zweitstimmen_assoziation add primary key (partei_id, wahlkreis_id);


--Tabelle, die für jede Partei die prozentual erreichten Zweitstimmen angibt (Partei, prozent_zweitstimmen)

--Gesamtstimmen:
select sum(stimmen) from zweitstimmen_assoziation;

--Zweitstimmen pro Partei gesamt:
CREATE OR REPLACE VIEW partei_zweitstimmen AS 
SELECT partei_id, SUM(stimmen) AS stimmen FROM zweitstimmen_assoziation
GROUP BY partei_id;

--Prozent pro Partei:
create view prozent_zweitstimmen as(
select sp.partei_id as partei_id, sp.stimmen/(select sum(stimmen) as prozent_zweitstimmen from zweitstimmen_assoziation) from (select partei_id, sum(stimmen) as stimmen from zweitstimmen_assoziation group by partei) sp;
);

--Assoziationstabelle für Erststimmen(KandidatId, Wahlkreis_id, Stimmenanzahl):

create table erststimmen_assoziation as
(select s.direktkandidat_id as direktkandidat_id, s.wahlkreis_id as wahlkreis_id, count(s) as stimmen from direktkandidat d, wahlkreis w, erststimme s
where s.wahlkreis_id = w.id and s.direktkandidat_id = d.id
group by s.direktkandidat_id, s.wahlkreis_id);
alter table erststimmen_assoziation add primary key (direktkandidat_id, wahlkreis_id);


--Scherper Auswertung

-- Function: scherper_faktoren()
CREATE OR REPLACE FUNCTION scherper_faktoren()
  RETURNS SETOF numeric AS
$BODY$
BEGIN
	FOR i IN 0..597 LOOP -- insges 598 zeilen
		RETURN NEXT i+0.5;
	END LOOP;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100
  ROWS 1000;
  
--Möglich: Speichern der berechneten scherper_faktoren in einer extra Tabelle:
DROP TABLE IF EXISTS scherperFaktoren;
CREATE TABLE scherperFaktoren AS SELECT scherper_faktoren as faktor FROM scherper_faktoren();
ALTER TABLE scherperFaktoren ADD PRIMARY KEY (faktor);


--Idee: kreuzprodukt zwischen partei.stimmen und scherperFaktoren

CREATE OR REPLACE VIEW scherper_auswertung AS 
 SELECT pza.partei_id, pza.stimmen::numeric / s.faktor AS gewicht
   FROM partei_zweitstimmen pza, scherperfaktoren s
  WHERE (pza.stimmen::numeric / (( SELECT sum(partei_zweitstimmen.stimmen) AS sum
           FROM partei_zweitstimmen))) >= 0.05
  ORDER BY pza.stimmen::numeric / s.faktor DESC;


--Sitzverteilung

CREATE OR REPLACE VIEW sitzverteilung_partei AS 
 WITH auswetung AS (
         SELECT saw.partei_id, saw.gewicht
           FROM scherper_auswertung saw
		  ORDER BY saw.gewicht DESC
         LIMIT 598
        )
 SELECT auswetung.partei_id, p.name, count(*) AS count
   FROM auswetung, partei p
  WHERE auswetung.partei_id = p.id
  GROUP BY auswetung.partei_id, p.name
  ORDER BY count(*) DESC;
  
-- Pro Bundesland:

CREATE OR REPLACE VIEW sitzeParteiBundesland AS 
 WITH wahlkreise_pro_land AS (
         SELECT get_wahlkreis_by_jahr.land_id, count(*) AS wk_count
           FROM get_wahlkreis_by_jahr(2009) get_wahlkreis_by_jahr(id, name, land_id)
          GROUP BY get_wahlkreis_by_jahr.land_id
        )
 SELECT sv.partei_id, round(((sv.count * wpl.wk_count * 2)::double precision / 598::double precision)::numeric, 0) AS sitze, wpl.land_id
   FROM sitzverteilung_partei_alexx sv, wahlkreise_pro_land wpl;
  
--Wahl gewinner

--Maximale Direktkandidaten pro Wahlkreis

create view direktkandidat_gewinner as (
select ea.wahlkreis_id, ea.direktkandidat_id, ea.stimmen from erststimmenassoziation ea
where ea.stimmen >= (select max(stimmen) from erststimmenassoziation ea2 where ea.wahlkreis_id = ea2.wahlkreis_id group by ea2.wahlkreis_id)
order by ea.wahlkreis_id desc);

--Und nun die Wahlgewinner unter Benutzung der Maximalen Direktkandidaten pro Wahlkreis View

create table wahl_gewinner (kandidat_id, typ, land_id, partei_id) as(
select dg.direktkandidat_id, "Direktkandidat", l.id, p.id
from direktkandidat_gewinner dg, direktdandidat d, land l, partei p, wahlkreis wk
where dg.direktkandidat_id = d.id and d.partei_id = p.id and dg.wahlkreis_id = wk.id and wk.land_id = l.id
);
alter table wahl_gewinner add primary key (direktkandidat_id, typ);