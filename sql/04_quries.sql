USE ecommerce_db;
GO
 
/* 1. Top 10 products by revenue */
SELECT TOP 10
    i.item_name,
    SUM(f.total_price) AS total_sales
FROM fact_table f
JOIN item_dim i ON f.item_key = i.item_key
GROUP BY i.item_name
ORDER BY total_sales DESC;
 
/* 2. Top 10 customers by total spend */
SELECT TOP 10
    c.name,
    SUM(f.total_price) AS total_spend
FROM fact_table f
JOIN customer_dim c ON f.customer_key = c.coustomer_key
GROUP BY c.name
ORDER BY total_spend DESC;
 
/* 3. Sales by city */
SELECT TOP 10
    s.city,
    SUM(f.total_price) AS total_sales
FROM fact_table f
JOIN store_dim s ON f.store_key = s.store_key
GROUP BY s.city
ORDER BY total_sales DESC;
 
/* 4. Sales by month (across all years) */
SELECT
    t.month,
    SUM(f.total_price) AS total_sales
FROM fact_table f
JOIN time_dim t ON f.time_key = t.time_key
GROUP BY t.month
ORDER BY t.month;
 
/* 5. Total sales by store */
SELECT
    s.store_key,
    s.upazila,
    SUM(f.total_price) AS total_store_sales
FROM fact_table f
JOIN store_dim s ON f.store_key = s.store_key
GROUP BY s.store_key, s.upazila
ORDER BY total_store_sales DESC;
 
/* 6. Monthly sales trend by year */
SELECT
    t.year,
    t.month,
    SUM(f.total_price) AS monthly_sales
FROM fact_table f
JOIN time_dim t ON f.time_key = t.time_key
GROUP BY t.year, t.month
ORDER BY t.year, t.month;
 
/* 7. Customer purchase frequency */
SELECT TOP 10
    c.name,
    COUNT(*) AS purchase_frequency
FROM fact_table f
JOIN customer_dim c ON f.customer_key = c.coustomer_key
GROUP BY c.name
ORDER BY purchase_frequency DESC;
 
/* 8. Top 5 product categories by quantity sold */
SELECT TOP 5
    i.description AS product_category,
    SUM(f.quantity) AS total_quantity_sold
FROM fact_table f
JOIN item_dim i ON f.item_key = i.item_key
GROUP BY i.description
ORDER BY total_quantity_sold DESC;
 
/* 9. Payment method preferences */
SELECT
    p.trans_type,
    COUNT(*) AS payment_count
FROM fact_table f
JOIN payment_dim p ON f.payment_key = p.payment_key
GROUP BY p.trans_type
ORDER BY payment_count DESC;
 