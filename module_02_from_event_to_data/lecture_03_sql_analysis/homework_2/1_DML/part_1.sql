INSERT INTO products 
VALUES (506, 'Golden Apple', '777.77', 1, 'A', '2025-11-24 21:51:39', 'No', 'No', '77'),
(507, 'Silver Carrot', '333.33', 1, 'B', '2025-11-24 21:51:39', 'No', 'No', '33');
SELECT * FROM products
ORDER BY product_id DESC 
LIMIT 20;