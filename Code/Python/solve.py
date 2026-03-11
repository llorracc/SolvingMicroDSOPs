"""Top-level solvers: finite-horizon and infinite-horizon backward induction.

This module orchestrates the backward-induction loop that builds the Pile
by repeatedly calling the stage solver (BkBldrPrd) from
stages/cons_with_shocks.py.

Functions
---------
make_connector(params)
    Build a Connector with discretized shocks for the given parameters.

solve_finite_horizon(T, params=None)
    Backward induction over T periods.  Returns a Pile.

solve_infinite_horizon(params=None, tol=None, max_iter=None)
    Iterate the Bellman operator to convergence.  Returns a Pile.
"""

import numpy as np

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from solution import ModelParams, Connector, Pile
from stages.cons_with_shocks import (
    STAGE_NAME, make_terminal_solution, solve_one_period,
)


def make_connector(params: ModelParams) -> Connector:
    """Build a Connector with equiprobable discrete shock approximation.

    Uses DiscreteApproximationToMeanOneLogNormal from resources.py.
    """
    from resources import DiscreteApproximationToMeanOneLogNormal

    dstn = DiscreteApproximationToMeanOneLogNormal(
        N=params.n_shocks, sigma=params.sigma,
    )
    return Connector(
        params=params,
        shock_nodes=dstn.X,
        shock_weights=dstn.pmf,
    )


# ---------------------------------------------------------------------------
# Finite-horizon solver
# ---------------------------------------------------------------------------

def solve_finite_horizon(T: int, params: ModelParams = None) -> Pile:
    """Solve the consumption-savings problem over T periods.

    Period T is terminal: v_T(m) = u(m), c_T(m) = m.     (eq:levelTm1)
    For t = T-1, ..., 0: apply BkBldrPrd.

    Parameters
    ----------
    T : int
        Number of periods.  Terminal period has index T.
    params : ModelParams, optional
        Defaults to ModelParams() (baseline calibration).

    Returns
    -------
    Pile
        Contains PeriodSolution for t = 0, 1, ..., T.
    """
    if params is None:
        params = ModelParams()

    connector = make_connector(params)
    pile = Pile(params, connector)

    # Terminal period
    pile.add(T, make_terminal_solution(params))

    # Backward induction
    for t in range(T - 1, -1, -1):
        sol_t = solve_one_period(pile, t)
        pile.add(t, sol_t)

    return pile


# ---------------------------------------------------------------------------
# Infinite-horizon solver
# ---------------------------------------------------------------------------

def _find_target_m(c_func, params):
    """Find target wealth m_hat where E[m'/m] = 1.  (eq:mTrgNrmet)

    At steady state: (R/Gamma)*(m_hat - c*(m_hat)) + 1 = m_hat.
    """
    from scipy.optimize import brentq

    RNrmByG = params.RNrmByG

    def residual(m):
        a = m - c_func(m)
        return RNrmByG * a + 1.0 - m

    try:
        return brentq(residual, 0.5, params.a_max)
    except ValueError:
        return np.nan


def solve_infinite_horizon(
    params: ModelParams = None,
    tol: float = None,
    max_iter: int = None,
) -> Pile:
    """Solve the stationary infinite-horizon problem.

    Iterates the Bellman operator (via BkBldrPrd) until the target
    wealth m_hat converges: |m_hat_{k} - m_hat_{k-1}| < tol.

    Parameters
    ----------
    params : ModelParams, optional
    tol : float, optional
        Convergence tolerance.  Defaults to params.tol.
    max_iter : int, optional
        Maximum iterations.  Defaults to params.max_iter.

    Returns
    -------
    Pile
        Contains the converged stationary solution at index 0,
        with the "next-period" copy at index 1.
    """
    if params is None:
        params = ModelParams()
    if tol is None:
        tol = params.tol
    if max_iter is None:
        max_iter = params.max_iter

    connector = make_connector(params)
    pile = Pile(params, connector)

    # Initial guess: terminal (consume everything)
    pile.add(1, make_terminal_solution(params))

    m_hat_prev = np.nan

    for k in range(max_iter):
        sol_new = solve_one_period(pile, 0)
        c_func = sol_new[STAGE_NAME]['dcsn'].c

        m_hat = _find_target_m(c_func, params)

        # Shift: new solution becomes "next period"
        pile.add(1, sol_new)

        if np.isfinite(m_hat) and np.isfinite(m_hat_prev):
            if abs(m_hat - m_hat_prev) < tol:
                pile.add(0, sol_new)
                return pile

        m_hat_prev = m_hat

    pile.add(0, sol_new)
    return pile


# ---------------------------------------------------------------------------
# Quick demo when run directly
# ---------------------------------------------------------------------------

if __name__ == '__main__':
    print("Solving finite-horizon (T=50) ...")
    params = ModelParams()
    pile = solve_finite_horizon(50, params)
    print(f"  Pile has {len(pile)} periods: {pile.periods()[:5]} ... {pile.periods()[-3:]}")

    c5 = pile[0][STAGE_NAME]['dcsn'].c
    m_test = np.array([1.0, 2.0, 3.0, 5.0, 10.0])
    print(f"  c*(m) at t=0: {[f'{c5(m):.4f}' for m in m_test]}")

    print("\nSolving infinite-horizon ...")
    pile_inf = solve_infinite_horizon(params)
    c_inf = pile_inf[0][STAGE_NAME]['dcsn'].c
    print(f"  c_inf(m) : {[f'{c_inf(m):.4f}' for m in m_test]}")

    m_hat = _find_target_m(c_inf, params)
    print(f"  Target m_hat = {m_hat:.6f}")
