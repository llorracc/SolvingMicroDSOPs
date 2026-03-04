This directory contains data constructed by the programs in ./Code/Stata and used by the SMM 
code in the ./Code/Mathematica and ./Code/Matlab directories

. The code in the Stata 
directory assumes that the Survey of Consumer Finance datasets reside in a directory called 
"Downloads" that is one directory above the top level of the archive.  That is, if you download 
the SolvingMicroDSOPs archive to a folder called MyStuff, you will need to have at least two 
folders in that folder:

./MyStuff/SolvingMicroDSOPs
./MyStuff/Downloads 

because the Stata code expects 
to find files like scf92.dta in the 'Downloads' directory.  (We do things this way because it would 
be a big waste of space to include the scf datasets directly in the archive when they can be 
downloaded separately from the Fed).  


See ReadMe file in the ./Code/Stata folder for more details. 