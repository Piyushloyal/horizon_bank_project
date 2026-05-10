# Horizon Bank Ltd. — Portfolio Project

![Domain](https://img.shields.io/badge/Domain-Finance%20%2F%20Banking-1F3864?style=flat-square)
![Tools](https://img.shields.io/badge/Tools-Excel%20%7C%20PostgreSQL%20%7C%20Tableau-0F6E56?style=flat-square)
![Rows](https://img.shields.io/badge/Dataset-3000%20Rows-854F0B?style=flat-square)
![Level](https://img.shields.io/badge/Level-Fresher%20BA-534AB7?style=flat-square)

---

## Project Overview

A end-to-end project simulating a real world banking data workflow for **Horizon Bank Ltd. (FY 2024)**. The project covers the full data pipeline:

```
Raw Data (Excel)  →  Data Cleaning (Excel)  →  SQL Analysis (PostgreSQL)  →  Dashboard (Tableau)
```

---

## Files in This Repository

| File | Description |
|------|-------------|
| `Horizon_Bank_RAW.xlsx` | Raw dataset with 3000 rows — contains dirty data (invalid ages, missing amounts, blank credit scores) highlighted in orange |
| `Horizon_Bank_CLEANED.xlsx` | Cleaned dataset — all issues fixed, helper flag columns added, cleaning summary sheet included |
| `horizon_bank_queries.sql` | Full SQL script — table creation, CSV import, 3 validation queries and 14 analysis queries (Easy / Medium / Hard) |
| `README.md` | This file |

---

## Dataset Schema

| Column | Type | Description |
|--------|------|-------------|
| `Transaction_ID` | VARCHAR | Unique transaction identifier |
| `Customer_ID` | VARCHAR | Customer reference |
| `Customer_Name` | VARCHAR | Full name |
| `Age` | INT | Customer age |
| `Gender` | VARCHAR | Male / Female / Other |
| `City` | VARCHAR | 10 Indian cities |
| `Account_Type` | VARCHAR | Savings / Current / FD / RD |
| `Transaction_Date` | DATE | Date in FY2024 |
| `Transaction_Type` | VARCHAR | Deposit / Withdrawal / Transfer / EMI / UPI |
| `Amount_INR` | NUMERIC | Transaction amount in INR |
| `Loan_Type` | VARCHAR | Home / Personal / Auto / Education Loan |
| `Loan_Amount_INR` | NUMERIC | Loan principal amount |
| `Interest_Rate_Pct` | NUMERIC | Loan interest rate |
| `Loan_Status` | VARCHAR | Active / Closed / NPA / Pending |
| `Credit_Score` | INT | Customer credit score (550–850) |
| `Branch_Code` | VARCHAR | BR001 – BR008 |

---

## Data Cleaning Steps (Excel)

All cleaning was performed in Excel before importing to PostgreSQL:

1. **Duplicate Transaction IDs** — removed using Data > Remove Duplicates
2. **Invalid Age values** — ages < 18 or > 100 replaced with 30 (median proxy)
3. **Missing Amount values** — filled with median transaction amount
4. **Missing Credit Score** — filled with city wise average using AVERAGEIF
5. **Null Loan fields** — filled with `N/A` (string) or `0` (numeric)
6. **Gender standardisation** — enforced Male / Female / Other via Data Validation
7. **Amount outliers** — transactions > ₹10,00,000 flagged in `Amount_Flag` column

---

## SQL Query Summary

### Easy
| # | Query | Business Insight |
|---|-------|-----------------|
| Q1 | Total transaction count | Import validation |
| Q2 | Count by transaction type | Product usage frequency |
| Q3 | Loan amount by loan type | Portfolio composition |
| Q4 | Customer count by gender | Demographic split |

### Medium
| # | Query | Business Insight |
|---|-------|-----------------|
| Q5 | Monthly trend | Seasonal forecasting |
| Q6 | Avg credit score by city | City-level risk profiling |
| Q7 | NPA by city + loan type | Bad loan hotspots |
| Q8 | Deposits vs withdrawals by account | Cash flow by product |
| Q9 | Branch performance | Operational benchmarking |
| Q10 | Interest rate banding | Risk pricing analysis |

### Hard
| # | Query | Business Insight |
|---|-------|-----------------|
| Q11 | Top 10 customers by value | High-value customer targeting |
| Q12 | Cumulative deposits (Window fn) | Deposit growth trajectory |
| Q13 | City NPA rate ranking (RANK) | Risk exposure league table |
| Q14 | Credit score segmentation | Multi-dimension customer profiling |

---

## How to Run

### PostgreSQL Setup
```sql
-- 1. Create database in pgAdmin
-- Name: horizon_bank_db

-- 2. Run CREATE TABLE from horizon_bank_queries.sql

-- 3. Import cleaned CSV
COPY horizon_bank_transactions
FROM 'C:/your_path/Horizon_Bank_CLEANED.csv'
WITH (FORMAT CSV, HEADER TRUE, DELIMITER ',', ENCODING 'UTF8');

-- 4. Run validation queries (Q1–Q3 in the .sql file)

-- 5. Run analysis queries (Q4–Q14)
```

---

## Tools Used

- **Microsoft Excel** — Data generation, cleaning and validation
- **PostgreSQL + pgAdmin 4** — Relational database and SQL analysis
- **Tableau** *(coming soon)* — Interactive dashboard and data visualisation

---

## Key Skills Demonstrated

- Requirements understanding and data scoping
- Data quality assessment and cleaning documentation
- SQL querying at multiple complexity levels
- Business insight generation from raw data
- Structured project documentation

---

## Author

**Business Analyst Portfolio Project**  
Domain: Finance / Banking
