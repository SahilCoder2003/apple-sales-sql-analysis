--  CHEKING THAT ALL THE TABLE RUN OR NOT PROPERLY
SELECT * FROM category
SELECT * FROM product
SELECT * FROM sales
SELECT * FROM stores
SELECT * FROM warranty


SELECT * FROM sales
where sale_id is not null

DELETE FROM sales
WHERE sale_id is null

-- QUETIONS AND ANSWER

EXPLAIN ANALYZE
SELECT * FROM sales
WHERE product_id='P-44'
-- BEFORE APPLYING THE INDEXES THE EXECUTION TIME OF ABOVE QUERY IS 139.858MS

-- CREATE THE INDEX
CREATE INDEX ON sales(product_id)
EXPLAIN ANALYZE
SELECT * FROM sales
WHERE product_id='P-44'
-- AFTER APPLYING INDEXES THE EXECUTION TIME OF ABOVE QUERY IS 36.503MS
EXPLAIN ANALYZE
SELECT * FROM product AS p
JOIN category AS cat
ON cat.category_id=p.category_id
-- EX TIME OF ABOVE CODE IS 0.115MS
CREATE INDEX product_category_id ON product(category_id)
EXPLAIN ANALYZE
SELECT * FROM product AS p
JOIN category AS cat
ON cat.category_id=p.category_id

-- 01:FIND THE NUMBER OF STORES IN EACH COUNTRY
SELECT 
	country,
	COUNT(store_id) AS total_Stores
FROM stores
GROUP BY 1
ORDER BY 2 DESC
 -- 02:CALCULATE THE TOTAL NUMBER OF UNITS SOLD BY EACH COUNTRY
SELECT
 	s.country,
 	SUM(sa.quantity) AS total_unti_sold 
FROM stores AS s
JOIN sales AS sa
ON sa.store_id=s.store_id
GROUP BY 1
ORDER BY 2 DESC

-- 03:IDENTIFY HOW MANY SALES OCCURED IN DECEMBER 2023
SELECT 
	COUNT(sale_id)
FROM sales
WHERE TO_CHAR(TO_DATE(sale_date,'DD-MM-YYYY'),'MM-YYYY')='12-2023'

-- 04:DETERMINE HOW MANY STORE HAVE NEVER HAD WARRANTY CLAIM FILED
SELECT DISTINCT(st.store_id) FROM stores AS st
LEFT JOIN sales AS sa
ON sa.store_id=st.store_id
LEFT JOIN warranty as w
ON w.sale_id=sa.sale_id
WHERE w.sale_id IS NULL

or

SELECT COUNT(*) FROM stores 
WHERE store_id NOT IN(SELECT DISTINCT(store_id) FROM sales AS s
							 RIGHT JOIN warranty as w
							ON s.sale_id=w.sale_id)

-- 05:CALCULATE THE PERCENTAGE OF WARRANTY CLAIMES MARKED AS 'WARRANY VOID'
SELECT DISTINCT(repair_status) FROM warranty

SELECT
	ROUND(count(*)::NUMERIC/(SELECT count(*) FROM warranty)::NUMERIC*100 ,2)AS per_wv
FROM warranty
WHERE repair_status='Warranty Void'

-- 06:IDENTITY THE WHICH STORE HAD THE HIGHEST TOTAL UNITS SOLD IN THE LAST YEAR
SELECT 
	st.store_id,
	st.store_name,
	SUM(sa.quantity) AS total_units_sold 
FROM stores as st
JOIN sales AS sa
ON sa.store_id=st.store_id
WHERE  TO_CHAR(TO_DATE(sale_date,'DD-MM-YYYY'),'YYYY')='2023'
GROUP BY 1,2
ORDER BY 3 DESC

-- 07:COUNT THE NUMBER OF UNIQUE PRODUCT SOLD IN LAST YEAR
SELECT product_id,product_name FROM product
WHERE product_id in (
					SELECT DISTINCT PRODUCT_ID FROM sales
					WHERE TO_CHAR(TO_DATE(sale_date,'DD-MM-YYYY'),'YYYY')='2023')

