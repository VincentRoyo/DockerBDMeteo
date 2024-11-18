-- Insertion des types de clients dans la table TypeClient
INSERT INTO consommation.TypeClient (nom_type) VALUES
    ('Particulier'),
    ('Petite entreprise'),
    ('Moyenne entreprise'),
    ('Grande entreprise'),
    ('Administration publique'),
    ('Industriel');
    
COMMIT;

-- Insertion des sources d'énergie dans la table SourceEnergie
INSERT INTO consommation.SourceEnergie (nom, type_energie) VALUES
    ('Solaire', 'Renouvelable'),
    ('Éolien', 'Renouvelable'),
    ('Hydraulique', 'Renouvelable'),
    ('Pétrole', 'Fossile'),
    ('Charbon', 'Fossile'),
    ('Gaz naturel', 'Fossile');
    
COMMIT;

-- Insertion des 1 000 clients dans la table Client
DO $$
DECLARE
    i INT;
    type_client_id INT;
BEGIN
    -- Boucle pour insérer 1000 clients
    FOR i IN 1..1000 LOOP
        -- Sélection aléatoire du type de client
        type_client_id := (SELECT id_type FROM consommation.TypeClient ORDER BY RANDOM() LIMIT 1);

        -- Insertion du client
        INSERT INTO consommation.Client (nom, prenom, num_telephone, email, adresse, date_inscription, date_naissance, id_type)
        VALUES (
            'NomClient' || i, -- Nom générique : NomClient1, NomClient2, ...
            'PrenomClient' || i, -- Prénom générique : PrenomClient1, PrenomClient2, ...
            '06' || (RANDOM() * 1000000000)::INT, -- Numéro de téléphone aléatoire
            'email' || i || '@exemple.com', -- Email générique
            'Adresse ' || i, -- Adresse générique
            '2023-01-01'::DATE + (RANDOM() * 365)::INT, -- Date d'inscription aléatoire dans l'année 2023
            '1980-01-01'::DATE + (RANDOM() * 15000)::INT, -- Date de naissance aléatoire
            type_client_id
        );
    END LOOP;
END $$;

COMMIT;


-- Insertion des 1 000 contrats dans la table Contrat
DO $$
DECLARE
    i INT;
    client_id INT;
    contrat_type VARCHAR(50);
    date_debut DATE;
    date_fin DATE;
    duree INT;
    prime NUMERIC(10, 2);
    plafond_conso NUMERIC(10, 2);
    statut VARCHAR(20);
    type_logement VARCHAR(50);
    penalite NUMERIC(10, 2);
BEGIN
    -- Boucle pour insérer 1000 contrats
    FOR i IN 1..1000 LOOP
        -- Sélection aléatoire d'un client
        client_id := (SELECT id_client FROM consommation.Client ORDER BY RANDOM() LIMIT 1);

        -- Définir aléatoirement le type du contrat
        contrat_type := CASE
            WHEN i % 2 = 0 THEN 'Electricité'
            ELSE 'Gaz'
        END;

        -- Définir aléatoirement les dates de début et de fin du contrat
        date_debut := '2023-01-01'::DATE + (RANDOM() * 365)::INT; -- Date aléatoire sur l'année 2023
        date_fin := date_debut + (RANDOM() * 12 + 6)::INT; -- Durée aléatoire entre 6 et 18 mois

        -- Durée en mois (aléatoire entre 6 et 18 mois)
        duree := (RANDOM() * 12 + 6)::INT;

        -- Prime aléatoire (entre 50 et 500)
        prime := ROUND((RANDOM() * 450 + 50)::NUMERIC, 2);

        -- Plafond de consommation (entre 100 et 1000)
        plafond_conso := ROUND((RANDOM() * 900 + 100)::NUMERIC, 2);

        -- Statut du contrat aléatoire
        statut := CASE
            WHEN i % 2 = 0 THEN 'Actif'
            ELSE 'Inactif'
        END;

        -- Type de logement aléatoire
        type_logement := CASE
            WHEN i % 4 = 0 THEN 'Appartement'
            WHEN i % 4 = 1 THEN 'Maison'
            WHEN i % 4 = 2 THEN 'Bureau'
            ELSE 'Zone industriel'
        END;

        -- Pénalité aléatoire (entre 0 et 20)
        penalite := ROUND((RANDOM() * 20)::NUMERIC, 2);

        -- Insertion du contrat
        INSERT INTO consommation.Contrat (type, date_debut, date_fin, duree, prime, plafond_conso, statut, type_logement, penalite)
        VALUES (
            contrat_type,
            date_debut,
            date_fin,
            duree,
            prime,
            plafond_conso,
            statut,
            type_logement,
            penalite
        );
    END LOOP;
