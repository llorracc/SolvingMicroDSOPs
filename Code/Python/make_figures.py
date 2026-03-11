"""Generate publication-quality figures for SolvingMicroDSOPs.

Usage:
    python Code/Python/make_figures.py           # all figures
    python Code/Python/make_figures.py --only PlotCFuncsConverge
"""

import sys
import os
import argparse
import numpy as np

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

from solution import ModelParams
from solve import solve_finite_horizon, make_connector, solve_infinite_horizon
from stages.cons_with_shocks import (
    STAGE_NAME, solve_one_period, make_terminal_solution,
    _utility, _marginal_utility, _inv_marginal_utility, build_a_grid,
)

FIGURES_DIR = os.path.join(
    os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))),
    'Figures',
)

plt.rcParams.update({
    'font.size': 12,
    'axes.labelsize': 14,
    'legend.fontsize': 11,
    'lines.linewidth': 1.5,
    'figure.figsize': (8, 5),
    'savefig.bbox': 'tight',
    'savefig.dpi': 150,
})


def save_fig(name):
    path = os.path.join(FIGURES_DIR, name)
    plt.savefig(path + '.pdf')
    plt.savefig(path + '.png')
    plt.close()
    print(f'  Saved {name}.pdf/.png')


# ======================================================================
# Figure: discreteApprox -- equiprobable approximation to lognormal CDF
# ======================================================================

def fig_discreteApprox():
    """Fig:discreteapprox -- equiprobable discrete approximation to lognormal."""
    from resources import DiscreteApproximationToMeanOneLogNormal
    import scipy.stats as stats

    sigma = 0.1
    mu = -0.5 * sigma**2
    N = 7

    dstn = DiscreteApproximationToMeanOneLogNormal(N, sigma)
    dist = stats.lognorm(sigma, 0, np.exp(mu))

    x = np.linspace(0.7, 1.4, 300)

    fig, ax = plt.subplots()
    ax.plot(x, dist.cdf(x), 'k-', label='True CDF')
    ax.plot(dstn.X, dist.cdf(dstn.X), 'ko', markersize=6, label=f'{N}-point approx')
    for i, xi in enumerate(dstn.X):
        ax.vlines(xi, 0, dist.cdf(xi), colors='gray', linestyles='--', linewidth=0.8)
    ax.set_xlabel(r'$\theta$')
    ax.set_ylabel(r'$F(\theta)$')
    ax.set_title(r'Equiprobable Discrete Approximation to Lognormal $F$')
    ax.legend()
    ax.set_xlim(0.7, 1.4)
    ax.set_ylim(0, 1)
    ax.grid(True, alpha=0.3)
    save_fig('discreteApprox')


# ======================================================================
# Figure: PlotCFuncsConverge -- converging consumption functions
# ======================================================================

def fig_PlotCFuncsConverge():
    """Fig:PlotCFuncsConverge -- consumption functions converging with horizon."""
    params = ModelParams()
    T = 50
    pile = solve_finite_horizon(T, params)

    m = np.linspace(0.5, 5.0, 300)

    fig, ax = plt.subplots()
    for n in [1, 5, 10, 15, 20]:
        t = T - n
        c_func = pile[t][STAGE_NAME]['dcsn'].c
        c_vals = np.array([c_func(mi) for mi in m])
        ax.plot(m, c_vals, label=f'$T - {n}$')

    ax.plot(m, m, 'k:', linewidth=0.8, alpha=0.4, label='45-degree')
    ax.set_xlabel(r'$m$')
    ax.set_ylabel(r'$\mathrm{c}(m)$')
    ax.set_title(r'Converging $\grave{\mathrm{c}}_{T-n}(m)$ as $n$ increases')
    ax.legend()
    ax.grid(True, alpha=0.3)
    save_fig('PlotCFuncsConverge')


# ======================================================================
# Figure: GothVInvVSGothC -- consumed function vs approximation
# ======================================================================

