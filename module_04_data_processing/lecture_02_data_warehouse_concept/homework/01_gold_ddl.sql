CREATE SCHEMA IF NOT EXISTS gold;
CREATE SCHEMA IF NOT EXISTS mart;

CREATE TABLE IF NOT EXISTS gold.etl_run (
    etl_run_key       bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    process_name      text NOT NULL,
    started_at        timestamptz NOT NULL DEFAULT clock_timestamp(),
    finished_at       timestamptz,
    status            text NOT NULL DEFAULT 'RUNNING' CHECK (status IN ('RUNNING', 'SUCCESS', 'FAILED')),
    rows_inserted     bigint NOT NULL DEFAULT 0 CHECK (rows_inserted >= 0),
    rows_updated      bigint NOT NULL DEFAULT 0 CHECK (rows_updated >= 0),
    error_message     text
);

CREATE TABLE IF NOT EXISTS gold.dim_location (
    location_key      integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    country_id        integer NOT NULL,
    city_id           integer NOT NULL,
    country_name      text NOT NULL,
    country_code      varchar(2) NOT NULL,
    city_name         text NOT NULL,
    zipcode           varchar(20),
    CONSTRAINT uq_dim_location_bk UNIQUE (city_id),
    CONSTRAINT ck_dim_location_country_code CHECK (country_code ~ '^[A-Z]{2}$')
);

CREATE TABLE IF NOT EXISTS gold.dim_shop (
    shop_key          integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    shop_id           integer NOT NULL,
    location_key      integer NOT NULL REFERENCES gold.dim_location(location_key),
    shop_address      text NOT NULL,
    CONSTRAINT uq_dim_shop_bk UNIQUE (shop_id)
);

CREATE TABLE IF NOT EXISTS gold.dim_category (
    category_key      integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_id       integer NOT NULL,
    category_name     text NOT NULL,
    CONSTRAINT uq_dim_category_bk UNIQUE (category_id),
    CONSTRAINT uq_dim_category_name UNIQUE (category_name)
);

CREATE TABLE IF NOT EXISTS gold.dim_product (
    product_key       integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    product_id        integer NOT NULL,
    product_name      text NOT NULL,
    category_key      integer NOT NULL REFERENCES gold.dim_category(category_key),
    list_price        numeric(14,2) NOT NULL CHECK (list_price >= 0),
    product_class     varchar(10),
    resistant         boolean,
    is_allergic       boolean,
    vitality_days     integer CHECK (vitality_days >= 0),
    valid_from_dt     timestamp NOT NULL,
    valid_to_dt       timestamp,
    is_current        boolean NOT NULL DEFAULT true,
    CONSTRAINT uq_dim_product_version UNIQUE (product_id, valid_from_dt),
    CONSTRAINT ck_dim_product_dates CHECK (valid_to_dt IS NULL OR valid_to_dt > valid_from_dt),
    CONSTRAINT ck_dim_product_current_dates CHECK ((is_current AND valid_to_dt IS NULL) OR (NOT is_current AND valid_to_dt IS NOT NULL))
);
CREATE UNIQUE INDEX IF NOT EXISTS ux_dim_product_current ON gold.dim_product(product_id) WHERE is_current;
CREATE INDEX IF NOT EXISTS ix_dim_product_category_key ON gold.dim_product(category_key);

CREATE TABLE IF NOT EXISTS gold.dim_customer (
    customer_key      integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id       integer NOT NULL,
    location_key      integer NOT NULL REFERENCES gold.dim_location(location_key),
    first_name        text NOT NULL,
    middle_initial    varchar(10),
    last_name         text NOT NULL,
    customer_address  text NOT NULL,
    CONSTRAINT uq_dim_customer_bk UNIQUE (customer_id)
);
CREATE INDEX IF NOT EXISTS ix_dim_customer_location_key ON gold.dim_customer(location_key);

