#!/bin/bash
# SolvingMicroDSOPs Environment Setup with UV
# Creates platform- and architecture-specific venvs: .venv-{platform}-{arch}
# e.g. .venv-darwin-arm64, .venv-linux-x86_64
#
# Usage:
#   source reproduce/reproduce_environment.sh   # create + activate
#   bash   reproduce/reproduce_environment.sh   # create only

set -e

# Deactivate conda if active to avoid architecture mismatches
if command -v conda >/dev/null 2>&1; then
    if [ -n "${CONDA_DEFAULT_ENV:-}" ] || [ -n "${CONDA_PREFIX:-}" ]; then
        echo "Detected active conda environment - deactivating for clean venv creation"
        for i in $(seq 1 5); do
            conda deactivate 2>/dev/null || true
            [ -z "${CONDA_DEFAULT_ENV:-}" ] && break
        done
        unset CONDA_DEFAULT_ENV CONDA_PREFIX CONDA_PYTHON_EXE CONDA_SHLVL CONDA_EXE _CE_CONDA _CE_M
    fi
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# ---------------------------------------------------------------------------
# Platform / architecture detection
# ---------------------------------------------------------------------------
get_platform_venv_path() {
    local platform="" arch=""

    case "$(uname -s)" in
        Darwin) platform="darwin" ;;
        Linux)  platform="linux" ;;
        *)      platform="" ;;
    esac

    if [[ "$(uname -s)" == "Darwin" ]]; then
        if sysctl -n hw.optional.arm64 2>/dev/null | grep -q 1; then
            arch="arm64"
        else
            arch="x86_64"
        fi
    else
        arch="$(uname -m)"
    fi

    case "$arch" in
        arm64)   arch="arm64" ;;
        aarch64) arch="aarch64" ;;
        x86_64)  arch="x86_64" ;;
    esac

    if [[ -n "$platform" ]] && [[ -n "$arch" ]]; then
        echo "$PROJECT_ROOT/.venv-$platform-$arch"
    elif [[ -n "$platform" ]]; then
        echo "$PROJECT_ROOT/.venv-$platform"
    else
        echo "$PROJECT_ROOT/.venv"
    fi
}

# ---------------------------------------------------------------------------
# Ensure python/python3 symlinks exist in the venv
# uv often omits these; create them from pyvenv.cfg "home" entry.
# ---------------------------------------------------------------------------
ensure_venv_python_links() {
    local venv="$1"
    if [[ -z "$venv" ]]; then
        return 0
    fi
    if [[ ! -d "$venv/bin" ]]; then
        return 0
    fi

    # Already has a working python — nothing to do
    if [[ -x "$venv/bin/python" ]]; then
        return 0
    fi

    # Read the Python home from pyvenv.cfg
    local python_home=""
    if [[ -f "$venv/pyvenv.cfg" ]]; then
        python_home=$(grep '^home' "$venv/pyvenv.cfg" | sed 's/^home *= *//')
    fi
    if [[ -z "$python_home" ]]; then
        return 0
    fi

    # Find the versioned python binary (e.g. python3.10)
    local versioned=""
    for candidate in "$python_home"/python3.*; do
        if [[ -x "$candidate" ]] && [[ "$candidate" != *-config ]]; then
            versioned="$candidate"
            break
        fi
    done
    if [[ -z "$versioned" ]]; then
        if [[ -x "$python_home/python3" ]]; then
            versioned="$python_home/python3"
        elif [[ -x "$python_home/python" ]]; then
            versioned="$python_home/python"
        fi
    fi
    if [[ -z "$versioned" ]]; then
        return 0
    fi

    local basename_versioned
    basename_versioned=$(basename "$versioned")

    # Create chain: python3.X -> real binary, python3 -> python3.X, python -> python3
    if [[ ! -e "$venv/bin/$basename_versioned" ]]; then
        ln -sf "$versioned" "$venv/bin/$basename_versioned"
    fi
    if [[ ! -e "$venv/bin/python3" ]]; then
        ln -sf "$basename_versioned" "$venv/bin/python3"
    fi
    if [[ ! -e "$venv/bin/python" ]]; then
        ln -sf "python3" "$venv/bin/python"
    fi

    echo "  Created python symlinks in $(basename "$venv")/bin/"
}

