"""Tests for the modular multi-control stage architecture.

Tests cover:
  - disc stage: pure discount passthrough
  - cons-noshocks: EGM produces monotone, concave consumption function
  - portable (bar_Shr=0): shocks-only matches old Connector logic
  - portable (optimize): portfolio share in [0,1], FOC near zero
  - period-cons-only equivalence with cons-with-shocks (existing solver)
  - period-port-cons: well-behaved consumption and Shr functions
  - period-cons-port: well-behaved
  - finite and infinite horizon modular solvers
"""

import numpy as np
import pytest
import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'Python'))

from solution import ModelParams, Connector, BetweenPeriodConnector
from stages.disc import solve_disc
from stages.cons_noshocks import solve_cons_noshocks, build_a_grid
from stages.portable import solve_portable, make_shock_distribution
from period_types import (
    PeriodSpec, PERIOD_CONS_ONLY, PERIOD_PORT_CONS, PERIOD_CONS_PORT,
    PERIOD_PORT_ONLY, make_terminal_solution, wrap_terminal_with_portable,
    solve_period, _get_dcsn_funcs,
)
from solve_modular import (
    solve_modular_finite, solve_modular_infinite,
    _get_c_func, _find_target_m,
)


@pytest.fixture
def params():
    return ModelParams()


@pytest.fixture
def shock_dstn(params):
    return make_shock_distribution(params)


# ==========================================================================
# Phase 1 tests: ModelParams and BetweenPeriodConnector
# ==========================================================================

class TestModelParams:
    def test_portfolio_params_exist(self, params):
        assert hasattr(params, 'equity_premium')
        assert hasattr(params, 'sigma_risky')
        assert hasattr(params, 'n_risky')
        assert params.equity_premium == 0.04
        assert params.sigma_risky == 0.15
        assert params.n_risky == 7

    def test_RNrmByG(self, params):
        assert abs(params.RNrmByG - params.Rfree / params.PermGroFac) < 1e-15


class TestBetweenPeriodConnector:
    def test_identity(self):
        conn = BetweenPeriodConnector()
        a = np.array([1.0, 2.0, 3.0])
        k = conn.connect(a)
        np.testing.assert_array_equal(a, k)
        assert a is not k  # should be a copy


# ==========================================================================
# Phase 2 tests: disc stage
# ==========================================================================

class TestDiscStage:
    def test_value_scaling(self, params):
        """v_disc = beta * Gamma^{1-rho} * v_cntn."""
        v_cntn = lambda x: np.sin(x)
        vda_cntn = lambda x: np.cos(x)
        stg = solve_disc(v_cntn, vda_cntn, params)

        x = np.array([0.5, 1.0, 2.0, 5.0])
        expected_factor = params.DiscFac * params.PermGroFac ** (1.0 - params.CRRA)

        np.testing.assert_allclose(
            stg['arvl'].v(x), expected_factor * np.sin(x), rtol=1e-14)

    def test_marginal_scaling(self, params):
        """v'_disc = beta * Gamma^{1-rho} * v'_cntn (same factor as v)."""
        v_cntn = lambda x: np.sin(x)
        vda_cntn = lambda x: np.cos(x)
        stg = solve_disc(v_cntn, vda_cntn, params)

        x = np.array([0.5, 1.0, 2.0])
        expected_factor = params.DiscFac * params.PermGroFac ** (1.0 - params.CRRA)

        np.testing.assert_allclose(
            stg['arvl'].vda(x), expected_factor * np.cos(x), rtol=1e-14)

    def test_cntn_perch_stores_original(self, params):
        v_cntn = lambda x: x ** 2
        vda_cntn = lambda x: 2 * x
        stg = solve_disc(v_cntn, vda_cntn, params)

        x = np.array([3.0])
        assert stg['cntn'].v(x) == 9.0
        assert stg['cntn'].vda(x) == 6.0


# ==========================================================================
# Phase 3 tests: cons-noshocks stage
# ==========================================================================

