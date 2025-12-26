# Customer-Churn-Revenue-Analysis-SQL-Project-
# Project Overview
This project performs an end-to-end SQL-based analysis of customer behavior, revenue performance, and churn using transactional sales data. The analysis models a small sales database, runs analytical SQL queries to extract business insights, and classifies customers into lifecycle stages such as Active, Churned, and Never Converted.

The final SQL outputs are designed to be consumed by BI tools (e.g., Power BI) for visualization, but all business logic is implemented in SQL.

# Tech Stack
SQL (PostgreSQL-compatible syntax)
Relational database modeling
Window functions, CTEs, aggregations
Power BI (visualization layer only)

# Database Schema
## Tables
customers
customer_id (PK)
customer_name
signup_date

## Products
product_id (PK)
product_name
category
price

## Orders
order_id (PK)
customer_id (FK)
order_date
status

## Order_items
order_item_id (PK)
order_id (FK)
product_id (FK)
quantity
price

## Relationships:
customers → orders (one-to-many)
orders → order_items (one-to-many)
products → order_items (one-to-many)
