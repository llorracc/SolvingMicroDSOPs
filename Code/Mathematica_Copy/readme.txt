This directory contains the programs outlined in the SolvingMicroDSOPs lecture notes:

1. the setup files that initialize the environment;
2. the programs to solve the various two-period versions of the problem;
3. the multi-period program;
4. the multi-control program.

It also contains two extra files: doAll.m and discreteApprox!Plot.m.

Throughout, the documentation explains where various formulas come from by reference to equation names in 
BufferStockTheory.tex.  This is the LaTeX code that generates the paper "Theoretical Foundations of Buffer Stock Saving"; that LaTeX code is available in the online archive for that paper, available at 

http://econ.jhu.edu/people/ccarroll/papers/BufferStockTheory.zip in the "LaTeX" directory

*************************************************************
Running the programs together:
 - Open doAll.nb
 - Move the cursor to the first 'cell' in the notebook
 - Press Shift-Enter to execute the contents of that cell
 - Scroll down to the next cell that contains code
 - Press Shift-Enter to execute that code
 - Repeat

Some annoying warning messages will appear (e.g. extrapolation is used
instead of interpolation etc.) but they will not interrupt the
program. To turn off the time delays caused by the warning messages,
go to Edit->Preferences->Global Options->MessageOptions, and turn off
all the "beeps". The default option can be restored by pushing the
small bullet buttion on the left.

To clear all variables in the memory, type ClearAll["Global`*"] (can type it in any cell, any notebook that you opened).
*************************************************************
 


*************************************************************
Setup files:
1. setup_grids.m
2. setup_grids_eee.m
3. setup_params.m
4. setup_params_multicontrol.m
5. setup_params_multiperiod.m
6. setup_shocks.m

Depending on the type of program being run, different sets of setup files are automatically loaded. For example, the two-period program package will not load "setup_params_multiperiod.m".

*************************************************************
The two-period program package contains 6 core files:
1. 2period.m
2. 2periodIntExp.m
3. 2periodIntExpFOC.m
4. 2periodIntExpFOCInv.m
5. 2periodIntExpFOCInvEEE.m
6. 2periodIntExpFOCInvEEECon.m

It contains another 6 "plot" files corresponding to each one of the above. To run the package ONLY, run do_2period.m. This file will load the "plot" files, which in turn will load the corresponding core files automatically.
*************************************************************
The multi-period program contains 2 files:
1. multiperiod.m;
2. multiperiodPlot.m.

To run the program, run multiperiodPlot.m (NOT multiperiod.m).
*************************************************************
The multi-control program contains 2 files:
1. multicontrol.m;
2. multicontrolPlot.m.

To run the program, run multicontrolPlot.m (NOT multicontrol.m).
*************************************************************
The program "discreteApprox!Plot.m" produces the graph of discrete approximation of shocks in the lecture notes.
*************************************************************

(end of readme.txt)
