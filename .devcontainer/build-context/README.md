# .devcontainer/build-context/

This directory exists to match the HAFiscal container architecture pattern.

For SolvingMicroDSOPs, the LaTeX package list (Single Source of Truth) lives at:

    reproduce/required_latex_packages.txt

The Dockerfile references it via the `SST_FILE_PATH` build argument:

    ARG SST_FILE_PATH=reproduce/required_latex_packages.txt

Because the `devcontainer.json` sets `"context": ".."` (the repo root),
`reproduce/required_latex_packages.txt` is directly accessible to the Dockerfile
during `docker build`. No copy into this directory is needed.

If you add packages to `reproduce/required_latex_packages.txt`, rebuild the
container image (`Dev Containers: Rebuild Container`) for the changes to take effect.
