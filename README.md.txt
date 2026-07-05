                              Pakistan Mobile Sales Analysis — SQL Portfolio Project

📌 Project Overview

This project analyzes 3,835 mobile phone sales transactions across 19 major cities of Pakistan
from 2021 to 2024 using PostgreSQL. The goal is to extract meaningful business insights
from raw sales data using SQL — ranging from basic aggregations to advanced window functions and CTEs.


📊 Dataset Details

DetailValueTotal Rows3,835 transactionsTime PeriodOctober 2021 – October 2024BrandsApple, Samsung, Xiaomi, Vivo, OnePlusMobile Models15 modelsCities Covered19 cities across PakistanPayment MethodsCash, Easypaisa, JazzCash, Credit Card, Bank TransferData Prepared InMicrosoft Excel


🏙️ Cities Covered

Karachi, Lahore, Islamabad, Rawalpindi, Peshawar, Quetta, Multan,
Faisalabad, Sialkot, Gujranwala, Hyderabad, Abbottabad, Bahawalpur,
Sargodha, Sukkur, Sahiwal, Mardan, Sheikhupura, Gujrat


🛠️ Tools Used


PostgreSQL — Database & query execution
pgAdmin 4 — SQL interface
Microsoft Excel — Data cleaning & preparation
Git & GitHub — Version control & portfolio hosting



📁 Project Files

FileDescriptionREADME.mdProject overview and documentationschema.sqlCREATE TABLE statement with column definitionsqueries.sql30 SQL questions from Basic to Advanced with answersPakistan_Mobile_Sales_Data.csvRaw cleaned dataset


🔍 SQL Concepts Covered

Basic


DDL: CREATE TABLE, data types
SELECT, WHERE, ORDER BY, LIMIT
Aggregations: SUM, AVG, COUNT, MIN, MAX
GROUP BY with multiple columns
DISTINCT for unique values
CASE WHEN for conditional grouping


Intermediate


HAVING — filtering on aggregated values
Subqueries in WHERE and HAVING
EXTRACT() and DATE_TRUNC() for date intelligence
STRING_AGG() for concatenation
NOT IN for exclusion logic
Conditional aggregation (manual PIVOT)


Advanced


Window Functions: RANK(), DENSE_RANK(), ROW_NUMBER(), NTILE(), LAG()
PARTITION BY for within-group calculations
ROWS BETWEEN for moving averages
CTEs (Common Table Expressions)
Multi-CTE chaining with JOIN
Year-over-Year and Month-over-Month growth analysis



💡 Key Business Questions Answered


Which brand generates the highest total revenue?
How does each brand's market share change year by year?
Which city has the most dominant brand (>40% share)?
Who are the top customers in each city?
What is the month-over-month and year-over-year revenue growth?
Which customers churned (bought in 2021–22 but not in 2023–24)?
What is the best quarter for each brand?
How do customers segment by spending (Premium / High / Medium / Low)?
Full executive KPI dashboard in a single query



📈 Sample Insight


Using LAG() window function, this project tracks month-over-month revenue trends
across 4 years — identifying seasonal peaks and growth patterns per brand.


👤 Author

Hammad
Junior Data Analyst | SQL · Excel · Power BI

This project is part of my data analytics portfolio built to demonstrate
real-world SQL skills for junior data analyst roles.
