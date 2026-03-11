# Notation Glossary

This is a consolidated reference for the mathematical notation used in **SolvingMicroDSOPs**. Macros are defined in `@local/local-macros.sty` and `@resources/` style files. Python identifiers mirror these names where possible (see the "Python" column).

> **Naming convention.** We aim for identical names across LaTeX macros, Python code, and filenames. The one exception is the Greek letter δ (U+03B4), used as a generic derivative marker (replacing prime). Unicode δ works in LaTeX macro names (under LuaLaTeX) and Python identifiers, but Unicode characters in filenames are fragile across filesystems, git tooling, and CI environments. Therefore, **filenames substitute lowercase `d` for `δ`** — e.g., the figure `Plot_ud_VS_vCntnd.pdf` corresponds to the LaTeX label `fig:Plot_ud_VS_vCntnd` and the Python function `compute_uδ_vs_vCntnδ_data`.

---

## Variables: normalized (lowercase roman)

Normalized variables are divided by permanent income $\pLvl$. These are the ones the code actually works with.

| LaTeX | Symbol | Python | Meaning |
|-------|--------|--------|---------|
| `\mNrm` | $m$ | `mNrm` | Market resources (cash-on-hand) |
| `\cNrm` | $c$ | `cNrm` | Consumption |
| `\aNrm` | $a$ | `aNrm` | End-of-period assets |
| `\bNrm` | $b$ | `bNrm` | Beginning-of-period bank balances |
| `\kNrm` | $k$ | `kNrm` | Capital (investable before returns) |

## Variables: levels (bold italic)

Level (unnormalized) variables are set in bold italic: $\boldsymbol{\mathit{m}}$, $\boldsymbol{\mathit{c}}$, etc.

| LaTeX | Symbol | Meaning |
|-------|--------|---------|
| `\mLvl` | $\boldsymbol{\mathit{m}}$ | Level market resources |
| `\pLvl` | $\boldsymbol{\mathit{p}}$ | Permanent income level |

---

## Parameters

| LaTeX | Symbol | Python | Meaning |
|-------|--------|--------|---------|
| `\DiscFac` | $\beta$ | `DiscFac` | Discount factor |
| `\CRRA` | $\rho$ | `CRRA` | Coefficient of relative risk aversion |
| `\Rfree` | $R$ | `Rfree` | Gross risk-free return |
| `\Risky` | $\tilde{R}$ | `Risky` | Gross risky return |
| `\Rport` | $R_{\text{port}}$ | `Rport` | Gross portfolio return |
| `\PermGroFac` | $\Gamma$ | `PermGroFac` | Permanent income growth factor |
| `\RNrmByG` | $R/\Gamma$ | `RNrmByG` | Return factor normalized by growth |
| `\LivPrb` | $\mathcal{L}$ | `LivPrb` | Survival probability |

---

## Functions (upright roman)

| LaTeX | Symbol | Python | Meaning |
|-------|--------|--------|---------|
| `\uFunc` | $\mathrm{u}$ | `u()` | CRRA utility function |
| `\vFunc` | $\mathrm{v}$ | `v()` | Value function |
| `\cFunc` | $\mathrm{c}$ | `cFunc()` | Consumption policy function |

### Decorated value functions

| LaTeX | Symbol | Python | Meaning |
|-------|--------|--------|---------|
| `\vEndPrd` | $\mathrm{v}_\succ$ | `vEndPrd()` | End-of-period (continuation) value |
| `\vEndPrd^{\partial a}` | $\mathrm{v}^{\delta a}_\succ$ | `vCntnδ()` | Marginal end-of-period value (w.r.t. $a$) |
| `\cCntn` | — | `cCntn()` | Continuation consumption function |

### Superscript conventions

| Superscript | Meaning |
|------------|---------|
| $\partial$ | First derivative (marginal) |
| $\delta a$ | Derivative with respect to $a$ |
| $\grave{\phantom{x}}$ | Constrained solution (via `\cnstr{}`) |
| $\breve{\phantom{x}}$ | Optimal value (via `\Opt`) |
| $\bar{\phantom{x}}$ | Upper bound / maximum (via `\Max{}`) |
| $\underline{\phantom{x}}$ | Lower bound / minimum (via `\Min{}`) |

---

## Shocks

