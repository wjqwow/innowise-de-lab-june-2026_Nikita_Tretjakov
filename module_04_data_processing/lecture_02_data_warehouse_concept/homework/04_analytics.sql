-- 1. Ежемесячная выручка по странам и категориям товаров.
SELECT d.year_num, d.month_num, l.country_name, c.category_name,
       sum(f.net_revenue)::numeric(16,2) AS net_revenue,
       sum(f.quantity) AS units_sold
FROM gold.fact_sales f
JOIN gold.dim_date d ON d.date_key = f.date_key
JOIN gold.dim_location l ON l.location_key = f.location_key
JOIN gold.dim_product p ON p.product_key = f.product_key
JOIN gold.dim_category c ON c.category_key = p.category_key
GROUP BY d.year_num, d.month_num, l.country_name, c.category_name
ORDER BY d.year_num, d.month_num, net_revenue DESC;

-- 2. 10 крупнейших клиентов по чистой выручке
SELECT c.customer_id, concat_ws(' ', c.first_name, c.last_name) AS customer_name,
       l.country_name, l.city_name, sum(f.net_revenue)::numeric(16,2) AS net_revenue
FROM gold.fact_sales f
JOIN gold.dim_customer c ON c.customer_key = f.customer_key
JOIN gold.dim_location l ON l.location_key = c.location_key
GROUP BY c.customer_id, c.first_name, c.last_name, l.country_name, l.city_name
ORDER BY net_revenue DESC LIMIT 10;

-- 3. Эффективность работы сотрудников и валовая прибыль
SELECT e.employee_id, concat_ws(' ', e.first_name, e.last_name) AS employee_name,
       sum(f.net_revenue)::numeric(16,2) AS revenue,
       sum(f.estimated_profit)::numeric(16,2) AS estimated_profit,
       round(100 * sum(f.estimated_profit) / NULLIF(sum(f.net_revenue), 0), 2) AS estimated_margin_pct
FROM gold.fact_sales f
JOIN gold.dim_employee e ON e.employee_key = f.employee_key
JOIN gold.dim_product p ON p.product_key = f.product_key
GROUP BY e.employee_id, e.first_name, e.last_name
ORDER BY estimated_profit DESC;

-- 4. Самые продаваемые товары
SELECT p.product_id, p.product_name, sum(f.quantity) AS quantity_sold,
       sum(f.net_revenue)::numeric(16,2) AS net_revenue
FROM gold.fact_sales f JOIN gold.dim_product p ON p.product_key = f.product_key
GROUP BY p.product_id, p.product_name
ORDER BY quantity_sold DESC LIMIT 20;

-- 5. Средняя стоимость транзакции по магазинам (transaction_number — это бизнес-ключ квитанции)
WITH receipts AS (
    SELECT f.shop_key, f.transaction_number, sum(f.net_revenue) AS receipt_revenue
    FROM gold.fact_sales f GROUP BY f.shop_key, f.transaction_number
)
SELECT s.shop_id, s.shop_address, avg(r.receipt_revenue)::numeric(16,2) AS average_check
FROM receipts r JOIN gold.dim_shop s ON s.shop_key = r.shop_key
GROUP BY s.shop_id, s.shop_address ORDER BY average_check DESC;
