"""Solver routines extracted from SolvingMicroDSOPs.ipynb.

Each function encapsulates a mechanical loop that was previously
inline in the notebook, letting the notebook cells focus on the
mathematical ideas rather than loop bookkeeping.
"""

import numpy as np
from scipy.optimize import minimize
from scipy.interpolate import InterpolatedUnivariateSpline


# ------------------------------------------------------------------
# 1. Direct value-function maximisation
# ------------------------------------------------------------------

def solve_Tm1_direct(endOfPrd, m_grid, v_cntn=None):
    """Solve T-1 by maximising u(c) + v_cntn(m-c) on *m_grid*.

    Parameters
    ----------
    endOfPrd : EndOfPrd instance
    m_grid : 1-d array of market-resources values
    v_cntn : callable, optional
        Continuation value v(a).  When None, uses endOfPrd.vEndPrd(a).

    Returns
    -------
    cVec, vVec : lists of optimal consumption and value at each m.
    """
    u = endOfPrd.uFunc
    Gamma = endOfPrd.PermGroFac
    Rfree = endOfPrd.Rfree
    theta_min = min(endOfPrd.IncShkDstn.X)

    if v_cntn is None:
        v_cntn = endOfPrd.vEndPrd

    cVec, vVec = [], []
    for m in m_grid:
        c_max = m + Gamma[0] * theta_min / Rfree
        nvalue = lambda c: -(u(c) + v_cntn(m - c))
        res = minimize(nvalue, np.array([0.3 * m]),
                       method='trust-constr',
                       bounds=((1e-12, 0.999 * c_max),),
                       options={'gtol': 1e-12, 'disp': False})
        cVec.append(res['x'][0])
        vVec.append(-res['fun'])
    return cVec, vVec


# ------------------------------------------------------------------
# 1b. Plot_ud_VS_vCntnd data: u^{\partial}(c) vs marginal continuation values
# ------------------------------------------------------------------

def compute_uδ_vs_vCntnδ_data(sigma_theta=1.0, N_shocks=7, N_coarse=5,
                                  rho=2.0, beta=0.96, R=1.02, G=1.0,
                                  a_max=4.0, eps=0.001, c_fine_N=500):
    """Compute data for Plot_ud_VS_vCntnd (marginal utility vs marginal continuation value).

    Sets up a 2-period model with exaggerated income-shock variance
    (sigma_theta=1.0, matching Code-private/Mathematica/2periodIntExp!Plot.m)
    and computes:

      - u'(c): CRRA marginal utility
      - v'_cntn(m-c): exact marginal continuation value for m=3 and m=4,
        computed analytically via EndOfPrd.vCntnδ_Tm1
      - v̂'_cntn(m-c): numerical derivative of the piecewise-linear
        interpolation of v_cntn on a coarse N_coarse-point grid

    The step-function character of v̂' illustrates the problem with
    optimizing u(c) + v̂_cntn(m-c): the optimizer returns an arbitrary
    point within a flat step rather than the true optimum.

    Returns dict with keys:
        c_m3, vp_exact_m3, vp_hat_m3,
        c_m4, uδ, vp_exact_m4, vp_hat_m4
    """
    from Code.Python.resources import Utility
    from Code.Python.notebook_params import make_income_distribution
    from Code.Python.endOfPrd import EndOfPrd

    u = Utility(rho)
    theta = make_income_distribution(sigma=sigma_theta, N=N_shocks)
    Gamma = np.array([G])
    eop = EndOfPrd(u, beta, rho, Gamma, R, theta)

    # Piecewise-linear interpolation of v_cntn(a) on the coarse grid
    a_coarse = np.linspace(0, a_max, N_coarse)
    v_coarse = np.array([eop.vEndPrd(a, t=-1) for a in a_coarse])
    v_hat = InterpolatedUnivariateSpline(a_coarse, v_coarse, k=1)

    def vp_hat(a):
        return float((v_hat(a + eps) - v_hat(a - eps)) / (2 * eps))

    c_m3 = np.linspace(0.1, 3.0, int(c_fine_N * 0.75))
    c_m4 = np.linspace(0.1, 4.0, c_fine_N)

    return dict(
        c_m3=c_m3,
        vp_exact_m3=np.array([eop.vCntnδ_Tm1(3.0 - c) for c in c_m3]),
        vp_hat_m3=np.array([vp_hat(3.0 - c) for c in c_m3]),
        c_m4=c_m4,
        uδ=u.δ(c_m4),
        vp_exact_m4=np.array([eop.vCntnδ_Tm1(4.0 - c) for c in c_m4]),
        vp_hat_m4=np.array([vp_hat(4.0 - c) for c in c_m4]),
    )


