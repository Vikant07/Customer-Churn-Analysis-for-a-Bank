/*=============================================================================
  PROJECT : Bank Customer Churn Analysis
  PURPOSE : Intermediate SQL analysis for customer churn patterns
  DATABASE: MySQL 8+ (uses backticks for identifiers)
  SOURCE  : projectdata.`raw_customer-churn-records`

  NOTE:
  - This script is designed to follow the Python EDA performed in the project.
  - It uses the original dataset column names, including `Satisfaction Score`.
  - Run the sections one at a time and review the output of each query.
  - No data is updated, deleted, or modified by this script.
=============================================================================*/

/*=============================================================================
  1. DATA PREVIEW
=============================================================================*/

-- Preview a small sample first.
SELECT *
FROM projectdata.`raw_customer-churn-records`
LIMIT 10;

-- To display the complete source table, run this separately when required:
-- SELECT * FROM projectdata.`raw_customer-churn-records`;


/*=============================================================================
  2. DATASET SIZE AND CUSTOMER CHECKS
=============================================================================*/

-- Total number of records.
SELECT
    COUNT(*) AS total_records
FROM projectdata.`raw_customer-churn-records`;

-- Check whether CustomerId is unique in the dataset.
SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT CustomerId) AS unique_customers,
    COUNT(*) - COUNT(DISTINCT CustomerId) AS repeated_customer_id_rows
FROM projectdata.`raw_customer-churn-records`;

-- Inspect possible missing values in important analysis columns.
SELECT
    SUM(CASE WHEN CustomerId IS NULL THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN Geography IS NULL THEN 1 ELSE 0 END) AS missing_geography,
    SUM(CASE WHEN Age IS NULL THEN 1 ELSE 0 END) AS missing_age,
    SUM(CASE WHEN Balance IS NULL THEN 1 ELSE 0 END) AS missing_balance,
    SUM(CASE WHEN NumOfProducts IS NULL THEN 1 ELSE 0 END) AS missing_num_of_products,
    SUM(CASE WHEN IsActiveMember IS NULL THEN 1 ELSE 0 END) AS missing_active_member,
    SUM(CASE WHEN Exited IS NULL THEN 1 ELSE 0 END) AS missing_exited
FROM projectdata.`raw_customer-churn-records`;

-- Check the values present in the main binary columns.
SELECT DISTINCT Exited
FROM projectdata.`raw_customer-churn-records`
ORDER BY Exited;

SELECT DISTINCT IsActiveMember
FROM projectdata.`raw_customer-churn-records`
ORDER BY IsActiveMember;

SELECT DISTINCT Complain
FROM projectdata.`raw_customer-churn-records`
ORDER BY Complain;


/*=============================================================================
  3. OVERALL CUSTOMER CHURN
=============================================================================*/

-- Customer count and churn distribution.
SELECT
    Exited,
    CASE
        WHEN Exited = 1 THEN 'Churned'
        WHEN Exited = 0 THEN 'Retained'
        ELSE 'Unknown / Missing'
    END AS customer_status,
    COUNT(*) AS customer_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*)
                              FROM projectdata.`raw_customer-churn-records`), 2) AS customer_percentage
FROM projectdata.`raw_customer-churn-records`
GROUP BY Exited
ORDER BY Exited;

-- Overall churn KPIs.
SELECT
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS churned_customers,
    SUM(CASE WHEN Exited = 0 THEN 1 ELSE 0 END) AS retained_customers,
    ROUND(100.0 * SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 2) AS churn_rate_pct
FROM projectdata.`raw_customer-churn-records`;


/*=============================================================================
  4. CHURN BY GEOGRAPHY
=============================================================================*/

SELECT
    Geography,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS churned_customers,
    SUM(CASE WHEN Exited = 0 THEN 1 ELSE 0 END) AS retained_customers,
    ROUND(100.0 * SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 2) AS churn_rate_pct
FROM projectdata.`raw_customer-churn-records`
GROUP BY Geography
ORDER BY churn_rate_pct DESC;


/*=============================================================================
  5. CHURN BY AGE GROUP
=============================================================================*/

SELECT
    CASE
        WHEN Age < 30 THEN 'Under 30'
        WHEN Age BETWEEN 30 AND 39 THEN '30-39'
        WHEN Age BETWEEN 40 AND 49 THEN '40-49'
        WHEN Age BETWEEN 50 AND 59 THEN '50-59'
        WHEN Age >= 60 THEN '60+'
        ELSE 'Unknown'
    END AS age_group,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(100.0 * SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 2) AS churn_rate_pct,
    ROUND(AVG(Age), 1) AS average_age
FROM projectdata.`raw_customer-churn-records`
GROUP BY age_group
ORDER BY
    CASE age_group
        WHEN 'Under 30' THEN 1
        WHEN '30-39' THEN 2
        WHEN '40-49' THEN 3
        WHEN '50-59' THEN 4
        WHEN '60+' THEN 5
        ELSE 6
    END;

-- Average and median are not both available as simple portable aggregates;
-- this query provides average age by churn status.
SELECT
    Exited,
    CASE WHEN Exited = 1 THEN 'Churned' ELSE 'Retained' END AS customer_status,
    COUNT(*) AS customer_count,
    ROUND(AVG(Age), 2) AS average_age
FROM projectdata.`raw_customer-churn-records`
GROUP BY Exited
ORDER BY Exited;


