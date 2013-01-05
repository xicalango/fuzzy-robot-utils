DROP TABLE scherperFaktoren;
CREATE TABLE scherperFaktoren AS SELECT scherper_faktoren as faktor FROM scherper_faktoren();
ALTER TABLE scherperFaktoren ADD PRIMARY KEY (faktor);