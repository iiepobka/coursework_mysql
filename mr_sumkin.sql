/* 
Курсовой проект БД(база данных) интернет магазина Mr.Sumkin (https://www.sumki.ru/)
*/
/*
1. Составить общее текстовое описание БД и решаемых ею задач;
*/
/*
БД интернет магазина Mr.Sumkin (https://www.sumki.ru/) предназначена для:
- ведения каталога товаров интернет магазина с подробным их описанием и с сортировкой 
по категориям и подкатегориям товаров;
- ведения реестра покупателей магазина, хранения их учетных данных, сопровождения
их действий на платформе интернет магазинв;
- ведения реестра заказов интернет магазина;
- ведения учета действующих складов магазина и нахличия определённых товаров на складах.  
*/

/*
2. Минимальное количество таблиц - 10;
3. Скрипты создания структуры БД (с первичными ключами, индексами,
внешними ключами);
5. Скрипты наполнения БД данными;
*/
DROP DATABASE IF EXISTS mr_sumkin;
CREATE DATABASE mr_sumkin;
USE mr_sumkin;
/*
 * 
 */
DROP TABLE IF EXISTS categories_of_goods;
CREATE TABLE categories_of_goods 
(
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
	cat_name VARCHAR(50) COMMENT 'наименование категорий товаров',
	PRIMARY KEY (id)
) COMMENT = 'категории товаров';


INSERT INTO categories_of_goods (cat_name)
VALUES
	('Сумки'), ('Багаж'), 
	('Рюкзаки и поясные сумки'), ('Аксессуары');
/*
 * 
 */
DROP TABLE IF EXISTS subcategories_of_goods;
CREATE TABLE subcategories_of_goods 
(
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
	subcat_name VARCHAR(70) COMMENT 'наименование подкатегорий товаров',
	cat_name_id BIGINT UNSIGNED NOT NULL COMMENT 'id категории товара',
	FOREIGN KEY (cat_name_id) REFERENCES categories_of_goods(id),
	PRIMARY KEY (id)
) COMMENT = 'подкатегории товаров';


INSERT INTO subcategories_of_goods (subcat_name, cat_name_id)
VALUES
	('Барсетки и Визитки', 1), ('Деловые сумки', 1), 
	('Женские сумки из искусственной кожи и ткани', 1), 
	('Женские сумки из натуральной кожи', 1),
	('Кейсы', 1), ('Клатчи', 1), ('Мужские портфели', 1),
	('Папки для документов', 1), ('Планшеты', 1), 
	('Спортивные сумки', 1),
	('Чемоданы', 2), ('Дорожные сумки', 2), 
	('Дорожные сумки на колесах', 2), 
	('Кожаный багаж - Саквояжи', 2),
	('Портпледы', 2), ('Бьюти кейсы', 2),
	('Городские рюкзаки', 3), ('Детские и школьные рюкзаки', 3), 
	('Кожаные рюкзаки', 3), ('Поясные сумки и Сумки через плечо', 3),
	('Спортивные рюкзаки', 3),
	('Зонты', 4), ('Кошельки и Визитницы', 4), 
	('Обложки для документов', 4), ('Ремни', 4); 
/*
 * 
 */
DROP TABLE IF EXISTS goods;
CREATE TABLE goods 
(
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
	goods_name VARCHAR(70) COMMENT 'наименование товара',
	goods_number VARCHAR(15) COMMENT 'артикул товара',
	for_who ENUM('f', 'm', 'u', 'c', 'a') 
	COMMENT 'для кого товар: female, male, unisex, children, for all',
	price DECIMAL(8,2) COMMENT 'цена товара',
	color VARCHAR(15) COMMENT 'цвет товара',
	material VARCHAR(30) COMMENT 'материал, из которого изготовлен товар',
	manufacturer VARCHAR(30) COMMENT 'брэнд товара',
	country_manufacturer VARCHAR(50) COMMENT 'страна-изготовитель товара',
	`size` ENUM('l', 'm', 's') COMMENT 'размер: large, medium, small',
	`length` DECIMAL(5,1) COMMENT 'длина товара (см)',
	`width` DECIMAL(5,1) COMMENT 'ширина товара (см)',
	`height` DECIMAL(5,1) COMMENT 'высота товара (см)',
	shoulder_strap ENUM('yes', 'no') COMMENT 'наличие плечевого ремня',
	short_handle ENUM('yes', 'no') COMMENT 'наличие коротких ручек',
	A4_format ENUM('yes', 'no') COMMENT 'влезает ли формат Ф4',
	laptop_compartment ENUM('yes', 'no') COMMENT 'наличие отделения для ноутбука',
	additionally VARCHAR(250) COMMENT 'дополнительно о товаре',	
	subcat_name_id BIGINT UNSIGNED NOT NULL COMMENT 'id подкатегории товара',
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	FOREIGN KEY (subcat_name_id) REFERENCES subcategories_of_goods(id),
	PRIMARY KEY (id),
	INDEX index_goods_name (goods_name)
) COMMENT = 'товары';
/*
 * 
 */
DROP TABLE IF EXISTS is_new_goods;
CREATE TABLE is_new_goods (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  good_id BIGINT UNSIGNED COMMENT 'id из таблицы goods',
  finished_at DATETIME,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (good_id) REFERENCES goods (id),
  PRIMARY KEY (id)
) COMMENT = 'новые товары в магазине';

DROP TRIGGER IF EXISTS tr_insert_into_is_new_goods;
delimiter //
CREATE TRIGGER tr_insert_into_is_new_goods
AFTER INSERT ON goods
FOR EACH ROW
BEGIN 
	INSERT INTO is_new_goods (good_id, finished_at)
	VALUES (NEW.id, DATE_ADD(NEW.created_at, INTERVAL 30 DAY));	
END //
delimiter ;
/*
 * 
 */
