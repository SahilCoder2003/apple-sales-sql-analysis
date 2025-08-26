CREATE TABLE category(
	category_id VARCHAR(10),
	category_name VARCHAR(25)
)
DROP TABLE IF EXISTS stores;
CREATE TABLE stores(
	store_id VARCHAR(10),
	store_name VARCHAR(30),
	city VARCHAR(15),
	country VARCHAR(10),
	opening_date DATE
)

DROP TABLE IF EXISTS product;
CREATE TABLE product(
	product_id VARCHAR(10),
	product_name VARCHAR(30),
	category_id VARCHAR(10),
	launch_date DATE,
	price VARCHAR(10)
)
 DROP TABLE IF EXISTS sales;
 CREATE TABLE sales(
	sale_id VARCHAR(15),
	sale_date VARCHAR(20),
	store_id VARCHAR(10),
	product_id VARCHAR(10),
	quantity INT
 )
 DROP TABLE IF EXISTS warranty;
 CREATE TABLE warranty(
	claim_id VARCHAR(10),
	claim_date DATE,
	sale_id VARCHAR(15),
	repair_status VARCHAR(15)
 )
-- ADD CONSTRAINTS (PRIMARY KEY AND FOREIGN KEY)
ALTER TABLE category 
ADD primary key(category_id)

ALTER TABLE product
ADD PRIMARY KEY(product_id)

ALTER TABLE sales
ADD PRIMARY KEY(sale_id)

ALTER TABLE stores
ADD PRIMARY KEY(store_id)

ALTER TABLE warranty 
ADD PRIMARY KEY(claim_id)

-- FOREIGN KEY CONSTRAINTS
ALTER TABLE product
ADD CONSTRAINT fk_product_id FOREIGN KEY(category_id)
REFERENCES category(category_id)

ALTER TABLE product
ADD CONSTRAINT fk_store_id FOREIGN KEY(store_id)
REFERENCES stores(store_id),
ADD CONSTRAINT fk_product_id FOREIGN KEY(product_id)
REFERENCES product(product_id);
