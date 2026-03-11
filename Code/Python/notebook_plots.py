"""
Plotting utilities for SolvingMicroDSOPs.ipynb.

Each function produces one figure from precomputed data,
keeping the notebook focused on the substantive content.

Notation (matching local-macros.sty):
    ≺  (\\prec)  = arrival perch     \\arvl
    ~  (\\sim)   = decision perch    \\dcsn
    ≻  (\\succ)  = continuation perch \\cntn
    ∂  (\\partial) superscript = derivative w.r.t. perch state
    \\grave{·}  = interpolated approximation
"""

import os
import matplotlib.pyplot as plt
import numpy as np

_REPO_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
FIGURES_DIR = os.path.join(_REPO_ROOT, "Figures")


def save_fig(name):
    """Save current figure to Figures/<name> in pdf, png, jpg, and svg.

    Does nothing when *name* is None or an empty string so callers can
    unconditionally pass ``save_as=...`` without branching.
    """
    if not name:
        return
    os.makedirs(FIGURES_DIR, exist_ok=True)
    path = os.path.join(FIGURES_DIR, name)
    for ext in ("pdf", "png", "jpg", "svg"):
        plt.savefig(path + "." + ext)


# ─────────────────────────────────────────────────────────
# Value Function Maximization
# ─────────────────────────────────────────────────────────

def plot_consumption_Tm1(mVec, cVec, save_as=None):
    """Figure: c_{T-1}(m) from brute-force value function maximization."""
    plt.plot(mVec, cVec, "k-")
    plt.title(r"$\mathrm{c}_{T-1}(m_{T-1})$ (solid)")
    plt.xlabel(r"$m_{T-1}$")
    plt.ylabel(r"$\mathrm{c}(m_{T-1})$")
    save_fig(save_as)


def plot_c_exact_vs_approx(mVec_exact, cVec_exact, mVec_approx, cVec_approx,
                                  xlim_lo=None, save_as=None):
    """Exact c_{T-1} versus interpolated approximation.

    LaTeX figure: PlotcTm1Simple
    """
    plt.plot(mVec_exact, cVec_exact, "k-")
    plt.plot(mVec_approx, cVec_approx, "--")
    if xlim_lo is not None:
        plt.xlim(xlim_lo, 4.0)
    plt.xlabel(r"$m_{T-1}$")
    plt.ylabel(r"$\mathrm{c}(m_{T-1})$")
    plt.title(
        r"$\mathrm{c}_{T-1}(m_{T-1})$ (solid) versus "
        r"$\grave{\mathrm{c}}_{T-1}(m_{T-1})$ (dashed)"
    )
    save_fig(save_as)


def plot_v_exact_vs_approx(mVec_exact, vVec_exact, mVec_approx, vVec_approx,
                                  xlim_lo=None, save_as=None):
    """Exact v_{T-1} versus interpolated approximation.

    LaTeX figure: PlotVTm1Simple
    """
    plt.plot(mVec_exact, vVec_exact, "k-")
    plt.plot(mVec_approx, vVec_approx, "--")
    if xlim_lo is not None:
        plt.xlim(xlim_lo, 4.0)
    plt.xlabel(r"$m_{T-1}$")
    plt.ylabel(r"$\mathrm{v}_{\sim,T-1}$")
    plt.title(
        r"$\mathrm{v}_{\sim,T-1}(m_{T-1})$ (solid) versus "
        r"$\grave{\mathrm{v}}_{\sim,T-1}(m_{T-1})$ (dashed)"
    )
    save_fig(save_as)


# ─────────────────────────────────────────────────────────
# Interpolating Expectations
# ─────────────────────────────────────────────────────────

def plot_vEndPrd_exact_vs_approx(aVec_exact, vEndPrd_exact,
                                        aVec_approx, vEndPrd_approx,
                                        save_as=None):
    """Continuation value exact versus approximation.

    LaTeX figure: PlotOTm1RawVSInt
    """
    plt.plot(aVec_exact, vEndPrd_exact, "k-")
    plt.plot(aVec_approx, vEndPrd_approx, "--")
    plt.xlabel(r"$a_{T-1}$")
    plt.ylabel(r"$\mathrm{v}_{\succ,T-1}$")
    plt.title(
        r"Continuation value $\mathrm{v}_{\succ,T-1}(a_{T-1})$ (solid) "
        r"versus $\grave{\mathrm{v}}_{\succ,T-1}(a_{T-1})$ (dashed)"
    )
    save_fig(save_as)


