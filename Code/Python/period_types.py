"""Period builder: compose modular stages into the four period types.

The period types from the Multiple Control Variables treatment in SolvingMicroDSOPs:

  period-cons-only:  portable(bar_Shr=0) -> cons-noshocks -> disc
  period-port-cons:  portable(optimize)  -> cons-noshocks -> disc
  period-cons-port:  cons-noshocks -> portable(optimize) -> disc
  period-port-only:  portable(optimize) -> disc

Each period type is represented as a PeriodSpec, which records the ordered
list of stages and configuration needed to compose them.

The solve_period() function takes a PeriodSpec plus the between-period
continuation values and returns a solved PeriodSolution.
"""

from dataclasses import dataclass, field
from typing import Optional, List, Dict
import numpy as np

import sys
import os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from solution import ModelParams, PeriodSolution
from stages.disc import solve_disc
from stages.cons_noshocks import solve_cons_noshocks, build_a_grid
from stages.portable import solve_portable, make_shock_distribution


# ---------------------------------------------------------------------------
# PeriodSpec: declarative description of a period type
# ---------------------------------------------------------------------------

@dataclass
class PeriodSpec:
    name: str
    stage_names: List[str]
    bar_Shr: Optional[float] = None  # None = optimize, 0.0 = shocks-only

    def __repr__(self):
        return f"PeriodSpec('{self.name}', stages={self.stage_names}, bar_Shr={self.bar_Shr})"


PERIOD_CONS_ONLY = PeriodSpec(
    'cons-only',
    ['portable', 'cons-noshocks', 'disc'],
    bar_Shr=0.0,
)

PERIOD_PORT_CONS = PeriodSpec(
    'port-cons',
    ['portable', 'cons-noshocks', 'disc'],
    bar_Shr=None,
)

PERIOD_CONS_PORT = PeriodSpec(
    'cons-port',
    ['cons-noshocks', 'portable', 'disc'],
    bar_Shr=None,
)


# ---------------------------------------------------------------------------
# Terminal period
# ---------------------------------------------------------------------------

