"""Modular top-level solvers: finite and infinite horizon backward induction.

These solvers use the modular period architecture from period_types.py,
composing reusable stages (disc, cons-noshocks, portable) into period
types and iterating the Bellman operator backward.

Functions
---------
solve_modular_finite(T, period_spec, params)
    Backward induction over T periods.

solve_modular_infinite(period_spec, params, tol, max_iter)
    Iterate the Bellman operator to convergence.
"""

import numpy as np
from scipy.optimize import brentq

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from solution import ModelParams, PeriodSolution
from period_types import (
    PeriodSpec, PERIOD_CONS_ONLY, PERIOD_PORT_CONS,
    make_terminal_solution, wrap_terminal_with_portable,
    solve_period, _get_dcsn_funcs,
)
from stages.portable import make_shock_distribution


# ---------------------------------------------------------------------------
# Finite-horizon solver
# ---------------------------------------------------------------------------

def solve_modular_finite(T: int,
                         period_spec: PeriodSpec = None,
                         params: ModelParams = None) -> dict:
    """Solve the consumption-savings problem over T periods using modular stages.

    Parameters
    ----------
    T : int
        Number of periods.  Terminal period has index T.
    period_spec : PeriodSpec, optional
        Defaults to PERIOD_CONS_ONLY.
    params : ModelParams, optional
        Defaults to ModelParams() (baseline calibration).

    Returns
    -------
    dict
        'solutions': dict mapping period index -> PeriodSolution
        'params': ModelParams
    """
    if params is None:
        params = ModelParams()
    if period_spec is None:
        period_spec = PERIOD_CONS_ONLY

    shock_dstn = make_shock_distribution(params)
    solutions = {}

    # Terminal period.  For period types whose entry stage is portable
    # (port-cons, cons-only, port-only), the preceding period's disc
    # needs the shock-integrated terminal value -> wrap with portable.
    # For cons-port (entry = cons-noshocks, state m), disc needs the
    # raw terminal v_T(m) = u(m) with no shock integration.
    raw_terminal = make_terminal_solution(params)
    if period_spec.stage_names[0] != 'cons-noshocks':
        terminal = wrap_terminal_with_portable(
            raw_terminal, period_spec, params, shock_dstn)
    else:
        terminal = raw_terminal
    solutions[T] = terminal

    # Backward induction
    for t in range(T - 1, -1, -1):
        nxt_sol = solutions[t + 1]
        v_nxt, cδ_nxt = _get_dcsn_funcs(nxt_sol)

        sol_t = solve_period(period_spec, v_nxt, cδ_nxt,
                             params, shock_dstn)
        solutions[t] = sol_t

    return {'solutions': solutions, 'params': params}


# ---------------------------------------------------------------------------
# Infinite-horizon solver
# ---------------------------------------------------------------------------

def _get_c_func(period_sol: PeriodSolution):
    """Extract consumption function from a period solution.

    Looks for a cons-noshocks stage first, then falls back to the first
    stage with a .c attribute on its dcsn perch.
    """
    if 'cons-noshocks' in period_sol.stg:
        return period_sol['cons-noshocks']['dcsn'].c

    for sname in period_sol.stg_order:
        dcsn = period_sol[sname]['dcsn']
        if hasattr(dcsn, 'c') and dcsn.c is not None:
            return dcsn.c

    return None


def _find_target_m(c_func, params):
    """Find target wealth m_hat where E[m'/m] = 1.  (eq:mTrgNrmet)"""
    RNrmByG = params.RNrmByG

    def residual(m):
        a = m - c_func(m)
        return RNrmByG * a + 1.0 - m

    try:
        return brentq(residual, 0.5, params.a_max)
    except ValueError:
        return np.nan


