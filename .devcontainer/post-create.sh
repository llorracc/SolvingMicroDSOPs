#!/bin/bash
# Post-create script for SolvingMicroDSOPs devcontainer.
# Runs once after the container is created and VS Code connects.
# TeX Live is already baked into the image by the Dockerfile — this script
# only sets up the Python environment and verifies the installation.

set -e

# Repo root: resolve from script location so it works for both /workspace and /workspace/RepoName
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"
echo "$REPO_ROOT" > .devcontainer/repo-root 2>/dev/null || true

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  SolvingMicroDSOPs Devcontainer Post-Create Setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Repo root: $REPO_ROOT"
echo ""

# ============================================================================
# 1. Verify TeX Live (should already be installed in image)
# ============================================================================
echo "📄 Checking TeX Live installation..."
TEXLIVE_BIN=$(find /usr/local/texlive/2025/bin -type d -mindepth 1 -maxdepth 1 2>/dev/null | head -1)
if [ -n "$TEXLIVE_BIN" ] && [ -f "$TEXLIVE_BIN/pdflatex" ]; then
    PDFLATEX_VERSION=$("$TEXLIVE_BIN/pdflatex" --version 2>&1 | head -1)
    echo "  ✅ TeX Live 2025 installed: $PDFLATEX_VERSION"
else
    echo "  ❌ TeX Live not found — was the image built from the Dockerfile?"
    echo "     Run: Dev Containers: Rebuild Container (without cache)"
fi

# ============================================================================
# 2. Build Python environment (architecture-specific — must run at container
#    startup, not image build time, because arch may differ from build host)
# ============================================================================
echo ""
echo "🐍 Setting up Python environment..."

export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

PLATFORM=$(uname -s | tr "[:upper:]" "[:lower:]")
ARCH=$(uname -m)
if [ "$PLATFORM" = "darwin" ]; then
    VENV_PATH="$REPO_ROOT/.venv-darwin-$ARCH"
else
    VENV_PATH="$REPO_ROOT/.venv-linux-$ARCH"
fi

if [ -d "$VENV_PATH" ] && [ -f "$VENV_PATH/bin/python" ]; then
    PYTHON_VERSION=$("$VENV_PATH/bin/python" --version 2>&1)
    echo "  ✅ Python environment already exists: $VENV_PATH"
    echo "     $PYTHON_VERSION"
else
    echo "  📦 Building Python environment for $(uname -m)..."
    echo "     This is a one-time setup (2–3 minutes)."
    if [ -f "./reproduce/reproduce_environment_comp_uv.sh" ]; then
        bash ./reproduce/reproduce_environment_comp_uv.sh
    else
        echo "  ⚠️  reproduce_environment_comp_uv.sh not found"
        echo "     Try: uv sync --all-groups"
    fi
    # Re-detect venv path in case it was just created
    [ -d "$REPO_ROOT/.venv-linux-$ARCH" ] && VENV_PATH="$REPO_ROOT/.venv-linux-$ARCH"
    [ -d "$REPO_ROOT/.venv-darwin-$ARCH" ] && VENV_PATH="$REPO_ROOT/.venv-darwin-$ARCH"
fi

# ============================================================================
# 2b. Symlink .venv -> platform venv (so python.defaultInterpreterPath works)
# ============================================================================
if [ -d "$VENV_PATH" ] && [ -f "$VENV_PATH/bin/python" ]; then
    if [ -L "$REPO_ROOT/.venv" ]; then
        CURRENT=$(readlink "$REPO_ROOT/.venv")
        if [ "$CURRENT" != "$(basename "$VENV_PATH")" ]; then
            rm -f "$REPO_ROOT/.venv"
            ln -s "$(basename "$VENV_PATH")" "$REPO_ROOT/.venv"
            echo "  🔗 Updated .venv -> $(basename "$VENV_PATH")"
        fi
    elif [ ! -e "$REPO_ROOT/.venv" ]; then
        ln -s "$(basename "$VENV_PATH")" "$REPO_ROOT/.venv"
        echo "  🔗 .venv -> $(basename "$VENV_PATH") (for VS Code Python extension)"
    fi
fi

# ============================================================================
# 2c. Write venv-local Jupyter kernel spec with absolute Python path.
#     Lives inside the venv — no global ~/Library/Jupyter collision.
#     Also removes any stale global "solvingmicrodsops" kernel from older setups.
# ============================================================================
if [ -f "$VENV_PATH/bin/python" ] && "$VENV_PATH/bin/python" -c "import ipykernel" 2>/dev/null; then
    # Remove stale global kernel if present
    for GLOBAL_K in "$HOME/Library/Jupyter/kernels/solvingmicrodsops" \
                     "$HOME/.local/share/jupyter/kernels/solvingmicrodsops"; do
        if [ -d "$GLOBAL_K" ]; then
            rm -rf "$GLOBAL_K"
            echo "  🧹 Removed stale global kernel at $GLOBAL_K"
        fi
    done

    KERNEL_DIR="$VENV_PATH/share/jupyter/kernels/python3"
    mkdir -p "$KERNEL_DIR"
    cat > "$KERNEL_DIR/kernel.json" <<KJSON
{
 "argv": [
  "$VENV_PATH/bin/python",
  "-m",
  "ipykernel_launcher",
  "-f",
  "{connection_file}"
 ],
 "display_name": "Python 3 (ipykernel)",
 "language": "python",
 "metadata": {
  "debugger": true
 }
}
KJSON
    echo "  🔑 Jupyter kernel spec written (venv-local)"
fi

# ============================================================================
# 3. Verify build scripts
# ============================================================================
echo ""
echo "🔧 Checking build scripts..."
for script in reproduce/docker/setup.sh reproduce/reproduce_environment_comp_uv.sh; do
    if [ -f "$script" ]; then
        echo "  ✅ $script"
    else
        echo "  ⚠️  $script (not found)"
    fi
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Setup Complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Quick start:"
echo "  pdflatex --version          # verify LaTeX"
echo "  python --version            # verify Python"
echo "  ./reproduce.sh --docs       # build SolvingMicroDSOPs.pdf"
echo ""
