WITH monthly_revenue AS (
SELECT DATE_TRUNC('month', s.sales_timestamp::DATE) AS sale_month, SUM(s.total_price) AS monthly_revenue
FROM sales s
JOIN employees e ON s.employee_id = e.employee_id 
JOIN shops sh ON e.shop_id = sh.shop_id 
JOIN cities ON sh.city_id = cities.city_id 
JOIN countries ON cities.country_id = countries.country_id 
WHERE countries.country_name = 'Germany'
AND s.sales_timestamp IS NOT NULL
AND s.sales_timestamp != ''
AND s.sales_timestamp ~ '^\d{4}-\d{2}-\d{2}'
GROUP BY DATE_TRUNC('month', s.sales_timestamp::DATE)
)
SELECT 
TO_CHAR(sale_month, 'YYYY-MM-DD HH24:MI:SS') AS sale_month,
    monthly_revenue,
COALESCE(LAG(monthly_revenue) OVER (ORDER BY sale_month), monthly_revenue) AS previous_month_revenue,
COALESCE(monthly_revenue - LAG(monthly_revenue) OVER (ORDER BY sale_month), 0) AS revenue_diff_vs_previous
FROM monthly_revenue
ORDER BY sale_month ASC
LIMIT 24;