SELECT e.first_name, e.last_name, sh.address, s.total_price AS max_amount
FROM employees e
JOIN shops sh ON e.shop_id = sh.shop_id
JOIN sales s ON e.employee_id = s.employee_id
WHERE s.total_price = (
SELECT MAX(total_price)
FROM sales
);