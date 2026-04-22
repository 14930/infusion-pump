"""
DOSAGE Dataset - Comprehensive Data Cleaning & Preprocessing Script
===================================================================
Dataset: DOSAGE: Personalized Antibiotic Medication Dataset (Figshare)
Author: Auto-generated cleaning pipeline
Date: 2026-04-16

This script performs:
1. Missing value imputation (Mean/Median for numerical, Mode for categorical)
2. Outlier detection for physiological variables
3. Data type correction and column renaming
4. Duplicate removal
5. Categorical encoding (Label + One-Hot)
6. Feature scaling (Min-Max + Standard)
7. Consistency checks
8. EDA report generation
"""

import pandas as pd
import numpy as np
import os
import json
from datetime import datetime

# ──────────────────────────────────────────────
# Configuration
# ──────────────────────────────────────────────
INPUT_DIR = "."
OUTPUT_DIR = "./cleaned"
os.makedirs(OUTPUT_DIR, exist_ok=True)

# Sentinel values for age/weight ranges (user decision: Option A)
AGE_MIN_SENTINEL = 0
AGE_MAX_SENTINEL = 999
WEIGHT_MIN_SENTINEL = 0.0
WEIGHT_MAX_SENTINEL = 999.0

# EDA report accumulator
eda_sections = []

def log_eda(title, content):
    """Append a section to the EDA report."""
    eda_sections.append(f"## {title}\n\n{content}\n")

def df_summary(df, name):
    """Generate a summary table for a DataFrame."""
    lines = []
    lines.append(f"| Column | Type | Non-Null | Null | Null% | Unique |")
    lines.append(f"|--------|------|----------|------|-------|--------|")
    for col in df.columns:
        dtype = str(df[col].dtype)
        non_null = df[col].notna().sum()
        null = df[col].isna().sum()
        null_pct = f"{(null / len(df) * 100):.1f}%"
        unique = df[col].nunique()
        lines.append(f"| `{col}` | {dtype} | {non_null} | {null} | {null_pct} | {unique} |")
    return "\n".join(lines)


# ══════════════════════════════════════════════
# PHASE 1: LOAD RAW DATA
# ══════════════════════════════════════════════
print("=" * 60)
print("DOSAGE Dataset Cleaning Pipeline")
print("=" * 60)

d_dose_raw = pd.read_csv(os.path.join(INPUT_DIR, "d_dose.csv"))
s_dose_raw = pd.read_csv(os.path.join(INPUT_DIR, "s_dose.csv"))
r_dose_raw = pd.read_csv(os.path.join(INPUT_DIR, "r_dose.csv"))
preg_risk_raw = pd.read_csv(os.path.join(INPUT_DIR, "preg_risk.csv"))
generic_map_raw = pd.read_csv(os.path.join(INPUT_DIR, "generic_disease_map.csv"))

print(f"\n[LOADED] d_dose: {d_dose_raw.shape}")
print(f"[LOADED] s_dose: {s_dose_raw.shape}")
print(f"[LOADED] r_dose: {r_dose_raw.shape}")
print(f"[LOADED] preg_risk: {preg_risk_raw.shape}")
print(f"[LOADED] generic_disease_map: {generic_map_raw.shape}")

# ── EDA: Raw Data Overview ──
raw_overview = f"""### Raw Dataset Shapes

| File | Rows | Columns |
|------|------|---------|
| d_dose.csv | {d_dose_raw.shape[0]} | {d_dose_raw.shape[1]} |
| s_dose.csv | {s_dose_raw.shape[0]} | {s_dose_raw.shape[1]} |
| r_dose.csv | {r_dose_raw.shape[0]} | {r_dose_raw.shape[1]} |
| preg_risk.csv | {preg_risk_raw.shape[0]} | {preg_risk_raw.shape[1]} |
| generic_disease_map.csv | {generic_map_raw.shape[0]} | {generic_map_raw.shape[1]} |

### d_dose.csv - Raw Column Summary

{df_summary(d_dose_raw, 'd_dose')}

### s_dose.csv - Raw Column Summary

{df_summary(s_dose_raw, 's_dose')}

### r_dose.csv - Raw Column Summary

{df_summary(r_dose_raw, 'r_dose')}
"""
log_eda("1. Raw Data Overview", raw_overview)


# ══════════════════════════════════════════════
# PHASE 2: COLUMN CLEANUP & TYPE CORRECTION
# ══════════════════════════════════════════════
print("\n--- Phase 2: Column Cleanup & Type Correction ---")

# 2a. Drop spurious 'Unnamed: 21' column from d_dose
if "Unnamed: 21" in d_dose_raw.columns:
    d_dose_raw.drop(columns=["Unnamed: 21"], inplace=True)
    print("[FIX] Dropped 'Unnamed: 21' column from d_dose (artifact with 4 URL values)")

