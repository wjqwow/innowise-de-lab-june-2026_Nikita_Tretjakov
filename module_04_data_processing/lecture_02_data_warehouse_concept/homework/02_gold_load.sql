BEGIN;

-- 0. Записываем начало загрузки в журнал.
INSERT INTO gold.etl_run (process_name) VALUES ('silver_to_gold');

-- 1. ЛОКАЦИИ (город + страна). Сначала обновляем уже известные города.
UPDATE gold.dim_location l
SET country_id = c.country_id,
    country_name = c.country_name,
    country_code = upper(c.country_code),
    city_name = ci.city_name,
    zipcode = ci.zipcode::varchar(20)
FROM silver.silver_cities ci
JOIN silver.silver_countries c ON c.country_id = ci.country_id
WHERE l.city_id = ci.city_id;

-- Затем добавляем только новые города:
INSERT INTO gold.dim_location (country_id, city_id, country_name, country_code, city_name, zipcode)
SELECT c.country_id, ci.city_id, c.country_name, upper(c.country_code), ci.city_name, ci.zipcode::varchar(20)
FROM silver.silver_cities ci
JOIN silver.silver_countries c ON c.country_id = ci.country_id
WHERE NOT EXISTS (SELECT 1 FROM gold.dim_location l WHERE l.city_id = ci.city_id);

-- 2. КАТЕГОРИИ.
UPDATE gold.dim_category d
SET category_name = s.category_name
FROM silver.silver_categories s
WHERE d.category_id = s.category_id;

INSERT INTO gold.dim_category (category_id, category_name)
SELECT s.category_id, s.category_name
FROM silver.silver_categories s
WHERE NOT EXISTS (SELECT 1 FROM gold.dim_category d WHERE d.category_id = s.category_id);

-- 3. МАГАЗИНЫ.
UPDATE gold.dim_shop d
SET location_key = l.location_key,
    shop_address = s.address
FROM silver.silver_shops s
JOIN gold.dim_location l ON l.city_id = s.city_id
WHERE d.shop_id = s.shop_id;

INSERT INTO gold.dim_shop (shop_id, location_key, shop_address)
SELECT s.shop_id, l.location_key, s.address
FROM silver.silver_shops s
JOIN gold.dim_location l ON l.city_id = s.city_id
WHERE NOT EXISTS (SELECT 1 FROM gold.dim_shop d WHERE d.shop_id = s.shop_id);

-- 4. КЛИЕНТЫ.
UPDATE gold.dim_customer d
SET location_key = l.location_key,
    first_name = s.first_name,
    middle_initial = NULLIF(s.middle_initial, ''),
    last_name = s.last_name,
    customer_address = s.address
FROM silver.silver_customers s
JOIN gold.dim_location l ON l.city_id = s.city_id
WHERE d.customer_id = s.customer_id;

INSERT INTO gold.dim_customer (customer_id, location_key, first_name, middle_initial, last_name, customer_address)
SELECT s.customer_id, l.location_key, s.first_name, NULLIF(s.middle_initial, ''), s.last_name, s.address
FROM silver.silver_customers s
JOIN gold.dim_location l ON l.city_id = s.city_id
WHERE NOT EXISTS (SELECT 1 FROM gold.dim_customer d WHERE d.customer_id = s.customer_id);

-- 5. СОТРУДНИКИ.
UPDATE gold.dim_employee d
SET shop_key = sh.shop_key,
    first_name = s.first_name,
    middle_initial = NULLIF(s.middle_initial, ''),
    last_name = s.last_name,
    birth_date = s.birth_date::date,
    gender = NULLIF(s.gender, ''),
    hire_date = s.hire_date::date
FROM silver.silver_employees s
JOIN gold.dim_shop sh ON sh.shop_id = s.shop_id
WHERE d.employee_id = s.employee_id;

INSERT INTO gold.dim_employee (employee_id, shop_key, first_name, middle_initial, last_name, birth_date, gender, hire_date)
SELECT s.employee_id, sh.shop_key, s.first_name, NULLIF(s.middle_initial, ''), s.last_name,
       s.birth_date::date, NULLIF(s.gender, ''), s.hire_date::date
FROM silver.silver_employees s
JOIN gold.dim_shop sh ON sh.shop_id = s.shop_id
WHERE NOT EXISTS (SELECT 1 FROM gold.dim_employee d WHERE d.employee_id = s.employee_id);

-- 6. ТОВАРЫ (SCD Type 2).
UPDATE gold.dim_product d
SET valid_to_dt = COALESCE(s.modify_timestamp::timestamp, CURRENT_TIMESTAMP),
    is_current = false
FROM silver.silver_products s
JOIN gold.dim_category c ON c.category_id = s.category_id
WHERE d.product_id = s.product_id
  AND d.is_current = true
  AND (d.product_name, d.category_key, d.list_price, d.product_class, d.resistant, d.is_allergic, d.vitality_days)
      IS DISTINCT FROM
      (s.product_name, c.category_key, s.price::numeric(14,2), NULLIF(s.class, '')::varchar(10),
       CASE lower(s.resistant::text) WHEN 'yes' THEN true WHEN 'no' THEN false END,
       CASE lower(s.is_allergic::text) WHEN 'yes' THEN true WHEN 'no' THEN false END,
       s.vitality_days::integer);

