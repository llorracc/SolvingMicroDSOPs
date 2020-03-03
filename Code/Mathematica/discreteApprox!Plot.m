(* ::Package:: *)

(*
Makes figure illustrating the discrete approximation to the lognormal distribution
*)

\[Mu]ThatMakesE1 = -(\[Sigma]\[Theta]^2)/2;

hMin = \[Theta]Vals[[ 1]]-2.3 \[Sigma]\[Theta];
hMax = \[Theta]Vals[[-1]]+2.0 \[Sigma]\[Theta];

(* CDFPlot: 'True' lognormal distribution *)
CDFPlot = Plot[
  CDF[LogNormalDistribution[\[Mu]ThatMakesE1,\[Sigma]\[Theta]],x]
    ,{x,hMin,hMax}
    ,PlotRange->{{hMin,hMax},{0,1}}
    ,AxesOrigin->{hMin,0}
];

(* Connect vertical axis to the \[Sharp] points *)
HorizLines = 
Table[
  CDFLevel=CDF[LogNormalDistribution[\[Mu]ThatMakesE1,\[Sigma]\[Theta]], \[Sharp]InnerPts[[LoopOverEdges]]];
  Graphics[{Dashed,Line[{{hMin,CDFLevel},{\[Sharp]InnerPts[[LoopOverEdges]],CDFLevel}}]}]
,{LoopOverEdges,Length[\[Sharp]InnerPts]}];


discreteApprox = Show[CDFPlot,
Table[Graphics[{Thick,Line[{{\[Theta]Vals[[i]],Accumulate[\[Theta]Prob][[i]]-1/7},{\[Theta]Vals[[i]],Accumulate[\[Theta]Prob][[i]]}}]}],{i,7}],
Table[Graphics[{Thick,Dashed,Red,Line[{{\[Theta]Vals[[i]],Accumulate[\[Theta]Prob][[i]]},{\[Theta]Vals[[i+1]],Accumulate[\[Theta]Prob][[i]]}}]}],{i,6}],
HorizLines,Graphics[Text[" \[LeftArrow] \[DoubleStruckCapitalE][\[Theta] | \!\(\*SubsuperscriptBox[\(\[Sharp]\), \(n - 2\), \(\(\\\ \\\ \)\(-1\)\)]\) < \[Theta] < \!\(\*SubsuperscriptBox[\(\[Sharp]\), \(n - 1\), \(\(\\\ \\\ \)\(-1\)\)]\)]",{\[Theta]Vals[[-2]],Accumulate[\[Theta]Prob][[-3]]},{-1,0}]]
,Graphics[Text["\[DoubleStruckCapitalE][\[Theta] | 0 < \[Theta] < \!\(\*SubsuperscriptBox[\(\[Sharp]\), \( 1\), \(-1\)]\)]\[RightArrow] ",{\[Theta]Vals[[1]],\[Theta]Prob[[1]]/2},{1,0}]]
,Ticks->{
{{\[Sharp]InnerPts[[1]],"\!\(\*SubsuperscriptBox[\(\[Sharp]\), \(\(\\\ \\\ \)\(1\)\), \(-1\)]\)"},{\[Sharp]InnerPts[[-1]],"\!\(\*SubsuperscriptBox[\(\[Sharp]\), \(n - 1\), \(\(\\\ \\\ \)\(-1\)\)]\)"}},{{0.,"0."},{\[Theta]Prob[[1]],"\!\(\*SubscriptBox[\(\[Sharp]\), \(1\)]\)  "},{Accumulate[\[Theta]Prob][[-2]],"\!\(\*SubsuperscriptBox[\(\[Sharp]\), \(n - 1\), \(\\\ \\\ \)]\)"},{1.,"1."}}
}
,AxesLabel->{"\[Theta]","\[ScriptCapitalF]"}
];

ExportFigs["discreteApprox",discreteApprox];
Print[discreteApprox];



