/****************************************************************************************
    ENTERPRISE ANALYTICS HACKATHON
    Stage 1 - Base Analytics Layer

    Author : Mehreen Fatima
    Database : AdventureWorks
****************************************************************************************/

----------------------------------------------------------
-- Create Analytics Schema
----------------------------------------------------------

CREATE SCHEMA IF NOT EXISTS analytics;
SELECT column_name
FROM information_schema.columns
WHERE table_schema='sales'
AND table_name='salesorderdetail'
ORDER BY ordinal_position;
CREATE OR REPLACE VIEW analytics.vw_sales_base AS
SELECT
    soh.salesorderid,
    soh.orderdate,
    soh.duedate,
    soh.shipdate,
    soh.customerid,
    soh.salespersonid,
    soh.territoryid,

    sod.salesorderdetailid,
    sod.productid,
    sod.specialofferid,

    sod.orderqty,
    sod.unitprice,
    sod.unitpricediscount,

    ROUND(
        sod.orderqty * sod.unitprice * (1 - sod.unitpricediscount),
        2
    ) AS line_total,

    soh.subtotal,
    soh.taxamt,
    soh.freight,
    soh.totaldue

FROM sales.salesorderheader soh
JOIN sales.salesorderdetail sod
ON soh.salesorderid = sod.salesorderid;

--Customer Base View
CREATE OR REPLACE VIEW analytics.vw_customer_base AS

SELECT

    c.customerid,

    c.personid,

    c.storeid,

    p.firstname,
    p.lastname,

    CONCAT(p.firstname,' ',p.lastname) AS customer_name,

    s.name AS store_name

FROM sales.customer c

LEFT JOIN person.person p

ON c.personid = p.businessentityid

LEFT JOIN sales.store s

ON c.storeid = s.businessentityid;

-- Product Base View
CREATE OR REPLACE VIEW analytics.vw_product_base AS

SELECT

    p.productid,

    p.name AS product_name,

    p.productnumber,

    p.standardcost,

    p.listprice,

    p.color,

    p.size,

    sc.productsubcategoryid,

    sc.name AS subcategory,

    pc.productcategoryid,

    pc.name AS category

FROM production.product p

LEFT JOIN production.productsubcategory sc

ON p.productsubcategoryid = sc.productsubcategoryid

LEFT JOIN production.productcategory pc

ON sc.productcategoryid = pc.productcategoryid;

-- Employee Base View
CREATE OR REPLACE VIEW analytics.vw_employee_base AS

SELECT

    sp.businessentityid,

    CONCAT(pp.firstname,' ',pp.lastname) AS employee_name,

    sp.salesquota,

    sp.bonus,

    sp.commissionpct,

    sp.salesytd,

    sp.saleslastyear

FROM sales.salesperson sp

JOIN person.person pp

ON sp.businessentityid = pp.businessentityid;
--Territory base view
CREATE OR REPLACE VIEW analytics.vw_territory_base AS

SELECT

    territoryid,

    name AS territory,

    countryregioncode,

    "group"

FROM sales.salesterritory;
-- Inventory Base View
CREATE OR REPLACE VIEW analytics.vw_inventory_base AS

SELECT

    pi.productid,

    p.name AS product_name,

    pi.locationid,

    pi.quantity,

    pi.shelf,

    pi.bin

FROM production.productinventory pi

JOIN production.product p

ON pi.productid = p.productid;

--Vendor Base View
CREATE OR REPLACE VIEW analytics.vw_vendor_base AS

SELECT

    v.businessentityid,

    v.accountnumber,

    v.name,

    v.creditrating,

    v.preferredvendorstatus,

    v.activeflag

FROM purchasing.vendor v;

--Purchasing Base View
SELECT column_name
FROM information_schema.columns
WHERE table_schema='purchasing'
AND table_name='vendor'
ORDER BY ordinal_position;
--Data Analytics Base View
CREATE OR REPLACE VIEW analytics.vw_date_base AS

SELECT DISTINCT

    orderdate,

    EXTRACT(YEAR FROM orderdate) AS year,

    EXTRACT(QUARTER FROM orderdate) AS quarter,

    EXTRACT(MONTH FROM orderdate) AS month,

    TO_CHAR(orderdate,'Month') AS month_name,

    TO_CHAR(orderdate,'Day') AS day_name

