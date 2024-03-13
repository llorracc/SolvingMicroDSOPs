(* ::Package:: *)

(* The solution method is identical to 2periodIntExpFOCInv.m; the only difference is the use of triple exponential grid *)
<<setup_everything.m;
<<setup_grids_eee.m;
\[GothicC]FuncLife = { Indeterminate & }; (* Consumed function meaningless in last period of life *)


<<prepareIntExpFOCInvEEE.m;

SolveAnotherPeriod;
