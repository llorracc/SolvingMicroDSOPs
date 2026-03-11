"""Tests for the modular solver (solution.py, stages/cons_with_shocks.py, solve.py).

Tests verify:
    1. Container classes (ModelParams, Perch, Stage, PeriodSolution, Connector, Pile)
    2. Terminal period solution
    3. One backward step (EGM at T-1)
    4. Finite-horizon properties (monotonicity, concavity, convergence)
    5. Infinite-horizon convergence
    6. Cross-validation against the legacy EndOfPrd code
"""

import math
import pytest
import numpy as np

from solution import ModelParams, Connector, Perch, Stage, PeriodSolution, Pile
from stages.cons_with_shocks import (
    STAGE_NAME, make_terminal_solution, solve_one_period,
    _utility, _marginal_utility, _inv_marginal_utility, build_a_grid,
)
from solve import make_connector, solve_finite_horizon, solve_infinite_horizon


# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------

@pytest.fixture
def params():
    return ModelParams()


@pytest.fixture
def connector(params):
    return make_connector(params)


@pytest.fixture
def pile_T(params, connector):
    """A Pile containing only the terminal period."""
    pile = Pile(params, connector)
    pile.add(1, make_terminal_solution(params))
    return pile


# ---------------------------------------------------------------------------
# 1. Container class tests
# ---------------------------------------------------------------------------

class TestModelParams:
    def test_defaults(self, params):
        assert params.DiscFac == 0.96
        assert params.CRRA == 2.0
        assert params.Rfree == 1.03

    def test_RNrmByG(self, params):
        assert abs(params.RNrmByG - 1.03) < 1e-10

    def test_frozen(self, params):
        with pytest.raises(AttributeError):
            params.DiscFac = 0.99


class TestContainers:
    def test_perch_creation(self):
        p = Perch('dcsn')
        assert p.name == 'dcsn'

    def test_stage_bracket(self):
        s = Stage('cons')
        assert s['arvl'].name == 'arvl'
        assert s['dcsn'].name == 'dcsn'
        assert s['cntn'].name == 'cntn'

    def test_period_solution_add_stage(self):
        sol = PeriodSolution('T')
        stg = sol.add_stage('cons')
        assert 'cons' in sol.stg
        assert sol['cons'] is stg


class TestConnector:
    def test_natural_borrowing_constraint(self, connector):
        a_min = connector.natural_borrowing_constraint()
        assert a_min < 0
        assert np.isfinite(a_min)

    def test_m_nxt_shape(self, connector, params):
        a = np.array([0.0, 1.0, 2.0])
        m = connector.m_nxt(a)
        assert m.shape == (3, params.n_shocks)

    def test_m_nxt_increasing_in_a(self, connector):
        a = np.array([0.5, 1.0, 2.0])
        m = connector.m_nxt(a)
        assert np.all(np.diff(m, axis=0) > 0)


class TestPile:
    def test_add_and_retrieve(self, params, connector):
        pile = Pile(params, connector)
        sol = PeriodSolution('test')
        pile.add(5, sol)
        assert pile[5] is sol
        assert 5 in pile
        assert len(pile) == 1


# ---------------------------------------------------------------------------
# 2. Terminal period
# ---------------------------------------------------------------------------

class TestTerminalPeriod:
    def test_c_equals_m(self, params):
        sol = make_terminal_solution(params)
        m = np.array([0.5, 1.0, 2.0, 5.0])
        c = sol[STAGE_NAME]['dcsn'].c(m)
        np.testing.assert_allclose(c, m)

    def test_v_equals_utility(self, params):
        sol = make_terminal_solution(params)
        m = np.array([1.0, 2.0, 3.0])
        v = sol[STAGE_NAME]['dcsn'].v(m)
        expected = _utility(m, params.CRRA)
        np.testing.assert_allclose(v, expected)

    def test_vδ_equals_marginal_utility(self, params):
        sol = make_terminal_solution(params)
        m = np.array([1.0, 2.0, 3.0])
        vδ = sol[STAGE_NAME]['dcsn'].vδ(m)
        expected = _marginal_utility(m, params.CRRA)
        np.testing.assert_allclose(vδ, expected)


# ---------------------------------------------------------------------------
# 3. One backward step (T-1)
# ---------------------------------------------------------------------------

