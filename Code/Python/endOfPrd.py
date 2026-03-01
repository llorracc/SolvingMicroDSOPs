# ---
# jupyter:
#   jupytext:
#     formats: ipynb,py:light
#     text_representation:
#       extension: .py
#       format_name: light
#       format_version: '1.5'
#       jupytext_version: 1.19.1
#   kernelspec:
#     display_name: Python 3 (ipykernel)
#     language: python
#     name: python3
# ---

# ## The EndOfPrd class
# This notebook defines the EndOfPrd class, which encapsulates the
# end-of-period (continuation-stage) functions from SolvingMicroDSOPs:
# $\vEndPrd$, $\vEndPrd^{\delta a}$, and $\cCntn$, as well as interpolations.
#
# The class bundles the parameters for the problem in one place.
# We likewise bundle the utility function and the discrete distribution
# approximation in their own classes (see resources.py).
#
# We define an EndOfPrd object with \\uFunc, \\DiscFac, \\CRRA, \\PermGroFac,
# \\Rfree, and \\IncShkDstn.
#
# Once initialized, we have access to these methods:
#
#         vEndPrd(a):          \\vEndPrd(a) in levels
#         vEndPrd_Tm1(a):      \\vEndPrd_{T-1}(a) in levels
#         vCntnδ(a):        \\vEndPrd^{\\da}(a) marginal value
#         vCntnδ_Tm1(a):    \\vEndPrd^{\\da}_{T-1}(a) marginal value at T-1
#         vCntnδ_t(a):      \\vEndPrd^{\\da}_t(a) marginal value at general t
#         cCntn(a):          \\cCntn(a) consumed function
#         cCntn_Tm1(a):      \\cCntn_{T-1}(a) consumed function at T-1
#         cCntn_t(a):        \\cCntn_t(a) consumed function at general t
#
# ## The EndOfPrd class:

from __future__ import division
from scipy.interpolate import InterpolatedUnivariateSpline
import numpy as np


