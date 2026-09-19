-- ==============================================================================
-- Script: 02_staging_and_load.sql
-- Description: Temporary staging tables and ELT transformation pipeline.
--              Clears quotes, decimal commas, whitespaces, and handles NULLs.
-- ==============================================================================

-- ------------------------------------------------------------------------------
-- 1. CUSTOMERS
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS staging_customers;

CREATE TEMP TABLE staging_customers (
    cust_no      TEXT,
    cust_name    TEXT,
    street       TEXT,
    number       TEXT,
    town         TEXT,
    postcode     TEXT,
    cr_limit     TEXT,
    curr_balance TEXT
);

\copy staging_customers FROM 'CUSTOMER-data.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

INSERT INTO CUSTOMERS (cust_no, cust_name, street, number, town, postcode, cr_limit, curr_balance)
SELECT 
    BTRIM(cust_no, ' ''')::INT,
    BTRIM(cust_name, ' '''),
    BTRIM(street, ' '''),
    NULLIF(BTRIM(number, ' '''), '')::INT,
    BTRIM(town, ' '''),
    BTRIM(postcode, ' '''),
    REPLACE(BTRIM(cr_limit, ' '''), ',', '.')::NUMERIC(10, 2),
    REPLACE(BTRIM(curr_balance, ' '''), ',', '.')::NUMERIC(10, 2)
FROM staging_customers;

DROP TABLE staging_customers;


-- ------------------------------------------------------------------------------
-- 2. PRODUCTS
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS staging_products;

CREATE TEMP TABLE staging_products (
    prod_code     TEXT,
    description   TEXT,
    prod_origin   TEXT,
    list_price    TEXT,
    qty_on_hand   TEXT,
    reorder_level TEXT,
    reorder_qty   TEXT
);

\copy staging_products FROM 'PRODUCT-data.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

INSERT INTO PRODUCTS (prod_code, description, prod_origin, list_price, qty_on_hand, reorder_level, reorder_qty)
SELECT 
    BTRIM(prod_code, ' '''),
    BTRIM(description, ' '''),
    BTRIM(prod_origin, ' '''),
    REPLACE(BTRIM(list_price, ' '''), ',', '.')::NUMERIC(7, 2),
    BTRIM(qty_on_hand, ' ''')::INT,
    BTRIM(reorder_level, ' ''')::INT,
    BTRIM(reorder_qty, ' ''')::INT
FROM staging_products;

DROP TABLE staging_products;


-- ------------------------------------------------------------------------------
-- 3. ORDERS
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS staging_orders;

CREATE TEMP TABLE staging_orders (
    order_no   TEXT,
    order_date TEXT,
    cust_no    TEXT
);

\copy staging_orders FROM 'ORDERS-data.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

INSERT INTO ORDERS (order_no, order_date, cust_no)
SELECT 
    BTRIM(order_no, ' ''')::INT,
    CASE 
        WHEN BTRIM(order_date, ' ''') ~ '^\d{4}-\d{2}-\d{2}$' THEN BTRIM(order_date, ' ''')::DATE
        ELSE TO_DATE(BTRIM(order_date, ' '''), 'DD-MM-YYYY')
    END,
    NULLIF(BTRIM(cust_no, ' '''), '')::INT
FROM staging_orders;

DROP TABLE staging_orders;


-- ------------------------------------------------------------------------------
-- 4. ORDER_DETAILS
-- ------------------------------------------------------------------------------
DROP TABLE IF EXISTS staging_order_details;

CREATE TEMP TABLE staging_order_details (
    order_no    TEXT,
    prod_code   TEXT,
    order_qty   TEXT,
    order_price TEXT
);

\copy staging_order_details FROM 'ORDER_DEATILS-data.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',');

INSERT INTO ORDER_DETAILS (order_no, prod_code, order_qty, order_price)
SELECT 
    BTRIM(order_no, ' ''')::INT,
    BTRIM(prod_code, ' '''),
    BTRIM(order_qty, ' ''')::INT,
    REPLACE(BTRIM(order_price, ' '''), ',', '.')::NUMERIC(7, 2)
FROM staging_order_details;

DROP TABLE staging_order_details;