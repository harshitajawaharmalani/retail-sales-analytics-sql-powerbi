USE ecommerce_db;
GO
/* ---------- 0. Profiling: how bad is it? (run before creating views) ---------- */
 

SELECT
    COUNT(*)                                                         AS total_rows,
    SUM(CASE WHEN name IS NULL THEN 1 ELSE 0 END)                    AS null_names,
    SUM(CASE WHEN name LIKE '%"%' THEN 1 ELSE 0 END)                 AS names_with_quotes,
    SUM(CASE WHEN name LIKE '%[sSrRdDwWcC]/[oO] %' THEN 1 ELSE 0 END) AS names_with_address_text,
    SUM(CASE WHEN contact_no IS NULL THEN 1 ELSE 0 END)              AS null_contacts,
    SUM(CASE WHEN contact_no LIKE '%[^0-9]%' THEN 1 ELSE 0 END)      AS non_numeric_contacts
FROM customer_dim;
GO
 
 
/* ---------- 1. Clean customer view ---------- */
 
CREATE OR ALTER VIEW vw_customer_dim_clean AS
SELECT
    c.coustomer_key AS customer_key,

    COALESCE(
        NULLIF(NULLIF(s3.name_clean, ''), 'null'),
        'Unknown Customer'
    ) AS customer_name,

    CASE
        WHEN LTRIM(RTRIM(c.contact_no)) NOT LIKE '%[^0-9]%'
             AND LEN(LTRIM(RTRIM(c.contact_no))) BETWEEN 10 AND 13
        THEN LTRIM(RTRIM(c.contact_no))
        ELSE NULL
    END AS contact_no,

    CASE
        WHEN LTRIM(RTRIM(c.contact_no)) NOT LIKE '%[^0-9]%'
             AND LEN(LTRIM(RTRIM(c.contact_no))) BETWEEN 10 AND 13
        THEN 1 ELSE 0
    END AS is_contact_valid,

    c.nid
FROM customer_dim c
CROSS APPLY (
    SELECT REPLACE(LTRIM(RTRIM(c.name)), '"', '') AS n1
) s1
CROSS APPLY (
    SELECT LTRIM(RTRIM(
        CASE
            WHEN PATINDEX('% [sSrRdDwWcC]/[oO]%', ' ' + s1.n1) > 0
                THEN LEFT(s1.n1, PATINDEX('% [sSrRdDwWcC]/[oO]%', ' ' + s1.n1) - 1)
            ELSE s1.n1
        END
    )) AS n2
) s2
CROSS APPLY (
    SELECT LTRIM(RTRIM(
        CASE
            WHEN CHARINDEX('@', s2.n2) > 0
                THEN LEFT(s2.n2, CHARINDEX('@', s2.n2) - 1)
            ELSE s2.n2
        END
    )) AS name_clean
) s3;
GO
 
 
/* ---------- 2. Clean time view ---------- */
 
CREATE OR ALTER VIEW vw_time_dim_clean AS
SELECT
    t.time_key,
    d.full_date,
    CAST(d.full_date AS DATE)            AS date_only,
    DATEPART(HOUR,  d.full_date)         AS hour_of_day,
    DAY(d.full_date)                     AS day_of_month,
    DATEPART(ISO_WEEK, d.full_date)      AS week_no,        -- replaces the empty week column
    MONTH(d.full_date)                   AS month_no,
    DATENAME(MONTH, d.full_date)         AS month_name,
    'Q' + CAST(DATEPART(QUARTER, d.full_date) AS VARCHAR(1)) AS quarter_label,
    YEAR(d.full_date)                    AS year_no
FROM time_dim t
CROSS APPLY (
    SELECT TRY_CONVERT(DATETIME, t.[date], 105) AS full_date   -- 105 = dd-mm-yyyy
) d;
GO
 

 /* ---------- 3. Validation (run after creating the views) ---------- */
 
-- Names fixed
SELECT TOP 20 c.name AS raw_name, v.customer_name AS clean_name
FROM customer_dim c
JOIN vw_customer_dim_clean v ON v.customer_key = c.coustomer_key
WHERE c.name IS NULL OR c.name LIKE '%"%' OR c.name LIKE '%[sSrRdDwWcC]/[oO] %';
 
-- Contact numbers rejected as invalid
SELECT COUNT(*) AS invalid_contacts
FROM vw_customer_dim_clean
WHERE is_contact_valid = 0;
 
-- Dates that failed to parse (should be 0; if not, check date format)
SELECT COUNT(*) AS unparsed_dates
FROM vw_time_dim_clean
WHERE full_date IS NULL;
 
-- Row counts must match the raw tables
SELECT
    (SELECT COUNT(*) FROM customer_dim)          AS raw_customers,
    (SELECT COUNT(*) FROM vw_customer_dim_clean) AS clean_customers,
    (SELECT COUNT(*) FROM time_dim)              AS raw_time,
    (SELECT COUNT(*) FROM vw_time_dim_clean)     AS clean_time;
 
-- Fact rows where price conversion failed in the load (TRY_CAST returns NULL)
SELECT COUNT(*) AS fact_rows_with_null_price
FROM fact_table
WHERE total_price IS NULL OR unit_price IS NULL OR quantity IS NULL;
GO