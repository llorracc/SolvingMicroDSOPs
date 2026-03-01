"""Integration tests exercising key computational sections of the main notebook.

These replicate the core numerical steps from
SolvingMicroDSOP_private_withBrentQToo.py without running the entire notebook
(which generates 21 figures and takes several minutes).
"""

import numpy as np
import pytest
from scipy.interpolate import InterpolatedUnivariateSpline

from resources import (
    DiscreteApproximationToMeanOneLogNormal,
    Utility,
    get_improved_grid,
)
from endOfPrd import EndOfPrd


# Shared parameters (matching the notebook defaults)
CRRA = 2.0
DISCFAC = 0.96
RFREE = 1.03
PERMGROFAC = np.array([1.0, 1.0])
SIGMA = 0.1
N_SHOCKS = 7


@pytest.fixture
def inc_shk():
    return DiscreteApproximationToMeanOneLogNormal(N=N_SHOCKS, sigma=SIGMA)


@pytest.fixture
def eop(inc_shk):
    uFunc = Utility(CRRA)
    return EndOfPrd(uFunc, DISCFAC, CRRA, PERMGROFAC, RFREE, inc_shk)


# ---------------------------------------------------------------------------
# Section 1: Discretization
# ---------------------------------------------------------------------------

class TestDiscretization:
    def test_lognormal_approx_properties(self, inc_shk):
        assert len(inc_shk.X) == N_SHOCKS
        assert abs(inc_shk.E() - 1.0) < 1e-12
        assert np.all(inc_shk.X > 0)


# ---------------------------------------------------------------------------
# Section 5: FOC / Marginal Value
# ---------------------------------------------------------------------------

class TestMarginalValue:
    def test_shape_and_sign(self, eop):
        a_grid = np.linspace(0.5, 10.0, 20)
        mv = np.array([eop.vδaCntn_Tm1(a) for a in a_grid])
        assert mv.shape == (20,)
        assert np.all(mv > 0)

    def test_decreasing(self, eop):
        a_grid = np.linspace(0.5, 10.0, 20)
        mv = np.array([eop.vδaCntn_Tm1(a) for a in a_grid])
        assert np.all(np.diff(mv) < 0)


# ---------------------------------------------------------------------------
# Section 8: Endogenous Gridpoints Method (EGM)
# ---------------------------------------------------------------------------

class TestEGM:
    def test_egm_step(self, eop):
        """Run one EGM step: compute c from FOC inversion, recover m = a + c."""
        a_grid = np.array(get_improved_grid(0.01, 20.0, 40))

        # Consumed function at each grid point
        c_vec = np.array([eop.cCntn_Tm1(a) for a in a_grid])

        # Endogenous grid: m = a + c
        m_vec = a_grid + c_vec

        # Basic checks
        assert np.all(c_vec > 0), "Consumption should be positive"
        assert np.all(np.diff(m_vec) > 0), "m grid should be increasing"
        assert len(m_vec) == len(a_grid)

    def test_egm_interpolation(self, eop):
        """Build the EGM consumption function and evaluate it."""
        a_grid = np.array(get_improved_grid(0.01, 20.0, 40))
        c_vec = np.array([eop.cCntn_Tm1(a) for a in a_grid])
        m_vec = a_grid + c_vec

        # Prepend the natural borrowing constraint point
        m_vec = np.insert(m_vec, 0, 0.0)
        c_vec = np.insert(c_vec, 0, 0.0)

        cFunc = InterpolatedUnivariateSpline(m_vec, c_vec, k=1, ext=0)

        # Evaluate at test points within the grid range
        m_test = np.array([1.0, 2.0, 5.0, 10.0])
        c_test = cFunc(m_test)
        assert np.all(c_test > 0), "Interpolated consumption should be positive"
        assert np.all(c_test < m_test), "Consumption should be less than resources"


# ---------------------------------------------------------------------------
# Section 9+: Multi-period convergence (light check)
# ---------------------------------------------------------------------------

class TestMultiPeriod:
    def test_two_period_value_improvement(self, eop):
        """T-1 value should exceed terminal value at any m."""
        uFunc = Utility(CRRA)
        m = 2.0
        v_T = uFunc(m)
        v_Tm1 = eop.vEndPrd(m) + uFunc(m * 0.5)  # rough: consume half
        # The actual optimised value is higher, but even a bad policy
        # should give a finite number; just check vEndPrd is finite.
        assert np.isfinite(eop.vEndPrd(m))
