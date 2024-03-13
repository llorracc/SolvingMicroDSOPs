(* ::Package:: *)

<<2periodIntExp.m;                            

Print["Solve 2period model by interpolating expectations."];

PlotOTm1RawVSInt = Plot[
  {\[GothicV][a,1],\[GothicV]FuncLife[[PeriodsSolved+1]][a]}
  ,{a,\[GothicA]Min,\[GothicA]Max}
  ,PlotStyle->{Dashing[{}],Dashing[{.01}]}
  ,AxesLabel->{"\!\(\*SubscriptBox[\(m\), \(T - 1\)]\)","\!\(\*SubscriptBox[\(\[GothicV]\), \(T - 1\)]\)"}
];
ExportFigs["PlotOTm1RawVSInt",PlotOTm1RawVSInt];
Print[PlotOTm1RawVSInt];

PlotVTm1IntExp = 
  Plot[\[ScriptV][m,1],{m,mMin,mMax}
    ,PlotStyle->Dashing[{.01}]
    ,DisplayFunction->Identity];

PlotcTm1IntExp = 
  Plot[\[ScriptC][m,1],{m,mMin,mMax}
  ,PlotStyle->{Dashing[{.01}]} 
  ,DisplayFunction->Identity];

PlotCompareVTm1AB = 
  Show[PlotVTm1Simple,PlotVTm1IntExp
     ,DisplayFunction->$DisplayFunction
     ,AxesLabel->{"\!\(\*SubscriptBox[\(m\), \(T - 1\)]\)","\!\(\*SubscriptBox[\(v\), \(T - 1\)]\)"}
     ];
ExportFigs["PlotCompareVTm1AB",PlotCompareVTm1AB];
Print[PlotCompareVTm1AB];

PlotComparecTm1AB = 
  Show[PlotcTm1IntExp,PlotcTm1Simple
     ,DisplayFunction->$DisplayFunction
     ,AxesLabel->{"\!\(\*SubscriptBox[\(m\), \(T - 1\)]\)","\!\(\*SubscriptBox[\(c\), \(T - 1\)]\)"}
     ,PlotRange->{Automatic,{0.,Automatic}}
     ];
ExportFigs["PlotComparecTm1AB",PlotComparecTm1AB];
Print[PlotComparecTm1AB];

xEq3Plot = Plot[
    {(   \[GothicV][3-c+.001,1]-   \[GothicV][3-c-.001,1])/.002
    ,(\[GothicV]Hat[3-c+.001,1]-\[GothicV]Hat[3-c-.001,1])/.002}
,{c,.1,3}
,PlotRange->{{0,3},{0,0.8}}
,PlotStyle->{Dashing[{}],Dashing[{}],Dashing[{}]}
,DisplayFunction->Identity
];

xEq4Plot = Plot[
    {uP[c]
    ,(   \[GothicV][4-c+.001,1]-   \[GothicV][4-c-.001,1])/.002
    ,(\[GothicV]Hat[4-c+.001,1]-\[GothicV]Hat[4-c-.001,1])/.002}
,{c,.1,4}
,PlotRange->{{0,4},{0,0.8}}
,PlotStyle->{Thickness[.006],Dashing[{.01}],Dashing[{.01}]}
,DisplayFunction->Identity
];

PlotuPrimeVSOPrime = 
Show[xEq3Plot,xEq4Plot,PlotRange->{{0,4},{0,0.8}}
  ,AxesLabel->{"\!\(\*SubscriptBox[\(c\), \(T - 1\)]\)","\!\(\*SubsuperscriptBox[\(\[GothicV]\), \(T - 1\), \('\)]\)(\!\(\*SubscriptBox[\(m\), \(T - 1\)]\)-\!\(\*SubscriptBox[\(c\), \(T - 1\)]\)),\!\(\*SuperscriptBox[\(u\), \('\)]\)(\!\(\*SubscriptBox[\(c\), \(T - 1\)]\))"}
,DisplayFunction->$DisplayFunction
];
ExportFigs["PlotuPrimeVSOPrime",PlotuPrimeVSOPrime];
Print[PlotuPrimeVSOPrime];
