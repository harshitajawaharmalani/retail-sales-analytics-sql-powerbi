USE ecommerce_db;
GO

-- 1. Drop existing tables if re-running script
IF OBJECT_ID('fact_table', 'U') IS NOT NULL DROP TABLE fact_table;
IF OBJECT_ID('customer_dim', 'U') IS NOT NULL DROP TABLE customer_dim;
IF OBJECT_ID('item_dim', 'U') IS NOT NULL DROP TABLE item_dim;
IF OBJECT_ID('store_dim', 'U') IS NOT NULL DROP TABLE store_dim;
IF OBJECT_ID('time_dim', 'U') IS NOT NULL DROP TABLE time_dim;
IF OBJECT_ID('payment_dim', 'U') IS NOT NULL DROP TABLE payment_dim;
GO

-- 2. Create Dimension Tables
CREATE TABLE customer_dim (
    coustomer_key VARCHAR(50) PRIMARY KEY,
    name VARCHAR(255),
    contact_no VARCHAR(100),
    nid VARCHAR(50)
);

CREATE TABLE item_dim (
    item_key VARCHAR(50) PRIMARY KEY,
    item_name VARCHAR(255),
    description VARCHAR(MAX),
    unit_price NUMERIC(10, 2),
    man_country VARCHAR(100),
    supplier VARCHAR(255),
    unit VARCHAR(100)
);

CREATE TABLE store_dim (
    store_key VARCHAR(50) PRIMARY KEY,
    country VARCHAR(100),
    city VARCHAR(100),
    upazila VARCHAR(100)
);

CREATE TABLE time_dim (
    time_key VARCHAR(50) PRIMARY KEY,
    date VARCHAR(50),
    hour INT,
    day VARCHAR(20),
    week INT,
    month INT,
    quarter VARCHAR(10),
    year INT
);

CREATE TABLE payment_dim (
    payment_key VARCHAR(50) PRIMARY KEY,
    trans_type VARCHAR(50),
    bank_name VARCHAR(100)
);

-- 3. Create Fact Table
CREATE TABLE fact_table (
    fact_id INT IDENTITY(1,1) PRIMARY KEY,
    payment_key VARCHAR(50),
    customer_key VARCHAR(50),
    time_key VARCHAR(50),
    item_key VARCHAR(50),
    store_key VARCHAR(50),
    quantity INT,
    unit VARCHAR(50),
    unit_price NUMERIC(10, 2),
    total_price NUMERIC(12, 2)
);
GO

-- 4. Create Performance Indexes
CREATE INDEX idx_fact_customer ON fact_table(customer_key);
CREATE INDEX idx_fact_item ON fact_table(item_key);
CREATE INDEX idx_fact_time ON fact_table(time_key);
CREATE INDEX idx_fact_store ON fact_table(store_key);
CREATE INDEX idx_fact_payment ON fact_table(payment_key);
GO