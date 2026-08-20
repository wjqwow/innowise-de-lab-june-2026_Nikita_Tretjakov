CREATE SCHEMA IF NOT EXISTS mart;

CREATE OR REPLACE VIEW mart.mart_daily_anomaly AS
WITH daily AS (
    SELECT f.shop_key, f.location_key, d.full_date, sum(f.net_revenue)::numeric(16,2) AS revenue
    FROM gold.fact_sales f JOIN gold.dim_date d ON d.date_key = f.date_key
    GROUP BY f.shop_key, f.location_key, d.full_date
)
SELECT shop_key, location_key, full_date, revenue,
       avg(revenue) OVER (PARTITION BY shop_key ORDER BY full_date
           RANGE BETWEEN INTERVAL '30 days' PRECEDING AND INTERVAL '1 day' PRECEDING)::numeric(16,2) AS expected_revenue,
       (revenue - avg(revenue) OVER (PARTITION BY shop_key ORDER BY full_date
           RANGE BETWEEN INTERVAL '30 days' PRECEDING AND INTERVAL '1 day' PRECEDING))::numeric(16,2) AS uplift
FROM daily;

CREATE OR REPLACE VIEW mart.mart_shop_daily AS
WITH daily AS (
    SELECT f.shop_key, f.location_key, d.full_date, sum(f.net_revenue)::numeric(16,2) AS daily_revenue
    FROM gold.fact_sales f JOIN gold.dim_date d ON d.date_key = f.date_key
    GROUP BY f.shop_key, f.location_key, d.full_date
)
SELECT d.full_date, d.shop_key, d.location_key, l.country_name, l.country_code, l.city_name, l.zipcode,
       s.shop_address, d.daily_revenue,
       avg(d.daily_revenue) OVER (PARTITION BY d.shop_key)::numeric(16,2) AS avg_daily_revenue
FROM daily d
JOIN gold.dim_shop s ON s.shop_key = d.shop_key
JOIN gold.dim_location l ON l.location_key = d.location_key;

CREATE OR REPLACE VIEW mart.mart_customer_behavior AS
WITH customer_revenue AS (
    SELECT c.customer_key, c.location_key, COALESCE(sum(f.net_revenue), 0)::numeric(16,2) AS revenue,
           max(d.full_date) AS last_purchase_date,
           (SELECT max(full_date) FROM gold.dim_date dd JOIN gold.fact_sales ff ON ff.date_key = dd.date_key) AS as_of_date
    FROM gold.dim_customer c
    LEFT JOIN gold.fact_sales f ON f.customer_key = c.customer_key
    LEFT JOIN gold.dim_date d ON d.date_key = f.date_key
    GROUP BY c.customer_key, c.location_key
), segmented AS (
    SELECT location_key,
           CASE WHEN last_purchase_date >= as_of_date - 90 THEN 'Active' ELSE 'Inactive' END AS activity_status,
           CASE WHEN revenue = 0 THEN 'No purchases' WHEN revenue < 100 THEN 'Low'
                WHEN revenue < 500 THEN 'Medium' ELSE 'High' END AS revenue_segment
    FROM customer_revenue
)
SELECT location_key, activity_status, revenue_segment, count(*) AS customer_count
FROM segmented
GROUP BY location_key, activity_status, revenue_segment;

CREATE OR REPLACE VIEW mart.mart_employee_performance AS
WITH employee_sales AS (
    SELECT e.employee_key, e.employee_id, e.shop_key, sh.location_key,
           concat_ws(' ', e.first_name, e.last_name) AS employee_name,
           count(f.sales_key) AS sales_lines, COALESCE(sum(f.net_revenue), 0)::numeric(16,2) AS net_revenue,
           COALESCE(sum(f.estimated_profit), 0)::numeric(16,2) AS estimated_profit
    FROM gold.dim_employee e
    JOIN gold.dim_shop sh ON sh.shop_key = e.shop_key
    LEFT JOIN gold.fact_sales f ON f.employee_key = e.employee_key
    LEFT JOIN gold.dim_product p ON p.product_key = f.product_key
    GROUP BY e.employee_key, e.employee_id, e.shop_key, sh.location_key, e.first_name, e.last_name
), ranked AS (
    SELECT *, dense_rank() OVER (PARTITION BY shop_key ORDER BY estimated_profit DESC) AS profit_rank,
              dense_rank() OVER (PARTITION BY shop_key ORDER BY estimated_profit ASC) AS outsider_rank
    FROM employee_sales
)
SELECT *, CASE WHEN profit_rank <= 3 THEN 'Leader' WHEN outsider_rank <= 3 THEN 'Outsider' ELSE 'Middle' END AS performance_group
FROM ranked;

CREATE OR REPLACE VIEW mart.mart_product_seasonality AS
SELECT f.location_key, p.category_key, c.category_name, d.year_num, d.quarter_num, d.month_num, d.month_name,
       sum(f.quantity) AS quantity_sold, sum(f.net_revenue)::numeric(16,2) AS revenue,
       dense_rank() OVER (PARTITION BY f.location_key, d.year_num, d.month_num ORDER BY sum(f.quantity) DESC) AS category_volume_rank
FROM gold.fact_sales f
JOIN gold.dim_date d ON d.date_key = f.date_key
JOIN gold.dim_product p ON p.product_key = f.product_key
JOIN gold.dim_category c ON c.category_key = p.category_key
GROUP BY f.location_key, p.category_key, c.category_name, d.year_num, d.quarter_num, d.month_num, d.month_name;
