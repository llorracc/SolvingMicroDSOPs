(* ::Package:: *)

(* ExtrapProblemPlot.m *)
<<2periodIntExpFOCInv.m;
<<DefineTm1Raw.m;

GapMax=1.1(\[ScriptC]\[Digamma][1,1]-\[ScriptC]Tm1Raw[1]);
GapMin=-GapMax;

ExtrapProblemPlot = Plot[{\[ScriptC]\[Digamma][m,1]-\[ScriptC]Tm1Raw[m],\[ScriptC]\[Digamma][m,1]-\[ScriptC][m,1]},{m,1,30}
,AxesLabel->{"\!\(\*SubscriptBox[\(m\), \(T - 1\)]\)","\!\(\*SubscriptBox[OverscriptBox[\(c\), \(_\)], \(T - 1\)]\)-\!\(\*SubscriptBox[OverscriptBox[\(c\), \(`\)], \(T - 1\)]\)"}
,PlotRange->{{0.,Automatic},{GapMin,GapMax}}
,PlotLegend->{"Truth","Approximation"}
,LegendSize->0.75
,LegendTextSpace->5
,LegendPosition->{-0.75,-0.5}
];
ExportFigs["ExtrapProblemPlot",ExtrapProblemPlot];
Print[ExtrapProblemPlot];



