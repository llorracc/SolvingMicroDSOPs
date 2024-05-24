#/bin/bash
scriptDir="$(realpath $(dirname $0))" ; cd $scriptDir
pdflatex -shell-escape -output-format dvi SolvingMicroDSOPs
bibtex -terse SolvingMicroDSOPs
pdflatex -shell-escape -output-format dvi SolvingMicroDSOPs
pdflatex -shell-escape -output-format dvi SolvingMicroDSOPs
rm -f economics.bib; make4ht  --utf8 --config SolvingMicroDSOPs.cfg --format html5 SolvingMicroDSOPs "svg            "   "-cunihtf -utf8"
