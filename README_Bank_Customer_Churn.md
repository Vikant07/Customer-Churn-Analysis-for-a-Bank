# Bank Customer Churn Analysis

**Portfolio Project \| Customer Retention Risk Analytics**

An evidence-led analysis of historical bank customer churn to identify
customer segments with elevated exit rates, understand observed
patterns, and recommend where retention teams should investigate first.

> **Management question:** Which customer segments show elevated
> historical churn, and where should the bank investigate before
> designing targeted retention interventions?

## Project Overview

This project analyses a supplied bank customer dataset containing
**10,000 customer records** and **18 columns**. The target field is
`Exited`, where `1` represents a customer who exited and `0` represents
a retained customer.

The analysis covers geography, age, product holding, engagement, account
balance, gender, card type and satisfaction score. It combines
data-quality checks, exploratory data analysis (EDA), statistical tests,
SQL query review and a Power BI dashboard review.

### Headline Results

  Metric                            Result
  ------------------------------- --------
  Total customer records            10,000
  Customers exited                   2,038
  Historical churn rate             20.38%
  Geographies                            3
  Unique customer IDs               10,000
  Missing values in source data          0
  Exact duplicate rows                   0

## Key Findings

### 1. Geography

-   Germany has a historical churn rate of **32.44%** (814 of 2,509
    customers).
-   Spain records **16.67%** (413 of 2,477).
-   France records **16.17%** (811 of 5,014).
-   Germany is the clearest geographic outlier and merits a focused
    diagnostic.

### 2. Age

-   Customers aged **50--59** have the highest reported churn rate at
    **56.04%** (487 of 869).
-   The 40--49 age group records **30.83%** (807 of 2,618).
-   Customers under 30 record **7.56%** (124 of 1,641).

### 3. Number of Products

-   Customers with two products have a churn rate of **7.60%** (349 of
    4,590).
-   Customers with one product have a churn rate of **27.71%** (1,409 of
    5,084).
-   The three-product segment records **82.71%** (220 of 266).
-   All 60 customers in the four-product segment exited. The three- and
    four-product groups are comparatively small, so these rates require
    careful interpretation.

### 4. Customer Engagement

-   Inactive customers: **26.87%** churn (1,303 of 4,849).
-   Active customers: **14.27%** churn (735 of 5,151).
-   A controlled re-engagement pilot is more appropriate than assuming
    inactivity causes churn.

### 5. Balance and Activity Combined

-   Inactive + has balance: **31.66%** (983 of 3,105).
-   Inactive + zero balance: **18.35%** (320 of 1,744).
-   Active + has balance: **16.93%** (555 of 3,278).
-   Active + zero balance: **9.61%** (180 of 1,873).

### 6. Additional Statistical Evidence

-   Gender differences are observed: female customers record 25.07%
    churn and male customers 16.47%.
-   Card type is not statistically associated with churn at the 0.05
    significance level in the reported test (p = 0.168).
-   Satisfaction score is also not statistically associated with churn
    at the 0.05 level (p = 0.433).
-   `Complain` is a leakage warning: 2,034 of 2,044 customers with
    `Complain = 1` exited. Its event timing is unknown, so it should not
    be treated as a valid pre-churn predictor.

## Business Recommendations

1.  **Investigate Germany first.** Compare age, tenure, product count,
    balance and activity mix before attributing the geographic
    difference to a cause.
2.  **Review the multi-product customer journey.** Investigate three-
    and four-product experiences, while accounting for small sample
    sizes.
3.  **Pilot inactivity-based re-engagement.** Use a treatment group and
    a comparable control group to measure incremental retention.
4.  **Review balance and gender differences with context.** Examine
    product mix, service history and customer composition rather than
    assuming causal drivers.
5.  **Strengthen data and model governance.** Confirm feature timing and
    prevent outcome leakage before attempting predictive use.

## Tools and Methods

