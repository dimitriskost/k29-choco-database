-- ----------------------------------------------------------------------------
-- 2. BUSINESS QUERIES
-- ----------------------------------------------------------------------------

-- Question 1:
-- Names of all clients ordered by outstanding debt in descending order.
SELECT C.cust_name
FROM CUSTOMERS C
ORDER BY C.curr_balance DESC;


-- Question 2:
-- Product codes that must be reordered due to insufficient stock.
SELECT P.prod_code
FROM PRODUCTS P
WHERE P.qty_on_hand < P.reorder_level;


-- Question 3:
-- Names of all clients that ordered 'Almond-Choco' in April 2025.
SELECT DISTINCT C.cust_name
FROM CUSTOMERS C
JOIN ORDERS O ON C.cust_no = O.cust_no
JOIN ORDER_DETAILS D ON O.order_no = D.order_no
JOIN PRODUCTS P ON D.prod_code = P.prod_code
WHERE O.order_date >= '2025-04-01' 
  AND O.order_date <= '2025-04-30' 
  AND P.description LIKE 'Almond-Choco%';


-- Question 4:
-- Product code, order number, and order date for orders with order_qty > reorder_qty.
SELECT D.prod_code, O.order_no, O.order_date 
FROM ORDER_DETAILS D
JOIN ORDERS O ON D.order_no = O.order_no
JOIN PRODUCTS P ON D.prod_code = P.prod_code
WHERE D.order_qty > P.reorder_qty;


-- Question 5:
-- Value and order number of the best order for 'OrangeChoco' chocolate.
-- Used ILIKE pattern to match both 'OrangeChoco' and 'Orange-Choco'.
SELECT (D.order_price * D.order_qty) AS total_value, O.order_no
FROM ORDERS O
JOIN ORDER_DETAILS D ON O.order_no = D.order_no
JOIN PRODUCTS P ON D.prod_code = P.prod_code
WHERE P.description ILIKE '%Orange%Choco%'
  AND (D.order_price * D.order_qty) = (
      SELECT MAX(D2.order_price * D2.order_qty)
      FROM ORDER_DETAILS D2
      JOIN PRODUCTS P2 ON D2.prod_code = P2.prod_code
      WHERE P2.description ILIKE '%Orange%Choco%'
  );


-- Question 6:
-- Cities where the clients' average credit limit is greater than 9,000.
SELECT C.town
FROM CUSTOMERS C
GROUP BY C.town
HAVING AVG(C.cr_limit) > 9000;


-- Question 7:
-- Smallest and largest order value per product code.
SELECT D.prod_code, 
       MIN(D.order_qty * D.order_price) AS min_order_value, 
       MAX(D.order_qty * D.order_price) AS max_order_value
FROM ORDER_DETAILS D
GROUP BY D.prod_code;


-- Question 8:
-- Days of June 2025 where total received order value exceeded 35,000.
SELECT O.order_date
FROM ORDERS O
JOIN ORDER_DETAILS D ON O.order_no = D.order_no
WHERE O.order_date >= '2025-06-01' 
  AND O.order_date <= '2025-06-30'
GROUP BY O.order_date
HAVING SUM(D.order_qty * D.order_price) > 35000;


-- Question 9:
-- Product code, origin, and distinct customer count for products ordered in January 2024.
SELECT P.prod_code, P.prod_origin, COUNT(DISTINCT O.cust_no) AS num_customers
FROM PRODUCTS P
JOIN ORDER_DETAILS D ON P.prod_code = D.prod_code
JOIN ORDERS O ON D.order_no = O.order_no
WHERE O.order_date >= '2024-01-01' 
  AND O.order_date <= '2024-01-31'
GROUP BY P.prod_code, P.prod_origin;


-- Question 10:
-- Product codes with the highest restocking cost (reorder_qty * list_price).
SELECT P.prod_code 
FROM PRODUCTS P
WHERE (P.reorder_qty * P.list_price) = (
    SELECT MAX(P2.reorder_qty * P2.list_price)
    FROM PRODUCTS P2
);


