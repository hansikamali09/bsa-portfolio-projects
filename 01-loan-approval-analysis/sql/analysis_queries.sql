-- ============================================================
-- Bank Loan Approval Data Analysis
-- Business question: Where do approval rates differ significantly
-- across applicant segments, and what does that suggest about
-- underwriting risk factors?
--
-- Table: loan_applications (loaded from data/loan_applications.csv)
-- ============================================================

-- 1. Overall approval rate (baseline)
SELECT
    COUNT(*) AS total_applications,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS approved,
    ROUND(100.0 * SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) / COUNT(*), 1) AS approval_rate_pct
FROM loan_applications;


-- 2. Approval rate by Credit History (expected strongest predictor)
SELECT
    Credit_History,
    COUNT(*) AS applications,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS approved,
    ROUND(100.0 * SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) / COUNT(*), 1) AS approval_rate_pct
FROM loan_applications
GROUP BY Credit_History
ORDER BY Credit_History DESC;


-- 3. Approval rate by Property Area
SELECT
    Property_Area,
    COUNT(*) AS applications,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS approved,
    ROUND(100.0 * SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) / COUNT(*), 1) AS approval_rate_pct
FROM loan_applications
GROUP BY Property_Area
ORDER BY approval_rate_pct DESC;


-- 4. Approval rate by Education level
SELECT
    Education,
    COUNT(*) AS applications,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS approved,
    ROUND(100.0 * SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) / COUNT(*), 1) AS approval_rate_pct
FROM loan_applications
GROUP BY Education
ORDER BY approval_rate_pct DESC;


-- 5. Approval rate by Self-Employment status
SELECT
    Self_Employed,
    COUNT(*) AS applications,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS approved,
    ROUND(100.0 * SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) / COUNT(*), 1) AS approval_rate_pct
FROM loan_applications
GROUP BY Self_Employed
ORDER BY approval_rate_pct DESC;


-- 6. Approval rate by combined household income bracket
--    (ApplicantIncome + CoapplicantIncome)
SELECT
    CASE
        WHEN (ApplicantIncome + CoapplicantIncome) < 3000 THEN '1. Under 3,000'
        WHEN (ApplicantIncome + CoapplicantIncome) < 6000 THEN '2. 3,000 - 5,999'
        WHEN (ApplicantIncome + CoapplicantIncome) < 10000 THEN '3. 6,000 - 9,999'
        ELSE '4. 10,000+'
    END AS income_bracket,
    COUNT(*) AS applications,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS approved,
    ROUND(100.0 * SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) / COUNT(*), 1) AS approval_rate_pct
FROM loan_applications
GROUP BY income_bracket
ORDER BY income_bracket;


-- 7. Approval rate by number of Dependents
SELECT
    Dependents,
    COUNT(*) AS applications,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS approved,
    ROUND(100.0 * SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) / COUNT(*), 1) AS approval_rate_pct
FROM loan_applications
GROUP BY Dependents
ORDER BY Dependents;


-- 8. Cross-segment view: Credit History x Property Area
--    (identifies the highest / lowest performing combined segments)
SELECT
    Credit_History,
    Property_Area,
    COUNT(*) AS applications,
    SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) AS approved,
    ROUND(100.0 * SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) / COUNT(*), 1) AS approval_rate_pct
FROM loan_applications
GROUP BY Credit_History, Property_Area
ORDER BY Credit_History DESC, approval_rate_pct DESC;


-- 9. Average approved loan amount by Property Area
SELECT
    Property_Area,
    ROUND(AVG(LoanAmount), 0) AS avg_approved_loan_amount
FROM loan_applications
WHERE Loan_Status = 'Y'
GROUP BY Property_Area
ORDER BY avg_approved_loan_amount DESC;


-- 10. Segments with sample size >= 30 and approval rate below the
--     overall baseline (candidates for underwriting review)
SELECT
    Property_Area,
    Education,
    COUNT(*) AS applications,
    ROUND(100.0 * SUM(CASE WHEN Loan_Status = 'Y' THEN 1 ELSE 0 END) / COUNT(*), 1) AS approval_rate_pct
FROM loan_applications
GROUP BY Property_Area, Education
HAVING COUNT(*) >= 30
ORDER BY approval_rate_pct ASC
LIMIT 5;
