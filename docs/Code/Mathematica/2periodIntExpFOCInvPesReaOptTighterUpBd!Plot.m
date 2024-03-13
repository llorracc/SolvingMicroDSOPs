(* ::Package:: *)

(* PeriodIntExpFOCInvPesReaOptTighterUpBd!Plot.m *)

<<2PeriodIntExpFOCInvPesReaOptTighterUpBd.m;


<<DefineTm1Raw.m;


Print["Use the 'method of moderation, with tighter upper bound refinement.'"];
\[FilledUpTriangle]mCuspt=Last[\[Kappa]MinLife]*Last[\[FilledUpTriangle]\[GothicH]AccessibleLife]/(Last[\[Kappa]MaxLife]-Last[\[Kappa]MinLife]); (* June 2012 KT fixed *)
mCuspt=\[FilledUpTriangle]mCuspt-Last[\[GothicH]AccessibleLife]; 

cCuspt=\[ScriptC][mCuspt, 1];


(* Problem with the MoM: Needs tighter upper bound improvement *)
IntExpFOCInvPesReaOptNeedTighterUpBdPlot = Show[
  Plot[{\[ScriptC][m, 1]
, \[ScriptC]\[Digamma]TighterUpBd[m, 1]
, \[ScriptC]\[Digamma][m,1]
, \[ScriptC]\[Digamma]Pes[m,1]}
, {m, -\[GothicH]MinLife[[-1]], 2}
, AxesLabel->{"\!\(\*SubscriptBox[\(m\), \(T - 1\)]\)","\!\(\*SubscriptBox[\(c\), \(T - 1\)]\)"}
, PlotStyle->{
  Directive[Black,Thickness[Small]]
, Directive[Black,Thickness[Medium],Dashing[Medium]]
, Directive[Black,Thickness[Medium],Dashing[Tiny]]
, Directive[Black,Thickness[Medium]]
}
, PlotRange->{{-\[GothicH]MinLife[[-1]]-0.2, 2}, {-0.2, 2}}
]
, Plot[\[ScriptC]\[Digamma]TighterUpBd[m, 1]
, {m, -\[GothicH]MinLife[[-1]], mCuspt}
, PlotStyle->{
      Directive[Black,Thickness[Medium]]}]
, Plot[\[ScriptC]\[Digamma][m,1]
, {m, mCuspt, 2}
, PlotStyle->{
      Directive[Black,Thickness[Medium]]}]
, ListPlot[Rest[Most[Transpose[{mVect, cVectRealst}]]], PlotMarkers->{"\[Bullet]", Large}, PlotStyle->PointSize[0.01]]
, ListPlot[{{-\[GothicH]MinLife[[-1]], 0}}, PlotMarkers->{"\[Bullet]", Large}, PlotStyle->PointSize[0.01]]
, ListPlot[{{mCuspt, \[ScriptC]\[Digamma][mCuspt,1]}}, PlotMarkers->{"\[SmallCircle]", Large}, PlotStyle->PointSize[0.02]]
, Graphics[{Dashed, Line[{{mCuspt, 0.0},{mCuspt, 2.5}}]}]
, Graphics[{Text["\[LowerLeftArrow]\!\(\*SuperscriptBox[\(m\), \(\[Sharp]\)]\)", {mCuspt*1.08, 0.08}]}]
, Graphics[{Text["\!\(\*OverscriptBox[\(c\), \(_\)]\)=\!\(\*OverscriptBox[\(\[Kappa]\), \(_\)]\)\[FilledUpTriangle]m \[RightArrow]", {mCuspt*1.5, 1.75}]}]
, Graphics[{Text["\!\(\*OverscriptBox[\(c\), \(_\)]\)=\!\(\*UnderscriptBox[\(\[Kappa]\), \(_\)]\)(\[FilledUpTriangle]m+\[FilledUpTriangle]\[GothicH]) \[RightArrow]", {mCuspt*0.4, 0.9}]}]
, Graphics[{Text["\[LeftArrow]\!\(\*c\)", {mCuspt*1.35, 0.9}]}]
, Graphics[{Text["\[LeftArrow]\!\(\*UnderscriptBox[\(c\), \(_\)]\)=\!\(\*UnderscriptBox[\(\[Kappa]\), \(_\)]\)\[FilledUpTriangle]m", {mCuspt*1.3, 0.59}]}]
];
ExportFigs["IntExpFOCInvPesReaOptNeedTighterUpBdPlot", IntExpFOCInvPesReaOptNeedTighterUpBdPlot];
Print[IntExpFOCInvPesReaOptNeedTighterUpBdPlot];


