#!/usr/bin/env python

import csv

FILE_PATH = '/home/alexx/Uni/btw2009/Daten/StruktBtwkr2005.csv'

rows = []

with open(FILE_PATH, 'r') as csvfile:
    reader = csv.reader(csvfile, delimiter=';', quotechar='"')
    for row in reader:
        rows.append(row)
       

headers = [
    rows[0],
    rows[1]
]


with open('wahlkreise2005.csv', 'w') as csvfile:	
	writer = csv.writer(csvfile, delimiter=',', quotechar='"')
	writer.writerow(["Nummer","Land","Name"])
	
	for i in range(3,len(rows)):
		row = rows[i]
		if len(row) > 0 and row[1] != '0':
			writer.writerow([int(row[1]), row[0], row[2]])

