(* ::Package:: *)

(* setup_PerfectForesightSolutionTighterUpBd.m *)
(* Perfect foresight consumption function; \[Digamma] stands for 'foressight' *)

\[ScriptC]\[Digamma]TighterUpBd[mt_,PeriodsUntilT_]:=Block[{\[ScriptC]Val},
	If[PeriodsUntilT == 0
, (*then*) \[ScriptC]Val=mt
, (*else*) \[ScriptC]Val=\[Kappa]MaxLife[[PeriodsUntilT+1]] (mt + \[GothicH]MinLife[[PeriodsUntilT+1]])
];
  Return[\[ScriptC]Val];
]; (* End Block[]*)

\[Kappa]\[Digamma]TighterUpBd[mt_,PeriodsUntilT_]:=Block[{\[Kappa]Val},
	If[PeriodsUntilT == 0
, (*then*) \[Kappa]Val=1
, (*else*) \[Kappa]Val=\[Kappa]MaxLife[[PeriodsUntilT+1]]
];
  Return[\[Kappa]Val];
]; (* End Block[]*)

\[CapitalLambda]\[Digamma]TighterUpBd[mt_,PeriodsUntilT_]:= Block[{\[CapitalLambda]Val},
  If[PeriodsUntilT == 0
, (*then*)\[CapitalLambda]Val=mt
, (*else*)\[CapitalLambda]Val=\[CapitalLambda]\[Digamma]TighterUpBdFuncLife[[PeriodsUntilT+1]][mt]
];
 Return[\[CapitalLambda]Val];
]; (* End Block[]*)

\[ScriptV]\[Digamma]TighterUpBd[mt_,PeriodsUntilT_]:= Block[{\[CapitalLambda]Val, vVal},
  \[CapitalLambda]Val=\[CapitalLambda]\[Digamma]TighterUpBd[mt, PeriodsUntilT];
  vVal=u[\[CapitalLambda]Val];
Return[vVal];
]; (* End Block[]*)


(*
\[ScriptV]m\[Digamma]TighterUpBd[mt_,PeriodsUntilT_]:= Block[{\[ScriptC]Val, vmVal},
  \[ScriptC]Val=\[ScriptC]\[Digamma]TighterUpBd[mt, PeriodsUntilT];
  vmVal=uP[\[ScriptC]Val];
Return[vmVal];
]; (* End Block[]*)
*)


(*

\[ScriptV]\[Digamma]TighterUpBd[mt_,PeriodsUntilT_]:= Block[{\[ScriptC]Val, uVal, aVal, \[GothicV]Val, \[ScriptV]Val},
  \[ScriptC]Val=\[ScriptC]\[Digamma]TighterUpBd[mt,PeriodsUntilT];
  uVal=u[\[ScriptC]Val];
  If[PeriodsUntilT == 0
, (*then*)\[GothicV]Val=uVal
, (*else*)aVal=mt-\[ScriptC]Val
;         \[GothicV]Val=\[GothicV]\[Digamma]TighterUpBd[aVal, PeriodsUntilT]
;         \[ScriptV]Val=uVal+\[GothicV]Val
;
];
Return[\[ScriptV]Val];
]; (* End Block[]*)

*)


Clear[\[GothicV]\[Digamma]TighterUpBd, \[GothicV]a\[Digamma]TighterUpBd, \[GothicV]aa\[Digamma]TighterUpBd, \[GothicC]\[Digamma]TighterUpBd, \[GothicC]a\[Digamma]TighterUpBd];
(* With the consumption function, MPC function and value function at t+1, 
we can derive the GothicV function and its first two derivatives at t,
for those perfect-foresight but behaves likes the consumption rules as stipulated
by the TighterUpBd function.  *)

\[GothicV]\[Digamma]TighterUpBd[at_?NumericQ,PeriodsUntilT_] := Block[{\[Beta]tp1, Rtp1, \[ScriptCapitalG]tp1, yExptp1, mtp1, \[ScriptV]tp1, \[GothicV]Val},
	\[Beta]tp1=\[Beta]Life[[PeriodsUntilT+1]];
	Rtp1=RLife[[PeriodsUntilT+1]];
	\[ScriptCapitalG]tp1=\[ScriptCapitalG]Life[[PeriodsUntilT+1]];
    yExptp1=yExpLife[[PeriodsUntilT+1]];
  If[PeriodsUntilT == 0,(*then*)Return[0.]];
  (*else*)
  mtp1=at (Rtp1/\[ScriptCapitalG]tp1)+yExptp1;
  \[ScriptV]tp1=\[ScriptV]\[Digamma][mtp1,PeriodsUntilT-1];
  \[GothicV]Val=(\[Beta]tp1 \[ScriptCapitalG]tp1^(1-\[Rho]))*\[ScriptV]tp1;
  Return[\[GothicV]Val];
]; (* End Block[]*)