INSERT INTO goods 
(
	goods_name, goods_number, for_who, price, color, material, manufacturer, 
	country_manufacturer, `size`, `length`, `width`, `height`, shoulder_strap, 
	short_handle, A4_format, laptop_compartment, additionally, subcat_name_id
)
VALUES
(
	'Барсетка Poshete', '361307 ',
	'a', 2990, 'Черный', 'Натуральная кожа', 'Poshete', 'КНР',
	's', 17, 21, 7, 'yes', 'yes', 'no', 'no', NULL, 1
),
(
	'Барсетка Wanlima', '6910121',  
	'a', 17390, 'Черный', 'Натуральная кожа', 'Wanlima', 'КНР',
	'm', 23.5, 30, 10.5, 'yes', 'yes', 'no', 'no', NULL, 1
),
(
	'Визитка Foluoyide', '1538217',  
	'a', 3180, 'Коричневый', 'Натуральная кожа', 'Foluoyide', 'КНР',
	's', 17, 21, 7, 'yes', 'no', 'no', 'no', NULL, 1
), -- sale 50%
(
	'Визитка Poshete', '3635166-1',  
	'a', 17390, 'Синий', 'Текстиль', 'Poshete', 'КНР',
	's', 18, 22, 7, 'yes', 'no', 'no', 'no', NULL, 1
),
(
	'Деловая сумка Francesco Molinary', '3616892-3',  
	'm', 9990, 'Черный', 'Натуральная кожа', 'Francesco Molinary', 'КНР',
	'm', 40, 30, 13, 'yes', 'yes', 'no', 'no', NULL, 2
),
(
	'Деловая сумка Poshete', '752357-902',
	'm', 10390, 'Коричневый', 'Натуральная кожа', 'Poshete', 'КНР',
	'm', 34, 25, 8, 'yes', 'yes', 'no', 'no', NULL, 2
),
(
	'Деловая сумка Poshete', '3616108-3-ик',  
	'f', 4350, 'Разноцветные', 'Искусственная кожа', 'Poshete', 'КНР',
	'm', 39, 29, 6, 'yes', 'yes', 'yes', 'yes', NULL, 2
),
(
	'Деловая сумка Poshete', '3613905',  
	'm', 9950, 'Черный', 'Натуральная кожа', 'Poshete', 'КНР',
	'm', 43, 35, 9, 'yes', 'yes', 'yes', 'yes', NULL, 2
),
(
	'Женская сумка Jonas Hanway', '2656759-ик',  
	'f', 3790, 'Черный', 'Искусственная кожа', 'Jonas Hanway', 'Россия',
	's', 23, 18, 8, 'no', 'yes', 'no', 'no', NULL, 3
),
(
	'Женская сумка Olivi', '2656759-ик',  
	'f', 3270, 'Разноцветные', 'Искусственная кожа', 'Olivi', 'Россия',
	'm', 35, 27, 10, 'no', 'yes', 'yes', 'no', 'Длина ручек 60 см', 3
),
(
	'Женская сумка Passo Avanti', '884865-808-ик',  
	'f', 4390, 'Коричневый', 'Искусственная кожа', 'Passo Avanti', 'КНР',
	'm', 28, 26, 13, 'no', 'yes', 'no', 'no', NULL, 3
),
(
	'Женская сумка Olivi', '584424-ик',  
	'f', 3520, 'Бордовый', 'Искусственная кожа', 'Olivi', 'Россия',
	'm', 33, 23, 12, 'no', 'yes', 'no', 'no', 'Длина ручек 60 см', 3
),
(
	'Женская сумка Protege', '52147/1', 
	'f', 8340, 'Разноцветные', 'Натуральная кожа', 'Protege', 'Россия',
	'm', 31, 20, 9, 'yes', 'yes', 'no', 'no', 'Длина ручек 30 см', 4
),
(
	'Женская сумка Afina', '4711041',
	'f', 9490, 'Разноцветные', 'Натуральная кожа', 'Afina', 'Россия',
	'm', 34.5, 25, 11, 'yes', 'yes', 'yes', 'no', 'Длина ручек 35 см', 4
),
(
	'Женская сумка Francesco Molinary', '011118208',  
	'f', 5490, 'Разноцветные', 'Натуральная кожа', 'Francesco Molinary', 
	'КНР', 's', 18, 16, 9, 'yes', 'no', 'no', 'no', NULL, 4
),
(
	'Женская сумка Francesco Molinary', '531912',  
	'f', 9790, 'Разноцветные', 'Натуральная кожа', 'Francesco Molinary', 
	'КНР', 'm', 35, 29, 11, 'no', 'yes', 'no', 'no', 'Длина ручек 60 см', 4
),
(
	'Кейс Francesco Molinary', '754513-3974-1',  
	'm', 19990, 'Черный', 'Натуральная кожа', 'Francesco Molinary', 
	'КНР', 'm', 40, 32, 14, 'yes', 'yes', 'yes', 'no', NULL, 5
),
(
	'Кейс Sandler', '051843',  
	'm', 3390, 'Черный', 'Полиэстер', 'Sandler', 'Россия', 'm', 
	40, 29, 14, 'yes', 'yes', 'yes', 'no', 'Расширение до 18 см', 5
),
(
	'Мужской клатч Sezfert', '79188003',  
	'm', 7290, 'Черный', 'Натуральная кожа', 'Sezfert', 'КНР', 's', 
	23, 11, 5, 'no', 'no', 'no', 'no', NULL, 6
),
(
	'Мужской клатч Galib', '791869-1263',  
	'm', 6290, 'Черный', 'Натуральная кожа', 'GalibSezfert', 'КНР', 
	's', 21, 11, 4, 'yes', 'no', 'no', 'no', NULL, 6
),
(
	'Мужской портфель Poshete', '3611605',  
	'm', 7470, 'Коричневый', 'Натуральная кожа', 'Poshete', 'КНР', 
	'm', 36, 31, 7, 'yes', 'yes', 'yes', 'yes', NULL, 7
),
(
	'Кожаный портфель Hexagona', '385461301', 
	'm', 9830, 'Черный', 'Натуральная кожа', 'Hexagona', 'КНР', 
	'm', 42, 30, 14, 'yes', 'yes', 'yes', 'yes', NULL, 7
), -- sale 50%
(
	'Кожаная папка Francesco Molinary', '751513-7305',  
	'm', 12790, 'Черный', 'Натуральная кожа', 'Francesco Molinary', 'КНР', 
	'm', 36, 27, 4, 'no', 'yes', 'yes', 'no', NULL, 8
),
(
	'Мужская кожаная сумка-планшет К8036', NULL, 
	'm', 9990, 'Капучино', NULL, NULL, NULL, 
	's', 25, 20, 12, 'yes', 'no', 'no', 'no', NULL, 9
),
(
	'Планшет Д1412', NULL,  
	'm', 3700, 'Капучино', NULL, NULL, NULL, 
	'm', 34, 46, 20, 'yes', 'yes', 'yes', 'yes', NULL, 9
),
(
	'Спортивная сумка Mr. Bag', '011061-4', 
	'f', 2450, 'Разноцветные', 'Полиэстер', 'Mr. Bag', 'Россия', 
	'm', 43, 24, 26, 'yes', 'yes', 'no', 'no', NULL, 10
),
(
	'Спортивная сумка Polar', '011061-4',  
	'u', 3990, 'Темно-синий', 'Полиэстер', 'Polar', 'Россия', 
	'm', 50, 25, 21, 'yes', 'yes', 'no', 'no', NULL, 10
),
(
	'Чемодан средний Francesco Molinary', '753332-159/2-24',  
	'a', 13320, 'Хаки', 'Поликарбонат', 'Francesco Molinary', 'КНР', 
	'l', 44, 67, 28, 'no', 'no', 'no', 'no', NULL, 11
),
(
	'Чемодан большой MR.BAG', '361638-28',
	'f', 8990, 'Песочный', 'Пластик', 'MR.BAG', 'КНР', 
	'l', 45, 66, 28, 'no', 'no', 'no', 'no', NULL, 11
),
(
	'Чемодан средний Mr.Bag', '336102-24',  
	'm', 7890, 'Разноцветные', NULL, 'MR.BAG', NULL, 
	'm', 39.5, 60, 25, 'no', 'no', 'no', 'no', NULL, 11
),
(
	'Дорожная сумка KARTEX', '7710016', 
	'f', 2490, 'Коричневый', 'Текстиль', 'KARTEX', 'Россия', 
	NULL, 49, 33, 24, 'no', 'no', 'no', 'no', NULL, 12
),
(
	'Дорожная сумка ECOTOPE', '361780',  
	'f', 2150, 'Серый', 'Текстиль', 'ECOTOPE', NULL, 
	NULL, 45, 26, 19, 'no', 'no', 'no', 'no', NULL, 12
),
(
	'Дорожная сумка ANTAN', '1212-177-ИК',  
	'f', 5440, 'Черный', 'Искусственная кожа', 'ANTAN', NULL, 
	NULL, 33, 23, 37, 'yes', 'yes', 'no', 'no', 'Объём 37 литров', 12
), -- sale 50%
(
	'Сумка тележка на колесах САКСИ', '121381', 
	'u', 4290, 'Черный', 'Текстиль', 'САКСИ', NULL, 
	'm', 36, 57, 29, 'no', 'no', 'no', 'no', NULL, 13
),
(
	'Сумка 7058.1', NULL,  
	'u', 4470, 'Бордовый', 'Текстиль', NULL, NULL, 
	NULL, NULL, NULL, NULL, 'no', 'no', 'no', 'no', 'Вес 2.4 кг', 13
),
(
	'Дорожная сумка POSHETE', '3611384',  
	'm', 9990, 'Коричневый', 'Натуральная кожа', 'POSHETE', NULL, 
	NULL, 47, 31, 11, 'yes', 'yes', 'no', 'no', NULL, 14
),
(
	'Дорожная сумка LACCENTO', '8010543',  
	'm', 9990, 'Коричневый', 'Натуральная кожа', 'LACCENTO', 'Россия', 
	'm', 47, 25, 24, 'yes', 'yes', 'no', 'no', NULL, 14
),
(
	'Саквояж Maxsimo Tarnavsky', '7111037',  
	'f', 11990, 'Черный', 'Натуральная кожа', 'Maxsimo Tarnavsky', 'Россия', 
	'm', 51, 33, 25, 'yes', 'yes', 'no', 'no', NULL, 14
),
(
	'Портплед POLAR CLUB', '1017056',  
	'f', 6790, 'Серый', 'Полиэстер', 'POLAR CLUB', 'КНР', 
	NULL, 55, 37, 16, 'yes', 'yes', 'no', 'no', NULL, 15
),
(
	'Портплед 014', NULL,  
	'm', 4220, 'Черный', NULL, NULL, NULL, 
	NULL, NULL, NULL, NULL, 'yes', 'yes', 'no', 'no', 'Вес 1.6 кг', 15
),
(
	'Портплед Francesco Molinary', '753513-11561-1',  
	'm', 18590, 'Серый', 'Натуральная кожа', 'Francesco Molinary', 'КНР', 
	NULL, 59, 48, 3, 'yes', 'yes', 'no', 'no', NULL, 15
),
(
	'Бьюти кейс POLAR CLUB', '1017057',  
	'f', 3390, 'Синий', 'Полиэстер', 'POLAR CLUB', 'КНР', 
	'm', 35, 28, 24, 'yes', 'yes', 'no', 'no', NULL, 16
),
(
	'Бьюти кейс POLAR', '1017028',  
	'f', 3390, 'Синий', 'Полиэстер', 'POLAR', 'КНР', 
	'm', 34, 26, 20, 'yes', 'yes', 'no', 'no', NULL, 16
),
(
	'Бьюти кейс Grott', '0161094-14',  
	'f', 2650, 'Серый', 'Текстиль', 'Grott', 'КНР', 
	'm', 35, 27, 18, 'yes', 'yes', 'no', 'no', NULL, 16
),
(
	'Рюкзак R.Cruzo', '161811-ик',  
	'f', 3190, 'Черный', 'Искусственная кожа', 'R.Cruzo', 'КНР', 
	'm', 25, 32, 12, 'no', 'no', 'no', 'no', NULL, 17
),
(
	'Мужской рюкзак Francesco Molinary', '3612190',  
	'm', 12990, 'Черный', 'Натуральная кожа', 'Francesco Molinary', 'КНР', 
	'm', 30, 41, 14, 'no', 'no', 'yes', 'yes', NULL, 17
), -- sale 50%
(
	'Рюкзак YESO', '74526001-1',  
	'c', 1990, 'Синий', 'Текстиль', 'YESO', 'КНР', 
	'm', 30, 42, 14, 'no', 'no', 'yes', 'yes', NULL, 17
),
(
	'Школьный рюкзак Mike & Mar', '12111724',  
	'c', 2250, 'Розовый', 'Полиэстер', 'Mike & Mar', 'КНР', 
	'm', 30, 40, 20, 'no', 'no', 'no', 'no', NULL, 18
),
(
	'Рюкзак Polar', '72511745-3',  
	'c', 3190, 'Розовый', NULL, 'Polar', 'Россия', 
	'm', 33, 46, 14, 'no', 'no', 'no', 'no', 'Вес 1 кг', 18
),
(
	'Женский рюкзак Francesco Molinary', '3618120-2',  
	'f', 6190, 'Разноцветные', 'Натуральная кожа', 'Francesco Molinary', 'КНР', 
	'm', 26, 32, 8, 'no', 'no', 'no', 'no', NULL, 19
),
(
	'Мужской рюкзак Poshete', '3612201',  
	'm', 3150, 'Коричневый', 'Натуральная кожа', 'Poshete', 'КНР', 
	's', 18, 26, 6, 'no', 'no', 'no', 'no', NULL, 19
),
(
	'Сумка через плечо Wenger', '38512201',  
	'u', 2950, 'Черный', 'Нейлон', 'Wenger', 'КНР', 
	's', 20, 27, 6, 'no', 'yes', 'no', 'no', NULL, 20
),
(
	'Поясная сумка Hexagona', '381151112',  
	'u', 8950, 'Серый', 'Натуральная кожа', 'Hexagona', 'КНР', 
	's', 23, 13, 5, 'no', 'no', 'no', 'no', NULL, 20
),
(
	'Рюкзак Ecotope', '36100103',  
	'u', 2790, 'Черный', 'Текстиль', 'Ecotope', 'КНР', 
	'm', 32, 46, 20, 'no', 'yes', 'yes', 'yes', NULL, 21
),
(
	'Рюкзак Wenger', '7216677',  
	'u', 8180, 'Серый', 'Полиэстер', 'Wenger', 'КНР', 
	'l', 39, 67, 26, 'no', 'yes', 'no', 'yes', NULL, 21
),
(
	'Мужской зонт Три Слона', '7560 ',  
	'm', 2590, 'Черный', NULL, 'Три Слона', 'КНР', 
	NULL, NULL, NULL, NULL, 'no', 'no', 'no', 'no', NULL, 22
),
(
	'Мужской зонт Три Слона', '7700 ',  
	'm', 2590, 'Черный', NULL, 'Три Слона', 'КНР', 
	NULL, NULL, NULL, NULL, 'no', 'no', 'no', 'no', NULL, 22
),
(
	'Женский зонт Три Слона ', '7101 ',  
	'f', 2790, 'Разноцветные', NULL, 'Три Слона', 'КНР', 
	NULL, NULL, NULL, NULL, 'no', 'no', 'no', 'no', NULL, 22
),
(
	'Женский кошелек Coscet', '301208-108-ик', 
	'f', 1970, 'Синий', 'Искусственная кожа', 'Coscet', 'КНР', 
	's', 10.5, 10, 2, 'no', 'no', 'no', 'no', NULL, 23
),
(
	'Мужской кошелек Marco Coverna', '6012080',
	'm', 2950, 'Черный', 'Натуральная кожа', 'Marco Coverna', NULL, 
	's', 11.5, 9.5, 2.5, 'no', 'no', 'no', 'no', NULL, 23
),
(
	'Обложка для автодокументов и паспорта', '301706',  
	'a', 1910, 'Черный', 'Натуральная кожа', NULL, 'Россия', 
	's', 10, 14, 1, 'no', 'no', 'no', 'no', NULL, 24
),
(
	'Обложка для документов Sezfert', '60174-303',  
	'm', 4290, 'Черный', 'Натуральная кожа', 'Sezfert', 'Россия', 
	's', 10, 13.5, 2, 'no', 'no', 'no', 'no', NULL, 24
),
(
	'Ремень A.Roberto', '67140/2245',  
	'm', 2110, 'Черный', 'Натуральная кожа', 'A.Roberto', 'Россия', 
	's', 102, 4, NULL, 'no', 'no', 'no', 'no', NULL, 25
),
(
	'Ремень Black Tortoise', '4617100013', 
	'm', 2550, 'Коричневый', 'Натуральная кожа', 'Black Tortoise', 'Россия', 
	's', 125, 4, NULL, 'no', 'no', 'no', 'no', NULL, 25
);
/*
 * 
 */
