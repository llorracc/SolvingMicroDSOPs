(* ::Package:: *)

<<2periodIntExpFOC.m;                            

Print["Solve using the FOC, rather than the level of value."];

PlotGothVRawVSFOC =
  Plot[
  {\[GothicV]a[a,1],\[GothicV]Hata[a,1]}
  ,{a,mMin,mMax}
  ,PlotStyle->{Dashing[{.001}],Dashing[{.01}]}
  ,AxesLabel->{"\!\(\*SubscriptBox[\(a\), \(T - 1\)]\)","\!\(\*SuperscriptBox[\(\[GothicV]\), \('\)]\),\!\(\*SuperscriptBox[OverscriptBox[\(\[GothicV]\), \(`\)], \('\)]\)"}
  ,ImageSize->{72 6.,72 6./GoldenRatio}
];
ExportFigs["PlotGothVRawVSFOC",PlotGothVRawVSFOC];
Print[PlotGothVRawVSFOC];

PlotcTm1IntExpFOC = 
    Plot[{\[ScriptC]FuncLife[[PeriodsSolved+1]][m]},{m,mMin,mMax}
    ,PlotStyle->Dashing[{.02}]
    ,DisplayFunction->Identity
    ];

PlotcTm1ABC =
  Show[PlotcTm1IntExp,PlotcTm1Simple,PlotcTm1IntExpFOC
    ,DisplayFunction->$DisplayFunction
    ,ImageSize->{72 6.,72 6./GoldenRatio}
    ,AxesLabel->{"\!\(\*SubscriptBox[\(m\), \(T - 1\)]\)","\!\(\*SubscriptBox[\(c\), \(T - 1\)]\)"}
    ,PlotRange->{Automatic,{0.,Automatic}}
    ];
ExportFigs["PlotcTm1ABC",PlotcTm1ABC];
Print[PlotcTm1ABC];
