START TRANSACTION;

-- 1) Lookup: Types
INSERT INTO tbl_types (name) VALUES
  ('Grass'),
  ('Fire'),
  ('Water'),
  ('Lightning'),
  ('Psychic'),
  ('Fighting'),
  ('Darkness'),
  ('Metal'),
  ('Fairy'),
  ('Dragon'),
  ('Colorless')
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- 2) Lookup: Stages
INSERT INTO tbl_stages (name) VALUES
  ('Basic'),
  ('Stage 1'),
  ('Stage 2'),
  ('EX'),
  ('GX'),
  ('V'),
  ('VMAX'),
  ('VSTAR'),
  ('Mega'),
  ('BREAK')
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- 3) Collections / Sets
-- Using well-known sets as examples
INSERT INTO tbl_collections (collectionSetName, releaseDate, totalCardsInCollection) VALUES
  ('Base Set',       '1999-01-09', 102),
  ('Jungle',         '1999-06-16', 64),
  ('Fossil',         '1999-10-10', 62),
  ('Sword & Shield', '2020-02-07', 202)
ON DUPLICATE KEY UPDATE
  releaseDate = VALUES(releaseDate),
  totalCardsInCollection = VALUES(totalCardsInCollection);

-- Bulbasaur (Base Set #44) - Grass, Basic
INSERT INTO tbl_cards
(hp, name, info, attack, damage, weak, ressis, retreat, cardNumberInCollection, collection_id, type_id, stage_id)
VALUES
(40, 'Bulbasaur', 'A strange seed was planted on its back at birth. The plant sprouts and grows with this Pokémon.',
 'Leech Seed', '20', 'Fire', 'None', '1',
 44,
 (SELECT id FROM tbl_collections WHERE collectionSetName = 'Base Set'),
 (SELECT id FROM tbl_types WHERE name = 'Grass'),
 (SELECT id FROM tbl_stages WHERE name = 'Basic'));

-- Ivysaur (Base Set #30) - Grass, Stage 1
INSERT INTO tbl_cards
(hp, name, info, attack, damage, weak, ressis, retreat, cardNumberInCollection, collection_id, type_id, stage_id)
VALUES
(60, 'Ivysaur', 'When the bulb on its back grows large, it appears to lose the ability to stand on its hind legs.',
 'Vine Whip', '30', 'Fire', 'None', '2',
 30,
 (SELECT id FROM tbl_collections WHERE collectionSetName = 'Base Set'),
 (SELECT id FROM tbl_types WHERE name = 'Grass'),
 (SELECT id FROM tbl_stages WHERE name = 'Stage 1'));

-- Venusaur (Base Set #15) - Grass, Stage 2
INSERT INTO tbl_cards
(hp, name, info, attack, damage, weak, ressis, retreat, cardNumberInCollection, collection_id, type_id, stage_id)
VALUES
(100, 'Venusaur', 'The plant blooms when it is absorbing solar energy. It stays on the move to seek sunlight.',
 'Solar Beam', '60', 'Fire', 'None', '2',
 15,
 (SELECT id FROM tbl_collections WHERE collectionSetName = 'Base Set'),
 (SELECT id FROM tbl_types WHERE name = 'Grass'),
 (SELECT id FROM tbl_stages WHERE name = 'Stage 2'));

-- Charmander (Base Set #46) - Fire, Basic
INSERT INTO tbl_cards
(hp, name, info, attack, damage, weak, ressis, retreat, cardNumberInCollection, collection_id, type_id, stage_id)
VALUES
(50, 'Charmander', 'Obviously prefers hot places. When it rains, steam is said to spout from the tip of its tail.',
 'Ember', '30', 'Water', 'None', '1',
 46,
 (SELECT id FROM tbl_collections WHERE collectionSetName = 'Base Set'),
 (SELECT id FROM tbl_types WHERE name = 'Fire'),
 (SELECT id FROM tbl_stages WHERE name = 'Basic'));

-- Squirtle (Base Set #63) - Water, Basic
INSERT INTO tbl_cards
(hp, name, info, attack, damage, weak, ressis, retreat, cardNumberInCollection, collection_id, type_id, stage_id)
VALUES
(40, 'Squirtle', 'After birth, its back swells and hardens into a shell. It powerfully sprays foam from its mouth.',
 'Bubble', '10', 'Lightning', 'None', '1',
 63,
 (SELECT id FROM tbl_collections WHERE collectionSetName = 'Base Set'),
 (SELECT id FROM tbl_types WHERE name = 'Water'),
 (SELECT id FROM tbl_stages WHERE name = 'Basic'));

-- Pikachu (Base Set #58) - Lightning, Basic
INSERT INTO tbl_cards
(hp, name, info, attack, damage, weak, ressis, retreat, cardNumberInCollection, collection_id, type_id, stage_id)
VALUES
(40, 'Pikachu', 'When several of these Pokémon gather, their electricity could build and cause lightning storms.',
 'Thunder Jolt', '30', 'Fighting', 'Metal', '1',
 58,
 (SELECT id FROM tbl_collections WHERE collectionSetName = 'Base Set'),
 (SELECT id FROM tbl_types WHERE name = 'Lightning'),
 (SELECT id FROM tbl_stages WHERE name = 'Basic'));

-- Machop (Base Set #52) - Fighting, Basic
INSERT INTO tbl_cards
(hp, name, info, attack, damage, weak, ressis, retreat, cardNumberInCollection, collection_id, type_id, stage_id)
VALUES
(50, 'Machop', 'Loves to build its muscles. It trains in all styles of martial arts to become even stronger.',
 'Low Kick', '20', 'Psychic', 'None', '1',
 52,
 (SELECT id FROM tbl_collections WHERE collectionSetName = 'Base Set'),
 (SELECT id FROM tbl_types WHERE name = 'Fighting'),
 (SELECT id FROM tbl_stages WHERE name = 'Basic'));

-- Snorlax (Jungle #11) - Colorless, Basic
INSERT INTO tbl_cards
(hp, name, info, attack, damage, weak, ressis, retreat, cardNumberInCollection, collection_id, type_id, stage_id)
VALUES
(90, 'Snorlax', 'Very lazy. Just eats and sleeps. As its rotund bulk builds, it becomes steadily more slothful.',
 'Body Slam', '30', 'Fighting', 'Psychic', '4',
 11,
 (SELECT id FROM tbl_collections WHERE collectionSetName = 'Jungle'),
 (SELECT id FROM tbl_types WHERE name = 'Colorless'),
 (SELECT id FROM tbl_stages WHERE name = 'Basic'));

-- Scyther (Jungle #10) - Grass, Basic (Resists Fighting in WotC era)
INSERT INTO tbl_cards
(hp, name, info, attack, damage, weak, ressis, retreat, cardNumberInCollection, collection_id, type_id, stage_id)
VALUES
(70, 'Scyther', 'With ninja-like agility and speed, it can create the illusion that there is more than one.',
 'Slash', '30', 'Fire', 'Fighting', '0',
 10,
 (SELECT id FROM tbl_collections WHERE collectionSetName = 'Jungle'),
 (SELECT id FROM tbl_types WHERE name = 'Grass'),
 (SELECT id FROM tbl_stages WHERE name = 'Basic'));

-- Gengar (Fossil #5) - Psychic, Stage 2
INSERT INTO tbl_cards
(hp, name, info, attack, damage, weak, ressis, retreat, cardNumberInCollection, collection_id, type_id, stage_id)
VALUES
(80, 'Gengar', 'Under a full moon, this Pokémon likes to mimic the shadows of people and laugh at their fright.',
 'Dark Mind', '30', 'Psychic', 'None', '1',
 5,
 (SELECT id FROM tbl_collections WHERE collectionSetName = 'Fossil'),
 (SELECT id FROM tbl_types WHERE name = 'Psychic'),
 (SELECT id FROM tbl_stages WHERE name = 'Stage 2'));

-- Dragonite (Fossil #4) - Colorless, Stage 2 (older era – Dragon often Colorless)
INSERT INTO tbl_cards
(hp, name, info, attack, damage, weak, ressis, retreat, cardNumberInCollection, collection_id, type_id, stage_id)
VALUES
(100, 'Dragonite', 'An extremely rarely seen marine Pokémon. Its intelligence is said to match that of humans.',
 'Slam', '40×', 'Colorless', 'Fighting', '2',
 4,
 (SELECT id FROM tbl_collections WHERE collectionSetName = 'Fossil'),
 (SELECT id FROM tbl_types WHERE name = 'Colorless'),
 (SELECT id FROM tbl_stages WHERE name = 'Stage 2'));

-- ==== Sword & Shield (2020) examples ====

-- Zacian V (SWSH #138) - Metal, V
INSERT INTO tbl_cards
(hp, name, info, attack, damage, weak, ressis, retreat, cardNumberInCollection, collection_id, type_id, stage_id)
VALUES
(220, 'Zacian V', 'It has a regal appearance and holds a splendid sword. It pierces opponents with swift movements.',
 'Brave Blade', '230', 'Fire', 'Grass', '2',
 138,
 (SELECT id FROM tbl_collections WHERE collectionSetName = 'Sword & Shield'),
 (SELECT id FROM tbl_types WHERE name = 'Metal'),
 (SELECT id FROM tbl_stages WHERE name = 'V'));

-- Snorlax VMAX (SWSH #142) - Colorless, VMAX
INSERT INTO tbl_cards
(hp, name, info, attack, damage, weak, ressis, retreat, cardNumberInCollection, collection_id, type_id, stage_id)
VALUES
(340, 'Snorlax VMAX', 'Gigantamax Snorlax’s body has become a mountain of trees and greenery.',
 'G-Max Fall', '60+', 'Fighting', 'None', '4',
 142,
 (SELECT id FROM tbl_collections WHERE collectionSetName = 'Sword & Shield'),
 (SELECT id FROM tbl_types WHERE name = 'Colorless'),
 (SELECT id FROM tbl_stages WHERE name = 'VMAX'));

-- Morpeko V (SWSH #79) - Lightning, V
INSERT INTO tbl_cards
(hp, name, info, attack, damage, weak, ressis, retreat, cardNumberInCollection, collection_id, type_id, stage_id)
VALUES
(170, 'Morpeko V', 'Hunger switches its form. When it gets hungry, it turns vicious and clutches at opponents.',
 'Electro Wheel', '150', 'Fighting', 'Metal', '2',
 79,
 (SELECT id FROM tbl_collections WHERE collectionSetName = 'Sword & Shield'),
 (SELECT id FROM tbl_types WHERE name = 'Lightning'),
 (SELECT id FROM tbl_stages WHERE name = 'V'));

-- Inteleon (SWSH #58) - Water, Stage 2
INSERT INTO tbl_cards
(hp, name, info, attack, damage, weak, ressis, retreat, cardNumberInCollection, collection_id, type_id, stage_id)
VALUES
(160, 'Inteleon', 'It has excellent sniping skills. It can hit a Berry in a tree from a hundred yards away.',
 'Aqua Bullet', '120', 'Lightning', 'None', '1',
 58,
 (SELECT id FROM tbl_collections WHERE collectionSetName = 'Sword & Shield'),
 (SELECT id FROM tbl_types WHERE name = 'Water'),
 (SELECT id FROM tbl_stages WHERE name = 'Stage 2'));

-- Rillaboom (SWSH #14) - Grass, Stage 2
INSERT INTO tbl_cards
(hp, name, info, attack, damage, weak, ressis, retreat, cardNumberInCollection, collection_id, type_id, stage_id)
VALUES
(170, 'Rillaboom', 'By drumming, it taps into the energy of its special tree stump. The roots sync with its drum.',
 'Wood Hammer', '140', 'Fire', 'None', '3',
 14,
 (SELECT id FROM tbl_collections WHERE collectionSetName = 'Sword & Shield'),
 (SELECT id FROM tbl_types WHERE name = 'Grass'),
 (SELECT id FROM tbl_stages WHERE name = 'Stage 2'));

-- Cinderace (SWSH #36) - Fire, Stage 2
INSERT INTO tbl_cards
(hp, name, info, attack, damage, weak, ressis, retreat, cardNumberInCollection, collection_id, type_id, stage_id)
VALUES
(170, 'Cinderace', 'It juggles a pebble with its feet, turning it into a burning soccer ball.',
 'Flare Strike', '190', 'Water', 'None', '2',
 36,
 (SELECT id FROM tbl_collections WHERE collectionSetName = 'Sword & Shield'),
 (SELECT id FROM tbl_types WHERE name = 'Fire'),
 (SELECT id FROM tbl_stages WHERE name = 'Stage 2'));

COMMIT;