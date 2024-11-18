-- Création des données pour TypeCapteur
INSERT INTO releve.TypeCapteur (nom_type) VALUES
    ('Température'),
    ('Luminosité'),
    ('Pression atmosphérique'),
    ('Humidité'),
    ('Vent'),
    ('Débit eau'),
    ('Précipitation');
    
COMMIT;

-- Création des données pour Saison
INSERT INTO releve.Saison (nom) VALUES
    ('Hiver'),
    ('Printemps'),
    ('Été'),
    ('Automne');
    
COMMIT;

-- Insertion massive dans la table Date pour couvrir plusieurs années
DO $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..365 LOOP
        INSERT INTO releve.Date (jour, mois, annee)
        VALUES (
            (i % 31) + 1,          -- Jour entre 1 et 31
            ((i % 12) + 1),        -- Mois entre 1 et 12
            2020 + (i % 5)         -- Années de 2020 à 2024
        );
    END LOOP;
END $$;

COMMIT;

-- Insertion massive dans la table Temps pour toutes les secondes de la journée (24 heures * 60 minutes * 60 secondes = 86400 secondes)
DO $$
DECLARE
    h INT;
    m INT;
    s INT;
BEGIN
    FOR h IN 0..23 LOOP
        FOR m IN 0..59 LOOP
            FOR s IN 0..59 LOOP
                INSERT INTO releve.Temps (heure, minute, seconde)
                VALUES (h, m, s);
            END LOOP;
        END LOOP;
    END LOOP;
END $$;

COMMIT;


