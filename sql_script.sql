----------------------------------
-  CREATION OF THE SILVER LAYER  -
----------------------------------
CREATE TABLE orders_clean
WITH (
  format            = 'PARQUET',
  external_location = 's3://mon-datalake-ecommerce-<suffix>/silver/orders/',
  write_compression = 'SNAPPY'
  partitioned_by = ARRAY['order_date']
)
AS
SELECT
  invoiceno,
  TRY_CAST(productid   AS BIGINT)        AS product_id,
  TRY_CAST(quantity    AS INT)           AS quantity,
  TRY_CAST(unitprice   AS DECIMAL(10,2)) AS unit_price,
  TRY_CAST(unitprice AS DECIMAL(10,2)) * TRY_CAST(quantity AS INT) AS line_amount,
  TRY_CAST(customerid  AS BIGINT)        AS customer_id,
  CASE
    WHEN UPPER(TRIM(country)) IN ('USA', 'US', 'U.S.A') THEN 'United States'
    WHEN UPPER(TRIM(country)) IN ('UK', 'U.K.') THEN 'United Kingdom'
    WHEN UPPER(TRIM(country)) = 'FRNACE' THEN 'France'
    WHEN UPPER(TRIM(country)) = 'ITALIE' THEN 'Italy'
    WHEN UPPER(TRIM(country)) = 'ESPAGNE' THEN 'Spain'
    WHEN UPPER(TRIM(country)) = 'SUISSE' THEN 'Switzerland'
    WHEN UPPER(TRIM(country)) = 'ALLEMAGNE' THEN 'Germany'
    WHEN UPPER(TRIM(country)) = 'PAYS-BAS' THEN 'Netherlands'
    WHEN UPPER(TRIM(country)) = 'BELGIQUE' THEN 'Belguim'
    ELSE regexp_replace(country, '(\w)(\w*)', x -> UPPER(x[1]) || LOWER(x[2]))
  END AS country,
  CASE WHEN invoiceno LIKE 'C%' THEN TRUE ELSE FALSE END AS is_return,
  TRY_CAST(invoicedate AS TIMESTAMP) AS invoice_date
FROM orders
WHERE invoiceno IS NOT NULL
  AND TRY_CAST(quantity AS INT) IS NOT NULL
  AND TRY_CAST(invoicedate AS TIMESTAMP) IS NOT NULL;


CREATE OR REPLACE TABLE products_clean
WITH (
  format            = 'PARQUET',
  external_location = 's3://mon-datalake-ecommerce-<suffix>/silver/products/',
  write_compression = 'SNAPPY'
)
AS
SELECT
id as product_id,
title,
category,
brand,
price as catalog_price,
round(price - price * discountpercentage / 100, 2) AS discounted_price,
stock,
dimensions.width AS width,
dimensions.height AS height,
dimensions.depth AS depth
FROM products;

CREATE TABLE users_clean
WITH (
  format            = 'PARQUET',
  external_location = 's3://mon-datalake-ecommerce-<suffix>/silver/users/',
  write_compression = 'SNAPPY'
)
AS
SELECT
id AS customer_id,
firstname,
lastname,
email,
address.city,
address.country,
company.name AS company_name
FROM users;

----------------------------------
-  CREATION OF THE GOLD LAYER  -
----------------------------------
CREATE TABLE dim_date
WITH (
    format              = 'PARQUET',
    external_location   = 's3://mon-datalake-ecommerce-eef256/gold/dim_date/',
    write_compression   = 'SNAPPY'
)
AS
SELECT
  CAST(date_format(d, '%Y%m%d') AS INTEGER) AS date_id,
  CAST(d AS TIMESTAMP) AS full_date,
  year(d) AS year,
  month(d) AS month,
  date_format(d, '%M') AS month_name,
  day_of_week(d) AS day,
  quarter(d) AS quarter
FROM UNNEST(sequence(DATE '2026-01-01', DATE '2026-12-31', INTERVAL '1' DAY)) AS t(d);

CREATE TABLE dim_customers
WITH (
    format='PARQUET',
    write_compression='SNAPPY',
    external_location='s3://mon-datalake-ecommerce-eef256/gold/dim_customers/'
)
AS
SELECT customer_id, firstname, lastname, email, city, country, company_name
FROM users_clean
UNION ALL
SELECT -1, 'Unknown', 'Unknown', 'Unknown', 'Unknown', 'Unknown', 'Unknown';

CREATE TABLE dim_products
WITH (
    format='PARQUET',
    write_compression='SNAPPY',
    external_location='s3://mon-datalake-ecommerce-eef256/gold/dim_products/'
)
AS
SELECT product_id, title, category, brand, catalog_price, discounted_price
FROM products_clean
UNION ALL
SELECT -1, 'Unknown', 'Unknown', 'Unknown', CAST(NULL AS DECIMAL(10,2)), CAST(NULL AS DECIMAL(10,2));

CREATE TABLE fact_sales
WITH (
  format            = 'PARQUET',
  external_location = 's3://mon-datalake-ecommerce-eef256/gold/fact_sales/',
  write_compression = 'SNAPPY'
)
AS
SELECT
  o.invoiceno,
  COALESCE(p.product_id, -1) AS product_id,
  COALESCE(u.customer_id, -1) AS customer_id,
  COALESCE(d.date_id, -1) AS date_id,
  (o.customer_id IS NULL) AS is_guest_order,
  (p.product_id IS NULL) AS product_orphan,
  (o.customer_id IS NOT NULL AND u.customer_id IS NULL) AS customer_orphan,
  (d.date_id IS NULL) AS date_orphan,
  o.invoice_date,
  o.country,
  o.is_return,
  o.quantity,
  o.unit_price,
  o.line_amount
FROM orders_clean o
LEFT JOIN products_clean p ON o.product_id  = p.product_id
LEFT JOIN users_clean    u ON o.customer_id = u.customer_id
LEFT JOIN dim_date       d ON CAST(o.invoice_date AS DATE) = d.full_date;