def plot_vCntnδ_exact_vs_approx(aVec_exact, vp_exact, aVec_approx, vp_approx,
                                  save_as=None):
    """Marginal continuation value exact versus piecewise-linear approximation.

    Parameters
    ----------
    aVec_exact : array
        Fine grid of a for plotting the exact curve.
    vp_exact : array
        Exact marginal continuation values at aVec_exact.
    aVec_approx : array
        Grid of a used to build the piecewise-linear approximation.
    vp_approx : array
        Approximate marginal values at aVec_approx.
    """
    plt.plot(
        aVec_exact, vp_exact, "k-",
        label=r"$\mathrm{v}^{\partial}_{\succ,T-1}(a_{T-1})$ exact"
    )
    plt.plot(
        aVec_approx, vp_approx, "--",
        label=r"$\grave{\mathrm{v}}^{\partial}_{\succ,T-1}(a_{T-1})$ approx"
    )
    plt.ylim(0.0, 1.0)
    plt.xlabel(r"$a_{T-1}$")
    plt.ylabel(r"$\mathrm{v}^{\partial}_{\succ,T-1}$")
    plt.title(
        r"Marginal continuation value $\mathrm{v}^{\partial}_{\succ,T-1}$ (solid) "
        r"versus $\grave{\mathrm{v}}^{\partial}_{\succ,T-1}$ (dashed)"
    )
    plt.legend(loc="best")
    save_fig(save_as)


def plot_c_from_vEndPrd(mVec_exact, cVec_exact, mVec_approx, cVec_approx,
                        save_as=None):
    """c_{T-1} exact versus from interpolated continuation value.

    LaTeX figure: PlotComparecTm1AB
    """
    plt.plot(mVec_exact, cVec_exact, "k-")
    plt.plot(mVec_approx, cVec_approx, "--")
    plt.xlabel(r"$m_{T-1}$")
    plt.ylabel(r"$\mathrm{c}_{T-1}$")
    plt.title(
        r"$\mathrm{c}_{T-1}(m_{T-1})$ (solid) versus "
        r"$\grave{\mathrm{c}}_{T-1}(m_{T-1})$ (dashed)"
    )
    save_fig(save_as)


# ─────────────────────────────────────────────────────────
# Plot_ud_VS_vCntnd — u^{\partial}(c) versus marginal continuation values
# ─────────────────────────────────────────────────────────

def plot_uδ_vs_vCntnδ(uδ_vs_vCntnδ_data, save_as=None):
    """\mathrm{u}^{\partial}(\mathrm{c}) versus exact and interpolated marginal continuation values.

    LaTeX figure: Plot_ud_VS_vCntnd

    Parameters
    ----------
    uδ_vs_vCntnδ_data : dict returned by notebook_solvers.compute_uδ_vs_vCntnδ_data()
    """
    c_m3, c_m4 = uδ_vs_vCntnδ_data['c_m3'], uδ_vs_vCntnδ_data['c_m4']

    plt.plot(c_m4, uδ_vs_vCntnδ_data['uδ'], 'k-', linewidth=2.5,
             label=r"$\mathrm{u}^{\partial}(\mathrm{c}_{T-1})$")

    plt.plot(c_m3, uδ_vs_vCntnδ_data['vp_exact_m3'], color='tab:blue', linewidth=1.5,
             label=r"$\mathrm{v}^{\partial}_{\succ}(3 - \mathrm{c})$ exact")
    plt.plot(c_m3, uδ_vs_vCntnδ_data['vp_hat_m3'], color='tab:blue', linewidth=1,
             linestyle='--', label=r"$\grave{\mathrm{v}}^{\partial}_{\succ}(3 - \mathrm{c})$ interp")

    plt.plot(c_m4, uδ_vs_vCntnδ_data['vp_exact_m4'], color='tab:orange', linewidth=1.5,
             label=r"$\mathrm{v}^{\partial}_{\succ}(4 - \mathrm{c})$ exact")
    plt.plot(c_m4, uδ_vs_vCntnδ_data['vp_hat_m4'], color='tab:orange', linewidth=1,
             linestyle='--', label=r"$\grave{\mathrm{v}}^{\partial}_{\succ}(4 - \mathrm{c})$ interp")

    plt.xlim(0, 4)
    plt.ylim(0, 0.8)
    plt.xlabel(r"$\mathrm{c}_{T-1}$")
    plt.ylabel(r"$\mathrm{v}^{\partial}_{\succ,T-1}(m_{T-1} - \mathrm{c}_{T-1}),\; \mathrm{u}^{\partial}(\mathrm{c}_{T-1})$")
    plt.title(
        r"$\mathrm{u}^{\partial}(\mathrm{c})$ vs exact $\mathrm{v}^{\partial}_{\succ}(m-\mathrm{c})$ and "
        r"step-function $\grave{\mathrm{v}}^{\partial}_{\succ}(m-\mathrm{c})$"
    )
    plt.legend(loc='upper right', fontsize=8)
    save_fig(save_as)
    plt.show()


