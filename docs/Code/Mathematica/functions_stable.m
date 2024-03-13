(* ::Package:: *)

(* functions_stable.m: functions that remain unchanged across all model solution variants *)

Clear[\[GothicV],\[GothicV]a,\[GothicV]aa,\[GothicC],\[GothicC]a];
(* With the consumption function, MPC function and value function at t+1, 
we can derive the GothicV function and its first two derivatives at t.  *)

\[GothicV][at_?NumericQ,PeriodsUntilT_] := Block[{\[Beta]tp1, Rtp1, \[ScriptCapitalG]tp1, mtp1, \[GothicV]Val},
	\[Beta]tp1=\[Beta]Life[[PeriodsUntilT+1]];
	Rtp1=RLife[[PeriodsUntilT+1]];
	\[ScriptCapitalG]tp1=\[ScriptCapitalG]Life[[PeriodsUntilT+1]];
  If[PeriodsUntilT == 0,(*then*)Return[0.]];
  (*else*)\[GothicV]Val=
   (\[Beta]tp1 \[ScriptCapitalG]tp1^(1-\[Rho]))*
   Sum[
      mtp1=at (Rtp1/\[ScriptCapitalG]tp1)+\[Theta]Vals[[\[Theta]Loop]];
      \[Theta]Prob[[\[Theta]Loop]] \[ScriptV][mtp1,PeriodsUntilT-1]
  ,{\[Theta]Loop,Length[\[Theta]Vals]}];
  Return[\[GothicV]Val];
]; (* End Block[]*)

\[GothicV]a[at_?NumericQ,PeriodsUntilT_] := Block[{\[Beta]tp1, Rtp1, \[ScriptCapitalG]tp1, mtp1,\[GothicV]aVal},
	\[Beta]tp1=\[Beta]Life[[PeriodsUntilT+1]];
	Rtp1=RLife[[PeriodsUntilT+1]];
	\[ScriptCapitalG]tp1=\[ScriptCapitalG]Life[[PeriodsUntilT+1]];
  If[PeriodsUntilT == 0,(*then*)Return[0.]];
  (*else*)\[GothicV]aVal = 
  (\[Beta]tp1 \[ScriptCapitalG]tp1^(-\[Rho])) Rtp1*
  Sum[
      mtp1=at (Rtp1/\[ScriptCapitalG]tp1)+\[Theta]Vals[[\[Theta]Loop]];
      \[Theta]Prob[[\[Theta]Loop]] uP[\[ScriptC][mtp1,PeriodsUntilT-1]]
  ,{\[Theta]Loop,Length[\[Theta]Vals]}];
  Return[\[GothicV]aVal];
];(*End Block[]*)

\[GothicV]aa[at_?NumericQ,PeriodsUntilT_] := Block[{\[Beta]tp1, Rtp1, \[ScriptCapitalG]tp1, mtp1,\[GothicV]aaVal},
	\[Beta]tp1=\[Beta]Life[[PeriodsUntilT+1]];
	Rtp1=RLife[[PeriodsUntilT+1]];
	\[ScriptCapitalG]tp1=\[ScriptCapitalG]Life[[PeriodsUntilT+1]];
  If[PeriodsUntilT == 0,(*then*)Return[0.]];
  (*else*)\[GothicV]aaVal=
  (\[Beta]tp1*Rtp1^(2)*\[ScriptCapitalG]tp1^(-\[Rho]-1))*Sum[
      mtp1=at (Rtp1/\[ScriptCapitalG]tp1)+\[Theta]Vals[[\[Theta]Loop]];
      \[Theta]Prob[[\[Theta]Loop]] uPP[\[ScriptC][mtp1,PeriodsUntilT-1]]*\[Kappa][mtp1,PeriodsUntilT-1]
  ,{\[Theta]Loop,Length[\[Theta]Vals]}];
  Return[\[GothicV]aaVal];
];(*End Block[]*)

\[GothicC][at_?NumericQ, PeriodsUntilT_] := nP[\[GothicV]a[at,PeriodsUntilT]];

\[GothicC]a[at_?NumericQ, PeriodsUntilT_]:=\[GothicV]aa[at,PeriodsUntilT]/uPP[(\[GothicV]a[at,PeriodsUntilT])^(-1/\[Rho])];

\[GothicC]aa[at_?NumericQ, PeriodsUntilT_]:=(\[GothicC]a[at+0.00001,PeriodsUntilT]-\[GothicC]a[at,PeriodsUntilT])/0.000001;

\[GothicC]aaa[at_?NumericQ, PeriodsUntilT_]:=(\[GothicC]aa[at+0.0000001,PeriodsUntilT]-\[GothicC]aa[at,PeriodsUntilT])/0.00000001;

SetAttributes[{\[ScriptC],\[ScriptV],\[GothicV],\[GothicV]a,\[GothicV]aa,\[GothicC],\[GothicC]a}, Listable]; (* Allows funcs to operate on lists *)