# ------------------------------------------------------------------
# 2. EGM for a single period
# ------------------------------------------------------------------

def solve_egm_Tm1(endOfPrd, a_grid, self_a_min, constrained=True):
    """Run one-period EGM at T-1 and return (mVec, cVec).

    Parameters
    ----------
    endOfPrd : EndOfPrd instance
    a_grid : 1-d array of end-of-period asset points
    self_a_min : float  (natural borrowing constraint)
    constrained : bool
        If True, enforce c <= m (no borrowing beyond natural constraint).

    Returns
    -------
    mVec, cVec : lists (including the boundary point at the start)
    """
    m0 = 0.0 if (constrained and self_a_min < 0) else self_a_min
    cVec = [0.0]
    mVec = [m0]
    for a in a_grid:
        c = endOfPrd.cCntn_Tm1(a)
        m = c + a
        if constrained:
            c = np.minimum(c, m)
        cVec.append(c)
        mVec.append(m)
    return mVec, cVec


# ------------------------------------------------------------------
# 3. Consumption-only life-cycle backward induction
# ------------------------------------------------------------------

def solve_consumption_lifecycle(endOfPrd, T, a_grid, self_a_min,
                                constrained=True):
    """Backward induction over T periods using EGM (no portfolio).

    Returns
    -------
    cFunc_life : dict  {t: InterpolatedUnivariateSpline}  for t in 0..T-1.
    """
    m0 = 0.0 if (constrained and self_a_min < 0) else self_a_min

    # --- T-1: terminal period ---
    cVec = [0.0]
    mVec = [m0]
    for a in a_grid:
        c = endOfPrd.cCntn_Tm1(a)
        m = c + a
        if constrained:
            c = np.minimum(c, m)
        cVec.append(c)
        mVec.append(m)

    cFunc = InterpolatedUnivariateSpline(mVec, cVec, k=1)
    cFunc_life = {T - 1: cFunc}

    # --- backward from T-2 to 0 ---
    for t in range(T - 2, -1, -1):
        cVec = [0.0]
        mVec = [m0]
        for a in a_grid:
            c = endOfPrd.cCntn_t(a, cFunc)
            m = c + a
            if constrained:
                c = np.minimum(c, m)
            cVec.append(c)
            mVec.append(m)
        cFunc = InterpolatedUnivariateSpline(mVec, cVec, k=1)
        cFunc_life[t] = cFunc

    return cFunc_life


# ------------------------------------------------------------------
# 4. Portfolio life-cycle backward induction  (EndOfPrdMC)
# ------------------------------------------------------------------