DROP TABLE IF EXISTS goods_photos;
CREATE TABLE goods_photos(
	id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,    
    good_id BIGINT UNSIGNED NOT NULL COMMENT 'id товара из таблицы goods',  
    filename VARCHAR(255) COMMENT 'наименование файла фото',
    `size` INT COMMENT 'размер в Кб файла фото',
	metadata JSON COMMENT 'метаданные фото',
    created_at DATETIME DEFAULT NOW(),
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	INDEX (good_id),
    FOREIGN KEY (good_id) REFERENCES goods(id),
    PRIMARY KEY (id)
) COMMENT = 'фото товаров';

INSERT INTO goods_photos (good_id, filename,`size`, metadata) 
VALUES 
(1, 'photo_1.psd', 325, NULL), (2, 'photo_2.jpeg', 272, NULL),
(3, 'photo_3.bmp', 433, NULL), (4, 'photo_4.jpeg', 198, NULL),
(5, 'photo_5.psd', 323, NULL), (6, 'photo_6.tiff', 371, NULL),
(7, 'photo_7.bmp', 432, NULL), (8, 'photo_8.psd', 314, NULL),
(9, 'photo_9.psd', 325, NULL), (10, 'photo_10.jpeg', 272, NULL),
(11, 'photo_11.bmp', 432, NULL), (12, 'photo_12.jpeg', 298, NULL),
(13, 'photo_13.psd', 228, NULL), (14, 'photo_14.tiff', 364, NULL),
(15, 'photo_15.bmp', 512, NULL), (16, 'photo_16.psd', 258, NULL),
(17, 'photo_17.psd', 316, NULL), (18, 'photo_18.tiff', 284, NULL),
(19, 'photo_19.bmp', 402, NULL), (20, 'photo_20.psd', 358, NULL),
(21, 'photo_21.bmp', 352, NULL), (22, 'photo_22.jpeg', 198, NULL),
(23, 'photo_23.psd', 198, NULL), (24, 'photo_24.tiff', 1267, NULL),
(25, 'photo_25.bmp', 110, NULL), (26, 'photo_26.psd', 478, NULL),
(27, 'photo_27.psd', 261, NULL), (28, 'photo_28.tiff',184, NULL),
(29, 'photo_29.bmp', 315, NULL), (30, 'photo_30.psd', 321, NULL),
(31, 'photo_31.bmp', 311, NULL), (32, 'photo_32.jpeg', 98, NULL),
(33, 'photo_33.psd', 118, NULL), (34, 'photo_34.tiff', 164, NULL),
(35, 'photo_35.bmp', 517, NULL), (36, 'photo_36.psd', 228, NULL),
(37, 'photo_37.psd', 376, NULL), (38, 'photo_38.tiff', 288, NULL),
(39, 'photo_39.bmp', 92, NULL), (40, 'photo_40.psd', 348, NULL),
(41, 'photo_41.bmp', 352, NULL), (42, 'photo_42.jpeg', 298, NULL),
(43, 'photo_43.psd', 1158, NULL), (44, 'photo_44.tiff', 164, NULL),
(45, 'photo_45.bmp', 420, NULL), (46, 'photo_46.psd', 459, NULL),
(47, 'photo_47.psd', 226, NULL), (48, 'photo_48.tiff', 334, NULL),
(49, 'photo_49.bmp', 322, NULL), (50, 'photo_50.psd', 325, NULL),
(51, 'photo_51.bmp', 432, NULL), (52, 'photo_52.jpeg', 278, NULL),
(53, 'photo_53.psd', 228, NULL), (54, 'photo_54.tiff', 324, NULL),
(55, 'photo_55.bmp', 512, NULL), (56, 'photo_56.psd', 256, NULL),
(57, 'photo_57.psd', 216, NULL), (58, 'photo_58.tiff', 384, NULL),
(59, 'photo_59.bmp', 302, NULL), (60, 'photo_60.psd', 348, NULL),
(61, 'photo_61.bmp', 362, NULL), (62, 'photo_62.jpeg', 196, NULL),
(63, 'photo_63.psd', 558, NULL), (64, 'photo_64.tiff', 204, NULL);
/*
 * 
 */
