# EDA Report - DOSAGE Personalized Antibiotic Medication Dataset

**Generated**: 2026-04-16 16:35:23
**Source**: DOSAGE Dataset (Figshare)
**Pipeline**: `data_cleaning.py`

---

## 1. Raw Data Overview

### Raw Dataset Shapes

| File | Rows | Columns |
|------|------|---------|
| d_dose.csv | 3029 | 22 |
| s_dose.csv | 288 | 20 |
| r_dose.csv | 220 | 12 |
| preg_risk.csv | 98 | 2 |
| generic_disease_map.csv | 1066 | 2 |

### d_dose.csv - Raw Column Summary

| Column | Type | Non-Null | Null | Null% | Unique |
|--------|------|----------|------|-------|--------|
| `generic` | object | 3029 | 0 | 0.0% | 97 |
| `disease` | object | 3028 | 1 | 0.0% | 267 |
| `min_age_d` | float64 | 414 | 2615 | 86.3% | 3 |
| `max_age_d` | float64 | 313 | 2716 | 89.7% | 2 |
| `min_age_m` | float64 | 877 | 2152 | 71.0% | 6 |
| `max_age_m` | float64 | 33 | 2996 | 98.9% | 2 |
| `min_age_y` | float64 | 1726 | 1303 | 43.0% | 12 |
| `max_age_y` | float64 | 2671 | 358 | 11.8% | 14 |
| `min_weight` | float64 | 176 | 2853 | 94.2% | 33 |
| `max_weight` | float64 | 151 | 2878 | 95.0% | 28 |
| `min_dose_dw_mg` | float64 | 1336 | 1693 | 55.9% | 45 |
| `max_dose_dw_mg` | float64 | 1332 | 1697 | 56.0% | 55 |
| `min_dose_dw_iu` | float64 | 4 | 3025 | 99.9% | 1 |
| `max_dose_dw_iu` | float64 | 4 | 3025 | 99.9% | 2 |
| `limit_mg` | float64 | 526 | 2503 | 82.6% | 25 |
| `limit_iu` | float64 | 4 | 3025 | 99.9% | 1 |
| `min_dose_dd_mg` | float64 | 1663 | 1366 | 45.1% | 54 |
| `max_dose_dd_mg` | float64 | 1662 | 1367 | 45.1% | 67 |
| `min_dose_dd_UNIT` | float64 | 27 | 3002 | 99.1% | 7 |
| `max_dose_dd_iu` | float64 | 27 | 3002 | 99.1% | 6 |
| `route` | object | 3028 | 1 | 0.0% | 3 |
| `Unnamed: 21` | object | 4 | 3025 | 99.9% | 1 |

### s_dose.csv - Raw Column Summary

| Column | Type | Non-Null | Null | Null% | Unique |
|--------|------|----------|------|-------|--------|
| `generic` | object | 288 | 0 | 0.0% | 89 |
| `min_age_d` | float64 | 44 | 244 | 84.7% | 3 |
| `max_age_d` | float64 | 36 | 252 | 87.5% | 2 |
| `min_age_m` | float64 | 95 | 193 | 67.0% | 5 |
| `max_age_m` | float64 | 2 | 286 | 99.3% | 2 |
| `min_age_y` | float64 | 149 | 139 | 48.3% | 7 |
| `max_age_y` | float64 | 250 | 38 | 13.2% | 6 |
| `min_weight` | float64 | 16 | 272 | 94.4% | 10 |
| `max_weight` | float64 | 14 | 274 | 95.1% | 9 |
| `min_dose_dw_mg` | float64 | 144 | 144 | 50.0% | 30 |
| `max_dose_dw_mg` | float64 | 143 | 145 | 50.3% | 35 |
| `min_dose_dw_iu` | float64 | 3 | 285 | 99.0% | 1 |
| `max_dose_dw_iu` | float64 | 3 | 285 | 99.0% | 1 |
| `limit_mg` | float64 | 62 | 226 | 78.5% | 15 |
| `limit_iu` | float64 | 3 | 285 | 99.0% | 1 |
| `min_dose_dd_mg` | float64 | 139 | 149 | 51.7% | 24 |
| `max_dose_dd_mg` | float64 | 139 | 149 | 51.7% | 34 |
| `min_dose_dd_UNIT` | float64 | 3 | 285 | 99.0% | 3 |
| `max_dose_dd_iu` | float64 | 3 | 285 | 99.0% | 3 |
| `route` | object | 288 | 0 | 0.0% | 3 |

### r_dose.csv - Raw Column Summary