# ---------------------------------------------------------------------------
# Migration helpers
# ---------------------------------------------------------------------------
migrate_legacy_venvs() {
    local platform=""
    case "$(uname -s)" in
        Darwin) platform="darwin" ;;
        Linux)  platform="linux" ;;
        *)      return 0 ;;
    esac

    local old_platform_venv="$PROJECT_ROOT/.venv-$platform"

    # Migrate platform-only venv (e.g. .venv-darwin -> .venv-darwin-arm64)
    if [[ -d "$old_platform_venv" ]] && [[ ! -d "$VENV_PATH" ]]; then
        if [[ -f "$old_platform_venv/bin/python" ]]; then
            local detected_arch
            detected_arch=$("$old_platform_venv/bin/python" -c "import platform; print(platform.machine())" 2>/dev/null || echo "")
            if [[ -n "$detected_arch" ]]; then
                local target="$PROJECT_ROOT/.venv-$platform-$detected_arch"
                echo "Migrating .venv-$platform -> .venv-$platform-$detected_arch"
                mv "$old_platform_venv" "$target"
            fi
        else
            rm -rf "$old_platform_venv"
        fi
    fi

    # Migrate generic .venv directory (not a symlink) to platform-specific path
    if [[ -d "$PROJECT_ROOT/.venv" ]] && [[ ! -L "$PROJECT_ROOT/.venv" ]] && [[ ! -d "$VENV_PATH" ]]; then
        echo "Migrating legacy .venv -> $VENV_NAME"
        mv "$PROJECT_ROOT/.venv" "$VENV_PATH"
    fi

    # Remove stale .venv symlink only if its target no longer exists
    if [[ -L "$PROJECT_ROOT/.venv" ]] && [[ ! -e "$PROJECT_ROOT/.venv" ]]; then
        rm -f "$PROJECT_ROOT/.venv"
    fi
}

# ---------------------------------------------------------------------------
# Ensure UV is findable
# ---------------------------------------------------------------------------
ensure_uv_in_path() {
    case ":$PATH:" in
        *":$HOME/.local/bin:"*) ;;
        *) export PATH="$HOME/.local/bin:$PATH" ;;
    esac
    case ":$PATH:" in
        *":$HOME/.cargo/bin:"*) ;;
        *) export PATH="$HOME/.cargo/bin:$PATH" ;;
    esac
}

ensure_uv_in_path

# ---------------------------------------------------------------------------
# Create/update .venv symlink pointing to the platform-specific venv.
# This makes .venv a standard entry point for VS Code, Cursor, and other
# tools while preserving per-platform venvs on shared filesystems.
# The devcontainer's post-create.sh does the same thing.
# ---------------------------------------------------------------------------
ensure_venv_symlink() {
    local venv_path="$1"
    local venv_name
    venv_name=$(basename "$venv_path")
    local link="$PROJECT_ROOT/.venv"

    if [[ -L "$link" ]]; then
        local current
        current=$(readlink "$link")
        if [[ "$current" != "$venv_name" ]]; then
            rm -f "$link"
            ln -s "$venv_name" "$link"
            echo "  Updated .venv -> $venv_name"
        fi
    elif [[ -d "$link" ]]; then
        # Legacy shim directory — remove it
        rm -rf "$link"
        ln -s "$venv_name" "$link"
        echo "  Replaced .venv/ shim directory with symlink -> $venv_name"
    elif [[ ! -e "$link" ]]; then
        ln -s "$venv_name" "$link"
        echo "  Created .venv -> $venv_name"
    fi
}

