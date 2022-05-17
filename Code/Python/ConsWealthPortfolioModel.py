from copy import deepcopy
from dataclasses import dataclass

import numpy as np
from HARK.ConsumptionSaving.ConsPortfolioModel import (
    ConsPortfolioSolver,
    PortfolioConsumerType,
    init_portfolio,
)
from HARK.core import MetricObject, make_one_period_oo_solver
from HARK.distribution import DiscreteDistribution, calc_expectation
from HARK.interpolation import (
    LinearInterp,
    MargValueFuncCRRA,
    ValueFuncCRRA,
    ConstantFunction,
    BilinearInterp,
)
from HARK.utilities import CRRAutilityP_inv, NullFunc
from scipy.optimize import minimize_scalar, fixed_point, root

epsilon = 1e-6


@dataclass
class WealthPortfolioSolution(MetricObject):
    distance_criteria = ["vPfunc"]
    cFunc: LinearInterp = NullFunc()
    cFuncEnd: LinearInterp = NullFunc()
    shareFunc: LinearInterp = NullFunc()
    vFunc: ValueFuncCRRA = NullFunc()
    vPfunc: MargValueFuncCRRA = NullFunc()


class WealthPortfolioConsumerType(PortfolioConsumerType):
    time_inv_ = deepcopy(PortfolioConsumerType.time_inv_)
    time_inv_ = time_inv_ + ["WealthShare"]

    def __init__(self, verbose=False, quiet=False, **kwds):
        params = init_wealth_portfolio.copy()
        params.update(kwds)
        kwds = params

        # Initialize a basic portfolio consumer type
        PortfolioConsumerType.__init__(self, verbose=verbose, quiet=quiet, **kwds)

        solver = ConsWealthPortfolioSolver

        self.solve_one_period = make_one_period_oo_solver(solver)

    def update_solution_terminal(self):
        # set up with CRRA split with u of c and a

        mGrid = np.append(0.0, self.aXtraGrid)
        cGrid = (1 - self.WealthShare) * mGrid  # CD share of wealth
        aGrid = self.WealthShare * mGrid  # CD share of wealth

        cFunc_terminal = LinearInterp(mGrid, cGrid)  # as a function of wealth
        cFuncEnd_terminal = LinearInterp(aGrid, cGrid)  # as a function of assets
        shareFunc_terminal = ConstantFunction(0.0)  # this doesn't matter?

        vNvrs = cGrid ** (1.0 - self.WealthShare) * aGrid ** self.WealthShare
        vNvrsFunc = LinearInterp(mGrid, vNvrs)
        vFunc_terminal = ValueFuncCRRA(vNvrsFunc, self.CRRA)

        constant = (
            (1 - self.WealthShare) ** (1 - self.WealthShare)
            * self.WealthShare ** self.WealthShare
        ) ** (1 - self.CRRA)

        vPNvrs = mGrid * CRRAutilityP_inv(constant, self.CRRA)
        vPNvrsFunc = LinearInterp(mGrid, vPNvrs)

        vPfunc_terminal = MargValueFuncCRRA(vPNvrsFunc, self.CRRA)

        self.solution_terminal = WealthPortfolioSolution(
            cFunc=cFunc_terminal,
            cFuncEnd=cFuncEnd_terminal,
            shareFunc=shareFunc_terminal,
            vFunc=vFunc_terminal,
            vPfunc=vPfunc_terminal,
        )