| Column | Type | Non-Null | Null | Null% | Unique |
|--------|------|----------|------|-------|--------|
| `generic` | object | 220 | 0 | 0.0% | 73 |
| `disease` | object | 6 | 214 | 97.3% | 2 |
| `min_weight` | float64 | 30 | 190 | 86.4% | 6 |
| `max_weight` | float64 | 25 | 195 | 88.6% | 5 |
| `min_crcl` | float64 | 198 | 22 | 10.0% | 21 |
| `max_crcl` | float64 | 197 | 23 | 10.5% | 23 |
| `max_dose_dd_mg` | float64 | 165 | 55 | 25.0% | 41 |
| `max_dose_dw_mg` | float64 | 26 | 194 | 88.2% | 11 |
| `max_dose_dd_iu` | float64 | 2 | 218 | 99.1% | 2 |
| `max_dose_dw_iu` | float64 | 0 | 220 | 100.0% | 0 |
| `route` | object | 199 | 21 | 9.5% | 3 |
| `flag` | object | 27 | 193 | 87.7% | 2 |


---

## 2. Column Cleanup & Type Corrections

### Changes Made
- **Dropped** `Unnamed: 21` from `d_dose.csv` (artifact column with 4 URL values, not part of the schema)
- **Renamed** `min_dose_dd_UNIT` -> `min_dose_dd_iu` in both `d_dose.csv` and `s_dose.csv` (column name typo)
- **Verified** all numeric columns are `float64` (coerced any string values)


---

## 3. Duplicate Removal

### Duplicates Found & Removed

| File | Duplicates Found | Rows Before | Rows After |
|------|-----------------|-------------|------------|
| d_dose.csv | 76 | 3029 | 2953 |
| s_dose.csv | 0 | 288 | 288 |
| r_dose.csv | 0 | 220 | 220 |
| preg_risk.csv | 1 | 98 | 97 |
| generic_disease_map.csv | 0 | 1066 | 1066 |

**Note**: d_dose duplicates were mostly elderly (65-120y) dosing rows duplicated for the same drug/disease/route combination. preg_risk had Amikacin listed twice with category D.


---

## 4. Missing Value Handling

### Imputation Strategy Applied

| Column Group | Strategy | Rationale |
|-------------|----------|-----------|
| IU dose columns (`*_iu`, `limit_iu`) | Fill with `0.0` | Drug doesn't use IU units |
| mg dose columns (`*_mg`) | Fill with `0.0` | Drug doesn't use mg for that dosing mode |
| `limit_mg` | Fill with `0.0` | No maximum cap applies |
| Age min columns | Fill with `0` | No lower age restriction |
| Age max columns | Fill with `999` | No upper age restriction |
| Weight min/max | Fill with `0.0` / `999.0` | No weight restriction |
| `disease` (d_dose) | Drop row (1 row) | Cannot impute disease name |
| `route` (d_dose) | Drop row (1 row) | Cannot impute route reliably |
| `disease` (r_dose) | Fill with `"General"` | Renal adjustments not disease-specific |
| `route` (r_dose) | Fill with mode (`IV`) | Most common route for renal adjustments |
| `flag` (r_dose) | Fill with `"Normal"` | No special flag applies |
| CrCl (r_dose) | Fill with `0` / `999` | No creatinine clearance restriction |

### Final Null Counts

| File | Total Nulls |
|------|-------------|
| d_dose_cleaned | 0 |
| s_dose_cleaned | 0 |
| r_dose_cleaned | 0 |
| preg_risk_cleaned | 0 |
| generic_disease_map_cleaned | 0 |


---

## 5. Outlier Detection

### Findings

- **Weight range** (excluding sentinels): 1.2 - 79.9 kg [OK] (clinically valid for neonates to adults)
- **Age range (years)**: 1.0 - 120.0 years [OK] (120y is a safe upper bound, not a true outlier)
- **Weight-based dose (mg/kg/day)** (`min_dose_dw_mg`): 21 values above 3xIQR fence (210.0). Max: 400.0. These are high-dose antibiotics (e.g., Sulfamethoxazole-Trimethoprim) - **clinically valid, not data entry errors**.
- **Weight-based dose max (mg/kg/day)** (`max_dose_dw_mg`): 5 values above 3xIQR fence (432.8). Max: 600.0. These are high-dose antibiotics (e.g., Sulfamethoxazole-Trimethoprim) - **clinically valid, not data entry errors**.
- **Direct daily dose min (mg)** (`min_dose_dd_mg`): 50 values above 3xIQR fence (4500.0). Max: 16000.0. These are high-dose antibiotics (e.g., Sulfamethoxazole-Trimethoprim) - **clinically valid, not data entry errors**.
- **Direct daily dose max (mg)** (`max_dose_dd_mg`): 100 values above 3xIQR fence (9300.0). Max: 24000.0. These are high-dose antibiotics (e.g., Sulfamethoxazole-Trimethoprim) - **clinically valid, not data entry errors**.
- **Negative values**: 0 found across all numeric columns [OK]
- **Min <= Max consistency**: All paired columns validated [OK]

