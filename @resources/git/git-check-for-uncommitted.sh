#!/bin/bash
# Claude wrote this.  In "git" prompt originating Jun 1, 2024.

# Function to check for uncommitted changes
check_uncommitted_changes() {
  local dir=$1
  cd "$dir" || return 1

  # Check if the directory is a Git repository
  if git rev-parse --git-dir > /dev/null 2>&1; then
    # Check for uncommitted changes, but ignore untracked files
    if git status --porcelain --untracked-files=no | grep -q .; then
        echo "There are uncommitted changes in the repository at:"
        echo
        echo "$repo_dir"
        echo
        git status
        exit 2
    fi
  else
    echo "The directory $dir is not a Git repository"
    return 1
  fi
}

# Check if a directory is provided as an argument
if [[ $# -eq 0 ]]; then
  # No directory provided, use the current working directory
  dir="."
else
  # Directory provided as an argument
  dir="$1"
fi

# Call the function to check for uncommitted changes
check_uncommitted_changes "$dir"
exit $?
