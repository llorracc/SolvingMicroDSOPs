#!/bin/bash

# Check if both arguments are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <path_to_source_repo> <head_branch>"
    exit 1
fi

path_to_source_repo="$1"
head_branch="$2"

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
if [[ -z $(git status --porcelain) ]]; then
    echo "Current branch is clean. Switching to $head_branch..."
    if git checkout "$head_branch"; then
        echo "Successfully switched to $head_branch"
    else
        echo "Error: Failed to switch to branch $head_branch"
        exit 1
    fi
else
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    echo "The currently active branch ($current_branch) in $path_to_source_repo has uncommitted changes, as can be seen from the git status message below; please correct this and run this script again"
    echo
    git status
    exit 1
fi
