"""Integration tests for Code/Python/StructEstimation.py.

These are marked slow because each call solves the full lifecycle model.
Run with: uv run pytest Code/test_struct_estimation.py -v
Skip with: uv run pytest -m "not slow"

NOTE: simulate_moments and smmObjectiveFxn currently fail with HARK 0.17.x
due to API changes (DiscFac as list vs scalar in check_restrictions).
Those tests are marked xfail until the compatibility is fixed.
"""

import pytest

slow = pytest.mark.slow


@slow
class TestStructEstimationImport:
    def test_module_loads(self):
        import StructEstimation
        assert hasattr(StructEstimation, "smmObjectiveFxn")
        assert hasattr(StructEstimation, "simulate_moments")

    def test_agent_type_exists(self):
        from StructEstimation import TempConsumerType
        assert TempConsumerType is not None

    def test_function_signatures(self):
        """Verify the expected function signatures exist."""
        import StructEstimation
        import inspect
        sig = inspect.signature(StructEstimation.simulate_moments)
        assert "DiscFacAdj" in sig.parameters
        assert "CRRA" in sig.parameters

        sig = inspect.signature(StructEstimation.smmObjectiveFxn)
        assert "DiscFacAdj" in sig.parameters
        assert "CRRA" in sig.parameters


@slow
class TestSimulateMoments:
    @pytest.mark.xfail(
        reason="HARK 0.17.x check_restrictions() cannot compare list DiscFac < 0",
        strict=False,
    )
    def test_returns_seven_medians(self):
        from StructEstimation import simulate_moments
        moments = simulate_moments(DiscFacAdj=0.96, CRRA=2.0)
        assert len(moments) == 7, f"Expected 7 age-group medians, got {len(moments)}"

    @pytest.mark.xfail(
        reason="HARK 0.17.x check_restrictions() cannot compare list DiscFac < 0",
        strict=False,
    )
    def test_medians_positive(self):
        from StructEstimation import simulate_moments
        moments = simulate_moments(DiscFacAdj=0.96, CRRA=2.0)
        for i, m in enumerate(moments):
            assert m > 0, f"Median for age group {i} is non-positive: {m}"


@slow
class TestSMMObjective:
    @pytest.mark.xfail(
        reason="HARK 0.17.x check_restrictions() cannot compare list DiscFac < 0",
        strict=False,
    )
    def test_returns_nonnegative_scalar(self):
        from StructEstimation import smmObjectiveFxn
        import numpy as np
        val = smmObjectiveFxn(DiscFacAdj=0.96, CRRA=2.0)
        assert np.isscalar(val) or (hasattr(val, 'ndim') and val.ndim == 0)
        assert val >= 0, f"Objective should be non-negative, got {val}"
