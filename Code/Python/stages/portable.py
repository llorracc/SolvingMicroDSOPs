"""Portable stage: returns-and-shocks with optional portfolio optimization.

The portable stage handles:
  1. Portfolio return computation: Rport(Shr) = Rfree + (Risky - Rfree)*Shr  (eq:Rport)
  2. Shock integration over transitory income shocks theta
  3. Optional portfolio share optimization:  Shr*(k) = argmax E[v_cntn(mCheck)]  (eq:shrDecision)

Three operating modes determined by bar_Shr:
  - bar_Shr = 0.0  : shocks-only (no risky asset, Rport = Rfree)
                      Reduces to the current Connector.continuation_value logic.
  - bar_Shr = float : fixed portfolio share
  - bar_Shr = None  : optimize Shr at each k in the grid

Entry state: k (k-type, beginning-of-period capital)
Exit state:  mCheck (m-type, after returns and shocks)
"""

import numpy as np
from scipy.interpolate import InterpolatedUnivariateSpline, PchipInterpolator

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from solution import ModelParams, Stage, v_to_vinv, vinv_to_v


STAGE_NAME = 'portable'


def _make_interpolant(x, y):
    return InterpolatedUnivariateSpline(x, y, k=1)



def make_shock_distribution(params: ModelParams):
    """Build the joint (theta, risky-return) shock distribution.

    Uses the same parameterization as the EndOfPrdMC solver:
    sigma_risky is the std of the *level* of risky returns (not log-space).

    Returns
    -------
    dict with keys:
        theta_nodes, theta_weights : transitory income shocks
        risky_nodes, risky_weights : risky return factor realizations
    """
    from resources import DiscreteApproximationTwoIndependentDistribs
    import scipy.stats as stats

    theta_mu = -0.5 * params.sigma ** 2
    theta_z = stats.lognorm(s=params.sigma, scale=np.exp(theta_mu))

    risky_mean = params.Rfree + params.equity_premium
    mu_log = np.log(risky_mean**2 / np.sqrt(params.sigma_risky**2 + risky_mean**2))
    sigma_log = np.sqrt(np.log(params.sigma_risky**2 / risky_mean**2 + 1))
    risky_z = stats.lognorm(s=sigma_log, scale=np.exp(mu_log))

    dstn = DiscreteApproximationTwoIndependentDistribs(
        params.n_shocks, theta_z.cdf, theta_z.pdf, theta_z.ppf,
        params.n_risky, risky_z.cdf, risky_z.pdf, risky_z.ppf,
    )

    return dict(
        theta_nodes=dstn.X1,
        theta_weights=np.full(params.n_shocks, 1.0 / params.n_shocks),
        risky_nodes=dstn.X2,
        risky_weights=np.full(params.n_risky, 1.0 / params.n_risky),
    )


def _compute_mCheck(k, Rport, theta_nodes, PermGroFac):
    """mCheck_{ij} = (Rport_j / Gamma) * k + theta_i.

    Parameters
    ----------
    k : float or ndarray shape (K,)
    Rport : ndarray shape (J,)   -- portfolio return for each risky-return state
    theta_nodes : ndarray shape (I,)
    PermGroFac : float

    Returns
    -------
    mCheck : ndarray shape (K, J, I) or (J, I) if k is scalar
    """
    k = np.atleast_1d(k)
    Rport_over_G = Rport / PermGroFac
    # (K, J)
    Rk = k[:, None] * Rport_over_G[None, :]
    # (K, J, I)
    mCheck = Rk[:, :, None] + theta_nodes[None, None, :]
    return mCheck


