USE ecommerce_db;
GO

-- 1. Load Direct Dimension Tables
BULK INSERT customer_dim
FROM 'C:\Users\asus\Desktop\ecommerce-star-schema-analytics\data\customer_dim.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);

BULK INSERT item_dim
FROM 'C:\Users\asus\Desktop\ecommerce-star-schema-analytics\data\item_dim.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);

BULK INSERT store_dim
FROM 'C:\Users\asus\Desktop\ecommerce-star-schema-analytics\data\store_dim.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);

BULK INSERT payment_dim
FROM 'C:\Users\asus\Desktop\ecommerce-star-schema-analytics\data\payment_dim.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);

-- 2. Load Time Dimension via Staging Table
CREATE TABLE #time_stage (
    time_key VARCHAR(50), date VARCHAR(50), hour VARCHAR(20), day VARCHAR(20),
    week VARCHAR(20), month VARCHAR(20), quarter VARCHAR(20), year VARCHAR(20)
);

BULK INSERT #time_stage
FROM 'C:\Users\asus\Desktop\ecommerce-star-schema-analytics\data\time_dim.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '\n', TABLOCK);

INSERT INTO time_dim (time_key, date, hour, day, week, month, quarter, year)
SELECT time_key, date, TRY_CAST(hour AS INT), day, TRY_CAST(week AS INT), TRY_CAST(month AS INT), quarter, TRY_CAST(year AS INT)
FROM #time_stage;

DROP TABLE #time_stage;

-- 3. Load Fact Table via Staging Buffer (Handles Line Endings & Currency Formatting)
CREATE TABLE #fact_stage_raw (
    c1 VARCHAR(MAX), c2 VARCHAR(MAX), c3 VARCHAR(MAX), c4 VARCHAR(MAX), c5 VARCHAR(MAX),
    c6 VARCHAR(MAX), c7 VARCHAR(MAX), c8 VARCHAR(MAX), c9 VARCHAR(MAX), c10 VARCHAR(MAX)
);

BULK INSERT #fact_stage_raw
FROM 'C:\Users\asus\Desktop\ecommerce-star-schema-analytics\data\fact_table.csv'
WITH (FIRSTROW = 2, FIELDTERMINATOR = ',', ROWTERMINATOR = '0x0a', TABLOCK);

INSERT INTO fact_table (payment_key, customer_key, time_key, item_key, store_key, quantity, unit, unit_price, total_price)
SELECT 
    c1, c2, c3, c4, c5, 
    TRY_CAST(c6 AS INT), 
    c7, 
    TRY_CAST(REPLACE(REPLACE(c8, '$', ''), ',', '') AS NUMERIC(10,2)), 
    TRY_CAST(REPLACE(REPLACE(c9, '$', ''), ',', '') AS NUMERIC(12,2))
FROM #fact_stage_raw;

DROP TABLE #fact_stage_raw;

-- 4. Insert Placeholders for Missing Item Keys to Preserve Data Integrity
INSERT INTO item_dim (item_key, item_name, description, unit_price, man_country, supplier, unit)
SELECT DISTINCT 
    f.item_key,
    'Unknown Item (' + f.item_key + ')',
    'Auto-generated placeholder for key missing from source CSV',
    0.00,
    'Unknown',
    'Unknown',
    'pcs'
FROM fact_table f
LEFT JOIN item_dim i ON f.item_key = i.item_key
WHERE i.item_key IS NULL;

-- 5. Add Foreign Key Constraints after Data Validation
ALTER TABLE fact_table
ADD CONSTRAINT FK_fact_customer FOREIGN KEY (customer_key) REFERENCES customer_dim(coustomer_key),
    CONSTRAINT FK_fact_item FOREIGN KEY (item_key) REFERENCES item_dim(item_key),
    CONSTRAINT FK_fact_store FOREIGN KEY (store_key) REFERENCES store_dim(store_key),
    CONSTRAINT FK_fact_time FOREIGN KEY (time_key) REFERENCES time_dim(time_key),
    CONSTRAINT FK_fact_payment FOREIGN KEY (payment_key) REFERENCES payment_dim(payment_key);
GO