# ─────────────────────────────────────────────────────────
# Value Function versus First Order Condition
# ─────────────────────────────────────────────────────────

def plot_vp_exact_vs_approx(aVec_exact, vp_exact, aVec_approx, vp_approx_vals,
                            save_as=None):
    """Marginal continuation value exact vs piecewise-linear approx.

    LaTeX figure: PlotOPRawVSFOC
    """
    plot_vCntnδ_exact_vs_approx(aVec_exact, vp_exact, aVec_approx, vp_approx_vals,
                                  save_as=save_as)


def plot_c_three_methods(mVec_exact, cVec_exact,
                                mVec_v, cVec_via_v,
                                mVec_vp, cVec_via_vp,
                                save_as=None):
    """c_{T-1} exact versus two approximation methods.

    LaTeX figure: PlotcTm1ABC
    """
    plt.plot(mVec_exact, cVec_exact, "k-",
             label=r"$\mathrm{c}_{T-1}(m_{T-1})$")
    plt.plot(mVec_v, cVec_via_v, "-.",
             label=r"$\grave{\mathrm{c}}_{T-1}(m_{T-1})$ via $\grave{\mathrm{v}}_{\succ}$")
    plt.plot(mVec_vp, cVec_via_vp, "r--",
             label=r"$\grave{\grave{\mathrm{c}}}_{T-1}(m_{T-1})$ via $\grave{\grave{\mathrm{v}}}^{\partial}_{\succ}$")
    plt.xlabel(r"$m_{T-1}$")
    plt.ylabel(r"$\mathrm{c}_{T-1}$")
    plt.title(
        r"$\mathrm{c}_{T-1}(m_{T-1})$ (solid) versus two methods of "
        r"constructing $\grave{\mathrm{c}}_{T-1}(m_{T-1})$"
    )
    plt.legend(loc=4)
    save_fig(save_as)


# ─────────────────────────────────────────────────────────
# Natural Borrowing Constraint
# ─────────────────────────────────────────────────────────

def plot_consumed_fn(aVec_exact, cVec_exact, aVec_approx, cVec_approx,
                     save_as=None):
    """Consumed function exact versus interpolated.

    LaTeX figure: GothVInvVSGothC
    """
    plt.plot(aVec_exact, cVec_exact, "k-",
             label=r"$(\mathrm{v}^{\partial}_{\succ,T-1}(a_{T-1}))^{-1/\rho}$")
    plt.plot(aVec_approx, cVec_approx, "--", label=r"$\grave{\mathrm{c}}_{\succ,T-1}$")
    plt.xlabel(r"$a_{T-1}$")
    plt.ylabel(r"$\mathrm{c}_{\succ,T-1}$")
    plt.ylim(0.0, 5.0)
    plt.vlines(0.0, 0.0, 5.0, "k", "-.")
    plt.title(
        r"$\mathrm{c}_{\succ,T-1}(a_{T-1})$ (solid) versus "
        r"$\grave{\mathrm{c}}_{\succ,T-1}(a_{T-1})$"
    )
    plt.legend(loc=4)
    save_fig(save_as)


def plot_vp_from_consumed(aVec_exact, vp_exact,
                                 aVec_approx, vp_from_consumed,
                                 save_as=None):
    """Marginal value exact vs reconstructed from consumed function.

    LaTeX figure: GothVVSGothCInv
    """
    plt.plot(aVec_exact, vp_exact, "k-")
    plt.plot(aVec_approx, vp_from_consumed, "--")
    plt.xlabel(r"$a_{T-1}$")
    plt.ylabel(
        r"$\mathrm{v}^{\partial}_{\succ,T-1},\quad "
        r"\grave{\grave{\mathrm{v}}}^{\partial}_{\succ,T-1}$"
    )
    plt.title(
        r"$\mathrm{v}^{\partial}_{\succ,T-1}(a_{T-1})$ (solid) versus "
        r"$\grave{\grave{\mathrm{v}}}^{\partial}_{\succ}(a_{T-1})$"
        + "\n constructed using $\\grave{\\mathrm{c}}_{\\succ,T-1}$ (dashed)"
    )
    save_fig(save_as)


