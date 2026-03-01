"""Unit tests for Code/Python/endOfPrd.py."""

import numpy as np
import pytest
from resources import (
    DiscreteApproximationToMeanOneLogNormal,
    Utility,
)
from endOfPrd import EndOfPrd


@pytest.fixture
def eop():
    """Construct an EndOfPrd object with standard parameters."""
    CRRA = 2.0
    DiscFac = 0.96
    Rfree = 1.03
    PermGroFac = np.array([1.0, 1.0])  # two-element for indexing
    sigma = 0.1
    IncShkDstn = DiscreteApproximationToMeanOneLogNormal(N=5, sigma=sigma)
    uFunc = Utility(CRRA)
    return EndOfPrd(uFunc, DiscFac, CRRA, PermGroFac, Rfree, IncShkDstn)


class TestVEndPrd:
    def test_scalar_input_scalar_output(self, eop):
        val = eop.vEndPrd(1.0)
        assert np.isscalar(val) or val.ndim == 0

    def test_negative_value_for_crra_gt1(self, eop):
        val = eop.vEndPrd(1.0)
        assert val < 0  # CRRA=2 -> u(c) = c^(-1)/(-1) < 0


class TestVδaCntn:
    def test_Tm1_positive(self, eop):
        val = eop.vδaCntn_Tm1(1.0)
        assert val > 0

    def test_Tm1_decreasing(self, eop):
        a_vals = np.array([0.5, 1.0, 2.0, 5.0])
        mv = np.array([eop.vδaCntn_Tm1(a) for a in a_vals])
        assert np.all(np.diff(mv) < 0), "Marginal value should decrease in a"


class TestCCntn:
    def test_Tm1_positive(self, eop):
        val = eop.cCntn_Tm1(1.0)
        assert val > 0

    def test_Tm1_increasing(self, eop):
        a_vals = np.array([0.5, 1.0, 2.0, 5.0])
        cv = np.array([eop.cCntn_Tm1(a) for a in a_vals])
        assert np.all(np.diff(cv) > 0), "Consumed function should increase in a"


class TestRoundTrip:
    def test_uprime_of_cCntn_equals_vδaCntn(self, eop):
        """u'(cCntn(a)) should approximately equal vδaCntn(a)."""
        a_vals = np.array([0.5, 1.0, 2.0, 5.0])
        for a in a_vals:
            c = eop.cCntn_Tm1(a)
            lhs = eop.uFunc.δc(c)
            rhs = eop.vδaCntn_Tm1(a)
            assert abs(lhs - rhs) / max(abs(rhs), 1e-15) < 1e-8, (
                f"Round-trip failed at a={a}: u'(c)={lhs}, vδaCntn={rhs}"
            )
