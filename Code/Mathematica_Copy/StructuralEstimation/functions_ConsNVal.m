(* ::Package:: *)

(*
ClearAll[\[Chi]];
\[Chi][\[Mu]_?NumericQ,PeriodsUntilT_] := \[Chi]FuncLife[[PeriodsUntilT+1]][\[Mu]];

ClearAll[\[Chi]\[Mu]];
\[Chi]\[Mu][\[Mu]_?NumericQ,PeriodsUntilT_] := \[Chi]FuncLife[[PeriodsUntilT+1]]'[\[Mu]];
*)

ClearAll[\[Chi]];
\[Chi][\[Mu]t_?NumericQ,PeriodsUntilT_]:=\[Chi]FuncLife[[PeriodsUntilT+1]][\[Mu]t];
ClearAll[\[Chi]\[Mu]];
\[Chi]\[Mu][\[Mu]t_?NumericQ,PeriodsUntilT_]:=\[Chi]FuncLife[[PeriodsUntilT+1]]'[\[Mu]t];

\[Chi]Interp[\[Mu]t_?NumericQ,PeriodsUntilT_]:=\[Chi]FuncLife[[PeriodsUntilT+1]][\[Mu]t];

(* (*This is not necessary any more, since we expand the grid points 
in the interpolation. *)
\[Chi][\[Mu]t_?NumericQ,PeriodsUntilT_] := Block[{\[Mu]First, \[Mu]Last},
  \[Mu]First = \[Chi]FuncLife[[PeriodsUntilT+1]][[1,1,1]];
  \[Mu]Last = \[Chi]FuncLife[[PeriodsUntilT+1]][[1,1,-1]];
  If[\[Mu]t >= \[Mu]First && \[Mu]t <= \[Mu]Last, Return[\[Chi]FuncLife[[PeriodsUntilT+1]][\[Mu]t]]];
  (*else*)
  If[\[Mu]t < \[Mu]First, (* Assume it's linear below the interpolating Grid *)
    (*then*) Return[\[Chi]FuncLife[[PeriodsUntilT+1]][\[Mu]First]+(\[Mu]t-\[Mu]First)\[Chi]FuncLife[[PeriodsUntilT+1]]'[\[Mu]First]]];
  (*else*)
  If[\[Mu]t > \[Mu]Last, (* Assume it's linear above the interpolating Grid *)
    (*then*) Return[\[Chi]FuncLife[[PeriodsUntilT+1]][\[Mu]Last]+(\[Mu]t-\[Mu]Last)\[Chi]FuncLife[[PeriodsUntilT+1]]'[\[Mu]Last]]];
];

ClearAll[\[Chi]\[Mu]];
\[Chi]\[Mu][\[Mu]t_?NumericQ,PeriodsUntilT_] := Block[{\[Mu]First, \[Mu]Last},
  \[Mu]First = \[Chi]FuncLife[[PeriodsUntilT+1]][[1,1,1]];
  \[Mu]Last = \[Chi]FuncLife[[PeriodsUntilT+1]][[1,1,-1]];
  If[\[Mu]t >= \[Mu]First && \[Mu]t <= \[Mu]Last, Return[\[Chi]FuncLife[[PeriodsUntilT+1]]'[\[Mu]t]]];
  (*else*)
  If[\[Mu]t < \[Mu]First, (* Assume it's linear below the interpolating Grid *)
    (*then*) Return[\[Chi]FuncLife[[PeriodsUntilT+1]]'[\[Mu]First]]];
    (*else*)
  If[\[Mu]t > \[Mu]Last, (* Assume it's linear above the interpolating Grid *)
    (*then*) Return[\[Chi]FuncLife[[PeriodsUntilT+1]]'[\[Mu]Last]]];
];

*)


ClearAll[\[ScriptC], \[ScriptC]BeforeT, \[ScriptC]From\[Chi]];
\[ScriptC][mt_?NumericQ, PeriodsUntilT_] := If[PeriodsUntilT == 0
  ,(*then*) Return[mt]
  ,(*else*) \[ScriptC]BeforeT[mt,PeriodsUntilT]];
\[ScriptC]BeforeT[mt_?NumericQ, PeriodsUntilT_] := Block[{cUnconstr},
  If[Constrained==False, Return[\[ScriptC]From\[Chi][mt,PeriodsUntilT]]];
  cUnconstr = \[ScriptC]From\[Chi][mt,PeriodsUntilT];
  If[cUnconstr > mt, Return[mt]]; (* If you want to consume more than m, too bad! *)
  Return[cUnconstr];
];
\[ScriptC]From\[Chi][mt_?NumericQ, PeriodsUntilT_]:= Block[{
  mLowerBoundt, \[FilledUpTriangle]mt, \[FilledUpTriangle]\[GothicH]t, \[Kappa]t, \[Mu]t, \[Mu]First, \[Chi]t, \[Koppa]t, ctOptmst, ctPesmst, ctRealst},
  mLowerBoundt = \[GothicA]LowerBoundLife[[PeriodsUntilT+1]]; 
  \[FilledUpTriangle]mt   = mt-mLowerBoundt;
  \[FilledUpTriangle]\[GothicH]t   = \[FilledUpTriangle]\[GothicH]AccessibleLife[[PeriodsUntilT+1]];
  \[Kappa]t    = \[Kappa]MinLife[[PeriodsUntilT+1]];
  \[Mu]t = Log[\[FilledUpTriangle]mt];
  If[Chop[mt - mLowerBoundt]==0,\[Mu]t=-Infinity];
  \[Chi]t  = \[Chi][\[Mu]t,PeriodsUntilT];
  \[Koppa]t=1/(1+Exp[\[Chi]t]);
(*See Derivations.nb for derivations of formulas below *)
  ctOptmst = \[Kappa]t (\[FilledUpTriangle]mt+\[FilledUpTriangle]\[GothicH]t);
  ctPesmst = \[Kappa]t (\[FilledUpTriangle]mt); 
  ctRealst = ctOptmst-(ctOptmst-ctPesmst) \[Koppa]t; 
  Return[ctRealst]
];(*End Block*)
\[ScriptC][mt_?NumericQ] := \[ScriptC][mt,Length[\[Beta]Life]-1]; (* Without lifeperiod argument, use most recently solved *)


ClearAll[\[Kappa], \[Kappa]BeforeT, \[Kappa]From\[Chi]];
\[Kappa][mt_?NumericQ,PeriodsUntilT_] := If[PeriodsUntilT == 0,Return[1.]
, (*else*)\[Kappa]BeforeT[mt,PeriodsUntilT]];
\[Kappa]BeforeT[mt_?NumericQ,PeriodsUntilT_] := Block[{cUnconstr,\[Kappa]Unconstr},
  If[Constrained==False, Return[\[Kappa]From\[Chi][mt,PeriodsUntilT]]];
  cUnconstr = \[ScriptC]From\[Chi][mt,PeriodsUntilT];
  If[cUnconstr > mt,Return[1.]]; (* MPC is 1 if consumer is liquidity constrained *)
  Return[\[Kappa]From\[Chi][mt,PeriodsUntilT]]
];
\[Kappa]From\[Chi][mt_?NumericQ,PeriodsUntilT_]:=Block[{mLowerBoundt, \[FilledUpTriangle]mt, \[FilledUpTriangle]\[GothicH]t, \[Kappa]t, \[Mu]t, \[Mu]First, \[Chi]t, \[Chi]\[Mu]t, \[Koppa]t, \[Koppa]\[Mu]t, ctOptmst, ctPesmst, ctRealst, \[Kappa]tOptmst, \[Kappa]tPesmst, \[Kappa]tRealst},
  mLowerBoundt = \[GothicA]LowerBoundLife[[PeriodsUntilT+1]]; 
  \[FilledUpTriangle]mt   = mt-mLowerBoundt;
  \[FilledUpTriangle]\[GothicH]t   = \[FilledUpTriangle]\[GothicH]AccessibleLife[[PeriodsUntilT+1]];
  \[Kappa]t    = \[Kappa]MinLife[[PeriodsUntilT+1]];
  \[Mu]t = Log[\[FilledUpTriangle]mt];
  If[Chop[mt - mLowerBoundt]==0,\[Mu]t=-Infinity];
  \[Chi]t  = \[Chi][\[Mu]t,PeriodsUntilT];
  \[Chi]\[Mu]t = \[Chi]\[Mu][\[Mu]t,PeriodsUntilT];
  \[Koppa]t=1/(1+Exp[\[Chi]t]);
  \[Koppa]\[Mu]t = \[Chi]\[Mu]t (\[Koppa]t-1) \[Koppa]t;
(*See Derivations.nb for derivations of formulas below *)
  ctOptmst = \[Kappa]t (\[FilledUpTriangle]mt+\[FilledUpTriangle]\[GothicH]t);
  ctPesmst = \[Kappa]t (\[FilledUpTriangle]mt); 
  ctRealst = ctOptmst-(ctOptmst-ctPesmst) \[Koppa]t; 
  \[Kappa]tOptmst=\[Kappa]t;
  \[Kappa]tPesmst=\[Kappa]t;
  \[Kappa]tRealst=\[Kappa]tOptmst-\[Koppa]\[Mu]t (ctOptmst-ctPesmst)/\[FilledUpTriangle]mt -(ctOptmst-ctRealst)(\[Kappa]tOptmst-\[Kappa]tPesmst)/(ctOptmst-ctPesmst);
  Return[\[Kappa]tRealst]
];
\[Kappa][mt_?NumericQ] := \[Kappa][mt,Length[\[Beta]Life]-1]; (* Without lifeperiod argument, use most recently solved *)


ClearAll[FuncToDefine\[CapitalLambda]Func];

FuncToDefine\[CapitalLambda]Func[\[Rho]_?NumericQ] := Block[{},

ClearAll[\[CapitalChi]];
\[CapitalChi][\[Mu]_?NumericQ,PeriodsUntilT_] := \[CapitalChi]FuncLife[[PeriodsUntilT+1]][\[Mu]];

ClearAll[\[CapitalChi]\[Mu]];
\[CapitalChi]\[Mu][\[Mu]_?NumericQ,PeriodsUntilT_] := \[CapitalChi]FuncLife[[PeriodsUntilT+1]]'[\[Mu]];

ClearAll[\[CapitalLambda], \[CapitalLambda]BeforeT, \[CapitalLambda]From\[CapitalChi]];
\[CapitalLambda][mt_?NumericQ,PeriodsUntilT_] := If[PeriodsUntilT==0,mt,(*else*)\[CapitalLambda]BeforeT[mt,PeriodsUntilT]];
\[CapitalLambda]BeforeT[mt_?NumericQ,PeriodsUntilT_]:= Block[{\[CapitalLambda]Unconstr,cUnconstr},
 If[Constrained==False, Return[\[CapitalLambda]From\[CapitalChi][mt,PeriodsUntilT]]];
  cUnconstr = \[ScriptC]From\[Chi][mt,PeriodsUntilT];
 If[cUnconstr > mt,
    cWhereConstrBinds = \[GothicC]FuncLife[[PeriodsUntilT+1]][0.];
    vWhereConstrBinds=u[\[CapitalLambda]From\[CapitalChi][cWhereConstrBinds,PeriodsUntilT]];
    vConstr = vWhereConstrBinds+u[mt]-u[cWhereConstrBinds]; (* Because MPC is 1 below point where constraint binds *)
    Return[n[vConstr]]]; (* n is the inverse of u *)
 Return[\[CapitalLambda]From\[CapitalChi][mt,PeriodsUntilT]];
];
\[CapitalLambda]From\[CapitalChi][mt_?NumericQ,PeriodsUntilT_]:= Block[{mLowerBoundt,\[FilledUpTriangle]mt,\[FilledUpTriangle]\[GothicH]t,\[Kappa]t,\[Mu]t,\[CapitalChi]t, ctOptmst, ctPesmst,\[CapitalLambda]tOptmst,\[CapitalLambda]tPesmst, \[CapitalLambda]tRealst, \[CapitalKoppa]t, \[Mu]First,\[DoubleStruckCapitalC]t},
  mLowerBoundt = \[GothicA]LowerBoundLife[[PeriodsUntilT+1]]; 
  \[FilledUpTriangle]mt   = mt-mLowerBoundt;
  \[FilledUpTriangle]\[GothicH]t   = \[FilledUpTriangle]\[GothicH]AccessibleLife[[PeriodsUntilT+1]];
  \[Kappa]t    = \[Kappa]MinLife[[PeriodsUntilT+1]];
  \[Mu]t = Log[\[FilledUpTriangle]mt];
  \[CapitalChi]t = \[CapitalChi][\[Mu]t,PeriodsUntilT];
(*See Derivations.nb for derivations of formulas below *)
(*  \[DoubleStruckCapitalC]t = (1- \[CapitalThorn]^(PeriodsUntilT+1))/(1-\[CapitalThorn]);*)
  \[DoubleStruckCapitalC]t = vSumLife[[PeriodsUntilT+1]];
  ctOptmst = \[Kappa]t (\[FilledUpTriangle]mt+\[FilledUpTriangle]\[GothicH]t);
  ctPesmst = \[Kappa]t (\[FilledUpTriangle]mt); 
  \[CapitalLambda]tOptmst = ctOptmst (\[DoubleStruckCapitalC]t)^(1/(1-\[Rho]));
  \[CapitalLambda]tPesmst = ctPesmst (\[DoubleStruckCapitalC]t)^(1/(1-\[Rho]));
  \[CapitalKoppa]t=1/(1+Exp[\[CapitalChi]t]);
  \[CapitalLambda]tRealst = \[CapitalLambda]tOptmst-\[CapitalKoppa]t*(\[CapitalLambda]tOptmst-\[CapitalLambda]tPesmst); 
  Return[\[CapitalLambda]tRealst]; 
];(*End Block*)

ClearAll[\[ScriptV], \[ScriptV]BeforeT, \[ScriptV]From\[CapitalChi]];
\[ScriptV][mt_?NumericQ,PeriodsUntilT_] := If[PeriodsUntilT==0,u[mt],(*else*)\[ScriptV]BeforeT[mt,PeriodsUntilT]];
\[ScriptV]BeforeT[mt_?NumericQ,PeriodsUntilT_] := \[ScriptV]From\[CapitalChi][mt,PeriodsUntilT];
\[ScriptV]From\[CapitalChi][mt_?NumericQ,PeriodsUntilT_] := u[\[CapitalLambda][mt,PeriodsUntilT]];
\[ScriptV][mt_?NumericQ] := \[ScriptV][mt,Length[\[Beta]Life]-1]; (* Without lifeperiod argument, use most recently solved *)

ClearAll[\[ScriptV]m, \[ScriptV]mBeforeT];
\[ScriptV]m[mt_?NumericQ,PeriodsUntilT_] := If[PeriodsUntilT==0,uP[mt],(*else*)\[ScriptV]mBeforeT[mt,PeriodsUntilT]];
\[ScriptV]mBeforeT[mt_?NumericQ,PeriodsUntilT_] := uP[\[ScriptC][mt, PeriodsUntilT]];

SetAttributes[{\[Chi], \[Chi]\[Mu]
, \[ScriptC], \[ScriptC]BeforeT, \[ScriptC]From\[Chi]
, \[Kappa], \[Kappa]BeforeT, \[Kappa]From\[Chi]
, \[CapitalChi], \[CapitalChi]\[Mu]
, \[CapitalLambda], \[CapitalLambda]BeforeT, \[CapitalLambda]From\[CapitalChi]
, \[ScriptV], \[ScriptV]BeforeT, \[ScriptV]From\[CapitalChi]
, \[ScriptV]m, \[ScriptV]mBeforeT}, Listable]; (* Allows funcs to operate on lists *)

]; (* End of Block *)


(* ::Subsection:: *)
(*Vector-based function (to be used in Setup_ConsFn.m)*)


(* \[Chi]N\[Chi]\[Mu]Vec is a special function that calculate a vector of optimal \[Chi] and \[Chi]\[Mu]
 corresponding to a vector of \[Mu]. This is much faster than calculating
both one by one. It will be used in generating the sequence of optimal consumption function.*)

ClearAll[\[Chi]N\[Chi]\[Mu]Vec];

\[Chi]N\[Chi]\[Mu]Vec[\[Mu]Vect_?VectorQ,PeriodsUntilT_] := Block[{},
  \[Chi]N\[Chi]\[Mu]Vect=Table[{Null, Null}, {i, 1, Length[\[Mu]Vect]}];
  For[i=1, i<=Length[\[Mu]Vect], i++,
  \[Mu]t=\[Mu]Vect[[i]];
  {\[Chi]t, \[Chi]\[Mu]t}={\[Chi]FuncLife[[PeriodsUntilT+1]][\[Mu]t]
, \[Chi]FuncLife[[PeriodsUntilT+1]]'[\[Mu]t]};
  \[Chi]N\[Chi]\[Mu]Vect[[i]]={\[Chi]t, \[Chi]\[Mu]t};
  ];
Return[\[Chi]N\[Chi]\[Mu]Vect];
];(*End Block*)

(*
\[Chi]N\[Chi]\[Mu]Vec[\[Mu]Vect_?VectorQ,PeriodsUntilT_] := Block[{\[Mu]First, \[Mu]Last(*, \[Mu]t, \[Chi]t, \[Chi]\[Mu]t*)},
  \[Mu]First = \[Chi]FuncLife[[PeriodsUntilT+1]][[1,1,1]];
  \[Mu]Last = \[Chi]FuncLife[[PeriodsUntilT+1]][[1,1,-1]];
  \[Chi]N\[Chi]\[Mu]Vect=Table[{Null, Null}, {i, 1, Length[\[Mu]Vect]}];
  For[i=1, i<=Length[\[Mu]Vect], i++,
  \[Mu]t=\[Mu]Vect[[i]];
  {\[Chi]t, \[Chi]\[Mu]t}=Piecewise[{
  {{\[Chi]FuncLife[[PeriodsUntilT+1]][\[Mu]t]
, \[Chi]FuncLife[[PeriodsUntilT+1]]'[\[Mu]t]}
, \[Mu]t >= \[Mu]First && \[Mu]t <= \[Mu]Last}
, {{\[Chi]FuncLife[[PeriodsUntilT+1]][\[Mu]First]+(\[Mu]t-\[Mu]First)\[Chi]FuncLife[[PeriodsUntilT+1]]'[\[Mu]First]
, \[Chi]FuncLife[[PeriodsUntilT+1]]'[\[Mu]First]}
, \[Mu]t < \[Mu]First}
, {{\[Chi]FuncLife[[PeriodsUntilT+1]][\[Mu]Last]+(\[Mu]t-\[Mu]Last)\[Chi]FuncLife[[PeriodsUntilT+1]]'[\[Mu]Last]
, \[Chi]FuncLife[[PeriodsUntilT+1]]'[\[Mu]Last]}
, \[Mu]t > \[Mu]Last}
  }];
  \[Chi]N\[Chi]\[Mu]Vect[[i]]={\[Chi]t, \[Chi]\[Mu]t};
  ];
Return[\[Chi]N\[Chi]\[Mu]Vect];
];(*End Block*)
*)


(* \[ScriptC]N\[Kappa]Vec is a special function that calculate a vector of optimal \[ScriptC] and \[Kappa]
 corresponding to a vector of m. This is much faster than calculating
both one by one. It will be used in generating the sequence of optimal consumption function. *)

ClearAll[\[ScriptC]N\[Kappa]Vec];
\[ScriptC]N\[Kappa]Vec[mVect_?VectorQ, PeriodsUntilT_]:=Block[{
  mLowerBoundt, \[FilledUpTriangle]mVect, \[FilledUpTriangle]\[GothicH]t, \[Kappa]t, \[Mu]Vect, \[Chi]Vect, \[Chi]\[Mu]Vect
, \[Koppa]Vect, \[Koppa]\[Mu]Vect
, cVectOptmst, cVectPesmst, cVectRealst
, \[Kappa]VectOptmst, \[Kappa]VectPesmst, \[Kappa]VectRealst
, aVectRealst, aVectRealstNonpos, IndexNonpos},
If[PeriodsUntilT == 0, Return[Transpose[{mVect, mVect/mVect}]]
, mLowerBoundt = \[GothicA]LowerBoundLife[[PeriodsUntilT+1]]; 
  \[FilledUpTriangle]mVect   = mVect-mLowerBoundt;
  \[FilledUpTriangle]\[GothicH]t   = \[FilledUpTriangle]\[GothicH]AccessibleLife[[PeriodsUntilT+1]];
  \[Kappa]t    = \[Kappa]MinLife[[PeriodsUntilT+1]];
  \[Mu]Vect = Log[\[FilledUpTriangle]mVect];
  {\[Chi]Vect, \[Chi]\[Mu]Vect}=Transpose[\[Chi]N\[Chi]\[Mu]Vec[\[Mu]Vect,PeriodsUntilT]];
  \[Koppa]Vect=1/(1+Exp[\[Chi]Vect]);
  \[Koppa]\[Mu]Vect = \[Chi]\[Mu]Vect (\[Koppa]Vect-1) \[Koppa]Vect;
(*See Derivations.nb for derivations of formulas below *)
  cVectOptmst = \[Kappa]t (\[FilledUpTriangle]mVect+\[FilledUpTriangle]\[GothicH]t);
  cVectPesmst = \[Kappa]t (\[FilledUpTriangle]mVect); 
  cVectRealst = cVectOptmst-(cVectOptmst-cVectPesmst) \[Koppa]Vect; 
  \[Kappa]VectOptmst=\[Kappa]t;
  \[Kappa]VectPesmst=\[Kappa]t;
  \[Kappa]VectRealst=\[Kappa]VectOptmst-\[Koppa]\[Mu]Vect (cVectOptmst-cVectPesmst)/\[FilledUpTriangle]mVect -(cVectOptmst-cVectRealst)(\[Kappa]VectOptmst-\[Kappa]VectPesmst)/(cVectOptmst-cVectPesmst);
  aVectRealst=mVect-cVectRealst;

(* This part is similar to the transformation from \[ScriptC]From\[Chi] to \[ScriptC].*)
(* Impose the liquidity constraint *)
If[Select[aVectRealst, #<=0 &]!={}
, aVectRealstNonpos=Select[aVectRealst, #<=0 &]
; If[OptionPrintNonposAsset==True
, Print["Error: Nonpositive at! for ", Length[aVectRealstNonpos], " People in ConsFn"]
; ]
; IndexNonpos=Flatten[Map[Position[aVectRealst, #] &, aVectRealstNonpos], 2];
; Table[cVectRealst[[i]]=mVect[[i]]-atTiny
;       \[Kappa]VectRealst[[i]]=1
, {i, IndexNonpos}];
];
  Return[Transpose[{cVectRealst, \[Kappa]VectRealst}]];
];
];(*End Block*)


(* ::Subsection:: *)
(*Vector-based function (to be used in Setup_Sim.m)*)


(* \[ScriptC]VecMoM is a special function that calculate a vector of \[ScriptC]
 corresponding to a vector of m. This is much faster than calculating
 the optimal consumption one by one. *)
ClearAll[\[ScriptC]VecMoM];
\[ScriptC]VecMoM[mVect_?VectorQ, PeriodsUntilT_]:=Block[{
  mLowerBoundt, \[FilledUpTriangle]mVect, \[FilledUpTriangle]\[GothicH]t, \[Kappa]t, \[Mu]Vect, \[Chi]Vect, \[Koppa]Vect, cVectOptmst, cVectPesmst, cVectRealst
, aVectRealst, aVectRealstNonpos, IndexNonpos},
If[PeriodsUntilT == 0, Return[mVect]
, mLowerBoundt = \[GothicA]LowerBoundLife[[PeriodsUntilT+1]]; 
  \[FilledUpTriangle]mVect   = mVect-mLowerBoundt;
  \[FilledUpTriangle]\[GothicH]t   = \[FilledUpTriangle]\[GothicH]AccessibleLife[[PeriodsUntilT+1]];
  \[Kappa]t    = \[Kappa]MinLife[[PeriodsUntilT+1]];
  \[Mu]Vect = Log[\[FilledUpTriangle]mVect];
  \[Chi]Vect  = \[Chi]Vec[\[Mu]Vect,PeriodsUntilT];
  \[Koppa]Vect=1/(1+Exp[\[Chi]Vect]);
(*See Derivations.nb for derivations of formulas below *)
  cVectOptmst = \[Kappa]t (\[FilledUpTriangle]mVect+\[FilledUpTriangle]\[GothicH]t);
  cVectPesmst = \[Kappa]t (\[FilledUpTriangle]mVect); 
  cVectRealst = cVectOptmst-(cVectOptmst-cVectPesmst) \[Koppa]Vect; 
  aVectRealst = mVect-cVectRealst;
(* This part is similar to the transformation from \[ScriptC]From\[Chi] to \[ScriptC].*)
If[Select[aVectRealst, #<=0 &]!={}
, aVectRealstNonpos=Select[aVectRealst, #<=0 &]
; If[OptionPrintNonposAsset==True
, Print["Error: Nonpositive at! for ", Length[aVectRealstNonpos], " People in Sim"]
; ]
; IndexNonpos=Flatten[Map[Position[aVectRealst, #] &, aVectRealstNonpos], 2];
; Table[cVectRealst[[i]]=mVect[[i]]-atTiny
, {i, IndexNonpos}];
];
  Return[cVectRealst];
];
];(*End Block*)


ClearAll[\[Chi]VecSort];
(* \[Chi]VecSort is a vector-based function using sort. Slow! *)

\[Chi]VecSort[\[Mu]Vect_?VectorQ,PeriodsUntilT_] := Block[{\[Mu]First, \[Mu]Last},
  \[Mu]First = \[Chi]FuncLife[[PeriodsUntilT+1]][[1,1,1]];
  \[Mu]Last = \[Chi]FuncLife[[PeriodsUntilT+1]][[1,1,-1]];
  \[Mu]VectLength=Length[\[Mu]Vect];
  IndexVec=Table[i, {i, 1,  \[Mu]VectLength}];
  \[Mu]VectExpand1st=Transpose[{\[Mu]Vect, IndexVec}];
  \[Mu]VectExpand1stSort=Sort[\[Mu]VectExpand1st, #1[[1]]<#2[[1]] &];

 Index\[Mu]FirstDraft=Select[IndexVec, \[Mu]VectExpand1stSort[[#, 1]]>=\[Mu]First &, 1];
 Index\[Mu]LastDraft=Select[IndexVec, \[Mu]VectExpand1stSort[[#, 1]]>\[Mu]Last &, 1];
 Index\[Mu]First=If[Index\[Mu]FirstDraft=={}, \[Mu]VectLength+1, Index\[Mu]FirstDraft[[1]]];
 Index\[Mu]Last=If[Index\[Mu]LastDraft=={}, \[Mu]VectLength, Index\[Mu]LastDraft[[1]]];

 \[Mu]VectLeft=Table[\[Mu]VectExpand1stSort[[i, 1]], {i, 1, Index\[Mu]First-1}];
 \[Mu]VectMiddle=Table[\[Mu]VectExpand1stSort[[i, 1]], {i, Index\[Mu]First, Index\[Mu]Last}];
 \[Mu]VectRight=Table[\[Mu]VectExpand1stSort[[i, 1]], {i, Index\[Mu]Last+1, \[Mu]VectLength}];
 \[Chi]VectLeft=\[Chi]FuncLife[[PeriodsUntilT+1]][\[Mu]First]+(\[Mu]VectLeft-\[Mu]First)\[Chi]FuncLife[[PeriodsUntilT+1]]'[\[Mu]First];
 \[Chi]VectMiddle=\[Chi]FuncLife[[PeriodsUntilT+1]][\[Mu]VectMiddle];
 \[Chi]VectRight=\[Chi]FuncLife[[PeriodsUntilT+1]][\[Mu]Last]+(\[Mu]VectRight-\[Mu]Last)\[Chi]FuncLife[[PeriodsUntilT+1]]'[\[Mu]Last];
 \[Chi]VectDraft=Join[\[Chi]VectLeft, \[Chi]VectMiddle, \[Chi]VectRight];
 \[Mu]VectExpand2nd=Transpose[Join[Transpose[\[Mu]VectExpand1stSort], {\[Chi]VectDraft}]];
 \[Mu]VectExpand2ndSort=Sort[\[Mu]VectExpand2nd, #1[[2]]<#2[[2]] &];
 \[Chi]Vect=Transpose[\[Mu]VectExpand2ndSort][[3]];
Return[\[Chi]Vect];
];


ListOptionConsFnInSim={{"cInterp"}
, {"cListable", "\[Chi]Listable"}
, {"cVecMoM", "\[Chi]Interp"}
, {"cVecMoM", "\[Chi]Listable"}
, {"cVecMoM", "\[Chi]VecSort"}};

ClearAll[FuncToDefine\[ScriptC]VecN\[Chi]Vec];
FuncToDefine\[ScriptC]VecN\[Chi]Vec[OptionConsFnInSim_]:=Black[{}
, 
ClearAll[\[Chi]Vec];
ClearAll[\[ScriptC]Vec];
(* This is to call the Interpolated function \[ScriptC]FuncLife[[]]. Very inaccurate but Fast! *)
If[OptionConsFnInSim=={"cInterp"}
, \[ScriptC]Vec[mVect_?VectorQ, PeriodsUntilT_]:=\[ScriptC]FuncLife[[PeriodsUntilT+1]][mVect]
];

(* This is to call the Listable function \[ScriptC] directly. Accurate but Slow! *)
(* In defining the Listable \[ScriptC] function, we also call the Listable \[Chi] function. *)
(* It is slow because we need to compute c and \[Chi] one-by-one. *)
If[OptionConsFnInSim=={"cListable", "\[Chi]Listable"}
, \[ScriptC]Vec[mVect_?VectorQ, PeriodsUntilT_]:=\[ScriptC][mVect, PeriodsUntilT]
];

(* This is to call \[ScriptC]VecMoM function. *)
(* In defining \[ScriptC]VecMoM, however, we need to first define \[Chi]Vec, which have three versions. *)

(* This is to call the Interpolated function \[Chi]FuncLife[[]]. Slightly less inaccurate but Fast! *)
If[OptionConsFnInSim=={"cVecMoM", "\[Chi]Interp"}
, \[Chi]Vec[\[Mu]Vect_?VectorQ,PeriodsUntilT_]:=\[Chi]FuncLife[[PeriodsUntilT+1]][\[Mu]Vect]
; \[ScriptC]Vec[mVect_?VectorQ, PeriodsUntilT_]:=\[ScriptC]VecMoM[mVect, PeriodsUntilT]
]

(* This is to call the Listable function \[Chi] directly. Accurate but Slow! *)
(* It is slow because for EVERY element in \[Mu]Vect, the \[Chi] function needs to determine
   which of the following three section it belongs
,  i.e. (-\[Infinity], \[Mu]First), [\[Mu]First, \[Mu]Last], (\[Mu]Last, +\[Infinity])
*)
If[OptionConsFnInSim=={"cVecMoM", "\[Chi]Listable"}
, \[Chi]Vec[\[Mu]Vect_?VectorQ,PeriodsUntilT_]:=\[Chi][\[Mu]Vect,PeriodsUntilT]
; \[ScriptC]Vec[mVect_?VectorQ, PeriodsUntilT_]:=\[ScriptC]VecMoM[mVect, PeriodsUntilT]
];

(* This is to call \[Chi]VecSort  the \[Chi]Interp function. Accurate but Slow! *)
(* The idea is to first sort \[Mu]Vect, second partition it into three sections
,  i.e. (-\[Infinity], \[Mu]First), [\[Mu]First, \[Mu]Last], (\[Mu]Last, +\[Infinity]) 
,  third apply different rules for the three sections,
,  and fourth sort the function values back in the original order.
   It is slow because Sort takes a lot of time. 
*) 
If[OptionConsFnInSim=={"cVecMoM", "\[Chi]VecSort"}
, \[Chi]Vec[\[Mu]Vect_?VectorQ,PeriodsUntilT_]:=\[Chi]VecSort[\[Mu]Vect,PeriodsUntilT]
; \[ScriptC]Vec[mVect_?VectorQ, PeriodsUntilT_]:=\[ScriptC]VecMoM[mVect, PeriodsUntilT]
];
]; (* End of Block *)