def solve_modular_infinite(period_spec: PeriodSpec = None,
                           params: ModelParams = None,
                           tol: float = None,
                           max_iter: int = None) -> dict:
    """Solve the stationary infinite-horizon problem using modular stages.

    Iterates the Bellman operator until the target wealth m_hat converges.

    Parameters
    ----------
    period_spec : PeriodSpec, optional
        Defaults to PERIOD_CONS_ONLY.
    params : ModelParams, optional
    tol : float, optional
    max_iter : int, optional

    Returns
    -------
    dict
        'solution': PeriodSolution (converged stationary solution)
        'solutions': {0: converged, 1: copy for next-period}
        'params': ModelParams
        'converged': bool
        'iterations': int
    """
    if params is None:
        params = ModelParams()
    if period_spec is None:
        period_spec = PERIOD_CONS_ONLY
    if tol is None:
        tol = params.tol
    if max_iter is None:
        max_iter = params.max_iter

    shock_dstn = make_shock_distribution(params)

    # Initial guess: terminal (consume everything).
    # Wrap with portable only for period types whose entry is portable.
    raw_terminal = make_terminal_solution(params)
    if period_spec.stage_names[0] != 'cons-noshocks':
        nxt_sol = wrap_terminal_with_portable(
            raw_terminal, period_spec, params, shock_dstn)
    else:
        nxt_sol = raw_terminal

    m_hat_prev = np.nan
    converged = False

    for k in range(max_iter):
        v_nxt, cδ_nxt = _get_dcsn_funcs(nxt_sol)
        sol_new = solve_period(period_spec, v_nxt, cδ_nxt,
                               params, shock_dstn)

        c_func = _get_c_func(sol_new)
        if c_func is not None:
            m_hat = _find_target_m(c_func, params)
        else:
            m_hat = np.nan

        if np.isfinite(m_hat) and np.isfinite(m_hat_prev):
            if abs(m_hat - m_hat_prev) < tol:
                converged = True
                break

        m_hat_prev = m_hat
        nxt_sol = sol_new

    return {
        'solution': sol_new,
        'solutions': {0: sol_new, 1: sol_new},
        'params': params,
        'converged': converged,
        'iterations': k + 1,
    }


# ---------------------------------------------------------------------------
# Quick demo when run directly
# ---------------------------------------------------------------------------

if __name__ == '__main__':
    params = ModelParams()

    print("=== Modular finite-horizon (T=50, cons-only) ===")
    result = solve_modular_finite(50, PERIOD_CONS_ONLY, params)
    sol0 = result['solutions'][0]
    c_func = _get_c_func(sol0)
    m_test = np.array([1.0, 2.0, 3.0, 5.0, 10.0])
    if c_func is not None:
        print(f"  c*(m) at t=0: {[f'{c_func(m):.4f}' for m in m_test]}")

    print("\n=== Modular infinite-horizon (cons-only) ===")
    result_inf = solve_modular_infinite(PERIOD_CONS_ONLY, params)
    sol_inf = result_inf['solution']
    c_inf = _get_c_func(sol_inf)
    if c_inf is not None:
        print(f"  c_inf(m) : {[f'{c_inf(m):.4f}' for m in m_test]}")
        m_hat = _find_target_m(c_inf, params)
        print(f"  Target m_hat = {m_hat:.6f}")
    print(f"  Converged: {result_inf['converged']} in {result_inf['iterations']} iterations")

    print("\n=== Modular finite-horizon (T=10, port-cons with portfolio opt) ===")
    result_pc = solve_modular_finite(10, PERIOD_PORT_CONS, params)
    sol_pc = result_pc['solutions'][0]
    c_pc = _get_c_func(sol_pc)
    if c_pc is not None:
        print(f"  c*(m) at t=0: {[f'{c_pc(m):.4f}' for m in m_test]}")
    if 'portable' in sol_pc.stg:
        Shr = sol_pc['portable']['dcsn'].Shr
        k_test = np.array([1.0, 2.0, 5.0, 10.0])
        print(f"  Shr*(k) at t=0: {[f'{Shr(k):.4f}' for k in k_test]}")
