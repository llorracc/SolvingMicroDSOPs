(* ::Package:: *)

(* PeriodIntExpFOCInvPesReaOpt!Plot.m *)
Print["Use the 'method of moderation, without tighter upper bound refinement.'"];

<<2PeriodIntExpFOCInvPesReaOpt.m;
<<DefineTm1Raw.m;

IntExpFOCInvPesReaOptGapPlot = Plot[{\[ScriptC]Tm1Raw[m]-\[ScriptC][m, 1]}
,{m,mVect[[1]],30(*mVect[[-1]]*)}
,AxesLabel->{"\!\(\*SubscriptBox[\(m\), \(T - 1\)]\)","\!\(\*SubscriptBox[\(\[ScriptC]\), \(T - 1\)]\)-\!\(\*SubscriptBox[OverscriptBox[\(c\), \(`\)], \(T - 1\)]\)"}
,PlotRange->{{mVect[[1]],30},All}];
ExportFigs["IntExpFOCInvPesReaOptGapPlot",IntExpFOCInvPesReaOptGapPlot];
Print[IntExpFOCInvPesReaOptGapPlot];









