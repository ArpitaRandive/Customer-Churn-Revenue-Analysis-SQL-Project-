-- PART 1: DATABASE SETUP
-- Run this separately before executing the rest
CREATE DATABASE sales_analysis;

-- PART 2: SCHEMA (TABLE CREATION)
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    customer_name VARCHAR(100),
    signup_date DATE
);
CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price NUMERIC
);
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(customer_id),
    order_date DATE,
    status VARCHAR(20)
);
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id),
    product_id INT REFERENCES products(product_id),
    quantity INT,
    price NUMERIC
);

-- PART 3: DATA INSERTION (SYNTHETIC DATA)
INSERT INTO customers (customer_name, signup_date) VALUES
('Alice Johnson', '2023-06-15'),
('Bob Smith', '2023-09-10'),
('Charlie Lee', '2023-12-01'),
('Diana Patel', '2024-01-20'),
('Ethan Brown', '2024-02-05');

INSERT INTO products (product_name, category, price) VALUES
('Laptop', 'Electronics', 1200),
('Headphones', 'Electronics', 230),
('Desk', 'Furniture', 450),
('Office Chair', 'Furniture', 300),
('Coffee Maker', 'Appliances', 90);

INSERT INTO orders (order_id, customer_id, order_date, status) VALUES
(1, 1, '2024-01-10', 'completed'),
(2, 1, '2024-02-15', 'completed'),
(3, 1, '2024-03-05', 'completed'),
(4, 1, '2024-04-20', 'completed'),
(5, 2, '2024-02-10', 'completed'),
(6, 2, '2024-04-09', 'completed'),
(7, 3, '2024-03-18', 'cancelled'),
(8, 4, '2024-01-25', 'completed'),
(9, 4, '2024-05-30', 'completed');


INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
(1, 1, 1, 1200),
(1, 2, 1, 230),
(2, 1, 1, 1200),
(3, 3, 1, 450),
(4, 2, 1, 230),
(5, 3, 1, 450),
(6, 4, 1, 300),
(8, 5, 1, 90);

-- PART 4: CORE BUSINESS ANALYTICS
SELECT
    SUM(oi.quantity * oi.price) AS total_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id;

SELECT
    DATE_TRUNC('month', o.order_date) AS month,
    SUM(oi.quantity * oi.price) AS monthly_revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY month
ORDER BY month;

WITH monthly AS (
    SELECT
        DATE_TRUNC('month', o.order_date) AS month,
        SUM(oi.quantity * oi.price) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.status = 'completed'
    GROUP BY month
)
SELECT
    month,
    revenue,
    revenue - LAG(revenue) OVER (ORDER BY month) AS mom_change
FROM monthly;

SELECT
    c.customer_id,
    c.customer_name,
    SUM(oi.quantity * oi.price) AS customer_revenue
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id, c.customer_name
ORDER BY customer_revenue DESC;

SELECT
    p.product_name,
    p.category,
    SUM(oi.quantity * oi.price) AS product_revenue
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_name, p.category
ORDER BY product_revenue DESC;

SELECT
    ROUND(
        SUM(oi.quantity * oi.price) /
        COUNT(DISTINCT o.order_id),
        2
    ) AS avg_order_value
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id;

-- PART 5: ADVANCED CUSTOMER ANALYTICS
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT o.order_id) AS total_orders,
    CASE
        WHEN COUNT(DISTINCT o.order_id) > 1 THEN 'Repeat Customer'
        ELSE 'One-Time Customer'
    END AS customer_type
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
WHERE o.status = 'completed'
GROUP BY c.customer_id, c.customer_name;

WITH last_purchase AS (
    SELECT
        customer_id,
        MAX(order_date) AS last_order_date
    FROM orders
    WHERE status = 'completed'
    GROUP BY customer_id
)
SELECT
    c.customer_id,
    c.customer_name,
    lp.last_order_date,
    CASE
        WHEN lp.last_order_date IS NULL THEN 'Never Converted'
        WHEN lp.last_order_date < CURRENT_DATE - INTERVAL '60 days'
            THEN 'Churned'
        ELSE 'Active'
    END AS customer_status
FROM customers c
LEFT JOIN last_purchase lp
ON c.customer_id = lp.customer_id
ORDER BY c.customer_id;

SELECT
    c.customer_id,
    c.customer_name,
    SUM(oi.quantity * oi.price) AS lifetime_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.status = 'completed'
GROUP BY c.customer_id, c.customer_name
ORDER BY lifetime_value DESC;
