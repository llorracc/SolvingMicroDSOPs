#!/usr/bin/env bash

script_dir="$(dirname "$0")"

# Make sure the Python script exists and is executable
if [ ! -f "$script_dir/split-to-sentences.py" ]; then
    echo "Error: split-to-sentences.py not found in the script directory."
    exit 1
fi
chmod +x "$script_dir/split-to-sentences.py"

# Define usage message
usage() {
    echo "Usage: $0 [--all] [--replace] [--delete] <dir_path> [filename.tex]"
    echo ""
    echo "Options:"
    echo "  --all         Process all .tex files in the directory"
    echo "  --replace     Replace original file with sentenced version"
    echo "  --delete      Delete unsentenced backups created during replacement"
    exit 1
}

# Parse long options using getopt
TEMP=$(getopt -o '' --long all,replace,delete -- "$@")
if [ $? != 0 ]; then usage; fi
eval set -- "$TEMP"

# Initialize flags
all_files=false
replace_original=false
delete_unsentenced=false

# Process options
while true; do
    case "$1" in
        --all) all_files=true; shift ;;
        --replace) replace_original=true; shift ;;
        --delete) delete_unsentenced=true; shift ;;
        --) shift; break ;;
        *) echo "Error: Unknown option: $1"; usage ;;
    esac
done

# Collect remaining positional arguments
dir_path="$1"
filename="$2"

# Validate directory path
if [ -z "$dir_path" ]; then
    echo "Error: Directory path not provided."
    usage
fi

if [ ! -d "$dir_path" ]; then
    echo "Error: Directory path '$dir_path' does not exist."
    exit 1
fi

# Change to the target directory
cd "$dir_path" || exit 1

# Function to process a single file
process_file() {
    input_file="$1"
    python "$script_dir/split-to-sentences.py" "$input_file"

    if cmp -s "$input_file" "${input_file%.tex}-sentenced.tex"; then
        rm -f "${input_file%.tex}-sentenced.tex"
        echo "No changes made to file: $input_file"
    else
        echo "Processed file saved as: ${input_file%.tex}-sentenced.tex"
    fi
}

# Main execution logic
if $all_files; then
    tex_files=(*.tex)
    if [ ${#tex_files[@]} -eq 0 ]; then
        echo "No .tex files found in the directory."
        exit 0
    fi

    for file in "${tex_files[@]}"; do
        echo "Processing file: $file"
        process_file "$file"
        if $replace_original && [ -f "${file%.tex}-sentenced.tex" ]; then
            mv "$file" "${file%.tex}-unsentenced.tex"
            mv "${file%.tex}-sentenced.tex" "$file"
            if $delete_unsentenced; then
                rm -f "${file%.tex}-unsentenced.tex"
            fi
        fi
        echo "------------------------"
    done

    echo "All .tex files processed."
else
    if [ -z "$filename" ]; then
        echo "Error: Filename not provided."
        usage
    fi

    if [ ! -f "$filename" ]; then
        echo "Error: File '$filename' does not exist in the directory."
        exit 1
    fi

    echo "Processing file: $filename"
    process_file "$filename"
    if $replace_original && [ -f "${filename%.tex}-sentenced.tex" ]; then
        mv "$filename" "${filename%.tex}-unsentenced.tex"
        mv "${filename%.tex}-sentenced.tex" "$filename"
        if $delete_unsentenced; then
            rm -f "${filename%.tex}-unsentenced.tex"
        fi
    fi
fi