# ---------------------------------------------------------------------------
# Resolve venv path
# ---------------------------------------------------------------------------
VENV_PATH=$(get_platform_venv_path)
VENV_NAME=$(basename "$VENV_PATH")

echo "========================================"
echo "SolvingMicroDSOPs Environment Setup (UV)"
echo "========================================"
echo ""
echo "Platform: $(uname -s) ($(uname -m))"
echo "Venv:     $VENV_NAME"
echo ""

# ---------------------------------------------------------------------------
# Step 0: Migrate legacy venvs
# ---------------------------------------------------------------------------
migrate_legacy_venvs

# Refresh after possible migration
VENV_PATH=$(get_platform_venv_path)
VENV_NAME=$(basename "$VENV_PATH")

# ---------------------------------------------------------------------------
# Step 1: If valid venv already exists, just report and activate
# ---------------------------------------------------------------------------
# First, try to repair missing python symlinks (uv quirk)
ensure_venv_python_links "$VENV_PATH"

if [[ -d "$VENV_PATH" ]] && [[ -f "$VENV_PATH/bin/python" ]]; then
    PYTHON_VERSION=$("$VENV_PATH/bin/python" --version 2>&1 | awk '{print $2}')
    PYTHON_ARCH=$("$VENV_PATH/bin/python" -c "import platform; print(platform.machine())" 2>/dev/null || echo "unknown")
    echo "Found existing environment at $VENV_NAME/"
    echo "  Python: $PYTHON_VERSION ($PYTHON_ARCH)"

    if "$VENV_PATH/bin/python" -c "import HARK" 2>/dev/null; then
        HARK_VERSION=$("$VENV_PATH/bin/python" -c "import HARK; print(HARK.__version__)" 2>/dev/null || echo "unknown")
        echo "  HARK:   $HARK_VERSION"
    fi
    echo ""

    ensure_venv_symlink "$VENV_PATH"

    # Activate if being sourced
    if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
        source "$VENV_PATH/bin/activate"
        echo "Environment activated."
    else
        echo "To activate: source $VENV_NAME/bin/activate"
    fi
    echo ""
    return 0 2>/dev/null || exit 0
fi

# ---------------------------------------------------------------------------
# Step 2: Ensure UV is installed
# ---------------------------------------------------------------------------
if ! command -v uv >/dev/null 2>&1; then
    echo "UV is not installed."
    echo ""
    if [[ -n "${CI:-}" ]] || [[ ! -t 0 ]]; then
        echo "Installing UV automatically (non-interactive mode)..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        ensure_uv_in_path
    else
        echo "Installation options:"
        if command -v brew >/dev/null 2>&1; then
            echo "  1) Homebrew:  brew install uv  (recommended)"
            echo "  2) Curl:      curl -LsSf https://astral.sh/uv/install.sh | sh"
            echo "  3) pip+venv:  standard Python (slower)"
            echo -n "Choose [1-3] or N to cancel: "
        else
            echo "  1) Curl:      curl -LsSf https://astral.sh/uv/install.sh | sh"
            echo "  2) pip+venv:  standard Python (slower)"
            echo -n "Choose [1-2] or N to cancel: "
        fi
        read -r response
        case "$response" in
            1)
                if command -v brew >/dev/null 2>&1; then
                    brew install uv
                else
                    curl -LsSf https://astral.sh/uv/install.sh | sh
                fi
                ensure_uv_in_path
                ;;
            2)
                if command -v brew >/dev/null 2>&1; then
                    curl -LsSf https://astral.sh/uv/install.sh | sh
                    ensure_uv_in_path
                else
                    USE_PIP_FALLBACK=true
                fi
                ;;
            3) USE_PIP_FALLBACK=true ;;
            [Nn]*) echo "Cancelled."; return 1 2>/dev/null || exit 1 ;;
            *) echo "Invalid choice"; return 1 2>/dev/null || exit 1 ;;
        esac
    fi

    if [[ "${USE_PIP_FALLBACK:-false}" != "true" ]] && ! command -v uv >/dev/null 2>&1; then
        echo "UV installation failed. Falling back to pip+venv."
        USE_PIP_FALLBACK=true
    fi
