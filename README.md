# 🍏 Apple Sales SQL Analysis  

## 📌 Project Overview  
This project demonstrates **end-to-end SQL analysis** on Apple’s sales data.  
It involves designing normalized tables, solving 20+ real-world business queries, and optimizing performance with indexes and `EXPLAIN ANALYZE`.  

The goal is to showcase SQL skills in **Joins, Window Functions, Subqueries, CTEs, and Query Optimization**.  

---

## 🛠️ Skills & Tools  
- **PostgreSQL** (Database & Querying)  
- **pgAdmin** (Database Management)  
- **SQL Concepts:**  
  - Joins (INNER, LEFT, SELF, RIGHT)  
  - Window Functions (RANK, SUM OVER, LAG, LEAD)  
  - Subqueries & CTEs  
  - Date Functions (DATE_TRUNC, TO_DATE, EXTRACT, INTERVAL)  
  - Query Optimization (`EXPLAIN ANALYZE`, Indexing)  

---

## 📂 Dataset Structure  
- `category.csv` → Product categories  
- `products.csv` → Apple products with launch dates & categories  
- `stores.csv` → Store details (city, country, region)  
- `sales.csv` → Sales transactions (store, product, user, quantity, price)  
- `warranty.csv` → Warranty details (claims, status, validity)  

---

## 🔑 Key Business Questions Solved  

### 1️⃣ Top 3 Products by Revenue Per Month  
```sql
SELECT month, product_id, revenue
FROM (
    SELECT DATE_TRUNC('month', sale_date) AS month,
           product_id,
           SUM(quantity * price) AS revenue,
           RANK() OVER (PARTITION BY DATE_TRUNC('month', sale_date)
                        ORDER BY SUM(quantity * price) DESC) AS rank
    FROM sales
    GROUP BY month, product_id
) t
WHERE rank <= 3;
```
### 2️⃣ Customers Who Never Purchased the Same Item Twice
```sql
SELECT DISTINCT s.user_id
FROM sales s
WHERE NOT EXISTS (
    SELECT 1
    FROM sales s2
    WHERE s.user_id = s2.user_id
    GROUP BY s2.user_id, s2.product_id
    HAVING COUNT(*) > 1
);

```
### 3️⃣ Least-Selling Product by Country & Year
```sql
SELECT country, year, product_id, total_sales
FROM (
    SELECT st.country,
           DATE_PART('year', sa.sale_date) AS year,
           sa.product_id,
           SUM(sa.quantity) AS total_sales,
           RANK() OVER (PARTITION BY st.country, DATE_PART('year', sa.sale_date)
                        ORDER BY SUM(sa.quantity) ASC) AS least_rank
    FROM sales sa
    JOIN stores st ON sa.store_id = st.store_id
    GROUP BY st.country, year, sa.product_id
) t
WHERE least_rank = 1;

```
### 4️⃣ Year-on-Year Growth Ratio for Stores
```sql
SELECT store_id,
       year,
       total_sales,
       LAG(total_sales) OVER (PARTITION BY store_id ORDER BY year) AS prev_year_sales,
       ROUND(
         (total_sales::numeric - LAG(total_sales) OVER (PARTITION BY store_id ORDER BY year)) 
         / NULLIF(LAG(total_sales) OVER (PARTITION BY store_id ORDER BY year), 0) * 100, 2
       ) AS yoy_growth_percent
FROM (
    SELECT store_id,
           DATE_PART('year', sale_date) AS year,
           SUM(quantity * price) AS total_sales
    FROM sales
    GROUP BY store_id, year
) yearly_sales;

```
## 📈 Project Outcomes
- Identified top-performing and least-selling products across countries and years.
- Discovered customer purchasing patterns (unique buyers, repeat buyers, etc.).
- Analyzed warranty claims and calculated percentage of void claims.
- Calculated year-on-year growth of Apple stores.
- Optimized queries using indexes, reducing runtime by 70% (139ms → 36ms)

  
## 🚀 How to Run the Project
- Clone this repository:
   ```bash
   git clone https://github.com/SahilCoder2003/apple-sales-sql-analysis.git
   cd apple-sales-sql-analysis
- Create a PostgreSQL database (e.g., apple_database).
- Import CSV datasets into respective tables (category, products, stores, sales, warranty).
- Run queries from the APPLE_SQL.sql or question_of_sql.sql files in pgAdmin or psql.
  
##  🧑‍💻 Author 
# Sahil F.
- Aspiring Data Analyst & Data Scientist
- Skills: SQL, Python, Excel, Data Analysis
🌐 LinkedIn Profile
 (www.linkedin.com/in/sahilf2003)
