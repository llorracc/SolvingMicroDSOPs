"""Unit tests for Code/Python/snippets/building_pile_backward.py."""

import pytest
from building_pile_backward import (
    u,
    make_pile_T,
    backward_mover_prd,
)


DISCFAC = 0.96
CRRA = 2.0
M_GRID = [0.1 + 0.35 * i for i in range(30)]


class TestMakePileT:
    def test_terminal_value_equals_utility(self):
        pile_T = make_pile_T(DISCFAC, CRRA)
        m = 2.0
        assert pile_T.vBegPrd(m) == u(m, CRRA)

    def test_terminal_consume_everything(self):
        pile_T = make_pile_T(DISCFAC, CRRA)
        m = 3.5
        assert pile_T.cFunc(m) == m


class TestBackwardMoverPrd:
    def test_pile_structure(self):
        pile_T = make_pile_T(DISCFAC, CRRA)
        Pile = [pile_T]

        pile_Tm1, connector = backward_mover_prd(
            Pile, pile_T, "T-1", DISCFAC, M_GRID, CRRA
        )
        assert Pile[0] is pile_Tm1
        assert Pile[1] is connector
        assert Pile[2] is pile_T
        assert len(Pile) == 3

    def test_Tm1_consumption_less_than_m(self):
        pile_T = make_pile_T(DISCFAC, CRRA)
        Pile = [pile_T]
        pile_Tm1, _ = backward_mover_prd(
            Pile, pile_T, "T-1", DISCFAC, M_GRID, CRRA
        )
        m = 2.0
        c = pile_Tm1.cFunc(m)
        assert 0 < c < m, f"Expected 0 < c < m, got c={c}, m={m}"

    def test_Tm1_value_is_finite(self):
        pile_T = make_pile_T(DISCFAC, CRRA)
        Pile = [pile_T]
        pile_Tm1, _ = backward_mover_prd(
            Pile, pile_T, "T-1", DISCFAC, M_GRID, CRRA
        )
        m = 2.0
        import math
        assert math.isfinite(pile_Tm1.vBegPrd(m))
        # Two-period value is the sum of two negative CRRA utilities,
        # so it should be more negative than the single-period value.
        assert pile_Tm1.vBegPrd(m) < pile_T.vBegPrd(m)
