(* ::Package:: *)

<<multiperiodCon_infhor.m;

mTargetTol=0.0001;
T0=SessionTime[];
SolveInfHorizToToleranceAtTarget[mTargetTol];
T1=SessionTime[];
Print["Total Time Used: ", NumberForm[(T1-T0)/60,3], " minutes."];


Show[Plot[Table[\[ScriptC][x, i], {i, 0, PeriodsSolved}], {x, 0, 10}]
, Plot[(1-\[ScriptCapitalG]/RFree)*x+\[ScriptCapitalG]/RFree, {x, 0, 10}]
]