# ─────────────────────────────────────────────────────────
# Endogenous Gridpoints (EGM)
# ─────────────────────────────────────────────────────────

def plot_egm_vs_exact(mVec_exact, cVec_exact, mVec_egm, cVec_egm,
                             xlim_lo=None, save_as=None):
    """c_{T-1} exact versus EGM solution.

    LaTeX figure: PlotComparecTm1AD
    """
    plt.plot(mVec_exact, cVec_exact, "k-")
    plt.plot(mVec_egm, cVec_egm, "--")
    if xlim_lo is not None:
        plt.xlim(xlim_lo, 4.0)
    plt.ylim(0.0, 3.0)
    plt.xlabel(r"$m_{T-1}$")
    plt.ylabel(r"$\mathrm{c}_{T-1}(m_{T-1})$")
    plt.title(
        r"$\mathrm{c}_{T-1}(m_{T-1})$ (solid) versus "
        r"$\grave{\mathrm{c}}_{T-1}(m_{T-1})$ using EGM"
    )
    save_fig(save_as)


# ─────────────────────────────────────────────────────────
# Improved Grid
# ─────────────────────────────────────────────────────────

def plot_egm_eee(mVec_exact, cVec_exact, mVec_eee, cVec_eee, xlim_lo=None,
                 save_as=None):
    """c_{T-1} exact versus EGM with EEE grid.

    LaTeX figure: GothVInvVSGothCEEE
    """
    plt.plot(mVec_exact, cVec_exact, "k-")
    plt.plot(mVec_eee, cVec_eee, "*")
    if xlim_lo is not None:
        plt.xlim(2 * xlim_lo, 4.0)
    plt.ylim(-0.1, 3.0)
    plt.xlabel(r"$m_{T-1}$")
    plt.ylabel(r"$\mathrm{c}_{T-1}(m_{T-1})$")
    plt.title(
        r"$\mathrm{c}_{T-1}(m_{T-1})$ (solid) versus $\grave{\mathrm{c}}_{T-1}(m_{T-1})$"
        + "\n using EGM and EEE grid of $a$ (star)"
    )
    save_fig(save_as)


def plot_vp_eee(aVec_exact, vp_exact, aVec_eee, vp_eee, save_as=None):
    """Marginal continuation value exact versus EEE grid points.

    LaTeX figure: GothVVSGothCInvEEE
    """
    plt.plot(aVec_exact, vp_exact, "k-")
    plt.plot(aVec_eee, vp_eee, "*")
    plt.xlabel(r"$a_{T-1}$")
    plt.ylabel(r"$\mathrm{v}^{\partial}_{\succ,T-1}$")
    plt.title(
        r"$\mathrm{v}^{\partial}_{\succ,T-1}(a_{T-1})$ (solid) versus "
        r"$\grave{\grave{\mathrm{v}}}^{\partial}_{\succ}(a_{T-1})$"
        + "\n using EGM with EEE grid of $a$ (star)"
    )
    save_fig(save_as)


# ─────────────────────────────────────────────────────────
# Artificial Borrowing Constraint
# ─────────────────────────────────────────────────────────

def plot_constrained_vs_unconstrained(mVec_const, cVec_const,
                                             mVec_unconst, cVec_unconst,
                                             save_as=None):
    """Constrained versus unconstrained consumption.

    LaTeX figure: cVScCon
    """
    plt.plot(mVec_const, cVec_const, "k-")
    plt.plot(mVec_unconst, cVec_unconst, "--")
    plt.xlabel(r"$m_{T-1}$")
    plt.ylabel(r"$\mathrm{c}_{T-1}(m_{T-1})$")
    plt.ylim(0.0, 5.0)
    plt.vlines(0.0, 0.0, 5.0, "k", "-.")
    plt.title("Constrained (solid) and Unconstrained Consumption (dashed)")
    save_fig(save_as)


# ─────────────────────────────────────────────────────────
# Multiple Periods
# ─────────────────────────────────────────────────────────

def plot_convergence(mVec, cFunc_life, T, n_periods=9, save_as=None):
    """Convergence of consumption functions across periods.

    LaTeX figure: PlotCFuncsConverge
    """
    for t in range(T - 1, T - 1 - n_periods, -1):
        cFunc = cFunc_life[t]
        plt.plot(mVec, cFunc(mVec), "k-")
    plt.xlabel(r"$m$")
    plt.ylabel(r"$\grave{\mathrm{c}}_{T-n}(m)$")
    plt.title(r"Convergence of $\grave{\mathrm{c}}_{T-n}(m)$ Functions as $n$ Increases")
    save_fig(save_as)


