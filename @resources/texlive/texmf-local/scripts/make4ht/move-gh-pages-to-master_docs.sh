#!/bin/bash
# After compiling the html version on the gh-pages branch, copy to /tmp/docs
# then switch to master branch and retrieve from /tmp/docs its new contents

scriptDir="$(realpath $(dirname "$0"))" # get the path to this script itself

echo '' ; echo '{{{ starting '"$(basename $0)"

if [ "$#" -gt 1 ]; then
  echo "usage:   ${0##*/} <directory>"
  echo "example: ${0##*/} /Volumes/Sync/GitHub/llorracc/SolvingMicroDSOPs/SolvingMicroDSOPs-Latest"
  exit 1
fi
path="$1"
# scriptDir=/Volumes/Sync/GitHub/llorracc/SolvingMicroDSOPs/SolvingMicroDSOPs-make ; path=/Volumes/Sync/GitHub/llorracc/SolvingMicroDSOPs/SolvingMicroDSOPs-Public
stem="$(basename $path)"

cd "$path"

# ── Safety: refuse to destroy uncommitted work on master ──────────
# We are on the gh-pages branch (created from master HEAD).
# 'git restore .' + 'git clean' + 'git checkout master' below will
# obliterate any working-tree changes that were present when the branch
# was created.  Detect this by diffing the working tree against master's
# committed state for source files.
dirty_vs_master="$(git diff master --name-only -- '*.py' '*.tex' '*.md' '*.ipynb' '*.bib' '*.sh' '*.cfg' '*.sty' 2>/dev/null)"
if [[ -n "$dirty_vs_master" ]]; then
    echo "" >&2
    echo "FATAL: Source files differ from master's committed state:" >&2
    echo "$dirty_vs_master" >&2
    echo "" >&2
    echo "The working tree had uncommitted changes when the gh-pages" >&2
    echo "branch was created.  Refusing to destroy them." >&2
    echo "Commit or stash your changes on master, then re-run." >&2
    echo "" >&2
    exit 1
fi

mkdir -p /tmp/"$stem"/docs
rm -f    /tmp/"$stem"/docs/*.* # in case there's something from the last try
rsync --delete-excluded --exclude '.git' --no-links -aqz . /tmp/"$stem"/docs

# prevent recursion
[[ -d /tmp/"$stem"/docs/docs ]] && rm -Rf /tmp/"$stem"/docs/docs

# Now restore gh-pages to its pristine state
git restore .

# This allows switching back to master:
git clean --force -e '.venv*' > /dev/null # delete all the unadded/uncommitted stuff; keep .venv* untouched

# docs is a dir in master
git checkout master

# Sync any new content from gh-pages to master/docs
rsync --delete-excluded --exclude '.git' --no-links -aqz /tmp/"$stem"/docs/ docs/

echo '' ; echo 'finishing '"$(basename $0) }}}"

