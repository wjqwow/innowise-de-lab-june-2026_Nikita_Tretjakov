SELECT shops.shop_id, shops.address, cities.city_name, countries.country_name
FROM shops
JOIN cities ON shops.city_id = cities.city_id
JOIN countries ON cities.country_id = countries.country_id
WHERE countries.country_name = 'Poland';