# + code_folding=[2, 144]
class EndOfPrd:
    def __init__(self, uFunc, DiscFac, CRRA, PermGroFac, Rfree, IncShkDstn, variable_variance=False):
        """
        Initialize an EndOfPrd object for end-of-period functions.

        Bundles the parameters needed to compute the end-of-period
        functions: \\vEndPrd, \\vEndPrd^{\\da}, and the "consumed function" \\cCntn.

        Parameters
        ----------
        uFunc : object
            Utility function (\\uFunc). Must accept a float and have a
            "δ" method returning marginal utility.
        DiscFac : float
            Discount factor (\\DiscFac).
        CRRA : float
            Coefficient of Relative Risk Aversion (\\CRRA).
        PermGroFac : array
            Permanent income growth factor (\\PermGroFac), time series indexed by t.
        Rfree : float
            Risk-free return factor (\\Rfree). Fixed in time.
        IncShkDstn : object
            Discretized income shock distribution. Must have method "E()"
            for computing expectations. Convention: permanent shock first,
            transitory shock second.
        variable_variance : bool
            If True, IncShkDstn is a list of distribution objects (one per period).
        """
        self.uFunc = uFunc
        self.DiscFac = DiscFac
        self.CRRA = CRRA
        self.PermGroFac = PermGroFac
        self.PermGroFacAdjV = PermGroFac ** (1.0 - CRRA)    # G^{1-rho}
        self.PermGroFacAdjMu = PermGroFac ** (-CRRA)         # G^{-rho}
        self.Rfree = Rfree
        self.IncShkDstn = IncShkDstn
        self.variable_variance = variable_variance

    def vEndPrd_Tm1(self, a):
        """
        End-of-period value \\vEndPrd(a) at T-1.

        Implements eq:vEndPrdTm1 from SolvingMicroDSOPs.
        """
        RNrmByG = self.Rfree / self.PermGroFac[-1]

        def vEndPrd_func(tranShkEmpDummy):
            return self.uFunc(RNrmByG * a + tranShkEmpDummy)

        return self.DiscFac * self.PermGroFacAdjV[-1] * self.IncShkDstn.E(vEndPrd_func)

    def vEndPrd(self, a, t=-1, vFuncNxt=None):
        """
        End-of-period value \\vEndPrd at asset level a.

        For t=-1 (T-1): implements eq:vEndPrdTm1 from SolvingMicroDSOPs.
        For general t with vFuncNxt: implements eq:vNormed.
        """

        if t == -1 and vFuncNxt is None:
            return np.vectorize(self.vEndPrd_Tm1)(a)

        # Define function describing tomorrow:
        if vFuncNxt is not None:
            tp1 = t + 1

            def vEndPrd_func(tranShkEmpDummy):
                return vFuncNxt(self.Rfree / self.PermGroFac[tp1] * a + tranShkEmpDummy)

        else:
            raise Exception(
                "Please either specify that t=-1 (indicating solution for period T-1) or specify *both* t and vFuncNxt."
            )

        if self.variable_variance:
            vEndPrd = (
                self.DiscFac * self.PermGroFacAdjV[tp1] * self.IncShkDstn[tp1].E(vEndPrd_func)
            )
        else:
            vEndPrd = self.DiscFac * self.PermGroFacAdjV[tp1] * self.IncShkDstn.E(vEndPrd_func)

        return vEndPrd

    def vCntnδ(self, a, t=-1, cFuncNxt=None):
        """
        Marginal end-of-period value \\vEndPrd^{\\da} at asset level a.

        For t=-1 (T-1): implements eq:vEndδTm1.
        For general t with cFuncNxt: implements eq:envelope.
        """

        if t == -1 and cFuncNxt is None:
            return np.vectorize(self.vCntnδ_Tm1)(a)

        if cFuncNxt is not None:
            tp1 = t + 1

            def vCntnδ_func(
                tranShkEmpDummy,
                Rfree=self.Rfree,
                PermGroFac_tp1=self.PermGroFac[tp1],
                aa=a,
                CRRA=self.CRRA,
                uδ=self.uFunc.δ,
                cFuncNxt_=cFuncNxt,
            ):
                return uδ(cFuncNxt_(Rfree / PermGroFac_tp1 * aa + tranShkEmpDummy))

        else:
            raise Exception(
                "Please either specify that t=-1 (indicating solution for period T-1) or specify *both* t and cFuncNxt."
            )

        if self.variable_variance:
            vCntnδ = (
                self.DiscFac
                * self.Rfree
                * self.PermGroFacAdjMu[tp1]
                * self.IncShkDstn[tp1].E(vCntnδ_func)
            )
        else:
            vCntnδ = (
                self.DiscFac
                * self.Rfree
                * self.PermGroFacAdjMu[tp1]
                * self.IncShkDstn.E(vCntnδ_func)
            )

        return vCntnδ

    def cCntn(self, a, t=-1, cFuncNxt=None):
        """
        "Consumed function" \\cCntn at asset level a.

        For t=-1 (T-1): implements eq:cGoth.
        For general t with cFuncNxt: implements eq:consumedfn.
        """

        if t == -1 and cFuncNxt is None:
            return np.vectorize(self.cCntn_Tm1)(a)
        elif cFuncNxt is not None:
            cCntn = self.vCntnδ(a, t=t, cFuncNxt=cFuncNxt) ** (-1.0 / self.CRRA)
        else:
            raise Exception(
                "Please either specify that t=-1 (indicating solution for period T-1) or specify *both* t and cFuncNxt."
            )

        return cCntn

    def cCntn_Tm1(self, a):
        """
        "Consumed function" \\cCntn at a for period T-1.

        Implements eq:cGoth from SolvingMicroDSOPs.
        """
        return self.vCntnδ_Tm1(a) ** (-1.0 / self.CRRA)

    def vCntnδ_Tm1(self, a):
        """
        Marginal end-of-period value \\vEndPrd^{\\da}(a) at T-1.

        Implements eq:vEndδTm1 from SolvingMicroDSOPs.
        """
        # RNrmByG = R/G (\\RNrmByG), the return factor normalized by growth:
        RNrmByG = self.Rfree / self.PermGroFac[-1]

        def vCntnδ_func(tranShkEmpDummy):
            return self.uFunc.δ(RNrmByG * a + tranShkEmpDummy)

        # The value:
        vCntnδ = (
            self.DiscFac * self.Rfree * self.PermGroFacAdjMu[-1] * self.IncShkDstn.E(vCntnδ_func)
        )

        return vCntnδ

    def cCntn_t(self, a, cFuncNxt, t=None):
        """
        "Consumed function" \\cCntn at a for a general period t.

        Implements eq:consumedfn from SolvingMicroDSOPs.
        Uses cFuncNxt (next-period consumption function) to compute expectations.
        """

        if t is None:
            t = -1

        E_sum = 0.0
        for tranShkEmp in self.IncShkDstn.X:
            RNrmByG_tp1 = self.Rfree / self.PermGroFac[t + 1]
            c_tp1 = cFuncNxt(RNrmByG_tp1 * a + tranShkEmp)

            E_sum += c_tp1 ** (-self.CRRA)

        alt_cCntn = (
            self.DiscFac
            * self.Rfree
            * (self.PermGroFac[t + 1] ** (-self.CRRA))
            * (1.0 / self.IncShkDstn.N)
            * E_sum
        ) ** (-1.0 / self.CRRA)

        cCntn = self.vCntnδ_t(a, cFuncNxt, t) ** (-1.0 / self.CRRA)

        tempdiff = alt_cCntn - cCntn
        assert np.abs(tempdiff) < 1e-10, (
            "in EndOfPrd.cCntn_t, manually calculated cCntn(a) != computed cCntn, by this much: "
            + str(tempdiff)
            + " values: alt_cCntn: "
            + str(alt_cCntn)
            + " cCntn: "
            + str(cCntn)
        )

        return cCntn

    def vCntnδ_t(self, a, cFuncNxt, t=None):
        """
        Marginal end-of-period value \\vEndPrd^{\\da}(a) for a general period t.

        Uses cFuncNxt (next-period consumption function) to compute expectations.
        Implements eq:vEndδTm1 generalized to arbitrary t.
        """

        if t is None:
            PermGroFacAdjMu_tp1 = self.PermGroFacAdjMu[0]
            RNrmByG_tp1 = self.Rfree / self.PermGroFac[0]
        else:
            PermGroFacAdjMu_tp1 = self.PermGroFacAdjMu[t + 1]
            RNrmByG_tp1 = self.Rfree / self.PermGroFac[t + 1]

        def vCntnδ_func(tranShkEmpDummy):
            return self.uFunc.δ(cFuncNxt(RNrmByG_tp1 * a + tranShkEmpDummy))

        # The value:
        vCntnδ = self.DiscFac * self.Rfree * PermGroFacAdjMu_tp1 * self.IncShkDstn.E(vCntnδ_func)

        return vCntnδ


