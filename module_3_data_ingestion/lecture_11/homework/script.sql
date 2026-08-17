-- 1. countries
CREATE TABLE bronze.bronze_countries (
    country_id INTEGER PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL,
    country_code VARCHAR(3)
);

-- 2. categories
CREATE TABLE bronze.bronze_categories (
    category_id INTEGER PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL
);

-- 3. cities
CREATE TABLE bronze.bronze_cities (
    city_id INTEGER PRIMARY KEY,
    city_name VARCHAR(100) NOT NULL,
    zipcode VARCHAR(20),
    country_id INTEGER REFERENCES bronze.bronze_countries(country_id)
);

-- 4. products
CREATE TABLE bronze.bronze_products (
    product_id INTEGER PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    price DECIMAL(10,2),
    category_id INTEGER REFERENCES bronze.bronze_categories(category_id),
    class VARCHAR(10),
    modify_timestamp VARCHAR(50),
    resistant VARCHAR(10),
    is_allergic VARCHAR(10),
    vitality_days INTEGER
);

-- 5. shops
CREATE TABLE bronze.bronze_shops (
    shop_id INTEGER PRIMARY KEY,
    city_id INTEGER REFERENCES bronze.bronze_cities(city_id),
    address VARCHAR(500)
);

-- 6. employees
CREATE TABLE bronze.bronze_employees (
    employee_id INTEGER PRIMARY KEY,
    first_name VARCHAR(100),
    middle_initial VARCHAR(10),
    last_name VARCHAR(100),
    birth_date VARCHAR(50),
    gender VARCHAR(10),
    city_id INTEGER REFERENCES bronze.bronze_cities(city_id),
    shop_id INTEGER REFERENCES bronze.bronze_shops(shop_id),
    hire_date VARCHAR(50)
);

-- 7. customers
CREATE TABLE bronze.bronze_customers (
    customer_id INTEGER PRIMARY KEY,
    first_name VARCHAR(100),
    middle_initial VARCHAR(10),
    last_name VARCHAR(100),
    city_id INTEGER REFERENCES bronze.bronze_cities(city_id),
    address VARCHAR(500)
);

-- 8. sales
CREATE TABLE bronze.bronze_sales (
    sales_id INTEGER PRIMARY KEY,
    employee_id INTEGER REFERENCES bronze.bronze_employees(employee_id),
    customer_id INTEGER REFERENCES bronze.bronze_customers(customer_id),
    product_id INTEGER REFERENCES bronze.bronze_products(product_id),
    quantity DECIMAL(10,2),
    discount DECIMAL(5,2),
    total_price DECIMAL(10,2),
    sales_timestamp VARCHAR(50),
    transaction_number VARCHAR(50)
);