@dataclass
class ConsWealthPortfolioSolver(ConsPortfolioSolver):
    solution_next: WealthPortfolioSolution
    ShockDstn: DiscreteDistribution
    IncShkDstn: DiscreteDistribution
    TranShkDstn: DiscreteDistribution
    RiskyDstn: DiscreteDistribution
    LivPrb: float
    DiscFac: float
    CRRA: float
    Rfree: float
    PermGroFac: float
    BoroCnstArt: float
    aXtraGrid: np.array
    ShareGrid: np.array
    vFuncBool: bool
    AdjustPrb: float
    DiscreteShareBool: bool
    ShareLimit: float
    IndepDstnBool: bool
    WealthShare: float

    def __post_init__(self):
        self.def_utility_funcs()

    def def_utility_funcs(self):
        """
        Define temporary functions for utility and its derivative and inverse
        """
        super().def_utility_funcs()

        # cobb douglas aggregate of consumption and assets
        self.f = lambda c, a: (c ** (1.0 - self.WealthShare)) * (a ** self.WealthShare)
        self.fPc = (
            lambda c, a: (1.0 - self.WealthShare)
            * c ** (-self.WealthShare)
            * a ** self.WealthShare
        )
        self.fPa = (
            lambda c, a: self.WealthShare
            * c ** (1.0 - self.WealthShare)
            * a ** (self.WealthShare - 1.0)
        )

        self.uCD = lambda c, a: self.u(self.f(c, a))
        self.uPc = lambda c, a: self.uP(self.f(c, a)) * self.fPc(c, a)
        self.uPa = lambda c, a: self.uP(self.f(c, a)) * self.fPa(c, a)

        self.CRRA_Alt = self.CRRA * (1 - self.WealthShare) + self.WealthShare
        self.WealthShare_Alt = self.WealthShare * (1 - self.CRRA) / self.CRRA_Alt
        self.muInv = lambda x: CRRAutilityP_inv(
            x / (1 - self.WealthShare), self.CRRA_Alt
        )

    def set_and_update_values(self):
        """
        Unpacks some of the inputs (and calculates simple objects based on them),
        storing the results in self for use by other methods.
        """

        # Unpack next period's solution
        self.vPfunc_next = self.solution_next.vPfunc
        self.vFunc_next = self.solution_next.vFunc

        # Flag for whether the natural borrowing constraint is zero
        # True because of utility of assets, functions cannot be evaluated at a = 0
        self.zero_bound = True

    def prepare_to_calc_EndOfPrdvP(self):
        """
        Prepare to calculate end-of-period marginal values by creating an array
        of market resources that the agent could have next period, considering
        the grid of end-of-period assets and the distribution of shocks he might
        experience next period.
        """

        super().prepare_to_calc_EndOfPrdvP()

        self.aNrmMat, self.shareMat = np.meshgrid(
            self.aNrmGrid, self.ShareGrid, indexing="ij"
        )

    def calc_EndOfPrdvP(self):
        """
        Calculate end-of-period marginal value of assets and shares at each point
        in aNrm and ShareGrid. Does so by taking expectation of next period marginal
        values across income and risky return shocks.
        """

        def dvdb_func(shocks, b_nrm):
            """
            Evaluate realizations of marginal value of market resources next period
            """

            p_shk = shocks[0] * self.PermGroFac
            t_shk = shocks[1]
            m_nrm_next = b_nrm / p_shk + t_shk

            dvdb = self.vPfunc_next(m_nrm_next)

            return p_shk ** (-self.CRRA) * dvdb

        # Calculate intermediate marginal value of bank balances by taking expectations over income shocks
        dvdb_intermed = calc_expectation(self.IncShkDstn, dvdb_func, self.bNrmGrid)
        dvdbNvrs_intermed = self.uPinv(dvdb_intermed)

        dvdbNvrsFunc_intermed = LinearInterp(self.bNrmGrid, dvdbNvrs_intermed)
        dvdbFunc_intermed = MargValueFuncCRRA(dvdbNvrsFunc_intermed, self.CRRA)

        def marginal_values(shock, a_nrm, share):
            """
            Evaluate realizations of marginal value of share
            """

            r_diff = shock - self.Rfree
            r_port = self.Rfree + r_diff * share
            b_nrm = a_nrm * r_port

            E_dvdb = dvdbFunc_intermed(b_nrm)

            dvda = r_port * E_dvdb
            dvds = r_diff * a_nrm * E_dvdb

            return dvda, dvds

        # Calculate end-of-period marginal value of risky portfolio share by taking expectations
        marg_vals = (
            self.DiscFac
            * self.LivPrb
            * calc_expectation(
                self.RiskyDstn, marginal_values, self.aNrmMat, self.shareMat
            )
        )
        # calc_expectation returns one additional "empty" dimension, remove it
        # this line can be deleted when calc_expectation is fixed
        marg_vals = marg_vals[:, :, :, 0]

        self.EndOfPrddvda = marg_vals[0]
        self.EndOfPrddvds = marg_vals[1]

        self.EndOfPrddvdaNvrs = self.uPinv(self.EndOfPrddvda)
        self.EndOfPrddvdaNvrsFunc = BilinearInterp(
            self.EndOfPrddvdaNvrs, self.aNrmGrid, self.ShareGrid
        )
        self.EndOfPrddvdaFunc = MargValueFuncCRRA(self.EndOfPrddvdaNvrsFunc, self.CRRA)

    def calc_EndOfPrdv(self):
        def v_of_b(shocks, b_nrm):
            p_shk = shocks[0] * self.PermGroFac
            t_shk = shocks[1]
            m_nrm_next = b_nrm / p_shk + t_shk

            v_next = self.vFunc_next(m_nrm_next)

            return p_shk ** (1.0 - self.CRRA) * v_next

        v_intermed = calc_expectation(self.IncShkDstn, v_of_b, self.bNrmGrid)
        vNvrs_intermed = self.uinv(v_intermed)

        vNvrsFunc_intermed = LinearInterp(self.bNrmGrid, vNvrs_intermed)
        vFunc_intermed = ValueFuncCRRA(vNvrsFunc_intermed, self.CRRA)

        def v_of_a(shock, a_nrm, share):
            r_diff = shock - self.Rfree
            r_port = self.Rfree + r_diff * share
            b_nrm = a_nrm * r_port

            return vFunc_intermed(b_nrm)

        vals = (
            self.DiscFac
            * self.LivPrb
            * calc_expectation(self.RiskyDstn, v_of_a, self.aNrmMat, self.shareMat)
        )
        vals = vals[:, :, 0]
        vNvrs = self.uinv(vals)
        vNvrsFunc = BilinearInterp(vNvrs, self.aNrmGrid, self.ShareGrid)
        vFunc = ValueFuncCRRA(vNvrsFunc, self.CRRA)

        self.EndOfPrdvFunc = vFunc

    def optimize_risky_share(self, how="root"):

        aNrmGrid_temp = np.append(0.0, self.aNrmGrid)

        if how == "root":  # by root finding
            # already done by parent
            self.opt_share = self.Share_now

        elif how == "vfi":  # by value function iteration

            self.calc_EndOfPrdv()

            def objective_share(share, a_nrm):
                return -self.EndOfPrdvFunc(a_nrm, share)

            opt_share = np.empty_like(self.aNrmGrid)
            v_opt = np.empty_like(self.aNrmGrid)
            for ai in range(self.aNrmGrid.size):
                a_nrm = self.aNrmGrid[ai]
                sol = minimize_scalar(
                    objective_share, method="bounded", args=(a_nrm,), bounds=(0, 1),
                )
                opt_share[ai] = sol.x
                v_opt[ai] = -sol.fun

            self.opt_share = opt_share

            # need to reset EndOfPrdv to be a function of just a
            vNvrs = self.uinv(v_opt)
            vNvrs_temp = np.append(0.0, vNvrs)
            vNvrsFunc = LinearInterp(aNrmGrid_temp, vNvrs_temp)
            self.EndOfPrdvFunc = ValueFuncCRRA(vNvrsFunc, self.CRRA)

        # calculate end of period vp function given optimal share
        # this is created regardless of how optimal share is found
        vP = self.EndOfPrddvdaFunc(self.aNrmGrid, self.opt_share)
        vPnvrs = self.uPinv(vP)
        vPnvrs_temp = np.append(0.0, vPnvrs)
        vPnvrsFunc = LinearInterp(aNrmGrid_temp, vPnvrs_temp)
        self.EndOfPrdvPfunc = MargValueFuncCRRA(vPnvrsFunc, self.CRRA)

    def optimize_consumption_vfi(self):

        self.optimize_risky_share(how="root")

        def objective_consumption(c_nrm, m_nrm):
            a_nrm = m_nrm - c_nrm
            return -self.uCD(c_nrm, a_nrm) - self.EndOfPrdvFunc(a_nrm)

        # use the same grid for cash on hand
        self.mNrmGrid = self.aXtraGrid

        c_opt = np.empty_like(self.mNrmGrid)
        v_opt = np.empty_like(c_opt)
        for mi in range(self.mNrmGrid.size):
            m_nrm = self.mNrmGrid[mi]
            sol = minimize_scalar(
                objective_consumption,
                method="bounded",
                args=(m_nrm,),
                bounds=(epsilon, m_nrm - epsilon),
            )

            c_opt[mi] = sol.x
            v_opt[mi] = -sol.fun

        return c_opt, v_opt

    def optimize_consumption_fixed_point(self, cNrm, mNrm):

        self.optimize_risky_share()

        def first_order_condition(c_nrm_prev, a_nrm):
            # first order condition solving for outer c
            num = self.muInv(self.EndOfPrdvPfunc(a_nrm)) * (
                a_nrm ** self.WealthShare_Alt
            )
            denom = self.muInv(
                1 - (c_nrm_prev / a_nrm) * (self.WealthShare / (1 - self.WealthShare))
            )

            c_nrm_next = num / denom

            return c_nrm_next

        def first_order_condition_alt(c_nrm_prev, a_nrm):
            # save as first order condition above without using muInv
            num = self.EndOfPrdvPfunc(a_nrm)
            denom = (1 - self.WealthShare) * (
                a_nrm / c_nrm_prev
            ) ** self.WealthShare - self.WealthShare * (c_nrm_prev / a_nrm) ** (
                1 - self.WealthShare
            )

            c_nrm_next = (num / denom) ** (-1 / (self.CRRA) * (1 - self.WealthShare))

            return c_nrm_next

        def first_order_condition_other(c_nrm_prev, a_nrm):
            # first order condition solving for inner c
            lhs = 1 - self.EndOfPrdvPfunc(a_nrm) / self.uPc(c_nrm_prev, a_nrm)
            return lhs * (1 - self.WealthShare) / self.WealthShare * a_nrm

        aNrm = mNrm - cNrm

        # testing all 3 conditions over already optimized functions
        # FOC minus actual consumption should be equal to 0
        # still seems like v3 `first order condition` other is the best
        v1 = first_order_condition(cNrm, aNrm) - cNrm
        v2 = first_order_condition_alt(cNrm, aNrm) - cNrm
        v3 = first_order_condition_other(cNrm, aNrm) - cNrm

        # first guess should be based off previous solution
        c_next = self.solution_next.cFuncEnd(self.aNrmGrid)
        c_now = self.cFuncEnd(self.aNrmGrid)

        # the below grids show how close the `approximations` are to the
        # optimal solution
        c_now_v1 = first_order_condition(c_now, self.aNrmGrid) - c_now
        c_now_v2 = first_order_condition_alt(c_now, self.aNrmGrid) - c_now
        c_now_v3 = first_order_condition_other(c_now, self.aNrmGrid) - c_now

        c_next_v1 = first_order_condition(c_next, self.aNrmGrid) - c_next
        c_next_v2 = first_order_condition_alt(c_next, self.aNrmGrid) - c_next
        c_next_v3 = first_order_condition_other(c_next, self.aNrmGrid) - c_next

        c_opt = np.empty_like(self.aNrmGrid)

        # conclusion: fixed point itteration is good only when the initial
        # guess is *very* close to the actual solution
        # when c_nrm = c_now FPI provides a nice solution (c_now - c_opt is small)
        # when c_nrm = c_next FPI sometimes breaks and (c_next - c_opt is large)
        for ai in range(self.aNrmGrid.size):
            c_nrm = c_now[ai]
            a_nrm = self.aNrmGrid[ai]
            # these should be close to zero at the optimal value
            # but below we are testing their value at the initial guess
            val1 = first_order_condition(c_nrm, a_nrm) - c_nrm
            val2 = first_order_condition_alt(c_nrm, a_nrm) - c_nrm
            val3 = first_order_condition_other(c_nrm, a_nrm) - c_nrm
            try:
                sol = fixed_point(first_order_condition_other, c_nrm, args=(a_nrm,),)
            except:
                sol = c_nrm
            c_opt[ai] = sol

        return c_opt

    def optimize_consumption_root(self):

        self.optimize_risky_share(how="root")

        self.mNrmGrid = self.aXtraGrid

        def objective_func(c_nrm, m_nrm):
            a_nrm = m_nrm - c_nrm
            return (
                self.uPc(c_nrm, a_nrm)
                - self.uPa(c_nrm, a_nrm)
                - self.EndOfPrdvPfunc(a_nrm)
            )

        # use as first guess the next period's solution
        c_opt = self.solution_next.cFunc(self.mNrmGrid)

        for mi in range(self.aNrmGrid.size):
            m_nrm = self.mNrmGrid[mi]
            sol = root(objective_func, c_opt[mi], args=(m_nrm,))
            c_opt[mi] = sol.x[0]

        return c_opt

    def make_basic_solution(self):
        """
        Given end of period assets and end of period marginal values, construct
        the basic solution for this period.
        """

        cNrm = self.optimize_consumption_root()
        cNrm_temp = np.append(0.0, cNrm)
        mNrmGrid_temp = np.append(0.0, self.mNrmGrid)
        self.cFunc = LinearInterp(mNrmGrid_temp, cNrm_temp)
        self.cFuncEnd = LinearInterp(mNrmGrid_temp - cNrm_temp, cNrm_temp)

        # to debug, uncomment line below and set debug points
        # cNrm_other = self.optimize_consumption_fixed_point(cNrm, self.mNrmGrid)

        # self.cAltFunc = LinearInterp(mNrmGrid_temp, np.append(0.0, cNrm_alt))

        # vNrmNvrs = self.uinv(vNrm)
        # vNrmNvrs_temp = np.insert(vNrmNvrs, 0, 0, axis=0)
        # vNrmNvrsFunc = LinearInterp(mNrmGrid_temp, vNrmNvrs_temp)
        # self.vFunc = ValueFuncCRRA(vNrmNvrsFunc, self.CRRA)

        aNrm = self.mNrmGrid - cNrm
        vP = self.uPa(cNrm, aNrm) + self.EndOfPrdvPfunc(aNrm)
        vPnvrs = self.uPinv(vP)
        vPnvrs_temp = np.append(0.0, vPnvrs)
        vPnvrsFunc = LinearInterp(mNrmGrid_temp, vPnvrs_temp)
        self.vPfunc = MargValueFuncCRRA(vPnvrsFunc, self.CRRA)

    def make_ShareFuncAdj(self):

        if self.zero_bound:
            self.shareFuncEndOfPrd = LinearInterp(
                np.append(0.0, self.aNrmGrid),
                np.append(1.0, self.Share_now),
                intercept_limit=self.ShareLimit,
                slope_limit=0.0,
            )
        else:
            self.shareFuncEndOfPrd = LinearInterp(
                self.aNrmGrid,
                self.Share_now,
                intercept_limit=self.ShareLimit,
                slope_limit=0.0,
            )

        cNrm = self.cFunc(self.mNrmGrid)
        aNrm = self.mNrmGrid - cNrm
        shares = self.shareFuncEndOfPrd(aNrm)

        self.shareFunc = LinearInterp(
            np.append(0.0, self.mNrmGrid),
            np.append(1.0, shares),
            intercept_limit=self.ShareLimit,
            slope_limit=0.0,
        )

    def make_porfolio_solution(self):

        self.solution = WealthPortfolioSolution(
            cFunc=self.cFunc,
            shareFunc=self.shareFunc,
            # vFunc=self.vFunc,
            vPfunc=self.vPfunc,
            # cFuncEnd=self.cAltFunc,
        )

        self.solution.shareFuncEndOfPrd = self.shareFuncEndOfPrd


init_wealth_portfolio = init_portfolio.copy()
init_wealth_portfolio["TranShkCount"] = 2
init_wealth_portfolio["TranShkStd"] = [0.01]
init_wealth_portfolio["PermShkStd"] = [0.0]
init_wealth_portfolio["UnempPrb"] = 0.0
init_wealth_portfolio["WealthShare"] = 1 / 3

# from TRP specs
init_wealth_portfolio["RiskyAvg"] = 1.0486
init_wealth_portfolio["RiskyStd"] = 0.1375
init_wealth_portfolio["Rfree"] = 1.016
