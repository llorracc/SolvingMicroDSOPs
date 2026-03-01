# reproduce/docker/

This directory contains the **Single Source of Truth** for container environment construction.

## Files

| File | Purpose |
|------|---------|
| `setup.sh` | **SST** — installs TeX Live 2025 and UV, then delegates Python venv creation to `reproduce/reproduce_environment_comp_uv.sh`. Called by the Dockerfile, devcontainer, and CI. |
| `run-setup.sh` | **Workspace finder** — locates `setup.sh` when the workspace root cannot be inferred from `$PWD` (used by `devcontainer.json` `postCreateCommand`). |

## Design

`setup.sh` is the single script that must be kept up-to-date when:
- The TeX Live package list changes (edit `reproduce/required_latex_packages.txt` instead)
- The Python version requirement changes (edit `pyproject.toml`)
- The UV installer URL changes

All other entry points (Dockerfile, `.devcontainer/devcontainer.json`, GitHub Actions) call `setup.sh` — they contain no environment-setup logic of their own.

## LaTeX packages

The list of tlmgr packages to install is maintained in:

```
reproduce/required_latex_packages.txt
```

This is the Single Source of Truth for LaTeX package selection. Edit that file rather than `setup.sh` when adding or removing packages.