-- Question 11:
-- Date of the overall largest order (sum of all items per order).
SELECT O.order_date
FROM ORDERS O
JOIN ORDER_DETAILS D ON O.order_no = D.order_no
GROUP BY O.order_no, O.order_date
HAVING SUM(D.order_qty * D.order_price) = (
    SELECT MAX(order_total)
    FROM (
        SELECT SUM(D2.order_qty * D2.order_price) AS order_total
        FROM ORDER_DETAILS D2
        GROUP BY D2.order_no
    ) sub
);


-- Question 12:
-- Names of clients who placed no orders in February 2025.
SELECT C.cust_name
FROM CUSTOMERS C
WHERE NOT EXISTS (
    SELECT 1
    FROM ORDERS O
    WHERE O.cust_no = C.cust_no
      AND O.order_date >= '2025-02-01'
      AND O.order_date <= '2025-02-28'
);


-- Question 13:
-- Names of clients who placed orders on August 12th, 2025.
SELECT DISTINCT C.cust_name
FROM CUSTOMERS C
JOIN ORDERS O ON C.cust_no = O.cust_no
WHERE O.order_date = '2025-08-12';


-- Question 14:
-- Place of origin representing the maximum total value of available inventory.
SELECT P1.prod_origin
FROM PRODUCTS P1
GROUP BY P1.prod_origin
HAVING SUM(P1.qty_on_hand * P1.list_price) >= ALL (
    SELECT SUM(P2.qty_on_hand * P2.list_price)
    FROM PRODUCTS P2
    GROUP BY P2.prod_origin
);


-- Question 15:
-- Product code and description for products sold below list price.
SELECT DISTINCT P.prod_code, P.description
FROM PRODUCTS P
JOIN ORDER_DETAILS D ON P.prod_code = D.prod_code
WHERE D.order_price < P.list_price;


-- Question 16:
-- Orders without an associated customer (Referential Integrity check).
-- Single ANSI LEFT JOIN query safely captures NULLs and orphan records.
SELECT O.*
FROM ORDERS O
LEFT JOIN CUSTOMERS C ON O.cust_no = C.cust_no
WHERE C.cust_no IS NULL;


-- Question 17:
-- Customers who have never placed an order.
SELECT C.*
FROM CUSTOMERS C
LEFT JOIN ORDERS O ON C.cust_no = O.cust_no
WHERE O.order_no IS NULL;


-- Question 18:
-- Products ordered in April 2024 OR ordered at least twice in May 2025.
SELECT DISTINCT P.prod_code, P.description
FROM PRODUCTS P
JOIN ORDER_DETAILS D ON P.prod_code = D.prod_code
JOIN ORDERS O ON D.order_no = O.order_no
WHERE O.order_date >= '2024-04-01' 
  AND O.order_date <= '2024-04-30'
UNION
SELECT P.prod_code, P.description
FROM PRODUCTS P
JOIN ORDER_DETAILS D ON P.prod_code = D.prod_code
JOIN ORDERS O ON D.order_no = O.order_no
WHERE O.order_date >= '2025-05-01' 
  AND O.order_date <= '2025-05-31'
GROUP BY P.prod_code, P.description
HAVING COUNT(*) >= 2;


-- Question 19:
-- Product descriptions and customer names for orders placed by clients in Xanthi.
SELECT DISTINCT P.description, C.cust_name
FROM CUSTOMERS C
JOIN ORDERS O ON C.cust_no = O.cust_no
JOIN ORDER_DETAILS D ON O.order_no = D.order_no
JOIN PRODUCTS P ON D.prod_code = P.prod_code
WHERE C.town = 'Ξάνθη';


-- Question 20:
-- Maximum value by which a customer exceeds their assigned credit limit.
SELECT MAX(C.curr_balance - C.cr_limit) AS exceding_value
FROM CUSTOMERS C
WHERE C.curr_balance > C.cr_limit;