| LaTeX | Symbol | Python | Meaning |
|-------|--------|--------|---------|
| `\permShk` | $\psi$ | `permShk` | Permanent income shock |
| `\tranShkEmp` | $\theta$ | `tranShkEmp` | Transitory employment shock |
| `\tranShk` | $\xi$ | `tranShk` | Transitory shock (generic) |

---

## Time and periods

| LaTeX | Symbol | Meaning |
|-------|--------|---------|
| `\prdt` | $t$ | Current period |
| `\prdT` | $T$ | Terminal period |

---

## Stage / perch notation

Each period is decomposed into **stages**, and each stage has **perches** (checkpoints). This notation is central to the modular architecture.

### Perch types

| LaTeX | Symbol | Name | Meaning |
|-------|--------|------|---------|
| `\arvl` / `\Arrival` | $\prec$ | Arrival | State when entering a stage |
| `\dcsn` / `\Decision` | $\sim$ | Decision | State at the decision point |
| `\cntn` / `\Continuation` | $\succ$ | Continuation | State after the decision, before next stage |

### Subscript convention

Functions are subscripted by perch: $\mathrm{v}_\prec$ (arrival value), $\mathrm{v}_\sim$ (decision value), $\mathrm{v}_\succ$ (continuation value).

### Stage names

| `\StgName{...}` | Control-name | Python module | Description |
|-----------------|-------------|---------------|-------------|
| `disc` | $\beta$ | `stages/disc.py` | Discounting (no choice; applies $\beta$) |
| `cons-noshocks` | $\mathrm{c}$ | `stages/cons_noshocks.py` | Consumption choice (shocks already realized) |
| `cons-with-shocks` | $\mathrm{c}$ | — | Consumption + shock realization in one stage |
| `portable` | $\varsigma$ | `stages/portable.py` | Returns, portfolio choice (optional), and shock realization |
| `shocks-only` | — | (portable with `bar_Shr=0`) | `portable` configured with fixed $\bar{\varsigma}=0$; shocks only, no portfolio choice |

### Connectors and builders

| LaTeX | Symbol | Meaning |
|-------|--------|---------|
| `\Cnctr` | $\mathcal{C}$ | Connector between stages |
| `\BkBldr` | $\mathtt{B}^\leftarrow$ | Backward builder (builds solution backward in time) |
| `\Pile` | $\mathtt{P}$ | Pile — the accumulated solution across periods |

---

## Expectation operators

| LaTeX | Symbol | Meaning |
|-------|--------|---------|
| `\Ex` | $\mathbb{E}$ | Generic expectation |
| `\ExEndPrd` | $\mathbb{E}_\succ$ | Expectation at end of period (over next-period shocks) |
| `\ExArvl` | $\mathbb{E}_\prec$ | Expectation at arrival |
| `\ExDcsn` | $\mathbb{E}_\sim$ | Expectation at decision |

---

## Growth-adjusted factors

| LaTeX | Meaning |
|-------|---------|
| `\PermGroFacAdjV` | $\Gamma^{1-\rho}$ — growth adjustment for value functions |
| `\PermGroFacAdjMu` | $\Gamma^{-\rho}$ — growth adjustment for marginal utility |

---

## Portfolio choice

| LaTeX | Symbol | Python | Meaning |
|-------|--------|--------|---------|
| `\Shr` | $\varsigma$ | `Shr` | Portfolio share in risky asset |

---

## Borrowing constraints

| LaTeX | Symbol | Meaning |
|-------|--------|---------|
| `\NatBoroCnstra` | $\underline{a}$ | Natural borrowing constraint (self-imposed) |

---

## Abbreviated attribute names on `Perch` objects

The `Perch` class in `solution.py` uses short attribute names that do not directly mirror any single LaTeX macro:

| Perch attribute | LaTeX equivalent | Meaning |
|----------------|-----------------|---------|
| `.v` | `\vFunc` (subscripted by perch) | Value function at this perch |
| `.c` | `\cFunc` (subscripted by perch) | Consumption rule at this perch |
| `.cδ` | consumed function (related to `\vCntn^{\delta a}`) | $(\mathrm{v}^{\delta a})^{-1/\rho}$, nearly-linear for interpolation |
| `.vδ` | `\vCntn^{\delta a}` or `\vEndPrd^{\delta a}` | Marginal value w.r.t. state, derived from `.cδ` |
