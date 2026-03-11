#!/usr/bin/env bash
# reproduce_min.sh — Execute the Jupyter notebook only (ipython/nbconvert).
# Regenerates notebook outputs (figures, results). Does not compile the PDF or run estimation.

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

export MPLBACKEND="${MPLBACKEND:-Agg}"

if command -v uv >/dev/null 2>&1; then
    uv sync --group jupyter
    uv run jupyter nbconvert --execute --to notebook --inplace --ExecutePreprocessor.timeout=600 -- SolvingMicroDSOPs.ipynb
else
    if [ -f /opt/conda/etc/profile.d/conda.sh ]; then
        source /opt/conda/etc/profile.d/conda.sh
        conda activate solvingmicrodsops 2>/dev/null || true
    else
        echo "Error: neither 'uv' nor conda found. Install uv or use a Binder/Docker image."
        exit 1
    fi
    jupyter nbconvert --execute --to notebook --inplace --ExecutePreprocessor.timeout=600 -- SolvingMicroDSOPs.ipynb
fi

echo "reproduce_min.sh finished successfully (notebook executed)."
