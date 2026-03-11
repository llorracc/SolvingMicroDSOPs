# Terminal Quick Start — SolvingMicroDSOPs DevContainer

This guide is for users interacting with the devcontainer via a terminal
(SSH, Docker exec, or VS Code integrated terminal).

## Check environment is ready

```bash
# Python
python --version
python -c "import HARK; print('HARK', HARK.__version__)"

# LaTeX
pdflatex --version
latexmk --version
```

## Build the document

```bash
cd /workspace          # or /workspaces/SolvingMicroDSOPs-Latest/
./reproduce.sh --docs
```

## Run the notebook

```bash
jupyter lab --ip=0.0.0.0 --port=8888 --no-browser
# Then open http://localhost:8888 in your browser
```

## Activate Python environment manually

```bash
# Detect your architecture
uname -m   # e.g., x86_64 or aarch64

# Activate the matching venv
source .venv-linux-$(uname -m)/bin/activate
```

## Re-run environment setup

```bash
bash reproduce/docker/setup.sh
# or just Python:
bash reproduce/reproduce_environment_comp_uv.sh
```

## Useful paths

```
/workspace/                               → Repo root
/usr/local/texlive/2025/bin/*/            → TeX Live binaries
~/.local/bin/uv                           → UV package manager
/workspace/.venv-linux-<arch>/bin/python  → Python
```