FROM sales.salesorderheader;

--Executive Base View
CREATE OR REPLACE VIEW analytics.vw_executive_base AS

SELECT

    s.salesorderid,

    s.orderdate,

    c.customer_name,

    p.product_name,

    p.category,

    e.employee_name,

    t.territory,

    s.orderqty,

    s.line_total

FROM analytics.vw_sales_base s

LEFT JOIN analytics.vw_customer_base c

ON s.customerid = c.customerid

LEFT JOIN analytics.vw_product_base p

ON s.productid = p.productid

LEFT JOIN analytics.vw_employee_base e

ON s.salespersonid = e.businessentityid

LEFT JOIN analytics.vw_territory_base t

ON s.territoryid = t.territoryid;

--Column Names
SELECT column_name
FROM information_schema.columns
WHERE table_schema='sales'
AND table_name='salesorderheader'
ORDER BY ordinal_position;

SELECT column_name
FROM information_schema.columns
WHERE table_schema='production'
AND table_name='product'
ORDER BY ordinal_position;

SELECT column_name
FROM information_schema.columns
WHERE table_schema='sales'
AND table_name='customer'
ORDER BY ordinal_position;

SELECT column_name
FROM information_schema.columns
WHERE table_schema='sales'
AND table_name='salesperson'
ORDER BY ordinal_position;

SELECT column_name
FROM information_schema.columns
WHERE table_schema='production'
AND table_name='productinventory'
ORDER BY ordinal_position;

SELECT column_name
FROM information_schema.columns
WHERE table_schema='purchasing'
AND table_name='vendor'
ORDER BY ordinal_position;

--Territory Analytics
CREATE OR REPLACE VIEW analytics.territory_analytics AS
SELECT

territoryid,

name,

countryregioncode,

"group"

FROM sales.salesterritory;

--Purchasing Analytics
CREATE OR REPLACE VIEW analytics.purchase_analytics AS

SELECT

poh.purchaseorderid,

poh.vendorid,

v.name vendor_name,

poh.employeeid,

poh.orderdate,

pod.productid,

pod.orderqty,

pod.unitprice,

pod.linetotal

FROM purchasing.purchaseorderheader poh

JOIN purchasing.purchaseorderdetail pod

ON poh.purchaseorderid=pod.purchaseorderid

JOIN analytics.vendor_analytics v

ON poh.vendorid=v.businessentityid;
-- Task 01-----completed here--
-----Task 02------
--stage 01 for Completed already in task 01----
------Stage 2 Business Matrics----
---View 11 Monthly Revenue----
CREATE OR REPLACE VIEW analytics.vw_monthly_revenue AS
SELECT
    EXTRACT(YEAR FROM orderdate) AS sales_year,
    EXTRACT(MONTH FROM orderdate) AS sales_month,
    TO_CHAR(orderdate,'Month') AS month_name,
    SUM(line_total) AS monthly_revenue,
    COUNT(DISTINCT salesorderid) AS total_orders
FROM analytics.vw_sales_base
GROUP BY
    EXTRACT(YEAR FROM orderdate),
    EXTRACT(MONTH FROM orderdate),
    TO_CHAR(orderdate,'Month')
ORDER BY sales_year,sales_month;
--View 12 Quarterly revenue---
CREATE OR REPLACE VIEW analytics.vw_quarterly_revenue AS
SELECT

EXTRACT(YEAR FROM orderdate) AS sales_year,

EXTRACT(QUARTER FROM orderdate) AS sales_quarter,

SUM(line_total) AS quarterly_revenue,

COUNT(DISTINCT salesorderid) total_orders

FROM analytics.vw_sales_base

GROUP BY

EXTRACT(YEAR FROM orderdate),

EXTRACT(QUARTER FROM orderdate)

ORDER BY

sales_year,

sales_quarter;

----View 13 Sales Growth(Window Function)
CREATE OR REPLACE VIEW analytics.vw_sales_growth AS

WITH monthly_sales AS

