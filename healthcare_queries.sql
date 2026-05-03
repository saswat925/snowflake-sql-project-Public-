select * from office.public.healthcare;

USE DATABASE office;
USE SCHEMA PUBLIC;

select * from healthcare;
--null count
SELECT 
COUNT(*) - COUNT(date_of_admission) AS date_of_admission_null_count,
COUNT(*) - COUNT(discharge_date) AS discharge_date_null_count,
count(*) - count(blood_type) as blood_type_null_count
FROM healthcare;
-- INSIGHT: Checking nulls in critical date/blood columns ensures data quality before analysis

--check duplicate
select name, count(*) as dp_count from healthcare
group by name
having count(*) > 1;
-- INSIGHT: Duplicate names found — could be repeat visits or true duplicates, verify with additional columns



-- Convert DATE_OF_ADMISSION: VARCHAR -> DATE
ALTER TABLE OFFICE.PUBLIC.HEALTHCARE ADD COLUMN DATE_OF_ADMISSION_NEW DATE;
UPDATE OFFICE.PUBLIC.HEALTHCARE SET DATE_OF_ADMISSION_NEW = TO_DATE(DATE_OF_ADMISSION, 'DD-MM-YYYY');
ALTER TABLE OFFICE.PUBLIC.HEALTHCARE DROP COLUMN DATE_OF_ADMISSION;
ALTER TABLE OFFICE.PUBLIC.HEALTHCARE RENAME COLUMN DATE_OF_ADMISSION_NEW TO DATE_OF_ADMISSION;

-- Convert DISCHARGE_DATE: VARCHAR -> DATE
ALTER TABLE OFFICE.PUBLIC.HEALTHCARE ADD COLUMN DISCHARGE_DATE_NEW DATE;
UPDATE OFFICE.PUBLIC.HEALTHCARE SET DISCHARGE_DATE_NEW = TO_DATE(DISCHARGE_DATE, 'DD-MM-YYYY');
ALTER TABLE OFFICE.PUBLIC.HEALTHCARE DROP COLUMN DISCHARGE_DATE;
ALTER TABLE OFFICE.PUBLIC.HEALTHCARE RENAME COLUMN DISCHARGE_DATE_NEW TO DISCHARGE_DATE;

--check data type
desc table healthcare;

--total amount 
select round(sum(billing_amount),0) from healthcare;
-- INSIGHT: Total revenue = 255 million across 10,000 patients
--average bill amount 
select round(avg(billing_amount),2) from healthcare;
-- INSIGHT: Average bill = 25,516.81 per patient
---age group column permanently add

ALTER TABLE OFFICE.PUBLIC.HEALTHCARE ADD COLUMN AGE_GROUP VARCHAR
UPDATE OFFICE.PUBLIC.HEALTHCARE SET AGE_GROUP = 
  CASE
    WHEN age BETWEEN 18 AND 25 THEN 'Young Adult'
    WHEN age BETWEEN 26 AND 40 THEN 'Adult'
    WHEN age BETWEEN 41 AND 60 THEN 'Middle Age'
    WHEN age BETWEEN 61 AND 85 THEN 'Senior'
    ELSE 'Other'
  END
--total revenue
select round(sum(billing_amount), 2 ) as total_revenue from healthcare
-- INSIGHT: Total revenue = 255,168,068 — consistent across all patients

--total_patients name
select count(name) as total_patients from healthcare;
-- INSIGHT: Total 10,000 patients in the dataset
--gender distribution 
select gender, count(*) as patient_count from healthcare
group by gender; 
-- INSIGHT: Female 5,075 (50.7%) vs Male 4,925 (49.3%) — nearly equal gender split
--age group count 
select age_group, count(*) as total_patients from healthcare
group by age_group;
-- INSIGHT: Seniors dominate (3,661 = 36.6%), Young Adults are the smallest group (1,181 = 11.8%)
--top medical condition
select medical_condition, count(*) as total_patients from healthcare
group by medical_condition
order by total_patients desc;
-- INSIGHT: Asthma leads (1,708), Diabetes lowest (1,623) — all conditions are near-equally distributed
---highest billing hospital
select hospital, round(sum(billing_amount),2) as total_bill from healthcare
group by hospital
order by total_bill desc;
-- INSIGHT: Smith and Sons is the top hospital (477K), multiple Smith-named hospitals dominate billing
--insurance provider usage
  select insurance_provider, count(*) as tota_patients from healthcare
  group by insurance_provider
  order by tota_patients desc;
-- INSIGHT: Cigna leads (2,040), Medicare lowest (1,925) — all 5 insurers nearly equal at ~20% each
--avg billing by condition 
select medical_condition, round(avg(billing_amount), 2) as avg_billing from healthcare
group by medical_condition
order by avg_billing;
-- INSIGHT: Diabetes has the highest avg cost (26,060), Arthritis the lowest (25,187) — narrow range across conditions
--admission type analysis
select admission_type, count(*) as total_patients from healthcare
group by admission_type
-- INSIGHT: Urgent (3,391), Emergency (3,367), Elective (3,242) — fairly balanced distribution
--average stays days 
SELECT ROUND(avg(DATEDIFF(day,date_of_admission,discharge_date)),2) AS avg_stay_days
FROM healthcare;
-- INSIGHT: Average hospital stay is 15.56 days per patient
--monthly admission trend
select month(date_of_admission) as month_name, count(*) as admission from healthcare
group by month_name
order by month_name
-- INSIGHT: Check for seasonal spikes or consistent admission patterns across months

select * from healthcare    

