"""Discounting stage for the modular period architecture.

The disc stage applies the time-preference discount factor and the
permanent-income normalization to the between-period continuation value.
It has no control variable -- it is a pure value transformation.

    v_disc(x) = beta * Gamma^{1-rho} * v_cntn(x)       (eq:trns-single-prd)
    v'_disc(x) = beta * Gamma^{1-rho} * v'_cntn(x)    (same prefactor)

The disc stage is a pure scalar multiplication -- the state x passes
through unchanged.  The R/Gamma chain-rule factor that appears in the
old Connector.marginal_continuation_value belongs in the portable stage
(from d(mCheck)/dk = Rport/Gamma), not here.
"""

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from solution import ModelParams, Stage


STAGE_NAME = 'disc'


def solve_disc(v_cntn, cδ_cntn, params: ModelParams) -> Stage:
    """Solve the discounting stage.

    Parameters
    ----------
    v_cntn : callable
        Continuation value function from the between-period connector
        (the *next* period's arrival value).
    cδ_cntn : callable
        Consumed function (inverse marginal value) from the between-period
        connector: cδ(x) = (v'(x))^{-1/rho}.
    params : ModelParams

    Returns
    -------
    Stage
        With arvl and dcsn perches populated (they are identical since
        there is no decision in this stage).
    """
    beta = params.DiscFac
    Gamma = params.PermGroFac
    rho = params.CRRA

    prefactor = beta * Gamma ** (1.0 - rho)
    cδ_prefactor = prefactor ** (-1.0 / rho)

    def v_disc(x):
        return prefactor * v_cntn(x)

    def cδ_disc(x):
        return cδ_prefactor * cδ_cntn(x)

    def vδ_disc(x):
        return cδ_disc(x) ** (-rho)

    stg = Stage(STAGE_NAME)
    stg['cntn'].v = v_cntn
    stg['cntn'].cδ = cδ_cntn
    stg['dcsn'].v = v_disc
    stg['dcsn'].vδ = vδ_disc
    stg['dcsn'].cδ = cδ_disc
    stg['arvl'].v = v_disc
    stg['arvl'].vδ = vδ_disc
    stg['arvl'].cδ = cδ_disc

    return stg