-- 08:FIND THE AVEARAGE PRICE PRODUCT IN EACH CATEGORY
SELECT 
	p.category_id,
	cat.category_name,
	ROUND(AVG(PRICE),2)
FROM product AS p
JOIN category AS cat
ON cat.category_id=p.category_id
GROUP BY 1,2
ORDER BY 3 DESC

-- 09:HOW MANY WARRANTY CLAIMS WERE FILLED IN 2020
SELECT count(*) FROM warranty
WHERE EXTRACT(YEAR FROM claim_date)=2020

-- 10:FOR EACH STORE IDENTIFY THE BEST SELLING DAY BASED ON THE HIGHEST QUANTITY SOLD
SELECT * FROM(
SELECT store_id,
	 TO_CHAR(TO_DATE(sale_date,'DD-MM-YYYY'),'DAY'),
	SUM(quantity) AS total_quantity_sold,
	RANK() OVER(PARTITION BY store_id ORDER BY SUM(quantity)) AS ranks
FROM sales
GROUP BY 1,2)
WHERE ranks=1

-- 11:FIND THE REVENUE OF THE TOP 3 PRODUCT BY REVEUE PER MONTH
SELECT * FROM(
SELECT 
	p.product_id,
	p.product_name,

	EXTRACT(MONTH FROM TO_DATE(sa.sale_date,'DD-MM-YYYY')) AS month,
	
	sum(p.price*sa.quantity) AS revenue,
	RANK() OVER(PARTITION BY EXTRACT(MONTH FROM TO_DATE(sa.sale_date,'DD-MM-YYYY')) ORDER BY sum(p.price*sa.quantity)DESC ) AS top_revenue_rank
FROM product AS p
JOIN sales AS sa
ON sa.product_id=p.product_id
GROUP BY 1,2,3)
WHERE top_revenue_rank<=3

-- MEDIUM TO HARD QUETIONS
--PRACTIVE QUERY
SELECT DISTINCT store_id,EXTRACT(MONTH FROM TO_DATE(sale_date,'DD-MM-YYYY')) as date
FROM sales
ORDER BY 1
with con AS(
SELECT DISTINCT product_id,DATE_TRUNC('MONTH',launch_Date) FROM product
)
SELECT * FROM con a
JOIN con b
ON a.product_id=b.product_id
AND b.sale_Date=a.sale_date + interval '1 month'


CREATE TABLE self_join(
 user_id VARCHAR(10),
 month_start DATE
)

INSERT INTO self_join(user_id, month_start)
VALUES
('U1', '2025-01-01'),
('U1', '2025-02-01'),
('U1', '2025-04-01'),
('U2', '2025-02-01'),
('U2', '2025-03-01'),
('U3', '2025-01-01'),
('U3', '2025-03-01'),
('U4', '2025-11-01'),
('U4', '2025-12-01');

SELECT * FROM self_join

with ctc AS(
SELECT DISTINCT user_id,DATE_TRUNC('MONTH',month_start) as month_start FROM self_join
)

SELECT DISTINCT(COUNT(sj1.user_id)) FROM ctc as sj2
JOIN ctc as sj1
ON sJ1.user_id=sj2.user_id
AND sj2.month_start=sj1.month_start + interval '1 month'


SELECT * FROM category
SELECT DISTINCT category_id,launch_Date FROM product

-- 11:IDENTIFY THE LEAST SELLING PRODUCT IN EACH COUTRY AND EACH YEAR BASED ON THE TOTAL_UNITS SOLD
SELECT lr.*,p.product_name FROM(
SELECT 
	st.country,
	EXTRACT(YEAR FROM TO_DATE(sa.sale_date,'DD-MM-YYYY')) AS year_of_sale,
	sa.product_id,
	SUM(sa.quantity) AS total_sold_product,
	RANK() OVER(PARTITION BY st.country,
								EXTRACT(YEAR FROM TO_DATE(sa.sale_date,'DD-MM-YYYY'))
								ORDER BY SUM(sa.quantity)) AS least_rank
FROM stores AS st
JOIN sales AS sa
ON sa.store_id=st.store_id
GROUP BY 1,2,3
) AS lr JOIN product AS p
ON p.product_id=lr.product_id
WHERE least_rank=1

