(* ::Package:: *)

ClearAll[FuncToDefine\[GothicV]Func];
FuncToDefine\[GothicV]Func[\[Rho]_?NumericQ]:=Block[{},

Clear[\[GothicV],\[GothicV]a,\[GothicV]aa,\[GothicC],\[GothicC]a];
(* The idea here is that with consumption function, MPC function and value function at t+1,
we could derive the GothicV function and its first two derivatives at t.  *)

(* Note the difference between this section and the previous 2period: here we have 
shocks to both permanent and transitory income. *)

\[GothicV][at_?NumericQ,PeriodsUntilT_] := Block[{mtp1, \[GothicV]Val},
  If[PeriodsUntilT == 0,(*then*)Return[0.]];
  (*else*)
  \[GothicV]Val=\[Beta]Life[[PeriodsUntilT+1]]*Sum[
       mtp1=at*RLife[[PeriodsUntilT+1]]/(\[CapitalPsi]Vals[[\[CapitalPsi]Loop]]*\[ScriptCapitalG]Life[[PeriodsUntilT+1]]) + \[Theta]Vals[[\[Theta]Loop]];
      Times[\[Theta]Probs[[\[Theta]Loop]]*\[CapitalPsi]Probs[[\[CapitalPsi]Loop]]
, (\[CapitalPsi]Vals[[\[CapitalPsi]Loop]]*\[ScriptCapitalG]Life[[PeriodsUntilT+1]])^(1-\[Rho])
, \[ScriptV][mtp1,PeriodsUntilT-1]
], {\[Theta]Loop,1,Length[\[Theta]Vals]}, {\[CapitalPsi]Loop,1,Length[\[CapitalPsi]Vals]}];  
  Return[\[GothicV]Val];
]; (* End Block[]*)

\[GothicV]a[at_?NumericQ,PeriodsUntilT_] := Block[{mtp1,\[GothicV]aVal},
  If[PeriodsUntilT == 0,(*then*)Return[0.]];
  (*else*)
  \[GothicV]aVal=\[Beta]Life[[PeriodsUntilT+1]]*RLife[[PeriodsUntilT+1]]*Sum[
      mtp1=at*RLife[[PeriodsUntilT+1]]/(\[CapitalPsi]Vals[[\[CapitalPsi]Loop]]*\[ScriptCapitalG]Life[[PeriodsUntilT+1]]) + \[Theta]Vals[[\[Theta]Loop]];
      Times[\[Theta]Probs[[\[Theta]Loop]]*\[CapitalPsi]Probs[[\[CapitalPsi]Loop]]
, (\[CapitalPsi]Vals[[\[CapitalPsi]Loop]]*\[ScriptCapitalG]Life[[PeriodsUntilT+1]])^(-\[Rho])
, uP[\[ScriptC][mtp1, PeriodsUntilT-1]]
], {\[Theta]Loop,1,Length[\[Theta]Vals]}, {\[CapitalPsi]Loop,1,Length[\[CapitalPsi]Vals]}];  
  Return[\[GothicV]aVal];
];(*End Block[]*)

\[GothicV]aa[at_?NumericQ,PeriodsUntilT_] := Block[{mtp1,\[GothicV]aaVal},
  If[PeriodsUntilT == 0,(*then*)Return[0.]];
  (*else*)
  \[GothicV]aaVal=\[Beta]Life[[PeriodsUntilT+1]]*RLife[[PeriodsUntilT+1]]^(2)*Sum[
      mtp1=at*RLife[[PeriodsUntilT+1]]/(\[CapitalPsi]Vals[[\[CapitalPsi]Loop]]*\[ScriptCapitalG]Life[[PeriodsUntilT+1]]) + \[Theta]Vals[[\[Theta]Loop]];
      Times[\[Theta]Probs[[\[Theta]Loop]]*\[CapitalPsi]Probs[[\[CapitalPsi]Loop]]
, (\[CapitalPsi]Vals[[\[CapitalPsi]Loop]]*\[ScriptCapitalG]Life[[PeriodsUntilT+1]])^(-\[Rho]-1)
, uPP[\[ScriptC][mtp1,PeriodsUntilT-1]]
, \[Kappa][mtp1,PeriodsUntilT-1]
], {\[Theta]Loop,1,Length[\[Theta]Vals]}, {\[CapitalPsi]Loop,1,Length[\[CapitalPsi]Vals]}];  
  Return[\[GothicV]aaVal];
];(*End Block[]*)

\[GothicC][at_?NumericQ, PeriodsUntilT_] := nP[\[GothicV]a[at,PeriodsUntilT]];

\[GothicC]a[at_?NumericQ, PeriodsUntilT_]:=\[GothicV]aa[at,PeriodsUntilT]/uPP[(\[GothicV]a[at,PeriodsUntilT])^(-1/\[Rho])];

\[GothicC]aa[at_?NumericQ, PeriodsUntilT_]:=(\[GothicC]a[at+0.00001,PeriodsUntilT]-\[GothicC]a[at,PeriodsUntilT])/0.000001;

\[GothicC]aaa[at_?NumericQ, PeriodsUntilT_]:=(\[GothicC]aa[at+0.0000001,PeriodsUntilT]-\[GothicC]aa[at,PeriodsUntilT])/0.00000001;

SetAttributes[{\[GothicV],\[GothicV]a,\[GothicV]aa,\[GothicC],\[GothicC]a, \[GothicC]aa, \[GothicC]aaa}, Listable]; (* Allows funcs to operate on lists *)


(* Vector-based Functions *)
ClearAll[\[DoubleStruckCapitalE]All];

\[DoubleStruckCapitalE]All[aVect_?VectorQ, PeriodsUntilT_] := Block[{
  aVectLength, aVectLengthZero
, \[GothicC]Vec,\[Kappa]Vec,\[GothicC]PVec,\[GothicV]aVec,\[GothicV]aaVec,atp1Vec,mtp1Vec,\[GothicV]Vec},
aVectLength=Length[aVect];
If[PeriodsUntilT == 0
,(*then*)aVectLengthZero=Table[0., {aVectLength}]
; \[DoubleStruckCapitalE]AllThis={aVectLengthZero, aVectLengthZero, aVectLengthZero}];

If[PeriodsUntilT > 0, (*then*)
  mtp1Vec=Table[aVect*RLife[[PeriodsUntilT+1]]/(\[CapitalPsi]Vals[[\[CapitalPsi]Loop]]*\[ScriptCapitalG]Life[[PeriodsUntilT+1]]) + \[Theta]Vals[[\[Theta]Loop]]
               , {\[Theta]Loop,1,Length[\[Theta]Vals]}, {\[CapitalPsi]Loop,1,Length[\[CapitalPsi]Vals]}];
  mtp1VecFlatten=Flatten[mtp1Vec];
  {\[ScriptC]VectFlatten, \[Kappa]VectFlatten}=Transpose[\[ScriptC]N\[Kappa]Vec[mtp1VecFlatten, PeriodsUntilT-1]];
  {\[ScriptC]Vect, \[Kappa]Vect}=Map[Partition[Partition[#, Length[aVect]], Length[\[CapitalPsi]Vals]] &, {\[ScriptC]VectFlatten, \[Kappa]VectFlatten}];
  \[GothicV]aVal=\[Beta]Life[[PeriodsUntilT+1]]*RLife[[PeriodsUntilT+1]]*Sum[
      Times[\[Theta]Probs[[\[Theta]Loop]]*\[CapitalPsi]Probs[[\[CapitalPsi]Loop]]
      , (\[CapitalPsi]Vals[[\[CapitalPsi]Loop]]*\[ScriptCapitalG]Life[[PeriodsUntilT+1]])^(-\[Rho])
      , uP[\[ScriptC]Vect[[\[Theta]Loop, \[CapitalPsi]Loop]]]
      ], {\[Theta]Loop,1,Length[\[Theta]Vals]}, {\[CapitalPsi]Loop,1,Length[\[CapitalPsi]Vals]}];  
  \[GothicV]aaVal=\[Beta]Life[[PeriodsUntilT+1]]*RLife[[PeriodsUntilT+1]]^(2)*Sum[
        Times[\[Theta]Probs[[\[Theta]Loop]]*\[CapitalPsi]Probs[[\[CapitalPsi]Loop]]     
        , (\[CapitalPsi]Vals[[\[CapitalPsi]Loop]]*\[ScriptCapitalG]Life[[PeriodsUntilT+1]])^(-\[Rho]-1)
        , uPP[\[ScriptC]Vect[[\[Theta]Loop, \[CapitalPsi]Loop]]]
        , \[Kappa]Vect[[\[Theta]Loop, \[CapitalPsi]Loop]]
        ], {\[Theta]Loop,1,Length[\[Theta]Vals]}, {\[CapitalPsi]Loop,1,Length[\[CapitalPsi]Vals]}];  
  If[OptionToCalValFunc==True,
  \[ScriptV]Vect=\[ScriptV][mtp1Vec, PeriodsUntilT-1];
  \[GothicV]Val=\[Beta]Life[[PeriodsUntilT+1]]*Sum[
        Times[\[Theta]Probs[[\[Theta]Loop]]*\[CapitalPsi]Probs[[\[CapitalPsi]Loop]]
        , (\[CapitalPsi]Vals[[\[CapitalPsi]Loop]]*\[ScriptCapitalG]Life[[PeriodsUntilT+1]])^(1-\[Rho])
        , \[ScriptV]Vect[[\[Theta]Loop, \[CapitalPsi]Loop]]
        ], {\[Theta]Loop,1,Length[\[Theta]Vals]}, {\[CapitalPsi]Loop,1,Length[\[CapitalPsi]Vals]}];  
  ];
];

  \[DoubleStruckCapitalE]AllThis=If[OptionToCalValFunc==True
 , {\[GothicV]aVal, \[GothicV]aaVal, \[GothicV]Val}
 , {\[GothicV]aVal, \[GothicV]aaVal}];

Return[\[DoubleStruckCapitalE]AllThis];
];

]; (* End of Block *)
