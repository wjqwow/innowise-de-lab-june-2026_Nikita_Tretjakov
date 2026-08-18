import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy.exc import SQLAlchemyError
from datetime import datetime

DATABASE_URL = "postgresql://admin:admin@localhost:5430/postgre"

try:
    engine = create_engine(DATABASE_URL)
    print("Подключение успешно")
except SQLAlchemyError as e:
    print(f"Ошибка подключения: {e}")

def validate_and_fix_date(date_str):
    """
    Функция валидации дат:
    - пытается разобрать кривые форматы (слэши)
    - проверяет реальность даты
    - невозможные даты заменяет на 1900-01-01
    """
    if pd.isna(date_str) or date_str == '': #проверяем, является ли строка пустым значением
        return '1900-01-01'
    
    date_str = str(date_str).strip() #удаляем лишние пробелы в начале и в конце

    #пытаемся распарсить разные форматы
    formats = ['%Y-%m-%d', '%Y/%m/%d', '%d-%m-%Y', '%d/%m/%Y', '%m-%d-%Y', '%m/%d/%Y']
    
    for fmt in formats:
        try:
            date_obj = datetime.strptime(date_str, fmt)
            if date_obj.year >= 1900 and date_obj.year <= 2100:
                return date_obj.strftime('%Y-%m-%d')
        except ValueError:
            continue
    #если ничего не подошло - тех. дефолт
    return '1900-01-01'

df_employees = pd.read_sql('SELECT * FROM bronze.bronze_employees', engine)
df_sales = pd.read_sql('SELECT * FROM bronze.bronze_sales', engine)
df_products = pd.read_sql('SELECT * FROM bronze.bronze_products', engine)
df_cities = pd.read_sql('SELECT * FROM bronze.bronze_cities', engine)
df_shops = pd.read_sql('SELECT * FROM bronze.bronze_shops', engine)
df_customers = pd.read_sql('SELECT * FROM bronze.bronze_customers', engine)
df_countries = pd.read_sql('SELECT * FROM bronze.bronze_countries', engine)
df_categories = pd.read_sql('SELECT * FROM bronze.bronze_categories', engine)

df_employees['birth_date'] = df_employees['birth_date'].apply(validate_and_fix_date) #apply применяет нашу функцию к каждой строке
df_employees['hire_date'] = df_employees['hire_date'].apply(validate_and_fix_date)

def fix_sales_timestamp(ts_str):
    if pd.isna(ts_str) or ts_str == '':
        return pd.NaT #тип данных "не время" приведет к NaT
    
    ts_str = str(ts_str).strip()
    
    try:
        if ' ' in ts_str: #если есть пробел, значит есть и дата и время
            return datetime.strptime(ts_str, '%Y-%m-%d %H:%M:%S') #парсинг происходит по маске полного формата
        elif '-' in ts_str or '/' in ts_str: #если только дата (проверка по разделителю) - добавляем 00:00:00
            date_part = validate_and_fix_date(ts_str)
            return datetime.strptime(f'{date_part} 00:00:00', '%Y-%m-%d %H:%M:%S')
    except:
        return pd.NaT
    
    return pd.NaT

df_sales['sales_timestamp'] = df_sales['sales_timestamp'].apply(fix_sales_timestamp)

#если даты нет совсем — удаляем строку (dropna)
df_sales = df_sales.dropna(subset=['sales_timestamp'])

df_products['price'] = pd.to_numeric(df_products['price'], errors='coerce') #преобразуем в тип numeric, а errors заменяет ошибки на NaN
df_sales['quantity'] = pd.to_numeric(df_sales['quantity'], errors='coerce')
df_sales['discount'] = pd.to_numeric(df_sales['discount'], errors='coerce')
df_sales['total_price'] = pd.to_numeric(df_sales['total_price'], errors='coerce')

df_products['resistant'] = df_products['resistant'].apply(
    lambda x: str(x).lower() in ['true', '1', 'yes', 't'] if pd.notna(x) else None
)
df_products['is_allergic'] = df_products['is_allergic'].apply(
    lambda x: str(x).lower() in ['true', '1', 'yes', 't'] if pd.notna(x) else None
)

df_products['modify_timestamp'] = df_products['modify_timestamp'].apply(
    lambda x: validate_and_fix_date(x) if pd.notna(x) else None
)

df_countries.to_sql(
    name='silver_countries',
    con=engine,
    schema='silver',
    if_exists='append',
    index=False,
    chunksize=5000
)

df_categories.to_sql(
    name='silver_categories',
    con=engine,
    schema='silver',
    if_exists='append',
    index=False,
    chunksize=5000
)

df_cities.to_sql(
    name='silver_cities',
    con=engine,
    schema='silver',
    if_exists='append',
    index=False,
    chunksize=5000
)

df_shops.to_sql(
    name='silver_shops',
    con=engine,
    schema='silver',
    if_exists='append',
    index=False,
    chunksize=5000
)

df_customers.to_sql(
    name='silver_customers',
    con=engine,
    schema='silver',
    if_exists='append',
    index=False,
    chunksize=5000
)

df_products.to_sql(
    name='silver_products',
    con=engine,
    schema='silver',
    if_exists='append',
    index=False,
    chunksize=5000
)

df_employees.to_sql(
    name='silver_employees',
    con=engine,
    schema='silver',
    if_exists='append',
    index=False,
    chunksize=5000
)

df_sales.to_sql(
    name='silver_sales',
    con=engine,
    schema='silver',
    if_exists='append',
    index=False,
    chunksize=5000
)

print('Данные успешно загружены в Silver слой')