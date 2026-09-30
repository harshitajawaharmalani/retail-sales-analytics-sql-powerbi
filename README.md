# Enterprise Retail Revenue & Multi-Branch Logistics Pipeline

An end-to-end analytics project on a retail **star schema** (1 fact table + 5 dimension tables, ~500K transactions). Raw CSVs are loaded into **SQL Server** with a validated ETL process, analyzed with **T-SQL**, and presented in an interactive **Power BI** dashboard.

![Dashboard](powerbi/dashboard.png)

## Project Overview

The goal is to answer core business questions for a multi-branch retailer:

- Which cities, stores and products drive the most revenue?
- Who are the highest-spending and most frequent customers?
- How do sales change over time (month, year, trend)?
- Which payment methods do customers prefer?

## Tech Stack

| Layer | Tools |
|---|---|
| Database | Microsoft SQL Server (T-SQL) |
| ETL | `BULK INSERT`, staging tables, `TRY_CAST` |
| Analysis | Joins, aggregations, star-schema queries |
| Visualization | Power BI |

## Data Model

Star schema with one fact table and five dimensions:

```
customer_dim ─┐
item_dim ─────┤
store_dim ────┼──── fact_table (quantity, unit_price, total_price)
time_dim ─────┤
payment_dim ──┘
```

| Table | Key columns |
|---|---|
| `fact_table` | payment_key, customer_key, time_key, item_key, store_key, quantity, unit_price, total_price |
| `customer_dim` | customer key, name, contact_no, nid |
| `item_dim` | item_key, item_name, description (category), unit_price, man_country, supplier |
| `store_dim` | store_key, country, city, upazila |
| `time_dim` | time_key, date, hour, day, week, month, quarter, year |
| `payment_dim` | payment_key, trans_type (card / cash / mobile), bank_name |

## ETL & Data Quality Steps

1. **Schema design:** created dimension and fact tables with primary keys and indexes on every foreign-key column.
2. **Staging tables:** loaded `time_dim` and `fact_table` through temp staging tables so data types could be converted safely with `TRY_CAST`.
3. **Cleaning currency values:** stripped `$` and `,` characters from price columns before casting to `NUMERIC`.
4. **Quoted CSV handling:** reloaded `item_dim` with `FORMAT = 'CSV'` because product descriptions contain commas.
5. **Missing keys:** found item keys in the fact table with no match in `item_dim` and added placeholder rows so no transactions were dropped.
6. **Referential integrity:** added foreign keys only after validation, and ran orphan-record checks (`03_verification.sql`).

## Key Numbers (from the dashboard)

- **~500K** total orders
- **~3M** units sold
- **52.73M** total revenue
- Date range: **Jan 2014 to Jan 2021**
- **Dhaka** is the top city by revenue, followed by Chittagong and Khulna
- **Card** is the most-used payment type, followed by mobile and cash

## Dashboard Features

- KPI cards: total orders, total quantity, total revenue
- Date range slider and product-category filter
- Revenue by city, top customers, top products
- Revenue by category split by payment type
- Transactions by payment type

## Repository Structure

```
├── README.md
├── .gitignore
├── powerbi/
│   ├── dashboard.png              # dashboard screenshot
│   └── Ecomm_sales_dashboard.pbix # Power BI file
├── data/                          # CSVs not included (see Dataset)
└── sql/
    ├── 01_schema_ddl.sql          # tables, keys, indexes
    ├── 02_load_data.sql           # ETL / bulk load
    ├── 03_verification.sql        # row counts, orphan checks, item_dim reload
    └── 04_queries.sql             # business analysis queries
```

## How to Run

1. Download the dataset (see below) and place the CSVs in `data/`.
2. Create a database: `CREATE DATABASE ecommerce_db;`
3. Update the file paths in `sql/02_load_data.sql` and `sql/03_verification.sql`.
4. Run the scripts in order: `01` → `02` → `03` → `04`.
5. Open `powerbi/Ecomm_sales_dashboard.pbix` in Power BI Desktop and point the data source to your `ecommerce_db` (Transform data → Data source settings), or connect a new report to the database.

## Dataset

Source: **"ECommerce Data Analysis"** dataset on Kaggle (6 tables: 1 fact, 5 dimensions).
Link: `<https://www.kaggle.com/datasets/mmohaiminulislam/ecommerce-data-analysis>`

The dataset is publicly available and credited to its original author. The SQL scripts, ETL process and dashboard in this repo are my own work built on top of it.

## Author

**<Your Name>**
[LinkedIn](<https://www.linkedin.com/in/harshita-jawaharmalani-2568b32aa>) · [GitHub](<https://github.com/harshitajawaharmalani>)