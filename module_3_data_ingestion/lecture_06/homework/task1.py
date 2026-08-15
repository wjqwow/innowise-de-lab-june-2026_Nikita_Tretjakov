rows_range = range(1,6)
rows = list(rows_range)
rows[2] = 'Ремонт'
if 5 in rows:
    print('Ряд 5 доступен')
priority_rows = rows[:3]
print('Список рядов:', rows)
print('Приоритетные ряды:', priority_rows)
