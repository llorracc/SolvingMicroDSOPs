"""
Specifies the full set of calibrated values required to estimate the SolvingMicroDSOPs
model.  The empirical data is stored in a separate csv file and is loaded in SetupSCFdata.
"""
from __future__ import print_function
import numpy as np
from HARK.Calibration.Income.IncomeTools import parse_income_spec, CGM_income
from HARK.datasets.life_tables.us_ssa.SSATools import parse_ssa_life_table

# ---------------------------------------------------------------------------------
# Debugging flags
# ---------------------------------------------------------------------------------

show_PermGroFacAgg_error = False
# Error Notes:
# This sets a "quick fix" to the error, AttributeError: 'TempConsumerType' object has no attribute 'PermGroFacAgg'
# If you set this flag to "True" you will see the error. A more thorough fix is to
# fix the place where this error was introduced (Set to "True" and it will appear;
# this was almost certainly introduced when the code was extended to be used in the
# GE setting). An even more thorough solution, which moves beyond the scope of
# fixing this error, is adding unit tests to ID when changes to some code will
# break things elsewhere.
# Note: alternatively, decide that the "init_consumer_objects['PermGroFacAgg'] = 1.0"
# line below fixes it properly ('feature not a bug') and remove all this text.

# ---------------------------------------------------------------------------------
# - Define all of the model parameters for SolvingMicroDSOPs and ConsumerExamples -
# ---------------------------------------------------------------------------------

exp_nest = 3  # Number of times to "exponentially nest" when constructing a_grid
aXtraMin = 0.001  # Minimum end-of-period "assets above minimum" value
aXtraMax = 20  # Maximum end-of-period "assets above minimum" value
aXtraHuge = None  # A very large value of assets to add to the grid, not used
aXtraExtra = None  # Some other value of assets to add to the grid, not used
aXtraCount = 8  # Number of points in the grid of "assets above minimum"

BoroCnstArt = 0.0  # Artificial borrowing constraint; imposed minimum level of end-of period assets
CubicBool = (
    True  # Use cubic spline interpolation when True, linear interpolation when False
)
vFuncBool = False  # Whether to calculate the value function during solution

Rfree = 1.03  # Interest factor on assets
PermShkCount = (
    7  # Number of points in discrete approximation to permanent income shocks
)
TranShkCount = (
    7  # Number of points in discrete approximation to transitory income shocks
)
UnempPrb = 0.005  # Probability of unemployment while working
UnempPrbRet = 0.000  # Probability of "unemployment" while retired
IncUnemp = 0.0  # Unemployment benefits replacement rate
IncUnempRet = 0.0  # "Unemployment" benefits when retired

final_age = 90  # Age at which the problem ends (die with certainty)
retirement_age = 65  # Age at which the consumer retires
initial_age = 25  # Age at which the consumer enters the model
TT = final_age - initial_age  # Total number of periods in the model
retirement_t = retirement_age - initial_age - 1

CRRA_start = 4.0  # Initial guess of the coefficient of relative risk aversion during estimation (rho)
DiscFacAdj_start = 0.99  # Initial guess of the adjustment to the discount factor during estimation (beth)
DiscFacAdj_bound = [
    0.0001,
    15.0,
]  # Bounds for beth; if violated, objective function returns "penalty value"
CRRA_bound = [
    0.0001,
    15.0,
]  # Bounds for rho; if violated, objective function returns "penalty value"

# Income
ss_variances = True
income_spec = CGM_income["HS"]
# Replace retirement age
income_spec["age_ret"] = retirement_age
inc_calib = parse_income_spec(
    age_min=initial_age, age_max=final_age, **income_spec, SabelhausSong=ss_variances
)

