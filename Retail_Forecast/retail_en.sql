USE xomdata_dataset;

-- ==============================================================================
-- DATA EXPLORATION
-- ==============================================================================
-- NOTE: Always use TOP or LIMIT when querying raw data to prevent system overload.
SELECT TOP 100 * FROM retails.sales;


-- ==============================================================================
-- YEARLY FINANCIAL PERFORMANC & YEAR-OVER-YEAR (YoY) PROFIT GROWTH
-- Objective: Calculate overall revenue, cost, and profit margin by year.
-- Objective: Analyze profit growth momentum compared to the previous year.
-- ==============================================================================

WITH YearlyData AS (
    SELECT
        YEAR(s.order_date) AS order_year,
        COUNT(DISTINCT s.order_number) AS total_orders,
        CAST(SUM(s.quantity * p.unit_price_usd) AS NUMERIC(18,2)) AS total_revenue,
        CAST(SUM(s.quantity * (p.unit_price_usd - p.unit_cost_usd)) AS NUMERIC(18,2)) AS current_profit
    FROM retails.sales AS s
    JOIN retails.products AS p
        ON s.product_key = p.product_key
    GROUP BY YEAR(s.order_date)
)
SELECT 
    order_year,
    total_orders,
    total_revenue,
    current_profit,
    LAG(current_profit) OVER(ORDER BY order_year ASC) AS last_year_profit,  
    
    -- YoY Growth (%) = ((Current - Last) / Last) * 100
    CAST(
        (current_profit - LAG(current_profit) OVER(ORDER BY order_year ASC)) * 100.0
        / NULLIF(LAG(current_profit) OVER(ORDER BY order_year ASC), 0) 
    AS NUMERIC(18,2)) AS profit_growth_yoy_pct
FROM YearlyData
ORDER BY order_year ASC;


-- ==============================================================================
-- ROW-LEVEL METRICS & OPERATION PAIN POINTS
-- Objective: Prepare granular data for dashboards (calculating delivery delays).
-- ==============================================================================
SELECT
    s.order_number,
    s.order_date,
    
    -- Handle Missing Data: Fallback to order_date if delivery_date is NULL
    COALESCE(s.delivery_date, s.order_date) AS adjusted_delivery_date,
    s.delivery_date AS original_delivery_date, -- Added alias to prevent column duplication
    
    s.customer_key,
    s.store_key,
    s.product_key,
    s.quantity,
    
    -- Row-level Financials
    CAST((s.quantity * p.unit_price_usd) AS NUMERIC(18,2)) AS revenue,
    CAST((s.quantity * p.unit_cost_usd) AS NUMERIC(18,2)) AS cost,
    CAST((s.quantity * (p.unit_price_usd - p.unit_cost_usd)) AS NUMERIC(18,2)) AS profit,
    
    -- Operational Metrics: Delivery Delay
    DATEDIFF(DAY, s.order_date, COALESCE(s.delivery_date, s.order_date)) AS delivery_delay_days,
    
    -- Channel Classification
    CASE 
        WHEN s.delivery_date IS NULL THEN 'In-Store'
        ELSE 'Online'
    END AS order_channel

FROM retails.sales AS s
JOIN retails.products AS p 
    ON s.product_key = p.product_key;


-- ==============================================================================
-- CUSTOMER COHORT & LIFETIME METRICS (RFM BASE)
-- Objective: Analyze customer behavior to support Cohort segmentation.
-- ==============================================================================
WITH SystemParams AS (
    -- Optimization: Fetch max date once instead of calculating per row.
    SELECT MAX(order_date) AS max_system_date FROM retails.sales
),
CustomerBase AS (
    SELECT 
        s.customer_key,
        MIN(s.order_date) AS first_purchase_date,
        MAX(s.order_date) AS last_purchase_date,
        CAST(SUM(s.quantity * p.unit_price_usd) AS NUMERIC(18,2)) AS lifetime_spend,
        COUNT(DISTINCT s.order_number) AS total_orders
    FROM retails.sales AS s
    JOIN retails.products AS p 
        ON s.product_key = p.product_key
    GROUP BY s.customer_key
)
SELECT 
    c.*, 
    cb.first_purchase_date,
    cb.last_purchase_date,
    cb.lifetime_spend,
    cb.total_orders,
    
    -- Customer Tenure (Months)
    DATEDIFF(MONTH, cb.first_purchase_date, sp.max_system_date) AS months_since_first_purchase
FROM retails.customers AS c
LEFT JOIN CustomerBase AS cb 
    ON c.customer_key = cb.customer_key
CROSS JOIN SystemParams AS sp;


-- ==============================================================================
-- KEY PERFORMANCE INDICATORS (KPI)
-- Objective: Track average purchasing frequency per customer.
-- ==============================================================================
WITH KPI_Base AS (
    SELECT
        COUNT(DISTINCT s.customer_key) AS total_customers,
        COUNT(DISTINCT s.order_number) AS total_orders
    FROM retails.sales AS s
)
SELECT
    -- Renamed from ARPU to avg_orders_per_customer to reflect the actual math (Orders / Customers).
    CAST((total_orders * 1.0 / NULLIF(total_customers, 0)) AS NUMERIC(18,2)) AS avg_orders_per_customer
FROM KPI_Base;


-- ==============================================================================
-- TOP 5 PERFORMING PRODUCTS PER CATEGORY
-- Objective: Support inventory planning decisions.
-- ==============================================================================
WITH ProductRankings AS (
    SELECT 
        p.category,
        p.product_name,
        SUM(s.quantity) AS total_sold_qty,
        
        -- Window function to rank top-selling products within each category.
        RANK() OVER(PARTITION BY p.category ORDER BY SUM(s.quantity) DESC) AS category_rank
    FROM retails.sales AS s
    JOIN retails.products AS p
        ON s.product_key = p.product_key
    GROUP BY 
        p.category,
        p.product_name
)
SELECT 
    category,
    product_name,
    total_sold_qty,
    category_rank
FROM ProductRankings
WHERE category_rank <= 5
ORDER BY 
    category ASC, 
    category_rank ASC;