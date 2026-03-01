#!/bin/bash
set -e

echo "🚀 Setting up SolvingMicroDSOPs development environment with TeX Live 2025..."
echo "📦 METHOD: Small subset only — scheme-basic + collection-basic + packages from required_latex_packages.txt (NOT full TeX Live)"
echo ""
echo "Single Source of Truth (SST): reproduce/docker/setup.sh"
echo ""

START_TEXLIVE=$(date +%s)

# ============================================================================
# Helper Functions
# ============================================================================

check_disk_space() {
    local MIN_FREE_GB=${1:-5}
    if df -BG / &>/dev/null; then
        local AVAILABLE_GB=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
    else
        local AVAILABLE_GB=$(df -g / | awk 'NR==2 {print $4}')
    fi
    echo "📊 Checking disk space..."
    echo "   Available: ${AVAILABLE_GB}GB"
    echo "   Required: ${MIN_FREE_GB}GB"
    if [ "$AVAILABLE_GB" -lt "$MIN_FREE_GB" ]; then
        echo "❌ ERROR: Insufficient disk space!"
        echo "   Available: ${AVAILABLE_GB}GB, Required: ${MIN_FREE_GB}GB"
        df -h /
        exit 1
    fi
    echo "✅ Sufficient disk space available"
}

# Retry a command with exponential backoff
# Usage: retry_command <max_attempts> <command>
retry_command() {
    local MAX_ATTEMPTS=$1
    shift
    local ATTEMPT=1
    local DELAY=5
    while [ "$ATTEMPT" -le "$MAX_ATTEMPTS" ]; do
        echo "   Attempt $ATTEMPT/$MAX_ATTEMPTS..."
        if "$@"; then
            return 0
        fi
        if [ "$ATTEMPT" -lt "$MAX_ATTEMPTS" ]; then
            echo "   ⚠️  Command failed, retrying in ${DELAY} seconds..."
            sleep $DELAY
            DELAY=$((DELAY * 2))
        fi
        ATTEMPT=$((ATTEMPT + 1))
    done
    echo "❌ Command failed after $MAX_ATTEMPTS attempts"
    return 1
}

download_with_retry() {
    local URL=$1
    local OUTPUT=$2
    local MAX_ATTEMPTS=${3:-3}
    echo "📥 Downloading: $URL"
    retry_command "$MAX_ATTEMPTS" wget --show-progress --progress=bar:force "$URL" -O "$OUTPUT" || \
    retry_command "$MAX_ATTEMPTS" wget "$URL" -O "$OUTPUT"
}

# ============================================================================
# Workspace Detection
# ============================================================================

SCRIPT_PATH="${BASH_SOURCE[0]:-$0}"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"

# Priority chain for workspace detection (same pattern as HAFiscal SST):
# 1. /workspaces/<name>/reproduce/docker/ → /workspaces/<name>/
# 2. any path ending in .../reproduce/docker/ → go up two levels
# 3. ${workspaceFolder} env var (devcontainer)
# 4. ${GITHUB_WORKSPACE} env var (CI)
# 5. fallback: cwd

if [[ "$SCRIPT_DIR" =~ /workspaces/([^/]+)/reproduce/docker ]]; then
    WORKSPACE_NAME="${BASH_REMATCH[1]}"
    WORKSPACE_DIR="/workspaces/$WORKSPACE_NAME"
elif [[ "$SCRIPT_DIR" =~ /([^/]+)/reproduce/docker ]]; then
    WORKSPACE_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
elif [[ "$SCRIPT_PATH" =~ /workspaces/([^/]+)/ ]]; then
    WORKSPACE_NAME="${BASH_REMATCH[1]}"
    WORKSPACE_DIR="/workspaces/$WORKSPACE_NAME"
elif [ -n "${workspaceFolder}" ]; then
    WORKSPACE_DIR="${workspaceFolder}"
elif [ -n "${GITHUB_WORKSPACE}" ]; then
    WORKSPACE_DIR="${GITHUB_WORKSPACE}"
else
    if [ -d .git ]; then
        REPO_NAME=$(basename "$(git rev-parse --show-toplevel 2>/dev/null)" 2>/dev/null || basename "$PWD")
    else
        REPO_NAME=$(basename "$PWD" 2>/dev/null || echo "SolvingMicroDSOPs-Latest")
    fi
    WORKSPACE_DIR="/workspaces/${REPO_NAME}"
