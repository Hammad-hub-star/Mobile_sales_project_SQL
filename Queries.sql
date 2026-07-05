-- ============================================================
-- PROJECT  : Pakistan Mobile Sales Analysis
-- FILE     : queries.sql
-- DATABASE : PostgreSQL
-- AUTHOR   : Hammad
-- DATASET  : 3,835 rows | 2021-2024 | 19 cities | 5 brands
-- TABLE    : mobile_sales
-- ============================================================


-- Q01: How many unique customers are in the dataset?
-- Concept: COUNT DISTINCT

SELECT COUNT(DISTINCT customer_name) AS unique_customers
FROM mobile_sales;


-- Q02: Compare weekend vs weekday transaction count and revenue
-- Concept: CASE WHEN, GROUP BY

SELECT
    CASE
        WHEN day_name IN ('Saturday', 'Sunday') THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_type,
    COUNT(*) AS transactions,
    ROUND(SUM(units_sold * price_per_unit)::NUMERIC, 2) AS total_revenue
FROM mobile_sales
GROUP BY day_type
ORDER BY total_revenue DESC;


-- Q03: Find top 3 most expensive mobile models by average price
-- Concept: AVG, GROUP BY, ORDER BY DESC, LIMIT

SELECT mobile_model, brand,
       ROUND(AVG(price_per_unit)::NUMERIC, 2) AS average_price
FROM mobile_sales
GROUP BY mobile_model, brand
ORDER BY average_price DESC
LIMIT 3;


-- Q04: How many distinct mobile models does each brand offer?
-- Concept: COUNT DISTINCT inside GROUP BY

SELECT brand,
       COUNT(DISTINCT mobile_model) AS model_count
FROM mobile_sales
GROUP BY brand
ORDER BY model_count DESC;


-- Q05: Show quarterly revenue breakdown for each year (Q1/Q2/Q3/Q4)
-- Concept: EXTRACT from DATE, CASE WHEN for bucketing

SELECT
    EXTRACT(YEAR FROM sales_date) AS sales_year,
    CASE
        WHEN EXTRACT(MONTH FROM sales_date) BETWEEN 1 AND 3 THEN 'Q1 (Jan-Mar)'
        WHEN EXTRACT(MONTH FROM sales_date) BETWEEN 4 AND 6 THEN 'Q2 (Apr-Jun)'
        WHEN EXTRACT(MONTH FROM sales_date) BETWEEN 7 AND 9 THEN 'Q3 (Jul-Sep)'
        ELSE                                                      'Q4 (Oct-Dec)'
    END AS quarter,
    ROUND(SUM(units_sold * price_per_unit)::NUMERIC, 2) AS revenue
FROM mobile_sales
GROUP BY sales_year, quarter
ORDER BY sales_year, quarter;


-- Q06: Which payment method has the highest average customer rating?
-- Concept: AVG, GROUP BY, ORDER BY

SELECT payment_method,
       ROUND(AVG(customer_ratings)::NUMERIC, 2) AS avg_rating,
       COUNT(*) AS total_transactions
FROM mobile_sales
GROUP BY payment_method
ORDER BY avg_rating DESC;


-- Q07: Find all transactions where customer rating is below the overall average
-- Concept: Subquery in WHERE clause

SELECT transaction_id, customer_name, brand,
       mobile_model, customer_ratings, city
FROM mobile_sales
WHERE customer_ratings < (
    SELECT AVG(customer_ratings)
    FROM mobile_sales
)
ORDER BY customer_ratings ASC;


-- Q08: What is the total units sold and revenue per mobile model?
-- Concept: Multiple aggregations in one GROUP BY

SELECT mobile_model, brand,
       SUM(units_sold)  AS total_units,
       COUNT(*)         AS total_transactions,
       ROUND(SUM(units_sold * price_per_unit)::NUMERIC, 2) AS total_revenue
FROM mobile_sales
GROUP BY mobile_model, brand
ORDER BY total_revenue DESC;


-- Q09: Which cities were active in all 4 years (2021-2024)?
-- Concept: HAVING + COUNT DISTINCT on date part

SELECT city,
       COUNT(DISTINCT EXTRACT(YEAR FROM sales_date)) AS years_active
FROM mobile_sales
GROUP BY city
HAVING COUNT(DISTINCT EXTRACT(YEAR FROM sales_date)) = 4
ORDER BY city;


