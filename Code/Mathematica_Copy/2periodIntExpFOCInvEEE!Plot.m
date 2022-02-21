(* ::Package:: *)

<<2periodIntExpFOCInvEEE.m;                            
Print["Use a triple-exponential to construct aVec."];

GothVInvVSGothCEEE =
  Plot[
  {(\[GothicV]a[a,1])^(-1/\[Rho]),\[GothicC]FuncLife[[PeriodsSolved+1]][a]}
  ,{a,\[GothicA]VecPlusLowerBound[[1]],\[GothicA]Max}
  ,PlotRange->{{\[GothicA]VecPlusLowerBound[[1]],\[GothicA]Max},Automatic}
  ,PlotStyle->{Dashing[{}],Dashing[{.01}]}
  ,AxesLabel -> {"\!\(\*SubscriptBox[\(a\), \(T - 1\)]\)","(\!\(\*SubsuperscriptBox[\(\[GothicV]\), \(T - 1\), \('\)]\)(\!\(\*SubscriptBox[\(a\), \(T - 1\)]\))\!\(\*SuperscriptBox[\()\), \(\(-1\)/\[Rho]\)]\), \!\(\*SubscriptBox[OverscriptBox[\(\[GothicC]\), \(`\)], \(T - 1\)]\)(\!\(\*SubscriptBox[\(a\), \(T - 1\)]\))"}  
];
ExportFigs["GothVInvVSGothCEEE",GothVInvVSGothCEEE];
Print[GothVInvVSGothCEEE];

GothVVSGothCInvEEE = 
  Plot[
  {\[GothicV]a[a,1],\[GothicC]FuncLife[[PeriodsSolved+1]][a]^-\[Rho]}
  ,{a,\[GothicA]VecPlusLowerBound[[1]],\[GothicA]Max}
  ,PlotRange->{{\[GothicA]VecPlusLowerBound[[1]],\[GothicA]Max},Automatic}
  ,PlotStyle->{Dashing[{}],Dashing[{.01}]}
  ,AxesLabel -> {"\!\(\*SubscriptBox[\(a\), \(T - 1\)]\)","\!\(\*SubsuperscriptBox[\(\[GothicV]\), \(T - 1\), \('\)]\)(\!\(\*SubscriptBox[\(a\), \(T - 1\)]\)), \!\(\*SubsuperscriptBox[OverscriptBox[OverscriptBox[\(\[GothicV]\), \(`\)], \(`\)], \(T - 1\), \('\)]\)(\!\(\*SubscriptBox[\(a\), \(T - 1\)]\))"}
];
ExportFigs["GothVVSGothCInvEEE",GothVVSGothCInvEEE];
Print[GothVVSGothCInvEEE];

PlotcTm1IntExpFOCInvEEE = 
    Plot[{\[ScriptC]FuncLife[[PeriodsSolved+1]][m]},{m,mMin,mMax}
    ,PlotStyle->Dashing[{.02}]
    ,DisplayFunction->Identity
    ];

PlotComparecTm1ADEEE = 
  Show[PlotcTm1Simple,PlotcTm1IntExpFOCInvEEE
    ,DisplayFunction->$DisplayFunction
    ,AxesLabel -> {"\!\(\*SubscriptBox[\(m\), \(T - 1\)]\)","\!\(\*SubscriptBox[\(c\), \(T - 1\)]\)(\!\(\*SubscriptBox[\(m\), \(T - 1\)]\)), \!\(\*SubscriptBox[OverscriptBox[\(c\), \(`\)], \(T - 1\)]\)(\!\(\*SubscriptBox[\(a\), \(T - 1\)]\))"}
    ];
ExportFigs["PlotComparecTm1ADEEE",PlotComparecTm1ADEEE];
Print[PlotComparecTm1ADEEE];



