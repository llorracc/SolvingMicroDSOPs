#!/bin/bash
# Remove CreationDates from xbb files 

if [ "$#" -ne 1 ]; then
  echo "usage:   ${0##*/} <directory>"
  echo "example: ${0##*/} /Volumes/Data/Topics/NumericalMethods/SolvingMicroDSOPs/SolvingMicroDSOPs-Latest"
  exit 1
fi

dir="$1"

if [[ ! -e "$dir" ]]; then
    echo "$dir does not exist - exiting"
    exit 1
fi

cd "$dir"

echo 'Cleaning xbb files at: '"$dir"

for f in *.xbb; do
#    echo "$f"
    cmd="sed -i '' '/CreationDate/d' $f"
    eval "$cmd"
done