def fig_GothVInvVSGothC():
    """Fig:GothVInvVSGothC -- true consumed function vs piecewise-linear approx."""
    params = ModelParams()
    connector = make_connector(params)
    from solution import Pile
    pile = Pile(params, connector)
    pile.add(1, make_terminal_solution(params))
    sol_Tm1 = solve_one_period(pile, 0)

    a_min = connector.natural_borrowing_constraint()
    a_fine = np.linspace(a_min + 0.001, 4.0, 500)

    vδ_nxt = pile[1][STAGE_NAME]['dcsn'].vδ
    vδ_cntn_fine = connector.marginal_continuation_value(vδ_nxt, a_fine)
    c_cntn_true = _inv_marginal_utility(vδ_cntn_fine, params.CRRA)

    c_cntn_approx_func = sol_Tm1[STAGE_NAME]['cntn'].vδ
    if c_cntn_approx_func is not None:
        vδ_approx = c_cntn_approx_func(a_fine)
        c_cntn_approx = _inv_marginal_utility(vδ_approx, params.CRRA)
    else:
        c_cntn_approx = c_cntn_true

    fig, ax = plt.subplots()
    ax.plot(a_fine, c_cntn_true, 'k-', label=r'True $\mathrm{c}_{\succ}(a)$')
    ax.plot(a_fine, c_cntn_approx, 'k--', label=r'$\grave{\mathrm{c}}_{\succ}(a)$')
    ax.set_xlabel(r'$a$')
    ax.set_ylabel(r'$\mathrm{c}_{\succ}(a)$')
    ax.set_title(r'True $\mathrm{c}_{\succ,T-1}(a)$ vs $\grave{\mathrm{c}}_{\succ,T-1}(a)$')
    ax.legend()
    ax.grid(True, alpha=0.3)
    save_fig('GothVInvVSGothC')


# ======================================================================
# Figure: PlotComparecTm1AD -- EGM consumption function at T-1
# ======================================================================

def fig_PlotComparecTm1AD():
    """Fig:ComparecTm1AD -- true cFunc T-1 vs EGM approximation."""
    params = ModelParams()
    connector = make_connector(params)
    from solution import Pile
    pile = Pile(params, connector)
    pile.add(1, make_terminal_solution(params))
    sol_Tm1 = solve_one_period(pile, 0)

    m = np.linspace(0.5, 5.0, 500)
    c_egm = np.array([sol_Tm1[STAGE_NAME]['dcsn'].c(mi) for mi in m])

    # "True" = high-resolution version (same EGM with finer grid)
    params_fine = ModelParams(a_grid_size=500)
    connector_fine = make_connector(params_fine)
    pile_fine = Pile(params_fine, connector_fine)
    pile_fine.add(1, make_terminal_solution(params_fine))
    sol_fine = solve_one_period(pile_fine, 0)
    c_true = np.array([sol_fine[STAGE_NAME]['dcsn'].c(mi) for mi in m])

    fig, ax = plt.subplots()
    ax.plot(m, c_true, 'k-', label=r'$\mathrm{c}_{T-1}(m)$ (fine grid)')
    ax.plot(m, c_egm, 'k--', label=r'$\grave{\mathrm{c}}_{T-1}(m)$ (EGM)')
    ax.set_xlabel(r'$m$')
    ax.set_ylabel(r'$\mathrm{c}$')
    ax.set_title(r'$\mathrm{c}_{T-1}(m)$ (solid) vs $\grave{\mathrm{c}}_{T-1}(m)$ (dashed)')
    ax.legend()
    ax.grid(True, alpha=0.3)
    save_fig('PlotComparecTm1AD')


# ======================================================================
# Main
# ======================================================================

FIGURE_REGISTRY = {
    'discreteApprox': fig_discreteApprox,
    'PlotCFuncsConverge': fig_PlotCFuncsConverge,
    'GothVInvVSGothC': fig_GothVInvVSGothC,
    'PlotComparecTm1AD': fig_PlotComparecTm1AD,
}

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Generate SolvingMicroDSOPs figures')
    parser.add_argument('--only', type=str, default=None,
                        help='Generate only this figure')
    args = parser.parse_args()

    os.makedirs(FIGURES_DIR, exist_ok=True)

    if args.only:
        if args.only not in FIGURE_REGISTRY:
            print(f"Unknown figure '{args.only}'. Available: {list(FIGURE_REGISTRY.keys())}")
            sys.exit(1)
        print(f'Generating {args.only} ...')
        FIGURE_REGISTRY[args.only]()
    else:
        for name, func in FIGURE_REGISTRY.items():
            print(f'Generating {name} ...')
            func()

    print('Done.')
