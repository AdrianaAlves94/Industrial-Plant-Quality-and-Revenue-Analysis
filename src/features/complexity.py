"""
Complexity score for the EU Battery Passport attributes.

The score is a rule-based composite of four signals:
    - dynamic vs static
    - granularity (cell / module / pack / system)
    - number of regulations referencing the attribute
    - data format complexity

Rubric is intentionally interpretable. Weights are defended in the report's
methodology section.
"""

from __future__ import annotations

import pandas as pd

# ------------------------------------------------------------
# Rubric — review and adjust on Day 2 before computing
# ------------------------------------------------------------

DYNAMIC_WEIGHT = 2          # +2 if attribute is dynamic (vs static)
GRANULARITY_WEIGHTS = {     # how fine the data needs to be
    "cell": 2,
    "module": 1,
    "pack": 0,
    "system": 0,
}
MULTI_REGULATION_WEIGHT = 1  # +1 if referenced by 2+ regulations
COMPLEX_FORMAT_WEIGHT = 1    # +1 if format is non-trivial (e.g. structured doc, time-series)


def compute_complexity_score(row: pd.Series) -> int:
    """
    Compute the compliance complexity score for a single attribute row.

    Expected columns on `row`:
        - is_dynamic (bool)
        - granularity (str)
        - regulation_count (int)
        - is_complex_format (bool)

    Returns
    -------
    int
        Complexity score (0-6 typical range, never negative).
    """
    score = 0

    if row.get("is_dynamic", False):
        score += DYNAMIC_WEIGHT

    granularity = str(row.get("granularity", "")).lower()
    score += GRANULARITY_WEIGHTS.get(granularity, 0)

    if row.get("regulation_count", 0) >= 2:
        score += MULTI_REGULATION_WEIGHT

    if row.get("is_complex_format", False):
        score += COMPLEX_FORMAT_WEIGHT

    return score


def assign_complexity_band(score: int) -> str:
    """Bin scores into low / medium / high for visualization."""
    if score <= 1:
        return "low"
    if score <= 3:
        return "medium"
    return "high"


def add_complexity_columns(df: pd.DataFrame) -> pd.DataFrame:
    """
    Add complexity_score and complexity_band columns to an attribute dataframe.
    Returns a copy.
    """
    out = df.copy()
    out["complexity_score"] = out.apply(compute_complexity_score, axis=1)
    out["complexity_band"] = out["complexity_score"].apply(assign_complexity_band)
    return out
