-- Создать таблицы с иерархией из диаграммы в БД
-- Заполнить низкоуровневые таблицы именами(животных), командами которые они выполняют и датами рождения

DROP DATABASE IF EXISTS mans_best_friends;
CREATE DATABASE IF NOT EXISTS mans_best_friends;
USE mans_best_friends;

DROP TABLE IF EXISTS domestic_animals;
CREATE TABLE IF NOT EXISTS domestic_animals
(
	id INT PRIMARY KEY AUTO_INCREMENT,
    class VARCHAR(20)
);

INSERT INTO domestic_animals (class)
VALUES 
	('pets'),
    ('pack_animals');
SELECT * FROM domestic_animals;

DROP TABLE IF EXISTS pets;
CREATE TABLE IF NOT EXISTS pets
(
	id INT PRIMARY KEY AUTO_INCREMENT,
    class_id INT,
    pet_type_name VARCHAR(20),
    FOREIGN KEY (class_id) REFERENCES domestic_animals(id)
);

INSERT INTO pets (class_id, pet_type_name) 
VALUES 
	(1, 'Dogs'),
    (1, 'Cats'),
    (1, 'Hamsters');
SELECT * FROM pets;

DROP TABLE IF EXISTS dogs;
CREATE TABLE IF NOT EXISTS dogs
(
	id INT PRIMARY KEY AUTO_INCREMENT,
    subclass_id INT,
    dog_name VARCHAR(45),
    commands VARCHAR(100),
    birthday DATE,
    FOREIGN KEY (subclass_id) REFERENCES pets (id)
);

INSERT INTO dogs (subclass_id, dog_name, commands, birthday)
VALUES 
	(1, 'Teddy', 'sit, speak', '2015-03-21'),
    (1, 'Astro', 'shake, heel', '2021-12-21'),
    (1, 'Bella', 'lay down, HI 5, speak', '2019-07-04');
SELECT * FROM dogs;

DROP TABLE IF EXISTS cats;
CREATE TABLE IF NOT EXISTS cats
(
	id INT PRIMARY KEY AUTO_INCREMENT,
    subclass_id INT,
    cat_name VARCHAR(45),
    commands VARCHAR(100),
    birthday DATE,
    FOREIGN KEY (subclass_id) REFERENCES pets (id)
);

INSERT INTO cats (subclass_id, cat_name, commands, birthday)
VALUES 
	(2, 'Simba', 'stay, speak', '2022-09-13'),
    (2, 'Pepper', 'stay, come', '2011-10-22'),
    (2, 'Murzik', 'speak, sit', '2018-02-02');
SELECT * FROM cats;

DROP TABLE IF EXISTS hamsters;
CREATE TABLE IF NOT EXISTS hamsters
(
	id INT PRIMARY KEY AUTO_INCREMENT,
    subclass_id INT,
    hamster_name VARCHAR(45),
    commands VARCHAR(100),
    birthday DATE,
    FOREIGN KEY (subclass_id) REFERENCES pets (id)
);

INSERT INTO hamsters (subclass_id, hamster_name, commands, birthday)
VALUES 
	(3, 'Hammy', 'stand, roll over', '2022-12-31'),
    (3, 'Biscuit', 'stay, stand', '2023-11-01'),
    (3, 'Coco', 'climb', '2023-10-30');
SELECT * FROM hamsters;

DROP TABLE IF EXISTS pack_animals;
CREATE TABLE IF NOT EXISTS pack_animals
(
	id INT PRIMARY KEY AUTO_INCREMENT,
    class_id INT,
    pack_type_name VARCHAR(20),
    FOREIGN KEY (class_id) REFERENCES domestic_animals(id)
);

INSERT INTO pack_animals (class_id, pack_type_name) 
VALUES 
	(2, 'Horses'),
    (2, 'Camels'),
    (2, 'Donkeys');
SELECT * FROM pack_animals;

DROP TABLE IF EXISTS horses;
CREATE TABLE IF NOT EXISTS horses
(
	id INT PRIMARY KEY AUTO_INCREMENT,
    subclass_id INT,
    horse_name VARCHAR(45),
    commands VARCHAR(100),
    birthday DATE,
    FOREIGN KEY (subclass_id) REFERENCES pack_animals (id)
);

