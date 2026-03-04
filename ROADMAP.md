# How to Read This Document

**SolvingMicroDSOPs** builds up a toolkit for solving consumption/savings problems under uncertainty. Each topic addresses a limitation of the previous approach, so the material is best read in order — but you can skip ahead if you already know the basics.

---

## Reading paths

### "I want the full picture" — read everything in order

The document walks through the following progression:

| Topic | What you will learn | Prerequisites |
|-------|-------------------|---------------|
| **The Problem** | The canonical consumption/savings model under uncertainty — objective, budget constraint, income process, normalization. | Dynamic programming basics |
| **Notation** | The stage/perch notation that decomposes each period into arrival → decision → continuation. | The Problem |
| **The Usual Theory** | Value functions, envelope conditions, Euler equation, and the FOC — all restated in stage notation. | Notation |
| **Value Function Maximization** | The brute-force approach: discretize shocks, maximize on a grid. Why this is slow and inaccurate. | The Usual Theory |
| **Interpolation** | Approximating the consumption and value functions between grid points. | Value Function Maximization |
| **FOC / Euler Equation Methods** | Using the first-order condition instead of maximizing the value function. Far more accurate. | Interpolation |
| **Transformation** | The key trick: raising marginal value to $-1/\rho$ to get a nearly-linear "consumed function" that interpolates well. | FOC Methods |
| **Endogenous Gridpoints (EGM)** | Eliminating rootfinding entirely by inverting the Euler equation and letting the grid be endogenous. | Transformation |
| **Grid Construction** | Multi-exponential spacing to put grid points where they matter most. | EGM |
| **Borrowing Constraints** | Natural and artificial constraints; how they interact with EGM. | EGM |
| **Multi-Period Backward Induction** | Solving $T$, $T{-}1$, $T{-}2$, ... and convergence to the infinite-horizon solution. | EGM + Constraints |
| **Multiple Control Variables** | Portfolio choice (risky vs. risk-free asset) via a two-stage optimization within each period. | Multi-Period |
| **Modular Stage Architecture** | How the code decomposes each period into composable stages that can be mixed and matched for different model configurations. | Multiple Control Variables |
| **Structural Estimation** | Simulated Method of Moments (SMM) estimation matching SCF wealth-to-income data. | Multi-Period |

### "I just need to understand EGM"

Read: **The Problem** → **Notation** (skim) → **The Usual Theory** (FOC and envelope) → **Transformation** → **Endogenous Gridpoints**.

### "I want to do structural estimation"

Read: the full path above through **Multi-Period Backward Induction**, then jump to **Structural Estimation**. You can skip Multiple Control Variables unless your estimation involves portfolio choice.

### "I want to understand the code architecture"

Read: **Notation** (especially stages and perches) → **Multiple Control Variables** → **Modular Stage Architecture**. Then open the Jupyter notebook (`SolvingMicroDSOPs.ipynb`) and step through it.

### "I want to add portfolio choice to my model"

Read: everything through **Multi-Period**, then **Multiple Control Variables** carefully. The notebook section on portfolio choice has cross-validation against HARK.

---

## Where to find things

| If you want... | Look in... |
|----------------|-----------|
| The math | LaTeX source (`_sectn-*.tex`), compiled PDF |
| Working code | `SolvingMicroDSOPs.ipynb` (step-by-step) or `Code/Python/` modules |
| Notation reference | `Notation.md` (glossary of all macros and symbols) |
| How code maps to math | `.agents/orientation-code.md` |
| Parameter values | `Code/Python/notebook_params.py` |
| HARK comparison | `CONTRIBUTION.md` and the cross-validation cells in the notebook |
