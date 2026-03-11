# Solution container classes for the backward-induction solution structure.
#
# These classes mirror the LaTeX notation from SolvingMicroDSOPs:
#
#   Full:         S[t].stg['cFunc'].prch['cntn'].v(a)
#   Abbreviated:  S[t]['cFunc']['cntn'].v(a)
#   Math:         \mathcal{S}[\prd][\cFunc][\cntn].\vFunc(a)
#
# Hierarchy:
#   Pile  -->  PeriodSolution  -->  Stage  -->  Perch
#
# Pile is built by backward induction:
#   pile = Pile(params, connector)
#   pile.add(T, terminal_solution)
#   pile.add(T-1, solve_one_period(...))
#   ...
#
# Within each PeriodSolution, stages are stored in a dict (keyed by name)
# and also in an ordered list (for sequential iteration).
#
# Within each Stage, perches are stored in a dict (keyed by name: 'arvl',
# 'dcsn', 'cntn').
#
# Each Perch holds the functions defined at that point in the stage:
# v (value), c (consumption/decision rule), vδ (marginal value), etc.

from dataclasses import dataclass, field
from typing import Callable, Dict, Optional
import numpy as np


# ---------------------------------------------------------------------------
# Value-function transformation utilities (analogous to the consumed-function
# transformation for marginal value, but applied to the level of v).
#
# For CRRA utility u(c) = c^{1-rho}/(1-rho), the value function is
# approximately v(m) ~ u(c*(m)).  Applying the inverse:
#     vinv(v) = ((1-rho)*v)^{1/(1-rho)}
# recovers something close to c*(m), which is nearly linear.
# Interpolating vinv and inverting gives far fewer kinks than
# interpolating v directly.
# ---------------------------------------------------------------------------

def v_to_vinv(v, rho):
    """Transform value function to nearly-linear inverse-utility space."""
    v = np.asarray(v, dtype=float)
    if rho == 1.0:
        return np.exp(v)
    arg = (1.0 - rho) * v
    return np.maximum(arg, 1e-300) ** (1.0 / (1.0 - rho))


def vinv_to_v(vP, rho):
    """Recover value function from inverse-utility space."""
    vP = np.asarray(vP, dtype=float)
    if rho == 1.0:
        return np.log(np.maximum(vP, 1e-300))
    return np.maximum(vP, 1e-300) ** (1.0 - rho) / (1.0 - rho)


# ---------------------------------------------------------------------------
# ModelParams: frozen parameter set for the normalized consumption-savings
# ---------------------------------------------------------------------------

@dataclass(frozen=True)
class ModelParams:
    """Structural parameters for the normalized consumption-savings model.

    Corresponds to the parameter table in the context bundle:
        beta (DiscFac), rho (CRRA), R (Rfree), Gamma (PermGroFac),
        sigma (std dev of log transitory shock), n_shocks (quadrature points).

    Portfolio parameters (Multiple Control Variables):
        equity_premium, sigma_risky, n_risky.
    """
    DiscFac: float = 0.96
    CRRA: float = 2.0
    Rfree: float = 1.03
    PermGroFac: float = 1.0
    sigma: float = 0.1
    n_shocks: int = 7
    a_grid_size: int = 100
    a_max: float = 40.0
    tol: float = 1e-8
    max_iter: int = 1000
    # Portfolio parameters (eq:Rport, eq:shrDecision)
    equity_premium: float = 0.04
    sigma_risky: float = 0.15
    n_risky: int = 7

    @property
    def RNrmByG(self):
        """Normalized return factor R/Gamma (eq:RNrmByG)."""
        return self.Rfree / self.PermGroFac


# ---------------------------------------------------------------------------
# Perch
# ---------------------------------------------------------------------------

class Perch:
    """A named point within a stage that holds functions.

    In the math notation, a perch is the innermost retrieval level:
        S[t]['cFunc']['cntn'].v(a)
                      ^^^^^^
    corresponds to prch['cntn'], and .v is the value function stored there.

    Standard attributes (set freely):
        v   -- value function          (callable or None)
        c   -- consumption rule        (callable or None)
        cδ -- consumed function (vδ)^{-1/rho}, nearly linear (callable or None)
        vδ -- marginal value d(v)/d(state), derived from cδ  (callable or None)
    """

    def __init__(self, name):
        self.name = name

    def __repr__(self):
        attrs = [k for k in vars(self) if k != 'name']
        return f"Perch('{self.name}', funcs={attrs})"


