#!/usr/bin/env bash
# ==============================================================================
# Description: Automated database provisioning, schema deployment,
#              ELT staging cleaning, and verification audit.
# ==============================================================================

set -e

# Configuration
export PGHOST="${PGHOST:-localhost}"
export PGPORT="${PGPORT:-5432}"
export PGUSER="${PGUSER:-postgres}"
DB_NAME="choco_k29"

echo "==> [1/5] Checking file paths and environment..."

# Relocate CSV files to data/raw/ if found in root or Project2-TestSet01
mkdir -p data/raw
for file in CUSTOMER-data.csv PRODUCT-data.csv ORDERS-data.csv ORDER_DEATILS-data.csv; do
    if [ -f "$file" ] && [ ! -f "data/raw/$file" ]; then
        mv "$file" data/raw/
    elif [ -f "Project2-TestSet01/$file" ] && [ ! -f "data/raw/$file" ]; then
        cp "Project2-TestSet01/$file" data/raw/
    fi
done

# Verify CSV availability in data/raw
for file in CUSTOMER-data.csv PRODUCT-data.csv ORDERS-data.csv ORDER_DEATILS-data.csv; do
    if [ ! -f "data/raw/$file" ]; then
        echo "ERROR: Missing required data file: data/raw/$file"
        exit 1
    fi
done

echo "==> [2/5] Initializing Database: ${DB_NAME}..."
# Drop existing active connections and recreate target database
psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d postgres -c "DROP DATABASE IF EXISTS ${DB_NAME} WITH (FORCE);"
psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d postgres -c "CREATE DATABASE ${DB_NAME};"

echo "==> [3/5] Applying DDL Schema (01_schema.sql)..."
psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$DB_NAME" -f sql/01_schema.sql

echo "==> [4/5] Executing Staging & Ingestion Pipeline (02_staging_and_load.sql)..."
# Execute inside data/raw so \copy resolves relative file paths properly
(cd data/raw && psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$DB_NAME" -f ../../sql/02_staging_and_load.sql)

echo "==> [5/5] Verifying Target Entity Counts..."
psql -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -d "$DB_NAME" -c "
SELECT 
    (SELECT COUNT(*) FROM CUSTOMERS)     AS customers,      -- Expected: 1000
    (SELECT COUNT(*) FROM PRODUCTS)      AS products,       -- Expected: 100
    (SELECT COUNT(*) FROM ORDERS)        AS orders,         -- Expected: 4900
    (SELECT COUNT(*) FROM ORDER_DETAILS) AS order_details;  -- Expected: 14752
"

echo "Database '${DB_NAME}' provisioned and loaded successfully!"