-   **Python:** pandas, NumPy, SciPy and data visualisation for data
    validation, EDA and statistical testing.
-   **SQL:** MySQL 8+ analysis queries for customer-level churn
    segmentation and summaries.
-   **Power BI:** Dashboard design and KPI/visual review.
-   **Statistics:** Chi-square tests for categorical associations;
    Mann--Whitney U tests for continuous age and balance comparisons.

## Data Quality and Scope

The supplied CSV has **10,000 rows × 18 columns**, 10,000 distinct
`CustomerId` values, no missing values and no exact duplicate rows.

The source fields include customer attributes (`CreditScore`,
`Geography`, `Gender`, `Age`, `Tenure`), account and engagement fields
(`Balance`, `NumOfProducts`, `HasCrCard`, `IsActiveMember`,
`EstimatedSalary`), the target (`Exited`) and supplementary fields
(`Complain`, `Satisfaction Score`, `Card Type`, `Point Earned`).

`RowNumber`, `CustomerId` and `Surname` are identifiers rather than
analytical predictors. `Complain` is retained only for a
leakage/data-quality check because its timing is unknown and it is
almost identical to the churn outcome. Satisfaction score is descriptive
pending confirmation of survey timing and coverage.

## Suggested Repository Structure

Use this structure if it matches the files you are publishing; rename
the paths to match your actual repository.

``` text
bank-customer-churn-analysis/
├── README.md
├── data/
│   └── Bank Customer Churn.csv
├── notebooks/
│   └── bank_customer_churn_eda.ipynb
├── sql/
│   └── bank_customer_churn_analysis.sql
├── powerbi/
│   └── bank_customer_churn_dashboard.pbix
└── reports/
    └── Bank_Customer_Churn_Management_Report.pdf
```

Do not upload confidential or restricted customer data. If the dataset
is subject to a licence or usage terms, follow those terms and link to
the original source rather than redistributing it without permission.

## How to Reproduce the Analysis

1.  Obtain the bank customer churn CSV from its authorised source.
2.  Open the Python EDA notebook and update the input file path to the
    location of the CSV.
3.  Run the notebook to inspect data quality, calculate segment-level
    churn rates, create visualisations and perform the documented
    statistical tests.
4.  Import the CSV into a MySQL 8+ database if you want to execute the
    SQL analysis script. Update the table reference in the script to
    match your imported table name.
5.  Open the Power BI report and update its data-source path if
    required.

**Execution status note:** The report's headline metrics and statistical
results were independently recalculated from the supplied raw CSV. The
supplied notebook had no saved execution outputs; the MySQL script was
reviewed statically but was not executed against a database; and the
Power BI report was visually reviewed from a screenshot rather than
validated by opening and executing the PBIX.

## Limitations

-   This is a historical, cross-sectional dataset. It contains no
    transaction date, event date or observation timestamp.
-   Calendar trends, cohort retention, tenure-over-time curves and
    30/60/90-day forecasts cannot be calculated from the supplied
    fields.
-   Observed associations do not prove causation.
-   The three- and four-product groups are small; the 100% churn rate
    for four products is based on only 60 customers.
-   Complaint timing is unknown; `Complain` must not be treated as a
    valid pre-churn signal.
-   Legacy model metrics mentioned in a separate brief were not
    revalidated against the supplied CSV and are not presented here as
    verified model performance.

## Conclusion

The analysis supports prioritising a Germany-focused diagnostic, a
cautious review of the multi-product customer journey and controlled
inactivity-based outreach. The findings identify where to investigate;
they do not prove why customers left or establish that a specific
intervention will reduce churn.

**Bottom line:** Use historical analysis to prioritise investigation,
controlled tests to establish impact, and properly timed data before
claiming predictive capability.

------------------------------------------------------------------------

*Prepared from the supplied Bank Customer Churn CSV, Python EDA
notebook, MySQL analysis script, business-problem brief and Power BI
screenshot. Report source review date: 02 November 2026.*
