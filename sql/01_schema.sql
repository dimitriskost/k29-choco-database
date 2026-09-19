-- ----------------------------------------------------------------------------
-- 1. DATABASE SCHEMA DEFINITION (DDL)
-- ----------------------------------------------------------------------------

DROP TABLE IF EXISTS ORDER_DETAILS CASCADE;
DROP TABLE IF EXISTS ORDERS CASCADE;
DROP TABLE IF EXISTS PRODUCTS CASCADE;
DROP TABLE IF EXISTS CUSTOMERS CASCADE;

CREATE TABLE CUSTOMERS (
    cust_no INT PRIMARY KEY,
    cust_name VARCHAR(100) NOT NULL,
    street VARCHAR(100),
    number INT,
    town VARCHAR(100),
    postcode CHAR(5),
    cr_limit NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    curr_balance NUMERIC(10, 2) NOT NULL DEFAULT 0.00
);

CREATE TABLE PRODUCTS (
    prod_code VARCHAR(20) PRIMARY KEY,
    description TEXT,
    prod_origin CHAR(2) CHECK (prod_origin IN ('SA', 'CA', 'WA', 'EA', 'AS')),
    list_price NUMERIC(7, 2) NOT NULL,
    qty_on_hand INT NOT NULL DEFAULT 0,
    reorder_level INT NOT NULL DEFAULT 0,
    reorder_qty INT NOT NULL DEFAULT 0
);

CREATE TABLE ORDERS (
    order_no INT PRIMARY KEY,
    order_date DATE NOT NULL,
    cust_no INT,
    FOREIGN KEY (cust_no) REFERENCES CUSTOMERS(cust_no)
);

CREATE TABLE ORDER_DETAILS (
    order_no INT NOT NULL,
    prod_code VARCHAR(20) NOT NULL,
    order_qty INT NOT NULL CHECK (order_qty >= 10),
    order_price NUMERIC(7, 2) NOT NULL,
    PRIMARY KEY (order_no, prod_code),
    FOREIGN KEY (order_no) REFERENCES ORDERS(order_no),
    FOREIGN KEY (prod_code) REFERENCES PRODUCTS(prod_code)
);




