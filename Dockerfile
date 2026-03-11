# SolvingMicroDSOPs Dockerfile
#
# Single Source of Truth (SST): reproduce/docker/setup.sh
# This Dockerfile uses setup.sh directly to ensure consistency with devcontainer builds.
# All TeX Live setup logic lives in setup.sh.
#
# Three contexts, one source:
#   1. VS Code Dev Container  → .devcontainer/devcontainer.json builds this image;
#                               workspace is MOUNTED (not COPY'd); TeX Live is baked in.
#   2. Standalone Docker      → docker build copies repo and calls setup.sh
#   3. BinderHub / MyBinder   → binder/ directory (lighter, no full TeX Live)
#
# Build argument for SST file path (relative to build context = repo root)
ARG SST_FILE_PATH=reproduce/required_latex_packages.txt

FROM mcr.microsoft.com/devcontainers/python:3.11

ARG SST_FILE_PATH

ENV PYTHONUNBUFFERED=1
ENV DEBIAN_FRONTEND=noninteractive

# ============================================================================
# Install system dependencies
# Keep in sync with SYSTEM_PACKAGES in reproduce/docker/setup.sh
# ============================================================================
# The MS base image ships a Yarn apt repo whose GPG key may be expired/missing;
# remove it so apt-get update doesn't fail on signature verification.
RUN rm -f /etc/apt/sources.list.d/yarn.list 2>/dev/null; \
    apt-get update && apt-get install -y \
    wget \
    perl \
    build-essential \
    fontconfig \
    curl \
    git \
    zsh \
    make \
    rsync \
    bibtool \
    && rm -rf /var/lib/apt/lists/*

# Install Oh My Zsh
RUN if [ ! -d /home/vscode/.oh-my-zsh ]; then \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || true && \
    chsh -s $(which zsh) vscode || true; \
    fi

# Create TeX Live font directories
RUN mkdir -p /home/vscode/.texlive2025/texmf-var/fonts/tfm \
             /home/vscode/.texlive2025/texmf-var/fonts/pk && \
    chmod -R u+w /home/vscode/.texlive2025/texmf-var 2>/dev/null || true && \
    chown -R vscode:vscode /home/vscode/.texlive2025

# Ensure vscode user has sudo access (required by setup.sh for tlmgr)
RUN echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/vscode && \
    chmod 0440 /etc/sudoers.d/vscode

# ============================================================================
# Pre-install UV (Python package manager)
# ============================================================================
USER vscode
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
USER root
RUN echo 'export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"' >> /home/vscode/.bashrc && \
    echo 'export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"' >> /home/vscode/.zshrc 2>/dev/null || true
ENV PATH="/home/vscode/.local/bin:/home/vscode/.cargo/bin:${PATH}"

# ============================================================================
# Copy SST files needed at image-build time
# (setup scripts + LaTeX package list)
# ============================================================================
WORKDIR /tmp/sst
COPY reproduce/docker/setup.sh     /usr/local/bin/setup.sh
COPY reproduce/docker/run-setup.sh /usr/local/bin/run-setup.sh
COPY ${SST_FILE_PATH}              /tmp/required_latex_packages.txt
RUN chmod +x /usr/local/bin/setup.sh /usr/local/bin/run-setup.sh

# ============================================================================
# Install TeX Live 2025 at image-build time (BAKED INTO IMAGE)
# Small subset only: scheme-basic + collection-basic + packages from SST file.
# NOT full TeX Live (scheme-full would be several GB).
# Single Source of Truth: reproduce/docker/setup.sh
#
# SKIP_PYTHON_SETUP=1: Python venv is architecture-specific and must be built
# at container startup on the actual hardware, not at image-build time.
# ============================================================================
WORKDIR /tmp
RUN wget -q https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz && \
    tar -xzf install-tl-unx.tar.gz && \
    rm install-tl-unx.tar.gz

# Minimal scheme (~100–150 MB); then we add collection-basic + SST packages only
RUN INSTALL_DIR=$(find . -maxdepth 1 -name "install-tl-*" -type d | head -1) && \
    cat > "$INSTALL_DIR/texlive.profile" <<'PROFILE'
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

RUN INSTALL_DIR=$(find /tmp -maxdepth 1 -name "install-tl-*" -type d | head -1) && \
    cd "$INSTALL_DIR" && \
    ./install-tl --profile=texlive.profile --no-interaction && \
    cd / && rm -rf /tmp/install-tl-*

# Set TeX Live PATH for subsequent RUN commands and for containers
ENV PATH="/usr/local/texlive/2025/bin/aarch64-linux:/usr/local/texlive/2025/bin/x86_64-linux:${PATH}"

# Write to /etc/profile.d so interactive shells pick up TeX Live
RUN TEXLIVE_BIN=$(find /usr/local/texlive/2025/bin -type d -mindepth 1 -maxdepth 1 | head -1) && \
    echo "export PATH=\"$TEXLIVE_BIN:\$PATH\"" > /etc/profile.d/texlive.sh && \
    chmod +x /etc/profile.d/texlive.sh

# Update tlmgr, install collection-basic (provides pdflatex)
RUN tlmgr update --self && \
    tlmgr install collection-basic

# Install all required packages from SST file
RUN PACKAGES=$(grep -v "^#\|^$\|^##" /tmp/required_latex_packages.txt | \
             sed "s/[[:space:]]*#.*//" | \
             tr "\n" " " | \
             sed "s/[[:space:]]\+/ /g" | xargs) && \
    PACKAGES="$PACKAGES latexmk" && \
    echo "📦 Installing $(echo $PACKAGES | wc -w) LaTeX packages from SST file..." && \
    tlmgr install $PACKAGES || \
    echo "⚠️  Some packages may be in collections (non-fatal)"

