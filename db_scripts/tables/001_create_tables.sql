-- Lookup tables
CREATE TABLE tbl_types (
    id TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE tbl_stages (
    id TINYINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(15) NOT NULL UNIQUE
);

-- Collections
CREATE TABLE tbl_collections (
    id INT AUTO_INCREMENT PRIMARY KEY,
    collectionSetName VARCHAR(100) NOT NULL,
    releaseDate DATE,
    totalCardsInCollection INT
);

-- Cards (normalized: type, stage via FKs)
CREATE TABLE tbl_cards (
    id INT AUTO_INCREMENT PRIMARY KEY,
    hp INT,
    name VARCHAR(100) NOT NULL,
    info TEXT,
    attack VARCHAR(100),
    damage VARCHAR(10),
    weak VARCHAR(20),
    ressis VARCHAR(20),
    retreat VARCHAR(10),
    cardNumberInCollection INT,
    collection_id INT,
    type_id TINYINT UNSIGNED,
    stage_id TINYINT UNSIGNED,
    FOREIGN KEY (collection_id) REFERENCES tbl_collections(id),
    FOREIGN KEY (type_id) REFERENCES tbl_types(id),
    FOREIGN KEY (stage_id) REFERENCES tbl_stages(id)
);

-- Optional indexes
CREATE INDEX idx_cards_collection ON tbl_cards (collection_id);
CREATE INDEX idx_cards_type ON tbl_cards (type_id);
CREATE INDEX idx_cards_stage ON tbl_cards (stage_id);

-- Depois de criar as tabelas e seeds, siga:
-- 1. crie um banco de dados
-- 2. rode o primero script para a criação das tabelas (001_create_table.sql)
-- 3. rode os scripts para a criação do "sentido" (001_initial_seeds.sql)