# -


# ### Demonstrating Functionality
#
# First import and define a number of items needed:

# ### Plot some of the functions:
#
# Examine consumption functions.

# +
# if __name__ == "__main__":
#     # Examine the cCntn function:
#     # f = endOfPrd.cCntn_Tm1_interp(a_grid, self_a_min)

#     temp_a_grid = [self_a_min] + [a for a in a_grid]
#     c_grid = [0.0]
#     m_grid = [self_a_min]
#     for a in a_grid:
#         c = endOfPrd.cCntn(a, t=-1)
#         m = a + c
#         c_grid.append(c)
#         m_grid.append(m)

#     # Define a consumption function:
#     cFuncTm1 = InterpolatedUnivariateSpline(m_grid, c_grid, k=1)
#     plt.plot(m_grid, c_grid, "g-")
#     plt.show()

#     # Examine the cCntn function for (t != T-1):
#     c_grid2 = [0.0]
#     m_grid2 = [self_a_min]  # This needs to be ... falling back?
#     # because each period can potentially be borrowing
#     # more?
#     for a in a_grid:
#         c = endOfPrd.cCntn(a, t=0, cFuncNxt=cFuncTm1)
#         m = a + c
#         c_grid2.append(c)
#         m_grid2.append(m)

#     cFuncTm2 = InterpolatedUnivariateSpline(m_grid2, c_grid2, k=1)

#     plt.plot(m_grid, c_grid, "g-")
#     plt.plot(m_grid2, c_grid2, "r--")
#     plt.title("Consumption for T-1 and T-2")
#     plt.show()

#     # Examine the cCntn function for (t != T-1):
#     c_grid3 = [0.0]
#     m_grid3 = [self_a_min]  # This needs to be ... falling back?
#     # because each period can potentially be borrowing
#     # more?
#     for a in a_grid:
#         c = endOfPrd.cCntn(a, t=0, cFuncNxt=cFuncTm2)
#         m = a + c
#         c_grid3.append(c)
#         m_grid3.append(m)

#     plt.plot(m_grid, c_grid, "g-")
#     plt.plot(m_grid2, c_grid2, "r--")
#     plt.plot(m_grid3, c_grid3, "b:")
#     plt.title("Consumption for T-1, T-2, and T-3")
#     plt.show()
# -


# ## We will see that \\vEndPrd and \\vEndPrd^{\\da} replicate desired values.

# Code saved for possible future use:
"""
if __name__ == "__main__":
    # Examine the vEndPrd function:
    big_a_grid = np.linspace(0,4, 100)
    vals = [endOfPrd.vEndPrd(a) for a in a_grid]
    plt.plot(a_grid, vals, 'r--')
    plt.ylim(-2, 0.1)
    plt.show()

    # Examine the vCntnδ function:
    big_a_grid = np.linspace(0,4, 100)
    vals = [endOfPrd.vCntnδ_Tm1(a) for a in a_grid]
    plt.plot(a_grid, vals, 'r--')
    plt.ylim(0.0, 1.0)
    plt.show()
"""
'''
    def vCntnδ_Tm1_interp(self, a_grid):
        """
        Given a grid of end-of-period a-values, return the \\vEndPrd^{\\da}_{T-1} 
        function interpolated between the points on a_grid. 
        
        This implements eq:vEndδTm1 from SolvingMicroDSOPs, interpolated across a_grid.

        **NOTE: currently a bug here. Need to find. For now find externally.
        """        
        values = [self.vCntnδ_Tm1(a) for a in a_grid]
        return InterpolatedUnivariateSpline(a_grid, values, k=1)

    def cCntn_Tm1_interp(self, a_grid, a_min=None):
        """
        NOTE: not used in main program. Retained for future use.
        
        Return the \\cCntn value interpolated across the a-grid.
        
        a_min here refers to \\NatBoroCnstra_{T-1}. When provided, it must be correct.
        """
        if a_min is not None:
            a_grid = np.append(a_min, a_grid)
            Y = [self.cCntn_Tm1(a) for a in a_grid]
            Y[0] = 0.0
        else:
            Y = [self.cCntn_Tm1(a) for a in a_grid]
        return InterpolatedUnivariateSpline(a_grid, Y, k=1)     
'''
