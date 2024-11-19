DROP TABLE IF EXISTS releve.Releve CASCADE;
DROP TABLE IF EXISTS releve.Temps CASCADE;
DROP TABLE IF EXISTS releve.Localisation CASCADE;
DROP TABLE IF EXISTS releve.ConditionEnvironnemental CASCADE;
DROP TABLE IF EXISTS releve.Date CASCADE;
DROP TABLE IF EXISTS releve.Capteur CASCADE;
DROP TABLE IF EXISTS releve.TypeCapteur CASCADE;
DROP TABLE IF EXISTS releve.Saison CASCADE;
DROP TYPE IF EXISTS releve.departement_region;
DROP VIEW IF EXISTS releve.LocalisationView;
DROP MATERIALIZED VIEW IF EXISTS releve.DTL;
DROP MATERIALIZED VIEW IF EXISTS releve.TSCEL;
DROP MATERIALIZED VIEW IF EXISTS releve.DTLPartition;

-- Création de la table TypeCapteur
CREATE TABLE releve.TypeCapteur (
    id_type SERIAL PRIMARY KEY,
    nom_type VARCHAR(50) NOT NULL
);

-- Création de la table Capteur
CREATE TABLE releve.Capteur (
    id_capteur SERIAL PRIMARY KEY,
    marque VARCHAR(50) NOT NULL,
    modele VARCHAR(50) NOT NULL,
    precision NUMERIC(5, 2),
    date_installation DATE,
    plage_mesure VARCHAR(50),
    status VARCHAR(20),
    frequence VARCHAR(20),
    fournisseur VARCHAR(50),
    id_type INT REFERENCES releve.TypeCapteur(id_type)
);

-- Création de la table Localisation
CREATE TABLE releve.Localisation (
    id_localisation SERIAL PRIMARY KEY,
    longitude NUMERIC(10, 6),
    latitude NUMERIC(10, 6),
    altitude NUMERIC(5, 2),
    ville VARCHAR(50),
    departement VARCHAR(50),
    region VARCHAR(50),
    nombre_habitant INT,
    consommation NUMERIC(10, 2),
    zone_protege BOOLEAN,
    type_terrain VARCHAR(50)
);

-- Création de la table Date
CREATE TABLE releve.Date (
    id_date SERIAL PRIMARY KEY,
    jour INT CHECK (jour BETWEEN 1 AND 31),
    mois INT CHECK (mois BETWEEN 1 AND 12),
    annee INT CHECK (annee > 0)
);

-- Création de la table Temps
CREATE TABLE releve.Temps (
    id_temps SERIAL PRIMARY KEY,
    heure INT CHECK (heure BETWEEN 0 AND 23),
    minute INT CHECK (minute BETWEEN 0 AND 59),
    seconde INT CHECK (seconde BETWEEN 0 AND 59)
);

-- Création de la table Saison
CREATE TABLE releve.Saison (
    id_saison SERIAL PRIMARY KEY,
    nom VARCHAR(20) NOT NULL
);

-- Création de la table ConditionEnvironnemental
CREATE TABLE releve.ConditionEnvironnemental (
    id_condition SERIAL PRIMARY KEY,
    type_meteo VARCHAR(50),
    visibilite VARCHAR(50),
    nebulosite VARCHAR(50),
    type_precipitation VARCHAR(50),
    qualite_air VARCHAR(50),
    risque VARCHAR(50)
);

-- Création de la table Releve (Table de faits)
CREATE TABLE releve.Releve (
    id_temps INT REFERENCES releve.Temps(id_temps),
    id_localisation INT REFERENCES releve.Localisation(id_localisation),
    id_condition INT REFERENCES releve.ConditionEnvironnemental(id_condition),
    id_date INT REFERENCES releve.Date(id_date),
    id_capteur INT REFERENCES releve.Capteur(id_capteur),
    id_type_capteur INT REFERENCES releve.TypeCapteur(id_type),
    id_saison INT REFERENCES releve.Saison(id_saison),
    energie_solaire NUMERIC(10, 2),
    temperature NUMERIC(5, 2),
    vitesse_vent NUMERIC(5, 2),
    direction_vent NUMERIC(5, 2),
    precipitation NUMERIC(5, 2),
    humidite NUMERIC(5, 2),
    pression_atmo NUMERIC(6, 2),
    debit_eau NUMERIC(10, 2),
    PRIMARY KEY (id_temps, id_localisation, id_date, id_capteur, id_type_capteur, id_condition, id_saison)
);

COMMIT;

-- Créer un type composite pour représenter un département et sa région
CREATE TYPE releve.departement_region AS (
    departement TEXT,
    region TEXT
);

CREATE VIEW releve.LocalisationView AS
	SELECT *
	FROM releve.Localisation;
	
CREATE MATERIALIZED VIEW releve.DTL AS
SELECT          
    d.mois,
    d.annee,           
    t.heure,             
    l.departement,          
    l.region,           
    r.energie_solaire,
    r.precipitation,
    r.debit_eau
FROM releve.Releve r
JOIN releve.Localisation l ON r.id_localisation = l.id_localisation
JOIN releve.Date d ON r.id_date = d.id_date
JOIN releve.Temps t ON r.id_temps = t.id_temps;
    
CREATE MATERIALIZED VIEW releve.TSCEL AS
SELECT         
    t.heure,             
    l.ville,
    l.departement,          
    l.region,
    s.nom AS saison,  
    ce.type_meteo,     
    r.temperature,
    r.vitesse_vent,
    r.precipitation
FROM releve.Releve r
JOIN releve.Localisation l ON r.id_localisation = l.id_localisation
JOIN releve.ConditionEnvironnemental ce ON r.id_condition = ce.id_condition
JOIN releve.Saison s ON s.id_saison = r.id_saison
JOIN releve.Temps t ON r.id_temps = t.id_temps;




-- Vue avec partition (pas vu en cours mais en BUT)
CREATE MATERIALIZED VIEW releve.DTLPartition AS
SELECT 
    l.departement,
    l.region,
    d.annee,
    d.mois,
    t.heure,
    r.energie_solaire,
    ROUND(AVG(r.energie_solaire) OVER (PARTITION BY l.departement, d.annee, d.mois), 0) AS moyenne_ensoleillement,
    ROUND(AVG(r.precipitation) OVER (PARTITION BY d.annee, d.mois), 0) AS moyenne_precipitation,
    ROUND(AVG(r.debit_eau) OVER (PARTITION BY l.region, t.heure), 0) AS debit_moyen
FROM releve.Releve r
JOIN releve.Localisation l ON r.id_localisation = l.id_localisation
JOIN releve.Date d ON r.id_date = d.id_date
JOIN releve.Temps t ON r.id_temps = t.id_temps;

COMMIT;










	
