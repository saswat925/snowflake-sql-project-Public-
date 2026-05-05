# Healthcare Patient Analytics | End-to-End Data Analysis on Snowflake

## Project Overview
End-to-end data engineering and analytics project on a healthcare dataset — covering data ingestion, cleaning, transformation, feature engineering, and multi-dimensional analysis using Snowflake SQL.

**Database:** `OFFICE.PUBLIC`
**Table:** `HEALTHCARE` (10,000 rows)
**Date Range:** Multi-year patient admission data
**Pipeline:** Raw Ingestion → Cleaning → Transformation → Feature Engineering → Analytics

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                     END-TO-END DATA PIPELINE                        │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  [Raw Data]  →  [Data Quality]  →  [Transformation]  →  [Analytics]│
│                                                                     │
│  CSV/Source      Null Checks         Type Casting       KPIs        │
│  Ingestion       Duplicates          Date Conversion    Segments    │
│                  Validation          Feature Eng.       Trends      │
│                                      (Age Groups)       Insights    │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Data Schema

| Column | Type | Description |
|--------|------|-------------|
| NAME | VARCHAR | Patient name |
| AGE | NUMBER | Patient age |
| GENDER | VARCHAR | Male / Female |
| BLOOD_TYPE | VARCHAR | Blood type (A+, B-, AB+, etc.) |
| MEDICAL_CONDITION | VARCHAR | Diagnosis (Asthma, Diabetes, Cancer, etc.) |
| DATE_OF_ADMISSION | DATE | Admission date (converted from VARCHAR) |
| DISCHARGE_DATE | DATE | Discharge date (converted from VARCHAR) |
| DOCTOR | VARCHAR | Attending physician |
| HOSPITAL | VARCHAR | Hospital name |
| INSURANCE_PROVIDER | VARCHAR | Insurance company |
| BILLING_AMOUNT | NUMBER | Total billing amount ($) |
| ROOM_NUMBER | NUMBER | Room assigned |
| ADMISSION_TYPE | VARCHAR | Urgent / Emergency / Elective |
| MEDICATION | VARCHAR | Prescribed medication |
| TEST_RESULTS | VARCHAR | Normal / Abnormal / Inconclusive |
| AGE_GROUP | VARCHAR | Derived: Young Adult / Adult / Middle Age / Senior |

---

## Pipeline Steps

### Step 1: Data Ingestion
- Loaded raw healthcare data into `OFFICE.PUBLIC.HEALTHCARE`
- Initial row count: 10,000 patients

### Step 2: Data Quality Checks
- **Null Audit:** Checked critical columns (date_of_admission, discharge_date, blood_type, name, age, hospital) — all clean
- **Duplicate Detection:** Identified duplicate patient names using `GROUP BY + HAVING`
- **Data Type Inspection:** Used `DESC TABLE` to verify schema

### Step 3: Data Transformation
- **Date Conversion:** Converted `DATE_OF_ADMISSION` and `DISCHARGE_DATE` from VARCHAR (`DD-MM-YYYY`) to DATE type
- **Method:** ADD COLUMN → UPDATE with `TO_DATE()` → DROP old → RENAME new

### Step 4: Feature Engineering
- **Age Groups:** Created permanent derived column `AGE_GROUP`:
  - Young Adult: 18–25
  - Adult: 26–40
  - Middle Age: 41–60
  - Senior: 61–85

### Step 5: Analytics & Insights
- 20+ analytical queries covering KPIs, segments, trends, and cross-dimensional analysis

---

## Key Performance Indicators

| KPI | Value |
|-----|-------|
| Total Patients | 10,000 |
| Total Revenue | $255,168,068 |
| Avg Billing/Patient | $25,516.81 |
| Avg Hospital Stay | 15.56 days |
| Gender Split | Female 50.7% / Male 49.3% |
| Abnormal Test Rate | 34.5% |

---

## Analysis & Insights

### 1. Patient Demographics

