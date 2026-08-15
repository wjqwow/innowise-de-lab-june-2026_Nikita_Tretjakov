category_a = "Vegetables"
category_b = "Fruits"
price_per_unit_a = 150
quantity_a = 40

# Задаём ставку НДС (20% = 0.2)
vat_rate = 0.2

# Меняем местами значения категорий A и B
category_a, category_b = category_b, category_a

# Вычисляем общую стоимость партии A с НДС: (цена * кол-во) + НДС от этой суммы
total_price_a = (price_per_unit_a * quantity_a) + (price_per_unit_a * quantity_a * vat_rate)
print('Текущая категория A:', category_a)
print('Общая стоимость партии с НДС:', total_price_a)