class TestConsNoshocks:
    def test_monotone_consumption(self, params):
        """c*(m) should be strictly increasing in m."""
        rho = params.CRRA
        v_cntn = lambda a: np.maximum(a, 1e-300) ** (1 - rho) / (1 - rho)
        vda_cntn = lambda a: np.maximum(a, 1e-300) ** (-rho)

        stg = solve_cons_noshocks(v_cntn, vda_cntn, params, a_min=0.0)
        c_func = stg['dcsn'].c

        m_grid = np.linspace(0.5, 10.0, 50)
        c_vals = c_func(m_grid)
        assert np.all(np.diff(c_vals) > 0), "consumption should be monotone increasing"

    def test_consumption_between_zero_and_m(self, params):
        """0 <= c*(m) <= m."""
        rho = params.CRRA
        v_cntn = lambda a: np.maximum(a, 1e-300) ** (1 - rho) / (1 - rho)
        vda_cntn = lambda a: np.maximum(a, 1e-300) ** (-rho)

        stg = solve_cons_noshocks(v_cntn, vda_cntn, params, a_min=0.0)
        c_func = stg['dcsn'].c

        m_grid = np.linspace(0.5, 10.0, 50)
        c_vals = c_func(m_grid)
        assert np.all(c_vals >= 0), "consumption should be non-negative"
        assert np.all(c_vals <= m_grid + 1e-10), "consumption should not exceed m"

    def test_concavity(self, params):
        """c*(m) should be concave: c''(m) <= 0, i.e. MPC decreasing."""
        rho = params.CRRA
        v_cntn = lambda a: np.maximum(a, 1e-300) ** (1 - rho) / (1 - rho)
        vda_cntn = lambda a: np.maximum(a, 1e-300) ** (-rho)

        stg = solve_cons_noshocks(v_cntn, vda_cntn, params, a_min=0.0)
        c_func = stg['dcsn'].c

        m_grid = np.linspace(1.0, 10.0, 100)
        c_vals = c_func(m_grid)
        # MPC = dc/dm should be non-increasing
        mpc = np.diff(c_vals) / np.diff(m_grid)
        assert np.all(np.diff(mpc) <= 1e-6), "MPC should be non-increasing (concavity)"


# ==========================================================================
# Phase 4 tests: portable stage
# ==========================================================================

class TestPortableShocksOnly:
    """Test portable stage with bar_Shr=0 (shocks only, no risky asset)."""

    def test_matches_old_connector_value(self, params, shock_dstn):
        """portable(Shr=0) v should match Connector.continuation_value
        (up to the discount factor, which is in disc)."""
        from solve import make_connector

        connector = make_connector(params)
        rho = params.CRRA
        v_next = lambda m: np.maximum(m, 1e-300) ** (1 - rho) / (1 - rho)
        vda_next = lambda m: np.maximum(m, 1e-300) ** (-rho)

        a_grid = build_a_grid(1e-10, params.a_max, params.a_grid_size)

        # Old: includes discount
        v_old = connector.continuation_value(v_next, a_grid)

        # New portable: no discount, just shock integration
        k_grid = a_grid.copy()
        stg = solve_portable(v_next, vda_next, params, shock_dstn,
                             k_grid=k_grid, bar_Shr=0.0)

        # Portable gives raw E[v((R/G)*k + theta)], old gives beta*G^{1-rho}*E[...]
        discount = params.DiscFac * params.PermGroFac ** (1.0 - rho)
        v_new = stg['arvl'].v(k_grid)

        np.testing.assert_allclose(v_old, discount * v_new, rtol=1e-3)

    def test_matches_old_connector_marginal(self, params, shock_dstn):
        """portable(Shr=0) vda should match Connector.marginal_continuation_value
        (up to the discount factor)."""
        from solve import make_connector

        connector = make_connector(params)
        rho = params.CRRA
        v_next = lambda m: np.maximum(m, 1e-300) ** (1 - rho) / (1 - rho)
        vda_next = lambda m: np.maximum(m, 1e-300) ** (-rho)

        a_grid = build_a_grid(1e-10, params.a_max, params.a_grid_size)

        vda_old = connector.marginal_continuation_value(vda_next, a_grid)

        k_grid = a_grid.copy()
        stg = solve_portable(v_next, vda_next, params, shock_dstn,
                             k_grid=k_grid, bar_Shr=0.0)

        # Old marginal: beta * R * G^{-rho} * E[v'(...)]
        # = beta * G^{1-rho} * (R/G) * E[v'(...)]
        # = discount * (R/G) * E[v'(...)]
        # Portable gives (R/G) * E[v'(...)], disc gives beta*G^{1-rho}
        discount = params.DiscFac * params.PermGroFac ** (1.0 - rho)
        vda_new = stg['arvl'].vda(k_grid)

        np.testing.assert_allclose(vda_old, discount * vda_new, rtol=1e-3)


