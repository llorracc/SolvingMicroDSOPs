"""Smoke tests for the resources module (utility, discrete approximation, grids)."""

import numpy as np
import pytest

from resources import (
    Utility,
    DiscreteApproximation,
    DiscreteApproximationToMeanOneLogNormal,
    setup_grids_expMult,
    get_improved_grid,
)
import scipy.stats as stats


class TestUtility:
    """CRRA utility u(c) = c^{1-rho}/(1-rho) and its derivatives."""

    def test_positive_consumption(self):
        u = Utility(2.0)
        assert np.isfinite(u(1.0))
        assert np.isfinite(u(0.5))

    def test_marginal_utility_positive(self):
        u = Utility(2.0)
        assert u.δ(1.0) > 0
        assert u.δ(0.5) > u.δ(1.0)

    def test_marginal_utility_decreasing(self):
        u = Utility(2.0)
        c_grid = np.linspace(0.1, 5.0, 50)
        mu = np.array([u.δ(c) for c in c_grid])
        assert np.all(np.diff(mu) < 0)

    def test_inverse_marginal_utility(self):
        u = Utility(2.0)
        c = 1.5
        mu = u.δ(c)
        c_recovered = mu ** (-1.0 / 2.0)
        assert abs(c_recovered - c) < 1e-10

    def test_rho_one_is_log(self):
        u = Utility(1.0)
        assert abs(u(np.e) - 1.0) < 1e-10

    def test_second_derivative_at_one(self):
        u = Utility(2.0)
        assert abs(u.δδ(1.0) - (-2.0)) < 1e-15

    def test_concavity(self):
        u = Utility(3.0)
        c_vals = np.linspace(0.5, 5.0, 20)
        u2 = np.array([u.δδ(c) for c in c_vals])
        assert np.all(u2 < 0)


class TestDiscreteApproximation:
    """Equiprobable discrete approximation to a continuous distribution."""

    def test_mean_one_lognormal(self):
        da = DiscreteApproximationToMeanOneLogNormal(N=7, sigma=0.5)
        mean = np.dot(da.pmf, da.X)
        assert abs(mean - 1.0) < 0.01

    def test_probabilities_sum_to_one(self):
        da = DiscreteApproximationToMeanOneLogNormal(N=7, sigma=0.5)
        assert abs(np.sum(da.pmf) - 1.0) < 1e-12

    def test_N_nodes(self):
        for n in [3, 5, 11]:
            da = DiscreteApproximationToMeanOneLogNormal(N=n, sigma=0.5)
            assert len(da.X) == n
            assert len(da.pmf) == n

    def test_general_distribution(self):
        z = stats.norm(0, 1)
        da = DiscreteApproximation(N=7, cdf=z.cdf, pdf=z.pdf, invcdf=z.ppf)
        mean = np.dot(da.pmf, da.X)
        assert abs(mean - 0.0) < 0.05


class TestGridConstruction:
    """Multi-exponential grid spacing."""

    def test_grid_bounds(self):
        grid = setup_grids_expMult(0.0, 100.0, 200)
        assert grid[0] >= 0.0
        assert grid[-1] <= 100.0 + 1e-10

    def test_grid_monotone(self):
        grid = setup_grids_expMult(0.0, 50.0, 100)
        assert np.all(np.diff(grid) > 0)

    def test_grid_size(self):
        n = 200
        grid = setup_grids_expMult(0.0, 100.0, n)
        assert len(grid) >= n * 0.8


class TestGetImprovedGrid:
    """get_improved_grid: alternative grid construction."""

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