class TestOneBackwardStep:
    def test_sol_has_all_perches(self, pile_T):
        sol = solve_one_period(pile_T, 0)
        for perch_name in ['arvl', 'dcsn', 'cntn']:
            assert perch_name in sol[STAGE_NAME].prch

    def test_consumption_positive(self, pile_T):
        sol = solve_one_period(pile_T, 0)
        m = np.array([0.5, 1.0, 2.0, 5.0])
        c = np.array([sol[STAGE_NAME]['dcsn'].c(mi) for mi in m])
        assert np.all(c > 0)

    def test_consumption_less_than_m(self, pile_T):
        sol = solve_one_period(pile_T, 0)
        m = np.array([0.5, 1.0, 2.0, 5.0])
        c = np.array([sol[STAGE_NAME]['dcsn'].c(mi) for mi in m])
        assert np.all(c <= m + 1e-10)

    def test_consumption_monotone_increasing(self, pile_T):
        sol = solve_one_period(pile_T, 0)
        m = np.linspace(0.5, 10.0, 100)
        c = np.array([sol[STAGE_NAME]['dcsn'].c(mi) for mi in m])
        assert np.all(np.diff(c) >= -1e-10)

    def test_marginal_value_positive(self, pile_T):
        sol = solve_one_period(pile_T, 0)
        m = np.array([1.0, 2.0, 5.0])
        vδ = np.array([sol[STAGE_NAME]['dcsn'].vδ(mi) for mi in m])
        assert np.all(vδ > 0)


# ---------------------------------------------------------------------------
# 4. Finite-horizon properties
# ---------------------------------------------------------------------------

class TestFiniteHorizon:
    def test_pile_length(self, params):
        T = 10
        pile = solve_finite_horizon(T, params)
        assert len(pile) == T + 1

    def test_consumption_functions_converge(self, params):
        """Distant-from-T consumption functions should be nearly identical."""
        T = 50
        pile = solve_finite_horizon(T, params)
        m_test = 3.0
        c_0 = pile[0][STAGE_NAME]['dcsn'].c(m_test)
        c_5 = pile[5][STAGE_NAME]['dcsn'].c(m_test)
        c_Tm5 = pile[T - 5][STAGE_NAME]['dcsn'].c(m_test)
        c_Tm1 = pile[T - 1][STAGE_NAME]['dcsn'].c(m_test)
        assert abs(c_0 - c_5) < abs(c_Tm5 - c_Tm1)

    def test_consume_less_at_earlier_periods(self, params):
        """With precautionary saving, earlier periods consume less at same m."""
        T = 20
        pile = solve_finite_horizon(T, params)
        m_test = 3.0
        c_early = pile[0][STAGE_NAME]['dcsn'].c(m_test)
        c_late = pile[T - 1][STAGE_NAME]['dcsn'].c(m_test)
        assert c_early < c_late


# ---------------------------------------------------------------------------
# 5. Infinite-horizon convergence
# ---------------------------------------------------------------------------

class TestInfiniteHorizon:
    def test_converges(self, params):
        pile = solve_infinite_horizon(params, tol=1e-6, max_iter=500)
        assert 0 in pile

    def test_consumption_positive_and_less_than_m(self, params):
        pile = solve_infinite_horizon(params, tol=1e-6, max_iter=500)
        c_func = pile[0][STAGE_NAME]['dcsn'].c
        m = np.array([0.5, 1.0, 2.0, 5.0, 10.0])
        c = np.array([c_func(mi) for mi in m])
        assert np.all(c > 0)
        assert np.all(c < m + 1e-10)

    def test_target_m_reasonable(self, params):
        pile = solve_infinite_horizon(params, tol=1e-6, max_iter=500)
        c_func = pile[0][STAGE_NAME]['dcsn'].c
        from solve import _find_target_m
        m_hat = _find_target_m(c_func, params)
        assert 0.5 < m_hat < 10.0


# ---------------------------------------------------------------------------
# 6. Cross-validation against legacy EndOfPrd
# ---------------------------------------------------------------------------

class TestCrossValidation:
    def test_cCntn_Tm1_matches_legacy(self, params, connector):
        """The consumed function at T-1 should match the legacy EndOfPrd.cCntn_Tm1."""
        from resources import Utility, DiscreteApproximationToMeanOneLogNormal
        from endOfPrd import EndOfPrd

        uFunc = Utility(params.CRRA)
        dstn = DiscreteApproximationToMeanOneLogNormal(params.n_shocks, params.sigma)
        PermGroFac_vec = np.array([params.PermGroFac, params.PermGroFac])

        eop = EndOfPrd(uFunc, params.DiscFac, params.CRRA, PermGroFac_vec,
                       params.Rfree, dstn)

        pile = Pile(params, connector)
        pile.add(1, make_terminal_solution(params))
        sol = solve_one_period(pile, 0)

        a_test = np.array([0.5, 1.0, 2.0, 3.0])
        legacy_c = np.array([eop.cCntn_Tm1(a) for a in a_test])
        new_vδ = sol[STAGE_NAME]['cntn'].vδ
        new_c = _inv_marginal_utility(np.array([new_vδ(a) for a in a_test]),
                                      params.CRRA)

        np.testing.assert_allclose(new_c, legacy_c, rtol=0.05,
                                   err_msg="Consumed function at T-1 diverges from legacy")