-- Q10: Calculate revenue per unit sold for each brand
-- Concept: Division of two aggregated values (efficiency metric)

SELECT brand,
       ROUND(SUM(units_sold * price_per_unit)::NUMERIC, 2) AS total_revenue,
       SUM(units_sold) AS total_units,
       ROUND(
           (SUM(units_sold * price_per_unit) / SUM(units_sold))::NUMERIC, 2
       ) AS revenue_per_unit
FROM mobile_sales
GROUP BY brand
ORDER BY revenue_per_unit DESC;


-- Q11: Compare Cash vs Digital payments — revenue and average order value
-- Concept: CASE WHEN for grouping then aggregate

SELECT
    CASE
        WHEN payment_method = 'Cash' THEN 'Cash'
        ELSE 'Digital'
    END AS payment_type,
    COUNT(*) AS transactions,
    ROUND(SUM(units_sold * price_per_unit)::NUMERIC, 2) AS total_revenue,
    ROUND(AVG(units_sold * price_per_unit)::NUMERIC, 2) AS avg_order_value,
    ROUND(AVG(customer_ratings)::NUMERIC, 2) AS avg_rating
FROM mobile_sales
GROUP BY payment_type
ORDER BY total_revenue DESC;


-- Q12: Find brands where average transaction value exceeds 35,000 PKR
-- Concept: HAVING — filtering on aggregated values

SELECT brand,
       ROUND(AVG(units_sold * price_per_unit)::NUMERIC, 2) AS avg_order_value,
       COUNT(*) AS total_transactions
FROM mobile_sales
GROUP BY brand
HAVING AVG(units_sold * price_per_unit) > 35000
ORDER BY avg_order_value DESC;


-- Q13: Show year-wise market share (%) for each brand
-- Concept: SUM() OVER (PARTITION BY) — window inside aggregate

SELECT
    EXTRACT(YEAR FROM sales_date) AS sales_year,
    brand,
    ROUND(SUM(units_sold * price_per_unit)::NUMERIC, 2) AS revenue,
    ROUND(
        (SUM(units_sold * price_per_unit) /
         SUM(SUM(units_sold * price_per_unit))
         OVER (PARTITION BY EXTRACT(YEAR FROM sales_date)) * 100)::NUMERIC, 2
    ) AS market_share_pct
FROM mobile_sales
GROUP BY sales_year, brand
ORDER BY sales_year, market_share_pct DESC;


-- Q14: Find customers who purchased from more than one brand
-- Concept: HAVING + COUNT DISTINCT + STRING_AGG

SELECT customer_name,
       COUNT(DISTINCT brand) AS brands_bought,
       STRING_AGG(DISTINCT brand, ', ' ORDER BY brand) AS brand_list,
       COUNT(*) AS total_transactions
FROM mobile_sales
GROUP BY customer_name
HAVING COUNT(DISTINCT brand) > 1
ORDER BY brands_bought DESC, total_transactions DESC;


-- Q15: Which month is consistently the strongest across all years?
-- Concept: CTE + two-level GROUP BY for seasonal pattern

WITH monthly AS (
    SELECT
        EXTRACT(YEAR  FROM sales_date) AS yr,
        EXTRACT(MONTH FROM sales_date) AS mth,
        SUM(units_sold * price_per_unit) AS revenue
    FROM mobile_sales
    GROUP BY yr, mth
)
SELECT mth AS month_number,
       ROUND(AVG(revenue)::NUMERIC, 2) AS avg_revenue_across_years
FROM monthly
GROUP BY mth
ORDER BY avg_revenue_across_years DESC;


-- Q16: Find models that generate above-average revenue per transaction
-- Concept: HAVING with scalar subquery

SELECT mobile_model, brand,
       ROUND(AVG(units_sold * price_per_unit)::NUMERIC, 2) AS avg_txn_revenue,
       COUNT(*) AS transactions
FROM mobile_sales
GROUP BY mobile_model, brand
HAVING AVG(units_sold * price_per_unit) > (
    SELECT AVG(units_sold * price_per_unit)
    FROM mobile_sales
)
ORDER BY avg_txn_revenue DESC;


-- Q17: Build a pivot table — each brand's revenue broken down by city
-- Concept: Conditional aggregation / manual PIVOT using CASE WHEN

