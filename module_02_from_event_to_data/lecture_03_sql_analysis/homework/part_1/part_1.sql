SELECT sales.sales_id, products.product_name, shops.address
FROM sales
JOIN products ON sales.product_id = products.product_id 
JOIN employees ON sales.employee_id = employees.employee_id 
JOIN shops ON employees.shop_id = shops.shop_id 
LIMIT 10;