DROP TABLE IF EXISTS storehouses;
CREATE TABLE storehouses (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  storehouse_name VARCHAR(50) COMMENT 'наименование склада',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
) COMMENT = 'склады магазина';

INSERT INTO storehouses (storehouse_name) VALUES
	('Склад_1'), ('Склад_2'), ('Склад_3'),
	('Склад_4'), ('Склад_5'), ('Склад_6');
/*
 * 
 */
DROP TABLE IF EXISTS storehouses_location;
CREATE TABLE storehouses_location (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  region VARCHAR(100) COMMENT 'наименование региона',
  town VARCHAR(100) COMMENT 'наименование города',
  street VARCHAR(255) COMMENT 'наименование улицы',
  house INT(4) COMMENT 'номер дома',
  building VARCHAR(10) COMMENT 'номер корпуса и строения',
  storehouse_id BIGINT UNSIGNED NOT NULL COMMENT 'id склада',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,  
  FOREIGN KEY (storehouse_id) REFERENCES storehouses(id),
  PRIMARY KEY (id)
) COMMENT = 'адреса складов';

INSERT INTO storehouses_location 
(
	  region, town, street, house, building, storehouse_id  	
)
VALUES 
(
	'МО', 'Химки', '1-я Лесная', 4, '7а', 1
),
(
	'МО', 'Балашиха', 'Песочная', 1, '7а, стр. 5', 2
),
(
	'МО', 'Жуковский', 'Громова', 15, '8', 3
),
(
	'МО', 'Одинцово', 'Генерала Лизюкова', 2, '8 стр. 2', 4
),
(
	'МО', 'Реутов', 'Сосновая', 1, '2б', 5
),
(
	'МО', 'Красногорск', 'Большая Воскресенская', 5, '2с', 6
);
/*
 * 
 */
