#!/bin/bash
# Remove CreationDates from xbb files 

if [ "$#" -ne 1 ]; then
  echo "usage:   ${0##*/} <directory>"
  echo "example: ${0##*/} /path/to/your/directory"
  exit 1
fi

dir="$1"

if [[ ! -e "$dir" ]]; then
    echo "$dir does not exist - exiting"
    exit 1
fi

cd "$dir"

echo 'Cleaning xbb files at: '"$dir"

# Detect the operating system
OS=$(uname)

for f in *.xbb; do
    if [ -f "$f" ] && grep -q 'CreationDate' "$f"; then
        if [ "$OS" = "Darwin" ]; then
            # macOS version
            sed -i '' '/CreationDate/d' "$f"
        else
            # Linux version
            sed -i '/CreationDate/d' "$f"
        fi
        echo "Cleaned $f"
    fi
done
