#/bin/bash
scriptDir="$(realpath $(dirname $0))" ; cd $scriptDir
pdflatex -interaction=nonstopmode -shell-escape -output-format dvi SolvingMicroDSOPs
pdflatex -interaction=nonstopmode -shell-escape -output-format dvi SolvingMicroDSOPs
bibtex -terse SolvingMicroDSOPs
pdflatex -interaction=nonstopmode -shell-escape -output-format dvi SolvingMicroDSOPs
pdflatex -interaction=nonstopmode -shell-escape -output-format dvi SolvingMicroDSOPs
make4ht  --utf8 --config SolvingMicroDSOPs.cfg --format html5 SolvingMicroDSOPs "svg            "   "-cunihtf -utf8"
