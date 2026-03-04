#!/bin/bash

# Script name: bounding-boxes-add-if-missing.sh

# Function to display usage
show_usage() {
    echo "Usage: $0 <directory>"
    echo "  <directory>: The root directory to search for images (required)."
    echo "  This script processes jpg and png files without existing .xbb files in the specified directory"
    echo "  and its immediate subdirectories, then runs xbb-clean.sh on directories where files were processed."
}

# Check if help is requested
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_usage
    exit 0
fi

# Check if directory argument is provided
if [ $# -eq 0 ]; then
    echo "Error: No directory specified."
    show_usage
    exit 1
fi

root_dir="$1"

# Ensure the root directory exists
if [ ! -d "$root_dir" ]; then
    echo "Error: Directory '$root_dir' does not exist."
    exit 1
fi

# Get the directory of the current script
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Change to the root directory
cd "$root_dir" || exit 1

# Use a temporary file to store processed directories
temp_file=$(mktemp)

for pic_ext in jpg png; do
    count_files=0
    find . -maxdepth 2 -type f -name "*.$pic_ext" -print0 | 
    while IFS= read -r -d '' file; do
        # Strip the extension and check for .xbb file
        base_name="${file%.$pic_ext}"
        if [ ! -f "${base_name}.xbb" ]; then
            if ebb -x "$file"; then
                echo "Processed: $file"
		((count_files+))
                dirname "$file" >> "$temp_file"
            fi
        fi
    done
done

if [[ $count_files > 0 ]]; then
    echo processed "$count_files" with missing xbb boxes
else
    echo '' ; echo found no files with missing xbb boxes ; echo ''
fi


# Run xbb-clean.sh on each unique directory where files were processed
sort -u "$temp_file" | while read -r dir; do
    echo "Cleaning directory: $dir"
    "$script_dir/xbb-clean.sh" "$dir"
done

# Clean up the temporary file
rm -f "$temp_file"