# ─────────────────────────────────────────────────────────
# Method of Moderation
# ─────────────────────────────────────────────────────────

def plot_moderation_illustrated(mVec, cFunc_narrow, cFunc_wide,
                                R, beta, rho,
                                Gamma=1.0, m_min=None, save_as=None):
    """Extrapolation problem and its cure via a wider grid.

    LaTeX figure: IntExpFOCInvPesReaOptNeedHiPlot

    Parameters
    ----------
    mVec : array — grid of market resources for plotting
    cFunc_narrow : callable — consumption function solved on a narrow grid
                   (exhibits extrapolation breakdown at high m)
    cFunc_wide : callable — consumption function solved on a wide grid
                 (stays within the theoretical bounds)
    R, beta, rho : float — interest rate, discount factor, CRRA
    Gamma : float — permanent income growth factor (default 1.0)
    m_min : float or None — natural borrowing constraint (minimum m);
            if None, pessimist line is omitted
    save_as : str or None — figure name (without extension)
    """
    R, beta, rho = float(R), float(beta), float(rho)
    Gamma = float(Gamma)
    mVec = np.asarray(mVec, dtype=float)
    if m_min is not None:
        m_min = float(m_min)

    MPCmin = 1.0 - (R * beta) ** (1.0 / rho) / R
    h = Gamma / (1.0 - Gamma / R)

    c_opt = MPCmin * (mVec + h)

    plt.figure(figsize=(8, 5))
    plt.plot(mVec, c_opt, color="0.5", linestyle="--", linewidth=1.0,
             label=r"$(m+h)\,\kappa_{\min}$ (optimist)")

    if m_min is not None:
        c_pes = MPCmin * (mVec - m_min)
        plt.plot(mVec, c_pes, color="0.5", linestyle="--", linewidth=1.0,
                 label=r"$(m - m_{\min})\,\kappa_{\min}$ (pessimist)")

    c_narrow = cFunc_narrow(mVec)
    plt.plot(mVec, c_narrow, "r-", linewidth=1.2,
             label=r"$\mathrm{c}(m)$ (no moderation)")
    plt.plot(mVec, cFunc_wide(mVec), "k-", linewidth=1.5,
             label=r"$\mathrm{c}(m)$ (realist)")

    if hasattr(cFunc_narrow, "get_knots"):
        m_max_knot = float(cFunc_narrow.get_knots().max())
        c_at_knot = float(cFunc_narrow(m_max_knot))
        plt.plot(m_max_knot, c_at_knot, "ko", markersize=6, zorder=5)
        plt.annotate(
            "extrapolation\nbegins",
            xy=(m_max_knot, c_at_knot),
            xytext=(m_max_knot + 1.5, c_at_knot - 0.4),
            fontsize=8,
            arrowprops=dict(arrowstyle="->", color="black", lw=1.0),
        )

    plt.xlabel(r"$m$")
    plt.ylabel(r"$\mathrm{c}$")
    plt.title("Moderation Illustrated")
    plt.legend(fontsize=9)
    plt.xlim(mVec[0], mVec[-1])
    plt.ylim(0, None)
    save_fig(save_as)


# ─────────────────────────────────────────────────────────
# Multiple Control Variables (Portfolio)
# ─────────────────────────────────────────────────────────

def plot_consumption_port(mVec, cFunc, save_as=None):
    """c_{T-1}(m) with portfolio choice.

    LaTeX figure: PlotctMultContr
    """
    plt.plot(mVec, cFunc(mVec), "k-")
    plt.xlabel(r"$m$")
    plt.ylabel(r"$\mathrm{c}_{T-1}(m)$")
    plt.title(r"$\mathrm{c}_{T-1}(m)$ with Portfolio Choice")
    save_fig(save_as)


def plot_share_function(aVec, varsigmaGrid, merton_share=None, save_as=None):
    """Portfolio share in risky assets.

    LaTeX figure: PlotRiskySharetOfat

    Parameters
    ----------
    merton_share : float or None
        If given, plot a dashed horizontal line at this level
        representing the limiting Merton-Samuelson portfolio share.
    """
    plt.plot(aVec, varsigmaGrid, "k-")
    if merton_share is not None:
        plt.axhline(merton_share, color="k", linestyle="--", linewidth=0.8,
                     label=f"Merton-Samuelson limit ({merton_share:.3f})")
        plt.legend(loc="best")
    plt.xlabel(r"$a$")
    plt.ylabel(r"$\varsigma_{1}(a)$")
    plt.title(r"Portfolio Share in Risky Assets $\varsigma_{T-1}(a)$")
    save_fig(save_as)