(

SELECT

EXTRACT(YEAR FROM orderdate) sales_year,

EXTRACT(MONTH FROM orderdate) sales_month,

SUM(line_total) revenue

FROM analytics.vw_sales_base

GROUP BY

EXTRACT(YEAR FROM orderdate),

EXTRACT(MONTH FROM orderdate)

)

SELECT

sales_year,

sales_month,

revenue,

LAG(revenue) OVER
(
ORDER BY sales_year,sales_month
)

AS previous_month,

ROUND(

(
revenue-
LAG(revenue) OVER
(
ORDER BY sales_year,sales_month
)
)

/

NULLIF(

LAG(revenue) OVER
(
ORDER BY sales_year,sales_month
)

,0)

*100

,2)

AS growth_percentage

FROM monthly_sales;

--View 14 Product Performance--------
CREATE OR REPLACE VIEW analytics.vw_product_performance AS

SELECT

p.productid,

p.product_name,

p.category,

SUM(s.orderqty) total_quantity,

SUM(s.line_total) revenue,

AVG(s.unitprice) average_price

FROM analytics.vw_sales_base s

JOIN analytics.vw_product_base p

ON s.productid=p.productid

GROUP BY

p.productid,

p.product_name,

p.category;

---View 15 Product Ranking-------
CREATE OR REPLACE VIEW analytics.vw_product_ranking AS

SELECT

*,

RANK()

OVER

(

ORDER BY revenue DESC

)

AS product_rank

FROM analytics.vw_product_performance;

--View 16 Category Performance----
CREATE OR REPLACE VIEW analytics.vw_category_performance AS

SELECT

category,

SUM(revenue) total_revenue,

SUM(total_quantity) quantity_sold

FROM analytics.vw_product_performance

GROUP BY category

ORDER BY total_revenue DESC;

---------View 17 Employee Performance---------
CREATE OR REPLACE VIEW analytics.vw_employee_performance AS

SELECT

e.businessentityid,

e.employee_name,

COUNT(s.salesorderid) orders_handled,

SUM(s.line_total) revenue_generated,

AVG(s.line_total) average_sale

FROM analytics.vw_sales_base s

JOIN analytics.vw_employee_base e

ON s.salespersonid=e.businessentityid

GROUP BY

e.businessentityid,

e.employee_name;

--View 18 Employee Ranking----
CREATE OR REPLACE VIEW analytics.vw_employee_ranking AS

SELECT

*,

DENSE_RANK()

OVER

(

ORDER BY revenue_generated DESC

)

AS sales_rank

FROM analytics.vw_employee_performance;

--View 19 Customer Lifetime Value----
CREATE OR REPLACE VIEW analytics.vw_customer_lifetime_value AS

SELECT

c.customerid,

c.customer_name,

COUNT(s.salesorderid) total_orders,

SUM(s.line_total) lifetime_value,

AVG(s.line_total) average_order_value

FROM analytics.vw_sales_base s

JOIN analytics.vw_customer_base c

ON s.customerid=c.customerid

GROUP BY

c.customerid,

c.customer_name;

----View 20 Customer Segmentation (Case When)
CREATE OR REPLACE VIEW analytics.vw_customer_segments AS

SELECT

*,

CASE

WHEN lifetime_value>=100000 THEN 'VIP'

WHEN lifetime_value>=50000 THEN 'Gold'

WHEN lifetime_value>=10000 THEN 'Silver'

ELSE 'Regular'

END

AS customer_segment

FROM analytics.vw_customer_lifetime_value;

-----Part 3A — Executive KPI Datasets

--These views must be created after the Stage 1 and Stage 2 views we already built.
--1. Best Selling Products
CREATE OR REPLACE VIEW analytics.vw_best_selling_products AS
SELECT
    productid,
    product_name,
    category,
    total_quantity,
    revenue
FROM analytics.vw_product_performance
ORDER BY revenue DESC
LIMIT 20;
--Lowest Performing Products
CREATE OR REPLACE VIEW analytics.vw_lowest_performing_products AS
SELECT
    productid,
    product_name,
    category,
    total_quantity,
    revenue
FROM analytics.vw_product_performance
ORDER BY revenue ASC
LIMIT 20;
--3. Repeat Customers
CREATE OR REPLACE VIEW analytics.vw_repeat_customers AS
SELECT
    customerid,
    customer_name,
    total_orders,
    lifetime_value
