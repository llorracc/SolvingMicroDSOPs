(* ::Package:: *)

(* 2PeriodInt!Plot.m *)
<<2periodInt.m;                            

Print["Solve 2period model using linear interpolation."];

PlotVTm1Simple =
  Show[vTm1Plot,
    Plot[
    \[ScriptV][m,PeriodsUntilEnd=1],{m,mMin,mMax}
    ,AxesLabel->{"\!\(\*SubscriptBox[\(m\), \(T - 1\)]\)","\!\(\*SubscriptBox[\(v\), \(T - 1\)]\)"}
    ,PlotStyle->{Black,Dashing[{0.01}]}
    ]
  ];
ExportFigs["PlotVTm1Simple",PlotVTm1Simple];
Print[PlotVTm1Simple];

PlotcTm1Simple =
  Show[cTm1Plot,
    Plot[\[ScriptC][m,PeriodsUntilEnd=1],{m,mMin,mMax}
         ,AxesLabel->{"\!\(\*SubscriptBox[\(m\), \(T - 1\)]\)","\!\(\*SubscriptBox[\(c\), \(T - 1\)]\)"}
         ,PlotStyle->{Black,Dashing[{0.01}]}
         ]
  ];
ExportFigs["PlotcTm1Simple",PlotcTm1Simple];
Print[PlotcTm1Simple];
