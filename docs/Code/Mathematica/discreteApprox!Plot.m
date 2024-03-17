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
  CDFLevel=CDF[LogNormalDistribution[\[Mu]ThatMakesE1,\[Sigma]\[Theta]], \[Sharp]OuterPts[[LoopOverEdges-1]]];
  Graphics[{Dashed,Thickness[0.005],Line[{{\[Sharp]OuterPts[[LoopOverEdges-1]],CDFLevel},{\[Sharp]OuterPts[[LoopOverEdges]],CDFLevel}}]}]
,{LoopOverEdges,2,Length[\[Sharp]OuterPts]-1}];


discreteApprox = Show[CDFPlot,
Table[Graphics[{Thick,Line[{{\[Theta]Vals[[i]],Accumulate[\[Theta]Prob][[i]]-1/7},{\[Theta]Vals[[i]],Accumulate[\[Theta]Prob][[i]]}}]}],{i,7}],
 HorizLines
,Graphics[Text["\!\(\*SubsuperscriptBox[\(\[Theta]\), \(n -1  \), \(\(\\\ \\\ \)\(\)\)]\) = \[DoubleStruckCapitalE][\[Theta] | \!\(\*SubsuperscriptBox[\(\[Sharp]\), \(n - 2\), \(\(\\\ \\\ \)\(-1\)\)]\) < \[Theta] < \!\(\*SubsuperscriptBox[\(\[Sharp]\), \(n - 1\), \(\(\\\ \\\ \)\(-1\)\)]\)]  \[RightArrow] ",{\[Theta]Vals[[-2]],Accumulate[\[Theta]Prob][[-2]]-(1/14)},{1,0}]]
,Graphics[Text[" \[LeftArrow] \!\(\*SubsuperscriptBox[\(\[Theta]\), \(n    \), \(\(\\\ \\\ \)\(\)\)]\)  ",{\[Theta]Vals[[-1]],Accumulate[\[Theta]Prob][[-1]]-(1/14)},{-1,0}]]
,Graphics[Text[ " \[LeftArrow] \[DoubleStruckCapitalE][\[Theta] | \!\(\*SubsuperscriptBox[\(\[Sharp]\), \( 1\), \(-1\)]\) < \[Theta] < \!\(\*SubsuperscriptBox[\(\[Sharp]\), \(2\), \(-1\)]\)] = \!\(\*SubsuperscriptBox[\(\[Theta]\), \(\(\\\ \\\ \)\(2\)\), \(\)]\)",{\[Theta]Vals[[2]],\[Theta]Prob[[1]]*3/2},{-1,0}]]
,Ticks->{
 {
 {\[Sharp]InnerPts[[1]], "\!\(\*SubsuperscriptBox[\(\[Sharp]\), \(\(\\\ \\\ \)\(1\)\), \(-1\)]\)"}
(*,{\[Sharp]InnerPts[[-1]],"\!\(\*SubsuperscriptBox[\(\[Sharp]\), \(n - 1\), \(\(\\\ \\\ \)\(-1\)\)]\)"}*)
,{\[Theta]Vals[[1]]     ,"\!\(\*SubsuperscriptBox[\(\[Theta]\), \(\(\\\ \\\ \)\(1\)\), \(\)]\)"}
,{\[Theta]Vals[[-1]]    ,"\!\(\*SubsuperscriptBox[\(\[Theta]\), \(n      \), \(\(\\\ \\\ \)\(\)\)]\)"}
}
,{{0.                   ,"0."                                                                    },{\[Theta]Prob[[1]]     ,"\!\(\*SubscriptBox[\(\[Sharp]\), \(1\)]\)  "                               },{Accumulate[\[Theta]Prob][[-2]],"\!\(\*SubsuperscriptBox[\(\[Sharp]\), \(n - 1\), \(\\\ \\\ \)]\)"},{1.,"1."}}
}
,AxesLabel->{"\[Theta]","\[ScriptCapitalF]"}
,Epilog->{Dashed,Thickness[0.005],
(*,Line[{{\[Sharp]InnerPts[[ 1]],0.}       ,{\[Sharp]InnerPts[[ 1]],Accumulate[\[Theta]Prob][[ 1]]}}]*)
(*,Line[{{\[Sharp]InnerPts[[-1]],0.}       ,{\[Sharp]InnerPts[[-1]],Accumulate[\[Theta]Prob][[-2]]}}]*)
,Line[{{0.,0.01},{\[Sharp]OuterPts[[2]]     ,0.01}}]
,Line[{
{\[Sharp]InnerPts[[-1]],Accumulate[\[Theta]Prob][[-2]]}
,{2.,Accumulate[\[Theta]Prob][[-2]]}
}]
}
];

ExportFigs["discreteApprox",discreteApprox];
Print[discreteApprox];