FROM analytics.vw_customer_lifetime_value
WHERE total_orders > 1
ORDER BY lifetime_value DESC;
--4. Customer Retention
CREATE OR REPLACE VIEW analytics.vw_customer_retention AS

WITH yearly_customers AS
(
SELECT

EXTRACT(YEAR FROM orderdate) AS sales_year,

customerid

FROM analytics.vw_sales_base

GROUP BY

EXTRACT(YEAR FROM orderdate),

customerid
),

customer_counts AS
(
SELECT

sales_year,

COUNT(customerid) AS active_customers

FROM yearly_customers

GROUP BY sales_year
)

SELECT

sales_year,

active_customers,

LAG(active_customers)

OVER
(
ORDER BY sales_year
)

AS previous_year,

ROUND(

(active_customers::numeric/

NULLIF(

LAG(active_customers)

OVER
(
ORDER BY sales_year
)

,0)

)*100

,2)

AS retention_percentage

FROM customer_counts;
--5. Product Profitability
CREATE OR REPLACE VIEW analytics.vw_product_profitability AS

SELECT

p.productid,

p.product_name,

SUM(s.line_total) revenue,

SUM(s.orderqty*p.standardcost) total_cost,

SUM(s.line_total)-SUM(s.orderqty*p.standardcost)

AS profit

FROM analytics.vw_sales_base s

JOIN analytics.vw_product_base p

ON s.productid=p.productid

GROUP BY

p.productid,

p.product_name;
--6. Revenue Contribution
CREATE OR REPLACE VIEW analytics.vw_revenue_contribution AS

SELECT

employee_name,

revenue_generated,

ROUND(

revenue_generated/

SUM(revenue_generated)

OVER()

*100

,2)

AS contribution_percentage

FROM analytics.vw_employee_performance;
--7. Performance Comparison
CREATE OR REPLACE VIEW analytics.vw_performance_comparison AS

SELECT

employee_name,

orders_handled,

revenue_generated,

average_sale,

CASE

WHEN revenue_generated>

AVG(revenue_generated)

OVER()

THEN 'Above Average'

ELSE 'Below Average'

END

AS performance_level

FROM analytics.vw_employee_performance;
--8. Regional Revenue
CREATE OR REPLACE VIEW analytics.vw_regional_revenue AS

SELECT

    t.territory,

    SUM(s.line_total) AS revenue,

    COUNT(DISTINCT s.customerid) AS customers,

    COUNT(DISTINCT s.salesorderid) AS orders

FROM analytics.vw_sales_base s

JOIN analytics.vw_territory_base t

ON s.territoryid = t.territoryid

GROUP BY

    t.territory

ORDER BY revenue DESC;
--9. Regional Growth
CREATE OR REPLACE VIEW analytics.vw_regional_growth AS

WITH territory_month AS
(
    SELECT

        territoryid,

        EXTRACT(YEAR FROM orderdate) AS sales_year,

        EXTRACT(MONTH FROM orderdate) AS sales_month,

        SUM(line_total) AS revenue

    FROM analytics.vw_sales_base

    GROUP BY

        territoryid,

        EXTRACT(YEAR FROM orderdate),

        EXTRACT(MONTH FROM orderdate)
)

SELECT

    tm.territoryid,

    t.territory,

    tm.sales_year,

    tm.sales_month,

    tm.revenue,

    LAG(tm.revenue)

    OVER
    (
        PARTITION BY tm.territoryid
        ORDER BY tm.sales_year, tm.sales_month
    )

    AS previous_month,

    ROUND(

        (

        tm.revenue -

        LAG(tm.revenue)

        OVER
        (
            PARTITION BY tm.territoryid
            ORDER BY tm.sales_year, tm.sales_month
        )

        )

        /

        NULLIF(

        LAG(tm.revenue)

        OVER
        (
            PARTITION BY tm.territoryid
            ORDER BY tm.sales_year, tm.sales_month
        )

        ,0)

        *100

    ,2)

    AS growth_percent

FROM territory_month tm

JOIN analytics.vw_territory_base t

