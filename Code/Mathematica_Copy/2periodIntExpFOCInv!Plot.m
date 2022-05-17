(* ::Package:: *)

<<2periodIntExpFOCInv.m;                            
Print["Solve using the inverse (transformed) versions of the functions."];

GothVInvVSGothC =
  Plot[
  {(\[GothicV]a[a,1])^(-1/\[Rho]),\[GothicC]FuncLife[[PeriodsSolved+1]][a]}
  ,{a,\[GothicA]VecPlusLowerBound[[1]],\[GothicA]Max}
  ,PlotStyle->{Dashing[{}],Dashing[{.01}]}
  ,AxesOrigin->{0.,0.}
  ,PlotRange->{{\[GothicA]VecPlusLowerBound[[1]],\[GothicA]Max},Automatic}
  ,AxesLabel -> {"\!\(\*SubscriptBox[\(a\), \(T - 1\)]\)","(\!\(\*SubsuperscriptBox[\(\[GothicV]\), \(T - 1\), \('\)]\)(\!\(\*SubscriptBox[\(a\), \(T - 1\)]\))\!\(\*SuperscriptBox[\()\), \(\(-1\)/\[Rho]\)]\), \!\(\*SubscriptBox[OverscriptBox[\(\[GothicC]\), \(`\)], \(T - 1\)]\)(\!\(\*SubscriptBox[\(a\), \(T - 1\)]\))"}
];
ExportFigs["GothVInvVSGothC",GothVInvVSGothC];
Print[GothVInvVSGothC];

GothVVSGothCInv = 
  Plot[
  {\[GothicV]a[a,1],\[GothicC]FuncLife[[PeriodsSolved+1]][a]^-\[Rho]}
  ,{a,\[GothicA]Min,\[GothicA]Max}
  ,PlotStyle->{Dashing[{}],Dashing[{.01}]}
   ,AxesLabel -> {"\!\(\*SubscriptBox[\(a\), \(T - 1\)]\)","\!\(\*SubsuperscriptBox[\(\[GothicV]\), \(T - 1\), \('\)]\)(\!\(\*SubscriptBox[\(a\), \(T - 1\)]\)), \!\(\*SubsuperscriptBox[OverscriptBox[OverscriptBox[\(\[GothicV]\), \(`\)], \(`\)], \(T - 1\), \('\)]\)(\!\(\*SubscriptBox[\(a\), \(T - 1\)]\))"}
];
ExportFigs["GothVVSGothCInv",GothVVSGothCInv];
Print[GothVVSGothCInv];

PlotcTm1IntExpFOCInv = 
    Plot[{\[ScriptC]FuncLife[[PeriodsSolved+1]][m]},{m,mMin,mMax}
    ,PlotStyle->Dashing[{.02}]
    ,DisplayFunction->Identity
    ];

PlotComparecTm1AD = 
  Show[cTm1Plot,PlotcTm1IntExpFOCInv
    ,DisplayFunction->$DisplayFunction
    ,AxesLabel -> {"\!\(\*SubscriptBox[\(m\), \(T - 1\)]\)","\!\(\*SubscriptBox[\(c\), \(T - 1\)]\)(\!\(\*SubscriptBox[\(m\), \(T - 1\)]\)), \!\(\*SubscriptBox[OverscriptBox[\(c\), \(`\)], \(T - 1\)]\)(\!\(\*SubscriptBox[\(a\), \(T - 1\)]\))"}
    ];
ExportFigs["PlotComparecTm1AD",PlotComparecTm1AD];
Print[PlotComparecTm1AD];