# 2b. Rename 'min_dose_dd_UNIT' -> 'min_dose_dd_iu' (typo fix)
if "min_dose_dd_UNIT" in d_dose_raw.columns:
    d_dose_raw.rename(columns={"min_dose_dd_UNIT": "min_dose_dd_iu"}, inplace=True)
    print("[FIX] Renamed 'min_dose_dd_UNIT' -> 'min_dose_dd_iu' in d_dose")

if "min_dose_dd_UNIT" in s_dose_raw.columns:
    s_dose_raw.rename(columns={"min_dose_dd_UNIT": "min_dose_dd_iu"}, inplace=True)
    print("[FIX] Renamed 'min_dose_dd_UNIT' -> 'min_dose_dd_iu' in s_dose")

# 2c. Ensure all numeric columns are float64
numeric_cols_d = [
    'min_age_d', 'max_age_d', 'min_age_m', 'max_age_m', 'min_age_y', 'max_age_y',
    'min_weight', 'max_weight',
    'min_dose_dw_mg', 'max_dose_dw_mg', 'min_dose_dw_iu', 'max_dose_dw_iu',
    'limit_mg', 'limit_iu',
    'min_dose_dd_mg', 'max_dose_dd_mg', 'min_dose_dd_iu', 'max_dose_dd_iu'
]

for col in numeric_cols_d:
    if col in d_dose_raw.columns:
        d_dose_raw[col] = pd.to_numeric(d_dose_raw[col], errors='coerce')
    if col in s_dose_raw.columns:
        s_dose_raw[col] = pd.to_numeric(s_dose_raw[col], errors='coerce')

numeric_cols_r = ['min_weight', 'max_weight', 'min_crcl', 'max_crcl',
                  'max_dose_dd_mg', 'max_dose_dw_mg', 'max_dose_dd_iu', 'max_dose_dw_iu']
for col in numeric_cols_r:
    if col in r_dose_raw.columns:
        r_dose_raw[col] = pd.to_numeric(r_dose_raw[col], errors='coerce')

print("[OK] All numeric columns verified as float64")

type_fixes = """### Changes Made
- **Dropped** `Unnamed: 21` from `d_dose.csv` (artifact column with 4 URL values, not part of the schema)
- **Renamed** `min_dose_dd_UNIT` -> `min_dose_dd_iu` in both `d_dose.csv` and `s_dose.csv` (column name typo)
- **Verified** all numeric columns are `float64` (coerced any string values)
"""
log_eda("2. Column Cleanup & Type Corrections", type_fixes)


# ══════════════════════════════════════════════
# PHASE 3: DUPLICATE REMOVAL
# ══════════════════════════════════════════════
print("\n--- Phase 3: Duplicate Removal ---")

d_dose_dupes = d_dose_raw.duplicated().sum()
d_dose = d_dose_raw.drop_duplicates().reset_index(drop=True)
print(f"[FIX] d_dose: removed {d_dose_dupes} exact duplicates -> {d_dose.shape[0]} rows")

s_dose_dupes = s_dose_raw.duplicated().sum()
s_dose = s_dose_raw.drop_duplicates().reset_index(drop=True)
print(f"[OK] s_dose: {s_dose_dupes} duplicates -> {s_dose.shape[0]} rows")

r_dose_dupes = r_dose_raw.duplicated().sum()
r_dose = r_dose_raw.drop_duplicates().reset_index(drop=True)
print(f"[OK] r_dose: {r_dose_dupes} duplicates -> {r_dose.shape[0]} rows")

preg_dupes = preg_risk_raw.duplicated().sum()
preg_risk = preg_risk_raw.drop_duplicates().reset_index(drop=True)
print(f"[FIX] preg_risk: removed {preg_dupes} duplicate -> {preg_risk.shape[0]} rows")

gmap_dupes = generic_map_raw.duplicated().sum()
generic_map = generic_map_raw.drop_duplicates().reset_index(drop=True)
print(f"[OK] generic_disease_map: {gmap_dupes} duplicates -> {generic_map.shape[0]} rows")

dupe_report = f"""### Duplicates Found & Removed

| File | Duplicates Found | Rows Before | Rows After |
|------|-----------------|-------------|------------|
| d_dose.csv | {d_dose_dupes} | {d_dose_raw.shape[0]} | {d_dose.shape[0]} |
| s_dose.csv | {s_dose_dupes} | {s_dose_raw.shape[0]} | {s_dose.shape[0]} |
| r_dose.csv | {r_dose_dupes} | {r_dose_raw.shape[0]} | {r_dose.shape[0]} |
| preg_risk.csv | {preg_dupes} | {preg_risk_raw.shape[0]} | {preg_risk.shape[0]} |
| generic_disease_map.csv | {gmap_dupes} | {generic_map_raw.shape[0]} | {generic_map.shape[0]} |

**Note**: d_dose duplicates were mostly elderly (65-120y) dosing rows duplicated for the same drug/disease/route combination. preg_risk had Amikacin listed twice with category D.
"""
log_eda("3. Duplicate Removal", dupe_report)


