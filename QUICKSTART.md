# Quick Start

One-page path to reproduce and run SolvingMicroDSOPs. For full details see [README.md](README.md) and [AGENTS.md](AGENTS.md) (document structure and PDF build).

## Full reproduction (notebook + PDF + estimation)

**With Docker (recommended):**

```bash
git clone https://github.com/econ-ark/SolvingMicroDSOPs
cd SolvingMicroDSOPs
docker build -t solvingmicrodsops .
docker run --rm -v "$(pwd)":/workspace solvingmicrodsops
```

**Without Docker:**

```bash
git clone https://github.com/econ-ark/SolvingMicroDSOPs
cd SolvingMicroDSOPs
uv sync --all-groups
./reproduce.sh
```

This runs, in order: (1) execute the Jupyter notebook to regenerate figures/results, (2) compile the lecture notes PDF with latexmk, (3) run structural estimation. Outputs: updated notebook, `SolvingMicroDSOPs.pdf`, `Tables/estimate_results.csv`, and optional figures in `Figures/`.

## Partial runs

- **Notebook only:** `./reproduce_min.sh`
- **PDF only:** `./reproduce/reproduce_doc.sh` (requires TeX Live / latexmk)
- **Estimation only:** `uv run python Code/Python/StructEstimation.py`

## Run the notebook interactively

```bash
uv run jupyter lab
```

Then open `SolvingMicroDSOPs.ipynb`. With conda: `conda activate solvingmicrodsops` then `jupyter lab`.

## Check reproduction

After `./reproduce.sh`, `Tables/estimate_results.csv` should match the committed version within numerical tolerance. See [Tables/README.md](Tables/README.md).
