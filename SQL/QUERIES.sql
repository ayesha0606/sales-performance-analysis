-- =====================================
-- Query 1: Total Sales, Profit, Orders
-- =====================================
SELECT 
    ROUND(SUM(sales),2) AS total_sales,
    ROUND(SUM(profit),2) AS total_profit,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders;
-- =====================================
-- Query 2: Monthly Sales Trend
-- =====================================
SELECT
    DATE_TRUNC('month', order_date) AS month,
    ROUND(SUM(sales),2) AS monthly_sales
FROM orders
GROUP BY 1
ORDER BY 1;
-- =====================================
-- Query 3: Month-over-Month Growth
-- =====================================
WITH monthly_sales AS (
    SELECT
        DATE_TRUNC('month', order_date) AS month,
        SUM(sales) AS sales
    FROM orders
    GROUP BY 1
)
SELECT
    month,
    ROUND(sales,2) AS sales,
    ROUND(
        (sales - LAG(sales) OVER (ORDER BY month)) /
        LAG(sales) OVER (ORDER BY month) * 100
    ,2) AS mom_growth_pct
FROM monthly_sales;
-- =====================================
-- Query 4: Top 10 Products by Revenue
-- =====================================
SELECT
    p.product_name,
    ROUND(SUM(o.sales),2) AS total_sales
FROM orders o
JOIN products p ON o.product_id = p.product_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
-- =====================================
-- Query 5: Region-wise Sales & Profit
-- =====================================
SELECT
    c.region,
    ROUND(SUM(o.sales),2) AS revenue,
    ROUND(SUM(o.profit),2) AS profit
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY 1
ORDER BY 2 DESC;
-- =====================================
-- Query 6: Average Order Value (AOV)
-- =====================================
SELECT
    ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS avg_order_value
FROM orders;
-- =====================================
-- Query 7: Customer Repeat Rate
-- =====================================
WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id) AS total_orders
    FROM orders
    GROUP BY customer_id
)
SELECT
    ROUND(
        COUNT(CASE WHEN total_orders > 1 THEN 1 END) * 100.0
        / COUNT(*)
    ,2) AS repeat_customer_rate_pct
FROM customer_orders;
-- =====================================
-- Query 8: Top 10 Customers by Revenue
-- =====================================
SELECT
    c.customer_name,
    ROUND(SUM(o.sales),2) AS total_sales
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;
-- =====================================
-- Query 9: Pareto Analysis (80/20 Rule)
-- =====================================
WITH customer_revenue AS (
    SELECT
        customer_id,
        SUM(sales) AS revenue
    FROM orders
    GROUP BY customer_id
),
ranked_customers AS (
    SELECT
        customer_id,
        revenue,
        SUM(revenue) OVER () AS total_revenue,
        SUM(revenue) OVER (ORDER BY revenue DESC) AS cumulative_revenue
    FROM customer_revenue
)
SELECT
    customer_id,
    ROUND(revenue,2) AS revenue,
    ROUND(cumulative_revenue / total_revenue * 100,2) AS cumulative_pct
FROM ranked_customers
ORDER BY revenue DESC;