-- 12:CALCULATE THE HOW MANY WARRANTLY WERE FILLED IN THE LAST 180 DAYS OF A PRODUCT SALE


EXPLAIN ANALYZE
SELECT * FROM sales AS sa
JOIN warranty AS w
ON w.sale_id=sa.sale_id

CREATE INDEX w_sale_id ON warranty(sale_id)
CREATE INDEX sa_sale_is ON sales(sale_id)

SELECT COUNT(w.claim_id) AS days FROM sales AS sa
LEFT JOIN warranty AS w
ON w.sale_id=sa.sale_id
WHERE w.claim_date-TO_DATE(sa.sale_date,'DD-MM-YYYY')<=180

-- 13:DETERMINE THE HOW MANY WARRANTY WERE CLAIMS WERE FILLED FOR PRODUCTS LAUNCHED IN THE LAST YEAR

SELECT p.product_id,p.product_name,COUNT(w.claim_id) FROM product AS P
JOIN sales AS sa
ON sa.product_id=p.product_id
JOIN warranty AS w
ON w.sale_id=sa.sale_id
WHERE p.launch_date>=(SELECT MAX(TO_DATE(sale_date,'dd-mm-yyyy')) FROM sales)- INTERVAL '2 years'
GROUP BY 1,2

-- 14:LEAST THE MONTH IN THE LAST THREE YEAR WHERE SALES EXCEEDED 5000 UNITS IN USA

SELECT  
	st.country,
	EXTRACT(YEAR FROM TO_DATE(sa.sale_date,'DD-MM-YYYY')) AS years,
	EXTRACT(MONTH FROM TO_DATE(sa.sale_date,'dd-mm-yyyy')) AS months,
	SUM(sa.quantity) FROM sales AS sa
JOIN stores AS  st
ON sa.store_id=st.store_id
WHERE 
	TO_DATE(sa.sale_date,'DD-MM-YYYY')>=
							(SELECT 
									MAX(TO_DATE(sale_date,'dd-mm-yyyy'))
							FROM sales)- INTERVAL '3 years'
AND st.country='USA'							
GROUP BY 1,2,3
HAVING SUM(sa.quantity)>=5000
ORDER BY 2

-- 15:IDENTIFY THE PRODUCT CATEGORY WITH MOST WARRANTY CLAIMS IN THE LAST TWO YEARS

SELECT 
		ca.category_id,
		ca.category_name,
	   COUNT(w.claim_id) AS claim_count
FROM category AS ca
JOIN product AS p
ON p.category_id=ca.category_id
JOIN sales AS sa
ON sa.product_id=p.product_id
JOIN warranty AS w
ON sa.sale_id=w.sale_id
WHERE w.claim_date >=(SELECT 
									MAX(TO_DATE(sale_date,'dd-mm-yyyy'))
							FROM sales)- INTERVAL '2 years'
GROUP BY 1,2
ORDER BY 3 DESC

COMPLEX QUETIONS

-- 16:DETERMINE THE PERCENTAGE CHANCE OF RECIVEING WARRANTY CLAIMS AFTER EACH PURCHACE FOR EACH COUNTRY
SELECT country,
	  total_sales,
	  total_claim,
	  COALESCE(total_claim::NUMERIC/total_sales::NUMERIC*100,0) AS per_of_chance
FROM(
	SELECT 
		st.country,
		COUNT(sa.sale_id) AS total_sales,
		COUNT(W.claim_id) AS total_claim 
	FROM sales AS sa
	JOIN stores AS st
	ON st.store_id=sa.store_id
	LEFT JOIN warranty AS w
	ON w.sale_id=sa.sale_id
	GROUP BY 1)
ORDER BY 4 DESC

-- 17:ANALYZE THE Y-O-Y GROWTH RATIO FOR EACH STORE

SELECT 
	*,
	ROUND((current_year_revenue-privious_year_revenue)::NUMERIC/privious_year_revenue*100,2) AS growth_ratio
