"""Calibration parameters and distribution constructors for SolvingMicroDSOPs.ipynb.

Centralizes the parameter definitions that were scattered across
multiple notebook cells, keeping the notebook focused on the math.
"""

import numpy as np
import scipy.stats as stats
from numpy import log, exp

from Code.Python.resources import (
    Utility,
    DiscreteApproximation,
    DiscreteApproximationTwoIndependentDistribs,
)


def base_params():
    """Baseline structural parameters (consumption-only problem).

    Returns dict with keys: rho, beta, Gamma, R, u, theta_sigma, theta_grid_N.
    """
    rho = 2.0
    beta = 0.96
    Gamma = np.array([1.0])
    R = 1.02
    u = Utility(rho)
    return dict(rho=rho, beta=beta, Gamma=Gamma, R=R, u=u,
                theta_sigma=0.5, theta_grid_N=7)


def make_income_distribution(sigma=0.5, N=7):
    """Discretised mean-one lognormal transitory income shock.

    Returns a DiscreteApproximation instance.
    """
    mu = -0.5 * sigma ** 2
    z = stats.lognorm(sigma, 0, np.exp(mu))
    return DiscreteApproximation(N=N, cdf=z.cdf, pdf=z.pdf, invcdf=z.ppf)


def natural_borrowing_constraint(theta, Gamma, R):
    """a_min = -min(theta) * Gamma / R  (eq:NatBoroCnstra)."""
    return -min(theta.X) * Gamma[0] / R


def portfolio_params(R=1.02):
    """Portfolio-choice parameters (EndOfPrdMC / port-cons).

    Returns dict with keys: rho_port, theta_sigma_port, RiskyR_sigma,
    RiskyR_grid_N, phi, a_max, a_grid_size.
    """
    return dict(
        rho_port=6.0,
        theta_sigma_port=0.15,
        RiskyR_sigma=0.15,
        RiskyR_grid_N=7,
        phi=0.02,
        a_max=100.0,
        a_grid_size=800,
    )


def make_portfolio_distribution(R, theta_sigma_port=0.15, theta_grid_N=7,
                                RiskyR_sigma=0.15, RiskyR_grid_N=7, phi=0.02):
    """Joint (income, risky-return) distribution for portfolio choice.

    Returns a DiscreteApproximationTwoIndependentDistribs instance.
    """
    theta_mu_port = -0.5 * theta_sigma_port ** 2
    theta_z_port = stats.lognorm(s=theta_sigma_port, scale=exp(theta_mu_port))

    RiskyR_mu = R + phi
    mu = np.log(RiskyR_mu ** 2 / np.sqrt(RiskyR_sigma ** 2 + RiskyR_mu ** 2))
    sigma = np.sqrt(np.log(RiskyR_sigma ** 2 / RiskyR_mu ** 2 + 1))
    RiskyR_z = stats.lognorm(s=sigma, scale=np.exp(mu))

    return DiscreteApproximationTwoIndependentDistribs(
        theta_grid_N, theta_z_port.cdf, theta_z_port.pdf, theta_z_port.ppf,
        RiskyR_grid_N, RiskyR_z.cdf, RiskyR_z.pdf, RiskyR_z.ppf,
    )
