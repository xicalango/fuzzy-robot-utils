--Abfrage ob ein Kandidat mit gleichem Vorname,Nachname,Jahrgang,Partei doppelt vorkommt
--Notwendig, weil wahlbewerber_mit_wahlkreis ohne Kandidatennummer daherkommt

SELECT w."Kandidatennummer", COUNT(*) FROM raw.wahlbewerber_mit_wahlkreis ww, raw.wahlbewerber w
WHERE 
	ww."Vorname" = w."Vorname" AND
	ww."Nachname" = w."Nachname" AND
	ww."Jahrgang" = w."Jahrgang" AND
	ww."Partei" = w."Partei"
GROUP BY w."Kandidatennummer"
HAVING COUNT(*) > 1