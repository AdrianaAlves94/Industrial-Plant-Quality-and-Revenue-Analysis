"""
Tests for the complexity score module.

Run from project root:
    pytest tests/
"""

import pandas as pd
import pytest

from src.features.complexity import (
    add_complexity_columns,
    assign_complexity_band,
    compute_complexity_score,
)


class TestComputeComplexityScore:
    def test_all_zero_signals_returns_zero(self):
        row = pd.Series({
            "is_dynamic": False,
            "granularity": "pack",
            "regulation_count": 1,
            "is_complex_format": False,
        })
        assert compute_complexity_score(row) == 0

    def test_dynamic_adds_two(self):
        row = pd.Series({
            "is_dynamic": True,
            "granularity": "pack",
            "regulation_count": 1,
            "is_complex_format": False,
        })
        assert compute_complexity_score(row) == 2

    def test_cell_granularity_adds_two(self):
        row = pd.Series({
            "is_dynamic": False,
            "granularity": "cell",
            "regulation_count": 1,
            "is_complex_format": False,
        })
        assert compute_complexity_score(row) == 2

    def test_multi_regulation_adds_one(self):
        row = pd.Series({
            "is_dynamic": False,
            "granularity": "pack",
            "regulation_count": 3,
            "is_complex_format": False,
        })
        assert compute_complexity_score(row) == 1

    def test_max_score_signals_combine(self):
        row = pd.Series({
            "is_dynamic": True,
            "granularity": "cell",
            "regulation_count": 5,
            "is_complex_format": True,
        })
        # 2 (dynamic) + 2 (cell) + 1 (multi-reg) + 1 (complex format) = 6
        assert compute_complexity_score(row) == 6

    def test_unknown_granularity_treated_as_zero(self):
        row = pd.Series({
            "is_dynamic": False,
            "granularity": "wat",
            "regulation_count": 1,
            "is_complex_format": False,
        })
        assert compute_complexity_score(row) == 0


class TestAssignComplexityBand:
    @pytest.mark.parametrize(
        "score,expected_band",
        [
            (0, "low"),
            (1, "low"),
            (2, "medium"),
            (3, "medium"),
            (4, "high"),
            (6, "high"),
        ],
    )
    def test_band_thresholds(self, score, expected_band):
        assert assign_complexity_band(score) == expected_band


class TestAddComplexityColumns:
    def test_adds_two_columns_without_mutating_input(self):
        df = pd.DataFrame([
            {"is_dynamic": True, "granularity": "cell", "regulation_count": 2, "is_complex_format": False},
            {"is_dynamic": False, "granularity": "pack", "regulation_count": 1, "is_complex_format": False},
        ])
        original_columns = df.columns.tolist()
        out = add_complexity_columns(df)

        assert "complexity_score" in out.columns
        assert "complexity_band" in out.columns
        # ensure input is unchanged
        assert df.columns.tolist() == original_columns
