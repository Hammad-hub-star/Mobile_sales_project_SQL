-- ============================================================
-- PROJECT  : Pakistan Mobile Sales Analysis
-- FILE     : schema.sql
-- PURPOSE  : Create the main table for mobile sales data
-- DATABASE : PostgreSQL
-- AUTHOR   : Hammad
-- ============================================================


-- Step 1: Create the database (run this in pgAdmin separately)
-- CREATE DATABASE mobile_sales_db;


-- Step 2: Create the main table

CREATE TABLE mobile_sales (
    transaction_id   INT            PRIMARY KEY,   -- Unique ID for each sale
    day_name         VARCHAR(15),                  -- Day of week (Monday, Tuesday...)
    brand            VARCHAR(50)    NOT NULL,       -- Mobile brand name
    units_sold       INT            NOT NULL,       -- Number of units sold
    price_per_unit   NUMERIC(10, 2) NOT NULL,       -- Price of one unit in PKR
    customer_name    VARCHAR(100),                  -- Customer full name
    customer_age     INT,                           -- Customer age in years
    city             VARCHAR(50),                   -- City of sale
    payment_method   VARCHAR(30),                   -- Cash / Easypaisa / JazzCash / etc
    customer_ratings INT,                           -- Rating given by customer (1 to 5)
    mobile_model     VARCHAR(100),                  -- Specific model name
    sale_date        DATE                           -- Date of transaction
);


-- Step 3: Verify table was created
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'mobile_sales'
ORDER BY ordinal_position;


-- ============================================================
-- HOW TO IMPORT CSV DATA (pgAdmin 4)
-- ============================================================
-- 1. Right click on 'mobile_sales' table in pgAdmin
-- 2. Select 'Import/Export Data'
-- 3. Choose your CSV file
-- 4. Set Format: CSV
-- 5. Turn ON Header toggle (first row is column names)
-- 6. Set Delimiter: comma (,)
-- 7. Click OK
-- ============================================================


-- Step 4: Quick check after import
SELECT COUNT(*)   AS total_rows    FROM mobile_sales;
SELECT MIN(sale_date) AS start_date,
       MAX(sale_date) AS end_date  FROM mobile_sales;