#!/bin/bash
# creates html using make4ht for files in texfile_lst

# Assumes directory structure
# -root		    (e.g. GitHub/llorracc)
#  - base	    (e.g. SolvingMicroDSOPs) 
#    - base-Latest  (e.g. SolvingMicroDSOPs-Latest)
#      - file.tex   (e.g. SolvingMicroDSOPs.tex)
#    - base-Public  (e.g. SolvingMicroDSOPs-Public)
#      - file.tex   (e.g. SolvingMicroDSOPs.tex)

# Validate number of arguments
if [ $# -ne 4 ]; then
    echo "Usage: $0 root base vers branch_html texfile_lst"
    echo "Example:"
    echo "$0 /Volumes/Sync/GitHub-Projects SolvingMicroDSOPs Latest \"SolvingMicroDSOPs,cctwMoM\""
    exit 1
fi

root="$1"	 # path to project 
base="$2"	 # base is project/paper name
vers="$3"	 # source version (Public or Latest)
texfile_lst="$4" # comma-separated list of files to process

# Validate texfile_lst format
if [[ ! "$texfile_lst" =~ ^[a-zA-Z0-9_]+(,[a-zA-Z0-9_]+)*$ ]]; then
    echo "Error: texfile_lst should be a comma-separated list of strings"
    exit 1
fi

# comma-separated list of files to process passed like "SolvingMicroDSOPs,cctwMoM"
IFS=',' read -ra texfile_lst <<< "$texfile_lst"

this_dir="$(dirname -- "$0")"

# example:
# root=/Volumes/Sync/GitHub-Projects ; base=SolvingMicroDSOPs ; vers=Latest ; this_dir=/Volumes/Sync/GitHub/llorracc/SolvingMicroDSOPs/SolvingMicroDSOPs-Latest/@resources/texlive/texmf-local/scripts/make4ht ; texfile_lst="SolvingMicroDSOPs cctwMoM"

# for interactive debugging, paste code starting with root= to
# the command line, in which case is_sourced=false to prevent exit
is_sourced=true && [[ "${BASH_SOURCE[0]}" == "${0}" ]] && is_sourced=false

cd "$this_dir" # other scripts are in the same directory as this one

# Locate the directories containing other scripts 
scripts_rel="$(<.rel-path-to-scripts-root)" # dotfile allows portability
scripts_abs=$(realpath "$(<.rel-path-to-scripts-root)")
scripts_git=$(realpath "$scripts_abs/git")
texmf_local=$(realpath $scripts_abs/..)  # scripts is a subdirectory in texmf-local
texlive_abs=$(realpath $texmf_local/..)  # which is in texlive
resrces_abs=$(realpath $texlive_abs/..)  # which is in @resources
econark_css=$(realpath $resrces_abs/econ-ark/econ-ark-html-theme.css)
source_repo="$root/$base/$base-$vers"

# create boundingboxes for jpg or png figures that do not have them already
# needed for html rendering (even of svg files)
$this_dir/bounding-boxes-missing-add.sh $root/$base/$base-$vers

# can't switch out of an unclean repo
$scripts_git/git-check-whether-repo-current-branch-is-clean.sh "$source_repo" ; err="$?"
if [[ "$err" -ne 0 ]]; then
    echo aborting && say aborting
    [[ "$is_sourced"=="true" ]] && exit 1 # exit kills nonsourced shell
fi

# prepare destination
cd "$source_repo" 
$this_dir/gh-pages-delete.sh

# create gh-pages branch as copy of source branch
git checkout -b gh-pages

# Process gh-pages branch of repository and generate HTML
source "$this_dir/makeWeb_process-target.sh"

$this_dir/move-gh-pages-to-master_docs.sh

# echo
# echo 'No commits have been made'
# echo
echo "$0" completed