SELECT city,
    ROUND(SUM(CASE WHEN brand = 'Apple'   THEN units_sold * price_per_unit ELSE 0 END)::NUMERIC, 2) AS Apple,
    ROUND(SUM(CASE WHEN brand = 'Samsung' THEN units_sold * price_per_unit ELSE 0 END)::NUMERIC, 2) AS Samsung,
    ROUND(SUM(CASE WHEN brand = 'Xiaomi'  THEN units_sold * price_per_unit ELSE 0 END)::NUMERIC, 2) AS Xiaomi,
    ROUND(SUM(CASE WHEN brand = 'Vivo'    THEN units_sold * price_per_unit ELSE 0 END)::NUMERIC, 2) AS Vivo,
    ROUND(SUM(CASE WHEN brand = 'OnePlus' THEN units_sold * price_per_unit ELSE 0 END)::NUMERIC, 2) AS OnePlus,
    ROUND(SUM(units_sold * price_per_unit)::NUMERIC, 2) AS city_total
FROM mobile_sales
GROUP BY city
ORDER BY city_total DESC;


-- Q18: Identify churned customers (bought in 2021-2022 but NOT in 2023-2024)
-- Concept: NOT IN with subquery — set difference logic

SELECT DISTINCT customer_name
FROM mobile_sales
WHERE EXTRACT(YEAR FROM sales_date) IN (2021, 2022)
  AND customer_name NOT IN (
      SELECT DISTINCT customer_name
      FROM mobile_sales
      WHERE EXTRACT(YEAR FROM sales_date) IN (2023, 2024)
  )
ORDER BY customer_name;


-- Q19: Find the revenue gap between the #1 and #2 brand
-- Concept: RANK() + conditional aggregation

WITH brand_rev AS (
    SELECT brand,
           ROUND(SUM(units_sold * price_per_unit)::NUMERIC, 2) AS revenue,
           RANK() OVER (ORDER BY SUM(units_sold * price_per_unit) DESC) AS rnk
    FROM mobile_sales
    GROUP BY brand
)
SELECT
    MAX(CASE WHEN rnk = 1 THEN brand   END) AS top_brand,
    MAX(CASE WHEN rnk = 1 THEN revenue END) AS top_revenue,
    MAX(CASE WHEN rnk = 2 THEN brand   END) AS second_brand,
    MAX(CASE WHEN rnk = 2 THEN revenue END) AS second_revenue,
    MAX(CASE WHEN rnk = 1 THEN revenue END) -
    MAX(CASE WHEN rnk = 2 THEN revenue END) AS revenue_gap
FROM brand_rev
WHERE rnk <= 2;


-- Q20: Find the top customer by total spend in each city using ROW_NUMBER()
-- Concept: ROW_NUMBER() + PARTITION BY — most important window function

WITH city_spend AS (
    SELECT city, customer_name,
           ROUND(SUM(units_sold * price_per_unit)::NUMERIC, 2) AS total_spent,
           ROW_NUMBER() OVER (
               PARTITION BY city
               ORDER BY SUM(units_sold * price_per_unit) DESC
           ) AS rn
    FROM mobile_sales
    GROUP BY city, customer_name
)
SELECT city, customer_name, total_spent
FROM city_spend
WHERE rn = 1
ORDER BY total_spent DESC;


-- Q21: Calculate month-over-month revenue growth % using LAG()
-- Concept: LAG() — accessing the previous row's value

WITH monthly AS (
    SELECT DATE_TRUNC('month', sales_date)::DATE AS month,
           SUM(units_sold * price_per_unit) AS revenue
    FROM mobile_sales
    GROUP BY month
)
SELECT month,
       ROUND(revenue::NUMERIC, 2) AS revenue,
       LAG(ROUND(revenue::NUMERIC, 2)) OVER (ORDER BY month) AS prev_month_revenue,
       ROUND(
           ((revenue - LAG(revenue) OVER (ORDER BY month)) /
            LAG(revenue) OVER (ORDER BY month) * 100)::NUMERIC, 2
       ) AS mom_growth_pct
FROM monthly
ORDER BY month;


-- Q22: Calculate year-over-year growth for each brand using LAG() + PARTITION BY
-- Concept: LAG() + PARTITION BY — grouped time-series comparison