END $$;

COMMIT;


-- Insertion dans la table Tarification (au moins 20 tuples avec indexation en pourcentage et types/périodes modifiés)
INSERT INTO consommation.Tarification (type, periode_application, indexation_tarifaire, prix_base, tarif_heure_pointe, historique_tarifaire, remise, tarif_minimum, frais_annexe)
VALUES
    ('Standard', 'Mensuel', 5.0, 0.10, 0.12, 'Historique1', 0.05, 0.08, 2.00),
    ('Premium', 'Trimestriel', 7.5, 0.15, 0.18, 'Historique2', 0.07, 0.10, 2.50),
    ('Economique', 'Semestriel', 10.0, 0.20, 0.22, 'Historique3', 0.08, 0.12, 3.00),
    ('Standard', 'Mensuel', 5.5, 0.25, 0.27, 'Historique4', 0.10, 0.14, 3.50),
    ('Premium', 'Trimestriel', 6.0, 0.30, 0.32, 'Historique5', 0.12, 0.16, 4.00),
    ('Economique', 'Annuel', 8.0, 0.35, 0.37, 'Historique6', 0.14, 0.18, 4.50),
    ('Standard', 'Mensuel', 6.5, 0.40, 0.42, 'Historique7', 0.15, 0.20, 5.00),
    ('Premium', 'Semestriel', 7.0, 0.45, 0.47, 'Historique8', 0.16, 0.22, 5.50),
    ('Economique', 'Annuel', 9.0, 0.50, 0.52, 'Historique9', 0.17, 0.24, 6.00),
    ('Standard', 'Mensuel', 6.8, 0.55, 0.57, 'Historique10', 0.18, 0.26, 6.50),
    ('Premium', 'Trimestriel', 8.0, 0.60, 0.62, 'Historique11', 0.19, 0.28, 7.00),
    ('Economique', 'Semestriel', 9.5, 0.65, 0.67, 'Historique12', 0.20, 0.30, 7.50),
    ('Standard', 'Mensuel', 7.2, 0.70, 0.72, 'Historique13', 0.21, 0.32, 8.00),
    ('Premium', 'Trimestriel', 8.5, 0.75, 0.77, 'Historique14', 0.22, 0.34, 8.50),
    ('Economique', 'Annuel', 10.0, 0.80, 0.82, 'Historique15', 0.23, 0.36, 9.00),
    ('Standard', 'Mensuel', 7.8, 0.85, 0.87, 'Historique16', 0.24, 0.38, 9.50),
    ('Premium', 'Semestriel', 9.0, 0.90, 0.92, 'Historique17', 0.25, 0.40, 10.00),
    ('Economique', 'Annuel', 11.0, 0.95, 0.97, 'Historique18', 0.26, 0.42, 10.50),
    ('Standard', 'Mensuel', 8.2, 1.00, 1.02, 'Historique19', 0.27, 0.44, 11.00),
    ('Premium', 'Trimestriel', 10.0, 1.05, 1.07, 'Historique20', 0.28, 0.46, 11.50);
    
COMMIT;


-- Insertion massive dans la table Date pour couvrir plusieurs années avec les saisons
DO $$
DECLARE
    i INT;
    saison VARCHAR(20);