INSERT INTO gold.dim_product (
    product_id, product_name, category_key, list_price, product_class, resistant, is_allergic,
    vitality_days, valid_from_dt, valid_to_dt, is_current)
SELECT s.product_id, s.product_name, c.category_key, s.price::numeric(14,2),
       NULLIF(s.class, '')::varchar(10),
       CASE lower(s.resistant::text) WHEN 'yes' THEN true WHEN 'no' THEN false END,
       CASE lower(s.is_allergic::text) WHEN 'yes' THEN true WHEN 'no' THEN false END,
       s.vitality_days::integer, COALESCE(s.modify_timestamp::timestamp, CURRENT_TIMESTAMP), NULL, true
FROM silver.silver_products s
JOIN gold.dim_category c ON c.category_id = s.category_id
WHERE NOT EXISTS (
    SELECT 1 FROM gold.dim_product d
    WHERE d.product_id = s.product_id AND d.is_current = true
);

-- 7. ДАТЫ, существующие в продажах.
INSERT INTO gold.dim_date (date_key, full_date, day_of_week, day_name, week_num, month_num, month_name, quarter_num, year_num)
SELECT DISTINCT to_char(s.sales_timestamp::date, 'YYYYMMDD')::integer, s.sales_timestamp::date,
       extract(isodow FROM s.sales_timestamp)::smallint, trim(to_char(s.sales_timestamp, 'Day')),
       extract(week FROM s.sales_timestamp)::smallint, extract(month FROM s.sales_timestamp)::smallint,
       trim(to_char(s.sales_timestamp, 'Month')), extract(quarter FROM s.sales_timestamp)::smallint,
       extract(year FROM s.sales_timestamp)::smallint
FROM silver.silver_sales s
WHERE NOT EXISTS (
    SELECT 1 FROM gold.dim_date d
    WHERE d.date_key = to_char(s.sales_timestamp::date, 'YYYYMMDD')::integer
);

-- 8. ВРЕМЯ, существующее в продажах.
INSERT INTO gold.dim_time (time_key, full_time, hour_num, minute_num, second_num, part_of_day)
SELECT DISTINCT
       extract(hour FROM s.sales_timestamp)::integer * 10000
       + extract(minute FROM s.sales_timestamp)::integer * 100
       + extract(second FROM s.sales_timestamp)::integer,
       s.sales_timestamp::time,
       extract(hour FROM s.sales_timestamp)::smallint,
       extract(minute FROM s.sales_timestamp)::smallint,
       extract(second FROM s.sales_timestamp)::smallint,
       CASE WHEN extract(hour FROM s.sales_timestamp) < 6 THEN 'Night'
            WHEN extract(hour FROM s.sales_timestamp) < 12 THEN 'Morning'
            WHEN extract(hour FROM s.sales_timestamp) < 18 THEN 'Afternoon'
            ELSE 'Evening' END
FROM silver.silver_sales s
WHERE NOT EXISTS (
    SELECT 1 FROM gold.dim_time d
    WHERE d.time_key = extract(hour FROM s.sales_timestamp)::integer * 10000
                     + extract(minute FROM s.sales_timestamp)::integer * 100
                     + extract(second FROM s.sales_timestamp)::integer
);

-- 9. ФАКТЫ ПРОДАЖ. Добавляются только новые sales_id, поэтому повторный запуск не создаёт дубликаты.
INSERT INTO gold.fact_sales (
    sales_id, transaction_number, date_key, time_key, product_key, customer_key, employee_key, shop_key,
    location_key, quantity, discount_pct, gross_revenue, discount_amount, net_revenue, estimated_cost, estimated_profit)
SELECT s.sales_id, s.transaction_number,
       to_char(s.sales_timestamp::date, 'YYYYMMDD')::integer,
       extract(hour FROM s.sales_timestamp)::integer * 10000
       + extract(minute FROM s.sales_timestamp)::integer * 100
       + extract(second FROM s.sales_timestamp)::integer,
       p.product_key, c.customer_key, e.employee_key, sh.shop_key, sh.location_key,
       s.quantity::integer, s.discount::numeric(5,4),
       round(s.total_price::numeric(14,2) / (1 - s.discount::numeric), 2),
       round(s.total_price::numeric(14,2) / (1 - s.discount::numeric), 2) - s.total_price::numeric(14,2),
       s.total_price::numeric(14,2),
       round(p.list_price * s.quantity::integer, 2),
       s.total_price::numeric(14,2) - round(p.list_price * s.quantity::integer, 2)
FROM silver.silver_sales s
JOIN gold.dim_product p ON p.product_id = s.product_id AND p.is_current = true
JOIN gold.dim_customer c ON c.customer_id = s.customer_id
JOIN gold.dim_employee e ON e.employee_id = s.employee_id
JOIN gold.dim_shop sh ON sh.shop_key = e.shop_key
WHERE NOT EXISTS (SELECT 1 FROM gold.fact_sales f WHERE f.sales_id = s.sales_id);

-- 10. Закрываем запись журнала. 
UPDATE gold.etl_run
SET finished_at = CURRENT_TIMESTAMP,
    status = 'SUCCESS',
    rows_inserted = (SELECT count(*) FROM gold.fact_sales)
WHERE etl_run_key = (SELECT max(etl_run_key) FROM gold.etl_run)
  AND status = 'RUNNING';

COMMIT;
