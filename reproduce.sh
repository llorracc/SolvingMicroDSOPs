#!/usr/bin/env bash
# reproduce.sh — Full reproduction: notebook (figures/results), PDF (latexmk), structural estimation.
# See https://github.com/econ-ark/REMARK/blob/main/STANDARD.md

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

export MPLBACKEND="${MPLBACKEND:-Agg}"

run_notebook() {
    if command -v uv >/dev/null 2>&1; then
        uv run jupyter nbconvert --execute --to notebook --inplace --ExecutePreprocessor.timeout=600 -- SolvingMicroDSOPs.ipynb
    else
        jupyter nbconvert --execute --to notebook --inplace --ExecutePreprocessor.timeout=600 -- SolvingMicroDSOPs.ipynb
    fi
}

run_latexmk() {
    if ! command -v latexmk >/dev/null 2>&1; then
        echo "Warning: latexmk not found; skipping PDF build. Install TeX Live or use the Docker image."
        return 0
    fi
    latexmk
}

run_estimation() {
    if command -v uv >/dev/null 2>&1; then
        uv run python Code/Python/StructEstimation.py
    else
        python Code/Python/StructEstimation.py
    fi
}

# Prefer uv on PATH; else conda from binder/environment.yml (Binder installs uv via pip)
if command -v uv >/dev/null 2>&1; then
    uv sync --all-groups
else
    if [ -f /opt/conda/etc/profile.d/conda.sh ]; then
        source /opt/conda/etc/profile.d/conda.sh
        if command -v mamba >/dev/null 2>&1; then
            mamba env create -qq -f binder/environment.yml 2>/dev/null || true
        else
            conda env create -qq -f binder/environment.yml 2>/dev/null || true
        fi
        conda activate solvingmicrodsops
        uv sync --all-groups
    else
        echo "Error: neither 'uv' nor conda (/opt/conda) found. Install uv or use a Binder/Docker image."
        exit 1
    fi
fi

echo "=== 1/3 Executing notebook (ipython) ==="
run_notebook

echo "=== 2/3 Compiling PDF (latexmk) ==="
run_latexmk

echo "=== 3/3 Running structural estimation ==="
run_estimation

echo "reproduce.sh finished successfully."
