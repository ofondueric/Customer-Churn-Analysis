-- GET DATA INTO SQL by creatiing a table with same headings as dataset
CREATE TABLE Bank_churn (
	Customer_Id numeric,
	Surname	Text,
	Credit_Score	numeric,
	Geography text,
	Gender	text,
	Age	numeric,
	Tenure	numeric,
	Balance numeric,
	Num_Of_Products numeric,
	Has_Cr_Card	numeric,
	Is_Active_Member	numeric,
	Estimated_Salary	numeric,
	Exited numeric
);

/* 1. Business Problem:
A retail bank is experiencing customer attrition (churn), which reduces revenue 
and increases customeracquisition costs. The goal is to identify key drivers
of churn and provide actionable insights to improve customer retention.*/

-- 2. DATA CLEANING
-- finding duplicate (N/A)
SELECT 
	customer_id,
	COUNT(*) AS duplicate
FROM bank_churn
GROUP BY customer_id
HAVING count(*)>1;

-- Drop customer_id and Surname column as not relevant & confidential
ALTER TABLE bank_churn
DROP COLUMN customer_id,
DROP COLUMN surname;


-- 3. EXPLORATORY DATA ANALYSIS
SELECT 
	count(*) AS Total_customer,
	Min(balance) AS Min_bal,
	Max(balance) AS Max_bal,
	round(sum(estimated_salary),2) AS Total_sal,
	round(Avg(age),2) AS Mean_age,
	round(variance(credit_score),2) AS credit_score_Var,
	round(stddev(credit_score),2) AS credit_score_Std,
	corr(credit_score,balance) AS creditScore_balance_correlation,
	corr(age,estimated_salary) AS age_estimatedSalary_correlation
FROM bank_churn;

-- Total customer -KPI
SELECT 
	COUNT(*) AS Total_customer
FROM bank_churn;
-- Average balance - KPI
SELECT 
	round(Avg(balance),2) AS Average_balance
FROM bank_churn;
-- Average Tenure - KPI
SELECT 
	round(Avg(Tenure),2) AS Average_tenure
FROM bank_churn;
-- Overall churn rate - KPI
SELECT 
    COUNT(*) AS total_customers,
    SUM(Exited) AS churned_customers,
    round(SUM(Exited) / COUNT(*)*100,2) AS churn_rate
FROM bank_churn;
-- churn by geography
SELECT
	geography,
	SUM(Exited) AS churned_customers,
    round(SUM(Exited) / COUNT(*)*100,2) AS churn_rate
FROM bank_churn
GROUP BY 1;
-- churn by Gender
SELECT
	gender,
	SUM(Exited) AS churned_customers,
    round(SUM(Exited) / COUNT(*)*100,2) AS churn_rate
FROM bank_churn
GROUP BY 1;
-- churn by age
SELECT
	age,
	CASE
		When age < 18 then 'under 18'
		when age between 18 and 20 then '18-20'
		when age between 21 and 30 then '21-30'
		when age between 31 and 40 then '31-40'
		when age between 41 and 50 then '41-50'
		Else 'above 50'
	END AS age_bracket,
	SUM(Exited) AS churned_customers,
    round(SUM(Exited) / COUNT(*)*100,2) AS churn_rate
FROM bank_churn
GROUP BY 1, age_bracket
ORDER BY age_bracket;
-- Activity vs churn
SELECT
	is_active_member,
	Count(*)AS total_customer,
	Sum(exited) AS churn,
	round(Sum(exited)/Count(*),2)*100 AS Churn_rate
FROM bank_churn
Group by 1;
-- Has_cr_card vs churn
SELECT
	has_cr_card,
	Count(*)AS total_customer,
	Sum(exited) AS churn,
	round(Sum(exited)/Count(*),2)*100 AS Churn_rate
FROM bank_churn
Group by 1;
-- Credit_sore vs churn
SELECT 
	CASE
		WHEN credit_score BETWEEN 300 and 450 THEN '300-450'
		WHEN credit_score BETWEEN 451 and 550 THEN '451-550'
		WHEN credit_score BETWEEN 551 and 650 THEN '551-650'
		WHEN credit_score BETWEEN 651 and 750 THEN '651-750'
		ELSE 'above 750'
	END AS Credit_Score_bracket,
	Count(*)AS total_customer,
	Sum(exited) AS churn,
	round(Sum(exited)/Count(*),2)*100 AS Churn_rate
FROM bank_churn
GROUP BY Credit_Score_bracket
ORDER BY Credit_Score_bracket;
-- High risk customer
SELECT 
	COUNT(*)- SUM(Exited) AS Remaining_customer,
	count(risk_category) FILTER (WHERE risk_category = 'high risk') AS high_risk_customer,
	round(count(risk_category) FILTER (WHERE risk_category = 'high risk')/(COUNT(*)- SUM(Exited)),2)*100 AS Likely_to_churn_percentage
FROM bank_view;

-- 5. FEATURE ENGINEERING (Adding age_group and Credit_score_bracket) & CREATE view
 CREATE OR REPLACE VIEW bank_view AS (
 SELECT
	*,
	CASE
		When age < 18 then 'under 18'
		when age between 18 and 20 then '18-20'
		when age between 21 and 30 then '21-30'
		when age between 31 and 40 then '31-40'
		when age between 41 and 50 then '41-50'
		Else 'above 50'
	END AS age_group,
	CASE
		WHEN credit_score BETWEEN 300 and 450 THEN '300-450'
		WHEN credit_score BETWEEN 451 and 550 THEN '451-550'
		WHEN credit_score BETWEEN 551 and 650 THEN '551-650'
		WHEN credit_score BETWEEN 651 and 750 THEN '651-750'
		ELSE 'above 750'
	END AS Credit_Score_bracket,
	CASE
		when is_active_member = 0 and has_cr_card = 0 AND num_of_products = 1 then 'high risk'
		Else 'low risk'
	END AS risk_category
FROM bank_churn);
SELECT * FROM bank_view

SELECT *
FROM bank_churn
TABLESAMPLE BERNOULLI (0.50);

SELECT *
FROM bank_churn
TABLESAMPLE SYSTEM (10);