-- Insertion des données dans la table Localisation pour 18 régions et 101 départements de France
DO $$
DECLARE
    i INT;
    departement_record releve.departement_region;  -- Déclaration d'un enregistrement avec notre type composite
    v_ville TEXT;
    v_region TEXT;
    v_departement TEXT;
    v_latitude DOUBLE PRECISION;
    v_longitude DOUBLE PRECISION;
    v_altitude DOUBLE PRECISION;
    v_population INT;
    v_consommation DOUBLE PRECISION;
    v_zone_protege BOOLEAN;
    v_terrain TEXT;
    total_records INT := 10000;
    region_count INT := 18;
    records_per_region INT := total_records / region_count;

    -- Définir les départements avec leurs codes et régions sous forme de tableau de notre type composite
    departements releve.departement_region[] := ARRAY[
        ('75', 'Île-de-France'),
        ('77', 'Île-de-France'),
        ('78', 'Île-de-France'),
        ('91', 'Île-de-France'),
        ('92', 'Île-de-France'),
        ('93', 'Île-de-France'),
        ('94', 'Île-de-France'),
        ('95', 'Île-de-France'),
        ('13', 'Provence-Alpes-Côte d''Azur'),
        ('83', 'Provence-Alpes-Côte d''Azur'),
        ('06', 'Provence-Alpes-Côte d''Azur'),
        ('04', 'Provence-Alpes-Côte d''Azur'),
        ('05', 'Provence-Alpes-Côte d''Azur'),
        ('84', 'Provence-Alpes-Côte d''Azur'),
        ('31', 'Occitanie'),
        ('32', 'Occitanie'),
        ('34', 'Occitanie'),
        ('09', 'Occitanie'),
        ('11', 'Occitanie'),
        ('12', 'Occitanie'),
        ('46', 'Occitanie'),
        ('65', 'Occitanie'),
        ('66', 'Occitanie'),
        ('81', 'Occitanie'),
        ('82', 'Occitanie'),
        ('01', 'Auvergne-Rhône-Alpes'),
        ('03', 'Auvergne-Rhône-Alpes'),
        ('07', 'Auvergne-Rhône-Alpes'),
        ('15', 'Auvergne-Rhône-Alpes'),
        ('26', 'Auvergne-Rhône-Alpes'),
        ('38', 'Auvergne-Rhône-Alpes'),
        ('42', 'Auvergne-Rhône-Alpes'),
        ('43', 'Auvergne-Rhône-Alpes'),
        ('63', 'Auvergne-Rhône-Alpes'),
        ('69', 'Auvergne-Rhône-Alpes'),
        ('73', 'Auvergne-Rhône-Alpes'),
        ('74', 'Auvergne-Rhône-Alpes'),
        ('02', 'Hauts-de-France'),
        ('59', 'Hauts-de-France'),
        ('60', 'Hauts-de-France'),
        ('62', 'Hauts-de-France'),
        ('80', 'Hauts-de-France'),
        ('16', 'Nouvelle-Aquitaine'),
        ('17', 'Nouvelle-Aquitaine'),
        ('19', 'Nouvelle-Aquitaine'),
        ('23', 'Nouvelle-Aquitaine'),
        ('24', 'Nouvelle-Aquitaine'),
        ('33', 'Nouvelle-Aquitaine'),
        ('40', 'Nouvelle-Aquitaine'),
        ('47', 'Nouvelle-Aquitaine'),
        ('64', 'Nouvelle-Aquitaine'),
        ('79', 'Nouvelle-Aquitaine'),
        ('86', 'Nouvelle-Aquitaine'),
        ('87', 'Nouvelle-Aquitaine'),
        ('14', 'Normandie'),
        ('27', 'Normandie'),
        ('50', 'Normandie'),
        ('61', 'Normandie'),
        ('76', 'Normandie'),
        ('22', 'Bretagne'),
        ('29', 'Bretagne'),
        ('35', 'Bretagne'),
        ('56', 'Bretagne'),
        ('44', 'Pays de la Loire'),
        ('49', 'Pays de la Loire'),
        ('53', 'Pays de la Loire'),
        ('72', 'Pays de la Loire'),
        ('85', 'Pays de la Loire'),
        ('08', 'Grand Est'),
        ('10', 'Grand Est'),
        ('51', 'Grand Est'),
        ('52', 'Grand Est'),
        ('54', 'Grand Est'),
        ('55', 'Grand Est'),
        ('57', 'Grand Est'),
        ('67', 'Grand Est'),
        ('68', 'Grand Est'),
        ('88', 'Grand Est'),
        ('18', 'Centre-Val de Loire'),
        ('28', 'Centre-Val de Loire'),
        ('36', 'Centre-Val de Loire'),
        ('37', 'Centre-Val de Loire'),
        ('41', 'Centre-Val de Loire'),
        ('45', 'Centre-Val de Loire'),
        ('21', 'Bourgogne-Franche-Comté'),
        ('25', 'Bourgogne-Franche-Comté'),
        ('39', 'Bourgogne-Franche-Comté'),
        ('58', 'Bourgogne-Franche-Comté'),
        ('70', 'Bourgogne-Franche-Comté'),
        ('71', 'Bourgogne-Franche-Comté'),
        ('89', 'Bourgogne-Franche-Comté'),
        ('90', 'Bourgogne-Franche-Comté'),
        ('2A', 'Corse'),
        ('2B', 'Corse'),
        ('974', 'La Réunion'),
        ('972', 'Martinique'),
        ('971', 'Guadeloupe'),
        ('973', 'Guyane'),
        ('976', 'Mayotte')
    ];

BEGIN
    -- Insertion des enregistrements pour chaque département
    FOR i IN 1..array_length(departements, 1) LOOP
        departement_record := departements[i];
        
        -- Sélectionner les données pour chaque département
        v_departement := departement_record.departement;
        v_region := departement_record.region;
        v_ville := 'Ville' || i;  -- Nom de ville fictif pour cet exemple

        -- Génération des valeurs aléatoires
        v_latitude := (random() * 90) - 45;
        v_longitude := (random() * 180) - 90;
        v_altitude := (random() * 1000);
        v_population := (random() * 1000000)::INT;
        v_consommation := (random() * 5000);
        v_zone_protege := (i % 2) = 0;
        v_terrain := CASE
            WHEN i % 4 = 0 THEN 'Urbain'
            WHEN i % 4 = 1 THEN 'Forêt'
            WHEN i % 4 = 2 THEN 'Aquatique'
            ELSE 'Sableux'
        END;

        -- Insertion dans la table Localisation
        INSERT INTO releve.Localisation (ville, departement, region, latitude, longitude, altitude, nombre_habitant, consommation, zone_protege, type_terrain)
        VALUES (
            v_ville,
            v_departement,
            v_region,
            v_latitude,
            v_longitude,
            v_altitude,
            v_population,
            v_consommation,
            v_zone_protege,
            v_terrain
        );
    END LOOP;