BEGIN
    FOR i IN 1..365 LOOP
        -- Détermination de la saison en fonction du mois et du jour
        IF ((i % 12) + 1) IN (12, 1, 2) OR
           ((i % 12) + 1 = 3 AND (i % 31) + 1 <= 20) THEN
            saison := 'Hiver';  -- Décembre, janvier, février et fin mars
        ELSIF ((i % 12) + 1) IN (3, 4, 5) OR
              ((i % 12) + 1 = 6 AND (i % 31) + 1 <= 20) THEN
            saison := 'Printemps';  -- Mars, avril, mai et début juin
        ELSIF ((i % 12) + 1) IN (6, 7, 8) OR
              ((i % 12) + 1 = 9 AND (i % 31) + 1 <= 20) THEN
            saison := 'Été';  -- Juin, juillet, août et début septembre
        ELSE
            saison := 'Automne';  -- Septembre, octobre, novembre et fin décembre
        END IF;

        -- Insertion de la date avec la saison
        INSERT INTO consommation.Date (jour, mois, annee, saison)
        VALUES (
            (i % 31) + 1,          -- Jour entre 1 et 31
            ((i % 12) + 1),        -- Mois entre 1 et 12
            2020 + (i % 5),        -- Années de 2020 à 2024
            saison                 -- Saison
        );
    END LOOP;
END $$;

COMMIT;

DO $$
DECLARE
    i INT;
    client_id INT;
    contrat_id INT;
    type_client_id INT;
    source_id INT;
    localisation_id INT;
    tarif_id INT;
    date_id INT;
    cout_total NUMERIC(10, 2);
    emission_co2 NUMERIC(10, 2);
    quantite_total NUMERIC(10, 2);
    quantite_heure_creuse NUMERIC(10, 2);
    quantite_heure_pointe NUMERIC(10, 2);
BEGIN
    -- Boucle pour insérer 50 000 consommations
    FOR i IN 1..50000 LOOP
        -- Sélection aléatoire des IDs pour les relations
        client_id := (SELECT id_client FROM consommation.Client ORDER BY RANDOM() LIMIT 1);
        contrat_id := (SELECT id_contrat FROM consommation.Contrat ORDER BY RANDOM() LIMIT 1);
        type_client_id := (SELECT id_type FROM consommation.TypeClient ORDER BY RANDOM() LIMIT 1);
        source_id := (SELECT id_source FROM consommation.SourceEnergie ORDER BY RANDOM() LIMIT 1);
        localisation_id := (SELECT id_localisation FROM releve.Localisation ORDER BY RANDOM() LIMIT 1);
        tarif_id := (SELECT id_tarification FROM consommation.Tarification ORDER BY RANDOM() LIMIT 1);
        date_id := (SELECT id_date FROM consommation.Date ORDER BY RANDOM() LIMIT 1);

        -- Génération de valeurs aléatoires pour les autres colonnes
        cout_total := (RANDOM() * 1000)::NUMERIC(10, 2);  -- Coût total aléatoire
        emission_co2 := (RANDOM() * 500)::NUMERIC(10, 2);  -- Émission de CO2 aléatoire
        quantite_total := (RANDOM() * 1000)::NUMERIC(10, 2);  -- Quantité totale consommée
        quantite_heure_creuse := (RANDOM() * quantite_total)::NUMERIC(10, 2);  -- Quantité en heure creuse
        quantite_heure_pointe := quantite_total - quantite_heure_creuse;  -- Le reste en heure pointe

        -- Insertion d'une consommation aléatoire
        INSERT INTO consommation.Consommation (
            id_type_client, id_source_energie, id_localisation, id_client, id_contrat,
            id_tarification, id_date, cout_total, emission_co2, quantite_total, quantite_heure_creuse, quantite_heure_pointe
        )
        VALUES (
            type_client_id,  -- ID du type de client
            source_id,  -- ID de la source d'énergie
            localisation_id,  -- ID de la localisation
            client_id,  -- ID du client
            contrat_id,  -- ID du contrat
            tarif_id,  -- ID de la tarification
            date_id,  -- ID de la date
            cout_total,  -- Coût total
            emission_co2,  -- Émission de CO2
            quantite_total,  -- Quantité totale
            quantite_heure_creuse,  -- Quantité en heure creuse
            quantite_heure_pointe  -- Quantité en heure pointe
        );
    END LOOP;
END $$;

COMMIT;





