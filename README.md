# SolvingMicroDSOPs

**Solution Methods for Microeconomic Dynamic Stochastic Optimization Problems** — lecture notes, code, and replication for structural estimation of a life-cycle consumption-saving model.

**Author**: Christopher D. Carroll  
**Status**: [REMARK](https://github.com/econ-ark/REMARK) Tier 1 (Docker REMARK) — minimal reproducibility via containerization.

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/econ-ark/SolvingMicroDSOPs/HEAD)

For a one-page quick start, see [QUICKSTART.md](QUICKSTART.md).

---

## Quick Start with Docker

### Prerequisites

- Docker (20.0+)
- At least 4 GB RAM; 8 GB recommended for full reproduction
- ~2 GB disk for the image

### Build and run reproduction

```bash
git clone https://github.com/econ-ark/SolvingMicroDSOPs
cd SolvingMicroDSOPs
docker build -t solvingmicrodsops .
docker run --rm -v "$(pwd)":/workspace solvingmicrodsops
```

**Expected output**: The script (1) executes the Jupyter notebook to regenerate figures and results, (2) compiles the lecture notes PDF with latexmk, and (3) runs structural estimation (Nelder-Mead), writing `Tables/estimate_results.csv` and optionally contour/sensitivity figures in `Figures/` (e.g. `SMMcontour.pdf`, `Sensitivity.pdf`).

**Runtime**: About 2–7 minutes for the default estimation and contour plot on a modern laptop; full reproduction (notebook + PDF + estimation) can take ~10–15 minutes; up to ~40 minutes with bootstrap standard errors.

---

## What This Project Does

These notes describe numerical methods for solving microeconomic dynamic stochastic optimization problems and show how to estimate a standard life-cycle consumption-saving model using micro data (e.g. SCF). The estimation matches simulated age-conditional wealth profiles to median wealth by age group by varying the coefficient of relative risk aversion and a discount-factor adjustment.

The repository includes a Jupyter notebook aligned with the LaTeX lecture notes, Python code for structural estimation (SMM), and calibration/data setup. The main reproduction script runs the estimation and optionally contour plots and bootstrap standard errors.

---

## Repository Structure

```
.
├── SolvingMicroDSOPs.tex          # Main document (includes _sectn-*.tex subfiles)
├── SolvingMicroDSOPs-options.tex  # Boolean flags controlling document variants
├── SolvingMicroDSOPs.ipynb        # Jupyter notebook aligned with the lecture notes
├── SolvingMicroDSOPs.bib          # Bibliography
├── _sectn-*.tex                   # LaTeX sections (subfiles)
├── Equations/                     # Equation fragments (\input-ed by sections)
├── Figures/                       # Generated figures (.eps/.pdf/.svg)
├── Tables/                        # Generated tables (e.g. estimate_results.csv)
│
├── Code/
│   ├── Python/
│   │   ├── resources.py           # Utility functions, grids, shocks
│   │   ├── endOfPrd.py            # End-of-period value/marginal-value
│   │   ├── solution.py            # Solution containers (Perch, Stage, PeriodSolution)
│   │   ├── solve.py               # Backward-induction solver
│   │   ├── solve_modular.py       # Modular multi-stage solver
│   │   ├── period_types.py        # Canonical period configurations
│   │   ├── stages/                # Individual stage implementations
│   │   ├── StructEstimation.py    # SMM structural estimation (main entry)
│   │   ├── snippets/              # Standalone code examples for the text
│   │   └── tests/                 # Test suite (pytest); run via pyproject.toml
│   └── Stata/                     # SCF data pipeline (raw → Calibration/SCFdata.csv)
│
├── Calibration/
│   ├── EstimationParameters.py    # Discount factor, CRRA, life-cycle params
│   ├── SCFdata.csv                # Pre-processed SCF wealth-by-age data
│   └── SetupSCFdata.py            # Load and prepare SCF data for estimation
│
├── reproduce.sh                   # Full reproduction: notebook → PDF → estimation
├── reproduce_min.sh               # Notebook only
├── reproduce/                     # Additional scripts (PDF-only, env setup, Docker)
│
├── Dockerfile                     # Container (TeX Live + Python/uv)
├── binder/environment.yml         # Conda env for Binder
├── pyproject.toml                 # Python project config (deps, test paths)
├── uv.lock                        # Locked dependency versions
│
├── AGENTS.md                      # Orientation for AI-assisted work
├── .agents/                       # Detailed docs: LaTeX structure, code layout
├── CONTRIBUTION.md                # What this document contributes
├── ROADMAP.md                     # Suggested reading paths
├── Notation.md                    # Glossary of mathematical notation and macros
├── QUICKSTART.md                  # One-page quick start
└── docs/                          # Reference copy — do NOT edit
```

---

## Data

Estimation uses **Calibration/SCFdata.csv** (included in the repo). To rebuild this from raw SCF data, use the Stata pipeline in **Code/Stata/** (see [Code/Stata/README.md](Code/Stata/README.md)); that pipeline writes to **Data/Constructed/**; the Python code uses the pre-processed CSV in **Calibration/**. See also [Calibration/README.md](Calibration/README.md).

---

## Installation (without Docker)

See also https://econ-ark.org/materials/SolvingMicroDSOPs

### Using uv (recommended)

```bash
uv sync --all-groups
./reproduce.sh
```

To run only the notebook, only the PDF, or only estimation: `./reproduce_min.sh` (notebook), `./reproduce/reproduce_doc.sh` (PDF), or `uv run python Code/Python/StructEstimation.py` (estimation).

### Using conda

```bash
conda env create -f binder/environment.yml
conda activate solvingmicrodsops
./reproduce.sh
```

### Interactive replication (do_all.py)

```bash
conda activate solvingmicrodsops   # or: uv run bash
python do_all.py                   # prompts for low/medium/high/full run
```

### Reproduction output

After running `./reproduce.sh`, **Tables/estimate_results.csv** should match the committed version within numerical tolerance. See [Tables/README.md](Tables/README.md).

### Dependencies

Tested with **econ-ark** >= 0.17.1. For exact reproduction use `uv sync` (uses **uv.lock**).

---

## References

- Carroll, C. D. (2026). *Theoretical Foundations of Buffer Stock Saving*. Quantitative Economics.  
- Carroll, C. D., Slacalek, J., Tokuoka, K., & White, M. N. (2017). *The distribution of wealth and the marginal propensity to consume*. Quantitative Economics.

---

## Citation

See [CITATION.cff](CITATION.cff). If you use this code, please cite the repository and the papers above.

## License

[LICENSE](LICENSE) — Apache 2.0.

---

## Thanks

Thanks to Marc Chan for help updating the text and software, Kiichi Tokuoka for drafting the section on structural estimation, Damiano Sandri for revising the method of simulated moments estimation section, Weifeng Wu and Metin Uyanik for revisions related to the method of moderation, Tao Wang for contributions to the codebase and documentation, and several generations of Johns Hopkins graduate students for helping refine these notes.

---

**REMARK Tier**: 1 (Docker REMARK)  
**Last updated**: 2026-02-26
