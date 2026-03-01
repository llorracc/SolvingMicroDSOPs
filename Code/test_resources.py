"""Unit tests for Code/Python/resources.py."""

import numpy as np
import pytest
from resources import (
    DiscreteApproximation,
    DiscreteApproximationToMeanOneLogNormal,
    Utility,
    get_improved_grid,
)


# ---------------------------------------------------------------------------
# DiscreteApproximation / DiscreteApproximationToMeanOneLogNormal
# ---------------------------------------------------------------------------

class TestDiscreteApproxMeanOneLogNormal:
    @pytest.fixture
    def approx7(self):
        return DiscreteApproximationToMeanOneLogNormal(N=7, sigma=0.1)

    def test_correct_count(self, approx7):
        assert len(approx7.X) == 7
        assert len(approx7.pmf) == 7

    def test_weights_sum_to_one(self, approx7):
        assert abs(approx7.pmf.sum() - 1.0) < 1e-12

    def test_mean_one(self, approx7):
        assert abs(approx7.E() - 1.0) < 1e-12

    def test_expectation_of_identity(self, approx7):
        assert abs(approx7.E(lambda x: x) - 1.0) < 1e-12

    def test_values_positive(self, approx7):
        assert np.all(approx7.X > 0)

    def test_values_sorted(self, approx7):
        assert np.all(np.diff(approx7.X) > 0)

    def test_small_n(self):
        approx = DiscreteApproximationToMeanOneLogNormal(N=3, sigma=0.2)
        assert len(approx.X) == 3
        assert abs(approx.E() - 1.0) < 1e-10


# ---------------------------------------------------------------------------
# Utility (CRRA)
# ---------------------------------------------------------------------------

class TestUtility:
    def test_crra2_at_one(self):
        u = Utility(2.0)
        assert abs(u(1.0) - (-1.0)) < 1e-15  # 1^(-1)/(-1) = -1

    def test_crra2_marginal_at_one(self):
        u = Utility(2.0)
        assert abs(u.δc(1.0) - 1.0) < 1e-15  # 1^(-2) = 1

    def test_crra2_second_deriv_at_one(self):
        u = Utility(2.0)
        assert abs(u.δcδc(1.0) - (-2.0)) < 1e-15  # -2 * 1^(-3) = -2

    def test_log_utility(self):
        u = Utility(1.0)
        assert abs(u(np.e) - 1.0) < 1e-12
        assert abs(u.δc(2.0) - 0.5) < 1e-12

    def test_marginal_positive_and_decreasing(self):
        u = Utility(2.0)
        c_vals = np.linspace(0.5, 5.0, 20)
        mu = np.array([u.δc(c) for c in c_vals])
        assert np.all(mu > 0)
        assert np.all(np.diff(mu) < 0)

    def test_concavity(self):
        u = Utility(3.0)
        c_vals = np.linspace(0.5, 5.0, 20)
        u2 = np.array([u.δcδc(c) for c in c_vals])
        assert np.all(u2 < 0)


# ---------------------------------------------------------------------------
# get_improved_grid
# ---------------------------------------------------------------------------

class TestGetImprovedGrid:
    def test_returns_array_like(self):
        grid = get_improved_grid(0.01, 20.0, 50)
        assert len(grid) > 0

    def test_monotonically_increasing(self):
        grid = get_improved_grid(0.01, 20.0, 50)
        assert np.all(np.diff(grid) > 0)

    def test_all_positive(self):
        grid = get_improved_grid(0.01, 20.0, 50)
        assert np.all(np.array(grid) > 0)

    def test_different_sizes(self):
        g10 = get_improved_grid(0.01, 20.0, 10)
        g50 = get_improved_grid(0.01, 20.0, 50)
        assert len(g50) > len(g10)
