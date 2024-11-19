-- Supprimer les tables existantes pour éviter les conflits
DROP TABLE IF EXISTS consommation.Consommation CASCADE;
DROP TABLE IF EXISTS consommation.Client CASCADE;
DROP TABLE IF EXISTS consommation.Contrat CASCADE;
DROP TABLE IF EXISTS consommation.Tarification CASCADE;
DROP TABLE IF EXISTS consommation.Date CASCADE;
DROP TABLE IF EXISTS consommation.SourceEnergie CASCADE;
DROP TABLE IF EXISTS consommation.TypeClient CASCADE;
DROP MATERIALIZED VIEW IF EXISTS consommation.DTCL;

-- Création de la table TypeClient
CREATE TABLE consommation.TypeClient (
    id_type SERIAL PRIMARY KEY,
    nom_type VARCHAR(50) NOT NULL
);

-- Création de la table Client
CREATE TABLE consommation.Client (
    id_client SERIAL PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    prenom VARCHAR(50),
    num_telephone VARCHAR(15),
    email VARCHAR(100),
    adresse VARCHAR(100),
    date_inscription DATE,
    date_naissance DATE,
    id_type INT REFERENCES consommation.TypeClient(id_type)
);


-- Création de la table Date
CREATE TABLE consommation.Date (
    id_date SERIAL PRIMARY KEY,
    jour INT CHECK (jour BETWEEN 1 AND 31),
    mois INT CHECK (mois BETWEEN 1 AND 12),
    annee INT CHECK (annee > 0),
    saison VARCHAR(20)
);

-- Création de la table SourceEnergie
CREATE TABLE consommation.SourceEnergie (
    id_source SERIAL PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    type_energie VARCHAR(50) NOT NULL
);

-- Création de la table Contrat
CREATE TABLE consommation.Contrat (
    id_contrat SERIAL PRIMARY KEY,
    type VARCHAR(50),
    date_debut DATE,
    date_fin DATE,
    duree INT,
    prime NUMERIC(10, 2),
    plafond_conso NUMERIC(10, 2),
    statut VARCHAR(20),
    type_logement VARCHAR(50),
    penalite NUMERIC(10, 2)
);

-- Création de la table Tarification
CREATE TABLE consommation.Tarification (
    id_tarification SERIAL PRIMARY KEY,
    type VARCHAR(50),
    periode_application VARCHAR(50),
    indexation_tarifaire VARCHAR(50),
    prix_base NUMERIC(10, 2),
    tarif_heure_pointe NUMERIC(10, 2),
    historique_tarifaire VARCHAR(50),
    remise NUMERIC(10, 2),
    tarif_minimum NUMERIC(10, 2),
    frais_annexe NUMERIC(10, 2)
);

-- Création de la table Consommation (Table de faits)
CREATE TABLE consommation.Consommation (
    id_type_client INT REFERENCES consommation.TypeClient(id_type),
    id_source_energie INT REFERENCES consommation.SourceEnergie(id_source),
    id_localisation INT REFERENCES releve.Localisation(id_localisation),
    id_client INT REFERENCES consommation.Client(id_client),
    id_contrat INT REFERENCES consommation.Contrat(id_contrat),
    id_tarification INT REFERENCES consommation.Tarification(id_tarification),
    id_date INT REFERENCES consommation.Date(id_date),
    cout_total NUMERIC(10, 2),
    emission_co2 NUMERIC(10, 2),
    quantite_total NUMERIC(10, 2),
    quantite_heure_creuse NUMERIC(10, 2),
    quantite_heure_pointe NUMERIC(10, 2),
    PRIMARY KEY (id_client, id_date, id_contrat, id_type_client, id_source_energie, id_localisation, id_tarification)
);

COMMIT;

CREATE MATERIALIZED VIEW consommation.DTCL AS
SELECT
    d.jour,
    d.mois,             
    d.annee,          
    d.saison,           
    t.type AS type_tarification,
    c.nom AS nom,
    c.prenom AS prenom, 
    c.date_naissance,
    cons.id_type_client,
    cons.id_contrat,
    cons.cout_total,
    cons.emission_co2,
    cons.quantite_total,
    cons.quantite_heure_creuse,
    cons.quantite_heure_pointe
FROM consommation.Consommation cons
JOIN consommation.Date d ON cons.id_date = d.id_date 
JOIN consommation.Tarification t ON t.id_tarification = cons.id_tarification
JOIN consommation.Client c ON cons.id_client = c.id_client;
