prices = [100, -50, 300, 40, 800]
for i in prices:
    if i < 0: 
        prices.remove(i)
prices.append(150)
prices.sort()
tax_prices = [i * 1.2 for i in prices if (i * 1.2) > 100.0]

output = f'Базовый прайс (очищенный): {prices}\nЦены с НДС (>100): {tax_prices}\nОбщая выручка: {sum(tax_prices)}\nМинимум: {min(tax_prices)}\nМаксимум: {max(tax_prices)}'

print(output)