/*=============================================================================
  6. CHURN BY BALANCE GROUP
=============================================================================*/

SELECT
    CASE
        WHEN Balance = 0 THEN 'Zero Balance'
        WHEN Balance > 0 THEN 'Has Balance'
        ELSE 'Unknown'
    END AS balance_group,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(AVG(Balance), 2) AS average_balance,
    ROUND(100.0 * SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 2) AS churn_rate_pct
FROM projectdata.`raw_customer-churn-records`
GROUP BY balance_group
ORDER BY churn_rate_pct DESC;

-- Compare average account balance for retained and churned customers.
SELECT
    CASE WHEN Exited = 1 THEN 'Churned' ELSE 'Retained' END AS customer_status,
    COUNT(*) AS customer_count,
    ROUND(AVG(Balance), 2) AS average_balance,
    ROUND(MIN(Balance), 2) AS minimum_balance,
    ROUND(MAX(Balance), 2) AS maximum_balance
FROM projectdata.`raw_customer-churn-records`
GROUP BY Exited
ORDER BY Exited;


/*=============================================================================
  7. CHURN BY NUMBER OF PRODUCTS
=============================================================================*/

SELECT
    NumOfProducts,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(100.0 * SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 2) AS churn_rate_pct
FROM projectdata.`raw_customer-churn-records`
GROUP BY NumOfProducts
ORDER BY NumOfProducts;


/*=============================================================================
  8. CHURN BY ACTIVE MEMBERSHIP
=============================================================================*/

SELECT
    CASE
        WHEN IsActiveMember = 1 THEN 'Active'
        WHEN IsActiveMember = 0 THEN 'Inactive'
        ELSE 'Unknown'
    END AS membership_status,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(100.0 * SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 2) AS churn_rate_pct
FROM projectdata.`raw_customer-churn-records`
GROUP BY membership_status
ORDER BY churn_rate_pct DESC;


/*=============================================================================
  9. CHURN BY COMPLAINT STATUS — INTERPRET WITH CAUTION
=============================================================================*/

-- Explore the relationship between complaint status and churn.
SELECT
    Complain,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(100.0 * SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 2) AS churn_rate_pct
FROM projectdata.`raw_customer-churn-records`
GROUP BY Complain
ORDER BY Complain;

-- Cross-tabulation style count table.
SELECT
    Complain,
    SUM(CASE WHEN Exited = 0 THEN 1 ELSE 0 END) AS retained_customers,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS churned_customers,
    COUNT(*) AS total_customers
FROM projectdata.`raw_customer-churn-records`
GROUP BY Complain
ORDER BY Complain;

-- IMPORTANT:
-- The project EDA found Complain to be extremely closely associated with Exited.
-- Complaint timing is not established by this dataset. Treat it as a possible
-- post-outcome / leakage field, not as proof of an early churn warning signal.


/*=============================================================================
  10. CHURN BY SATISFACTION SCORE
=============================================================================*/

SELECT
    `Satisfaction Score` AS satisfaction_score,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(100.0 * SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 2) AS churn_rate_pct
FROM projectdata.`raw_customer-churn-records`
GROUP BY `Satisfaction Score`
ORDER BY satisfaction_score;


/*=============================================================================
  11. CHURN BY CARD TYPE
=============================================================================*/

SELECT
    `Card Type` AS card_type,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(100.0 * SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 2) AS churn_rate_pct
FROM projectdata.`raw_customer-churn-records`
GROUP BY `Card Type`
ORDER BY churn_rate_pct DESC;


/*=============================================================================
  12. CHURN BY GENDER
=============================================================================*/

SELECT
    Gender,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(100.0 * SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 2) AS churn_rate_pct
FROM projectdata.`raw_customer-churn-records`
GROUP BY Gender
ORDER BY churn_rate_pct DESC;


/*=============================================================================
  13. COMBINED CUSTOMER RISK SEGMENTS
=============================================================================*/

-- Simple segment view combining membership activity and balance group.
SELECT
    CASE
        WHEN IsActiveMember = 0 AND Balance > 0 THEN 'Inactive + Has Balance'
        WHEN IsActiveMember = 0 AND Balance = 0 THEN 'Inactive + Zero Balance'
        WHEN IsActiveMember = 1 AND Balance > 0 THEN 'Active + Has Balance'
        WHEN IsActiveMember = 1 AND Balance = 0 THEN 'Active + Zero Balance'
        ELSE 'Other / Unknown'
    END AS risk_segment,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(100.0 * SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 2) AS churn_rate_pct
FROM projectdata.`raw_customer-churn-records`
GROUP BY risk_segment
ORDER BY churn_rate_pct DESC;


/*=============================================================================
  14. FINAL SEGMENT SUMMARY
=============================================================================*/

-- Use this result to compare churn rate and sample size across key segments.
SELECT
    Geography,
    NumOfProducts,
    IsActiveMember,
    COUNT(*) AS total_customers,
    SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) AS churned_customers,
    ROUND(100.0 * SUM(CASE WHEN Exited = 1 THEN 1 ELSE 0 END) / NULLIF(COUNT(*), 0), 2) AS churn_rate_pct
FROM projectdata.`raw_customer-churn-records`
GROUP BY Geography, NumOfProducts, IsActiveMember
ORDER BY churn_rate_pct DESC, total_customers DESC;


/*=============================================================================
  END OF SCRIPT
=============================================================================*/
