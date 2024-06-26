USE retail_orders;

SELECT * FROM orders;
-- ----------------------------------------EXPLORATORY DATA ANALYSIS-----------------------------------------------------------------
--  QUESTIONS

-- QUES How many orders were placed in the dataset?
SELECT COUNT(*) AS total_orders
FROM orders;


-- QUES What is the total revenue generated from all the orders?
SELECT SUM(sale_price) AS total_sales
FROM orders;


-- QUES  What are the top 5 best-selling products by quantity?
SELECT product_id, COUNT(*) AS total_orders
FROM orders
GROUP BY product_id
ORDER BY total_orders DESC
LIMIT 5;


-- QUES What is the total revenue generated by each region?
SELECT region,SUM(sale_price) AS total_sales
FROM orders
GROUP BY region
ORDER BY total_sales DESC;


-- QUES Find Top 10 highest revenue generating products
SELECT product_id , SUM(sale_price) AS total_sales
FROM orders
GROUP BY product_id
ORDER BY total_sales DESC
LIMIT 10;


-- QUES Find Top 5 highest selling products in each region
WITH cte AS (
SELECT region,product_id, SUM(sale_price) AS total_sales,
ROW_NUMBER() OVER (partition by region ORDER BY SUM(sale_price) DESC) AS rn
FROM orders
GROUP BY region ,product_id )
SELECT region,product_id,total_sales,rn 
FROM cte  
where rn<=5;


-- QUES Find month over month growth comparison for 2022 and 2023 sales eg: Jan 2022 VS Jan 2023
WITH cte AS (
SELECT  YEAR(order_date) AS order_year,MONTH(order_date) AS order_month, 
SUM(sale_price) AS total_sales
FROM orders
GROUP BY order_year,order_month
)
SELECT order_month ,
SUM(CASE WHEN order_year=2022 THEN total_sales ELSE 0 END) AS sales_2022,
SUM(CASE WHEN order_year=2023 THEN total_sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month;


-- QUES For each category which month had highest sales
WITH cte AS (
SELECT category , MONTH(order_date) AS order_month, 
SUM(sale_price) AS total_sales,
ROW_NUMBER() OVER(PARTITION BY category ORDER BY SUM(sale_price) DESC) AS rn
FROM orders
GROUP BY category,order_month 
)
SELECT category,order_month,total_sales
FROM cte
WHERE rn=1;


-- QUES Which sub_category had highest growth by profit in 2023 compare to 2022?
WITH cte AS (
SELECT  sub_category,
YEAR(order_date) AS order_year, 
SUM(sale_price) AS total_sales
FROM orders
GROUP BY sub_category,order_year
),
cte2 as(
SELECT sub_category ,
SUM(CASE WHEN order_year=2022 THEN total_sales ELSE 0 END) AS sales_2022,
SUM(CASE WHEN order_year=2023 THEN total_sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY sub_category 
)
SELECT *,
(sales_2023 - sales_2022)*100/sales_2022 AS growth_percent
FROM cte2
ORDER BY growth_percent DESC
LIMIT 1;