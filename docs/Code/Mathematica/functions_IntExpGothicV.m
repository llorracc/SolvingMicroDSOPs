(* ::Package:: *)

<<functions_Interpolate.m;

\[GothicV]Hat[at_]                 := \[GothicV]FuncLife[[PeriodsSolved+1]][at];
\[GothicV]Hat[at_,PeriodsUntilT_]  := \[GothicV]FuncLife[[PeriodsUntilT+1]][at];
\[GothicV]Hata[at_]                := \[GothicV]aFuncLife[[PeriodsSolved+1]][at];
\[GothicV]Hata[at_,PeriodsUntilT_] := \[GothicV]aFuncLife[[PeriodsUntilT+1]][at];
SetAttributes[{\[GothicV]Hat,\[GothicV]Hata}, Listable];
