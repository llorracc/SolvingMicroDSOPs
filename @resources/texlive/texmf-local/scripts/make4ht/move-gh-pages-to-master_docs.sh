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
# Create /tmp/docs and sync current branch to there

# # (should be on branch gh-pages when you do this)
# git checkout gh-pages # just in case

# [[ "$?" -ne 0 ]] && echo 'git checkout gh-pages failed; fix then hit return to continue' && say error && read answer

mkdir -p /tmp/"$stem"/docs
rm -f    /tmp/"$stem"/docs/*.* # in case there's something from the last try
rsync --delete-excluded --exclude '.git' -aqz . /tmp/"$stem"/docs

# prevent recursion
[[ -d /tmp/"$stem"/docs/docs ]] && rm -Rf /tmp/"$stem"/docs/docs

# Now restore gh-pages to its pristine state
git restore .

# This allows switching back to master:
git clean --force > /dev/null # delete all the unadded/uncommitted stuff

# docs is a dir in master
git checkout master

# Sync any new content from gh-pages to master/docs
rsync --delete-excluded --exclude '.git' -aqz /tmp/"$stem"/docs/ docs/

echo '' ; echo 'finishing '"$(basename $0) }}}"