FROM
(
	SELECT 
	    st.store_id,
		st.store_name,
		EXTRACT(YEAR FROM TO_DATE(sa.sale_date,'DD-MM-YYYY')) AS current_year,
		SUM(sa.quantity*p.price) AS  current_year_revenue,
		LAG(SUM(sa.quantity*p.price))  OVER(PARTITION BY st.store_id) AS privious_year_revenue
	FROM stores AS st
	JOIN sales AS sa
	ON sa.store_id=st.store_id
	JOIN product AS p
	ON p.product_id=sa.product_id
	GROUP BY 1,2,3)

-- 18:CALCULATE THE CORRELATED BETWEEN PRODUCT PRICE AND WARRANTY CLAIM FOR 
-- PRODUCT SOLD IN THE LAST FIVE YEARS,SEGMENTED BY PRICE RANGE

SELECT
	 CASE
	 	WHEN p.price < 500 THEN 'less_expensive product'
		WHEN p.price BETWEEN 500 AND 1500 THEN 'midium price product'
		WHEN p.price BETWEEN 1500 AND 2500 THEN 'hiest price product'
	 END  AS price_segments,
	 count(w.claim_id) AS total_claims	
FROM warranty AS w
LEFT JOIN sales AS sa
ON sa.sale_id=w.sale_id
JOIN product AS p
ON p.product_id=sa.product_id
GROUP BY 1

-- 19:IDENTIFY THE STORE WITH THE HIEGHTS PERSENTAGE OF 'PAID_REPAIRED' CLAIMS RELATIVE TO TOTAL_CLAIM FILLED
WITH paid_repaired_per AS(
SELECT 
	sa.store_id,
	count(w.claim_id) AS total_repaid,
	COUNT(CASE WHEN w.repair_status='Paid Repaired' THEN 1 END) AS paid_repaid
FROM sales AS sa
RIGHT JOIN warranty AS w
ON w.sale_id=sa.sale_id
GROUP BY 1)
SELECT 
	*,
	ROUND((paid_repaid::NUMERIC/total_repaid::NUMERIC)::NUMERIC*100,2) AS diff
FROM paid_repaired_per
ORDER BY diff DESC

-- 20:WRITE QUERY TO CALCULATE THE MONTHLY RUNNING TOTAL OF SALES FOR EACH STORE 
-- OVER THE PAST FOUR YEAR AND CAMPARE TRENDS DURING THE PERIOD

SELECT 
	*,
	SUM(to_product_sold) 
			over(PARTITION BY store_id,year ORDER BY month  
							ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW ) 
FROM(
SELECT 
	st.store_id,
	st.store_name,
	EXTRACT(YEAR FROM TO_DATE(sa.sale_date,'DD-MM-YYYY'))AS year,
	EXTRACT(MONTH FROM TO_DATE(sa.sale_date,'DD-MM-YYYY')) AS month,
	COUNT(sa.quantity) to_product_sold	
FROM sales AS sa
JOIN stores AS st
ON st.store_id=sa.store_id
WHERE EXTRACT(YEAR FROM TO_DATE(sa.sale_date,'DD-MM-YYYY'))>=2020
GROUP BY 1,2,3,4)

-- BONUS QUESTIONS 
-- ANALYZE PRODUCT SALES TREND OVER TIME,SEGMENTED INTO KEY PERIOD
-- 			:FROM LAUNCH TO 6 MONTHS,6-12 MONTHS,12-18 MONTHS AND BEYOND 18 MONTHS
 
SELECT 
	p.product_name,
	CASE 
		WHEN 
			TO_DATE(sale_date,'DD-MM-YYYY') BETWEEN p.launch_date AND p.launch_date+interval '6 months'
		THEN '0 to6 months interval'
		WHEN 
			TO_DATE(sale_date,'DD-MM-YYYY') BETWEEN p.launch_date+interval '6 months' AND p.launch_date+interval '12 months'
		THEN '6  to 12 months interval'
		WHEN 
			TO_DATE(sale_date,'DD-MM-YYYY') BETWEEN p.launch_date+interval '12 months' AND p.launch_date+interval '18 months'
		THEN '12 to 18 months interval' 
	ELSE '18 months abouve'
	END AS sales_month_segments,
	sum(sa.quantity)
FROM product AS p
JOIN sales AS sa
ON sa.product_id=p.product_id
GROUP BY 1,2
ORDER BY 2