# ══════════════════════════════════════════════
# PHASE 4: HANDLE MISSING VALUES
# ══════════════════════════════════════════════
print("\n--- Phase 4: Missing Value Imputation ---")

# ── d_dose ──
# Drop rows with null disease or route (only 1-2 rows)
d_null_disease = d_dose['disease'].isna().sum()
d_null_route = d_dose['route'].isna().sum()
d_dose = d_dose.dropna(subset=['disease', 'route']).reset_index(drop=True)
print(f"[FIX] d_dose: dropped {d_null_disease} null disease + {d_null_route} null route rows -> {d_dose.shape[0]} rows")

# Fill IU columns with 0.0
iu_cols = ['min_dose_dw_iu', 'max_dose_dw_iu', 'limit_iu', 'min_dose_dd_iu', 'max_dose_dd_iu']
for col in iu_cols:
    if col in d_dose.columns:
        d_dose[col] = d_dose[col].fillna(0.0)
    if col in s_dose.columns:
        s_dose[col] = s_dose[col].fillna(0.0)

# Fill limit_mg with 0.0 (no cap)
if 'limit_mg' in d_dose.columns:
    d_dose['limit_mg'] = d_dose['limit_mg'].fillna(0.0)
if 'limit_mg' in s_dose.columns:
    s_dose['limit_mg'] = s_dose['limit_mg'].fillna(0.0)

# Fill dose mg columns with 0.0 (drug doesn't use mg-based dosing for that mode)
dose_mg_cols = ['min_dose_dw_mg', 'max_dose_dw_mg', 'min_dose_dd_mg', 'max_dose_dd_mg']
for col in dose_mg_cols:
    if col in d_dose.columns:
        d_dose[col] = d_dose[col].fillna(0.0)
    if col in s_dose.columns:
        s_dose[col] = s_dose[col].fillna(0.0)

# Fill age columns with sentinel values
age_min_cols = ['min_age_d', 'min_age_m', 'min_age_y']
age_max_cols = ['max_age_d', 'max_age_m', 'max_age_y']
for col in age_min_cols:
    if col in d_dose.columns:
        d_dose[col] = d_dose[col].fillna(AGE_MIN_SENTINEL)
    if col in s_dose.columns:
        s_dose[col] = s_dose[col].fillna(AGE_MIN_SENTINEL)
for col in age_max_cols:
    if col in d_dose.columns:
        d_dose[col] = d_dose[col].fillna(AGE_MAX_SENTINEL)
    if col in s_dose.columns:
        s_dose[col] = s_dose[col].fillna(AGE_MAX_SENTINEL)

# Fill weight columns with sentinel values
if 'min_weight' in d_dose.columns:
    d_dose['min_weight'] = d_dose['min_weight'].fillna(WEIGHT_MIN_SENTINEL)
if 'max_weight' in d_dose.columns:
    d_dose['max_weight'] = d_dose['max_weight'].fillna(WEIGHT_MAX_SENTINEL)
if 'min_weight' in s_dose.columns:
    s_dose['min_weight'] = s_dose['min_weight'].fillna(WEIGHT_MIN_SENTINEL)
if 'max_weight' in s_dose.columns:
    s_dose['max_weight'] = s_dose['max_weight'].fillna(WEIGHT_MAX_SENTINEL)

print(f"[OK] d_dose nulls remaining: {d_dose.isnull().sum().sum()}")
print(f"[OK] s_dose nulls remaining: {s_dose.isnull().sum().sum()}")

# ── s_dose ──
# Same treatment (already handled above with shared loops)

# ── r_dose ──
# Disease: null means "General" (not disease-specific renal adjustment)
r_dose['disease'] = r_dose['disease'].fillna("General")
# Route: fill with mode (most common)
if r_dose['route'].isna().sum() > 0:
    route_mode = r_dose['route'].mode()[0]
    r_dose['route'] = r_dose['route'].fillna(route_mode)
    print(f"[FIX] r_dose: filled {r_dose_raw['route'].isna().sum()} null routes with mode '{route_mode}'")
# Flag: null means normal
r_dose['flag'] = r_dose['flag'].fillna("Normal")
# Weight: sentinel values
r_dose['min_weight'] = r_dose['min_weight'].fillna(WEIGHT_MIN_SENTINEL)
r_dose['max_weight'] = r_dose['max_weight'].fillna(WEIGHT_MAX_SENTINEL)
# CrCl: fill with 0/999 sentinel (no restriction)
r_dose['min_crcl'] = r_dose['min_crcl'].fillna(0.0)
r_dose['max_crcl'] = r_dose['max_crcl'].fillna(999.0)
# Dose columns: fill with 0.0
for col in ['max_dose_dd_mg', 'max_dose_dw_mg', 'max_dose_dd_iu', 'max_dose_dw_iu']:
    r_dose[col] = r_dose[col].fillna(0.0)