ON tm.territoryid=t.territoryid;
--10. Top Territories
CREATE OR REPLACE VIEW analytics.vw_top_territories AS

SELECT *

FROM analytics.vw_regional_revenue

ORDER BY revenue DESC

LIMIT 10;
--11. Lowest Performing Territories
CREATE OR REPLACE VIEW analytics.vw_lowest_territories AS

SELECT *

FROM analytics.vw_regional_revenue

ORDER BY revenue ASC

LIMIT 10;
--12. Inventory Health
CREATE OR REPLACE VIEW analytics.vw_inventory_health AS

SELECT

    productid,

    name,

    SUM(quantity) AS total_stock,

    CASE

        WHEN SUM(quantity) < 100 THEN 'Critical'

        WHEN SUM(quantity) < 500 THEN 'Low'

        ELSE 'Healthy'

    END AS stock_status

FROM analytics.vw_inventory_base

GROUP BY

    productid,

    name;
--13. Low Stock Products
CREATE OR REPLACE VIEW analytics.vw_low_stock_products AS

SELECT *

FROM analytics.vw_inventory_health

WHERE stock_status='Critical';
--14. Supplier Performance
CREATE OR REPLACE VIEW analytics.vw_supplier_performance AS

SELECT

    v.name AS vendor_name,

    COUNT(DISTINCT poh.purchaseorderid) AS total_orders,

    SUM(pod.orderqty * pod.unitprice) AS total_purchase,

    AVG(pod.orderqty * pod.unitprice) AS average_purchase

FROM purchasing.purchaseorderheader poh

JOIN purchasing.purchaseorderdetail pod

ON poh.purchaseorderid = pod.purchaseorderid

JOIN purchasing.vendor v

ON poh.vendorid = v.businessentityid

GROUP BY

    v.name

ORDER BY total_purchase DESC;
--15. Purchasing Trends
CREATE OR REPLACE VIEW analytics.vw_purchasing_trends AS

SELECT

    EXTRACT(YEAR FROM poh.orderdate) AS purchase_year,

    EXTRACT(MONTH FROM poh.orderdate) AS purchase_month,

    SUM(pod.orderqty * pod.unitprice) AS purchase_amount,

    COUNT(DISTINCT poh.purchaseorderid) AS total_orders

FROM purchasing.purchaseorderheader poh

JOIN purchasing.purchaseorderdetail pod

ON poh.purchaseorderid = pod.purchaseorderid

GROUP BY

    EXTRACT(YEAR FROM poh.orderdate),

    EXTRACT(MONTH FROM poh.orderdate)

ORDER BY

    purchase_year,

    purchase_month;
-- Task 04-----
---Example of a Chained CTE-----
WITH monthly_sales AS (
    SELECT
        EXTRACT(YEAR FROM orderdate) AS year,
        EXTRACT(MONTH FROM orderdate) AS month,
        SUM(line_total) AS revenue
    FROM analytics.vw_sales_base
    GROUP BY
        EXTRACT(YEAR FROM orderdate),
        EXTRACT(MONTH FROM orderdate)
),

growth AS (
    SELECT
        year,
        month,
        revenue,
        LAG(revenue) OVER (ORDER BY year, month) AS previous_revenue
    FROM monthly_sales
)

SELECT
    year,
    month,
    revenue,
    previous_revenue,
    ROUND(
        ((revenue - previous_revenue) / NULLIF(previous_revenue,0)) * 100,
        2
    ) AS growth_percentage
FROM growth;
--Example of Conditional Aggregation
SELECT
    territoryid,

    SUM(CASE WHEN line_total >= 1000 THEN line_total ELSE 0 END) AS high_value_sales,

    SUM(CASE WHEN line_total < 1000 THEN line_total ELSE 0 END) AS regular_sales

FROM analytics.vw_sales_base

GROUP BY territoryid;
--Example of Ranking Functions----
SELECT
    product_name,
    revenue,

    RANK() OVER (ORDER BY revenue DESC) AS product_rank,

    DENSE_RANK() OVER (ORDER BY revenue DESC) AS dense_rank,

    ROW_NUMBER() OVER (ORDER BY revenue DESC) AS row_num

FROM analytics.vw_product_performance;