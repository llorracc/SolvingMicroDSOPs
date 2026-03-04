# binder/

This directory configures the BinderHub / MyBinder environment.

## Files

| File | Purpose |
|------|---------|
| `requirements.txt` | Python packages installed by BinderHub via pip |
| `apt.txt` | System packages installed by BinderHub via apt-get |
| `environment.yml` | Conda environment spec (symlink to root `environment.yml`) |
| `postBuild` | Post-build hook (warms up matplotlib font cache) |

## BinderHub vs Docker/devcontainer

BinderHub has constraints that prevent using the same setup as the full Docker image:

- **No root access during build** — so the TeX Live 2025 installer cannot be run
- **Build time limits** — so `texlive-full` cannot be installed; we use `texlive-latex-base` + `texlive-latex-recommended` from apt instead

This is a pragmatic trade-off: Binder is suitable for notebooks that do not require the full TeX Live 2025 distribution. For full reproducibility (including PDF document builds), use the Docker image or the VS Code Dev Container.

## Full environment

For the complete reproducible environment see:

- `reproduce/docker/setup.sh` — Single Source of Truth
- `Dockerfile` — standalone Docker image
- `.devcontainer/devcontainer.json` — VS Code Dev Container