IntExpFOCInvPesReaOptNeedTighterUpBdValuePlot = Show[
  Plot[{\[ScriptV][m, 1]
, \[ScriptV]\[Digamma]TighterUpBd[m,1]
, \[ScriptV]\[Digamma][m,1]
, \[ScriptV]\[Digamma]Pes[m,1]}
, {m, -\[GothicH]MinLife[[-1]], 2}
, AxesLabel->{"\!\(\*SubscriptBox[\(m\), \(T - 1\)]\)", "\!\(\*SubscriptBox[\(\[ScriptV]\), \(T - 1\)]\)"}
, PlotStyle->{
  Directive[Black,Thickness[Small]]
, Directive[Black,Thickness[Medium],Dashing[Large]]
, Directive[Black,Thickness[Medium],Dashing[Tiny]]
, Directive[Black,Thickness[Medium]]
}
, AxesOrigin->{0, -1}
, PlotRange->{{-\[GothicH]MinLife[[-1]], 2}, {-6, -1}}
]
, Plot[\[ScriptV]\[Digamma]TighterUpBd[m,1]
, {m, -\[GothicH]MinLife[[-1]], mCuspt}
, PlotStyle->{Directive[Black,Thickness[Medium]]}]
, Plot[\[ScriptV]\[Digamma][m,1]
, {m, mCuspt, 3}
, PlotStyle->{
      Directive[Black,Thickness[Medium]]}]
, ListPlot[Most[Transpose[{mVect, cVectRealst}]]]
, ListPlot[{{mCuspt, cCuspt}}, PlotMarkers->{"\[SmallCircle]", Large}, PlotStyle->PointSize[0.02]]
, Graphics[{Dashed, Line[{{mCuspt, 0.0},{mCuspt, -10}}]}]
, Graphics[{Text["\!\(\*SuperscriptBox[\(m\), \(\[Sharp]\)]\) \[UpperRightArrow]", {mCuspt*0.935, -1.23}]}]
];
ExportFigs["IntExpFOCInvPesReaOptNeedTighterUpBdValuePlot", IntExpFOCInvPesReaOptNeedTighterUpBdValuePlot];
Print[IntExpFOCInvPesReaOptNeedTighterUpBdValuePlot];


Print["Difference in consumption function before and after tighter upper bound refinement."];

IntExpFOCInvPesReaOptTighterUpBdGapPlot = Show[Plot[{\[ScriptC][m, 1]-\[ScriptC]Hi[m, 1]}
,{m,mVect[[1]],2}
,AxesLabel->{"\!\(\*SubscriptBox[\(m\), \(T - 1\)]\)"
, "\!\(\*SubscriptBox[OverscriptBox[OverscriptBox[\(c\), \(^\)], \(`\)], \(T - 1\)]\)-\!\(\*SubscriptBox[OverscriptBox[OverscriptBox[\(c\), \(\[Hacek]\)], \(`\)], \(T - 1\)]\)"}
, PlotRange->{{mVect[[1]], 2},{0.0004, -0.0004}}]
, Graphics[{Dashed, Line[{{mCuspt,0.05},{mCuspt,-0.05}}]}]
, Graphics[{Text["\!\(\*SuperscriptBox[\(m\), \(\[Sharp]\)]\) \[LowerRightArrow]", {mCuspt*0.88, 0.00008}]}]
];

ExportFigs["IntExpFOCInvPesReaOptTighterUpBdGapPlot",IntExpFOCInvPesReaOptTighterUpBdGapPlot];
Print[IntExpFOCInvPesReaOptTighterUpBdGapPlot];


IntExpFOCInvPesReaOptTighterUpBdValueGapPlot = Show[Plot[{\[ScriptV][m, 1]-\[ScriptV]Hi[m, 1]}
, {m,mVect[[1]],2}
, AxesLabel->{"\!\(\*SubscriptBox[\(m\), \(T - 1\)]\)"
, "\!\(\*SubscriptBox[OverscriptBox[OverscriptBox[\(\[GothicV]\), \(^\)], \(`\)], \(T - 1\)]\)-\!\(\*SubscriptBox[OverscriptBox[OverscriptBox[\(\[GothicV]\), \(\[Hacek]\)], \(`\)], \(T - 1\)]\)"}
, PlotRange->{{mVect[[1]], 2},{0.01, -0.01}}]
, Graphics[{Dashed, Line[{{mCuspt,0.05},{mCuspt,-0.05}}]}]
, Graphics[{Text["\!\(\*SuperscriptBox[\(m\), \(\[Sharp]\)]\)\[LowerRightArrow]", {mCuspt*0.902, 0.003}]}]
];

ExportFigs["IntExpFOCInvPesReaOptTighterUpBdValueGapPlot",IntExpFOCInvPesReaOptTighterUpBdValueGapPlot];
Print[IntExpFOCInvPesReaOptTighterUpBdValueGapPlot];



(*
Print[mCuspt ];
Print[cCuspt ];
Print[\[Kappa]Min];
Print[\[Kappa]Max];

Print[\[ScriptC]From\[Chi][mCuspt, 1]];
Print[\[ScriptC]From\[Chi][mCuspt, 2]];
Print[\[ScriptC]From\[Chi][mCuspt, 3]];

*)