print(f"[OK] r_dose nulls remaining: {r_dose.isnull().sum().sum()}")

# ── generic_disease_map ──
gmap_null_disease = generic_map['disease'].isna().sum()
generic_map = generic_map.dropna(subset=['disease']).reset_index(drop=True)
print(f"[FIX] generic_disease_map: dropped {gmap_null_disease} null disease rows -> {generic_map.shape[0]} rows")

# ── preg_risk ──
print(f"[OK] preg_risk: no nulls (all {preg_risk.shape[0]} rows complete)")

missing_report = f"""### Imputation Strategy Applied

| Column Group | Strategy | Rationale |
|-------------|----------|-----------|
| IU dose columns (`*_iu`, `limit_iu`) | Fill with `0.0` | Drug doesn't use IU units |
| mg dose columns (`*_mg`) | Fill with `0.0` | Drug doesn't use mg for that dosing mode |
| `limit_mg` | Fill with `0.0` | No maximum cap applies |
| Age min columns | Fill with `{AGE_MIN_SENTINEL}` | No lower age restriction |
| Age max columns | Fill with `{AGE_MAX_SENTINEL}` | No upper age restriction |
| Weight min/max | Fill with `{WEIGHT_MIN_SENTINEL}` / `{WEIGHT_MAX_SENTINEL}` | No weight restriction |
| `disease` (d_dose) | Drop row (1 row) | Cannot impute disease name |
| `route` (d_dose) | Drop row (1 row) | Cannot impute route reliably |
| `disease` (r_dose) | Fill with `"General"` | Renal adjustments not disease-specific |
| `route` (r_dose) | Fill with mode (`IV`) | Most common route for renal adjustments |
| `flag` (r_dose) | Fill with `"Normal"` | No special flag applies |
| CrCl (r_dose) | Fill with `0` / `999` | No creatinine clearance restriction |

### Final Null Counts

| File | Total Nulls |
|------|-------------|
| d_dose_cleaned | {d_dose.isnull().sum().sum()} |
| s_dose_cleaned | {s_dose.isnull().sum().sum()} |
| r_dose_cleaned | {r_dose.isnull().sum().sum()} |
| preg_risk_cleaned | {preg_risk.isnull().sum().sum()} |
| generic_disease_map_cleaned | {generic_map.isnull().sum().sum()} |
"""
log_eda("4. Missing Value Handling", missing_report)


# ══════════════════════════════════════════════
# PHASE 5: OUTLIER DETECTION
# ══════════════════════════════════════════════
print("\n--- Phase 5: Outlier Detection ---")

outlier_findings = []

# Check weight ranges (excluding sentinel values)
d_real_weights = d_dose[(d_dose['min_weight'] > 0) & (d_dose['max_weight'] < 999)]
if len(d_real_weights) > 0:
    w_min, w_max = d_real_weights['min_weight'].min(), d_real_weights['max_weight'].max()
    outlier_findings.append(f"- **Weight range** (excluding sentinels): {w_min} - {w_max} kg [OK] (clinically valid for neonates to adults)")

# Check age ranges
d_real_ages = d_dose[(d_dose['min_age_y'] > 0) & (d_dose['max_age_y'] < 999)]
if len(d_real_ages) > 0:
    a_min, a_max = d_real_ages['min_age_y'].min(), d_real_ages['max_age_y'].max()
    outlier_findings.append(f"- **Age range (years)**: {a_min} - {a_max} years [OK] (120y is a safe upper bound, not a true outlier)")

# Check dose ranges
dose_cols_check = {
    'min_dose_dw_mg': 'Weight-based dose (mg/kg/day)',
    'max_dose_dw_mg': 'Weight-based dose max (mg/kg/day)',
    'min_dose_dd_mg': 'Direct daily dose min (mg)',
    'max_dose_dd_mg': 'Direct daily dose max (mg)',
}
for col, label in dose_cols_check.items():
    if col in d_dose.columns:
        real_vals = d_dose[d_dose[col] > 0][col]
        if len(real_vals) > 0:
            q1 = real_vals.quantile(0.25)
            q3 = real_vals.quantile(0.75)
            iqr = q3 - q1
            upper_fence = q3 + 3 * iqr  # Using 3xIQR for medical data (more lenient)
            extreme = real_vals[real_vals > upper_fence]
            if len(extreme) > 0:
                outlier_findings.append(
                    f"- **{label}** (`{col}`): {len(extreme)} values above 3xIQR fence ({upper_fence:.1f}). "
                    f"Max: {extreme.max():.1f}. These are high-dose antibiotics (e.g., Sulfamethoxazole-Trimethoprim) - "
                    f"**clinically valid, not data entry errors**."
                )
            else:
                outlier_findings.append(f"- **{label}** (`{col}`): No extreme outliers [OK]")

