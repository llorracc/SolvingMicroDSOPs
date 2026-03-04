#!/bin/bash
# pull the latest @resources and replace local files
# with the same names.  Leave alone any existing files
# that do not have a counterpart in in the upstream

# written by CDC with help of Claude

# Function to print usage information
usage() {
    echo "Usage: $0 [destination_path] [dryrun]"
    echo "  destination_path: Path to update @resources"
    echo "  dryrun: Optional. If set to 'dryrun', perform a dry run without making changes"
    echo
    echo "Example:"
    echo "$0 /Volumes/Data/Papers/BufferStockTheory/BufferStockTheory-Latest [dryrun]"
    exit 1
}

# Portable realpath function
realpath() {
    [[ $1 = /* ]] && echo "$1" || echo "$PWD/${1#./}"
}

# Script initialization
bash_src="$(realpath "$(dirname "$0")")"
root_src="$(dirname "$bash_src")"
dest_path="$(dirname "$root_src")"
base_name="$(basename "$dest_path")"

# Check if script is run from econ-ark-tools or bin
if [[ "$base_name" == "econ-ark-tools" ]] || [[ "$base_name" == "bin" ]]; then
    if [ $# -eq 0 ]; then
        echo 
        echo "Script executed directly from econ-ark-tools/"
        echo "or from an interactive shell"
        echo "requires a destination directory as an argument."
        echo
        usage
    else
        dest_path="$1"
    fi
fi

echo "dest_path=$dest_path"

# GitHub repository URL
repo_url="https://github.com/econ-ark/econ-ark-tools"

# Create and manage temporary directory
tmpdir=$(mktemp -d) || { echo "Failed to create temp dir"; exit 1; }
trap 'rm -rf -- "$tmpdir"' EXIT

# Clone the repository
pushd "$tmpdir" > /dev/null
orig_path="$tmpdir/econ-ark-tools"
[[ -d "$orig_path" ]] && rm -rf "$orig_path"
echo "Cloning repository..."
git clone --depth 1 "$repo_url" || { echo "Failed to clone repository"; exit 1; }
popd > /dev/null

# Prepare destination
[[ ! -e "$dest_path/@resources" ]] && mkdir -p "$dest_path/@resources" 
chmod -Rf u+w "$dest_path/@resources" || { echo "Failed to set write permissions"; exit 1; }

# Handle dry run mode
dryrun=''
if [[ $# == 2 ]]; then # second argument
    if [[ $2 == "dryrun" ]]; then
        dryrun='--dry-run' && echo "Running in '--dry-run' mode - no changes will be made" && echo
    fi
fi

# rsync options
opts=(
    --copy-links --recursive --owner --group --human-readable --verbose
    --exclude="'old'" --exclude="'.DS_Store'" --exclude="'auto'" --exclude="'*~'"
    --checksum --delete --itemize-changes --out-format="'%i %n%L'"
)

# Check for deletions
cmd_dryrun="rsync --dry-run ${opts[*]} $orig_path/@resources/ $dest_path/@resources/"
deletions=$(eval "$cmd_dryrun" | grep -i deleting)

if [[ -n "$deletions" ]]; then
    echo -e "\nThe following files would be deleted:\n$deletions\n"
    if [[ -z "$dryrun" ]]; then
	echo ; echo 'The files below will be deleted:' ; echo
	say 'check deletions'
	timeout 20 bash -c 'read -p "Hit return to continue, Ctrl-C to abort" -r'
	# on MacOS, timeout requires brew install coreutils
	echo
    fi
fi

# Perform rsync
cmd="rsync $dryrun ${opts[*]} $orig_path/@resources/ $dest_path/@resources/"
echo "$cmd"
eval "$cmd" | grep '^>f.*c' | tee >(awk 'BEGIN {printf "\n"}; END { if (NR == 0) printf "\nNo file(s) changed\n\n"; else printf "\nSome file(s) changed\n\n"}')

# Change target to read-only to remind self that edits should be done upstream
chmod -Rf u-w "$dest_path/@resources"

# Ensure temporary directory is removed on script exit
trap 'rm -rf -- "$tmpdir"' EXIT