INSERT INTO horses (subclass_id, horse_name, commands, birthday)
VALUES 
	(1, 'Lady', 'walk, trot', '2000-01-11'),
    (1, 'Champ', 'easy, back', '2009-03-06'),
    (1, 'Luna', 'walk, trot, back', '2019-04-17');
SELECT * FROM horses;

DROP TABLE IF EXISTS camels;
CREATE TABLE IF NOT EXISTS camels
(
	id INT PRIMARY KEY AUTO_INCREMENT,
    subclass_id INT,
    camel_name VARCHAR(45),
    commands VARCHAR(100),
    birthday DATE,
    FOREIGN KEY (subclass_id) REFERENCES pack_animals (id)
);

INSERT INTO camels (subclass_id, camel_name, commands, birthday)
VALUES 
	(2, 'Oasis', 'walk, stand up, sit down', '1999-07-30'),
    (2, 'Sandy', 'stand up, sit down', '2023-12-11'),
    (2, 'Caramel', 'stop, walk', '2001-08-29');
SELECT * FROM camels;

DROP TABLE IF EXISTS donkeys;
CREATE TABLE IF NOT EXISTS donkeys
(
	id INT PRIMARY KEY AUTO_INCREMENT,
    subclass_id INT,
    donkey_name VARCHAR(45),
    commands VARCHAR(100),
    birthday DATE,
    FOREIGN KEY (subclass_id) REFERENCES pack_animals (id)
);

INSERT INTO donkeys (subclass_id, donkey_name, commands, birthday)
VALUES 
	(3, 'Pixie', 'come, back', '2023-11-30'),
    (3, 'Dookey', 'walk, stand', '1999-05-24'),
    (3, 'Dobby', 'stay, walk', '2016-06-22');
SELECT * FROM donkeys, horses;

/* 
Удалив из таблицы верблюдов, т.к. верблюдов решили перевезти в другой питомник на зимовку. 
Объединить таблицы лошади, и ослы в одну таблицу 
*/

DROP TABLE IF EXISTS camels;

SELECT horse_name AS name, commands, birthday, 'Horse' AS class FROM horses WHERE subclass_id = 1
UNION ALL
SELECT donkey_name AS name, commands, birthday, 'Donkey' AS class FROM donkeys WHERE subclass_id = 3;

/*
Создать новую таблицу “молодые животные” в которую попадут все животные старше 1 года, но младше 3 лет 
и в отдельном столбце с точностью до месяца подсчитать возраст животных в новой таблице
*/

DROP TABLE IF EXISTS young_animals;
CREATE TABLE IF NOT EXISTS young_animals AS
	SELECT name, commands, birthday, class, TIMESTAMPDIFF(MONTH, birthday, CURDATE()) AS months
    FROM (
		SELECT dog_name AS name, commands, birthday, 'Dog' AS class FROM dogs
        UNION SELECT cat_name AS name, commands, birthday, 'Cat' AS class FROM cats
        UNION SELECT hamster_name AS name, commands, birthday, 'Hamster' AS class FROM hamsters
        UNION SELECT horse_name AS name, commands, birthday, 'Horse' AS class FROM horses
        UNION SELECT donkey_name AS name, commands, birthday, 'Donkey' AS class FROM donkeys
		) AS all_animals
	WHERE birthday BETWEEN ADDDATE(CURDATE(), INTERVAL -3 YEAR) AND ADDDATE(CURDATE(), INTERVAL -1 YEAR);
    
SELECT * FROM young_animals;

/*
Объединить все таблицы в одну, при этом сохраняя поля, указывающие на прошлую принадлежность к старым таблицам.
*/

SELECT dog_name AS name, commands, birthday, 'Dog' AS class FROM dogs
UNION SELECT cat_name AS name, commands, birthday, 'Cat' AS class FROM cats
UNION SELECT hamster_name AS name, commands, birthday, 'Hamster' AS class FROM hamsters
UNION SELECT horse_name AS name, commands, birthday, 'Horse' AS class FROM horses
UNION SELECT donkey_name AS name, commands, birthday, 'Donkey' AS class FROM donkeys