fi

if [ -d "$WORKSPACE_DIR" ]; then
    cd "$WORKSPACE_DIR"
    echo "✅ Working directory: $WORKSPACE_DIR"
else
    echo "❌ ERROR: Could not find workspace directory: $WORKSPACE_DIR"
    echo "   Script path: $SCRIPT_PATH"
    echo "   Script dir: $SCRIPT_DIR"
    echo "   PWD: $PWD"
    echo "   GITHUB_WORKSPACE: ${GITHUB_WORKSPACE:-<not set>}"
    echo "   workspaceFolder: ${workspaceFolder:-<not set>}"
    echo ""
    echo "   Available directories in /workspaces:"
    ls -la /workspaces/ 2>/dev/null || echo "   /workspaces does not exist"
    exit 1
fi

# ============================================================================
# 1. Install TeX Live 2025 from official installer
# ============================================================================
echo "📄 Installing TeX Live 2025 (scheme-basic)..."
check_disk_space 3

if [ "${SKIP_APT_GET:-}" != "1" ]; then
    echo "Installing prerequisites via apt-get..."
    if ! sudo apt-get update; then
        echo "❌ ERROR: Failed to update package lists"
        exit 1
    fi
    if ! sudo apt-get install -y wget perl build-essential fontconfig curl git zsh make rsync bibtool; then
        echo "❌ ERROR: Failed to install prerequisites"
        exit 1
    fi
else
    echo "⏭️  Skipping apt-get (SKIP_APT_GET=1)"
fi

echo "Downloading TeX Live 2025 installer..."
cd /tmp
rm -rf install-tl-unx.tar.gz install-tl-*

INSTALLER_URL="https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz"
if ! download_with_retry "$INSTALLER_URL" "install-tl-unx.tar.gz" 3; then
    echo "❌ ERROR: Failed to download TeX Live installer"
    exit 1
fi

echo "Extracting installer..."
if ! tar -xzf install-tl-unx.tar.gz; then
    echo "❌ ERROR: Failed to extract TeX Live installer"
    exit 1
fi

INSTALL_DIR=$(find . -maxdepth 1 -name "install-tl-*" -type d | head -1)
if [ -z "$INSTALL_DIR" ] || [ ! -d "$INSTALL_DIR" ]; then
    echo "❌ ERROR: Could not find installer directory after extraction"
    exit 1
fi

cd "$INSTALL_DIR"

cat > texlive.profile << 'PROFILE'
selected_scheme scheme-basic
TEXDIR /usr/local/texlive/2025
TEXMFLOCAL /usr/local/texlive/texmf-local
TEXMFHOME ~/texmf
TEXMFVAR ~/.texlive2025/texmf-var
TEXMFCONFIG ~/.texlive2025/texmf-config
instopt_adjustpath 1
instopt_adjustrepo 1
tlpdbopt_autobackup 0
tlpdbopt_desktop_integration 0
tlpdbopt_file_assocs 0
tlpdbopt_post_code 1
PROFILE

echo "Installing TeX Live 2025 scheme-basic (this may take 10-15 minutes)..."
if ! sudo ./install-tl --profile=texlive.profile --no-interaction; then
    echo "❌ ERROR: TeX Live installation failed"
    df -h /
    exit 1
fi

if [ ! -d "/usr/local/texlive/2025" ]; then
    echo "❌ ERROR: TeX Live installation directory not found"
    exit 1
fi

TEXLIVE_BIN=$(find /usr/local/texlive/2025/bin -type d -mindepth 1 -maxdepth 1 | head -1)
if [ -z "$TEXLIVE_BIN" ] || [ ! -d "$TEXLIVE_BIN" ]; then
    echo "❌ ERROR: Could not find TeX Live bin directory"
    exit 1
fi

export PATH="$TEXLIVE_BIN:$PATH"

# System-wide PATH setup
if [ -d "/etc/profile.d" ] && [ -w "/etc/profile.d" ]; then
    echo "export PATH=\"$TEXLIVE_BIN:\$PATH\"" | sudo tee /etc/profile.d/texlive.sh > /dev/null
    sudo chmod +x /etc/profile.d/texlive.sh
