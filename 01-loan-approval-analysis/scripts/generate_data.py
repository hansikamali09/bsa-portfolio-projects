"""
generate_data.py
-----------------
Generates a synthetic bank-loan-application dataset for portfolio/analysis
purposes. The schema mirrors the well-known public "Loan Prediction" dataset
structure (applicant demographics, income, credit history, property area,
loan status), but every row here is randomly generated -- not real applicant
data -- so it is safe to publish and reuse.

Run:  python generate_data.py
Output: ../data/loan_applications.csv
"""

import csv
import random

random.seed(42)  # reproducible output

N_ROWS = 800

genders = ["Male", "Female"]
married = ["Yes", "No"]
dependents = ["0", "1", "2", "3+"]
education = ["Graduate", "Not Graduate"]
self_employed = ["Yes", "No"]
property_area = ["Urban", "Semiurban", "Rural"]

rows = []
for i in range(1, N_ROWS + 1):
    loan_id = f"LP{100000 + i}"
    gender = random.choices(genders, weights=[0.78, 0.22])[0]
    is_married = random.choices(married, weights=[0.65, 0.35])[0]
    dep = random.choices(dependents, weights=[0.55, 0.18, 0.17, 0.10])[0]
    edu = random.choices(education, weights=[0.78, 0.22])[0]
    self_emp = random.choices(self_employed, weights=[0.14, 0.86])[0]
    area = random.choices(property_area, weights=[0.38, 0.38, 0.24])[0]

    # Income correlated loosely with education/self-employment
    base_income = random.gauss(5400, 2600)
    if edu == "Graduate":
        base_income *= 1.25
    if self_emp == "Yes":
        base_income *= random.uniform(0.7, 1.6)  # more variance
    applicant_income = max(1500, round(base_income))

    coapplicant_income = 0
    if is_married == "Yes" and random.random() < 0.6:
        coapplicant_income = max(0, round(random.gauss(2200, 1500)))

    loan_amount = max(
        10, round((applicant_income + coapplicant_income) * random.uniform(0.02, 0.06))
    )
    loan_term = random.choices([360, 180, 120, 84, 60], weights=[0.72, 0.12, 0.08, 0.05, 0.03])[0]

    # Credit history: 1 = good record, 0 = poor/no record
    credit_history = random.choices([1, 0], weights=[0.84, 0.16])[0]

    # Approval probability model (drives realistic, analyzable trends)
    score = 0.15
    score += 0.55 if credit_history == 1 else -0.35
    score += 0.08 if edu == "Graduate" else 0.0
    score += 0.05 if area in ("Urban", "Semiurban") else -0.03
    score += 0.10 if (applicant_income + coapplicant_income) > 6000 else -0.05
    score -= 0.10 if self_emp == "Yes" else 0.0
    score -= 0.05 if dep == "3+" else 0.0
    prob_approved = min(0.97, max(0.03, score))

    loan_status = "Y" if random.random() < prob_approved else "N"

    rows.append([
        loan_id, gender, is_married, dep, edu, self_emp,
        applicant_income, coapplicant_income, loan_amount, loan_term,
        credit_history, area, loan_status
    ])

header = [
    "Loan_ID", "Gender", "Married", "Dependents", "Education", "Self_Employed",
    "ApplicantIncome", "CoapplicantIncome", "LoanAmount", "Loan_Amount_Term",
    "Credit_History", "Property_Area", "Loan_Status"
]

with open("../data/loan_applications.csv", "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerow(header)
    writer.writerows(rows)

print(f"Generated {N_ROWS} synthetic loan applications -> ../data/loan_applications.csv")