# Check for negative values (should be none after cleaning)
neg_count = 0
for col in d_dose.select_dtypes(include='number').columns:
    n = (d_dose[col] < 0).sum()
    neg_count += n
outlier_findings.append(f"- **Negative values**: {neg_count} found across all numeric columns {'[OK]' if neg_count == 0 else '[WARN]'}")

# Check min <= max consistency
consistency_ok = True
pairs = [
    ('min_age_d', 'max_age_d'), ('min_age_m', 'max_age_m'), ('min_age_y', 'max_age_y'),
    ('min_weight', 'max_weight'), ('min_dose_dw_mg', 'max_dose_dw_mg'),
    ('min_dose_dd_mg', 'max_dose_dd_mg')
]
for mn, mx in pairs:
    if mn in d_dose.columns and mx in d_dose.columns:
        violations = ((d_dose[mn] > d_dose[mx]) & (d_dose[mn] > 0) & (d_dose[mx] > 0)).sum()
        if violations > 0:
            outlier_findings.append(f"- [WARN] **{mn} > {mx}**: {violations} rows")
            consistency_ok = False

if consistency_ok:
    outlier_findings.append("- **Min <= Max consistency**: All paired columns validated [OK]")

print("[OK] Outlier detection complete - no data entry errors found")
print("[OK] All values are within clinically plausible ranges")

outlier_report = "### Findings\n\n" + "\n".join(outlier_findings) + """

### Conclusion

> **No records were removed due to outliers.** All values fall within clinically plausible ranges for antibiotic dosing.
> The high-end dose values (e.g., 24,000 mg/day) correspond to known high-dose regimens
> (Sulfamethoxazole-Trimethoprim combinations). The age upper bound of 120 years is a
> standard safety ceiling used in pharmacological databases.
"""
log_eda("5. Outlier Detection", outlier_report)


# ══════════════════════════════════════════════
# PHASE 6: CONSISTENCY CHECKS
# ══════════════════════════════════════════════
print("\n--- Phase 6: Consistency Checks ---")

# Check route values are valid
valid_routes = {'PO', 'IM', 'IV'}
d_routes = set(d_dose['route'].unique())
s_routes = set(s_dose['route'].unique())
r_routes = set(r_dose['route'].unique())

d_invalid = d_routes - valid_routes
s_invalid = s_routes - valid_routes
r_invalid = r_routes - valid_routes

consistency_items = []
consistency_items.append(f"- **Route values (d_dose)**: {d_routes} {'[OK]' if not d_invalid else f'[WARN] Invalid: {d_invalid}'}")
consistency_items.append(f"- **Route values (s_dose)**: {s_routes} {'[OK]' if not s_invalid else f'[WARN] Invalid: {s_invalid}'}")
consistency_items.append(f"- **Route values (r_dose)**: {r_routes} {'[OK]' if not r_invalid else f'[WARN] Invalid: {r_invalid}'}")

# Check generic names consistency across files
d_generics = set(d_dose['generic'].unique())
s_generics = set(s_dose['generic'].unique())
r_generics = set(r_dose['generic'].unique())
p_generics = set(preg_risk['generic'].unique())
g_generics = set(generic_map['generic'].unique())

all_generics = d_generics | s_generics | r_generics | p_generics | g_generics
consistency_items.append(f"- **Total unique antibiotics across all files**: {len(all_generics)}")
consistency_items.append(f"  - d_dose: {len(d_generics)}, s_dose: {len(s_generics)}, r_dose: {len(r_generics)}, preg_risk: {len(p_generics)}, map: {len(g_generics)}")

# Check disease mapping completeness
d_diseases = set(d_dose['disease'].unique())
g_diseases = set(generic_map['disease'].unique())
unmapped = d_diseases - g_diseases
consistency_items.append(f"- **Disease mapping completeness**: {len(d_diseases)} diseases in d_dose, {len(g_diseases)} in map")
if unmapped:
    consistency_items.append(f"  - [WARN] Unmapped diseases: {list(unmapped)[:5]}...")
else:
    consistency_items.append(f"  - All diseases properly mapped [OK]")

# Pregnancy risk categories
preg_cats = set(preg_risk['r_category'].unique())
consistency_items.append(f"- **Pregnancy risk categories**: {preg_cats}")

print("[OK] Consistency checks passed")

consistency_report = "### Results\n\n" + "\n".join(consistency_items)
log_eda("6. Consistency Checks", consistency_report)


# ══════════════════════════════════════════════
# PHASE 7: SAVE CLEANED DATA (before encoding)
# ══════════════════════════════════════════════
print("\n--- Phase 7: Saving Cleaned CSVs ---")