elif sudo mkdir -p /etc/profile.d 2>/dev/null; then
    echo "export PATH=\"$TEXLIVE_BIN:\$PATH\"" | sudo tee /etc/profile.d/texlive.sh > /dev/null
    sudo chmod +x /etc/profile.d/texlive.sh
fi

echo "export PATH=\"$TEXLIVE_BIN:\$PATH\"" >> ~/.bashrc
echo "export PATH=\"$TEXLIVE_BIN:\$PATH\"" >> ~/.zshrc 2>/dev/null || true

echo "Updating tlmgr..."
if ! retry_command 3 sudo "$TEXLIVE_BIN/tlmgr" update --self; then
    echo "⚠️  Warning: tlmgr self-update failed (may be OK if already up-to-date)"
fi

echo "Installing collection-basic (includes pdflatex)..."
if ! retry_command 3 sudo "$TEXLIVE_BIN/tlmgr" install collection-basic; then
    echo "❌ ERROR: Failed to install collection-basic"
    df -h /
    exit 1
fi

if ! command -v pdflatex >/dev/null 2>&1; then
    echo "❌ ERROR: pdflatex not found after installing collection-basic"
    exit 1
fi
echo "✅ pdflatex verified: $(which pdflatex)"

# ============================================================================
# Parse LaTeX packages from required_latex_packages.txt (SST)
# ============================================================================
parse_latex_packages() {
    local PACKAGES_FILE="${WORKSPACE_DIR}/reproduce/required_latex_packages.txt"
    if [ ! -f "$PACKAGES_FILE" ]; then
        echo "❌ ERROR: Required packages file not found: $PACKAGES_FILE" >&2
        exit 1
    fi
    echo "📄 Reading LaTeX packages from: $PACKAGES_FILE" >&2
    local PACKAGES=$(grep -v '^#\|^$\|^##' "$PACKAGES_FILE" | \
                     sed 's/[[:space:]]*#.*//' | \
                     tr '\n' ' ' | \
                     sed 's/[[:space:]]\+/ /g')
    PACKAGES="$PACKAGES latexmk"
    local PKG_COUNT=$(echo "$PACKAGES" | wc -w | tr -d ' ')
    echo "   Found $PKG_COUNT packages to install" >&2
    echo "$PACKAGES"
}

echo "Installing individual LaTeX packages..."
check_disk_space 2

LATEX_PACKAGES=$(parse_latex_packages)

install_packages_with_retry() {
    # shellcheck disable=SC2086
    sudo "$TEXLIVE_BIN/tlmgr" install $LATEX_PACKAGES 2>&1 | tee /tmp/tlmgr-install.log
    return "${PIPESTATUS[0]}"
}

if ! retry_command 2 install_packages_with_retry; then
    if [ -f /tmp/tlmgr-install.log ] && grep -q "package.*not present in repository" /tmp/tlmgr-install.log; then
        echo "⚠️  Some packages not found as standalone (may be in collections)"
    else
        echo "⚠️  tlmgr install had errors - will verify critical packages"
        if [ -f /tmp/tlmgr-install.log ]; then
            tail -20 /tmp/tlmgr-install.log
        fi
    fi
fi

# Verify latexmk
echo ""
echo "🔍 Verifying latexmk installation..."
if [ -f "$TEXLIVE_BIN/latexmk" ]; then
    echo "✅ latexmk found at: $TEXLIVE_BIN/latexmk"
    "$TEXLIVE_BIN/latexmk" -v | head -1
else
    echo "⚠️  latexmk not found, installing..."
    if ! retry_command 2 sudo "$TEXLIVE_BIN/tlmgr" install latexmk; then
        echo "❌ ERROR: Failed to install latexmk"
        exit 1
    fi
fi

echo "Updating font cache..."
"$TEXLIVE_BIN/mktexlsr" || true

echo "Configuring TeX Live font generation directories..."
mkdir -p ~/.texlive2025/texmf-var/fonts/tfm ~/.texlive2025/texmf-var/fonts/pk
chmod -R u+w ~/.texlive2025/texmf-var 2>/dev/null || true

