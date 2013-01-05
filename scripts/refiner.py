#!/usr/bin/env python

import csv

FILE_PATH = '/home/alexx/Dropbox/db-btw2009/csvDaten/alex/kerg2009.csv'

rows = []

with open(FILE_PATH, 'r') as csvfile:
    reader = csv.reader(csvfile, delimiter=';', quotechar='"')
    for row in reader:
        rows.append(row)
       

headers = [
    rows[0],
    rows[1],
    rows[2]
]

def getHeader(n, col):
    if col < 3:
        return headers[n][col]
    
    while( len(headers[n][col]) == 0 ):
        col -= 1
    
    return headers[n][col]
    
def getAllHeaders(col):
    return [ getHeader(0,col), getHeader(1,col), getHeader(2,col) ]

allHeaders = []

for i in range(0,len(rows[2])):
    allHeaders.append(getAllHeaders(i))
    
infos = []

partySet = set()

for i in range(3,len(allHeaders)):
    for j in range(3,len(rows)):
        info = {
            "name": allHeaders[i][0],
            "voteType": allHeaders[i][1],
            "timeType": allHeaders[i][2],
            "areaName": rows[j][1],
            "result": rows[j][i],
            "nr" : rows[j][0],
            "belongsTo": rows[j][2]
        }
        partySet.add(allHeaders[i][0])
        infos.append(info)

predicates = {
    "ErststimmenEndgueltig": lambda i: i["timeType"] == "Endg\xfcltig" and i["voteType"] == "Erststimmen" and len(i["areaName"])>0,
    "ZweitstimmenEndgueltig": lambda i: i["timeType"] == "Endg\xfcltig" and i["voteType"] == "Zweitstimmen" and len(i["areaName"])>0,
    "ErststimmenVorperiode": lambda i: i["timeType"] == "Vorperiode" and i["voteType"] == "Erststimmen" and len(i["areaName"])>0,
    "ZweitstimmenVorperiode": lambda i: i["timeType"] == "Vorperiode" and i["voteType"] == "Zweitstimmen" and len(i["areaName"])>0
}

for k,v in predicates.items():

    with open(k + '.csv', 'w') as csvfile:
        writer = csv.writer(csvfile, delimiter=';', quotechar='"')
        writer.writerow(["Nr","Geh\xf6rt zu","Gebiet","Partei","Stimmen"])
        
        for info in infos:
            if v(info):
                writer.writerow([info["nr"], info["belongsTo"], info["name"], info["areaName"], info["result"]])