END $$;

COMMIT;

-- Insertion massive dans la table ConditionEnvironnemental avec des conditions météorologiques variées
DO $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..100 LOOP
        INSERT INTO releve.ConditionEnvironnemental (type_meteo, visibilite, nebulosite, type_precipitation, qualite_air, risque)
        VALUES (
            CASE (i % 6)                              -- Type de météo
                WHEN 0 THEN 'Ensoleillé'
                WHEN 1 THEN 'Nuageux'
                WHEN 2 THEN 'Pluvieux'
                WHEN 3 THEN 'Orageux'
                WHEN 4 THEN 'Neigeux'
                WHEN 5 THEN 'Venteux'
            END,
            CASE (i % 3)                              -- Visibilité
                WHEN 0 THEN 'Bonne'
                WHEN 1 THEN 'Moyenne'
                WHEN 2 THEN 'Faible'
            END,
            CASE (i % 3)                              -- Nébulosité
                WHEN 0 THEN 'Clair'
                WHEN 1 THEN 'Partiellement couvert'
                WHEN 2 THEN 'Couvert'
            END,
            CASE (i % 4)                              -- Type de précipitation
                WHEN 0 THEN NULL
                WHEN 1 THEN 'Pluie'
                WHEN 2 THEN 'Grêle'
                WHEN 3 THEN 'Neige'
            END,
            CASE (i % 3)                              -- Qualité de l'air
                WHEN 0 THEN 'Bonne'
                WHEN 1 THEN 'Modérée'
                WHEN 2 THEN 'Mauvaise'
            END,
            CASE (i % 3)                              -- Risque
                WHEN 0 THEN 'Faible'
                WHEN 1 THEN 'Moyen'
                WHEN 2 THEN 'Élevé'
            END
        );
    END LOOP;
END $$;

COMMIT;

-- Insertion massive dans la table Capteur avec des modèles variés
DO $$
DECLARE
    i INT;
BEGIN
    FOR i IN 1..100 LOOP
        INSERT INTO releve.Capteur (marque, modele, precision, date_installation, plage_mesure, status, frequence, fournisseur, id_type)
        VALUES (
            'Marque' || (i % 10),                        -- Marque fictive
            'Modele' || i,                               -- Modèle fictif
            (random() * 0.1)::NUMERIC(3, 2),             -- Précision aléatoire
            '2022-01-01'::DATE + (i % 365),              -- Date d'installation
            '0-' || (50 + i * 10),                       -- Plage de mesure fictive
            CASE (i % 2)                                 -- Status
                WHEN 0 THEN 'Actif'
                WHEN 1 THEN 'Inactif'
            END,
            CASE (i % 3)                                 -- Fréquence
                WHEN 0 THEN 'Quotidien'
                WHEN 1 THEN 'Hebdomadaire'
                WHEN 2 THEN 'Mensuel'
            END,
            'Fournisseur' || (i % 5),                    -- Fournisseur fictif
            (i % 7) + 1                                  -- Référence au type de capteur
        );
    END LOOP;
END $$;

COMMIT;

-- Insertion massive dans la table Temps pour toutes les secondes de la journée (24 heures * 60 minutes * 60 secondes = 86400 secondes)
DO $$
DECLARE
    h INT;
    m INT;
    s INT;
BEGIN
    FOR h IN 0..23 LOOP
        FOR m IN 0..59 LOOP
            FOR s IN 0..59 LOOP
                INSERT INTO releve.Temps (heure, minute, seconde)
                VALUES (h, m, s);
            END LOOP;
        END LOOP;
    END LOOP;
END $$;

COMMIT;

