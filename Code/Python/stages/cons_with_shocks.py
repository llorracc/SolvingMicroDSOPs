"""EGM solver for the cons-with-shocks stage.

This module implements the combined consumption stage with transitory
income shocks, corresponding to the FOC-based approach in SolvingMicroDSOPs.

The stage has three perches:
    arvl  (arrival):      state k (k-type), v_arvl = E_arvl[v_dcsn]
    dcsn  (decision):     state m (m-type), v_dcsn = max_c u(c) + v_cntn
    cntn  (continuation): state a (k-type), v_cntn

The EGM algorithm:
    1. Compute marginal continuation value v'_cntn(a) on a-grid   (eq:vEndδTm1)
    2. Invert Euler: c_cntn(a) = (v'_cntn(a))^{-1/rho}           (eq:cGoth)
    3. Endogenous grid: m = a + c_cntn(a)                         (EGM)
    4. Prepend natural borrowing constraint: {a_min, 0}
    5. Build interpolated c*(m) and v_dcsn(m)
    6. Envelope: v'_dcsn(m) = c*(m)^{-rho}                        (eq:upcteqvtp)
"""

import numpy as np
from scipy.interpolate import interp1d

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from solution import (
    ModelParams, Connector, Perch, Stage, PeriodSolution, Pile,
)


STAGE_NAME = 'cons-with-shocks'


def _make_interpolant(x, y, kind='linear'):
    """Build a piecewise interpolant with extrapolation."""
    return interp1d(x, y, kind=kind, fill_value='extrapolate',
                    bounds_error=False, assume_sorted=True)


def _utility(c, rho):
    """CRRA utility u(c) = c^{1-rho}/(1-rho)."""
    if rho == 1.0:
        return np.log(np.maximum(c, 1e-300))
    return np.maximum(c, 1e-300) ** (1.0 - rho) / (1.0 - rho)


def _marginal_utility(c, rho):
    """Marginal CRRA utility u'(c) = c^{-rho}."""
    return np.maximum(c, 1e-300) ** (-rho)


def _inv_marginal_utility(mu, rho):
    """Inverse marginal utility: mu^{-1/rho}. (eq:cGoth)"""
    return mu ** (-1.0 / rho)


# ---------------------------------------------------------------------------
# Grid construction
# ---------------------------------------------------------------------------

def build_a_grid(a_min, a_max, n_points, n_nest=3):
    """Multi-exponential grid from a_min to a_max.

    Mirrors resources.get_improved_grid but accepts a_min directly.
    Dense near a_min, sparse at upper end.  (multi-exponential spacing)
    """
    from numpy import log, exp
    span = a_max - a_min
    g_min = 0.01 * span
    g_max = 10.0 * span

    log3_max = log(1 + log(1 + log(1 + g_max)))
    log3_min = log(1 + log(1 + log(1 + g_min)))
    step = (log3_max - log3_min) / n_points

    pts = []
    p = 0.0
    while p < log3_max:
        p += step
        pts.append(p)

    raw = exp(exp(exp(np.array(pts)) - 1) - 1) - 1
    return a_min + raw[:n_points]


# ---------------------------------------------------------------------------
# Terminal period
# ---------------------------------------------------------------------------

def make_terminal_solution(params: ModelParams) -> PeriodSolution:
    """Create the terminal-period solution: v_T(m) = u(m), c_T(m) = m.

    At the terminal period there is no continuation, so the agent
    consumes everything.
    """
    rho = params.CRRA

    def c_terminal(m):
        m = np.asarray(m, dtype=float)
        return m.copy()

    def v_terminal(m):
        m = np.asarray(m, dtype=float)
        return _utility(m, rho)

    def vδ_terminal(m):
        m = np.asarray(m, dtype=float)
        return _marginal_utility(m, rho)

    sol = PeriodSolution(name='T')
    stg = sol.add_stage(STAGE_NAME)

    stg['dcsn'].c = c_terminal
    stg['dcsn'].v = v_terminal
    stg['dcsn'].vδ = vδ_terminal

    stg['arvl'].c = c_terminal
    stg['arvl'].v = v_terminal
    stg['arvl'].vδ = vδ_terminal

    return sol


