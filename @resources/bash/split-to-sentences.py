#!/bin/sh
# DEPRECATION WRAPPER - DO NOT EDIT

# This is an auto-generated wrapper. Its purpose is to warn that the path
# used to call this script is deprecated and will be removed in the future.

# The real location of the scripts.
CANONICAL_PATH="$(dirname "$0")/../scripts/split-to-sentences.py"

# Print a warning message to standard error.
echo "
********************************************************************************
*** DEPRECATION WARNING ***
* You have accessed a script via the path: '@resources/bash'
* This path is deprecated and will be removed in a future version.
* Please update your code/configuration to use the canonical path: '@resources/scripts'
********************************************************************************
" >&2

# Execute the *real* script, passing along all command-line arguments.
exec "$CANONICAL_PATH" "$@"
