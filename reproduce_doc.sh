#!/usr/bin/env bash
# reproduce_doc.sh — Recompile the main lecture notes PDF only (latexmk).
# Use this when you have changed only the LaTeX source.

set -e

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

if ! command -v latexmk >/dev/null 2>&1; then
    echo "Error: latexmk not found. Install TeX Live (or use the Docker image)."
    exit 1
fi

latexmk