def solve_portable(v_cntn, cδ_cntn, params: ModelParams,
                   shock_dstn, k_grid, bar_Shr=None) -> Stage:
    """Solve the portable (returns+shocks) stage.

    Parameters
    ----------
    v_cntn : callable
        Continuation value v(mCheck) from the next stage downstream.
    cδ_cntn : callable
        Consumed function (inverse marginal value) from the next stage
        downstream: cδ(mCheck) = (v'(mCheck))^{-1/rho}.  Nearly linear.
    params : ModelParams
    shock_dstn : dict
        From make_shock_distribution().
    k_grid : ndarray
        Grid of beginning-of-period capital values.
    bar_Shr : float or None
        Fixed portfolio share, or None to optimize.
        When 0.0, the stage reduces to shocks-only (Rport = Rfree).

    Returns
    -------
    Stage
        With arvl, dcsn, cntn perches populated.
        arvl has .v, .vδ, .cδ, and (if optimized) .Shr function of k.
    """
    theta_nodes = shock_dstn['theta_nodes']
    theta_weights = shock_dstn['theta_weights']
    risky_nodes = shock_dstn['risky_nodes']
    risky_weights = shock_dstn['risky_weights']

    G = params.PermGroFac
    Rfree = params.Rfree
    rho = params.CRRA

    n_k = len(k_grid)

    if bar_Shr is not None:
        v_arvl_vals, vδ_arvl_vals = _eval_fixed_share(
            k_grid, bar_Shr, v_cntn, cδ_cntn, params, shock_dstn)
        Shr_vals = np.full(n_k, bar_Shr)
    else:
        v_arvl_vals = np.empty(n_k)
        vδ_arvl_vals = np.empty(n_k)
        Shr_vals = np.empty(n_k)

        for i, k_val in enumerate(k_grid):
            if k_val < 1e-12:
                v_arvl_vals[i] = v_cntn(np.atleast_1d(theta_nodes[0]))[0]
                cδ_at_theta0 = cδ_cntn(np.atleast_1d(theta_nodes[0]))[0]
                vδ_arvl_vals[i] = cδ_at_theta0 ** (-rho)
                Shr_vals[i] = 0.0
                continue

            shr_opt, v_opt = _optimize_share_at_k(
                k_val, v_cntn, cδ_cntn, params, shock_dstn)

            Shr_vals[i] = shr_opt
            v_arvl_vals[i] = v_opt

            Rport = Rfree + (risky_nodes - Rfree) * shr_opt
            Rport_over_G = Rport / G
            mCheck_ji = _compute_mCheck(
                np.atleast_1d(k_val), Rport, theta_nodes, G)[0]
            # Evaluate the nearly-linear consumed function, then re-exponentiate
            cδ_flat = cδ_cntn(mCheck_ji.ravel()).reshape(mCheck_ji.shape)
            vδ_flat = cδ_flat ** (-rho)
            vδ_inner = vδ_flat @ theta_weights
            vδ_arvl_vals[i] = (Rport_over_G * vδ_inner) @ risky_weights

    # Transform to consumed function before interpolation (eq:cδShrArvl)
    cδ_arvl_vals = vδ_arvl_vals ** (-1.0 / rho)
    cδ_arvl_interp = _make_interpolant(k_grid, cδ_arvl_vals)

    # Inverse-utility transformation for the value function:
    # vinv(v) = ((1-rho)*v)^{1/(1-rho)} ≈ c, nearly linear.
    vinv_arvl_vals = v_to_vinv(v_arvl_vals, rho)
    vinv_arvl_interp = _make_interpolant(k_grid, vinv_arvl_vals)

    Shr_interp = PchipInterpolator(k_grid, Shr_vals, extrapolate=True)

    def v_arvl_func(k):
        return vinv_to_v(vinv_arvl_interp(np.asarray(k, dtype=float)), rho)

    def cδ_arvl_func(k):
        return cδ_arvl_interp(np.asarray(k, dtype=float))

    def vδ_arvl_func(k):
        return cδ_arvl_func(k) ** (-rho)

    def Shr_func(k):
        return np.clip(Shr_interp(np.asarray(k, dtype=float)), 0.0, 1.0)

    stg = Stage(STAGE_NAME)
    stg['cntn'].v = v_cntn
    stg['cntn'].cδ = cδ_cntn
    stg['dcsn'].v = v_arvl_func
    stg['dcsn'].vδ = vδ_arvl_func
    stg['dcsn'].cδ = cδ_arvl_func
    stg['dcsn'].Shr = Shr_func
    stg['arvl'].v = v_arvl_func
    stg['arvl'].vδ = vδ_arvl_func
    stg['arvl'].cδ = cδ_arvl_func
    stg['arvl'].Shr = Shr_func

    return stg


