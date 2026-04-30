"""
Clean the raw BatteryPass-Ready Data Attribute Longlist.

Run from project root:
    python src/data/clean_longlist.py

Outputs:
    data/processed/attributes_clean.csv   (wide format)
    data/processed/attributes_long.csv    (melted: one row per attribute × battery type)
"""

from __future__ import annotations

import os
from pathlib import Path

import pandas as pd

# ------------------------------------------------------------
# Paths
# ------------------------------------------------------------
PROJECT_ROOT = Path(__file__).resolve().parents[2]
RAW_FILE = PROJECT_ROOT / "data" / "raw" / "2026_BatteryPassReady_DataAttributeLongList_v1_3.xlsx"
PROCESSED_DIR = PROJECT_ROOT / "data" / "processed"
SHEET_NAME = "Data attribute longlist_DR_v1.3"
HEADER_ROW = 6   # confirmed during Day 0 profiling


def load_raw() -> pd.DataFrame:
    """Load the raw longlist with the correct header row."""
    return pd.read_excel(RAW_FILE, sheet_name=SHEET_NAME, header=HEADER_ROW)


def clean_wide(df: pd.DataFrame) -> pd.DataFrame:
    """
    Apply standardization to the wide-format longlist.

    Steps to implement on Day 1:
        - drop fully empty columns / rows
        - rename columns to snake_case
        - standardize mandatory markers ('x' / '(x)' → consistent codes)
        - normalize categorical text (case, whitespace)
        - cast booleans where appropriate
        - validate row count == 100
    """
    out = df.copy()
    out = out.dropna(how="all").dropna(axis=1, how="all")
    # TODO: implement the cleaning steps above
    return out


def melt_to_long(df_wide: pd.DataFrame) -> pd.DataFrame:
    """
    Reshape wide → long: one row per (attribute, battery_type).

    Identify the 4 battery-type mandatory-flag columns, melt them into
    (battery_type, mandatory_flag) tuples.
    """
    # TODO: implement the melt once column names are stable
    raise NotImplementedError("Implement on Day 1 once cleaning is finalized")


def main() -> None:
    PROCESSED_DIR.mkdir(parents=True, exist_ok=True)

    raw = load_raw()
    print(f"Loaded raw: {raw.shape}")

    wide = clean_wide(raw)
    wide_path = PROCESSED_DIR / "attributes_clean.csv"
    wide.to_csv(wide_path, index=False)
    print(f"Wrote {wide_path}")

    # long = melt_to_long(wide)
    # long_path = PROCESSED_DIR / "attributes_long.csv"
    # long.to_csv(long_path, index=False)
    # print(f"Wrote {long_path}")


if __name__ == "__main__":
    main()
