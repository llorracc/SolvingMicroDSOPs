#!/bin/bash

theme=econ-ark-html-theme
echo curl "https://raw.githubusercontent.com/econ-ark/econ-ark-tools/master/Web/Styling/REMARKs-HTML/$theme.css" -o "'"$(dirname $0)/$theme.css"'"
