# K29Choco - Wholesale Database Design & Analytics

A robust, relational database system and analytical query suite designed for a B2B chocolate wholesale supplier. Developed as the second project for the "K29 - Design and Use of Databases" course at the National and Kapodistrian University of Athens (NKUA).

## Overview

K29Choco models the end-to-end supply chain and commercial operations of a wholesale chocolate distributor serving industrial sweets facilities, bakeries, and boutique chocolatiers. The system tracks inventory thresholds, order fulfillment, and client balances under strict relational constraints. Designed for PostgreSQL, the project emphasizes data integrity, robust staging/ELT data cleansing, and mathematically sound query design resilient to outlier anomalies.

## Tech Stack

* Database: PostgreSQL 
* Automation & Scripting: Bash (Shell Scripting)
* Environment: Linux (WSL Ubuntu)
* Tools: psql CLI, VS Code PostgreSQL Client Extension
* Languages: SQL 

## Key Features and Architecture

Rather than treating database design purely in the abstract, this implementation focuses on clean data, schema-level enforcement, and semantic accuracy:

* Resilient ELT & Staging Architecture: Direct bulk-loading was hardened by introducing temporary staging tables with string domains. Incoming data is dynamically cleaned using `BTRIM()` to strip outer single quotes (`'WA'`, `'Almond-Choco'`), `REPLACE()` to normalize comma-separated decimals into IEEE/standard dots, and whitespace truncation for strict `CHAR(5)` postcode definitions.
* Safe Anti-Filtering: Addressed subtle data anomalies—specifically `order_no = 108` with a `NULL` customer reference, which caused classical `NOT IN` predicates to fail due to SQL Three-Valued Logic. Anti-filtering logic is enforced via Left Anti-Joins (`LEFT JOIN ... WHERE target.key IS NULL`) to maintain deterministic, null-safe evaluations.
* Deterministic Time Filtering: Date operations intentionally avoid local time formatting (`DD-MM-YYYY` vs `MM-DD-YYYY`) in favor of mathematical interval bounding (`>=` and `<=`) against ISO standards (`YYYY-MM-DD`), guaranteeing portability across varying database locations.
* Fault-Tolerant String Matching: Queries targeting specific product varieties leverage case-insensitive pattern matching (`ILIKE`) and wildcards to guard against naming variations and dirty ingest formatting.

## Database Schema

The database is built on 4 core relational entities structured in Third Normal Form (3NF):

1. `CUSTOMERS`: Stores business details, postal routing, credit limits (`cr_limit`), and outstanding balances (`curr_balance`).
2. `PRODUCTS`: Inventory management relation tracking origins (`CHECK` constraint for regional codes `'SA'`, `'CA'`, `'WA'`, `'EA'`, `'AS'`), stock on hand, and reorder trigger levels.
3. `ORDERS`: Historical ordering events linking clients to transactions (1:N).
4. `ORDER_DETAILS`: M:N composite link table capturing line-item quantities (`CHECK (order_qty >= 10)`) and agreed billing prices.

## Repository Structure

* `setup.sh`: Automated bash script handling database provisioning, schema build, and staging ingestion.
* `sql/`: Database scripts directory.
  * `01_schema.sql`: DDL table creation and domain constraints.
  * `02_staging_and_load.sql`: Staging definitions, ELT process, and `\copy` pipelines.
  * `03_queries.sql`: The 20 analytical business queries (ANSI SQL-92 compliant).
* `data/raw/`: Original, immutable raw CSV datasets.
  * `CUSTOMER-data.csv`
  * `ORDER_DEATILS-data.csv`
  * `ORDERS-data.csv`
  * `PRODUCT-data.csv`
* `docs/`: Project documentation and diagram assets.
  * `er_diagram.png`: Entity-Relationship diagram.
  * `Project2_Requirements.pdf`: Official project specifications.
  * `K29_Choco_Report.pdf`: System implementation report.

## Installation and Setup

This project requires a Unix-like environment (Linux / WSL / macOS) and an active local PostgreSQL server.

1. Clone the repository:
```bash
git clone https://github.com/dimitriskost/k29-choco-database.git
cd k29-choco-database
```

2. Execute the Automated Setup:
Ensure the raw CSV datasets reside in `data/raw/` (or the project root). Run the setup script to provision the database, compile the schema, and clean-load all records:
```bash
chmod +x setup.sh
./setup.sh
```

3. Verification of Ingested Records:
Connect via `psql` to verify the total row counts match expected domain volumes:
```sql
SELECT 
    (SELECT COUNT(*) FROM CUSTOMERS)     AS customers,      -- Expected: 1000
    (SELECT COUNT(*) FROM PRODUCTS)      AS products,       -- Expected: 100
    (SELECT COUNT(*) FROM ORDERS)        AS orders,         -- Expected: 4900
    (SELECT COUNT(*) FROM ORDER_DETAILS) AS order_details;  -- Expected: 14752
```

4. Execute Business Queries:
Execute the analytical query suite against the database:
```bash
psql -h localhost -U postgres -d choco_k29 -f sql/03_queries.sql
```

## Author

Dimitrios Kostinis  
Undergraduate Student at Department of Mathematics, NKUA.