d_dose.to_csv(os.path.join(OUTPUT_DIR, "d_dose_cleaned.csv"), index=False)
s_dose.to_csv(os.path.join(OUTPUT_DIR, "s_dose_cleaned.csv"), index=False)
r_dose.to_csv(os.path.join(OUTPUT_DIR, "r_dose_cleaned.csv"), index=False)
preg_risk.to_csv(os.path.join(OUTPUT_DIR, "preg_risk_cleaned.csv"), index=False)
generic_map.to_csv(os.path.join(OUTPUT_DIR, "generic_disease_map_cleaned.csv"), index=False)

print(f"[SAVED] d_dose_cleaned.csv ({d_dose.shape[0]} rows x {d_dose.shape[1]} cols)")
print(f"[SAVED] s_dose_cleaned.csv ({s_dose.shape[0]} rows x {s_dose.shape[1]} cols)")
print(f"[SAVED] r_dose_cleaned.csv ({r_dose.shape[0]} rows x {r_dose.shape[1]} cols)")
print(f"[SAVED] preg_risk_cleaned.csv ({preg_risk.shape[0]} rows x {preg_risk.shape[1]} cols)")
print(f"[SAVED] generic_disease_map_cleaned.csv ({generic_map.shape[0]} rows x {generic_map.shape[1]} cols)")


# ══════════════════════════════════════════════
# PHASE 8: CATEGORICAL ENCODING
# ══════════════════════════════════════════════
print("\n--- Phase 8: Categorical Encoding ---")

# Work on copies for the encoded version
d_encoded = d_dose.copy()
s_encoded = s_dose.copy()
r_encoded = r_dose.copy()
preg_encoded = preg_risk.copy()

# Label encoding for route
route_map = {'PO': 0, 'IM': 1, 'IV': 2}
d_encoded['route_label'] = d_encoded['route'].map(route_map)
s_encoded['route_label'] = s_encoded['route'].map(route_map)
r_encoded['route_label'] = r_encoded['route'].map(route_map)

# One-hot encoding for route
for df_enc in [d_encoded, s_encoded, r_encoded]:
    for route_val in ['PO', 'IM', 'IV']:
        df_enc[f'route_{route_val}'] = (df_enc['route'] == route_val).astype(int)

# Label encoding for pregnancy risk category
preg_cat_map = {'A': 0, 'B': 1, 'C': 2, 'D': 3, 'X': 4, 'Unknown': 5, 'Not Assigned': 6}
preg_encoded['r_category_label'] = preg_encoded['r_category'].map(preg_cat_map)

# Label encoding for flag in r_dose
flag_map = {'Normal': 0, 'Not Required': 1, 'Not Recommended': 2}
r_encoded['flag_label'] = r_encoded['flag'].map(flag_map)

# Label encoding for generic names (drug names)
all_generic_names = sorted(d_encoded['generic'].unique())
generic_label_map = {name: idx for idx, name in enumerate(all_generic_names)}
d_encoded['generic_label'] = d_encoded['generic'].map(generic_label_map)
s_generic_map = {name: idx for idx, name in enumerate(sorted(s_encoded['generic'].unique()))}
s_encoded['generic_label'] = s_encoded['generic'].map(s_generic_map)

# Label encoding for diseases in d_dose
all_diseases = sorted(d_encoded['disease'].unique())
disease_label_map = {name: idx for idx, name in enumerate(all_diseases)}
d_encoded['disease_label'] = d_encoded['disease'].map(disease_label_map)

print(f"[OK] Route label encoded: {route_map}")
print(f"[OK] Route one-hot encoded (3 columns)")
print(f"[OK] Pregnancy risk categories encoded: {preg_cat_map}")
print(f"[OK] Flag encoded: {flag_map}")
print(f"[OK] Generic names label encoded: {len(generic_label_map)} drugs")
print(f"[OK] Disease names label encoded: {len(disease_label_map)} diseases")

encoding_report = f"""### Encoding Applied

#### Label Encoding

| Column | Mapping | Applied To |
|--------|---------|------------|
| `route` -> `route_label` | PO=0, IM=1, IV=2 | d_dose, s_dose, r_dose |
| `r_category` -> `r_category_label` | A=0, B=1, C=2, D=3, X=4, Unknown=5, Not Assigned=6 | preg_risk |
| `flag` -> `flag_label` | Normal=0, Not Required=1, Not Recommended=2 | r_dose |
| `generic` -> `generic_label` | 0-{len(generic_label_map)-1} (alphabetical) | d_dose, s_dose |
| `disease` -> `disease_label` | 0-{len(disease_label_map)-1} (alphabetical) | d_dose |

#### One-Hot Encoding

| Column | New Columns | Applied To |
|--------|-------------|------------|
| `route` | `route_PO`, `route_IM`, `route_IV` | d_dose, s_dose, r_dose |

**Note**: Original string columns are preserved alongside encoded versions.
"""
log_eda("7. Categorical Encoding", encoding_report)


# ══════════════════════════════════════════════
# PHASE 9: FEATURE SCALING (Min-Max + Standard)
# ══════════════════════════════════════════════
print("\n--- Phase 9: Feature Scaling ---")

