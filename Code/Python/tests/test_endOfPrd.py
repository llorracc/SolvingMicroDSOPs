"""Smoke tests for the EndOfPrd class (end-of-period value functions)."""

import numpy as np
import pytest

from resources import Utility, DiscreteApproximationToMeanOneLogNormal
from endOfPrd import EndOfPrd


@pytest.fixture
def eop():
    """EndOfPrd object with baseline parameters for period T-1."""
    rho = 2.0
    u = Utility(rho)
    beta = 0.96
    Gamma = np.array([1.0])
    R = 1.02
    dstn = DiscreteApproximationToMeanOneLogNormal(N=7, sigma=0.5)
    return EndOfPrd(u, beta, rho, Gamma, R, dstn)


class TestEndOfPrd:
    """Basic properties of the EndOfPrd class."""

    def test_instantiation(self, eop):
        assert eop.CRRA == 2.0
        assert eop.DiscFac == 0.96
        assert eop.Rfree == 1.02

    def test_has_expected_methods(self, eop):
        assert callable(eop.vEndPrd)
        assert callable(eop.vCntnδ)
        assert callable(eop.cCntn)

    def test_vEndPrd_finite(self, eop):
        a_grid = np.linspace(0.5, 10.0, 20)
        v = eop.vEndPrd(a_grid, t=-1)
        assert np.all(np.isfinite(v))

    def test_marginal_value_positive(self, eop):
        a_grid = np.linspace(0.5, 10.0, 20)
        vδ = eop.vCntnδ(a_grid, t=-1)
        assert np.all(vδ > 0)

    def test_consumed_function_positive(self, eop):
        a_grid = np.linspace(0.5, 10.0, 20)
        c = eop.cCntn(a_grid, t=-1)
        assert np.all(c > 0)

    def test_marginal_value_decreasing(self, eop):
        a_vals = np.array([0.5, 1.0, 2.0, 5.0])
        mv = eop.vCntnδ(a_vals, t=-1)
        assert np.all(np.diff(mv) < 0), "Marginal value should decrease in a"

    def test_consumed_function_increasing(self, eop):
        a_vals = np.array([0.5, 1.0, 2.0, 5.0])
        cv = eop.cCntn(a_vals, t=-1)
        assert np.all(np.diff(cv) > 0), "Consumed function should increase in a"


class TestRoundTrip:
    """u'(cCntn(a)) should equal vCntnδ(a) by the FOC inversion."""

    def test_uprime_of_cCntn_equals_vCntnδ(self, eop):
        a_vals = np.array([0.5, 1.0, 2.0, 5.0])
        c = eop.cCntn(a_vals, t=-1)
        lhs = np.array([eop.uFunc.δ(ci) for ci in c])
        rhs = eop.vCntnδ(a_vals, t=-1)
        np.testing.assert_allclose(lhs, rhs, rtol=1e-8,
                                   err_msg="Round-trip failed: u'(cCntn(a)) != vCntnδ(a)")
