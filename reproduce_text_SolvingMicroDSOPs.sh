#/bin/bash
pdflatex -interaction=nonstopmode                           -halt-on-error -file-line-error -shell-escape \\newcommand\\UseOption{FromShell}\\input{SolvingMicroDSOPs}
bibtex -terse    SolvingMicroDSOPs
pdflatex -interaction=nonstopmode                           -halt-on-error -file-line-error -shell-escape \\newcommand\\UseOption{FromShell}\\input{SolvingMicroDSOPs}
pdflatex -interaction=nonstopmode                           -halt-on-error -file-line-error -shell-escape \\newcommand\\UseOption{FromShell}\\input{SolvingMicroDSOPs}
latexmk -c
