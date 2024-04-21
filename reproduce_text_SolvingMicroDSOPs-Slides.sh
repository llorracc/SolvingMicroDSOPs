#/bin/bash
pdflatex -interaction=nonstopmode                           -halt-on-error -file-line-error -shell-escape \\newcommand\\UseOption{FromShell}\\input{SolvingMicroDSOPs-Slides}
pdflatex -interaction=nonstopmode                           -halt-on-error -file-line-error -shell-escape \\newcommand\\UseOption{FromShell}\\input{SolvingMicroDSOPs-Slides}
pdflatex -interaction=nonstopmode                           -halt-on-error -file-line-error -shell-escape \\newcommand\\UseOption{FromShell}\\input{SolvingMicroDSOPs-Slides}
latexmk -c