def _eval_fixed_share(k_grid, Shr, v_cntn, cδ_cntn, params, shock_dstn):
    """Evaluate v and v' at each k for a fixed portfolio share."""
    theta_nodes = shock_dstn['theta_nodes']
    theta_weights = shock_dstn['theta_weights']
    risky_nodes = shock_dstn['risky_nodes']
    risky_weights = shock_dstn['risky_weights']

    G = params.PermGroFac
    Rfree = params.Rfree
    rho = params.CRRA

    Rport = Rfree + (risky_nodes - Rfree) * Shr  # (J,)
    Rport_over_G = Rport / G

    # mCheck: (K, J, I)
    mCheck = _compute_mCheck(k_grid, Rport, theta_nodes, G)
    K, J, I = mCheck.shape

    v_flat = v_cntn(mCheck.ravel()).reshape(K, J, I)
    # Evaluate the nearly-linear consumed function, then re-exponentiate
    cδ_flat = cδ_cntn(mCheck.ravel()).reshape(K, J, I)
    vδ_flat = cδ_flat ** (-rho)

    # Double expectation: E_j[ E_i[ ... ] ]
    v_inner = v_flat @ theta_weights         # (K, J)
    vδ_inner = vδ_flat @ theta_weights     # (K, J)

    v_arvl = v_inner @ risky_weights         # (K,)

    # Marginal value includes Rport/G factor
    vδ_arvl = (vδ_inner * Rport_over_G[None, :]) @ risky_weights  # (K,)

    return v_arvl, vδ_arvl


def _optimize_share_at_k(k, v_cntn, cδ_cntn, params, shock_dstn):
    """Find optimal portfolio share at a single k value.

    Uses the FOC (eq:FOCport):
        0 = E[(R̃ - R) · v'_cntn(m̌)]
          = E[(R̃ - R) · cδ_cntn(m̌)^{-ρ}]

    where cδ_cntn is the nearly-linear consumed function.
    Falls back to bounded optimization only if root-finding fails.
    """
    theta_nodes = shock_dstn['theta_nodes']
    theta_weights = shock_dstn['theta_weights']
    risky_nodes = shock_dstn['risky_nodes']
    risky_weights = shock_dstn['risky_weights']
    G = params.PermGroFac
    Rfree = params.Rfree
    rho = params.CRRA

    excess_R = risky_nodes - Rfree  # (J,)

    def foc_residual(Shr):
        """FOC: E[(R̃ - R) · cδ_cntn(m̌)^{-ρ}] = 0."""
        Rport = Rfree + excess_R * Shr
        mCheck = _compute_mCheck(np.atleast_1d(k), Rport, theta_nodes, G)[0]
        cδ_flat = cδ_cntn(mCheck.ravel()).reshape(mCheck.shape)
        vδ_flat = cδ_flat ** (-rho)
        # Inner expectation over theta, then weight by (R̃-R) and risky weights
        vδ_inner = vδ_flat @ theta_weights          # (J,)
        return (excess_R * vδ_inner) @ risky_weights

    def expected_v(Shr):
        Rport = Rfree + excess_R * Shr
        mCheck = _compute_mCheck(np.atleast_1d(k), Rport, theta_nodes, G)[0]
        v_flat = v_cntn(mCheck.ravel()).reshape(mCheck.shape)
        return (v_flat @ theta_weights) @ risky_weights

    # Check corner solutions
    f0 = foc_residual(0.0)
    f1 = foc_residual(1.0)

    if f0 <= 0.0:
        shr_opt = 0.0
    elif f1 >= 0.0:
        shr_opt = 1.0
    else:
        from scipy.optimize import brentq
        shr_opt = brentq(foc_residual, 0.0, 1.0, xtol=1e-12)

    return shr_opt, expected_v(shr_opt)