DROP TABLE IF EXISTS goods_on_storehouses;
CREATE TABLE goods_on_storehouses (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,  
  reserves INT UNSIGNED COMMENT 'запасы товара на складе',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  good_id BIGINT UNSIGNED NOT NULL COMMENT 'id склада',
  storehouse_id BIGINT UNSIGNED NOT NULL COMMENT 'id товара',
  FOREIGN KEY (storehouse_id) REFERENCES storehouses(id),
  FOREIGN KEY (good_id) REFERENCES goods(id),
  PRIMARY KEY (id)
) COMMENT = 'товары на складе';


INSERT INTO goods_on_storehouses (reserves, good_id, storehouse_id)
VALUES
(10, 1, 1), (5, 1, 2), (2, 1, 3), (1, 1, 4), (0, 1, 5), (0, 1, 6),
(0, 2, 1), (2, 2, 2), (2, 2, 3), (4, 2, 4), (5, 2, 5), (1, 2, 6),
(3, 3, 1), (5, 3, 2), (0, 3, 3), (2, 3, 4), (11, 3, 5), (1, 3, 6),
(1, 4, 1), (3, 4, 2), (12, 4, 3), (0, 4, 4), (2, 4, 5), (4, 4, 6),
(4, 5, 1), (0, 5, 2), (1, 5, 3), (5, 5, 4), (2, 5, 5), (4, 5, 6),
(0, 6, 1), (3, 6, 2), (1, 6, 3), (2, 6, 4), (0, 6, 5), (6, 6, 6),
(0, 7, 1), (0, 7, 2), (0, 7, 3), (0, 7, 4), (0, 7, 5), (0, 7, 6),
(6, 8, 1), (4, 8, 2), (5, 8, 3), (3, 8, 4), (4, 8, 5), (8, 8, 6),
(10, 9, 1), (5, 9, 2), (2, 9, 3), (1, 9, 4), (0, 9, 5), (0, 9, 6),
(0, 10, 1), (2, 10, 2), (2, 10, 3), (4, 10, 4), (5, 10, 5), (1, 10, 6),
(3, 11, 1), (5, 11, 2), (0, 11, 3), (2, 11, 4), (11, 11, 5), (1, 11, 6),
(1, 12, 1), (3, 12, 2), (2, 12, 3), (0, 12, 4), (2, 12, 5), (4, 12, 6),
(2, 13, 1), (0, 13, 2), (0, 13, 3), (0, 13, 4), (0, 13, 5), (0, 13, 6),
(0, 14, 1), (3, 14, 2), (1, 14, 3), (2, 14, 4), (0, 14, 5), (6, 14, 6),
(0, 15, 1), (2, 15, 2), (1, 15, 3), (0, 15, 4), (2, 15, 5), (0, 15, 6),
(6, 16, 1), (4, 16, 2), (5, 16, 3), (3, 16, 4), (4, 16, 5), (8, 16, 6),
(6, 17, 1), (3, 17, 2), (2, 17, 3), (3, 17, 4), (4, 17, 5), (8, 17, 6),
(1, 18, 1), (5, 18, 2), (2, 18, 3), (11, 18, 4), (2, 18, 5), (1, 18, 6),
(0, 19, 1), (2, 19, 2), (2, 19, 3), (4, 19, 4), (5, 19, 5), (1, 19, 6),
(3, 20, 1), (5, 20, 2), (0, 20, 3), (5, 20, 4), (1, 20, 5), (1, 20, 6),
(1, 21, 1), (3, 21, 2), (2, 21, 3), (0, 21, 4), (4, 21, 5), (1, 21, 6),
(0, 22, 1), (0, 22, 2), (2, 22, 3), (1, 22, 4), (3, 22, 5), (1, 22, 6),
(0, 23, 1), (3, 23, 2), (1, 23, 3), (2, 23, 4), (0, 23, 5), (6, 23, 6),
(1, 24, 1), (2, 24, 2), (1, 24, 3), (0, 24, 4), (2, 24, 5), (0, 24, 6),
(6, 25, 1), (4, 25, 2), (5, 25, 3), (3, 25, 4), (4, 25, 5), (8, 25, 6),
(6, 26, 1), (3, 26, 2), (2, 26, 3), (3, 26, 4), (4, 26, 5), (8, 26, 6),
(1, 27, 1), (5, 27, 2), (2, 27, 3), (11, 27, 4), (2, 27, 5), (1, 27, 6),
(0, 28, 1), (2, 28, 2), (2, 28, 3), (4, 28, 4), (5, 28, 5), (1, 28, 6),
(3, 29, 1), (5, 29, 2), (0, 29, 3), (5, 29, 4), (1, 29, 5), (1, 29, 6),
(1, 30, 1), (3, 30, 2), (2, 30, 3), (0, 30, 4), (4, 30, 5), (1, 30, 6),
(0, 31, 1), (0, 31, 2), (2, 31, 3), (1, 31, 4), (3, 31, 5), (1, 31, 6),
(0, 32, 1), (3, 32, 2), (1, 32, 3), (2, 32, 4), (0, 32, 5), (6, 32, 6),
(2, 33, 1), (0, 33, 2), (2, 33, 3), (1, 33, 4), (3, 33, 5), (1, 33, 6),
(0, 34, 1), (2, 34, 2), (1, 34, 3), (0, 34, 4), (2, 34, 5), (0, 34, 6),
(6, 35, 1), (4, 35, 2), (5, 35, 3), (3, 35, 4), (4, 35, 5), (8, 35, 6),
(3, 36, 1), (5, 36, 2), (0, 36, 3), (5, 36, 4), (1, 36, 5), (1, 36, 6),
(1, 37, 1), (3, 37, 2), (2, 37, 3), (0, 37, 4), (4, 37, 5), (1, 37, 6),
(0, 38, 1), (0, 38, 2), (2, 38, 3), (1, 38, 4), (3, 38, 5), (1, 38, 6),
(0, 39, 1), (3, 39, 2), (1, 39, 3), (2, 39, 4), (0, 39, 5), (6, 39, 6),
(1, 40, 1), (3, 40, 2), (2, 40, 3), (0, 40, 4), (4, 40, 5), (1, 40, 6),
(0, 41, 1), (0, 41, 2), (2, 41, 3), (1, 41, 4), (3, 41, 5), (1, 41, 6),
(1, 42, 1), (3, 42, 2), (1, 42, 3), (2, 42, 4), (0, 42, 5), (6, 42, 6),
(0, 43, 1), (2, 43, 2), (1, 43, 3), (0, 43, 4), (2, 43, 5), (0, 43, 6),
(1, 44, 1), (2, 44, 2), (1, 44, 3), (2, 44, 4), (1, 44, 5), (5, 44, 6),
(5, 45, 1), (4, 45, 2), (5, 45, 3), (6, 45, 4), (4, 45, 5), (2, 45, 6),
(3, 46, 1), (5, 46, 2), (0, 46, 3), (5, 46, 4), (3, 46, 5), (0, 46, 6),
(1, 47, 1), (3, 47, 2), (2, 47, 3), (1, 47, 4), (0, 47, 5), (1, 47, 6),
(0, 48, 1), (0, 48, 2), (2, 48, 3), (1, 48, 4), (3, 48, 5), (1, 48, 6),
(0, 49, 1), (2, 49, 2), (4, 49, 3), (2, 49, 4), (0, 49, 5), (6, 49, 6),
(1, 50, 1), (3, 50, 2), (2, 50, 3), (0, 50, 4), (4, 50, 5), (1, 50, 6),
(0, 51, 1), (0, 51, 2), (2, 51, 3), (1, 51, 4), (2, 51, 5), (1, 51, 6),
(1, 52, 1), (3, 52, 2), (1, 52, 3), (2, 52, 4), (0, 52, 5), (6, 52, 6),
(0, 53, 1), (0, 53, 2), (2, 53, 3), (1, 53, 4), (3, 53, 5), (1, 53, 6),
(3, 54, 1), (2, 54, 2), (1, 54, 3), (0, 54, 4), (2, 54, 5), (0, 54, 6),
(6, 55, 1), (4, 55, 2), (5, 55, 3), (3, 55, 4), (4, 55, 5), (8, 55, 6),
(3, 56, 1), (2, 56, 2), (0, 56, 3), (1, 56, 4), (1, 56, 5), (1, 56, 6),
(1, 57, 1), (3, 57, 2), (0, 57, 3), (0, 57, 4), (4, 57, 5), (1, 57, 6),
(0, 58, 1), (0, 58, 2), (2, 58, 3), (1, 58, 4), (3, 58, 5), (1, 58, 6),
(1, 59, 1), (3, 59, 2), (1, 59, 3), (2, 59, 4), (0, 59, 5), (6, 59, 6),
(1, 60, 1), (3, 60, 2), (2, 60, 3), (0, 60, 4), (3, 60, 5), (1, 60, 6),
(2, 61, 1), (0, 61, 2), (2, 61, 3), (1, 61, 4), (3, 61, 5), (1, 61, 6),
(0, 62, 1), (3, 62, 2), (1, 62, 3), (2, 62, 4), (0, 62, 5), (6, 62, 6),
(3, 63, 1), (2, 63, 2), (1, 63, 3), (0, 63, 4), (2, 63, 5), (0, 63, 6),
(0, 64, 1), (2, 64, 2), (2, 64, 3), (2, 64, 4), (1, 64, 5), (10, 64, 6);
/*
 * 
 */