# ---------------------------------------------------------------------------
# One backward step  (BkBldrPrd)
# ---------------------------------------------------------------------------

def solve_one_period(pile: Pile, t: int) -> PeriodSolution:
    """Solve period t given that period t+1 is already in the Pile.

    This is BkBldrPrd in the SMD notation.

    Steps:
        1. Continuation perch: integrate next-period values     (eq:vCntnExpansion)
        2. EGM inversion: c_cntn(a) = (v'_cntn(a))^{-1/rho}   (eq:cGoth)
        3. Endogenous grid: m = a + c                           (EGM)
        4. Build interpolated c*(m), v_dcsn(m), v'_dcsn(m)
    """
    params = pile.params
    connector = pile.connector
    rho = params.CRRA

    # Retrieve next-period decision-perch functions
    nxt_sol = pile[t + 1]
    nxt_dcsn = nxt_sol[STAGE_NAME]['dcsn']
    v_dcsn_nxt = nxt_dcsn.v
    vδ_dcsn_nxt = nxt_dcsn.vδ

    # --- Grid construction ------------------------------------------------
    a_min = connector.natural_borrowing_constraint()
    a_grid = build_a_grid(a_min + 1e-10, params.a_max, params.a_grid_size)

    # --- Step 1: Continuation perch values on a-grid ----------------------
    # v_cntn(a) = beta * Gamma^{1-rho} * sum w_i * v_dcsn_{t+1}(m'_i)
    v_cntn_vals = connector.continuation_value(v_dcsn_nxt, a_grid)
    # v'_cntn(a) = beta * R * Gamma^{-rho} * sum w_i * v'_dcsn_{t+1}(m'_i)
    vδ_cntn_vals = connector.marginal_continuation_value(vδ_dcsn_nxt, a_grid)

    v_cntn_interp = _make_interpolant(a_grid, v_cntn_vals)
    vδ_cntn_interp = _make_interpolant(a_grid, vδ_cntn_vals)

    # --- Step 2: Inverse Euler (EGM) -------------------------------------
    # c_cntn(a) = (v'_cntn(a))^{-1/rho}                       (eq:cGoth)
    c_cntn = _inv_marginal_utility(vδ_cntn_vals, rho)

    # --- Step 3: Endogenous m grid ----------------------------------------
    m_endogenous = a_grid + c_cntn                              # EGM

    # Prepend natural borrowing constraint point {a_min, 0}
    m_endogenous = np.concatenate([[a_min], m_endogenous])
    c_endogenous = np.concatenate([[0.0], c_cntn])

    # --- Step 4: Build interpolated consumption function -------------------
    c_interp = _make_interpolant(m_endogenous, c_endogenous)

    def c_func(m):
        m = np.asarray(m, dtype=float)
        c = c_interp(m)
        return np.clip(c, 0.0, m)

    def v_func(m):
        m = np.asarray(m, dtype=float)
        c = c_func(m)
        a = m - c
        return _utility(c, rho) + v_cntn_interp(a)

    def vδ_func(m):
        """v'_dcsn(m) = u'(c*(m)) = c*(m)^{-rho}  (envelope, eq:upcteqvtp)"""
        m = np.asarray(m, dtype=float)
        c = np.maximum(c_func(m), 1e-300)
        return _marginal_utility(c, rho)

    # --- Assemble PeriodSolution ------------------------------------------
    sol = PeriodSolution(name=str(t))
    stg = sol.add_stage(STAGE_NAME)

    stg['cntn'].v = v_cntn_interp
    stg['cntn'].vδ = vδ_cntn_interp

    stg['dcsn'].c = c_func
    stg['dcsn'].v = v_func
    stg['dcsn'].vδ = vδ_func

    # In the single-stage model, arvl == dcsn (no pre-decision shocks
    # within the stage beyond those already folded into v_cntn).
    stg['arvl'].c = c_func
    stg['arvl'].v = v_func
    stg['arvl'].vδ = vδ_func

    return sol