fi

# ---------------------------------------------------------------------------
# pip+venv fallback
# ---------------------------------------------------------------------------
if [[ "${USE_PIP_FALLBACK:-false}" == "true" ]]; then
    cd "$PROJECT_ROOT"
    if ! command -v python3 >/dev/null 2>&1; then
        echo "Python 3 not found."; return 1 2>/dev/null || exit 1
    fi
    [[ ! -d "$VENV_PATH" ]] && python3 -m venv "$VENV_PATH"
    source "$VENV_PATH/bin/activate"
    python -m pip install --upgrade pip --quiet
    echo "Installing dependencies (may take 2-3 minutes)..."
    if [[ -f "pyproject.toml" ]]; then
        pip install -e . --quiet 2>/dev/null || pip install . --quiet
    fi
    echo ""
    ensure_venv_symlink "$VENV_PATH"
    echo "Environment ready: $VENV_NAME/"
    return 0 2>/dev/null || exit 0
fi

# ---------------------------------------------------------------------------
# Step 3: Create venv via UV
# ---------------------------------------------------------------------------
cd "$PROJECT_ROOT"

# Remove stale .venv symlink so UV doesn't get confused
# (If it's a real directory — legacy shim — remove it too)
if [[ -L ".venv" ]]; then
    rm -f .venv
elif [[ -d ".venv" ]]; then
    rm -rf .venv
fi

# Try to repair an incomplete venv (missing python) before giving up on it
if [[ -d "$VENV_PATH" ]] && [[ ! -f "$VENV_PATH/bin/python" ]]; then
    ensure_venv_python_links "$VENV_PATH"
fi

# If still no python, remove and recreate
if [[ -d "$VENV_PATH" ]] && [[ ! -f "$VENV_PATH/bin/python" ]]; then
    echo "Removing incomplete venv at $VENV_NAME (no python binary)..."
    rm -rf "$VENV_PATH"
fi

if [[ ! -d "$VENV_PATH" ]]; then
    echo "Creating virtual environment at $VENV_NAME..."
    ensure_uv_in_path
    if [[ "$(uname -m)" == "arm64" ]]; then
        arch -arm64 uv venv "$VENV_PATH"
    else
        uv venv "$VENV_PATH"
    fi
    # uv often omits python symlinks — create them now
    ensure_venv_python_links "$VENV_PATH"
    echo ""
fi

# ---------------------------------------------------------------------------
# Step 4: Install / sync dependencies
# ---------------------------------------------------------------------------
echo "Syncing dependencies..."
export UV_PROJECT_ENVIRONMENT="$VENV_PATH"
if [[ "$(uname -m)" == "arm64" ]]; then
    arch -arm64 uv sync --all-groups
else
    uv sync --all-groups
fi
echo ""

# ---------------------------------------------------------------------------
# Step 5: Symlink, summary, and activation
# ---------------------------------------------------------------------------
ensure_venv_symlink "$VENV_PATH"

echo "========================================"
echo "Setup Summary"
echo "========================================"
echo "Virtual environment: $VENV_NAME/"
if [[ -f "$VENV_PATH/bin/python" ]]; then
    echo "Python: $("$VENV_PATH/bin/python" --version 2>&1 | awk '{print $2}') ($("$VENV_PATH/bin/python" -c "import platform; print(platform.machine())" 2>/dev/null))"
fi
echo ""

if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    source "$VENV_PATH/bin/activate"
    echo "Environment activated."
else
    echo "To activate: source $VENV_NAME/bin/activate"
fi
echo ""
echo "Verify:"
echo "  python --version"
echo "  python -c 'import HARK; print(HARK.__version__)'"
echo ""