# ---------------------------------------------------------------------------
# Stage
# ---------------------------------------------------------------------------

class Stage:
    """A named collection of perches within a period.

    In the math notation, a stage is the middle retrieval level:
        S[t]['cFunc']['cntn'].v(a)
              ^^^^^^
    corresponds to stg['cFunc'].

    Stages hold their perches in a dict ``prch``, keyed by perch name.
    The standard perch names are 'arvl', 'dcsn', 'cntn'.

    Supports bracket indexing: stage['cntn'] returns the perch.
    """

    def __init__(self, name, perch_names=None):
        self.name = name
        self.prch = {}
        if perch_names is None:
            perch_names = ['arvl', 'dcsn', 'cntn']
        for pname in perch_names:
            self.prch[pname] = Perch(pname)

    def __getitem__(self, key):
        """Allow stage['cntn'] as shorthand for stage.prch['cntn']."""
        return self.prch[key]

    def __repr__(self):
        return f"Stage('{self.name}', perches={list(self.prch.keys())})"


# ---------------------------------------------------------------------------
# PeriodSolution
# ---------------------------------------------------------------------------

class PeriodSolution:
    """The solution for a single period, containing stages.

    In the math notation, a period solution is the outermost retrieval level
    (after the Pile itself):
        S[t]['cFunc']['cntn'].v(a)
         ^^^
    corresponds to S[t], which is a PeriodSolution.

    Stages are stored in a dict ``stg``, keyed by stage name.
    An ordered list ``stg_order`` records the sequence of stages
    (first to last within the period).

    Supports bracket indexing: period['cFunc'] returns the stage.
    """

    def __init__(self, name=None):
        self.name = name
        self.stg = {}
        self.stg_order = []

    def add_stage(self, name, perch_names=None):
        """Add a stage to this period's solution.

        Stages are appended in the order they are added;
        stg_order records this sequence.
        """
        stage = Stage(name, perch_names)
        self.stg[name] = stage
        self.stg_order.append(name)
        return stage

    def __getitem__(self, key):
        """Allow period['cFunc'] as shorthand for period.stg['cFunc']."""
        return self.stg[key]

    def wire(self, from_stage, to_stage):
        """Wire the continuation perch of from_stage to the arrival perch
        of to_stage.  This sets from_stage['cntn'] = to_stage['arvl'],
        implementing the stage-linking equation:

            S[t]['Shr']['cntn'] = S[t]['cFunc']['arvl']

        In math:  [Shr][cntn].v  <==  [cFunc][arvl].v
        """
        src = self.stg[from_stage].prch['cntn']
        dst = self.stg[to_stage].prch['arvl']
        for attr in vars(dst):
            if attr != 'name':
                setattr(src, attr, getattr(dst, attr))

    def __repr__(self):
        return f"PeriodSolution('{self.name}', stages={self.stg_order})"


# ---------------------------------------------------------------------------
# Connector: inter-period transition C(a <-> k)
# ---------------------------------------------------------------------------