def make_terminal_solution(params: ModelParams) -> PeriodSolution:
    """Terminal period: v_T(m) = u(m), c_T(m) = m.

    The terminal solution is stage-agnostic -- we store it under a
    generic 'terminal' stage so that the modular solver can retrieve
    decision-perch functions regardless of period type.
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
    stg = sol.add_stage('terminal')
    stg['dcsn'].c = c_terminal
    stg['dcsn'].v = v_terminal
    stg['dcsn'].vδ = vδ_terminal
    stg['dcsn'].cδ = c_terminal       # cδ_T(m) = (u'(m))^{-1/rho} = m
    stg['arvl'].c = c_terminal
    stg['arvl'].v = v_terminal
    stg['arvl'].vδ = vδ_terminal
    stg['arvl'].cδ = c_terminal

    return sol


def _utility(c, rho):
    if rho == 1.0:
        return np.log(np.maximum(c, 1e-300))
    return np.maximum(c, 1e-300) ** (1.0 - rho) / (1.0 - rho)


def _marginal_utility(c, rho):
    return np.maximum(c, 1e-300) ** (-rho)


def wrap_terminal_with_portable(terminal: PeriodSolution,
                                period_spec: PeriodSpec,
                                params: ModelParams,
                                shock_dstn: dict) -> PeriodSolution:
    """Wrap a raw terminal solution with a portable stage.

    The terminal period's entry value must include shock integration so
    that the preceding period's disc stage receives the correct continuation.
    Without this, the first backward step would miss E[v_T((R/G)*k + theta)].

    For solved (non-terminal) periods, shock integration is already present
    in the portable stage, so this is only needed for the terminal.
    """
    v_raw = terminal['terminal']['dcsn'].v
    cδ_raw = terminal['terminal']['dcsn'].cδ

    k_grid = build_a_grid(1e-10, params.a_max, params.a_grid_size)
    port_stg = solve_portable(
        v_raw, cδ_raw, params, shock_dstn,
        k_grid=k_grid, bar_Shr=period_spec.bar_Shr)

    wrapped = PeriodSolution(name='T')
    wrapped.stg['portable'] = port_stg
    wrapped.stg_order.append('portable')
    wrapped.stg['terminal'] = terminal['terminal']
    wrapped.stg_order.append('terminal')

    return wrapped


# ---------------------------------------------------------------------------
# Period solver: compose stages right-to-left
# ---------------------------------------------------------------------------

def _get_dcsn_funcs(period_sol: PeriodSolution):
    """Extract entry-point v and cδ from the first stage in the period.

    For solved periods (and wrapped terminals), the first stage is portable,
    whose arrival perch carries the shock-integrated entry value.
    Returns (v, cδ) where cδ is the consumed function (inverse marginal value).
    """
    first_stage_name = period_sol.stg_order[0]
    dcsn = period_sol[first_stage_name]['arvl']
    return dcsn.v, dcsn.cδ


def solve_period(period_spec: PeriodSpec,
                 v_nxt_dcsn, cδ_nxt_dcsn,
                 params: ModelParams,
                 shock_dstn: dict = None) -> PeriodSolution:
    """Solve one period by composing stages right-to-left.

    Parameters
    ----------
    period_spec : PeriodSpec
    v_nxt_dcsn : callable
        Value function from the next period's decision perch (already
        discounted if this is a between-period link, or raw terminal).
    cδ_nxt_dcsn : callable
        Consumed function (inverse marginal value) from the next period.
    params : ModelParams
    shock_dstn : dict, optional
        Shock distribution for the portable stage.  Built if not supplied.

    Returns
    -------
    PeriodSolution
        With all stages populated.
    """
    if shock_dstn is None:
        shock_dstn = make_shock_distribution(params)

    stages = period_spec.stage_names
    sol = PeriodSolution(name=period_spec.name)

    # We solve right-to-left.  The rightmost stage (disc) receives the
    # between-period continuation.  Each preceding stage receives the
    # arrival-perch functions of the stage to its right.
    v_cntn = v_nxt_dcsn
    cδ_cntn = cδ_nxt_dcsn

    solved_stages = {}

    for stage_name in reversed(stages):
        if stage_name == 'disc':
            stg = solve_disc(v_cntn, cδ_cntn, params)

        elif stage_name == 'cons-noshocks':
            a_min = _compute_a_min_for_cons(params, shock_dstn, period_spec)
            stg = solve_cons_noshocks(v_cntn, cδ_cntn, params, a_min=a_min)

        elif stage_name == 'portable':
            k_grid = build_a_grid(1e-10, params.a_max, params.a_grid_size)
            stg = solve_portable(
                v_cntn, cδ_cntn, params, shock_dstn,
                k_grid=k_grid, bar_Shr=period_spec.bar_Shr)

        else:
            raise ValueError(f"Unknown stage: {stage_name}")

        solved_stages[stage_name] = stg
        v_cntn = stg['arvl'].v
        cδ_cntn = stg['arvl'].cδ

    # Add stages to PeriodSolution in left-to-right order
    for stage_name in stages:
        stg = solved_stages[stage_name]
        sol.stg[stage_name] = stg
        sol.stg_order.append(stage_name)

    return sol


def _compute_a_min_for_cons(params, shock_dstn, period_spec):
    """Natural borrowing constraint for the cons-noshocks stage.

    When cons-noshocks is first in the pipeline (cons-port), the borrowing
    constraint is determined by the minimum post-shock market resources.
    When it follows portable, the a_min comes from the minimum mCheck.
    """
    theta_min = np.min(shock_dstn['theta_nodes'])
    RNrmByG = params.Rfree / params.PermGroFac

    stages = period_spec.stage_names
    cons_idx = stages.index('cons-noshocks')

    if cons_idx == 0:
        # cons-noshocks is the entry stage -- borrowing constraint from
        # the between-period connector
        return -theta_min / RNrmByG
    else:
        # cons-noshocks follows portable -- the portable stage already
        # integrates shocks, so a_min is just 0 (no additional constraint
        # beyond non-negativity of assets).
        return 0.0