-- Insertion massive dans la table Releve pour avoir 50 000 enregistrements
DO $$
DECLARE
    i INT;
    v_id_date INT;
    v_id_temps INT;
    v_id_localisation INT;
    v_id_condition INT;
    v_id_capteur INT;
    v_id_type_capteur INT;
    v_id_saison INT;
    v_temperature NUMERIC(4, 2);
    v_energie_solaire NUMERIC(6, 2);
    v_vitesse_vent NUMERIC(4, 2);
    v_direction_vent NUMERIC(5, 2);
    v_precipitation NUMERIC(5, 2);
    v_humidite NUMERIC(5, 2);
    v_pression_atmo NUMERIC(6, 2);
    v_debit_eau NUMERIC(6, 2);
BEGIN
    FOR i IN 1..50000 LOOP  -- Générer 50 000 relevés
        -- Sélection aléatoire des ID des autres tables pour remplir les relevés
        SELECT d.id_date INTO v_id_date FROM releve.Date d ORDER BY random() LIMIT 1;
        SELECT t.id_temps INTO v_id_temps FROM releve.Temps t ORDER BY random() LIMIT 1;
        SELECT l.id_localisation INTO v_id_localisation FROM releve.Localisation l ORDER BY random() LIMIT 1;
        SELECT c.id_condition INTO v_id_condition FROM releve.ConditionEnvironnemental c ORDER BY random() LIMIT 1;
        SELECT cap.id_capteur INTO v_id_capteur FROM releve.Capteur cap ORDER BY random() LIMIT 1;
        SELECT tc.id_type INTO v_id_type_capteur FROM releve.TypeCapteur tc ORDER BY random() LIMIT 1;
        SELECT s.id_saison INTO v_id_saison FROM releve.Saison s ORDER BY random() LIMIT 1;

        -- Initialiser les variables à NULL pour la gestion des capteurs
        v_temperature := NULL;
        v_energie_solaire := NULL;
        v_vitesse_vent := NULL;
        v_direction_vent := NULL;
        v_precipitation := NULL;
        v_humidite := NULL;
        v_pression_atmo := NULL;
        v_debit_eau := NULL;

        -- Appliquer les contraintes selon le type de capteur
        CASE v_id_type_capteur
            WHEN 1 THEN  -- Type "Température"
                v_temperature := (random() * 40 - 10)::NUMERIC(4, 2);  -- Température entre -10 et 30
            WHEN 2 THEN  -- Type "Luminosité"
                v_energie_solaire := (random() * 1000)::NUMERIC(6, 2);  -- Énergie solaire
            WHEN 3 THEN  -- Type "Pression atmosphérique"
                v_pression_atmo := (900 + random() * 200)::NUMERIC(6, 2);  -- Pression atmosphérique entre 900 et 1100
            WHEN 4 THEN  -- Type "Humidité"
                v_humidite := (random() * 100)::NUMERIC(5, 2);  -- Humidité
            WHEN 5 THEN  -- Type "Vent"
                v_vitesse_vent := (random() * 50)::NUMERIC(4, 2);  -- Vitesse du vent
                v_direction_vent := (random() * 360)::NUMERIC(5, 2);  -- Direction du vent
            WHEN 6 THEN  -- Type "Débit eau"
                v_debit_eau := (random() * 999.99)::NUMERIC(6, 2);  -- Débit d'eau
            WHEN 7 THEN  -- Type "Précipitation"
                v_precipitation := (random() * 100)::NUMERIC(5, 2);  -- Précipitation
        END CASE;

        -- Insertion dans la table Releve avec les valeurs spécifiques en fonction du type de capteur
        INSERT INTO releve.Releve (
            id_temps, 
            id_localisation, 
            id_condition, 
            id_date, 
            id_capteur, 
            id_type_capteur, 
            id_saison, 
            energie_solaire, 
            temperature, 
            vitesse_vent, 
            direction_vent, 
            precipitation, 
            humidite, 
            pression_atmo, 
            debit_eau
        ) VALUES (
            v_id_temps,
            v_id_localisation,
            v_id_condition,
            v_id_date,
            v_id_capteur,
            v_id_type_capteur,
            v_id_saison,
            v_energie_solaire,
            v_temperature,
            v_vitesse_vent,
            v_direction_vent,
            v_precipitation,
            v_humidite,
            v_pression_atmo,
            v_debit_eau
        );
    END LOOP;
END $$;

COMMIT;