class TestPortableOptimize:
    """Test portable stage with portfolio optimization (bar_Shr=None)."""

    def test_share_in_bounds(self, params, shock_dstn):
        rho = params.CRRA
        v_next = lambda m: np.maximum(m, 1e-300) ** (1 - rho) / (1 - rho)
        vda_next = lambda m: np.maximum(m, 1e-300) ** (-rho)

        k_grid = build_a_grid(1e-10, params.a_max, 50)
        stg = solve_portable(v_next, vda_next, params, shock_dstn,
                             k_grid=k_grid, bar_Shr=None)

        Shr_func = stg['dcsn'].Shr
        Shr_vals = Shr_func(k_grid)
        assert np.all(Shr_vals >= -0.01), "portfolio share should be >= 0"
        assert np.all(Shr_vals <= 1.01), "portfolio share should be <= 1"

    def test_positive_equity_premium_gives_positive_share(self, params, shock_dstn):
        """With positive equity premium, optimal Shr should be > 0 for most k."""
        rho = params.CRRA
        v_next = lambda m: np.maximum(m, 1e-300) ** (1 - rho) / (1 - rho)
        vda_next = lambda m: np.maximum(m, 1e-300) ** (-rho)

        k_grid = build_a_grid(1.0, 20.0, 30)
        stg = solve_portable(v_next, vda_next, params, shock_dstn,
                             k_grid=k_grid, bar_Shr=None)

        Shr_vals = stg['dcsn'].Shr(k_grid)
        assert np.mean(Shr_vals > 0.01) > 0.5, \
            "most portfolio shares should be positive with equity premium > 0"


# ==========================================================================
# Phase 5 tests: period types
# ==========================================================================

class TestPeriodConsOnly:
    """period-cons-only should closely match the old cons-with-shocks solver."""

    def test_equivalence_T_minus_1(self, params, shock_dstn):
        """Single backward step from terminal should match old solver."""
        from solve import solve_finite_horizon, STAGE_NAME

        T = 2
        pile = solve_finite_horizon(T, params)
        c_old = pile[T - 1][STAGE_NAME]['dcsn'].c

        result = solve_modular_finite(T, PERIOD_CONS_ONLY, params)
        c_new = result['solutions'][T - 1]['cons-noshocks']['dcsn'].c

        m_test = np.linspace(1.0, 10.0, 30)
        c_old_vals = np.array([c_old(m) for m in m_test])
        c_new_vals = np.array([c_new(m) for m in m_test])
        max_diff = np.max(np.abs(c_old_vals - c_new_vals))
        assert max_diff < 0.01, f"T-1 c(m) diff = {max_diff:.4e}"

    def test_equivalence_multi_period(self, params, shock_dstn):
        """Multi-period backward induction should match old solver."""
        from solve import solve_finite_horizon, STAGE_NAME

        T = 10
        pile = solve_finite_horizon(T, params)
        result = solve_modular_finite(T, PERIOD_CONS_ONLY, params)

        m_test = np.linspace(1.0, 10.0, 30)
        for t in [0, 5, T - 1]:
            c_old = pile[t][STAGE_NAME]['dcsn'].c
            c_new = result['solutions'][t]['cons-noshocks']['dcsn'].c
            diffs = [abs(c_old(m) - c_new(m)) for m in m_test]
            assert max(diffs) < 0.01, \
                f"Period {t}: max |c_old - c_new| = {max(diffs):.4e}"