def plot_hark_comparison_c(mGrid, c_hark, c_dsop, period_label="1",
                           save_as=None):
    """Compare consumption function: MicroDSOP versus HARK."""
    plt.plot(mGrid, c_hark, "r--", label="HARK")
    plt.plot(mGrid, c_dsop, "k-", label="MicroDSOP")
    plt.legend(loc=0)
    plt.title(f"consumption function solved by MicroDSOP and HARK at $t={period_label}$")
    plt.xlabel("m")
    plt.ylabel(rf"$\mathrm{{c}}_{{{period_label}}}(m)$")
    save_fig(save_as)


def plot_hark_comparison_share(mGrid, share_hark, share_dsop,
                                      period_label="1", save_as=None):
    """Compare share function: MicroDSOP versus HARK."""
    plt.plot(mGrid, share_hark, "r--", label="HARK solution")
    plt.plot(mGrid, share_dsop, "k-", label="MicroDSOP solution")
    plt.legend(loc=1)
    plt.title(f"share function solved by MicroDSOP and HARK (at $t={period_label}$)")
    plt.xlabel(r"$m$")
    plt.ylabel(rf"$\varsigma_{{{period_label}}}(m)$")
    save_fig(save_as)


def plot_hark_share_with_diff(mGrid, share_hark, share_dsop,
                                     period_label="T-1", save_as=None):
    """Two-panel comparison of portfolio share: HARK vs MicroDSOP with difference."""
    share_diff = share_hark - share_dsop
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(9, 4))
    ax1.plot(mGrid, share_hark, "r--", label="HARK solution")
    ax1.plot(mGrid, share_dsop, "k-", label="MicroDSOP solution")
    ax1.set_title(f"share function solved \n by MicroDSOP and HARK (at ${period_label}$)")
    ax1.set_xlabel(r"$m$")
    ax1.set_ylabel(rf"$\varsigma_{{{period_label}}}(m)$")
    ax1.legend(loc=0)
    ax2.plot(mGrid, share_diff, "b--", label="Difference")
    ax2.set_xlabel(r"$m$")
    ax2.legend(loc=0)
    ax2.set_title("Differences in solutions")
    save_fig(save_as)


def plot_marginal_value_share(share_grid, mv_dsop, mv_hark, a_grid, a_val=3.0,
                              save_as=None):
    """Marginal value of share at a given a (default a=3): MicroDSOP vs HARK."""
    idx = np.argmin(np.abs(np.asarray(a_grid) - a_val))
    a_plot = a_grid[idx]
    fig, ax = plt.subplots(figsize=(5, 4))
    ax.set_title(rf"$\mathrm{{v}}^{{\partial\varsigma}}_{{\succ}}(a,\varsigma)$ at $a={a_plot:.2g}$")
    ax.plot(share_grid, mv_dsop[idx, :], label="SolvingMicroDSOP")
    ax.plot(share_grid, mv_hark[idx, :], label="HARK")
    ax.hlines(0.0, xmin=0.0, xmax=1.0, linestyle="--", color="k", label="FOC")
    ax.set_xlabel(r"$\varsigma$")
    ax.set_ylabel(r"$\mathrm{v}^{\partial\varsigma}_{\succ}$")
    ax.legend(loc=0)
    save_fig(save_as)


# ─────────────────────────────────────────────────────────
# Modular Stage Architecture
# ─────────────────────────────────────────────────────────

