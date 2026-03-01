"""Smoke tests for period types and the modular solver."""

import numpy as np
import pytest

from solution import ModelParams
from period_types import (
    PERIOD_CONS_ONLY,
    PERIOD_PORT_CONS,
    PERIOD_CONS_PORT,
    PeriodSpec,
    make_terminal_solution,
    solve_period,
)
from stages.portable import make_shock_distribution


class TestPeriodSpecs:
    """Period type definitions are consistent."""

    def test_cons_only_has_three_stages(self):
        assert len(PERIOD_CONS_ONLY.stage_names) == 3

    def test_port_cons_has_three_stages(self):
        assert len(PERIOD_PORT_CONS.stage_names) == 3

    def test_cons_port_has_three_stages(self):
        assert len(PERIOD_CONS_PORT.stage_names) == 3

    def test_cons_only_fixed_share(self):
        assert PERIOD_CONS_ONLY.bar_Shr == 0.0

    def test_port_cons_optimizes(self):
        assert PERIOD_PORT_CONS.bar_Shr is None


class TestTerminalSolution:
    """Terminal period: c_T(m) = m, v_T(m) = u(m)."""

    def test_consumption_equals_resources(self):
        params = ModelParams()
        term = make_terminal_solution(params)
        m = np.array([0.5, 1.0, 2.0, 5.0])
        c = term['terminal']['dcsn'].c(m)
        np.testing.assert_allclose(c, m)

    def test_value_is_utility(self):
        params = ModelParams(CRRA=2.0)
        term = make_terminal_solution(params)
        m = np.array([1.0, 2.0])
        v = term['terminal']['dcsn'].v(m)
        expected = m ** (1 - 2.0) / (1 - 2.0)
        np.testing.assert_allclose(v, expected, atol=1e-12)

    def test_marginal_value(self):
        params = ModelParams(CRRA=2.0)
        term = make_terminal_solution(params)
        m = np.array([1.0, 2.0])
        vδ = term['terminal']['dcsn'].vδ(m)
        expected = m ** (-2.0)
        np.testing.assert_allclose(vδ, expected, atol=1e-12)


@pytest.mark.slow
class TestSolveOnePeriod:
    """Solve one period backward from the terminal and check basic properties."""

    def _solve_one(self):
        params = ModelParams(sigma=0.1, n_shocks=5)
        term = make_terminal_solution(params)
        shock_dstn = make_shock_distribution(params)
        v_T = term['terminal']['dcsn'].v
        cδ_T = term['terminal']['dcsn'].cδ
        return solve_period(PERIOD_CONS_ONLY, v_T, cδ_T, params, shock_dstn)

    def test_cons_only_consumption_positive(self):
        sol = self._solve_one()
        c_func = sol['cons-noshocks']['dcsn'].c
        m_test = np.linspace(0.5, 10.0, 20)
        c_vals = c_func(m_test)
        assert np.all(c_vals > 0), "Consumption should be positive"
        assert np.all(c_vals < m_test + 0.1), "Consumption should not exceed resources (approximately)"

    def test_cons_only_consumption_monotone(self):
        sol = self._solve_one()
        c_func = sol['cons-noshocks']['dcsn'].c
        m_test = np.linspace(1.0, 10.0, 50)
        c_vals = c_func(m_test)
        assert np.all(np.diff(c_vals) >= -1e-8), "Consumption should be non-decreasing in m"
