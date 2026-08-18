CREATE SCHEMA IF NOT EXISTS silver;

CREATE TABLE silver.silver_countries (
    country_id INTEGER PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL,
    country_code VARCHAR(3)
);

CREATE TABLE silver.silver_categories (
    category_id INTEGER PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL
);

CREATE TABLE silver.silver_cities (
    city_id INTEGER PRIMARY KEY,
    city_name VARCHAR(100) NOT NULL,
    zipcode VARCHAR(20),
    country_id INTEGER
);

CREATE TABLE silver.silver_products (
    product_id INTEGER PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    price NUMERIC(10,2),
    category_id INTEGER,
    class VARCHAR(10),
    modify_timestamp TIMESTAMP,
    resistant BOOLEAN,
    is_allergic BOOLEAN,
    vitality_days INTEGER
);

CREATE TABLE silver.silver_shops (
    shop_id INTEGER PRIMARY KEY,
    city_id INTEGER,
    address VARCHAR(500)
);

-- 6. employees
CREATE TABLE silver.silver_employees (
    employee_id INTEGER PRIMARY KEY,
    first_name VARCHAR(100),
    middle_initial VARCHAR(10),
    last_name VARCHAR(100),
    birth_date DATE,
    gender VARCHAR(10),
    city_id INTEGER,
    shop_id INTEGER,
    hire_date DATE
);

CREATE TABLE silver.silver_customers (
    customer_id INTEGER PRIMARY KEY,
    first_name VARCHAR(100),
    middle_initial VARCHAR(10),
    last_name VARCHAR(100),
    city_id INTEGER,
    address VARCHAR(500)
);

CREATE TABLE silver.silver_sales (
    sales_id INTEGER PRIMARY KEY,
    employee_id INTEGER,
    customer_id INTEGER,
    product_id INTEGER,
    quantity NUMERIC(10,2),
    discount NUMERIC(5,2),
    total_price NUMERIC(10,2),
    sales_timestamp TIMESTAMP,
    transaction_number VARCHAR(50),
    city_id INTEGER,
    shop_id INTEGER
);