def plot_finite_cross_validation(m_fine, c_pairs, labels=('Old', 'New'),
                                 save_as=None):
    """Finite-horizon cross-validation: old vs modular solver."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    for t_label, c_old_vals, c_new_vals in c_pairs:
        ax1.plot(m_fine, c_old_vals, 'k-', alpha=0.6)
        ax1.plot(m_fine, c_new_vals, 'r--', alpha=0.6)
        ax2.plot(m_fine, np.abs(c_old_vals - c_new_vals), label=t_label)
    ax1.plot([], [], 'k-', label=labels[0])
    ax1.plot([], [], 'r--', label=labels[1])
    ax1.set_xlabel(r'$m$'); ax1.set_ylabel(r'$\mathrm{c}(m)$')
    ax1.set_title(r'Convergence: old vs modular $\mathrm{c}_{T-n}(m)$'); ax1.legend()
    ax2.set_xlabel(r'$m$'); ax2.set_ylabel(r'$|\mathrm{c}_{\rm old} - \mathrm{c}_{\rm new}|$')
    ax2.set_title('Absolute difference (interpolation error)')
    ax2.legend(fontsize=8)
    plt.tight_layout()
    save_fig(save_as)


def plot_infinite_cross_validation(m_plot, c_old_vals, c_new_vals,
                                          m_hat_old, m_hat_new, save_as=None):
    """Infinite-horizon cross-validation: old vs modular solver."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))
    ax1.plot(m_plot, c_old_vals, 'b-', linewidth=2, label='Old solver')
    ax1.plot(m_plot, c_new_vals, 'r--', linewidth=2, label='Modular solver')
    ax1.axvline(m_hat_old, color='b', linestyle=':', alpha=0.5)
    ax1.axvline(m_hat_new, color='r', linestyle=':', alpha=0.5)
    ax1.set_xlabel(r'$m$'); ax1.set_ylabel(r'$\mathrm{c}^*(m)$')
    ax1.set_title(r'Infinite-horizon $\mathrm{c}^*(m)$'); ax1.legend()
    ax2.plot(m_plot, np.abs(c_old_vals - c_new_vals), 'k-')
    ax2.set_xlabel(r'$m$'); ax2.set_ylabel(r'$|\mathrm{c}_{\rm old} - \mathrm{c}_{\rm new}|$')
    ax2.set_title('Absolute difference')
    plt.tight_layout()
    save_fig(save_as)


def plot_port_cons_overview(m_plot, k_plot, result_pc, result_co,
                                   T_port, get_c_func, save_as=None):
    """Four-panel: port-cons vs cons-only consumption and portfolio share."""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    for t_offset in [1, 3, 5]:
        t = T_port - t_offset
        c_pc = get_c_func(result_pc['solutions'][t])
        c_co = get_c_func(result_co['solutions'][t])
        c_pc_vals = np.array([c_pc(m) for m in m_plot])
        c_co_vals = np.array([c_co(m) for m in m_plot])
        axes[0, 0].plot(m_plot, c_pc_vals, '--', label=f'port-cons T-{t_offset}')
        axes[0, 0].plot(m_plot, c_co_vals, '-', alpha=0.5, label=f'cons-only T-{t_offset}')

    axes[0, 0].set_xlabel(r'$m$'); axes[0, 0].set_ylabel(r'$\mathrm{c}(m)$')
    axes[0, 0].set_title(r'Consumption: port-cons vs cons-only')
    axes[0, 0].legend(fontsize=7, ncol=2)

    for t_offset in [1, 3, 5, 8]:
        t = T_port - t_offset
        sol = result_pc['solutions'][t]
        if 'portable' in sol.stg:
            Shr_func = sol['portable']['dcsn'].Shr
            Shr_vals = Shr_func(k_plot)
            axes[0, 1].plot(k_plot, Shr_vals, label=f'T-{t_offset}')

    axes[0, 1].set_xlabel(r'$k$'); axes[0, 1].set_ylabel(r'$\varsigma^*(k)$')
    axes[0, 1].set_title(r'Optimal portfolio share $\varsigma^*(k)$')
    axes[0, 1].set_ylim(-0.05, 1.05); axes[0, 1].legend(fontsize=8)

    sol_last = result_pc['solutions'][T_port - 1]
    c_pc_last = get_c_func(sol_last)
    c_pc_vals = np.array([c_pc_last(m) for m in m_plot])
    axes[1, 0].plot(m_plot, c_pc_vals, 'b-', linewidth=2)
    axes[1, 0].plot(m_plot, m_plot, 'k--', alpha=0.3)
    axes[1, 0].set_xlabel(r'$m$'); axes[1, 0].set_ylabel(r'$\mathrm{c}(m)$')
    axes[1, 0].set_title(r'port-cons: $\mathrm{c}^*_{T-1}(m)$')

    c_diff = []
    for t_offset in range(1, min(8, T_port)):
        t = T_port - t_offset
        c_pc = get_c_func(result_pc['solutions'][t])
        c_co = get_c_func(result_co['solutions'][t])
        diffs = [abs(c_pc(m) - c_co(m)) for m in m_plot]
        c_diff.append(max(diffs))

    axes[1, 1].bar(range(1, len(c_diff) + 1), c_diff, color='steelblue')
    axes[1, 1].set_xlabel('Periods from terminal (T-n)')
    axes[1, 1].set_ylabel(r'$\max |\mathrm{c}_{\rm port\text{-}cons} - \mathrm{c}_{\rm cons\text{-}only}|$')
    axes[1, 1].set_title('Max consumption difference by period')
    plt.tight_layout()
    save_fig(save_as)


