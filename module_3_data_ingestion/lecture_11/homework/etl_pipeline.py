import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy.exc import SQLAlchemyError

DATABASE_URL = "postgresql://admin:admin@localhost:5430/postgre"

try:
    engine = create_engine(DATABASE_URL)
    print("Подключение успешно")
except SQLAlchemyError as e:
    print(f"Ошибка подключения: {e}")

df = pd.read_csv('countries.csv', sep=';')
df.to_sql(
    name='bronze_countries',
    con=engine,
    schema='bronze',
    if_exists='append',
    index=False,
    chunksize=5000
)

print('countries.csv загружено')

df = pd.read_csv('cities.csv', sep=';')
df.to_sql(
    name='bronze_cities',
    con=engine,
    schema='bronze',
    if_exists='append',
    index=False,
    chunksize=5000
)

df = pd.read_csv('categories.csv', sep=';')
df.to_sql(
    name='bronze_categories',
    con=engine,
    schema='bronze',
    if_exists='append',
    index=False,
    chunksize=5000
)

print('categories.csv загружено')

df = pd.read_csv('products.csv', sep=';')
df.to_sql(
    name='bronze_products',
    con=engine,
    schema='bronze',
    if_exists='append',
    index=False,
    chunksize=5000
)

print('products.csv загружено')

df = pd.read_csv('shops.csv', sep=';')
df.to_sql(
    name='bronze_shops',
    con=engine,
    schema='bronze',
    if_exists='append',
    index=False,
    chunksize=5000
)

print('shops.csv загружено')

df = pd.read_csv('employees.csv', sep=';')
df.to_sql(
    name='bronze_employees',
    con=engine,
    schema='bronze',
    if_exists='append',
    index=False,
    chunksize=5000
)

print('employees.csv загружено')

df = pd.read_csv('customers.csv', sep=';')
df.to_sql(
    name='bronze_customers',
    con=engine,
    schema='bronze',
    if_exists='append',
    index=False,
    chunksize=5000
)

print('customers.csv загружено')

df = pd.read_csv('sales.csv', sep=';')
df.to_sql(
    name='bronze_sales',
    con=engine,
    schema='bronze',
    if_exists='append',
    index=False,   
)

print('sales.csv загружено')