CREATE TABLE IF NOT EXISTS gold.dim_employee (
    employee_key      integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    employee_id       integer NOT NULL,
    shop_key          integer NOT NULL REFERENCES gold.dim_shop(shop_key),
    first_name        text NOT NULL,
    middle_initial    varchar(10),
    last_name         text NOT NULL,
    birth_date        date,
    gender            varchar(20),
    hire_date         date,
    CONSTRAINT uq_dim_employee_bk UNIQUE (employee_id)
);
CREATE INDEX IF NOT EXISTS ix_dim_employee_shop_key ON gold.dim_employee(shop_key);

CREATE TABLE IF NOT EXISTS gold.dim_date (
    date_key          integer PRIMARY KEY, 
    full_date         date NOT NULL UNIQUE,
    day_of_week       smallint NOT NULL CHECK (day_of_week BETWEEN 1 AND 7),
    day_name          varchar(12) NOT NULL,
    week_num          smallint NOT NULL CHECK (week_num BETWEEN 1 AND 53),
    month_num         smallint NOT NULL CHECK (month_num BETWEEN 1 AND 12),
    month_name        varchar(12) NOT NULL,
    quarter_num       smallint NOT NULL CHECK (quarter_num BETWEEN 1 AND 4),
    year_num          smallint NOT NULL
);

CREATE TABLE IF NOT EXISTS gold.dim_time (
    time_key          integer PRIMARY KEY, 
    full_time         time NOT NULL UNIQUE,
    hour_num          smallint NOT NULL CHECK (hour_num BETWEEN 0 AND 23),
    minute_num        smallint NOT NULL CHECK (minute_num BETWEEN 0 AND 59),
    second_num        smallint NOT NULL CHECK (second_num BETWEEN 0 AND 59),
    part_of_day       varchar(12) NOT NULL
);

CREATE TABLE IF NOT EXISTS gold.fact_sales (
    sales_key             bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sales_id              bigint NOT NULL,
    transaction_number    varchar(30) NOT NULL,
    date_key              integer NOT NULL REFERENCES gold.dim_date(date_key),
    time_key              integer NOT NULL REFERENCES gold.dim_time(time_key),
    product_key           integer NOT NULL REFERENCES gold.dim_product(product_key),
    customer_key          integer NOT NULL REFERENCES gold.dim_customer(customer_key),
    employee_key          integer NOT NULL REFERENCES gold.dim_employee(employee_key),
    shop_key              integer NOT NULL REFERENCES gold.dim_shop(shop_key),
    location_key          integer NOT NULL REFERENCES gold.dim_location(location_key),
    quantity              integer NOT NULL CHECK (quantity > 0),
    discount_pct          numeric(5,4) NOT NULL CHECK (discount_pct BETWEEN 0 AND 1),
    gross_revenue         numeric(14,2) NOT NULL CHECK (gross_revenue >= 0),
    discount_amount       numeric(14,2) NOT NULL CHECK (discount_amount >= 0),
    net_revenue           numeric(14,2) NOT NULL CHECK (net_revenue >= 0),
    estimated_cost         numeric(14,2) NOT NULL CHECK (estimated_cost >= 0),
    estimated_profit       numeric(14,2) NOT NULL,
    loaded_at             timestamptz NOT NULL DEFAULT clock_timestamp(),
    CONSTRAINT uq_fact_sales_bk UNIQUE (sales_id),
    CONSTRAINT ck_fact_sales_revenue CHECK (gross_revenue = net_revenue + discount_amount),
    CONSTRAINT ck_fact_sales_profit CHECK (estimated_profit = net_revenue - estimated_cost)
);
CREATE INDEX IF NOT EXISTS ix_fact_sales_date_key ON gold.fact_sales(date_key);
CREATE INDEX IF NOT EXISTS ix_fact_sales_product_key ON gold.fact_sales(product_key);
CREATE INDEX IF NOT EXISTS ix_fact_sales_customer_key ON gold.fact_sales(customer_key);
CREATE INDEX IF NOT EXISTS ix_fact_sales_employee_key ON gold.fact_sales(employee_key);
CREATE INDEX IF NOT EXISTS ix_fact_sales_shop_key ON gold.fact_sales(shop_key);
CREATE INDEX IF NOT EXISTS ix_fact_sales_location_key ON gold.fact_sales(location_key);