class TestPeriodPortCons:
    """period-port-cons: consumption + portfolio optimization."""

    def test_well_behaved_consumption(self, params, shock_dstn):
        T = 5
        result = solve_modular_finite(T, PERIOD_PORT_CONS, params)
        sol = result['solutions'][T - 1]
        c_func = sol['cons-noshocks']['dcsn'].c

        m_grid = np.linspace(1.0, 10.0, 30)
        c_vals = c_func(m_grid)
        assert np.all(np.diff(c_vals) > 0), "consumption should increase with m"
        assert np.all(c_vals > 0), "consumption should be positive"
        assert np.all(c_vals <= m_grid + 1e-6), "consumption <= m"

    def test_portfolio_share_exists(self, params, shock_dstn):
        T = 5
        result = solve_modular_finite(T, PERIOD_PORT_CONS, params)
        sol = result['solutions'][T - 1]
        assert 'portable' in sol.stg
        Shr_func = sol['portable']['dcsn'].Shr
        k_test = np.array([1.0, 5.0, 10.0])
        Shr_vals = Shr_func(k_test)
        assert np.all(Shr_vals >= -0.01) and np.all(Shr_vals <= 1.01)


# ==========================================================================
# Phase 6 tests: modular solvers
# ==========================================================================

class TestModularFinite:
    def test_basic_run(self, params):
        result = solve_modular_finite(5, PERIOD_CONS_ONLY, params)
        assert len(result['solutions']) == 6  # periods 0..5

    def test_terminal_has_portable(self, params):
        result = solve_modular_finite(3, PERIOD_CONS_ONLY, params)
        terminal = result['solutions'][3]
        assert 'portable' in terminal.stg, \
            "terminal should be wrapped with portable stage"


class TestModularInfinite:
    def test_convergence(self, params):
        result = solve_modular_infinite(PERIOD_CONS_ONLY, params)
        assert result['converged'], \
            f"should converge, got {result['iterations']} iterations"

    def test_target_m_reasonable(self, params):
        result = solve_modular_infinite(PERIOD_CONS_ONLY, params)
        c_func = _get_c_func(result['solution'])
        m_hat = _find_target_m(c_func, params)
        assert 1.0 < m_hat < 20.0, f"target m = {m_hat} out of range"

    def test_matches_old_infinite_horizon(self, params):
        """Infinite-horizon modular should be close to old solver."""
        from solve import solve_infinite_horizon, STAGE_NAME, _find_target_m as old_find

        pile = solve_infinite_horizon(params)
        c_old = pile[0][STAGE_NAME]['dcsn'].c
        m_old = old_find(c_old, params)

        result = solve_modular_infinite(PERIOD_CONS_ONLY, params)
        c_new = _get_c_func(result['solution'])
        m_new = _find_target_m(c_new, params)

        assert abs(m_old - m_new) < 0.05, \
            f"target m: old={m_old:.4f}, new={m_new:.4f}"

        m_test = np.linspace(1.0, 10.0, 20)
        c_old_vals = np.array([c_old(m) for m in m_test])
        c_new_vals = np.array([c_new(m) for m in m_test])
        max_diff = np.max(np.abs(c_old_vals - c_new_vals))
        assert max_diff < 0.01, f"infinite-horizon c(m) diff = {max_diff:.4e}"


# ==========================================================================
# Integration: portfolio period types
# ==========================================================================

class TestPortfolioIntegration:
    """Smoke tests for period types involving portfolio choice."""

    def test_port_cons_finite_runs(self, params):
        result = solve_modular_finite(3, PERIOD_PORT_CONS, params)
        assert len(result['solutions']) == 4

    def test_port_only_finite_runs(self, params):
        result = solve_modular_finite(3, PERIOD_PORT_ONLY, params)
        assert len(result['solutions']) == 4

    def test_cons_port_finite_runs(self, params):
        result = solve_modular_finite(3, PERIOD_CONS_PORT, params)
        assert len(result['solutions']) == 4


if __name__ == '__main__':
    pytest.main([__file__, '-v', '--tb=short'])
