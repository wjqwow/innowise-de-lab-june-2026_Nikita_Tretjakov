def calculate_purchase(product_name, weight, price):
    """
    Данная функция принимает на вход:
    product_name — название товара;
    weight — вес партии;
    price — цена за кг.

    Результатом корректного выполнения функции является название товара и итоговая стоимость партии.
    Если входные данные неверны, то функция должна выдавать ошибку.
    """
    try:
        numeric_weight = float(weight)
        total_cost = numeric_weight * price
        technical_index = 100 / numeric_weight
        print(f"Товар: {product_name}. Итоговая стоимость: {total_cost}$")
        return product_name, total_cost
    except TypeError as t:
        print(f"Тип ошибки: {type(t)}\nСообщение: {t}")
    except ValueError as v:
        print(f"Тип ошибки: {type(v)}\nСообщение: {v}")
    except ZeroDivisionError as z:
        print(f"Тип ошибки: {type(z)}\nСообщение: {z}")
    finally:
        print('--- Проверка партии завершена --- ', '\n')

calculate_purchase("Томаты", 100, 2.5)
calculate_purchase("Огурцы", 'пятьдесят', 1.8)
calculate_purchase("Перец", 0, 4)
calculate_purchase("Зелень", [10], 5)




   