@dataclass
class Connector:
    """Inter-period connector: maps cntn-perch of period t to arvl-perch of t+1.

    In this model the connector is the identity on assets:
        k_{t+1} = a_t                              (eq:transitionstate)
    combined with the arrival transition that produces m from k and shocks:
        m_{t+1} = (R/Gamma) * k_{t+1} + theta      (eq:mLvl, normalized)

    The connector also provides backward-pass integration methods that
    compute continuation-perch values from next-period decision-perch values.
    """
    params: ModelParams
    shock_nodes: np.ndarray       # theta_i values, shape (n,)
    shock_weights: np.ndarray     # w_i values,     shape (n,)

    def m_nxt(self, a: np.ndarray) -> np.ndarray:
        """Next-period market resources for each (a, theta) pair.

        m_{t+1} = (R/Gamma) * a + theta             (eq:mLvl normalized)

        Parameters
        ----------
        a : array, shape (J,)

        Returns
        -------
        m : array, shape (J, n_shocks)
        """
        RNrmByG = self.params.RNrmByG
        return RNrmByG * a[:, None] + self.shock_nodes[None, :]

    def natural_borrowing_constraint(self) -> float:
        """a_min = -min(theta) / (R/Gamma).

        The tightest constraint ensuring m >= 0 in all states.
        """
        return -np.min(self.shock_nodes) / self.params.RNrmByG

    # --- backward-pass integration: next dcsn -> this cntn ----------------

    def continuation_value(
        self,
        v_dcsn_nxt: Callable,
        a_grid: np.ndarray,
    ) -> np.ndarray:
        """v_cntn(a) = beta * Gamma^{1-rho} * sum_i w_i * v_dcsn_{t+1}(m'_i).

        (eq:vCntnExpansion / eq:vDiscrete)
        """
        m = self.m_nxt(a_grid)                            # (J, n)
        v_vals = v_dcsn_nxt(m)                            # (J, n)
        p = self.params
        prefactor = p.DiscFac * p.PermGroFac ** (1.0 - p.CRRA)
        return prefactor * v_vals @ self.shock_weights

    def marginal_continuation_value(
        self,
        vδ_dcsn_nxt: Callable,
        a_grid: np.ndarray,
    ) -> np.ndarray:
        """v'_cntn(a) = beta * R * Gamma^{-rho} * sum_i w_i * v'_dcsn_{t+1}(m'_i).

        (eq:vEndδTm1)
        """
        m = self.m_nxt(a_grid)                            # (J, n)
        vδ_vals = vδ_dcsn_nxt(m)                        # (J, n)
        p = self.params
        prefactor = p.DiscFac * p.Rfree * p.PermGroFac ** (-p.CRRA)
        return prefactor * vδ_vals @ self.shock_weights


# ---------------------------------------------------------------------------
# BetweenPeriodConnector: thin rename mapper for the modular architecture
# ---------------------------------------------------------------------------

@dataclass
class BetweenPeriodConnector:
    """Pure rename mapper between periods in the modular stage architecture.

    In the modular design, shock integration and discounting
    move into the portable and disc stages respectively.  The connector
    is reduced to an identity on assets with a variable rename:
        k_{t+1} = a_t           (eq:transitionstate)

    This class provides the rename mapping so that the period builder can
    wire the exit state of one period to the entry state of the next.
    """
    exit_name: str = 'aNrm'
    entry_name: str = 'kNrm'

    def connect(self, exit_val: np.ndarray) -> np.ndarray:
        """Map exit state to entry state (identity in this model)."""
        return exit_val.copy()


# ---------------------------------------------------------------------------
# Pile: the backward-induction accumulator
# ---------------------------------------------------------------------------

class Pile:
    """Backward-induction solution stack (the 'Pile' from SMD notation).

    Stores one PeriodSolution per period, built right-to-left.
    The connector links adjacent periods via C(a <-> k).

    Usage:
        pile = Pile(params, connector)
        pile.add(T, terminal_solution)
        pile.add(T-1, solve_one_period(pile, T-1, params))
        ...
        c_func = pile[t]['cons-with-shocks']['dcsn'].c
    """

    def __init__(self, params: ModelParams, connector: Connector):
        self.params = params
        self.connector = connector
        self._solutions: Dict[int, PeriodSolution] = {}

    def add(self, t: int, sol: PeriodSolution) -> None:
        """Insert a period's solution into the Pile."""
        self._solutions[t] = sol

    def __getitem__(self, t: int) -> PeriodSolution:
        return self._solutions[t]

    def __contains__(self, t: int) -> bool:
        return t in self._solutions

    def __len__(self) -> int:
        return len(self._solutions)

    def periods(self):
        """Return sorted list of solved period indices."""
        return sorted(self._solutions.keys())

    def latest_t(self) -> int:
        """Return the highest period index in the Pile."""
        return max(self._solutions.keys())

    def __repr__(self):
        periods = self.periods()
        return f"Pile(periods={periods})"