def plot_three_period_types(m_plot, k_plot, results_all, T_all, get_c_func,
                            save_as=None):
    """Four-panel comparison of three period types (cons-only, port-cons, cons-port)."""
    colors = {
        'cons-only': 'blue', 'port-cons': 'red',
        'cons-port': 'green',
    }
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    for name, res in results_all.items():
        c = get_c_func(res['solutions'][T_all - 1])
        if c is not None:
            c_vals = np.array([c(m) for m in m_plot])
            axes[0, 0].plot(m_plot, c_vals, color=colors[name], linewidth=2, label=name)
    axes[0, 0].plot(m_plot, m_plot, 'k--', alpha=0.2)
    axes[0, 0].set_xlabel(r'$m$'); axes[0, 0].set_ylabel(r'$\mathrm{c}(m)$')
    axes[0, 0].set_title(r'$\mathrm{c}_{T-1}(m)$ across period types'); axes[0, 0].legend(fontsize=9)

    for name, res in results_all.items():
        sol = res['solutions'][T_all - 1]
        if 'portable' in sol.stg and hasattr(sol['portable']['dcsn'], 'Shr'):
            Shr = sol['portable']['dcsn'].Shr
            Shr_vals = Shr(k_plot)
            axes[0, 1].plot(k_plot, Shr_vals, color=colors[name], linewidth=2, label=name)
    axes[0, 1].set_xlabel(r'$k$'); axes[0, 1].set_ylabel(r'$\varsigma^*(k)$')
    axes[0, 1].set_title(r'$\varsigma^*_{T-1}(k)$ for period types with portfolio')
    axes[0, 1].set_ylim(-0.05, 1.05); axes[0, 1].legend(fontsize=9)

    for name, res in results_all.items():
        c = get_c_func(res['solutions'][0])
        if c is not None:
            c_vals = np.array([c(m) for m in m_plot])
            axes[1, 0].plot(m_plot, c_vals, color=colors[name], linewidth=2, label=name)
    axes[1, 0].plot(m_plot, m_plot, 'k--', alpha=0.2)
    axes[1, 0].set_xlabel(r'$m$'); axes[1, 0].set_ylabel(r'$\mathrm{c}(m)$')
    axes[1, 0].set_title(r'$\mathrm{c}_0(m)$ across period types'); axes[1, 0].legend(fontsize=9)

    for name, res in results_all.items():
        sol = res['solutions'][0]
        if 'portable' in sol.stg and hasattr(sol['portable']['dcsn'], 'Shr'):
            Shr = sol['portable']['dcsn'].Shr
            Shr_vals = Shr(k_plot)
            axes[1, 1].plot(k_plot, Shr_vals, color=colors[name], linewidth=2, label=name)
    axes[1, 1].set_xlabel(r'$k$'); axes[1, 1].set_ylabel(r'$\varsigma^*(k)$')
    axes[1, 1].set_title(r'$\varsigma^*_0(k)$ for period types with portfolio')
    axes[1, 1].set_ylim(-0.05, 1.05); axes[1, 1].legend(fontsize=9)
    plt.tight_layout()
    save_fig(save_as)


def plot_cross_validate_portfolio(m_cross, c_old_vals, c_new_vals,
                                     a_cross, shr_old_vals, shr_new_vals,
                                     save_as=None):
    """Two-panel: modular port-cons versus EndOfPrdMC (legacy portfolio solver)."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    axes[0].plot(m_cross, c_old_vals, 'b-', linewidth=2, label='EndOfPrdMC')
    axes[0].plot(m_cross, c_new_vals, 'r--', linewidth=2, label='Modular (port-cons)')
    axes[0].set_xlabel(r'$m$'); axes[0].set_ylabel(r'$\mathrm{c}(m)$')
    axes[0].set_title(r'$\mathrm{c}_1(m)$: EndOfPrdMC vs Modular'); axes[0].legend()
    if shr_old_vals is not None and shr_new_vals is not None:
        axes[1].plot(a_cross, shr_old_vals, 'b-', linewidth=2, label='EndOfPrdMC')
        axes[1].plot(a_cross, shr_new_vals, 'r--', linewidth=2, label='Modular')
        axes[1].set_xlabel(r'$a = m - \mathrm{c}(m)$'); axes[1].set_ylabel(r'$\varsigma^*$')
        axes[1].set_title(r'$\varsigma^*(a)$: EndOfPrdMC vs Modular')
        axes[1].set_ylim(-0.05, 1.05); axes[1].legend()
    plt.tight_layout()
    save_fig(save_as)
