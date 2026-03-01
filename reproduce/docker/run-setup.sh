#!/bin/bash
# Helper script to find and run setup.sh during container build.
# Called by postCreateCommand in .devcontainer/devcontainer.json.
# The indirection exists because the workspace path may vary
# (e.g., /workspaces/SolvingMicroDSOPs-Latest/ vs /workspaces/SolvingMicroDSOPs-Public/).

set -e

echo "🔍 Searching for setup.sh..."
echo "Current directory: $(pwd)"
echo "Contents of /workspaces:"
ls -la /workspaces/ 2>/dev/null || echo "  /workspaces does not exist yet"

WORKSPACE_DIRS=$(find /workspaces -maxdepth 1 -type d 2>/dev/null | grep -v '^/workspaces$' || echo '')

if [ -n "$WORKSPACE_DIRS" ]; then
    echo "Found workspace directories:"
    echo "$WORKSPACE_DIRS"
    for DIR in $WORKSPACE_DIRS; do
        if [ -f "$DIR/reproduce/docker/setup.sh" ]; then
            echo "✅ Found setup.sh at: $DIR/reproduce/docker/setup.sh"
            cd "$DIR"
            echo "Changed to directory: $(pwd)"
            bash reproduce/docker/setup.sh
            exit 0
        fi
    done
fi

# Fallback: try hardcoded paths for known repo variants
REPO_NAME=$(basename "$PWD" 2>/dev/null || echo "SolvingMicroDSOPs-Latest")
for SCRIPT_PATH in \
    "/workspaces/${REPO_NAME}/reproduce/docker/setup.sh" \
    "/workspaces/SolvingMicroDSOPs-Latest/reproduce/docker/setup.sh" \
    "/workspaces/SolvingMicroDSOPs-Public/reproduce/docker/setup.sh"; do
    if [ -f "$SCRIPT_PATH" ]; then
        echo "✅ Using hardcoded path: $SCRIPT_PATH"
        cd "$(dirname "$(dirname "$(dirname "$SCRIPT_PATH")")")"
        bash reproduce/docker/setup.sh
        exit 0
    fi
done

echo "❌ setup.sh not found. Tried:"
echo "  - Searched /workspaces for reproduce/docker/setup.sh"
echo "  - Hardcoded paths for SolvingMicroDSOPs variants"
find /workspaces -name setup.sh -path "*/reproduce/docker/setup.sh" 2>/dev/null || echo "    (no results)"
exit 1