---highest billing patient
select name, billing_amount from healthcare
order by billing_amount desc
limit 1 
-- INSIGHT: Identifies the single highest billing patient — useful for outlier analysis
--age group wise patints
SELECT age_group, COUNT(*) total
FROM healthcare
GROUP BY age_group;
-- INSIGHT: Seniors 3,661 > Middle Age 2,932 > Adults 2,226 > Young Adults 1,181
---condition wise average billing
select medical_condition, round(sum(billing_amount), 2) as avg_amount from healthcare
group by medical_condition
order by avg_amount desc
-- INSIGHT: Total billing per condition is evenly spread — no single condition dominates the revenue
--most common blood type 
SELECT blood_type, COUNT(*) total
FROM healthcare
GROUP BY blood_type
ORDER BY total DESC;
-- INSIGHT: AB- is most common (1,275), A- is least (1,238) — all blood types are nearly equal
--yearly revenue
SELECT YEAR(date_of_admission) yr,
SUM(billing_amount) revenue
FROM healthcare
GROUP BY yr;
-- INSIGHT: Year-over-year revenue trend — check for growth or decline patterns
--duplicate names
select name,count(*) total from healthcare
group by name
having count(*) > 1;
--null check all importanta columns
SELECT
COUNT(*)-COUNT(name) name_null,
COUNT(*)-COUNT(age) age_null,
COUNT(*)-COUNT(hospital) hospital_null
FROM healthcare;
-- INSIGHT: Name, Age, Hospital columns have zero nulls — data quality is good
---Emergency vs Routine Billing
SELECT admission_type,
ROUND(AVG(billing_amount),2) avg_bill
FROM healthcare
GROUP BY admission_type;
-- INSIGHT: Urgent (25,961) > Elective (25,892) > Emergency (24,709) — surprisingly Emergency is the cheapest

-- Doctor wise patient count
SELECT DOCTOR, COUNT(*) AS total_patients
FROM OFFICE.PUBLIC.HEALTHCARE
GROUP BY DOCTOR
ORDER BY total_patients DESC
LIMIT 10;
-- INSIGHT: Top doctors by patient volume — high count may indicate overwork or popularity

-- Average stay days by medical condition
SELECT MEDICAL_CONDITION,
       ROUND(AVG(DATEDIFF(DAY, DATE_OF_ADMISSION, DISCHARGE_DATE)), 2) AS avg_stay_days
FROM OFFICE.PUBLIC.HEALTHCARE
GROUP BY MEDICAL_CONDITION
ORDER BY avg_stay_days DESC;
-- INSIGHT: Arthritis has the longest stay (16 days), Obesity the shortest (15.4 days) — narrow range

-- Insurance provider wise total billing
SELECT INSURANCE_PROVIDER,
       ROUND(SUM(BILLING_AMOUNT), 2) AS total_billing,
       COUNT(*) AS total_patients,
       ROUND(AVG(BILLING_AMOUNT), 2) AS avg_billing
FROM OFFICE.PUBLIC.HEALTHCARE
GROUP BY INSURANCE_PROVIDER
ORDER BY total_billing DESC;
-- INSIGHT: All insurers handle ~2K patients each with similar avg billing — no provider bias detected

-- Medication frequency
SELECT MEDICATION, COUNT(*) AS usage_count
FROM OFFICE.PUBLIC.HEALTHCARE
GROUP BY MEDICATION
ORDER BY usage_count DESC;
-- INSIGHT: Penicillin is most prescribed (2,079), Paracetamol least (1,962) — all 5 medications are near-equal

-- Test results distribution
SELECT TEST_RESULTS, COUNT(*) AS total
FROM OFFICE.PUBLIC.HEALTHCARE
GROUP BY TEST_RESULTS;
-- INSIGHT: Abnormal (3,456) > Inconclusive (3,277) > Normal (3,267) — 34.5% of tests are abnormal!

-- Age group wise average billing
SELECT AGE_GROUP,
       ROUND(AVG(BILLING_AMOUNT), 2) AS avg_billing,
       ROUND(SUM(BILLING_AMOUNT), 2) AS total_billing
FROM OFFICE.PUBLIC.HEALTHCARE
GROUP BY AGE_GROUP
ORDER BY avg_billing DESC;
-- INSIGHT: Young Adults have the highest avg bill (25,836) but Seniors generate max total revenue (92.8M) due to volume

-- Monthly revenue trend
SELECT YEAR(DATE_OF_ADMISSION) AS yr,
       MONTH(DATE_OF_ADMISSION) AS mn,
       ROUND(SUM(BILLING_AMOUNT), 2) AS monthly_revenue,
       COUNT(*) AS admissions
FROM OFFICE.PUBLIC.HEALTHCARE
GROUP BY yr, mn
ORDER BY yr, mn;

-- Condition wise test result breakdown
SELECT MEDICAL_CONDITION, TEST_RESULTS, COUNT(*) AS total
FROM OFFICE.PUBLIC.HEALTHCARE
GROUP BY MEDICAL_CONDITION, TEST_RESULTS
ORDER BY MEDICAL_CONDITION, total DESC;
-- INSIGHT: Identifies which conditions have the highest abnormal test rate — useful for clinical prioritization

-- Top 5 highest billing doctors
SELECT DOCTOR, ROUND(SUM(BILLING_AMOUNT), 2) AS total_billing
FROM OFFICE.PUBLIC.HEALTHCARE
GROUP BY DOCTOR
ORDER BY total_billing DESC
LIMIT 5;
-- INSIGHT: Michael Johnson tops billing (181K), followed by Christopher Davis (159K)

-- Admission type vs age group
SELECT ADMISSION_TYPE, AGE_GROUP, COUNT(*) AS total_patients
FROM OFFICE.PUBLIC.HEALTHCARE
GROUP BY ADMISSION_TYPE, AGE_GROUP
ORDER BY ADMISSION_TYPE, total_patients DESC;
-- INSIGHT: Seniors dominate all admission types — highest in emergency, urgent, and elective admissions


