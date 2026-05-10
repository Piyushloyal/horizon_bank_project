-- ============================================================
--  Horizon Bank Ltd. — BA Project SQL Query Bank
--  Database : horizon_bank_db
--  Table    : horizon_bank_transactions
--  Author   : Business Analyst Portfolio Project
--  FY       : 2024
-- ============================================================


-- ============================================================
--  STEP 1 — CREATE TABLE
-- ============================================================

CREATE TABLE horizon_bank_transactions (
    transaction_id    VARCHAR(10)   PRIMARY KEY,
    customer_id       VARCHAR(10),
    customer_name     VARCHAR(100),
    age               INT,
    gender            VARCHAR(10),
    city              VARCHAR(50),
    account_type      VARCHAR(30),
    transaction_date  DATE,
    transaction_type  VARCHAR(20),
    amount_inr        NUMERIC(12,2),
    loan_type         VARCHAR(30),
    loan_amount_inr   NUMERIC(12,2),
    interest_rate_pct NUMERIC(5,2),
    loan_status       VARCHAR(20),
    credit_score      INT,
    branch_code       VARCHAR(10)
);


-- ============================================================
--  STEP 2 — IMPORT CSV
--  Update the path before running
-- ============================================================

COPY horizon_bank_transactions
FROM 'C:/BA_Project/horizon_bank_clean.csv'
WITH (
    FORMAT    CSV,
    HEADER    TRUE,
    DELIMITER ',',
    ENCODING  'UTF8'
);


-- ============================================================
--  STEP 3 — VALIDATE IMPORT
-- ============================================================

-- 1. Row count (should be 3000)
SELECT COUNT(*) AS total_rows
FROM horizon_bank_transactions;

-- 2. Spot check first 5 rows
SELECT *
FROM horizon_bank_transactions
LIMIT 5;

-- 3. Unique cities (should be 10)
SELECT DISTINCT city
FROM horizon_bank_transactions
ORDER BY city;


-- ============================================================
--  ANALYSIS QUERIES
--  EASY (Q1 – Q4)
-- ============================================================

-- Q1. Total number of transactions
-- Insight: Baseline count — confirms import success
SELECT COUNT(*) AS total_transactions
FROM horizon_bank_transactions;


-- Q2. Transaction count by type
-- Insight: Which transaction type is most frequent
SELECT transaction_type,
       COUNT(*) AS txn_count
FROM horizon_bank_transactions
GROUP BY transaction_type
ORDER BY txn_count DESC;


-- Q3. Total loan amount disbursed by loan type
-- Insight: Which loan product carries the highest portfolio value
SELECT loan_type,
       ROUND(SUM(loan_amount_inr), 2) AS total_loan_amount
FROM horizon_bank_transactions
WHERE loan_type IS NOT NULL
  AND loan_type != 'N/A'
GROUP BY loan_type
ORDER BY total_loan_amount DESC;


-- Q4. Customer count by gender
-- Insight: Demographic split for product targeting
SELECT gender,
       COUNT(DISTINCT customer_id) AS unique_customers
FROM horizon_bank_transactions
GROUP BY gender
ORDER BY unique_customers DESC;


-- ============================================================
--  MEDIUM (Q5 – Q10)
-- ============================================================

-- Q5. Monthly transaction volume and amount trend
-- Insight: Seasonal patterns for forecasting and capacity planning
SELECT TO_CHAR(transaction_date, 'YYYY-MM') AS month,
       COUNT(*)                              AS txn_count,
       ROUND(SUM(amount_inr), 2)            AS total_amount
FROM horizon_bank_transactions
GROUP BY month
ORDER BY month;


-- Q6. Average credit score by city
-- Insight: Cities with stronger or riskier customer bases
SELECT city,
       ROUND(AVG(credit_score), 0)          AS avg_credit_score,
       COUNT(DISTINCT customer_id)          AS unique_customers
FROM horizon_bank_transactions
WHERE credit_score IS NOT NULL
GROUP BY city
ORDER BY avg_credit_score DESC;


-- Q7. NPA loans breakdown by type and city
-- Insight: Which city + loan type combo has highest bad loan concentration
SELECT city,
       loan_type,
       COUNT(*)                             AS npa_count,
       ROUND(SUM(loan_amount_inr), 2)      AS npa_value
FROM horizon_bank_transactions
WHERE loan_status = 'NPA'
GROUP BY city, loan_type
ORDER BY npa_value DESC;


