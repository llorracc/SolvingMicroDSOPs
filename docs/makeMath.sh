#!/bin/sh

# Enable sudo
sudo echo "enabling sudo"

scriptRoot="$(dirname "$0")" # directory the script lives in

cd $scriptRoot

cd ./Mathematica

# The line below works on a Mac with Mathematica involved; it runs the text-only version 
/Applications/Mathematica.app/Contents/MacOS/MathKernel < doAll.m > doAll.out

cd $ScriptRoot/Code/Mathematica/StructuralEstimation/

# echo Comment out the line below to NOT do the SMM estimation because that is so slow!

/Applications/Mathematica.app/Contents/MacOS/MathKernel < StructEstimation.m > StructEstimation.out 


