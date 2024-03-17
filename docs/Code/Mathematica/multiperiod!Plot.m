(* ::Package:: *)

(* multiperiodPlot.m *)

<<multiperiod.m;

PeriodsToSolve= 19;
Do[SolveAnotherPeriod,{PeriodsToSolve}];

TableOf\[ScriptC]Funcs = 
  Table[
  Plot[
      \[ScriptC][\[Mu], LP-1]
     ,{\[Mu], mLowerBoundLife[[LP]], mMax}
     ,DisplayFunction->Identity
     ,PlotRange->{{mLowerBoundLife[[LP]]+0.01, 4.},{0.,2.}}
     ,Ticks->None
     ,Exclusions -> None
(*The \[Chi] function is defined as a piecewise function. 
 Without using Exclusion, there will some visual gaps in the graph. *)
     ]
    ,{LP,1,PeriodsToSolve+1}];

PlotCFuncsConverge = Show[
     TableOf\[ScriptC]Funcs[[20]]
     ,TableOf\[ScriptC]Funcs[[15]]
     ,TableOf\[ScriptC]Funcs[[10]]
     ,TableOf\[ScriptC]Funcs[[5]]
     ,TableOf\[ScriptC]Funcs[[1]]
     ,DisplayFunction->$DisplayFunction
     ,AxesLabel->{"\[ScriptM]","\!\(\*SubscriptBox[\(c\), \(T - n\)]\)(\[ScriptM])"}
];

ExportFigs["PlotCFuncsConverge",PlotCFuncsConverge];
Print[PlotCFuncsConverge];