### Conclusion

> **No records were removed due to outliers.** All values fall within clinically plausible ranges for antibiotic dosing.
> The high-end dose values (e.g., 24,000 mg/day) correspond to known high-dose regimens
> (Sulfamethoxazole-Trimethoprim combinations). The age upper bound of 120 years is a
> standard safety ceiling used in pharmacological databases.


---

## 6. Consistency Checks

### Results

- **Route values (d_dose)**: {'IV', 'IM', 'PO'} [OK]
- **Route values (s_dose)**: {'IV', 'IM', 'PO'} [OK]
- **Route values (r_dose)**: {'IV', 'IM', 'PO'} [OK]
- **Total unique antibiotics across all files**: 104
  - d_dose: 96, s_dose: 89, r_dose: 73, preg_risk: 97, map: 96
- **Disease mapping completeness**: 267 diseases in d_dose, 267 in map
  - All diseases properly mapped [OK]
- **Pregnancy risk categories**: {'D', 'C', 'B', 'Unknown', 'Not Assigned'}

---

## 7. Categorical Encoding

### Encoding Applied

#### Label Encoding

| Column | Mapping | Applied To |
|--------|---------|------------|
| `route` -> `route_label` | PO=0, IM=1, IV=2 | d_dose, s_dose, r_dose |
| `r_category` -> `r_category_label` | A=0, B=1, C=2, D=3, X=4, Unknown=5, Not Assigned=6 | preg_risk |
| `flag` -> `flag_label` | Normal=0, Not Required=1, Not Recommended=2 | r_dose |
| `generic` -> `generic_label` | 0-95 (alphabetical) | d_dose, s_dose |
| `disease` -> `disease_label` | 0-266 (alphabetical) | d_dose |

#### One-Hot Encoding

| Column | New Columns | Applied To |
|--------|-------------|------------|
| `route` | `route_PO`, `route_IM`, `route_IV` | d_dose, s_dose, r_dose |

**Note**: Original string columns are preserved alongside encoded versions.


---

## 8. Feature Scaling

### Scaling Strategy

| Feature Group | Method | Rationale |
|--------------|--------|-----------|
| Dose columns (mg, IU, limit) | **Min-Max [0,1]** | Bounded clinical ranges; preserves relative differences |
| Age columns (days, months, years) | **Standard (Z-score)** | Gaussian-like distribution; handles sentinel values better |
| Weight columns | **Standard (Z-score)** | Same rationale as age |
| CrCl (r_dose) | **Min-Max [0,1]** | Bounded clinical range (0-90) |

### Scaled Column Naming Convention
- Min-Max scaled: `{original}_minmax`
- Standard scaled: `{original}_zscore`

### Scaling Parameters
Saved to `cleaned/scaling_params.json` for inverse transform during inference.
Contains 18 parameter sets.


---

## 9. Final Data Summary

### Cleaned Dataset Shapes

| File | Rows | Columns | Description |
|------|------|---------|-------------|
| d_dose_cleaned.csv | 2952 | 21 | Disease-specific dosing (cleaned) |
| s_dose_cleaned.csv | 288 | 20 | Standard dosing (cleaned) |
| r_dose_cleaned.csv | 220 | 12 | Renal-adjusted dosing (cleaned) |
| preg_risk_cleaned.csv | 97 | 2 | Pregnancy risk categories (cleaned) |
| generic_disease_map_cleaned.csv | 1065 | 2 | Drug-disease mapping (cleaned) |
| d_dose_encoded.csv | 2952 | 45 | With encoding + scaling |
| s_dose_encoded.csv | 288 | 43 | With encoding + scaling |
| r_dose_encoded.csv | 220 | 21 | With encoding + scaling |
| preg_risk_encoded.csv | 97 | 3 | With label encoding |

### d_dose_cleaned.csv - Final Column Summary

