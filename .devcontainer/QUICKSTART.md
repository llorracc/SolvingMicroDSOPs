# DevContainer Quick Start Guide — SolvingMicroDSOPs

## How the container is built

The devcontainer is built from the root `Dockerfile` (not pulled from DockerHub).
TeX Live 2025 is **baked into the image** at build time — container startup is fast.
The Python virtual environment is built at first `postCreateCommand` for your architecture.

| Phase | What happens | When |
|-------|-------------|------|
| `docker build` | TeX Live 2025 + system packages installed | Once per image rebuild |
| `postCreateCommand` | Python venv built for your CPU arch | Once per container create |
| `postStartCommand` | Python venv activated | Every container start |

## First Open

Press `Cmd/Ctrl+Shift+P` → **"Dev Containers: Reopen in Container"**

The first open builds the image (10–15 min for TeX Live). Subsequent opens are fast.

## Simple Usage (After Container Starts)

```bash
./reproduce.sh --docs    # Build SolvingMicroDSOPs.pdf
```

No manual steps required — LaTeX and Python are ready automatically.

## Common Commands

```bash
./reproduce.sh --docs            # Build SolvingMicroDSOPs.pdf
./reproduce.sh --comp            # Full computation
./reproduce.sh --all             # Computation + documents
```

## Environment Testing

```bash
pdflatex --version
latexmk --version
python -c "import HARK; print('HARK', HARK.__version__)"
```

## Jupyter Lab (Optional)

```bash
jupyter lab --ip=0.0.0.0 --port=8888
```

Access at: <http://localhost:8888>

## Ports

| Port | Service |
|------|---------|
| 8888 | Jupyter Lab |
| 8866 | Voilà Dashboard |

## Troubleshooting

### Python environment not activated

```bash
source .venv-linux-x86_64/bin/activate    # Intel Linux
source .venv-linux-aarch64/bin/activate   # ARM Linux
# or rebuild from scratch:
./reproduce/reproduce_environment_comp_uv.sh
```

### LaTeX errors

```bash
cat SolvingMicroDSOPs.log
```

### Rebuild the image (e.g., after adding LaTeX packages)

`Cmd/Ctrl+Shift+P` → **"Dev Containers: Rebuild Container"**

After adding packages to `reproduce/required_latex_packages.txt`, a rebuild
is required (TeX Live packages are baked into the image, not installed at startup).

## File Locations

| Path | Contents |
|------|---------|
| `SolvingMicroDSOPs.tex` | Main document entry point |
| `SolvingMicroDSOPs.pdf` | Built PDF |
| `SolvingMicroDSOPs.ipynb` | Main Jupyter notebook |
| `Code/Python/` | Python replication code |
| `reproduce/` | Reproduction scripts |
| `reproduce/required_latex_packages.txt` | LaTeX package list (SST) |
| `.venv-linux-*/` | Architecture-specific Python venv |
| `/usr/local/texlive/2025/` | TeX Live installation (in image) |
