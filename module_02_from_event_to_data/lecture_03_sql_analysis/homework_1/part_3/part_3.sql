SELECT countries.country_name, COUNT(shops.shop_id) as shops_count
FROM countries 
JOIN cities ON countries.country_id = cities.country_id
JOIN shops ON shops.city_id = cities.city_id 
GROUP BY countries.country_name 
ORDER BY shops_count DESC;