echo "Pre-generating commonly used fonts..."
export PATH="$TEXLIVE_BIN:$PATH"
for font in cmr10 cmr12 cmbx10 cmbx12 cmti10 cmtt10; do
    echo "  Generating $font..."
    "$TEXLIVE_BIN/mktextfm" "$font" >/dev/null 2>&1 || true
done

END_TEXLIVE=$(date +%s)
TEXLIVE_DURATION=$((END_TEXLIVE - START_TEXLIVE))
echo "✅ TeX Live 2025 installation completed in ${TEXLIVE_DURATION}s"
echo "${TEXLIVE_DURATION}" > /tmp/texlive-install-time.txt

# Verify LaTeX
echo ""
echo "🔍 Verifying LaTeX installation..."
if command -v pdflatex >/dev/null 2>&1; then
    echo "✅ pdflatex found: $(which pdflatex)"
    pdflatex --version | head -3
else
    echo "❌ pdflatex not found!"
    exit 1
fi

echo ""
echo "🔍 Testing critical package availability..."
CRITICAL_CHECKS=(
    "amsmath.sty:amsmath"
    "hyperref.sty:hyperref"
    "geometry.sty:geometry"
    "natbib.sty:natbib"
    "snapshot.sty:snapshot"
    "scrartcl.cls:koma-script"
    "subfiles.sty:subfiles"
    "mathtools.sty:mathtools"
    "listings.sty:listings"
)
MISSING_CRITICAL=0
for check in "${CRITICAL_CHECKS[@]}"; do
    FILE="${check%%:*}"
    PKG_NAME="${check##*:}"
    if "$TEXLIVE_BIN/kpsewhich" "$FILE" >/dev/null 2>&1; then
        echo "  ✅ $PKG_NAME"
    else
        echo "  ❌ $PKG_NAME (CRITICAL - $FILE not found)"
        MISSING_CRITICAL=1
    fi
done

if [ $MISSING_CRITICAL -eq 1 ]; then
    echo ""
    echo "❌ ERROR: Critical LaTeX packages are missing!"
    exit 1
fi

# ============================================================================
# 2. Install UV (Python package manager)
# ============================================================================

if [ "${SKIP_PYTHON_SETUP:-}" = "1" ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "ℹ️  Skipping Python environment setup (SKIP_PYTHON_SETUP=1)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Python environment will be built at container startup"
    echo ""
    echo "📊 Installation Summary:"
    echo "  - TeX Live Version: 2025"
    echo "  - Scheme: basic + individual packages"
    echo "  - TeX Live installation time: ${TEXLIVE_DURATION}s"
    echo "  - Python environment: Will be built at startup"
    echo ""
    exit 0
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Installing UV (Python package manager)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

START_UV=$(date +%s)

curl -LsSf https://astral.sh/uv/install.sh | sh
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
echo "export PATH=\"\$HOME/.local/bin:\$HOME/.cargo/bin:\$PATH\"" >> ~/.bashrc
if command -v zsh >/dev/null 2>&1; then
    [ -f ~/.zshrc ] || touch ~/.zshrc
    if ! grep -q "\.local/bin.*\.cargo/bin" ~/.zshrc 2>/dev/null; then
        echo "export PATH=\"\$HOME/.local/bin:\$HOME/.cargo/bin:\$PATH\"" >> ~/.zshrc
    fi
fi

if ! command -v uv >/dev/null 2>&1; then
    if [ -f "$HOME/.local/bin/uv" ]; then
        export PATH="$HOME/.local/bin:$PATH"
    elif [ -f "$HOME/.cargo/bin/uv" ]; then
        export PATH="$HOME/.cargo/bin:$PATH"
    else
        echo "❌ UV installation failed!"
        exit 1
    fi
fi
echo "✅ UV installed: $(which uv)"
uv --version

END_UV=$(date +%s)
UV_DURATION=$((END_UV - START_UV))

# ============================================================================
# 3. Set up Python environment
# ============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🐍 Setting up Python environment with UV"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

cd "$WORKSPACE_DIR"
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

if ! command -v uv >/dev/null 2>&1; then
    echo "❌ UV not available"
    exit 1
fi

if [ -f "./reproduce/reproduce_environment_comp_uv.sh" ]; then
    echo "Using reproduce_environment_comp_uv.sh for environment setup..."
    bash ./reproduce/reproduce_environment_comp_uv.sh
else
    echo "Using direct uv sync..."
    if ! uv sync --all-groups; then
        echo "❌ uv sync failed"
        exit 1
    fi
fi

# Detect platform-specific venv
PLATFORM=""
ARCH=""
case "$(uname -s)" in
    Darwin) PLATFORM="darwin" ;;
    Linux)  PLATFORM="linux" ;;
