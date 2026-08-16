SMALL_BATCH_LIMIT = 500

def calculate_batch(weight, price, discount=0.0):
    """
    Рассчитывает стоимость партии товара и проверяет превышение лимита мелких закупок.
    
    Параметры:
    weight : float
        Вес партии товара в килограммах
    price : float
        Цена за килограмм в долларах
    discount : float, optional
        Сезонная скидка в долях (по умолчанию 0.0)
    
    Возвращает:
    tuple
        (final_sum, is_limit_exceeded)
        - final_sum : float - итоговая сумма партии
        - is_limit_exceeded : bool - True если сумма превышает лимит, иначе False
    """
    final_sum = weight * price * (1 - discount)
    is_limit_exceeded = final_sum > SMALL_BATCH_LIMIT
    return final_sum, is_limit_exceeded 

print(f'Партия 1 (Морковь): Сумма {calculate_batch(100, 4)[0]}. Превышение лимита: {calculate_batch(100, 4)[1]}')
print(f'Партия 2 (Яблоки): Сумма {calculate_batch(50, 20, 0.1)[0]}. Превышение лимита: {calculate_batch(50, 20, 0.1)[1]}')

