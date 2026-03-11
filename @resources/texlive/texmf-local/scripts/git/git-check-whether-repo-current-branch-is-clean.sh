#!/bin/bash

# Check if the argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <path_to_source_repo>"
    exit 1
fi

path_to_source_repo="$1"

# Change to the specified repository directory
cd "$path_to_source_repo" || {
    echo "Error: Unable to change to directory $path_to_source_repo"
    exit 1
}

# Check if it's a git repository
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "Error: $path_to_source_repo is not a git repository"
    exit 1
fi

# Check if the current branch is clean
echo 
if [[ -z $(git status --porcelain) ]]; then
    echo "Current branch is clean."
    echo
else
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    echo "The currently active branch ($current_branch) in $path_to_source_repo has uncommitted changes, as can be seen from the git status message below; please correct this and run this script again"
    echo
    git status
    exit 1
fi
