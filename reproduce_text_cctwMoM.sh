#/bin/bash
scriptDir="$(realpath $(dirname $0))" ; cd $scriptDir
pdflatex -interaction=nonstopmode -shell-escape -output-format dvi cctwMoM
pdflatex -halt-on-error    -output-format dvi -shell-escape cctwMoM
bibtex -terse cctwMoM
pdflatex -halt-on-error    -output-format dvi -shell-escape cctwMoM
pdflatex -halt-on-error    -output-format dvi -shell-escape cctwMoM