# Pre-generate commonly used fonts
RUN for font in cmr10 cmr12 cmbx10 cmbx12 cmti10 cmtt10; do \
        mktextfm $font >/dev/null 2>&1 || true; \
    done && mktexlsr

# Verify critical tools
RUN pdflatex --version && latexmk --version

# ============================================================================
# Workspace setup
# In devcontainer mode: /workspace is MOUNTED from the host at container start.
# In standalone mode:   /workspace is populated by the COPY below (if present).
# ============================================================================
RUN mkdir -p /workspace && chown -R vscode:vscode /workspace

WORKDIR /workspace

# Final PATH: both ARM and x86_64 TeX Live bin dirs (multi-arch)
ENV PATH="/usr/local/texlive/2025/bin/aarch64-linux:/usr/local/texlive/2025/bin/x86_64-linux:/home/vscode/.local/bin:/home/vscode/.cargo/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

EXPOSE 8888 8866

USER vscode
WORKDIR /workspace

# ============================================================================
# Entrypoint: build Python venv at first startup (architecture-specific)
# ============================================================================
RUN printf '%s\n' \
    '#!/bin/bash' \
    'set -e' \
    '' \
    'PLATFORM=$(uname -s | tr "[:upper:]" "[:lower:]")' \
    'ARCH=$(uname -m)' \
    'if [ "$PLATFORM" = "darwin" ]; then' \
    '    VENV_PATH="/workspace/.venv-darwin-$ARCH"' \
    'else' \
    '    VENV_PATH="/workspace/.venv-linux-$ARCH"' \
    'fi' \
    '' \
    'if [ ! -d "$VENV_PATH" ] || [ ! -f "$VENV_PATH/bin/python" ]; then' \
    '    echo "Building Python environment for $(uname -m) (one-time, 2-3 min)..."' \
    '    cd /workspace' \
    '    bash /workspace/reproduce/reproduce_environment_comp_uv.sh || {' \
    '        echo "❌ Failed to build Python environment"; exit 1; }' \
    '    echo "✅ Python environment ready"' \
    'else' \
    '    echo "ℹ️  Python environment already exists: $VENV_PATH"' \
    'fi' \
    '' \
    '[ -f ~/.bashrc ] && source ~/.bashrc || true' \
    'cd /workspace' \
    'exec "$@"' \
    > /home/vscode/entrypoint.sh && \
    chmod +x /home/vscode/entrypoint.sh

ENTRYPOINT ["/home/vscode/entrypoint.sh"]
# Default: run full reproduction (REMARK Tier 1). Override for a shell: docker run -it --entrypoint "" image /bin/bash
CMD ["./reproduce.sh"]