DROP TABLE IF EXISTS buyers;
CREATE TABLE buyers (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  first_name VARCHAR(255) COMMENT 'имя покупателя',
  last_name VARCHAR(255) COMMENT 'фамилия покупателя',
  login_name VARCHAR(255) UNIQUE COMMENT 'логин покупателя',
  region VARCHAR(100) COMMENT 'наименование региона',
  town VARCHAR(100) COMMENT 'наименование города',
  birthday DATE COMMENT 'дата рождения покупателя',
  gender ENUM('f', 'm') COMMENT 'пол покупателя: female, male', 
  `password` VARCHAR(20) COMMENT 'пароль покупателя при регистрации',
  phone BIGINT UNIQUE COMMENT 'телефон покупателя',
  email VARCHAR(50) UNIQUE COMMENT 'email покупателя',  
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  INDEX index_login_name (login_name),
  INDEX index_bueyers_name (first_name, last_name)
) COMMENT = 'покупатели';

INSERT INTO buyers 
(
  first_name, last_name, login_name, region, town,
  birthday, gender, `password`, phone, email
)
VALUES
(
	'Иван', 'Куклов', 'ivku_login', 'Москва', 'Москва', 
	'1989-02-02', 'm', 'qwer1234', 79851099554,'ivku@mail.ru'
),
(
	'Иван', 'Куклов', 'ivakur_login', 'Москва', 'Москва', 
	'1989-02-02', 'm', 'qwer1234', 79772569554,'ivakur@mail.ru'
),
(
	'Иван', 'Пирогов', 'ivpir_login', 'МО', 'Химки', 
	'1986-03-02', 'm', 'QweR1234', 79265095554,'ivpir@gmail.com'
),
(
	'Кристина', 'Пирогова', 'krpir_login', 'МО', 'Химки', 
	'1996-12-12', 'f', 'asdf1234', 79165075564,'krpir@gmail.com'
),
(
	'Елена', 'Ргова', 'helrog_login', 'МО', 'Красногорск', 
	'1986-10-22', 'f', 'asdf4321', 79111075394,'helrog@mail.ru'
),
(
	'Елена', 'Дуова', 'heldur_login', 'МО', 'Красногорск', 
	'1977-01-02', 'f', 'qwert54321', 79161095384,'heldur@gmail.com'
),
(
	'Кирилл', 'Скоков', 'kirsk_login', 'Москва', 'Зеленоград', 
	'1987-11-24', 'm', 'asdf54321', 79771594374,'kirsk@gmail.com'
),
(
	'Кирилл', 'Портнов', 'kirpor_login', 'Москва', 'Москва', 
	'1967-10-14', 'm', 'zxcvb54321', 79772594378,'kirpor@rambler.ru'
),
(
	'Анна', 'Портновская', 'annpor_login', 'Москва', 'Москва', 
	'1969-05-18', 'f', 'zxcvb1234', 79772515368,'annpor@rambler.ru'
),
(
	'Виктор', 'Скоков', 'viksk_login', 'Москва', 'Москва', 
	'1977-05-13', 'm', 'qazwsx4321', 79121594374,'viksk@gmail.com'
),
(
	'Семен', 'Портнов', 'sempor_login', 'Москва', 'Москва', 
	'1987-10-04', 'm', 'fgcvb54321', 79162574278,'sempor@rambler.ru'
),
(
	'Анна', 'Курова', 'annkur_login', 'Москва', 'Москва', 
	'1999-03-18', 'f', '1234567890', 79762515368,'annkur@rambler.ru'
),
(
	'Иван', 'Хохлов', 'ivah_login', 'Москва', 'Москва', 
	'1989-02-02', 'm', 'qwer1234', 79152549311,'ivah@mail.ru'
),
(
	'Дмитрий', 'Лигов', 'dimlig_login', 'МО', 'Люберцы', 
	'1986-11-12', 'm', 'qwerasdf', 79255145554,'dimlig@gmail.com'
),
(
	'Роза', 'Минина', 'romin_login', 'МО', 'Жуковский', 
	'1992-02-15', 'f', 'zxcvasdf', 79165276524,'romin@yandex.ru'
),
(
	'Елена', 'Фиговская', 'helfig_login', 'МО', 'Раменское', 
	'1989-10-28', 'f', 'qazwsxedcrfv', 79121575344,'helfig@mail.ru'
),
(
	'Игорь', 'Кузовов', 'igkuz_login', 'Москва', 'Москва', 
	'1979-12-05', 'm', '1202555554', 79771115534,'igkuz@mail.ru'
),
(
	'Гоша', 'Портов', 'gport_login', 'МО', 'Воскресенск', 
	'1988-06-18', 'm', 'QweRT135', 79155191514,'gport@gmail.com'
),
(
	'Ника', 'Абрамова', 'nabram_login', 'МО', 'Одинцово', 
	'1991-09-19', 'f', 'q1w2e3r4t5', 84951075564,'nabram@gmail.com'
),
(
	'Яна', 'Суслова', 'jasuslik_login', 'МО', 'Красногорск', 
	'1989-07-12', 'f', 'q.q.q.1Q', 79165274364,'jasuslik@mail.ru'
),
(
	'Кира', 'Пупкова', 'pupok_login', 'МО', 'Железнодорожный', 
	'1997-03-30', 'f', '1234.qwer', 79162095254,'pupok@yandex.ru'
),
(
	'Федор', 'Логов', 'fedlog_login', 'МО', 'Люберцы', 
	'1976-12-12', 'm', 'qwerasdf', 79155145554,'fedlog@gmail.com'
),
(
	'Инна', 'Минская', 'irmin_login', 'МО', 'Реутов', 
	'1994-06-25', 'f', 'zxcvasdf', 79265273514,'irmin@yandex.ru'
),
(
	'Алла', 'Фирская', 'allafi_login', 'МО', 'Раменское', 
	'1999-10-21', 'f', 'qazwsxedcrfv', 79112571364,'allafi@mail.ru'
),
(
	'Андрей', 'Кузов', 'andkuz_login', 'Москва', 'Москва', 
	'1989-05-25', 'm', '555555', 79701215534,'andkuz@mail.ru'
),
(
	'Антон', 'Партов', 'apart_login', 'МО', 'Серпухов', 
	'1988-06-08', 'm', 'QRT1357', 84955001514,'apart@gmail.com'
),
(
	'Сима', 'Рабинович', 'rabinovichsima_login', 'МО', 'Солнечногорск', 
	'1949-08-29', 'f', 'simar', 84951085464,'rabinovichsima@gmail.com'
),
(
	'Ирина', 'Терехова', 'irat_login', 'МО', 'Жуковский', 
	'1989-05-22', 'f', 'q1q1q!Q', 79264574244,'irat@mail.ru'
),
(
	'Татьяна', 'Лимбургская', 'limbo_login', 'МО', 'Шатура', 
	'1995-06-01', 'f', 'limbo!', 79122192294,'limbo@yandex.ru'
),
(
	'Марта', 'Бугланова', 'bugim_login', 'МО', 'Можайск', 
	'1993-09-09', 'f', 'bugim1234', 79252184291,'bugim@yandex.ru'
);
/*
 * 
 */
DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
  id_number_of_order BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  buyer_id BIGINT UNSIGNED NOT NULL COMMENT 'id из таблицы buyers',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (buyer_id) REFERENCES buyers(id),
  PRIMARY KEY (id_number_of_order)
) COMMENT = 'заказы покупателей';

INSERT INTO orders (buyer_id) VALUES
(10), (2), (3), (4), (5), (6), (7), (8), (9), (10),
(20), (12), (13), (14), (15), (16), (17), (18), (19), (20),
(30), (22), (23), (24), (25), (26), (27), (28), (29), (30),
(10), (12), (13), (24), (25), (16), (17), (18), (29), (20),
(20), (12), (30), (14), (15), (26), (27), (8), (9), (10),
(30), (22), (23), (24), (25), (26), (27), (28), (29), (30);
/*
 * 
 */
DROP TABLE IF EXISTS orders_goods;
CREATE TABLE orders_goods (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_id BIGINT UNSIGNED NOT NULL COMMENT 'id из таблицы orders',
  good_id BIGINT UNSIGNED NOT NULL COMMENT 'id из таблицы goods',
  amount_of_good INT UNSIGNED DEFAULT 1 COMMENT 'кол-во заказанных товара в шт.',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (order_id) REFERENCES orders(id_number_of_order),
  FOREIGN KEY (good_id) REFERENCES goods(id),
  PRIMARY KEY (id)
) COMMENT = 'заказы товаров покупателями';

INSERT INTO orders_goods (order_id, good_id, amount_of_good) VALUES
(1, 1, 2), (1, 2, 1), (2, 3, 2), (2, 4, 1), (2, 64, 1),
(3, 63, 1), (3, 5, 1), (4, 6, 1), (5, 62, 1), (5, 7, 1),
(6, 7, 2), (6, 8, 1), (7, 9, 1), (8, 61, 2), (9, 54, 1),
(10, 63, 1), (10, 45, 1), (10, 12, 1), (10, 60, 1), (10, 28, 2),
(11, 34, 1), (11, 28, 2), (11, 15, 1), (12, 52, 1), (12, 17, 1),
(13, 43, 1), (13, 27, 1), (14, 59, 3), (15, 1, 1), (15, 2, 1),
(15, 3, 1), (15, 4, 1),(15, 5, 1), (15, 6, 1),(15, 7, 1), 
(15, 8, 1), (15, 9, 1), (15, 10, 1), (15, 11, 1), (15, 12, 1),
(16, 15, 1), (16, 19, 1), (16, 20, 5), (16, 21, 1), (16, 22, 1),
(17, 32, 1), (18, 33, 3), (19, 31, 2), (20, 34, 5), (21, 37, 1),
(22, 42, 1), (22, 40, 2), (23, 50, 1), (24, 53, 2), (24, 49, 1),
(25, 38, 2), (25, 57, 1), (25, 64, 1), (26, 48, 1), (27, 53, 2),
(28, 33, 1), (28, 27, 1), (29, 55, 1), (29, 52, 2), (30, 37, 1);
/*
 * 
 */
DROP TABLE IF EXISTS delivery_date;
CREATE TABLE delivery_date (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  order_good_id BIGINT UNSIGNED NOT NULL COMMENT 'id из таблицы orders_goods',
  delivery_at DATE COMMENT 'согласованная дата доставки товара из заказа',
  confirm_delivery_at DATE COMMENT 'реальная дата доставки товара из заказа покупателю',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (order_good_id) REFERENCES orders_goods(id),
  PRIMARY KEY (id)
) COMMENT = 'даты доставки заказаных товаров';

INSERT INTO delivery_date (order_good_id, delivery_at, confirm_delivery_at) VALUES
(1, '2020-08-10', NULL), (2, '2020-08-10', NULL), 
(3, '2020-08-10', NULL), (4, '2020-08-10', NULL),
(5, '2020-08-10', NULL), (6, '2020-08-10', NULL),
(7, '2020-08-10', NULL), (8, '2020-08-10', NULL),
(9, '2020-08-10', NULL), (10, '2020-08-10', NULL),
(11, '2020-08-11', NULL), (12, '2020-08-11', NULL),
(13, '2020-08-11', NULL), (14, '2020-08-11', NULL),
(15, '2020-08-11', NULL), (16, '2020-08-11', NULL),
(17, '2020-08-11', NULL), (18, '2020-08-11', NULL),
(19, '2020-08-11', NULL), (20, '2020-08-11', NULL),
(21, '2020-08-12', NULL), (22, '2020-08-12', NULL),
(23, '2020-08-12', NULL), (24, '2020-08-12', NULL),
(25, '2020-08-12', NULL), (26, '2020-08-12', NULL),
(27, '2020-08-12', NULL), (28, '2020-08-12', NULL),
(29, '2020-08-12', NULL), (30, '2020-08-12', NULL),
(31, '2020-08-13', NULL), (32, '2020-08-13', NULL),
(33, '2020-08-13', NULL), (34, '2020-08-13', NULL),
(35, '2020-08-13', NULL), (36, '2020-08-13', NULL),
(37, '2020-08-13', NULL), (38, '2020-08-13', NULL),
(39, '2020-08-13', NULL), (40, '2020-08-13', NULL),
(41, '2020-08-14', NULL), (42, '2020-08-14', NULL),
(43, '2020-08-14', NULL), (44, '2020-08-14', NULL),
(45, '2020-08-14', NULL), (46, '2020-08-14', NULL),
(47, '2020-08-14', NULL), (48, '2020-08-14', NULL),
(49, '2020-08-14', NULL), (50, '2020-08-14', NULL),
(51, '2020-08-15', NULL), (52, '2020-08-15', NULL),
(53, '2020-08-15', NULL), (54, '2020-08-15', NULL),
(55, '2020-08-15', NULL), (56, '2020-08-15', NULL),
(57, '2020-08-15', NULL), (58, '2020-08-15', NULL),
(59, '2020-08-15', NULL), (60, '2020-08-15', NULL),
(61, '2020-08-16', NULL), (62, '2020-08-16', NULL),
(63, '2020-08-16', NULL), (64, '2020-08-16', NULL),
(65, '2020-08-16', NULL);
/*
 * 
 */