# Age-varying discount factors over the lifecycle, lifted from Cagetti (2003)
DiscFac_timevary = [
    1.064914,
    1.057997,
    1.051422,
    1.045179,
    1.039259,
    1.033653,
    1.028352,
    1.023348,
    1.018632,
    1.014198,
    1.010037,
    1.006143,
    1.002509,
    0.9991282,
    0.9959943,
    0.9931012,
    0.9904431,
    0.9880143,
    0.9858095,
    0.9838233,
    0.9820506,
    0.9804866,
    0.9791264,
    0.9779656,
    0.9769995,
    0.9762239,
    0.9756346,
    0.9752274,
    0.9749984,
    0.9749437,
    0.9750595,
    0.9753422,
    0.9757881,
    0.9763936,
    0.9771553,
    0.9780698,
    0.9791338,
    0.9803439,
    0.981697,
    0.8287214,
    0.9902111,
    0.9902111,
    0.9902111,
    0.9902111,
    0.9902111,
    0.9902111,
    0.9902111,
    0.9902111,
    0.9902111,
    0.9902111,
    0.9902111,
    0.9902111,
    0.9902111,
    0.9902111,
    0.9902111,
    0.9902111,
    0.9902111,
    0.9902111,
    0.9902111,
    0.9902111,
    0.9902111,
    0.9902111,
    0.9902111,
    0.9902111,
    0.9902111,
]

# Survival probabilities over the lifecycle
liv_prb = parse_ssa_life_table(
    female=False, min_age=initial_age, max_age=final_age - 1, cohort=1960
)

# Age groups for the estimation: calculate average wealth-to-permanent income ratio
# for consumers within each of these age groups, compare actual to simulated data
empirical_cohort_age_groups = [
    [26, 27, 28, 29, 30],
    [31, 32, 33, 34, 35],
    [36, 37, 38, 39, 40],
    [41, 42, 43, 44, 45],
    [46, 47, 48, 49, 50],
    [51, 52, 53, 54, 55],
    [56, 57, 58, 59, 60],
]

initial_wealth_income_ratio_vals = np.array(
    [0.17, 0.5, 0.83]
)  # Three point discrete distribution of initial w
initial_wealth_income_ratio_probs = np.array(
    [0.33333, 0.33333, 0.33334]
)  # Equiprobable discrete distribution of initial w
num_agents = 10000  # Number of agents to simulate
bootstrap_size = 50  # Number of re-estimations to do during bootstrap
seed = 31382  # Just an integer to seed the estimation

# -----------------------------------------------------------------------------
# -- Set up the dictionary "container" for making a basic lifecycle type ------
# -----------------------------------------------------------------------------

# Dictionary that can be passed to ConsumerType to instantiate
init_consumer_objects = {
    "CRRA": CRRA_start,
    "Rfree": Rfree,
    "PermGroFac": inc_calib["PermGroFac"],
    "BoroCnstArt": BoroCnstArt,
    "PermShkStd": inc_calib["PermShkStd"],
    "PermShkCount": PermShkCount,
    "TranShkStd": inc_calib["TranShkStd"],
    "TranShkCount": TranShkCount,
    "T_cycle": TT,
    "UnempPrb": UnempPrb,
    "UnempPrbRet": UnempPrbRet,
    "T_retire": retirement_t,
    "T_age": TT + 1,
    "IncUnemp": IncUnemp,
    "IncUnempRet": IncUnempRet,
    "aXtraMin": aXtraMin,
    "aXtraMax": aXtraMax,
    "aXtraCount": aXtraCount,
    "aXtraExtra": [aXtraExtra, aXtraHuge],
    "aXtraNestFac": exp_nest,
    "LivPrb": liv_prb,
    "DiscFac": DiscFac_timevary,
    "AgentCount": num_agents,
    "seed": seed,
    "tax_rate": 0.0,
    "vFuncBool": vFuncBool,
    "CubicBool": CubicBool,
}

if show_PermGroFacAgg_error:
    pass  # do nothing
else:
    print(
        "***NOTE: using a 'quick fix' for an attribute error. See 'Error Notes' in EstimationParameter.py for further discussion.***"
    )
    init_consumer_objects["PermGroFacAgg"] = 1.0


if __name__ == "__main__":
    print("Sorry, EstimationParameters doesn't actually do anything on its own.")
    print("This module is imported by StructEstimation, providing calibrated ")
    print("parameters for the example estimation.  Please see that module if you ")
    print("want more interesting output.")