\[GothicV]a\[Digamma]TighterUpBd[at_?NumericQ,PeriodsUntilT_] := Block[{\[Beta]tp1, Rtp1, \[ScriptCapitalG]tp1,  yExptp1, mtp1, \[ScriptC]tp1, \[GothicV]aVal},
	\[Beta]tp1=\[Beta]Life[[PeriodsUntilT+1]];
	Rtp1=RLife[[PeriodsUntilT+1]];
	\[ScriptCapitalG]tp1=\[ScriptCapitalG]Life[[PeriodsUntilT+1]];
    yExptp1=yExpLife[[PeriodsUntilT+1]];
  If[PeriodsUntilT == 0,(*then*)Return[0.]];
  (*else*)
  mtp1=at (Rtp1/\[ScriptCapitalG]tp1)+yExptp1;
  \[ScriptC]tp1=\[ScriptC]\[Digamma][mtp1,PeriodsUntilT-1];
  \[GothicV]aVal=(\[Beta]tp1 \[ScriptCapitalG]tp1^(-\[Rho])) Rtp1*uP[\[ScriptC]tp1];
  Return[\[GothicV]aVal];
];(*End Block[]*)

\[GothicV]aa\[Digamma]TighterUpBd[at_?NumericQ,PeriodsUntilT_] := Block[{\[Beta]tp1, Rtp1, \[ScriptCapitalG]tp1,  yExptp1, mtp1, \[ScriptC]tp1, \[Kappa]tp1, \[GothicV]aaVal},
	\[Beta]tp1=\[Beta]Life[[PeriodsUntilT+1]];
	Rtp1=RLife[[PeriodsUntilT+1]];
	\[ScriptCapitalG]tp1=\[ScriptCapitalG]Life[[PeriodsUntilT+1]];
    yExptp1=yExpLife[[PeriodsUntilT+1]];
  If[PeriodsUntilT == 0,(*then*)Return[0.]];
  (*else*)
  mtp1=at (Rtp1/\[ScriptCapitalG]tp1)+yExptp1;
  \[ScriptC]tp1=\[ScriptC]\[Digamma][mtp1,PeriodsUntilT-1];
  \[Kappa]tp1=\[Kappa]\[Digamma][mtp1,PeriodsUntilT-1];
  \[GothicV]aaVal=(\[Beta]tp1*Rtp1^(2)*\[ScriptCapitalG]tp1^(-\[Rho]-1))*uPP[\[ScriptC]tp1]*\[Kappa]tp1;
  Return[\[GothicV]aaVal];
];(*End Block[]*)

\[GothicC]\[Digamma]TighterUpBd[at_?NumericQ, PeriodsUntilT_] := nP[\[GothicV]a\[Digamma]TighterUpBd[at,PeriodsUntilT]];

\[GothicC]a\[Digamma]TighterUpBd[at_?NumericQ, PeriodsUntilT_]:=\[GothicV]aa\[Digamma]TighterUpBd[at,PeriodsUntilT]/uPP[(\[GothicV]a\[Digamma]TighterUpBd[at,PeriodsUntilT])^(-1/\[Rho])];

\[GothicC]aa\[Digamma]TighterUpBd[at_?NumericQ, PeriodsUntilT_]:=(\[GothicC]a\[Digamma]TighterUpBd[at+0.00001,PeriodsUntilT]-\[GothicC]a\[Digamma]TighterUpBd[at,PeriodsUntilT])/0.000001;

\[GothicC]aaa\[Digamma]TighterUpBd[at_?NumericQ, PeriodsUntilT_]:=(\[GothicC]aa\[Digamma]TighterUpBd[at+0.0000001,PeriodsUntilT]-\[GothicC]aa\[Digamma]TighterUpBd[at,PeriodsUntilT])/0.00000001;

SetAttributes[{\[ScriptC]\[Digamma]TighterUpBd,\[ScriptV]\[Digamma]TighterUpBd,\[GothicV]\[Digamma]TighterUpBd,\[GothicV]a\[Digamma]TighterUpBd,\[GothicV]aa\[Digamma]TighterUpBd,\[GothicC]\[Digamma]TighterUpBd,\[GothicC]a\[Digamma]TighterUpBd}, Listable]; (* Allows funcs to operate on lists *)