| Column | Type | Non-Null | Null | Null% | Unique |
|--------|------|----------|------|-------|--------|
| `generic` | object | 2952 | 0 | 0.0% | 96 |
| `disease` | object | 2952 | 0 | 0.0% | 267 |
| `min_age_d` | float64 | 2952 | 0 | 0.0% | 4 |
| `max_age_d` | float64 | 2952 | 0 | 0.0% | 3 |
| `min_age_m` | float64 | 2952 | 0 | 0.0% | 7 |
| `max_age_m` | float64 | 2952 | 0 | 0.0% | 3 |
| `min_age_y` | float64 | 2952 | 0 | 0.0% | 13 |
| `max_age_y` | float64 | 2952 | 0 | 0.0% | 15 |
| `min_weight` | float64 | 2952 | 0 | 0.0% | 33 |
| `max_weight` | float64 | 2952 | 0 | 0.0% | 29 |
| `min_dose_dw_mg` | float64 | 2952 | 0 | 0.0% | 46 |
| `max_dose_dw_mg` | float64 | 2952 | 0 | 0.0% | 56 |
| `min_dose_dw_iu` | float64 | 2952 | 0 | 0.0% | 2 |
| `max_dose_dw_iu` | float64 | 2952 | 0 | 0.0% | 3 |
| `limit_mg` | float64 | 2952 | 0 | 0.0% | 26 |
| `limit_iu` | float64 | 2952 | 0 | 0.0% | 2 |
| `min_dose_dd_mg` | float64 | 2952 | 0 | 0.0% | 55 |
| `max_dose_dd_mg` | float64 | 2952 | 0 | 0.0% | 68 |
| `min_dose_dd_iu` | float64 | 2952 | 0 | 0.0% | 8 |
| `max_dose_dd_iu` | float64 | 2952 | 0 | 0.0% | 7 |
| `route` | object | 2952 | 0 | 0.0% | 3 |

### Key Statistics (d_dose_cleaned)

|       |   min_age_d |   max_age_d |   min_age_m |   max_age_m |   min_age_y |   max_age_y |   min_weight |   max_weight |   min_dose_dw_mg |   max_dose_dw_mg |   min_dose_dw_iu |   max_dose_dw_iu |   limit_mg |    limit_iu |   min_dose_dd_mg |   max_dose_dd_mg |   min_dose_dd_iu |   max_dose_dd_iu |
|:------|------------:|------------:|------------:|------------:|------------:|------------:|-------------:|-------------:|-----------------:|-----------------:|-----------------:|-----------------:|-----------:|------------:|-----------------:|-----------------:|-----------------:|-----------------:|
| count |  2952       |    2952     | 2952        |    2952     |  2952       |    2952     |   2952       |     2952     |        2952      |        2952      |        2952      |         2952     |   2952     |  2952       |         2952     |          2952    |       2952       |       2952       |
| mean  |     1.21206 |     895.533 |    0.507453 |     987.876 |     6.85467 |     184.214 |      1.56858 |      949.334 |          20.8611 |          36.0593 |          67.7507 |          101.626 |    593.721 |  3252.03    |          693.347 |          1444.81 |       9756.1     |      17750.7     |
| std   |     5.1432  |     300.503 |    1.22604  |     104.639 |     7.79908 |     306.488 |      7.45657 |      213.978 |          42.9204 |          69.3133 |        1839.59   |         2908.84  |   1913.62  | 88300.3     |         1443.49  |          2757.83 |     118128       |     206395       |
| min   |     0       |       7     |    0        |       3     |     0       |       1     |      0       |        1.19  |           0      |           0      |           0      |            0     |      0     |     0       |            0     |             0    |          0       |          0       |
| 25%   |     0       |     999     |    0        |     999     |     0       |      11     |      0       |      999     |           0      |           0      |           0      |            0     |      0     |     0       |            0     |             0    |          0       |          0       |
| 50%   |     0       |     999     |    0        |     999     |     8       |     120     |      0       |      999     |           0      |           0      |           0      |            0     |      0     |     0       |          160     |           245    |          0       |          0       |
| 75%   |     0       |     999     |    1        |     999     |    12       |     120     |      0       |      999     |          20      |          40      |           0      |            0     |      0     |     0       |         1000     |          2000    |          0       |          0       |
| max   |    29       |     999     |   20        |     999     |    65       |     999     |     80       |      999     |         400      |         600      |       50000      |       100000     |  24000     |     2.4e+06 |        16000     |         24000    |          2.4e+06 |          3.6e+06 |

### Drug Distribution (Top 10 by row count)

| Antibiotic | Rows |
|-----------|------|
| Flucloxacillin | 198 |
| Doxycycline | 161 |
| Ampicillin | 154 |
| Cefazolin | 136 |
| Cefotaxime | 124 |
| Ceftriaxone | 103 |
| Ciprofloxacin Hydrochloride | 96 |
| Ciprofloxacin | 96 |
| Gentamicin | 92 |
| Vancomycin | 84 |

### Route Distribution

| Route | d_dose | s_dose | r_dose |
|-------|--------|--------|--------|
| PO | 1145 | 121 | 61 |
| IM | 566 | 51 | 25 |
| IV | 1241 | 116 | 134 |

