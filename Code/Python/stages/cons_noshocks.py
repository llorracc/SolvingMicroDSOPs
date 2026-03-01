"""Shock-free consumption stage using the Endogenous Grid Method (EGM).

In the modular period architecture, cons-noshocks receives a continuation
value function v_cntn(a) that already has shocks (and possibly portfolio
returns) integrated out by a preceding stage.  This stage solves:

    v_dcsn(m) = max_c  u(c) + v_cntn(m - c)

using the EGM:
    1. c_cntn(a) = (v'_cntn(a))^{-1/rho}          (eq:consumedFn)
    2. m_endogenous = a + c_cntn(a)                 (EGM)
    3. Prepend borrowing constraint point {a_min, 0}
    4. Build interpolated c*(m), v_dcsn(m)
    5. v'_dcsn(m) = u'(c*(m))                       (envelope, eq:upcteqvtp)

Arrival state: m (m-type, post-shock)
Control:       c
Exit state:    a = m - c  (k-type)
"""

import numpy as np
from scipy.interpolate import InterpolatedUnivariateSpline

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from solution import ModelParams, Stage, v_to_vinv, vinv_to_v


STAGE_NAME = 'cons-noshocks'


def _make_interpolant(x, y):
    return InterpolatedUnivariateSpline(x, y, k=1)


def _utility(c, rho):
    if rho == 1.0:
        return np.log(np.maximum(c, 1e-300))
    return np.maximum(c, 1e-300) ** (1.0 - rho) / (1.0 - rho)


def _marginal_utility(c, rho):
    return np.maximum(c, 1e-300) ** (-rho)


def _inv_marginal_utility(mu, rho):
    return mu ** (-1.0 / rho)


def build_a_grid(a_min, a_max, n_points):
    """Multi-exponential grid from a_min to a_max.

    Delegates to setup_grids_expMult (20-nested exp, multi-exponential spacing)
    so that the modular solver uses the same grid as the EndOfPrdMC solver.
    """
    from resources import setup_grids_expMult
    return setup_grids_expMult(a_min, a_max, n_points)


def solve_cons_noshocks(v_cntn, cδ_cntn, params: ModelParams,
                        a_grid=None, a_min=None) -> Stage:
    """Solve the shock-free consumption stage via EGM.

    Parameters
    ----------
    v_cntn : callable
        Continuation value function v(a), from the next stage downstream.
    cδ_cntn : callable
        Consumed function (inverse marginal value) from the next stage
        downstream: cδ(a) = (v'(a))^{-1/rho}.  Nearly linear.
    params : ModelParams
    a_grid : ndarray, optional
        Assets grid.  Built automatically if not supplied.
    a_min : float, optional
        Natural borrowing constraint.  Defaults to 0.0.

    Returns
    -------
    Stage
        With arvl, dcsn, cntn perches populated.
    """
    rho = params.CRRA

    if a_min is None:
        a_min = 0.0
    if a_grid is None:
        a_grid = build_a_grid(a_min + 1e-10, params.a_max, params.a_grid_size)

    # --- Evaluate continuation on the a-grid ---
    v_cntn_vals = np.asarray(v_cntn(a_grid), dtype=float)
    # Inverse-utility transformation: interpolate vinv ≈ c (nearly linear)
    vinv_cntn_vals = v_to_vinv(v_cntn_vals, rho)
    vinv_cntn_interp = _make_interpolant(a_grid, vinv_cntn_vals)

    # --- EGM: evaluate the nearly-linear consumed function directly ---
    c_cntn = np.asarray(cδ_cntn(a_grid), dtype=float)
    m_endogenous = a_grid + c_cntn

    # Prepend natural borrowing constraint point
    m_endogenous = np.concatenate([[a_min], m_endogenous])
    c_endogenous = np.concatenate([[0.0], c_cntn])

    c_interp = _make_interpolant(m_endogenous, c_endogenous)

    def c_func(m):
        m = np.asarray(m, dtype=float)
        c = c_interp(m)
        return np.clip(c, 0.0, m)

    def v_func(m):
        m = np.asarray(m, dtype=float)
        c = c_func(m)
        a = m - c
        return _utility(c, rho) + vinv_to_v(vinv_cntn_interp(a), rho)

    def vδ_func(m):
        m = np.asarray(m, dtype=float)
        c = np.maximum(c_func(m), 1e-300)
        return c ** (-rho)

    # --- Assemble Stage ---
    stg = Stage(STAGE_NAME)

    stg['cntn'].v = v_cntn
    stg['cntn'].cδ = cδ_cntn

    stg['dcsn'].c = c_func
    stg['dcsn'].v = v_func
    stg['dcsn'].vδ = vδ_func
    stg['dcsn'].cδ = c_func           # c*(m) IS the consumed function

    stg['arvl'].c = c_func
    stg['arvl'].v = v_func
    stg['arvl'].vδ = vδ_func
    stg['arvl'].cδ = c_func

    return stg
