(* ::Package:: *)

Print["Solve 2period model using brute force (no tricks or approximations) and plot."];

<<2period.m;                            

vTm1Plot =
  Plot[\[ScriptV][m,PeriodsBeforeEnd=1]
       ,{m,mMin,mMax}
       ,AxesLabel->{"\!\(\*SubscriptBox[\(m\), \(T - 1\)]\)","\!\(\*SubscriptBox[\(v\), \(T - 1\)]\)"}
       ,PlotStyle->{Black,Thickness[Small]}
  ];
ExportFigs["vTm1Plot",vTm1Plot];
Print[vTm1Plot];

cTm1Plot =
  Plot[\[ScriptC][m,PeriodsBeforeEnd=1]
       ,{m,mMin,mMax}
       ,AxesLabel->{"\!\(\*SubscriptBox[\(m\), \(T - 1\)]\)","\!\(\*SubscriptBox[\(c\), \(T - 1\)]\)"}
       ,PlotStyle->{Black,Thickness[Small]}
  ];
ExportFigs["cTm1Plot",cTm1Plot];
Print[cTm1Plot];
