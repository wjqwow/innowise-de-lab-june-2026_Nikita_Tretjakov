raw_log = "ORDER-2025-01-15|FRT-APPLE-PL|+111 (23) 456-78-90| мИНсК "
log = raw_log.split('|')
order_id = log[0]
product_code = log[1]
raw_phone = log[2]
raw_city = log[3]

category = product_code[:3]
region = product_code[-2:]
print(f'Позиция первого дефиса в коде товара: {product_code.find('-')}')
if product_code.startswith('FRT'):
    print("Код товара начинается с 'FRT'")
else:
    print("Код товара не начинается с 'FRT'")

clean_phone = ''
for char in raw_phone:
    if char.isdigit():
        clean_phone += char
print('Длина номера телефона:', len(clean_phone))

city = raw_city.strip().lower().title()

report = f"Заказ: {order_id}\nКатегория: {category} | Регион: {region}\nТелефон: {clean_phone}\nГород: {city}"

print(report)