| Age Group | Patients | % |
|-----------|----------|---|
| Senior (61-85) | 3,661 | 36.6% |
| Middle Age (41-60) | 2,932 | 29.3% |
| Adult (26-40) | 2,226 | 22.3% |
| Young Adult (18-25) | 1,181 | 11.8% |

> **Seniors dominate** at 36.6% — aligns with higher healthcare utilization in older populations.

### 2. Medical Conditions — Near-Equal Distribution

| Condition | Patients | Avg Billing |
|-----------|----------|-------------|
| Asthma | 1,708 | ~$25,500 |
| Obesity | 1,680 | ~$25,500 |
| Arthritis | 1,673 | ~$25,187 |
| Hypertension | 1,659 | ~$25,500 |
| Cancer | 1,657 | ~$25,500 |
| Diabetes | 1,623 | $26,060 |

> All conditions are **uniformly distributed** (~16-17% each). **Diabetes** has the highest avg billing despite lowest patient count.

### 3. Admission Types — Balanced

| Type | Patients | Avg Billing |
|------|----------|-------------|
| Urgent | 3,391 | $25,961 |
| Emergency | 3,367 | $24,709 |
| Elective | 3,242 | $25,892 |

> **Surprising:** Emergency admissions have the lowest average billing. Urgent costs 5% more than Emergency.

### 4. Insurance Provider Analysis

| Provider | Patients | Total Billing |
|----------|----------|---------------|
| Cigna | 2,040 | ~$52M |
| Aetna | 2,020 | ~$51M |
| Blue Cross | 2,009 | ~$51M |
| UnitedHealthcare | 2,006 | ~$51M |
| Medicare | 1,925 | ~$49M |

> All 5 insurers are **nearly equal** (~20% each) — no provider dominance or bias.

### 5. Hospital Performance
- **Top Hospital:** Smith and Sons ($477K total billing)
- Multiple Smith-named hospitals dominate the billing leaderboard
- Revenue distributed across many hospitals — no single-hospital dependency

### 6. Doctor Performance
- **Top Billing Doctor:** Michael Johnson ($181K)
- **Second:** Christopher Davis ($159K)
- Top 10 doctors by patient volume identified for workload analysis

### 7. Medication Distribution

| Medication | Usage Count |
|------------|-------------|
| Penicillin | 2,079 |
| Ibuprofen | 2,019 |
| Aspirin | 1,980 |
| Lipitor | 1,961 |
| Paracetamol | 1,962 |

> All 5 medications are near-equally prescribed — no single drug dependency.

### 8. Test Results — Concern Area

| Result | Count | % |
|--------|-------|---|
| Abnormal | 3,456 | 34.5% |
| Inconclusive | 3,277 | 32.8% |
| Normal | 3,267 | 32.7% |

> **34.5% abnormal results** — over a third of patients have abnormal tests. Combined with 32.8% inconclusive, only **32.7% are normal**.

### 9. Blood Type Distribution
- AB- is most common (1,275)
- A- is least common (1,238)
- All blood types are nearly equally distributed

### 10. Age Group vs Revenue

| Age Group | Avg Billing | Total Billing |
|-----------|-------------|---------------|
| Young Adult | $25,836 | ~$30.5M |
| Adult | ~$25,500 | ~$56.8M |
| Middle Age | ~$25,500 | ~$74.8M |
| Senior | ~$25,300 | $92.8M |

> **Young Adults have the highest avg bill** but **Seniors generate max total revenue** due to 3x volume.

### 11. Average Stay by Condition

| Condition | Avg Stay (Days) |
|-----------|-----------------|
| Arthritis | 16.0 |
| Cancer | ~15.7 |
| Hypertension | ~15.6 |
| Diabetes | ~15.5 |
| Asthma | ~15.5 |
| Obesity | 15.4 |

> Narrow range (15.4–16.0 days) — condition type doesn't significantly impact length of stay.

### 12. Monthly & Yearly Trends
- Year-over-year revenue tracking enabled via date conversion
- Monthly admission trends analyzed for seasonal patterns
- Month-over-month breakdowns available for operational planning