DROP TABLE IF EXISTS deferred_orders;
CREATE TABLE deferred_orders (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  buyer_id BIGINT UNSIGNED NOT NULL COMMENT 'id из таблицы buyers',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (buyer_id) REFERENCES buyers(id),
  PRIMARY KEY (id)
) COMMENT = 'отложенные заказы покупателей';

INSERT INTO deferred_orders (buyer_id) VALUES
(5), (10), (15), (20), (25), (30),
(7), (9), (17), (22), (27), (28);
/*
 * 
 */
DROP TABLE IF EXISTS deferred_orders_goods;
CREATE TABLE deferred_orders_goods (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  deferred_order_id BIGINT UNSIGNED NOT NULL COMMENT 'id из таблицы orders',
  good_id BIGINT UNSIGNED NOT NULL COMMENT 'id из таблицы goods',
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (deferred_order_id) REFERENCES deferred_orders(id),
  FOREIGN KEY (good_id) REFERENCES goods(id),
  PRIMARY KEY (id)
) COMMENT = 'заказы товаров покупателями';

INSERT INTO deferred_orders_goods (deferred_order_id, good_id) VALUES
(1, 1), (1, 2), (2, 3), (2, 4), (2, 64),
(3, 63), (3, 5), (4, 6), (5, 62), (5, 7),
(6, 7), (6, 8), (7, 9), (8, 61), (9, 54),
(10, 63), (10, 45), (10, 12), (10, 60), (10, 28),
(11, 34), (11, 28), (11, 15), (12, 52), (12, 17);
/*
 * 
 */
DROP TABLE IF EXISTS discounts;
CREATE TABLE discounts (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  buyer_id BIGINT UNSIGNED COMMENT 'id из таблицы buyers',
  good_id BIGINT UNSIGNED COMMENT 'id из таблицы goods',
  discount DECIMAL(2, 2) UNSIGNED COMMENT 'величина скидки от 0.0 до 1.0',
  started_at DATETIME,
  finished_at DATETIME,
  created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (buyer_id) REFERENCES buyers (id),
  FOREIGN KEY (good_id) REFERENCES goods (id),
  PRIMARY KEY (id)
) COMMENT = 'скидки';

INSERT INTO discounts (buyer_id, good_id, discount, started_at, finished_at)
VALUES
(NULL, 3, 0.5, '2020-07-30', '2020-08-30'),
(NULL, 22, 0.3, '2020-07-30', '2020-08-30'),
(NULL, 33, 0.4, '2020-07-30', '2020-08-30'),
(NULL, 46, 0.1, '2020-07-30', '2020-08-30'),
(12, NULL, 0.2, '2020-07-30', '2020-08-30'),
(25, NULL, 0.2, '2020-07-30', '2020-08-30');
/*
6. Cкрипты характерных выборок (включающие группировки, JOIN-ны, вложенные
таблицы);
*/
SELECT 
	COUNT(*) AS `count of orders`,
	orders_goods.good_id,
	goods.goods_name 
FROM 
	orders_goods
	JOIN
	goods
ON
	orders_goods.good_id = goods.id
GROUP BY 
	orders_goods.good_id
ORDER BY `count of orders` DESC;
/*
 * 
 */
SELECT 
	`g`.goods_name,
	`s`.subcat_name,
	`c`.cat_name 
FROM 
	goods AS `g`
	JOIN
	subcategories_of_goods AS `s`
	JOIN
	categories_of_goods AS `c`
ON 
	`g`.subcat_name_id = `s`.id
	AND
	`s`.cat_name_id = `c`.id;	
/*
7. Представления (минимум 2);
*/
CREATE OR REPLACE VIEW v_distribution_of_goods AS
SELECT 
	`g`.goods_name,
	`s`.subcat_name,
	`c`.cat_name 
FROM 
	goods AS `g`
	JOIN
	subcategories_of_goods AS `s`
	JOIN
	categories_of_goods AS `c`
ON 
	`g`.subcat_name_id = `s`.id
	AND
	`s`.cat_name_id = `c`.id
WITH CHECK OPTION;

SELECT * FROM v_distribution_of_goods;
/*
 * 
 */
CREATE OR REPLACE VIEW v_goods_with_discounts AS
SELECT
	`g`.id,
	`g`.goods_name,
	`g`.price,
	`d`.discount,
	`d`.started_at,
	`d`.finished_at 
FROM 
	discounts AS `d`
	JOIN
	goods AS `g`

ON
	`d`.good_id = `g`.id;

SELECT * FROM v_goods_with_discounts;
/*
 * 
 */
CREATE OR REPLACE VIEW v_buyers_with_discounts AS
SELECT
	`b`.id ,
	`b`.first_name,
	`b`.last_name,
	`b`.email,
	`d`.discount,
	`d`.started_at, 
	`d`.finished_at 
FROM 
	discounts AS `d`
	JOIN
	buyers AS `b`

ON
	`d`.buyer_id = `b`.id;

SELECT * FROM v_buyers_with_discounts;
/*
8. хранимые процедуры / триггеры; 
*/	
DROP PROCEDURE IF EXISTS pr_application_of_goods_discounts;
delimiter //
CREATE PROCEDURE pr_application_of_goods_discounts()
BEGIN
	DECLARE pr_count INT;
	DECLARE pr_number INT DEFAULT 0;
	DECLARE pr_id BIGINT;
	DECLARE pr_discount DECIMAL(2, 2);
	
	SELECT COUNT(*) INTO pr_count FROM discounts 
	WHERE good_id IS NOT NULL AND finished_at > NOW();

	WHILE pr_count > 0 DO
		SELECT good_id INTO pr_id FROM discounts 
		WHERE good_id IS NOT NULL AND finished_at > NOW() LIMIT pr_number, 1;	
		SELECT discount INTO pr_discount FROM discounts 
		WHERE good_id IS NOT NULL AND finished_at > NOW() LIMIT pr_number, 1;
		
		SET pr_count = pr_count - 1;
		SET pr_number = pr_number + 1;
	
		UPDATE goods 
		SET price = price * (1 - pr_discount)
		WHERE id = pr_id;	
	END WHILE;
END //
delimiter ;

CALL pr_application_of_goods_discounts();
/*
 * Тригер был создан выше для включения записей в таблицу is_new_goods
 */

/*
DROP TRIGGER IF EXISTS tr_insert_into_is_new_goods;
delimiter //
CREATE TRIGGER tr_insert_into_is_new_goods
AFTER INSERT ON goods
FOR EACH ROW
BEGIN 
	INSERT INTO is_new_goods (good_id, finished_at)
	VALUES (NEW.id, DATE_ADD(NEW.created_at, INTERVAL 30 DAY));	
END //
delimiter ; 
 */








