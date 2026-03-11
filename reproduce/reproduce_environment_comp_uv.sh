#!/bin/bash
# SolvingMicroDSOPs Python Environment Setup (UV)
#
# Single Source of Truth (SST) for Python virtual-environment creation.
# Called by:
#   - reproduce/docker/setup.sh           (devcontainer postCreateCommand)
#   - Dockerfile entrypoint               (first container start)
#   - reproduce/build-and-test-docker.sh  (CI smoke test)
#   - Developers directly                 (local setup)
#
# Delegates to reproduce_environment.sh which contains the full implementation.
# Using this thin wrapper preserves the SST contract while keeping
# reproduce_environment.sh as the canonical maintainable file.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    # Being sourced — source the implementation too so the venv gets activated
    # in the calling shell.
    source "$SCRIPT_DIR/reproduce_environment.sh"
else
    bash "$SCRIPT_DIR/reproduce_environment.sh" "$@"
fi
