# Analytics Layer Design

## Project Overview

This project focuses on designing an **Analytics Layer** for a PostgreSQL-based retail database. Instead of querying the operational database repeatedly, reusable analytical views are created to support business intelligence, reporting, and dashboard development.

The analytics layer transforms normalized transactional data into summarized datasets that are easier to query, faster to analyze, and reusable across multiple business reports.

---

# Objectives

- Build an intermediate analytics layer using SQL Views.
- Reduce repeated computation on transactional tables.
- Provide reusable datasets for reporting and visualization.
- Improve query readability and maintainability.
- Prepare data for Business Intelligence tools such as Power BI, Tableau, or Python.

---

# Analytics Views Created

## 1. Customer Analytics

Provides customer-level business metrics.

### Metrics Included

- Customer ID
- Customer Name
- Total Orders
- Total Revenue
- Average Order Value
- First Purchase Date
- Last Purchase Date
- Customer Lifetime Value (CLV)

### Business Purpose

Used to:

- Identify high-value customers
- Analyze customer purchasing behavior
- Measure customer lifetime value
- Track repeat customers

---

## 2. Product Analytics

Provides product performance metrics.

### Metrics Included

- Product ID
- Product Name
- Category
- Total Quantity Sold
- Total Sales
- Average Selling Price
- Number of Orders
- Total Profit

### Business Purpose

Used to:

- Identify best-selling products
- Measure product profitability
- Compare product categories
- Support inventory planning

---

## 3. Sales Analytics

Provides sales performance across time.

### Metrics Included

- Order Date
- Year
- Month
- Number of Orders
- Total Sales
- Total Profit
- Average Order Value

### Business Purpose

Used to:

- Analyze monthly sales trends
- Monitor revenue growth
- Compare business performance over time
- Build sales dashboards

---

# SQL Concepts Used

The analytics layer makes use of several important SQL concepts:

- Views
- Aggregate Functions
- GROUP BY
- JOIN Operations
- Common Table Expressions (CTEs)
- Date Functions
- Aliases
- ORDER BY

---

# Why Use an Analytics Layer?

Operational databases are optimized for recording transactions, not for reporting. Running analytical queries directly on transactional tables can lead to:

- Slower query performance
- Repeated calculations
- Complex SQL statements
- Higher database load

An analytics layer solves these issues by providing reusable summarized views that simplify reporting and improve performance.

---

# Benefits

- Faster analytical queries
- Cleaner SQL code
- Reusable business metrics
- Easier dashboard creation
- Better maintainability
- Reduced redundancy



# How to Run

1. Restore or create the PostgreSQL database.
2. Ensure all operational tables have been created and populated.
3. Open **pgAdmin** or **psql**.
4. Execute:

```sql
analytics_layer.sql
```

This script will create all analytical views.

---

# Example Queries

Retrieve customer analytics:

```sql
SELECT *
FROM customer_analytics;
```

Retrieve product analytics:

```sql
SELECT *
FROM product_analytics
ORDER BY total_sales DESC;
```

Retrieve monthly sales:

```sql
SELECT *
FROM sales_analytics
ORDER BY year, month;
```

---

# Business Insights

The analytics layer enables several valuable business insights, including:

- Identifying customers who generate the highest revenue.
- Determining which products contribute the most to overall sales and profit.
- Tracking monthly sales performance to identify seasonal trends and business growth.

---

# Technologies Used

- PostgreSQL
- SQL
- pgAdmin
- Jupyter Notebook (for further analysis)

---

# Author

**Mehreen Fatima**
