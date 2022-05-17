(* ::Package:: *)

(* multiperiodCon!Plot.m *)

<<multiperiodCon.m;

Do[SolveAnotherPeriod,{PeriodsToSolve= 19}];

TableOf\[ScriptC]Funcs = 
  Table[
  Plot[
      \[ScriptC][\[Mu], LP-1]
     ,{\[Mu],mMin,mMax}
     ,DisplayFunction->Identity
     ,PlotRange->{{0.,4.},{0.,2.}}
     ,Ticks->None
     ]
    ,{LP,1,PeriodsToSolve+1}];

PlotCFuncsConverge = Show[

     TableOf\[ScriptC]Funcs[[20]]
     , TableOf\[ScriptC]Funcs[[15]]
     , TableOf\[ScriptC]Funcs[[10]]
     , TableOf\[ScriptC]Funcs[[5]]
     , TableOf\[ScriptC]Funcs[[1]]
     ,DisplayFunction->$DisplayFunction
     ,AxesLabel->{"\[ScriptM]","\!\(\*SubscriptBox[OverscriptBox[\(c\), \(`\)], \(T - n\)]\)(\[ScriptM])"}
];

ExportFigs["PlotCFuncsConverge",PlotCFuncsConverge];
Print[PlotCFuncsConverge];







