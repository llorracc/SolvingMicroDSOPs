"""EndOfPrdMC: end-of-period class with multiple controls (portfolio choice).

Extends EndOfPrd with methods for optimising the portfolio share varsigma
alongside consumption c (portfolio-choice / EndOfPrdMC treatment).

Key methods
-----------
varsigma_Tminus1(a)        optimal share at T-1 (terminal next period)
varsigma_t(a, cFuncNxt)    optimal share at general t, given cFuncNxt
C_Tminus1(a)               optimal c at T-1
C_t(a, cFuncNxt)           optimal c at general t
Va_Tminus1(a)              marginal continuation value at T-1
Va_t(a, cFuncNxt)          marginal continuation value at general t
Vsigma_Tminus1(a, s)       dv/d(varsigma) at T-1
Vsigma_t(a, s, cFuncNxt)   dv/d(varsigma) at general t
"""

import numpy as np
from Code.Python.endOfPrd import EndOfPrd


class EndOfPrdMC(EndOfPrd):
    """End-of-period functions with portfolio (multiple-control) optimisation."""

    def __init__(self, uFunc, DiscFac, CRRA, PermGroFac, Rfree,
                 Distribution, share_grid_size,
                 IncShkDstn=None, Return=None, variable_variance=False):
        super().__init__(uFunc, DiscFac, CRRA, PermGroFac, Rfree,
                         IncShkDstn, variable_variance=False)
        self.Return = Return
        self.Distribution = Distribution
        self.share_grid_size = share_grid_size
        self.varsigma_grids = np.linspace(0.0, 1.0, self.share_grid_size)

    # ------------------------------------------------------------------
    # Share optimisation
    # ------------------------------------------------------------------

    def _find_optimal_share(self, FOC_s):
        """Find the zero-crossing of the FOC grid via linear interpolation."""
        share_grids = self.varsigma_grids
        if FOC_s[-1] > 0.0:
            return 1.0
        if FOC_s[0] < 0.0:
            return 0.0
        crossing = np.logical_and(FOC_s[1:] <= 0.0, FOC_s[:-1] >= 0.0)
        idx = np.argwhere(crossing)[0]
        bot_s, top_s = share_grids[idx], share_grids[idx + 1]
        bot_f, top_f = FOC_s[idx], FOC_s[idx + 1]
        alpha = 1.0 - top_f / (top_f - bot_f)
        return np.squeeze((1.0 - alpha) * bot_s + alpha * top_s)

    def varsigma_Tminus1(self, a):
        """Optimal portfolio share at T-1 (eq:shrDecision, terminal)."""
        if a < 0:
            return 0.0
        FOC_s = np.array([self.Vsigma_Tminus1(a, s) for s in self.varsigma_grids])
        return self._find_optimal_share(FOC_s)

    def varsigma_t(self, a, cFuncNxt):
        """Optimal portfolio share at general t (eq:shrDecision)."""
        if a < 0:
            return 0.0
        FOC_s = np.array([self.Vsigma_t(a, s, cFuncNxt) for s in self.varsigma_grids])
        return self._find_optimal_share(FOC_s)

    # ------------------------------------------------------------------
    # Consumption and marginal value
    # ------------------------------------------------------------------

    def C_Tminus1(self, a):
        return self.Va_Tminus1(a) ** (-1.0 / self.CRRA)

    def C_t(self, a, cFuncNxt):
        return self.Va_t(a, cFuncNxt) ** (-1.0 / self.CRRA)

    def Va_Tminus1(self, a):
        r"""dv_cntn/da at T-1 using optimal share (eq:vEndδTm1 + portfolio)."""
        varsigma_opt = self.varsigma_Tminus1(a)
        Va_func = lambda tinc_shk, rreturn: (
            self.Rfree + (rreturn - self.Rfree) * varsigma_opt
        ) * self.uFunc.δ(
            (self.Rfree + (rreturn - self.Rfree) * varsigma_opt)
            * a / self.PermGroFac[-1] + tinc_shk
        )
        return self.DiscFac * self.PermGroFacAdjMu[-1] * self.Distribution.E(Va_func)

    def Va_t(self, a, cFuncNxt):
        r"""dv_cntn/da at general t using optimal share (eq:envelope + portfolio)."""
        varsigma_opt = self.varsigma_t(a, cFuncNxt)
        Va_func = lambda tinc_shk, rreturn: (
            self.Rfree + (rreturn - self.Rfree) * varsigma_opt
        ) * self.uFunc.δ(
            cFuncNxt(
                (self.Rfree + (rreturn - self.Rfree) * varsigma_opt)
                * a / self.PermGroFac[-1] + tinc_shk
            )
        )
        return self.DiscFac * self.PermGroFacAdjMu[-1] * self.Distribution.E(Va_func)

    # ------------------------------------------------------------------
    # FOC w.r.t. portfolio share (for grid search)
    # ------------------------------------------------------------------

    def Vsigma_Tminus1(self, a, varsigma):
        r"""dv_cntn/d(varsigma) at T-1 for a given share."""
        if a == 0.0:
            return np.inf
        Vshare_func = lambda tinc_shk, rreturn: (
            rreturn - self.Rfree
        ) * self.uFunc.δ(
            (self.Rfree + (rreturn - self.Rfree) * varsigma)
            * a / self.PermGroFac[-1] + tinc_shk
        )
        return self.DiscFac * a / self.PermGroFac[-1] * self.Distribution.E(Vshare_func)

    def Vsigma_t(self, a, varsigma, cFuncNxt):
        r"""dv_cntn/d(varsigma) at general t for a given share."""
        if a == 0.0:
            return np.inf
        Vshare_func = lambda tinc_shk, rreturn: (
            rreturn - self.Rfree
        ) * self.uFunc.δ(
            cFuncNxt(
                (self.Rfree + (rreturn - self.Rfree) * varsigma)
                * a / self.PermGroFac[-1] + tinc_shk
            )
        )
        return self.DiscFac * a / self.PermGroFac[-1] * self.Distribution.E(Vshare_func)