def solve_portfolio_lifecycle(endOfPrdMC, T, a_grid):
    """Backward induction over T periods with portfolio share optimisation.

    Returns
    -------
    cFuncPort_life : dict  {t: spline}
    varsigma_life  : dict  {t: spline}
    """
    # --- T-1 (terminal next period) ---
    cVec, mVec, sVec = [0.0], [0.0], [0.0]
    for a in a_grid:
        varsigma = endOfPrdMC.varsigma_Tminus1(a)
        c = endOfPrdMC.C_Tminus1(a)
        m = c + a
        c = np.minimum(c, m)
        cVec.append(c); mVec.append(m); sVec.append(varsigma)

    cFunc = InterpolatedUnivariateSpline(mVec, cVec, k=1)
    sFunc = InterpolatedUnivariateSpline(mVec[1:], sVec[1:], k=1)
    cFuncPort_life = {T - 1: cFunc}
    varsigma_life = {T - 1: sFunc}

    # --- backward from T-2 to 1 ---
    for t in range(T - 2, 0, -1):
        cVec, mVec, sVec = [0.0], [0.0], [0.0]
        for a in a_grid:
            varsigma = endOfPrdMC.varsigma_t(a, cFunc)
            c = endOfPrdMC.C_t(a, cFunc)
            m = c + a
            c = np.minimum(c, m)
            cVec.append(c); mVec.append(m); sVec.append(varsigma)

        cFunc = InterpolatedUnivariateSpline(mVec, cVec, k=1)
        sFunc = InterpolatedUnivariateSpline(mVec[1:], sVec[1:], k=1)
        cFuncPort_life[t] = cFunc
        varsigma_life[t] = sFunc

    return cFuncPort_life, varsigma_life


# ------------------------------------------------------------------
# 5. HARK agent configuration  (EndOfPrdMC comparison)
# ------------------------------------------------------------------

def make_hark_portfolio_agent(T, rho_port, beta, R, Gamma,
                              theta_sigma_port, RiskyR_sigma,
                              RiskyR_grid_N, phi, a_max,
                              init_lifecycle_template=None):
    """Configure and return a HARK PortfolioConsumerType (unsolved).

    Caller must still invoke ``agent.solve()``.

    Parameters ``RiskyR_sigma`` and ``theta_sigma_port`` are level-space
    standard deviations.  HARK expects log-space sigma for ``RiskyStd``,
    so we convert here.
    """
    from copy import copy
    import numpy as np
    from HARK.ConsumptionSaving.ConsIndShockModel import init_lifecycle
    from HARK.ConsumptionSaving.ConsPortfolioModel import PortfolioConsumerType

    if init_lifecycle_template is None:
        init_lifecycle_template = init_lifecycle

    cfg = copy(init_lifecycle_template)
    T_cycle = T - 1

    # HARK's RiskyStd is sigma of log(R_risky); convert from level-space
    risky_mean = R + phi
    risky_sigma_log = float(np.sqrt(
        np.log(RiskyR_sigma**2 / risky_mean**2 + 1)
    ))

    cfg["T_cycle"] = T_cycle
    cfg["CRRA"] = rho_port
    cfg["Rfree"] = [R] * T_cycle
    cfg["LivPrb"] = [1.0] * T_cycle
    cfg["PermGroFac"] = [float(Gamma[0])] * T_cycle
    cfg["PermShkStd"] = [0.0] * T_cycle
    cfg["PermShkCount"] = 1
    cfg["TranShkStd"] = [theta_sigma_port] * T_cycle
    cfg["UnempPrb"] = 0.0
    cfg["T_retire"] = 0
    cfg["RiskyAvg"] = [risky_mean] * T_cycle
    cfg["RiskyStd"] = [risky_sigma_log] * T_cycle
    cfg["RiskyCount"] = RiskyR_grid_N
    cfg["RiskyAvgTrue"] = risky_mean
    cfg["RiskyStdTrue"] = risky_sigma_log
    cfg["DiscFac"] = beta
    cfg["PermGroFacAgg"] = 1.0
    cfg["aXtraMax"] = a_max
    cfg["aXtraCount"] = 800

    agent = PortfolioConsumerType(**cfg)
    agent.cycles = 1
    agent.vFuncBool = False
    return agent


def evaluate_hark_marginal_values(agent, a_grid, share_grid, which_period):
    """Evaluate dv/d(varsigma) from HARK on an (a, share) grid."""
    dvds_func = agent.solution[which_period - 1].dvdsFuncFxd
    mv = np.empty((len(a_grid), len(share_grid)))
    for i, a in enumerate(a_grid):
        for j, s in enumerate(share_grid):
            mv[i, j] = dvds_func(a, s)
    return mv
