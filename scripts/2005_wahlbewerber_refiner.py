#!/usr/bin/env python

import csv

FILE_PATH = '/home/alexx/Uni/btw2009/Daten/wahlbewerber2005.csv'

rows = []

with open(FILE_PATH, 'r') as csvfile:
	reader = csv.reader(csvfile, delimiter=',', quotechar='"')
	for row in reader:
		rows.append(row)

bewerbers = []

for i in range(1, len(rows)):
	row = rows[i]
	
	d = 0
	
	try:
		_ = int(row[7])
		d = 1
	except ValueError:
		pass
		
	try:
		_ = int(row[5])
		d = 2
	except ValueError:
		pass
		


	bewerber = {
		"name": row[0],
		"vorname": row[1],
		"partei": row[8+d],
		"wahlkreis": row[9+d],
		"land": row[10+d],
		"platz": row[11+d]
	}
	
	bewerbers.append(bewerber)
	
	
with open('bewerber2005.csv', 'w') as csvfile:
	writer = csv.writer(csvfile, delimiter=',', quotechar='"', quoting=csv.QUOTE_NONNUMERIC)
	writer.writerow(["Vorname","Name","Partei","Wahlkreis","Land","Platz"])

	for b in bewerbers:
	
	
		writer.writerow([ b["vorname"][1:],b["name"],b["partei"],b["wahlkreis"],b["land"],b["platz"] ])
	