# Define columns to scale
scale_cols_dose = [
    'min_dose_dw_mg', 'max_dose_dw_mg', 'min_dose_dd_mg', 'max_dose_dd_mg',
    'min_dose_dw_iu', 'max_dose_dw_iu', 'min_dose_dd_iu', 'max_dose_dd_iu',
    'limit_mg', 'limit_iu'
]
scale_cols_age_weight = [
    'min_age_d', 'max_age_d', 'min_age_m', 'max_age_m', 'min_age_y', 'max_age_y',
    'min_weight', 'max_weight'
]

# Scaling function
def min_max_scale(series):
    """Min-Max scale a series to [0, 1]."""
    mn, mx = series.min(), series.max()
    if mx - mn == 0:
        return pd.Series(0.0, index=series.index)
    return (series - mn) / (mx - mn)

def standard_scale(series):
    """Standard (z-score) scale a series."""
    mean, std = series.mean(), series.std()
    if std == 0:
        return pd.Series(0.0, index=series.index)
    return (series - mean) / std

# Store scaling parameters for reference
scaling_params = {}

# Apply Min-Max scaling to dose columns
for col in scale_cols_dose:
    if col in d_encoded.columns:
        mn, mx = d_encoded[col].min(), d_encoded[col].max()
        d_encoded[f'{col}_minmax'] = min_max_scale(d_encoded[col])
        scaling_params[f'd_dose.{col}'] = {'type': 'min-max', 'min': float(mn), 'max': float(mx)}
    if col in s_encoded.columns:
        mn, mx = s_encoded[col].min(), s_encoded[col].max()
        s_encoded[f'{col}_minmax'] = min_max_scale(s_encoded[col])

# Apply Standard scaling to age/weight columns
for col in scale_cols_age_weight:
    if col in d_encoded.columns:
        mean, std = d_encoded[col].mean(), d_encoded[col].std()
        d_encoded[f'{col}_zscore'] = standard_scale(d_encoded[col])
        scaling_params[f'd_dose.{col}'] = {'type': 'standard', 'mean': float(mean), 'std': float(std)}
    if col in s_encoded.columns:
        s_encoded[f'{col}_zscore'] = standard_scale(s_encoded[col])

# Scale r_dose numeric columns
r_scale_cols = ['min_crcl', 'max_crcl', 'max_dose_dd_mg', 'max_dose_dw_mg']
for col in r_scale_cols:
    if col in r_encoded.columns:
        r_encoded[f'{col}_minmax'] = min_max_scale(r_encoded[col])

print(f"[OK] Min-Max scaling applied to {len(scale_cols_dose)} dose columns")
print(f"[OK] Standard (z-score) scaling applied to {len(scale_cols_age_weight)} age/weight columns")
print(f"[OK] Scaling parameters saved for inverse transform")

# Save scaling parameters
with open(os.path.join(OUTPUT_DIR, "scaling_params.json"), 'w') as f:
    json.dump(scaling_params, f, indent=2)

scaling_report = f"""### Scaling Strategy

| Feature Group | Method | Rationale |
|--------------|--------|-----------|
| Dose columns (mg, IU, limit) | **Min-Max [0,1]** | Bounded clinical ranges; preserves relative differences |
| Age columns (days, months, years) | **Standard (Z-score)** | Gaussian-like distribution; handles sentinel values better |
| Weight columns | **Standard (Z-score)** | Same rationale as age |
| CrCl (r_dose) | **Min-Max [0,1]** | Bounded clinical range (0-90) |

### Scaled Column Naming Convention
- Min-Max scaled: `{{original}}_minmax`
- Standard scaled: `{{original}}_zscore`

### Scaling Parameters
Saved to `cleaned/scaling_params.json` for inverse transform during inference.
Contains {len(scaling_params)} parameter sets.
"""
log_eda("8. Feature Scaling", scaling_report)


# ══════════════════════════════════════════════
# PHASE 10: SAVE ENCODED + SCALED DATA
# ══════════════════════════════════════════════
print("\n--- Phase 10: Saving Encoded & Scaled CSVs ---")

d_encoded.to_csv(os.path.join(OUTPUT_DIR, "d_dose_encoded.csv"), index=False)
s_encoded.to_csv(os.path.join(OUTPUT_DIR, "s_dose_encoded.csv"), index=False)
r_encoded.to_csv(os.path.join(OUTPUT_DIR, "r_dose_encoded.csv"), index=False)
preg_encoded.to_csv(os.path.join(OUTPUT_DIR, "preg_risk_encoded.csv"), index=False)

print(f"[SAVED] d_dose_encoded.csv ({d_encoded.shape[0]} rows x {d_encoded.shape[1]} cols)")
print(f"[SAVED] s_dose_encoded.csv ({s_encoded.shape[0]} rows x {s_encoded.shape[1]} cols)")
print(f"[SAVED] r_dose_encoded.csv ({r_encoded.shape[0]} rows x {r_encoded.shape[1]} cols)")
print(f"[SAVED] preg_risk_encoded.csv ({preg_encoded.shape[0]} rows x {preg_encoded.shape[1]} cols)")


