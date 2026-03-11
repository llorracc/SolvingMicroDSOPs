#!/bin/bash
# Due to a bug in dvisvgm and/or ghostscript, under some circs junk gets added to the svg
# Remove it

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

echo 'Cleaning svg files at: '"$dir"

for f in *.svg; do
    echo "$f"
    cmd="sed -i '' '/PDF interpreter/d' $f"
    eval "$cmd"
    cmd="sed -i '' '/dNEWDPF/d' $f"
    eval "$cmd"
done
