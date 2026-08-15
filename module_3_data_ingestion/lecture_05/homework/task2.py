product = " фермерский ТВОРОГ " 
price = 4.567 
qty = 3 
csv_row = "milk,bread,cheese" 
review = "Это лучший ТВОРОГ в городе!" 

# префикс r указывает интерпретатору не обрабатывать символ обратного слэша (\) как знак специального экранирования
file_path = r"C:\EcoMarket\data\2025\january\sales.csv" 

clean_product = product.strip().lower().title()
total = price * qty
receipt = f'Чек "EcoMarket"\nТовар: {clean_product}\nКол-во: {qty}\nИтого: {total} руб.'
print(receipt)

clean_row=' | '.join(csv_row.split(','))
print(clean_row)

if "творог" in review.lower():
    print('Отзыв относится к категории: Dairy', file_path)

