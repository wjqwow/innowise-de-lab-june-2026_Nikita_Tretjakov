def calculate_total_delivery_cost(product_name: str, weights: list | tuple, prices: list | tuple, discount = 0.0, currency_rate: int | float = 1, *extra_costs: float) -> dict[str, float]:
    """
    Данная функция принимает на вход:
    product_name — название товара;
    weights — список весов партий;
    prices — список цен за кг.;
    discount — скидка в процентах;
    currency_rate — курс валюты;
    extra_costs — дополнительные сборы.

    Результатом корректного выполнения функции является словарь, в котором ключи — названия товаров, а значения — итоговые стоимости партий.
    Если входные данные неверны, то функция должна выдавать ошибку.
    """
    if len(weights) != len(prices):
        raise ValueError("Вес и цена должны быть равными длинами")
    total_sum: float = 0.0
    for i in range(len(weights)):
        total_sum += weights[i] * prices[i]
    discount_sum: float = total_sum
    if discount is not None:
        discount_sum = total_sum * (1 - discount)
    extra_sum: float = sum(extra_costs) 
    final_sum: float = (discount_sum + extra_sum) * currency_rate
    print(f"Товар: {product_name}, итоговая стоимость: {final_sum}")

calculate_total_delivery_cost(
    "Овощная партия",           # product_name
    [100, 50],                  # weights
    [4, 6],                     # prices
    0.1,                        # discount
    1,                          # currency_rate
    20, 15                      # *extra_costs
)

calculate_total_delivery_cost(
    "Фруктовая партия",         # product_name
    (30, 20, 10),               # weights
    (15, 12, 18),               # prices
    None,                       # discount
    1.2,                        # currency_rate
    25                          # *extra_costs
)