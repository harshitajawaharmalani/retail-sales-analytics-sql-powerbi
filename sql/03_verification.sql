USE ecommerce_db;
GO

-- Row counts across all tables
SELECT 'customer_dim' AS table_name, COUNT(*) AS row_count FROM customer_dim
UNION ALL SELECT 'item_dim', COUNT(*) FROM item_dim
UNION ALL SELECT 'store_dim', COUNT(*) FROM store_dim
UNION ALL SELECT 'time_dim', COUNT(*) FROM time_dim
UNION ALL SELECT 'payment_dim', COUNT(*) FROM payment_dim
UNION ALL SELECT 'fact_table', COUNT(*) FROM fact_table;

-- Referential integrity check (all orphan counts should be 0)
SELECT
    COUNT(CASE WHEN c.coustomer_key IS NULL THEN 1 END) AS orphan_customers,
    COUNT(CASE WHEN i.item_key IS NULL THEN 1 END) AS orphan_items,
    COUNT(CASE WHEN s.store_key IS NULL THEN 1 END) AS orphan_stores,
    COUNT(CASE WHEN t.time_key IS NULL THEN 1 END) AS orphan_times,
    COUNT(CASE WHEN p.payment_key IS NULL THEN 1 END) AS orphan_payments
FROM fact_table f
LEFT JOIN customer_dim c ON f.customer_key = c.coustomer_key
LEFT JOIN item_dim i ON f.item_key = i.item_key
LEFT JOIN store_dim s ON f.store_key = s.store_key
LEFT JOIN time_dim t ON f.time_key = t.time_key
LEFT JOIN payment_dim p ON f.payment_key = p.payment_key;
GO


ALTER TABLE fact_table DROP CONSTRAINT IF EXISTS FK_fact_item;
TRUNCATE TABLE item_dim;

BULK INSERT item_dim
FROM 'C:\Users\asus\Desktop\ecommerce-star-schema-analytics\data\item_dim.csv'   -- update to your local path
WITH (FIRSTROW = 2, FORMAT = 'CSV', FIELDQUOTE = '"',
      FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);

ALTER TABLE fact_table
ADD CONSTRAINT FK_fact_item FOREIGN KEY (item_key) REFERENCES item_dim(item_key);
GO