WITH yearly AS (
    SELECT brand,
           EXTRACT(YEAR FROM sales_date) AS yr,
           SUM(units_sold * price_per_unit) AS revenue
    FROM mobile_sales
    GROUP BY brand, yr
)
SELECT brand, yr,
       ROUND(revenue::NUMERIC, 2) AS revenue,
       ROUND(
           ((revenue - LAG(revenue) OVER (PARTITION BY brand ORDER BY yr)) /
            LAG(revenue) OVER (PARTITION BY brand ORDER BY yr) * 100)::NUMERIC, 2
       ) AS yoy_growth_pct
FROM yearly
ORDER BY brand, yr;


-- Q23: Find the brand that dominates each city (more than 40% revenue share)
-- Concept: Window percentage + CTE filter

WITH city_brand AS (
    SELECT city, brand,
           ROUND(SUM(units_sold * price_per_unit)::NUMERIC, 2) AS revenue,
           ROUND(
               SUM(units_sold * price_per_unit) /
               SUM(SUM(units_sold * price_per_unit)) OVER (PARTITION BY city) * 100
           ::NUMERIC, 2) AS city_share_pct
    FROM mobile_sales
    GROUP BY city, brand
)
SELECT city, brand, revenue, city_share_pct
FROM city_brand
WHERE city_share_pct > 40
ORDER BY city_share_pct DESC;


-- Q24: Cumulative running total revenue share for all brands (Pareto analysis)
-- Concept: Two SUM() OVER() — one for total, one for running cumulative

WITH brand_rev AS (
    SELECT brand,
           ROUND(SUM(units_sold * price_per_unit)::NUMERIC, 2) AS revenue
    FROM mobile_sales
    GROUP BY brand
)
SELECT brand,
       revenue,
       ROUND(revenue / SUM(revenue) OVER () * 100::NUMERIC, 2) AS share_pct,
       ROUND(
           SUM(revenue) OVER (ORDER BY revenue DESC) /
           SUM(revenue) OVER () * 100
       ::NUMERIC, 2) AS cumulative_share_pct
FROM brand_rev
ORDER BY revenue DESC;


-- Q25: Find the best performing quarter for each brand using DENSE_RANK()
-- Concept: DENSE_RANK() + PARTITION BY — rank within group without gaps

WITH qtr AS (
    SELECT brand,
           CASE
               WHEN EXTRACT(MONTH FROM sales_date) BETWEEN 1 AND 3 THEN 'Q1'
               WHEN EXTRACT(MONTH FROM sales_date) BETWEEN 4 AND 6 THEN 'Q2'
               WHEN EXTRACT(MONTH FROM sales_date) BETWEEN 7 AND 9 THEN 'Q3'
               ELSE 'Q4'
           END AS quarter,
           SUM(units_sold * price_per_unit) AS revenue,
           DENSE_RANK() OVER (
               PARTITION BY brand
               ORDER BY SUM(units_sold * price_per_unit) DESC
           ) AS dr
    FROM mobile_sales
    GROUP BY brand, quarter
)
SELECT brand,
       quarter AS best_quarter,
       ROUND(revenue::NUMERIC, 2) AS revenue
FROM qtr
WHERE dr = 1
ORDER BY revenue DESC;


-- Q26: Identify the fastest-growing brand each year
-- Concept: Multi-CTE chain — LAG + RANK combined

WITH yr_rev AS (
    SELECT brand,
           EXTRACT(YEAR FROM sales_date) AS yr,
           SUM(units_sold * price_per_unit) AS revenue
    FROM mobile_sales
    GROUP BY brand, yr
),
growth AS (
    SELECT brand, yr, revenue,
           ROUND(
               ((revenue - LAG(revenue) OVER (PARTITION BY brand ORDER BY yr)) /
                LAG(revenue) OVER (PARTITION BY brand ORDER BY yr) * 100)::NUMERIC, 2
           ) AS yoy_growth_pct
    FROM yr_rev
),
ranked AS (
    SELECT *,
           RANK() OVER (PARTITION BY yr ORDER BY yoy_growth_pct DESC) AS growth_rank
    FROM growth
    WHERE yoy_growth_pct IS NOT NULL
)
SELECT yr        AS sales_year,
       brand     AS fastest_growing_brand,
       ROUND(revenue::NUMERIC, 2) AS revenue,
       yoy_growth_pct
FROM ranked
WHERE growth_rank = 1
ORDER BY yr;