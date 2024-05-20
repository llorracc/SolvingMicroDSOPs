#/bin/bash
pdflatex -interaction=nonstopmode                           -halt-on-error -file-line-error -shell-escape \\newcommand\\UseOption{FromShell}\\input{cctwMoM}
bibtex -terse    cctwMoM
pdflatex -interaction=nonstopmode                           -halt-on-error -file-line-error -shell-escape \\newcommand\\UseOption{FromShell}\\input{cctwMoM}
pdflatex -interaction=nonstopmode                           -halt-on-error -file-line-error -shell-escape \\newcommand\\UseOption{FromShell}\\input{cctwMoM}
latexmk -c