esac
if [ "$PLATFORM" = "darwin" ]; then
    if sysctl -n hw.optional.arm64 2>/dev/null | grep -q 1; then
        ARCH="arm64"
    else
        ARCH="x86_64"
    fi
else
    ARCH="$(uname -m)"
fi
PLATFORM_VENV=".venv-${PLATFORM}-${ARCH}"

if [ -d "$PLATFORM_VENV" ] && [ -f "$PLATFORM_VENV/bin/python" ]; then
    VENV_PATH="$(pwd)/$PLATFORM_VENV"
elif [ -d ".venv" ] && [ -f ".venv/bin/python" ]; then
    VENV_PATH="$(pwd)/.venv"
else
    echo "❌ Virtual environment was not created"
    exit 1
fi

echo "✅ Virtual environment verified at: $VENV_PATH"

# Configure shell auto-activation (platform and architecture-specific)
# shellcheck disable=SC2016
ACTIVATION_CODE='
# Auto-activate SolvingMicroDSOPs virtual environment (platform and architecture-specific)
if [ -z "${VIRTUAL_ENV:-}" ]; then
    SOLVINGMICRODSOPS_WORKSPACE="/workspace"
    if [ ! -d "$SOLVINGMICRODSOPS_WORKSPACE" ]; then
        for _try_dir in "/workspace" "$HOME/workspace"; do
            [ -d "$_try_dir" ] && SOLVINGMICRODSOPS_WORKSPACE="$_try_dir" && break
        done
    fi
    SOLVINGMICRODSOPS_VENV=""
    SOLVINGMICRODSOPS_ARCH=$(uname -m)
    case "$(uname -s)" in
        Darwin)
            if [ -f "$SOLVINGMICRODSOPS_WORKSPACE/.venv-darwin-$SOLVINGMICRODSOPS_ARCH/bin/activate" ]; then
                SOLVINGMICRODSOPS_VENV="$SOLVINGMICRODSOPS_WORKSPACE/.venv-darwin-$SOLVINGMICRODSOPS_ARCH"
            fi
            ;;
        Linux)
            if [ -f "$SOLVINGMICRODSOPS_WORKSPACE/.venv-linux-$SOLVINGMICRODSOPS_ARCH/bin/activate" ]; then
                SOLVINGMICRODSOPS_VENV="$SOLVINGMICRODSOPS_WORKSPACE/.venv-linux-$SOLVINGMICRODSOPS_ARCH"
            fi
            ;;
    esac
    if [ -n "$SOLVINGMICRODSOPS_VENV" ] && [ -f "$SOLVINGMICRODSOPS_VENV/bin/activate" ]; then
        # shellcheck source=/dev/null
        source "$SOLVINGMICRODSOPS_VENV/bin/activate"
    fi
fi'

if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q "Auto-activate SolvingMicroDSOPs virtual environment" "$HOME/.bashrc" 2>/dev/null; then
        echo "$ACTIVATION_CODE" >> "$HOME/.bashrc"
        echo "✅ Added activation code to ~/.bashrc"
    fi
fi
if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "Auto-activate SolvingMicroDSOPs virtual environment" "$HOME/.zshrc" 2>/dev/null; then
        echo "$ACTIVATION_CODE" >> "$HOME/.zshrc"
        echo "✅ Added activation code to ~/.zshrc"
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ TeX Live 2025 + UV setup complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📊 Installation Summary:"
echo "  - TeX Live Version: 2025"
echo "  - Scheme: basic + individual packages"
echo "  - TeX Live installation time: ${TEXLIVE_DURATION}s"
echo "  - UV installation time: ${UV_DURATION}s"
echo "  - Virtual environment: $VENV_PATH"
