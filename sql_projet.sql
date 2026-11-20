-- =====================================================================
-- sql_projet.sql — Concession BMW (SAE BUT 1)
-- SGBD visé : MariaDB / MySQL
-- Noms : ATNI Hicham, BOURGOGNE Arthur, BAKALEC Benjamin  |  Groupe TP : A1  |  Groupe SAE : 3
-- =====================================================================


-- 1. SUPPRESSION DES TABLES (enfants d'abord, parents ensuite)

DROP TABLE IF EXISTS EQUIPER;
DROP TABLE IF EXISTS ESSAI;
DROP TABLE IF EXISTS VENTE;
DROP TABLE IF EXISTS VOITURE;
DROP TABLE IF EXISTS EMPLOYE;
DROP TABLE IF EXISTS `OPTION`;
DROP TABLE IF EXISTS MODELE;
DROP TABLE IF EXISTS COULEUR;
DROP TABLE IF EXISTS ETAT;
DROP TABLE IF EXISTS POSTE;
DROP TABLE IF EXISTS CLIENT;


-- 2. CRÉATION DES TABLES

CREATE TABLE CLIENT(
   id_client INT AUTO_INCREMENT,
   nom VARCHAR(50) NOT NULL,
   prenom VARCHAR(50) NOT NULL,
   email VARCHAR(100) NOT NULL,
   telephone VARCHAR(15) NOT NULL,
   adresse VARCHAR(150) NOT NULL,
   date_naissance DATE NOT NULL,
   parrain_id INT,
   PRIMARY KEY(id_client),
   FOREIGN KEY(parrain_id) REFERENCES CLIENT(id_client)
);

CREATE TABLE MODELE(
   id_modele INT AUTO_INCREMENT,
   nom_modele VARCHAR(50) NOT NULL,
   carrosserie VARCHAR(30) NOT NULL,
   energie VARCHAR(20) NOT NULL,
   puissance_ch SMALLINT NOT NULL,
   prix_base DECIMAL(10,2) NOT NULL,
   PRIMARY KEY(id_modele)
);

CREATE TABLE `OPTION`(
   id_option INT AUTO_INCREMENT,
   libelle_option VARCHAR(80),
   prix_catalogue DECIMAL(10,2) NOT NULL,
   PRIMARY KEY(id_option)
);

CREATE TABLE COULEUR(
   id_couleur INT AUTO_INCREMENT,
   libelle_couleur VARCHAR(50) NOT NULL,
   PRIMARY KEY(id_couleur),
   UNIQUE(libelle_couleur)
);

CREATE TABLE ETAT(
   id_etat INT AUTO_INCREMENT,
   libelle_etat VARCHAR(50) NOT NULL,
   PRIMARY KEY(id_etat),
   UNIQUE(libelle_etat)
);

CREATE TABLE POSTE(
   id_poste INT AUTO_INCREMENT,
   libelle_poste VARCHAR(50) NOT NULL,
   PRIMARY KEY(id_poste),
   UNIQUE(libelle_poste)
);

CREATE TABLE EMPLOYE(
   id_employe INT AUTO_INCREMENT,
   nom VARCHAR(50) NOT NULL,
   prenom VARCHAR(50) NOT NULL,
   poste_id INT NOT NULL,
   PRIMARY KEY(id_employe),
   FOREIGN KEY(poste_id) REFERENCES POSTE(id_poste)
);

CREATE TABLE VOITURE(
   id_voiture VARCHAR(17),
   kilometrage INT,
   date_mise_circulation DATE NOT NULL,
   prix_affiche DECIMAL(10,2) NOT NULL,
   couleur_id INT NOT NULL,
   etat_id INT NOT NULL,
   modele_id INT NOT NULL,
   PRIMARY KEY(id_voiture),
   FOREIGN KEY(couleur_id) REFERENCES COULEUR(id_couleur),
   FOREIGN KEY(etat_id) REFERENCES ETAT(id_etat),
   FOREIGN KEY(modele_id) REFERENCES MODELE(id_modele)
);

CREATE TABLE ESSAI(
   id_essai INT AUTO_INCREMENT,
   avis_client VARCHAR(255),
   date_essai DATETIME,
   duree_min INT,
   voiture_id VARCHAR(17) NOT NULL,
   employe_id INT NOT NULL,
   client_id INT NOT NULL,
   PRIMARY KEY(id_essai),
   FOREIGN KEY(voiture_id) REFERENCES VOITURE(id_voiture),
   FOREIGN KEY(employe_id) REFERENCES EMPLOYE(id_employe),
   FOREIGN KEY(client_id) REFERENCES CLIENT(id_client)
);

CREATE TABLE VENTE(
   id_vente INT AUTO_INCREMENT,
   date_vente DATE NOT NULL,
   prix_final DECIMAL(10,2) NOT NULL,
   remise_parrainage DECIMAL(10,2),
   mode_paiement VARCHAR(20),
   voiture_id VARCHAR(17) NOT NULL,
   employe_id INT NOT NULL,
   client_id INT NOT NULL,
   PRIMARY KEY(id_vente),
   CONSTRAINT uk_vente_voiture UNIQUE(voiture_id),
   FOREIGN KEY(voiture_id) REFERENCES VOITURE(id_voiture),
   FOREIGN KEY(employe_id) REFERENCES EMPLOYE(id_employe),
   FOREIGN KEY(client_id) REFERENCES CLIENT(id_client)
);

CREATE TABLE EQUIPER(
   voiture_id VARCHAR(17),
   option_id INT,
   prix_facture DECIMAL(10,2),
   PRIMARY KEY(voiture_id, option_id),
   FOREIGN KEY(voiture_id) REFERENCES VOITURE(id_voiture),
   FOREIGN KEY(option_id) REFERENCES `OPTION`(id_option)
);


-- 3. JEU DE TEST

INSERT INTO CLIENT (id_client, nom, prenom, email, telephone, adresse, date_naissance, parrain_id) VALUES
(1, 'Martin',   'Claire', 'claire.martin@mail.fr',  '0601020301', '12 rue de la Paix, Besançon',     '1985-03-14', NULL),
(2, 'Durand',   'Lucas',  'lucas.durand@mail.fr',   '0601020302', '5 avenue Carnot, Besançon',       '1990-07-22', 1),
(3, 'Bernard',  'Emma',   'emma.bernard@mail.fr',   '0601020303', '8 rue Battant, Besançon',         '1978-11-02', NULL),
(4, 'Petit',    'Hugo',   'hugo.petit@mail.fr',     '0601020304', '3 place Granvelle, Besançon',     '1995-01-30', NULL),
(5, 'Roux',     'Léa',    'lea.roux@mail.fr',       '0601020305', '21 rue des Granges, Besançon',    '1988-05-18', 4),
(6, 'Fournier', 'Théo',   'theo.fournier@mail.fr',  '0601020306', '14 chemin de Palente, Besançon',  '1992-09-09', 1),
(7, 'Girard',   'Inès',   'ines.girard@mail.fr',    '0601020307', '30 rue de Dole, Besançon',        '1982-12-25', NULL),
(8, 'Morel',    'Paul',   'paul.morel@mail.fr',     '0601020308', '2 rue Pasteur, Besançon',         '2000-04-04', NULL);

INSERT INTO POSTE (id_poste, libelle_poste) VALUES
(1, 'Vendeur'),
(2, 'Conseiller commercial'),
(3, 'Responsable essais');

INSERT INTO COULEUR (id_couleur, libelle_couleur) VALUES
(1, 'Noir'),
(2, 'Blanc'),
(3, 'Gris'),
(4, 'Bleu'),
(5, 'Rouge');

INSERT INTO ETAT (id_etat, libelle_etat) VALUES
(1, 'neuf'),
(2, 'occasion');

INSERT INTO EMPLOYE (id_employe, nom, prenom, poste_id) VALUES
(1, 'Lefevre',   'Sophie',  1),
(2, 'Garnier',   'Marc',    1),
(3, 'Chevalier', 'Julie',   2),
(4, 'Perrin',    'Antoine', 3);

INSERT INTO MODELE (id_modele, nom_modele, carrosserie, energie, puissance_ch, prix_base) VALUES
(1, 'Série 1', 'Compacte',  'Essence',     140, 34500.00),
(2, 'Série 3', 'Berline',   'Diesel',      190, 48900.00),
(3, 'X1',      'SUV',       'Hybride',     218, 46500.00),
(4, 'X5',      'SUV',       'Diesel',      286, 83000.00),
(5, 'i4',      'Berline',   'Électrique',  340, 62000.00);

INSERT INTO `OPTION` (id_option, libelle_option, prix_catalogue) VALUES
(1, 'Pack M Sport',                 1200.00),
(2, 'Toit panoramique',              450.00),
(3, 'Pack confort',                  900.00),
(4, 'Caméra de recul',               350.00),
(5, 'Jantes 19 pouces',              800.00),
(6, 'Système audio Harman Kardon',   750.00);

INSERT INTO VOITURE (id_voiture, kilometrage, date_mise_circulation, prix_affiche, couleur_id, etat_id, modele_id) VALUES
('WBA1A11000000001',     0, '2026-03-10', 35900.00, 1, 1, 1),
('WBA3B22000000002',     0, '2026-04-02', 49900.00, 2, 1, 2),
('WBA3B22000000003', 42000, '2022-06-15', 36900.00, 3, 2, 2),
('WBAX1X3000000004', 12000, '2025-01-20', 41900.00, 4, 2, 3),
('WBAX5X4000000005',     0, '2026-05-05', 85900.00, 1, 1, 4),
('WBAX5X4000000006', 68000, '2020-09-30', 52000.00, 2, 2, 4),
('WBAI4X5000000007',     0, '2026-06-12', 64900.00, 3, 1, 5),
('WBA1A11000000008', 25000, '2023-11-08', 24900.00, 5, 2, 1);

INSERT INTO EQUIPER (voiture_id, option_id, prix_facture) VALUES
('WBA1A11000000001', 5,  800.00),
('WBA3B22000000002', 1, 1200.00),
('WBA3B22000000002', 3,  900.00),
('WBAX1X3000000004', 2,  450.00),
('WBAX5X4000000005', 1, 1250.00),
('WBAX5X4000000005', 6,  750.00),
('WBAI4X5000000007', 3,  900.00),
('WBA1A11000000008', 4,  350.00);

INSERT INTO VENTE (id_vente, date_vente, prix_final, remise_parrainage, mode_paiement, voiture_id, employe_id, client_id) VALUES
(1, '2026-09-12', 51500.00, 500.00, 'virement', 'WBA3B22000000002', 1, 2),
(2, '2026-09-28', 42350.00,   0.00, 'crédit',   'WBAX1X3000000004', 2, 3),
(3, '2026-10-05', 51700.00, 300.00, 'chèque',   'WBAX5X4000000006', 1, 5),
(4, '2026-10-20', 25250.00,   0.00, 'carte',    'WBA1A11000000008', 3, 4);

INSERT INTO ESSAI (id_essai, avis_client, date_essai, duree_min, voiture_id, employe_id, client_id) VALUES
(1, 'Très confortable, bon freinage',  '2026-08-20 10:00:00', 30, 'WBA3B22000000002', 2, 2),
(2, 'Un peu cher mais superbe',        '2026-09-05 14:30:00', 45, 'WBAX1X3000000004', 1, 3),
(3, 'Moteur nerveux',                  '2026-09-20 11:00:00', 30, 'WBAX5X4000000006', 1, 5),
(4, 'Intérieur spacieux',              '2026-09-25 16:00:00', 20, 'WBA1A11000000008', 3, 4),
(5, 'Pas convaincu par la suspension', '2026-10-01 09:30:00', 30, 'WBA3B22000000003', 2, 6),
(6, 'Excellente autonomie',            '2026-10-10 15:00:00', 60, 'WBAI4X5000000007', 4, 7),
(7, 'Hésite encore, à revoir',         '2026-10-15 10:30:00', 40, 'WBAX5X4000000005', 4, 7),
(8, 'Maniable en ville',               '2026-11-02 17:00:00', 25, 'WBA1A11000000001', 3, 8);


-- 4. REQUÊTES (agrégation + jointures)

-- R1 : nombre de ventes et chiffre d'affaires par employé (LEFT JOIN : on garde aussi les employés sans vente)
SELECT EMPLOYE.nom, EMPLOYE.prenom,
       COUNT(VENTE.id_vente) AS nombre_ventes,
       SUM(VENTE.prix_final) AS chiffre_affaires
FROM EMPLOYE
LEFT JOIN VENTE ON VENTE.employe_id = EMPLOYE.id_employe
GROUP BY EMPLOYE.id_employe, EMPLOYE.nom, EMPLOYE.prenom;

-- R2 : nombre d'essais par modèle
SELECT MODELE.nom_modele,
       COUNT(ESSAI.id_essai) AS nombre_essais
FROM MODELE
JOIN VOITURE ON VOITURE.modele_id = MODELE.id_modele
JOIN ESSAI   ON ESSAI.voiture_id = VOITURE.id_voiture
GROUP BY MODELE.id_modele, MODELE.nom_modele;

-- R3 : total des options facturées par voiture
SELECT VOITURE.id_voiture,
       SUM(EQUIPER.prix_facture) AS total_options
FROM VOITURE
JOIN EQUIPER ON EQUIPER.voiture_id = VOITURE.id_voiture
GROUP BY VOITURE.id_voiture;

-- R4 : nombre d'essais par client (LEFT JOIN : on garde aussi les clients sans essai)
SELECT CLIENT.nom, CLIENT.prenom,
       COUNT(ESSAI.id_essai) AS nombre_essais
FROM CLIENT
LEFT JOIN ESSAI ON ESSAI.client_id = CLIENT.id_client
GROUP BY CLIENT.id_client, CLIENT.nom, CLIENT.prenom;

-- R5 : liste des ventes avec le client, le modèle vendu et l'employé (jointures, sans agrégat)
SELECT VENTE.id_vente, VENTE.date_vente, CLIENT.nom AS nom_client,
       MODELE.nom_modele, EMPLOYE.nom AS nom_employe, VENTE.prix_final
FROM VENTE
JOIN CLIENT  ON VENTE.client_id = CLIENT.id_client
JOIN VOITURE ON VENTE.voiture_id = VOITURE.id_voiture
JOIN MODELE  ON VOITURE.modele_id = MODELE.id_modele
JOIN EMPLOYE ON VENTE.employe_id = EMPLOYE.id_employe;

-- R6 : nombre de voitures par état (neuf / occasion)
SELECT ETAT.libelle_etat,
       COUNT(VOITURE.id_voiture) AS nombre_voitures
FROM ETAT
LEFT JOIN VOITURE ON VOITURE.etat_id = ETAT.id_etat
GROUP BY ETAT.id_etat, ETAT.libelle_etat;