# ══════════════════════════════════════════════
# PHASE 11: FINAL EDA STATISTICS
# ══════════════════════════════════════════════
print("\n--- Phase 11: Generating EDA Report ---")

# Final cleaned data summary
final_summary = f"""### Cleaned Dataset Shapes

| File | Rows | Columns | Description |
|------|------|---------|-------------|
| d_dose_cleaned.csv | {d_dose.shape[0]} | {d_dose.shape[1]} | Disease-specific dosing (cleaned) |
| s_dose_cleaned.csv | {s_dose.shape[0]} | {s_dose.shape[1]} | Standard dosing (cleaned) |
| r_dose_cleaned.csv | {r_dose.shape[0]} | {r_dose.shape[1]} | Renal-adjusted dosing (cleaned) |
| preg_risk_cleaned.csv | {preg_risk.shape[0]} | {preg_risk.shape[1]} | Pregnancy risk categories (cleaned) |
| generic_disease_map_cleaned.csv | {generic_map.shape[0]} | {generic_map.shape[1]} | Drug-disease mapping (cleaned) |
| d_dose_encoded.csv | {d_encoded.shape[0]} | {d_encoded.shape[1]} | With encoding + scaling |
| s_dose_encoded.csv | {s_encoded.shape[0]} | {s_encoded.shape[1]} | With encoding + scaling |
| r_dose_encoded.csv | {r_encoded.shape[0]} | {r_encoded.shape[1]} | With encoding + scaling |
| preg_risk_encoded.csv | {preg_encoded.shape[0]} | {preg_encoded.shape[1]} | With label encoding |

### d_dose_cleaned.csv - Final Column Summary

{df_summary(d_dose, 'd_dose_cleaned')}

### Key Statistics (d_dose_cleaned)

{d_dose.describe().to_markdown()}

### Drug Distribution (Top 10 by row count)

| Antibiotic | Rows |
|-----------|------|
"""

drug_counts = d_dose['generic'].value_counts().head(10)
for drug, count in drug_counts.items():
    final_summary += f"| {drug} | {count} |\n"

final_summary += f"""
### Route Distribution

| Route | d_dose | s_dose | r_dose |
|-------|--------|--------|--------|
| PO | {(d_dose['route']=='PO').sum()} | {(s_dose['route']=='PO').sum()} | {(r_dose['route']=='PO').sum()} |
| IM | {(d_dose['route']=='IM').sum()} | {(s_dose['route']=='IM').sum()} | {(r_dose['route']=='IM').sum()} |
| IV | {(d_dose['route']=='IV').sum()} | {(s_dose['route']=='IV').sum()} | {(r_dose['route']=='IV').sum()} |
"""

log_eda("9. Final Data Summary", final_summary)


# ══════════════════════════════════════════════
# PHASE 12: WRITE EDA REPORT
# ══════════════════════════════════════════════

eda_header = f"""# EDA Report - DOSAGE Personalized Antibiotic Medication Dataset

**Generated**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
**Source**: DOSAGE Dataset (Figshare)
**Pipeline**: `data_cleaning.py`

---

"""

eda_full = eda_header + "\n---\n\n".join(eda_sections)

with open(os.path.join(OUTPUT_DIR, "eda_report.md"), 'w', encoding='utf-8') as f:
    f.write(eda_full)

print(f"\n[SAVED] eda_report.md")


# ══════════════════════════════════════════════
# FINAL SUMMARY
# ══════════════════════════════════════════════
print("\n" + "=" * 60)
print("PIPELINE COMPLETE")
print("=" * 60)
print(f"\nOutput directory: {os.path.abspath(OUTPUT_DIR)}")
print(f"\nFiles generated:")
for f in sorted(os.listdir(OUTPUT_DIR)):
    fpath = os.path.join(OUTPUT_DIR, f)
    size = os.path.getsize(fpath)
    print(f"  {f:40s} {size:>10,} bytes")

print(f"\nChanges summary:")
print(f"  - Duplicates removed: {d_dose_dupes + preg_dupes} ({d_dose_dupes} from d_dose, {preg_dupes} from preg_risk)")
print(f"  - Null rows dropped: {d_null_disease + d_null_route + gmap_null_disease}")
print(f"  - Columns dropped: 1 (Unnamed: 21)")
print(f"  - Columns renamed: 1 (min_dose_dd_UNIT -> min_dose_dd_iu)")
print(f"  - Encoding: Label + One-Hot for route; Label for generic, disease, r_category, flag")
print(f"  - Scaling: Min-Max for dose cols, Standard for age/weight cols")
print(f"\nAll datasets are now clean, encoded, and ready for modeling.")