---

## SQL Analyses Included (healthcare.sql)

| # | Analysis | Type |
|---|----------|------|
| 1 | Null count (dates, blood type) | Data Quality |
| 2 | Duplicate name detection | Data Quality |
| 3 | Date type conversion (VARCHAR → DATE) | Transformation |
| 4 | Total revenue & avg billing | KPI |
| 5 | Age group feature engineering | Feature Engineering |
| 6 | Gender distribution | Demographics |
| 7 | Age group counts | Demographics |
| 8 | Top medical conditions | Clinical |
| 9 | Highest billing hospitals | Hospital Performance |
| 10 | Insurance provider usage | Insurance |
| 11 | Avg billing by condition | Financial |
| 12 | Admission type analysis | Operations |
| 13 | Average stay days | Operations |
| 14 | Monthly admission trend | Trend |
| 15 | Highest billing patient | Outlier |
| 16 | Condition-wise total billing | Financial |
| 17 | Blood type distribution | Demographics |
| 18 | Yearly revenue | Trend |
| 19 | Doctor-wise patient count | Workforce |
| 20 | Stay days by condition | Clinical |
| 21 | Insurance provider billing deep-dive | Financial |
| 22 | Medication frequency | Clinical |
| 23 | Test results distribution | Clinical |
| 24 | Age group billing analysis | Financial |
| 25 | Monthly revenue trend (yr + mn) | Trend |
| 26 | Condition × test result breakdown | Clinical |
| 27 | Top 5 billing doctors | Workforce |
| 28 | Admission type × age group | Cross-Dimensional |

---

## SQL Techniques Used

| Technique | Purpose |
|-----------|---------|
| `ALTER TABLE ADD/DROP/RENAME COLUMN` | Schema evolution |
| `TO_DATE()` | Type casting VARCHAR → DATE |
| `DATEDIFF()` | Calculate length of stay |
| `CASE WHEN` | Feature engineering (age groups) |
| `GROUP BY + HAVING` | Duplicate detection |
| `SUM() / AVG() / COUNT()` | Aggregation metrics |
| `ROUND()` | Clean numeric output |
| `YEAR() / MONTH()` | Date part extraction |
| `ORDER BY + LIMIT` | Top-N analysis |
| `COUNT(*) - COUNT(col)` | Null counting pattern |
| `DESC TABLE` | Schema inspection |

---

## Key Findings & Recommendations

1. **High Abnormal Test Rate (34.5%)** — Investigate lab processes; only 1 in 3 patients have normal results
2. **Senior-Dominated Population (36.6%)** — Invest in geriatric care, chronic disease management, and long-stay facilities
3. **Uniform Condition Distribution** — No single condition dominates; maintain balanced resource allocation across all 6 conditions
4. **Emergency Costs Lower Than Urgent** — Review urgent admission classification criteria; potential upcoding or process gap
5. **15.5-Day Average Stay** — Benchmark against industry standards; explore discharge optimization for cost savings
6. **Equal Insurance Distribution** — No insurer dependency; negotiate balanced contracts across all 5 providers
7. **Young Adults = Highest Avg Bill** — Despite being the smallest group (11.8%), they have the highest per-patient cost; investigate if driven by acute cases
8. **Doctor Workload Review** — Top doctors handling disproportionate billing; assess burnout risk and patient distribution

---

## Tech Stack

| Component | Tool |
|-----------|------|
| **Platform** | Snowflake Cloud Data Warehouse |
| **Compute** | COMPUTE_WH (Virtual Warehouse) |
| **Database** | OFFICE.PUBLIC |
| **Language** | SQL |
| **Role** | ACCOUNTADMIN |
| **IDE** | Snowsight (Snowflake Web UI) |

---

## Project Structure
```
healthcare-data-engineering/
├── healthcare_README.md         
└── healthcare.sql          


---

## Author
Saswat Betta Aptakam