-- Q8. Account type — deposit vs withdrawal comparison
-- Insight: Which account type drives more inflow vs outflow
SELECT account_type,
       ROUND(SUM(CASE WHEN transaction_type = 'Deposit'
                      THEN amount_inr ELSE 0 END), 2)    AS total_deposits,
       ROUND(SUM(CASE WHEN transaction_type = 'Withdrawal'
                      THEN amount_inr ELSE 0 END), 2)    AS total_withdrawals
FROM horizon_bank_transactions
GROUP BY account_type
ORDER BY total_deposits DESC;


-- Q9. Branch-wise performance summary
-- Insight: Compares branches on volume, amount, and customer reach
SELECT branch_code,
       COUNT(*)                             AS total_transactions,
       ROUND(SUM(amount_inr), 2)           AS total_amount,
       ROUND(AVG(amount_inr), 2)           AS avg_txn_amount,
       COUNT(DISTINCT customer_id)         AS unique_customers
FROM horizon_bank_transactions
GROUP BY branch_code
ORDER BY total_amount DESC;


-- Q10. Interest rate band analysis
-- Insight: Segments loans into low/medium/high buckets for risk pricing
SELECT CASE
           WHEN interest_rate_pct < 9  THEN 'Low (< 9%)'
           WHEN interest_rate_pct < 12 THEN 'Medium (9-12%)'
           ELSE                             'High (> 12%)'
       END                                 AS rate_band,
       COUNT(*)                            AS loan_count,
       ROUND(AVG(loan_amount_inr), 2)     AS avg_loan_amount
FROM horizon_bank_transactions
WHERE interest_rate_pct IS NOT NULL
GROUP BY rate_band
ORDER BY loan_count DESC;


-- ============================================================
--  HARD (Q11 – Q14)
-- ============================================================

-- Q11. Top 10 customers by total transaction value
-- Insight: High-value customers for relationship management and upselling
SELECT customer_id,
       customer_name,
       COUNT(*)                            AS txn_count,
       ROUND(SUM(amount_inr), 2)          AS total_txn_value,
       ROUND(AVG(credit_score), 0)        AS avg_credit_score
FROM horizon_bank_transactions
GROUP BY customer_id, customer_name
ORDER BY total_txn_value DESC
LIMIT 10;


-- Q12. Running cumulative deposit total by month (Window Function)
-- Insight: Deposit growth trajectory over the year
SELECT month,
       monthly_deposits,
       SUM(monthly_deposits) OVER (
           ORDER BY month
       ) AS cumulative_deposits
FROM (
    SELECT TO_CHAR(transaction_date, 'YYYY-MM') AS month,
           ROUND(SUM(amount_inr), 2)            AS monthly_deposits
    FROM horizon_bank_transactions
    WHERE transaction_type = 'Deposit'
    GROUP BY month
) AS monthly
ORDER BY month;


-- Q13. Rank cities by NPA rate (Window Function + Subquery)
-- Insight: NPA exposure ratio per city — key risk KPI
SELECT city,
       total_loans,
       npa_loans,
       ROUND((npa_loans * 100.0 / NULLIF(total_loans, 0)), 2) AS npa_rate_pct,
       RANK() OVER (
           ORDER BY (npa_loans * 1.0 / NULLIF(total_loans, 0)) DESC
       ) AS risk_rank
FROM (
    SELECT city,
           COUNT(*)                                            AS total_loans,
           COUNT(*) FILTER (WHERE loan_status = 'NPA')        AS npa_loans
    FROM horizon_bank_transactions
    WHERE loan_type != 'N/A'
    GROUP BY city
) AS loan_summary
ORDER BY risk_rank;


-- Q14. Customer segmentation by credit score band (CASE + Multi-Aggregation)
-- Insight: Maps credit quality to loan behaviour and NPA exposure
SELECT CASE
           WHEN credit_score >= 750 THEN 'Excellent (750+)'
           WHEN credit_score >= 700 THEN 'Good (700-749)'
           WHEN credit_score >= 650 THEN 'Fair (650-699)'
           ELSE                          'Poor (< 650)'
       END                               AS credit_band,
       COUNT(DISTINCT customer_id)      AS customer_count,
       ROUND(AVG(loan_amount_inr), 2)  AS avg_loan_amount,
       COUNT(*) FILTER (WHERE loan_status = 'NPA') AS npa_count,
       ROUND(AVG(amount_inr), 2)       AS avg_txn_amount
FROM horizon_bank_transactions
WHERE credit_score IS NOT NULL
GROUP BY credit_band
ORDER BY MIN(credit_score) DESC;
