# What This Document Contributes

**SolvingMicroDSOPs** provides an integrated treatment of the mathematics and computational methods for solving microeconomic dynamic stochastic optimization problems, accompanied by code that solves the models described in the text.

## Audience and prerequisites

The material is intended for **PhD economists** learning or seeking insight into efficient, fast methods for solving such models.

**Assumed background:**

- Dynamic programming and the Bellman equation (at the level of a first-year PhD macro sequence)
- Basic numerical methods: interpolation, numerical integration, optimization
- Familiarity with the consumption/savings problem under uncertainty (Deaton 1991, Carroll 1997)
- Python (for the code); LaTeX (for the mathematical presentation)

No prior exposure to the Endogenous Grid Method or structural estimation is required — the document teaches these from scratch.

## Scope

This is **not** a general survey of the broad topic. Rather, it presents specific methods applied to canonical consumption/savings models under uncertainty:

- **Brute-force value function maximization** and why it is slow and inaccurate.
- **First-order condition methods** that exploit the Euler equation instead.
- **The inverse marginal value transformation** that (almost) linearizes the interpolation problem.
- **Endogenous Grid Method (EGM)** that eliminates numerical rootfinding entirely.
- **Multi-period backward induction** with convergence to the infinite-horizon solution.
- **Portfolio choice** (multiple control variables) via a two-stage optimization.
- **Structural estimation** via Simulated Method of Moments (SMM) matching SCF data.

Each method is motivated by a concrete deficiency in the preceding approach, building a cumulative case for the techniques the author has found most effective in practice.

## What distinguishes this from other references

- **Ljungqvist and Sargent** and similar textbooks cover dynamic programming broadly; this document focuses narrowly on *implementation*, with working code for every method discussed.
- **HARK** (the Heterogeneous Agents Resources and toolKit) provides production-grade solvers; this document explains the mathematics *behind* those solvers at a level of detail suitable for someone building or modifying them. See the comparison below.
- The tight coupling of **LaTeX mathematics and Python code** — with deliberate mirroring of variable names — makes the connection between theory and implementation explicit and verifiable.

## Relationship to HARK

[HARK](https://github.com/econ-ark/HARK) is a production toolkit for heterogeneous-agent models. This repo uses HARK in two ways:

1. **Cross-validation**: the notebook solves each problem using the repo's own step-by-step code *and* using HARK's `IndShockConsumerType` / `PortfolioConsumerType`, then compares the results to confirm agreement.
2. **Structural estimation**: `StructEstimation.py` subclasses HARK's `IndShockConsumerType` to run the SMM estimation loop.

**What this repo adds that HARK does not provide:**

| This repo | HARK |
|-----------|------|
| Step-by-step derivation of each method, with LaTeX mathematics | Production solver code with API documentation |
| Progression from brute-force → FOC → transformation → EGM, showing why each step helps | EGM solver as a finished product |
| Explicit worked examples for a single period, then multiple periods, then infinite horizon | Lifecycle and infinite-horizon solvers ready to use |
| Modular stage architecture with composable `Stage` / `Perch` objects that mirror the math | Monolithic solver classes organized by model type |
| The transformation trick explained and visualized | Transformation used internally without exposition |
| Portfolio choice derived as a two-stage problem with inner/outer optimization | `PortfolioConsumerType` as a ready-made solver |

In short: HARK is for *using* solvers; this document is for *understanding and building* them.

## Key innovations presented

1. **The transformation trick**: raising the marginal value function to $-1/\rho$ to obtain a nearly-linear "consumed function" that can be interpolated with far greater accuracy than the value function itself.
2. **EGM for consumption problems**: a complete, step-by-step derivation and implementation that shows how to go from the first-order condition to an interpolated consumption function without any rootfinding.
3. **Modular stage architecture**: a decomposition of each period into composable stages (discounting, consumption choice, portfolio/shocks integration) that supports different model configurations from the same building blocks.

