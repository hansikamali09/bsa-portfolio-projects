
# Bank Loan Approval Data Analysis

**Skills demonstrated:** SQL, data analysis, Excel dashboarding, segmentation analysis, business insight generation.

## Overview
This project analyzes loan application outcomes to identify which applicant
segments have meaningfully different approval rates, and surfaces where a
bank's underwriting criteria might warrant closer review. It mirrors the kind
of analytical work a Business Systems Analyst does when investigating why a
process behaves differently across customer segments.

## Dataset
The schema is modeled on the widely-used public "Loan Prediction" dataset
structure (applicant demographics, income, credit history, property area,
loan status). **The data itself is synthetically generated** (see
`scripts/generate_data.py`) rather than pulled from a live source, since this
project was built offline — the generator uses a probability model so the
approval trends are realistic and analyzable, not random noise. If you want
to swap in a real public dataset (e.g., Kaggle's Loan Prediction dataset),
the script and SQL are written against the same column names, so you can
drop in a real CSV with no changes.

**Columns:** `Loan_ID, Gender, Married, Dependents, Education, Self_Employed,
ApplicantIncome, CoapplicantIncome, LoanAmount, Loan_Amount_Term,
Credit_History, Property_Area, Loan_Status`

- 800 synthetic applications
- Loaded into SQLite for querying (`loans.db`, built by the script below)

## How to reproduce
```bash
cd scripts
python generate_data.py          # writes ../data/loan_applications.csv

# Load into SQLite (from the project root)
python -c "
import sqlite3, pandas as pd
df = pd.read_csv('data/loan_applications.csv')
conn = sqlite3.connect('loans.db')
df.to_sql('loan_applications', conn, if_exists='replace', index=False)
"

# Run any query, e.g.:
sqlite3 loans.db < sql/analysis_queries.sql
```

## Files
| File | Purpose |
|---|---|
| `data/loan_applications.csv` | Source dataset |
| `scripts/generate_data.py` | Generates the synthetic dataset |
| `sql/analysis_queries.sql` | 10 SQL queries answering specific business questions |
| `Loan_Approval_Analysis.xlsx` | Dashboard + segment analysis + raw data, with charts |

## Key findings
1. **Credit history is by far the strongest predictor of approval** — 82.4%
   approval rate with a good credit history vs. 0.7% without one. This is the
   single clearest underwriting signal in the data.
2. **Approval rates vary modestly by property area** — Semiurban (71.3%) and
   Urban (69.2%) applicants are approved slightly more often than Rural
   (64.4%) applicants, a ~7-point spread worth investigating for fairness and
   risk-model calibration.
3. **Education and income bracket show smaller, secondary effects** —
   directionally consistent with expectation (higher income, Graduate
   education correlate with modestly higher approval) but far less
   determinative than credit history.
4. The workbook's **"Segments with approval rate below baseline"** query
   (Query 10 in `analysis_queries.sql`) is written to flag any
   Property Area × Education combination with at least 30 applications and a
   below-average approval rate — a reusable pattern for spotting segments
   that might need underwriting review as new data comes in.

## Tools used
SQL (SQLite), Python (pandas, openpyxl), Excel (pivot-style summary tables,
bar charts, multi-sheet dashboard)
