(* ::Package:: *)

(* ::Subsection:: *)
(*Consumption function;*)


ClearAll[\[Chi]Hi];
\[Chi]Hi[\[Mu]_?NumericQ, PeriodsUntilT_] := \[Chi]FuncLifeHi[[PeriodsUntilT+1]][\[Mu]];
ClearAll[\[Chi]\[Mu]Hi];
\[Chi]\[Mu]Hi[\[Mu]_?NumericQ, PeriodsUntilT_] := \[Chi]FuncLifeHi[[PeriodsUntilT+1]]'[\[Mu]];

ClearAll[\[Chi]Lo];
\[Chi]Lo[\[Mu]_?NumericQ, PeriodsUntilT_] := \[Chi]FuncLifeLo[[PeriodsUntilT+1]][\[Mu]];
ClearAll[\[Chi]\[Mu]Lo];
\[Chi]\[Mu]Lo[\[Mu]_?NumericQ, PeriodsUntilT_] := \[Chi]FuncLifeLo[[PeriodsUntilT+1]]'[\[Mu]];


\[ScriptC]Hi[mt_,PeriodsUntilT_]:= Block[{
  mLowerBoundt, mCuspt , \[FilledUpTriangle]mt, \[FilledUpTriangle]\[GothicH]t, \[Kappa]t, \[Kappa]Maxt, \[Mu]t, \[Mu]First, \[Chi]t, \[Chi]Lowert, \[Koppa]t, \[Koppa]Lowert, ctOptmst, ctPesmst, ctRealst},
  mLowerBoundt = mLowerBoundLife[[PeriodsUntilT+1]]; 
  mCuspt =mCuspLife[[PeriodsUntilT+1]];
  \[FilledUpTriangle]mt   = mt-mLowerBoundt;
  \[FilledUpTriangle]\[GothicH]t   = \[FilledUpTriangle]\[GothicH]AccessibleLife[[PeriodsUntilT+1]];
  \[Kappa]t    = \[Kappa]MinLife[[PeriodsUntilT+1]];
  \[Kappa]Maxt    = \[Kappa]MaxLife[[PeriodsUntilT+1]]; (* June 2012 KT added *)
  \[Mu]t = Log[\[FilledUpTriangle]mt];If[Chop[mt - mLowerBoundt]==0,\[Mu]t=-Infinity];
(*See Derivations.nb for derivations of formulas below *)
  ctOptmst = \[Kappa]t (\[FilledUpTriangle]mt+\[FilledUpTriangle]\[GothicH]t);
  ctPesmst = \[Kappa]t (\[FilledUpTriangle]mt);  
  \[Chi]t  = \[Chi]Hi[\[Mu]t,PeriodsUntilT]
; \[Koppa]t  =1/(1+Exp[\[Chi]t])
; ctRealst=ctOptmst-(ctOptmst-ctPesmst) \[Koppa]t
;
  Return[ctRealst]
];(*End Block*)

\[ScriptC]Lo[mt_,PeriodsUntilT_]:= Block[{
  mLowerBoundt, mCuspt , \[FilledUpTriangle]mt, \[FilledUpTriangle]\[GothicH]t, \[Kappa]t, \[Kappa]Maxt, \[Mu]t, \[Mu]First, \[Chi]t, \[Chi]Lowert, \[Koppa]t, \[Koppa]Lowert, ctOptmst, ctPesmst, ctRealst},
  mLowerBoundt = mLowerBoundLife[[PeriodsUntilT+1]]; 
  mCuspt =mCuspLife[[PeriodsUntilT+1]];
  \[FilledUpTriangle]mt   = mt-mLowerBoundt;
  \[FilledUpTriangle]\[GothicH]t   = \[FilledUpTriangle]\[GothicH]AccessibleLife[[PeriodsUntilT+1]];
  \[Kappa]t    = \[Kappa]MinLife[[PeriodsUntilT+1]];
  \[Kappa]Maxt    = \[Kappa]MaxLife[[PeriodsUntilT+1]]; (* June 2012 KT added *)
  \[Mu]t = Log[\[FilledUpTriangle]mt];If[Chop[mt - mLowerBoundt]==0,\[Mu]t=-Infinity];
(*See Derivations.nb for derivations of formulas below *)
  ctOptmst = \[Kappa]t (\[FilledUpTriangle]mt+\[FilledUpTriangle]\[GothicH]t);
  ctPesmst = \[Kappa]t (\[FilledUpTriangle]mt);  
  \[Chi]t  = \[Chi]Lo[\[Mu]t,PeriodsUntilT];
 \[Koppa]t  =1/(1+Exp[\[Chi]t]);
 ctRealst=\[Kappa]Maxt \[FilledUpTriangle]mt-(\[Kappa]Maxt \[FilledUpTriangle]mt-ctPesmst) \[Koppa]t;
  Return[ctRealst];
];(*End Block*)

\[ScriptC]Md[mt_,PeriodsUntilT_]:= Block[{
  ctRealst},
  ctRealst = \[ScriptC]FuncLifeMd[[PeriodsUntilT+1]][mt];
  Return[ctRealst];
];(*End Block*)


ClearAll[\[ScriptC], \[ScriptC]BeforeT, \[ScriptC]From\[Chi]];
\[ScriptC][mt_,PeriodsUntilT_] := If[PeriodsUntilT == 0
  ,(*then*) Return[mt]
  ,(*else*) \[ScriptC]BeforeT[mt,PeriodsUntilT]];
\[ScriptC]BeforeT[mt_,PeriodsUntilT_] := \[ScriptC]From\[Chi][mt,PeriodsUntilT];

(* Block[{cUnconstr},
  If[Constrained==False, Return[\[ScriptC]From\[Chi][mt,PeriodsUntilT]]];
  cUnconstr = \[ScriptC]From\[Chi][mt,PeriodsUntilT];
  If[cUnconstr > mt, Return[mt]]; (* If you want to consume more than m, too bad! *)
  Return[cUnconstr];
];*)

(*
\[ScriptC]From\[Chi]= Compile[{{mt, _Real, 1}, {PeriodsUntilT, _Integer, 1}}
, \[ScriptC]From\[Chi]Raw[mt,PeriodsUntilT]
, CompilationTarget->"C"
];
*)
\[ScriptC]From\[Chi][mt_,PeriodsUntilT_]:= Block[{
  mLowerBoundt, mCuspt, \[FilledUpTriangle]mt, mHighestBelowmCuspt 
, mLowestAbovemCuspt, \[FilledUpTriangle]\[GothicH]t, \[Kappa]t, \[Kappa]Maxt, \[Mu]t, \[Mu]First, \[Chi]t, \[Koppa]t, ctOptmst, ctPesmst, ctRealst},
 
  mLowerBoundt = mLowerBoundLife[[PeriodsUntilT+1]]; 
  mCuspt =mCuspLife[[PeriodsUntilT+1]];
  mHighestBelowmCuspt = mHighestBelowmCuspLife[[PeriodsUntilT+1]];
  mLowestAbovemCuspt = mLowestAbovemCuspLife[[PeriodsUntilT+1]]; 

  \[FilledUpTriangle]mt   = mt-mLowerBoundt;
  \[FilledUpTriangle]\[GothicH]t   = \[FilledUpTriangle]\[GothicH]AccessibleLife[[PeriodsUntilT+1]];
  \[Kappa]t    = \[Kappa]MinLife[[PeriodsUntilT+1]];
  \[Kappa]Maxt    = \[Kappa]MaxLife[[PeriodsUntilT+1]]; (* June 2012 KT added *)
  \[Mu]t = Log[\[FilledUpTriangle]mt];If[Chop[mt - mLowerBoundt]==0,\[Mu]t=-Infinity];
(*See Derivations.nb for derivations of formulas below *)
  ctOptmst = \[Kappa]t (\[FilledUpTriangle]mt+\[FilledUpTriangle]\[GothicH]t);
  ctPesmst = \[Kappa]t (\[FilledUpTriangle]mt);  

  If[mt >= mLowestAbovemCuspt
(* if mt >= mLoestAbovemCuspt (lowest point above mCusp), use Hi func *)
, \[Chi]t  = \[Chi]Hi[\[Mu]t,PeriodsUntilT]
; \[Koppa]t  =1/(1+Exp[\[Chi]t])
; ctRealst=ctOptmst-(ctOptmst-ctPesmst) \[Koppa]t
];

(* if mHiestBelowmCuspt <= mt <mLowestAbovemCuspt , use Mid function *)
  If[And[mt < mLowestAbovemCuspt, mt >= mHighestBelowmCuspt]
(* then use Mid func *)
, ctRealst = \[ScriptC]FuncLifeMd[[PeriodsUntilT+1]][mt]
];

(* if mt <= mHighestBelowmCuspt, use Lo func *)
 If[mt < mHighestBelowmCuspt
, \[Chi]t  = \[Chi]Lo[\[Mu]t,PeriodsUntilT]
; \[Koppa]t  =1/(1+Exp[\[Chi]t])
; ctRealst=\[Kappa]Maxt*\[FilledUpTriangle]mt-(\[Kappa]Maxt*\[FilledUpTriangle]mt-ctPesmst) \[Koppa]t 
]; (* End If *)

  Return[ctRealst]
];(*End Block*)

\[ScriptC][mt_] := \[ScriptC][mt,Length[\[Beta]Life]-1]; (* Without lifeperiod argument, use most recently solved *)


(*
  \[ScriptC]From\[Chi][mt_,PeriodsUntilT_]:= Plus[
  UnitStep[mt-mLowestAbovemCuspLife[[PeriodsUntilT+1]]]*\[ScriptC]Hi[mt, PeriodsUntilT]
, UnitStep[mHighestBelowmCuspLife[[PeriodsUntilT+1]]-mt]*\[ScriptC]Lo[mt, PeriodsUntilT]
, (1-UnitStep[mt-mLowestAbovemCuspLife[[PeriodsUntilT+1]]])*(1-UnitStep[mHighestBelowmCuspLife[[PeriodsUntilT+1]]-mt])*\[ScriptC]Md[mt, PeriodsUntilT]
];*)


\[Kappa]Hi[mt_,PeriodsUntilT_]:=Block[{mLowerBoundt, mCuspt, \[FilledUpTriangle]mt, \[FilledUpTriangle]\[GothicH]t, \[Kappa]t, \[Kappa]Maxt, \[Mu]t, \[Mu]First
, \[Chi]t, \[Chi]\[Mu]t, \[Koppa]t, \[Koppa]\[Mu]t, ctOptmst, ctPesmst, ctRealst, \[Kappa]tOptmst, \[Kappa]tPesmst, \[Kappa]tRealst},
  mLowerBoundt = mLowerBoundLife[[PeriodsUntilT+1]]; 
  mCuspt =mCuspLife[[PeriodsUntilT+1]];
  \[FilledUpTriangle]mt   = mt-mLowerBoundt;
  \[FilledUpTriangle]\[GothicH]t   = \[FilledUpTriangle]\[GothicH]AccessibleLife[[PeriodsUntilT+1]];
  \[Kappa]t    = \[Kappa]MinLife[[PeriodsUntilT+1]];
  \[Kappa]Maxt    = \[Kappa]MaxLife[[PeriodsUntilT+1]]; (* June 2012 KT added *)
  \[Mu]t = Log[\[FilledUpTriangle]mt];If[Chop[mt - mLowerBoundt]==0,\[Mu]t=-Infinity];
  ctOptmst = \[Kappa]t (\[FilledUpTriangle]mt+\[FilledUpTriangle]\[GothicH]t);
  ctPesmst = \[Kappa]t (\[FilledUpTriangle]mt); 
  \[Kappa]tOptmst = \[Kappa]t;
  \[Kappa]tPesmst = \[Kappa]t;
(*See Derivations.nb for derivations of formulas below *)
 
  \[Chi]t  = \[Chi]Hi[\[Mu]t,PeriodsUntilT];
  \[Chi]\[Mu]t = \[Chi]\[Mu]Hi[\[Mu]t,PeriodsUntilT];
  \[Koppa]t  =1/(1+Exp[\[Chi]t]); 
  \[Koppa]\[Mu]t = \[Chi]\[Mu]t (\[Koppa]t-1) \[Koppa]t; 
  ctRealst=ctOptmst-(ctOptmst-ctPesmst) \[Koppa]t; 
  \[Kappa]tRealst = \[Kappa]tOptmst-\[Koppa]\[Mu]t (ctOptmst-ctPesmst)/\[FilledUpTriangle]mt;
  Return[\[Kappa]tRealst]
];

\[Kappa]Lo[mt_,PeriodsUntilT_]:=Block[{mLowerBoundt, mCuspt, \[FilledUpTriangle]mt, \[FilledUpTriangle]\[GothicH]t, \[Kappa]t, \[Kappa]Maxt, \[Mu]t, \[Mu]First, \[Chi]t, \[Chi]\[Mu]t
, \[Koppa]t, \[Koppa]\[Mu]t, ctOptmst, ctPesmst, ctRealst, \[Kappa]tOptmst, \[Kappa]tPesmst, \[Kappa]tRealst},
  mLowerBoundt = mLowerBoundLife[[PeriodsUntilT+1]]; 
  mCuspt =mCuspLife[[PeriodsUntilT+1]];
  \[FilledUpTriangle]mt   = mt-mLowerBoundt;
  \[FilledUpTriangle]\[GothicH]t   = \[FilledUpTriangle]\[GothicH]AccessibleLife[[PeriodsUntilT+1]];
  \[Kappa]t    = \[Kappa]MinLife[[PeriodsUntilT+1]];
  \[Kappa]Maxt    = \[Kappa]MaxLife[[PeriodsUntilT+1]]; 
  \[Mu]t = Log[\[FilledUpTriangle]mt];If[Chop[mt - mLowerBoundt]==0,\[Mu]t=-Infinity];
  ctOptmst = \[Kappa]t (\[FilledUpTriangle]mt+\[FilledUpTriangle]\[GothicH]t);
  ctPesmst = \[Kappa]t (\[FilledUpTriangle]mt); 
  \[Kappa]tOptmst = \[Kappa]t;
  \[Kappa]tPesmst = \[Kappa]t;
(*See Derivations.nb for derivations of formulas below *)
 
  \[Chi]t  = \[Chi]Lo[\[Mu]t,PeriodsUntilT];
  \[Chi]\[Mu]t = \[Chi]\[Mu]Lo[\[Mu]t,PeriodsUntilT];
  \[Koppa]t  =1/(1+Exp[\[Chi]t]);
  \[Koppa]\[Mu]t = \[Chi]\[Mu]t (\[Koppa]t-1) \[Koppa]t; 
  ctRealst=\[Kappa]Maxt \[FilledUpTriangle]mt- (\[Kappa]Maxt \[FilledUpTriangle]mt-ctPesmst) \[Koppa]t; 
  \[Kappa]tRealst = ctRealst/\[FilledUpTriangle]mt-\[Koppa]\[Mu]t*(\[Kappa]Maxt-\[Kappa]tPesmst)
  Return[\[Kappa]tRealst]
];

\[Kappa]Md[mt_,PeriodsUntilT_]:= Block[{
  \[Kappa]tRealst},
  \[Kappa]tRealst = \[ScriptC]FuncLifeMd[[PeriodsUntilT+1]]'[mt];
  Return[\[Kappa]tRealst];
];(*End Block*)


ClearAll[\[Kappa], \[Kappa]BeforeT, \[Kappa]From\[Chi]];
\[Kappa][mt_,PeriodsUntilT_] := If[PeriodsUntilT == 0,Return[1.]
, (*else*)\[Kappa]BeforeT[mt,PeriodsUntilT]];
\[Kappa]BeforeT[mt_,PeriodsUntilT_] := \[Kappa]From\[Chi][mt,PeriodsUntilT];

(*Block[{cUnconstr,\[Kappa]Unconstr},
  If[Constrained==False, Return[\[Kappa]From\[Chi][mt,PeriodsUntilT]]];
  cUnconstr = \[ScriptC]From\[Chi][mt,PeriodsUntilT];
  If[cUnconstr > mt,Return[1.]]; (* MPC is 1 if consumer is liquidity constrained *)
  Return[\[Kappa]From\[Chi][mt,PeriodsUntilT]]
];
*)
\[Kappa]From\[Chi][mt_,PeriodsUntilT_]:=Block[{mLowerBoundt,  mCuspt, \[FilledUpTriangle]mt, mHighestBelowmCuspt 
, mLowestAbovemCuspt, \[FilledUpTriangle]\[GothicH]t, \[Kappa]t, \[Kappa]Maxt, \[Mu]t, \[Mu]First, \[Chi]t, \[Chi]\[Mu]t
, \[Koppa]t, \[Koppa]\[Mu]t, ctOptmst, ctPesmst, ctRealst, \[Kappa]tOptmst, \[Kappa]tPesmst, \[Kappa]tRealst},
  mLowerBoundt = mLowerBoundLife[[PeriodsUntilT+1]]; 
  mCuspt =mCuspLife[[PeriodsUntilT+1]];
  \[FilledUpTriangle]mt   = mt-mLowerBoundt;
  mHighestBelowmCuspt = mHighestBelowmCuspLife[[PeriodsUntilT+1]];
  mLowestAbovemCuspt = mLowestAbovemCuspLife[[PeriodsUntilT+1]]; 
  \[FilledUpTriangle]\[GothicH]t   = \[FilledUpTriangle]\[GothicH]AccessibleLife[[PeriodsUntilT+1]];
  \[Kappa]t    = \[Kappa]MinLife[[PeriodsUntilT+1]];
  \[Kappa]Maxt    = \[Kappa]MaxLife[[PeriodsUntilT+1]];
  \[Mu]t = Log[\[FilledUpTriangle]mt];If[Chop[mt - mLowerBoundt]==0,\[Mu]t=-Infinity];
  ctOptmst = \[Kappa]t (\[FilledUpTriangle]mt+\[FilledUpTriangle]\[GothicH]t);
  ctPesmst = \[Kappa]t (\[FilledUpTriangle]mt);  
  \[Kappa]tOptmst = \[Kappa]t;
  \[Kappa]tPesmst = \[Kappa]t;
(*See Derivations.nb for derivations of formulas below *)
  If[mt>= mLowestAbovemCuspt
(* if mt >= mLoestAbovemCuspt (lowest point above mCusp), use Hi func *)
, \[Chi]t  = \[Chi]Hi[\[Mu]t,PeriodsUntilT]
; \[Chi]\[Mu]t = \[Chi]\[Mu]Hi[\[Mu]t,PeriodsUntilT]
; \[Koppa]t  =1/(1+Exp[\[Chi]t])
; \[Koppa]\[Mu]t = \[Chi]\[Mu]t (\[Koppa]t-1) \[Koppa]t
; ctRealst=ctOptmst-(ctOptmst-ctPesmst) \[Koppa]t
; \[Kappa]tRealst = \[Kappa]tOptmst-\[Koppa]\[Mu]t (ctOptmst-ctPesmst)/\[FilledUpTriangle]mt
;
];

(* if mHiestBelowmCuspt <= mt <mLowestAbovemCuspt , use Mid function *)
If[And[mt < mLowestAbovemCuspt, mt >= mHighestBelowmCuspt]
(* then use Mid func *)
, \[Kappa]tRealst = \[ScriptC]FuncLifeMd[[PeriodsUntilT+1]]'[mt]
];

(* if mt <= mHighestBelowmCuspt, use Lo func *)
 If[mt < mHighestBelowmCuspt
, \[Chi]t  = \[Chi]Lo[\[Mu]t,PeriodsUntilT]
; \[Chi]\[Mu]t = \[Chi]\[Mu]Lo[\[Mu]t,PeriodsUntilT]
; \[Koppa]t  =1/(1+Exp[\[Chi]t])
; \[Koppa]\[Mu]t = \[Chi]\[Mu]t (\[Koppa]t-1) \[Koppa]t
; ctRealst=\[Kappa]Maxt \[FilledUpTriangle]mt-(\[Kappa]Maxt \[FilledUpTriangle]mt-ctPesmst) \[Koppa]t
; \[Kappa]tRealst = ctRealst/\[FilledUpTriangle]mt-\[Koppa]\[Mu]t (\[Kappa]Maxt-\[Kappa]tPesmst)
;
];

  Return[\[Kappa]tRealst]
];

\[Kappa][mt_] := \[Kappa][mt,Length[\[Beta]Life]-1]; (* Without lifeperiod argument, use most recently solved *)


(* ::Subsection:: *)
(*Value function;*)


ClearAll[FuncToDefine\[CapitalLambda]Func];

FuncToDefine\[CapitalLambda]Func[\[Rho]_?NumericQ] := Block[{}, 

ClearAll[\[CapitalChi]Hi];
\[CapitalChi]Hi[\[Mu]_,PeriodsUntilT_] := \[CapitalChi]FuncLifeHi[[PeriodsUntilT+1]][\[Mu]];

ClearAll[\[CapitalChi]\[Mu]Hi];
\[CapitalChi]\[Mu]Hi[\[Mu]_,PeriodsUntilT_] := \[CapitalChi]FuncLifeHi[[PeriodsUntilT+1]]'[\[Mu]];

ClearAll[\[CapitalChi]Lo];
\[CapitalChi]Lo[\[Mu]_,PeriodsUntilT_] := \[CapitalChi]FuncLifeLo[[PeriodsUntilT+1]][\[Mu]];

ClearAll[\[CapitalChi]\[Mu]Lo];
\[CapitalChi]\[Mu]Lo[\[Mu]_,PeriodsUntilT_] := \[CapitalChi]FuncLifeLo[[PeriodsUntilT+1]]'[\[Mu]];


\[CapitalLambda]Hi[mt_,PeriodsUntilT_]:= Block[{
  mLowerBoundt, \[FilledUpTriangle]mt, \[FilledUpTriangle]\[GothicH]t, \[Kappa]t, \[Kappa]Maxt, \[Mu]t, \[CapitalChi]t, \[CapitalKoppa]t
, ctOptmst, ctPesmst, \[CapitalLambda]tTighterUpBd, \[CapitalLambda]tOptmst, \[CapitalLambda]tPesmst, \[CapitalLambda]tRealst, \[Mu]First, vSumt
, mCuspt, \[GothicV]OptmstCon0at, \[ScriptV]tOptmstCon, \[CapitalLambda]tOptmstCon},
  mLowerBoundt = mLowerBoundLife[[PeriodsUntilT+1]]; 
  mCuspt =mCuspLife[[PeriodsUntilT+1]];
(*
  \[GothicV]OptmstCon0at=\[GothicV]OptmstCon0aLife[[PeriodsUntilT+1]];
*)
vSumt=vSumLife[[PeriodsUntilT+1]];
  \[FilledUpTriangle]mt   = mt-mLowerBoundt;
  \[FilledUpTriangle]\[GothicH]t   = \[FilledUpTriangle]\[GothicH]AccessibleLife[[PeriodsUntilT+1]];
  \[Kappa]t    = \[Kappa]MinLife[[PeriodsUntilT+1]];
  \[Kappa]Maxt    = \[Kappa]MaxLife[[PeriodsUntilT+1]]; (* June 2012 KT added *)
  \[Mu]t = Log[\[FilledUpTriangle]mt];If[Chop[mt - mLowerBoundt]==0,\[Mu]t=-Infinity];
  ctOptmst = \[Kappa]t (\[FilledUpTriangle]mt+\[FilledUpTriangle]\[GothicH]t);
  ctPesmst = \[Kappa]t (\[FilledUpTriangle]mt); 
  \[CapitalLambda]tOptmst = ctOptmst (vSumt)^(1/(1-\[Rho]));
  \[CapitalLambda]tPesmst = ctPesmst (vSumt)^(1/(1-\[Rho]));
 (*
 \[ScriptV]tOptmstCon = u[\[Kappa]Maxt \[FilledUpTriangle]mt]+\[GothicV]OptmstCon0at; (* June 2012 KT fixed *)
  \[CapitalLambda]tOptmstCon =((1-\[Rho])\[ScriptV]tOptmstCon)^(1/(1-\[Rho]));
*)
(*  If[mt>=mCuspt
, *)\[CapitalChi]t  = \[CapitalChi]Hi[\[Mu]t, PeriodsUntilT]
; \[CapitalKoppa]t=1/(1+Exp[\[CapitalChi]t])
; \[CapitalLambda]tRealst=\[CapitalLambda]tOptmst- \[CapitalKoppa]t(\[CapitalLambda]tOptmst-\[CapitalLambda]tPesmst)
;
(*, \[CapitalChi]t  = \[CapitalChi]Lo[\[Mu]t, PeriodsUntilT]
; \[CapitalKoppa]t=1/(1+Exp[\[CapitalChi]t])
; \[CapitalLambda]tRealst=\[CapitalLambda]tOptmstCon- \[CapitalKoppa]t(\[CapitalLambda]tOptmstCon-\[CapitalLambda]tPesmst)
;
];*)
  Return[\[CapitalLambda]tRealst] 
];(*End Block*)


\[CapitalLambda]Lo[mt_,PeriodsUntilT_]:= Block[{
  mLowerBoundt, mHighestBelowmCuspt, mLowestAbovemCuspt, \[FilledUpTriangle]mt, \[FilledUpTriangle]\[GothicH]t, \[Kappa]t, \[Kappa]Maxt, \[Mu]t, \[CapitalChi]t, \[CapitalKoppa]t
, ctOptmst, ctPesmst, \[CapitalLambda]tTighterUpBd, \[CapitalLambda]tOptmst, \[CapitalLambda]tPesmst, \[CapitalLambda]tRealst, \[Mu]First, vSumt
, mCuspt, \[GothicV]OptmstCon0at, \[ScriptV]tOptmstCon, \[CapitalLambda]tOptmstCon},
  mLowerBoundt = mLowerBoundLife[[PeriodsUntilT+1]]; 
  mCuspt =mCuspLife[[PeriodsUntilT+1]];
  mHighestBelowmCuspt = mHighestBelowmCuspLife[[PeriodsUntilT+1]];
  mLowestAbovemCuspt = mLowestAbovemCuspLife[[PeriodsUntilT+1]]; 
(*
  \[GothicV]OptmstCon0at=\[GothicV]OptmstCon0aLife[[PeriodsUntilT+1]];
*)  vSumt =vSumLife[[PeriodsUntilT+1]];
  \[FilledUpTriangle]mt   = mt-mLowerBoundt;
  \[FilledUpTriangle]\[GothicH]t   = \[FilledUpTriangle]\[GothicH]AccessibleLife[[PeriodsUntilT+1]];
  \[Kappa]t    = \[Kappa]MinLife[[PeriodsUntilT+1]];
  \[Kappa]Maxt    = \[Kappa]MaxLife[[PeriodsUntilT+1]]; (* June 2012 KT added *)
  \[Mu]t = Log[\[FilledUpTriangle]mt];If[Chop[mt - mLowerBoundt]==0,\[Mu]t=-Infinity];
  ctOptmst = \[Kappa]t (\[FilledUpTriangle]mt+\[FilledUpTriangle]\[GothicH]t);
  ctPesmst = \[Kappa]t (\[FilledUpTriangle]mt); 
  \[CapitalLambda]tOptmst = \[CapitalLambda]\[Digamma]TighterUpBd[mt, PeriodsUntilT];
  \[CapitalLambda]tPesmst = ctPesmst (vSumt)^(1/(1-\[Rho]));
  (*
	\[ScriptV]tOptmstCon = u[\[Kappa]Maxt \[FilledUpTriangle]mt]+\[GothicV]OptmstCon0at; (* June 2012 KT fixed *)
  \[CapitalLambda]tOptmstCon =((1-\[Rho])\[ScriptV]tOptmstCon)^(1/(1-\[Rho]));
*)

(*  If[mt>=mCuspt
, \[CapitalChi]t  = \[CapitalChi]Hi[\[Mu]t, PeriodsUntilT]
; \[CapitalKoppa]t=1/(1+Exp[\[CapitalChi]t])
; \[CapitalLambda]tRealst=\[CapitalLambda]tOptmst- \[CapitalKoppa]t(\[CapitalLambda]tOptmst-\[CapitalLambda]tPesmst)
;
, *)\[CapitalChi]t  = \[CapitalChi]Lo[\[Mu]t, PeriodsUntilT]
; \[CapitalKoppa]t=1/(1+Exp[\[CapitalChi]t])
; \[CapitalLambda]tRealst=\[CapitalLambda]tOptmst- \[CapitalKoppa]t(\[CapitalLambda]tOptmst-\[CapitalLambda]tPesmst)
;
(*];*)
  Return[\[CapitalLambda]tRealst] 
];(*End Block*)

(*
\[CapitalLambda]\[Digamma]Md[mt_,PeriodsUntilT_]:= Block[{\[CapitalLambda]Val, vVal},
  If[PeriodsUntilT == 0
, (*then*)\[CapitalLambda]Val=mt
, (*else*)\[CapitalLambda]Val=\[CapitalLambda]FuncLifeMd[[PeriodsUntilT+1]][mt]
];
 Return[\[CapitalLambda]Val];
]; (* End Block[]*)

\[ScriptV]\[Digamma]Md[mt_,PeriodsUntilT_]:= Block[{\[CapitalLambda]Val, vVal},
  \[CapitalLambda]Val=\[CapitalLambda]\[Digamma]Md[mt, PeriodsUntilT];
  vVal=u[\[CapitalLambda]Val];
Return[vVal];
]; (* End Block[]*)
*)

\[CapitalLambda]Md[mt_,PeriodsUntilT_]:= Block[{
  \[CapitalLambda]tRealst},
	If[PeriodsUntilT == 0
, (*then*)\[CapitalLambda]tRealst=mt
, (*else*) \[CapitalLambda]tRealst = \[CapitalLambda]FuncLifeMd[[PeriodsUntilT+1]][mt];
];
  Return[\[CapitalLambda]tRealst];
];(*End Block*)

\[ScriptV]Hi[mt_,PeriodsUntilT_]:=u[\[CapitalLambda]Hi[mt,PeriodsUntilT]];
\[ScriptV]Lo[mt_,PeriodsUntilT_]:=u[\[CapitalLambda]Lo[mt,PeriodsUntilT]];
\[ScriptV]Md[mt_,PeriodsUntilT_]:=u[\[CapitalLambda]Md[mt,PeriodsUntilT]];


ClearAll[\[CapitalLambda], \[CapitalLambda]BeforeT, \[CapitalLambda]From\[CapitalChi]];
\[CapitalLambda][mt_,PeriodsUntilT_] := If[PeriodsUntilT==0,mt,(*else*)\[CapitalLambda]BeforeT[mt,PeriodsUntilT]];
\[CapitalLambda]BeforeT[mt_,PeriodsUntilT_]:= \[CapitalLambda]From\[CapitalChi][mt,PeriodsUntilT];

(*Block[{\[CapitalLambda]Unconstr,cUnconstr
, cWhereConstrBinds, vWhereConstrBinds, vConstr},
 If[Constrained==False, Return[\[CapitalLambda]From\[CapitalChi][mt,PeriodsUntilT]]];
  cUnconstr = \[ScriptC]From\[Chi][mt,PeriodsUntilT];
 If[cUnconstr > mt,
    cWhereConstrBinds = \[GothicC]FuncLife[[PeriodsUntilT+1]][0.];
    vWhereConstrBinds=u[\[CapitalLambda]From\[CapitalChi][cWhereConstrBinds,PeriodsUntilT]];
    vConstr = vWhereConstrBinds+u[mt]-u[cWhereConstrBinds]; (* Because MPC is 1 below point where constraint binds *)
    Return[((1-\[Rho])vConstr)^(1/(1-\[Rho]))]];
 Return[\[CapitalLambda]From\[CapitalChi][mt,PeriodsUntilT]];
];

*)
\[CapitalLambda]From\[CapitalChi][mt_,PeriodsUntilT_]:= Block[{
  mLowerBoundt, mCuspt, \[FilledUpTriangle]mt, mHighestBelowmCuspt 
, mLowestAbovemCuspt, \[FilledUpTriangle]\[GothicH]t, \[Kappa]t, \[Kappa]Maxt, \[Mu]t, \[CapitalChi]t, \[CapitalKoppa]t
, ctOptmst, ctPesmst, \[CapitalLambda]tTighterUpBd, \[CapitalLambda]tOptmst, \[CapitalLambda]tPesmst, \[CapitalLambda]tRealst, \[Mu]First, vSumt
, \[GothicV]OptmstCon0at, \[ScriptV]tOptmstTighterUpBd, \[CapitalLambda]tOptmstTighterUpBd, \[ScriptV]tOptmst},
  mLowerBoundt = \[GothicA]LowerBoundLife[[PeriodsUntilT+1]]; 
  mCuspt =mCuspLife[[PeriodsUntilT+1]];
  mHighestBelowmCuspt = mHighestBelowmCuspLife[[PeriodsUntilT+1]];
  mLowestAbovemCuspt = mLowestAbovemCuspLife[[PeriodsUntilT+1]]; 
  vSumt=vSumLife[[PeriodsUntilT+1]];
  \[FilledUpTriangle]mt   = mt-mLowerBoundt;
  \[FilledUpTriangle]\[GothicH]t   = \[FilledUpTriangle]\[GothicH]AccessibleLife[[PeriodsUntilT+1]];
  \[Kappa]t    = \[Kappa]MinLife[[PeriodsUntilT+1]];
  \[Kappa]Maxt    = \[Kappa]MaxLife[[PeriodsUntilT+1]]; (* June 2012 KT added *)
  \[Mu]t = Log[\[FilledUpTriangle]mt];If[Chop[mt - mLowerBoundt]==0,\[Mu]t=-Infinity];
  ctPesmst = \[Kappa]t (\[FilledUpTriangle]mt); 
  \[CapitalLambda]tPesmst = ctPesmst (vSumt)^(1/(1-\[Rho]));


  If[mt >= mLowestAbovemCuspt
(* if mt >= mLoestAbovemCuspt (lowest point above mCusp), use Hi func *)
, \[CapitalChi]t  = \[CapitalChi]Hi[\[Mu]t, PeriodsUntilT]
; \[CapitalKoppa]t=1/(1+Exp[\[CapitalChi]t])
; ctOptmst = \[Kappa]t (\[FilledUpTriangle]mt+\[FilledUpTriangle]\[GothicH]t)
; \[CapitalLambda]tOptmst = ctOptmst (vSumt)^(1/(1-\[Rho]))
; \[CapitalLambda]tRealst=\[CapitalLambda]tOptmst- \[CapitalKoppa]t(\[CapitalLambda]tOptmst-\[CapitalLambda]tPesmst)
;
];


(* if mHiestBelowmCuspt <= mt <mLowestAbovemCuspt , use Mid function *)
  If[And[mt < mLowestAbovemCuspt, mt >= mHighestBelowmCuspt]
(* then use Mid func *)
, \[CapitalLambda]tRealst = \[CapitalLambda]FuncLifeMd[[PeriodsUntilT+1]][mt]
];

(* if mt <= mHighestBelowmCuspt, use Lo func *)
 If[mt < mHighestBelowmCuspt
, \[CapitalChi]t  = \[CapitalChi]Lo[\[Mu]t, PeriodsUntilT]
; \[CapitalKoppa]t=1/(1+Exp[\[CapitalChi]t])
; \[ScriptV]tOptmst =  \[ScriptV]\[Digamma]TighterUpBd[mt,PeriodsUntilT]

; \[CapitalLambda]tOptmst =((1-\[Rho])\[ScriptV]tOptmst)^(1/(1-\[Rho])) 
; \[CapitalLambda]tRealst=\[CapitalLambda]tOptmst- \[CapitalKoppa]t(\[CapitalLambda]tOptmst-\[CapitalLambda]tPesmst)
;
]; 

  Return[\[CapitalLambda]tRealst];
];(*End Block*)


ClearAll[\[ScriptV]];
\[ScriptV][mt_,PeriodsUntilT_] := u[\[CapitalLambda][mt,PeriodsUntilT]];
\[ScriptV]Hi[mt_,PeriodsUntilT_]:=u[\[CapitalLambda]Hi[mt,PeriodsUntilT]];
\[ScriptV]Lo[mt_,PeriodsUntilT_]:=u[\[CapitalLambda]Lo[mt,PeriodsUntilT]];
\[ScriptV]Md[mt_,PeriodsUntilT_]:=u[\[CapitalLambda]Md[mt,PeriodsUntilT]];
(*
\[ScriptV][mt_,PeriodsUntilT_] := If[PeriodsUntilT==0,u[mt],(*else*)\[ScriptV]BeforeT[mt,PeriodsUntilT]];
\[ScriptV]BeforeT[mt_,PeriodsUntilT_] := \[ScriptV]From\[CapitalChi][mt,PeriodsUntilT];
\[ScriptV]From\[CapitalChi][mt_,PeriodsUntilT_] := u[\[CapitalLambda][mt,PeriodsUntilT]];
*)
\[ScriptV][mt_] := \[ScriptV][mt,Length[\[Beta]Life]-1]; (* Without lifeperiod argument, use most recently solved *)
ClearAll[\[ScriptV]m, \[ScriptV]mBeforeT];
\[ScriptV]m[mt_,PeriodsUntilT_] := If[PeriodsUntilT==0,uP[mt],(*else*)\[ScriptV]mBeforeT[mt,PeriodsUntilT]];
\[ScriptV]mBeforeT[mt_,PeriodsUntilT_] := uP[\[ScriptC][mt, PeriodsUntilT]];

SetAttributes[{
  \[Chi]Hi, \[Chi]Lo
, \[Chi]\[Mu]Hi, \[Chi]\[Mu]Lo
, \[ScriptC]Hi, \[ScriptC]Lo, \[ScriptC]Md
, \[ScriptC], \[ScriptC]BeforeT, \[ScriptC]From\[Chi]
, \[Kappa]Hi, \[Kappa]Lo, \[Kappa]Md
, \[Kappa], \[Kappa]BeforeT, \[Kappa]From\[Chi]

, \[CapitalChi]Hi, \[CapitalChi]Lo
, \[CapitalChi]\[Mu]Hi, \[CapitalChi]\[Mu]Lo
, \[CapitalLambda]Hi, \[CapitalLambda]Lo, \[CapitalLambda]Md
, \[CapitalLambda], \[CapitalLambda]BeforeT, \[CapitalLambda]From\[CapitalChi]
, \[ScriptV], \[ScriptV]BeforeT, \[ScriptV]From\[CapitalChi]

, \[ScriptV]m, \[ScriptV]mBeforeT}, Listable]; (* Allows funcs to operate on lists *)

];


(* ::Subsection:: *)
(*Vector-based function (to be used in Setup_ConsFn.m)*)


(* \[Chi]N\[Chi]\[Mu]Vec is a special function that calculate a vector of optimal \[Chi] and \[Chi]\[Mu]
 corresponding to a vector of \[Mu]. This is much faster than calculating
both one by one. It will be used in generating the sequence of optimal consumption function.*)

ClearAll[\[Chi]N\[Chi]\[Mu]VecHi];
\[Chi]N\[Chi]\[Mu]VecHi[\[Mu]Vect_?VectorQ,PeriodsUntilT_] := Block[{\[Chi]N\[Chi]\[Mu]Vect},
  \[Chi]N\[Chi]\[Mu]Vect=Table[{Null, Null}, {i, 1, Length[\[Mu]Vect]}];
  For[i=1, i<=Length[\[Mu]Vect], i++,
  \[Mu]t=\[Mu]Vect[[i]];
  {\[Chi]t, \[Chi]\[Mu]t}={\[Chi]FuncLifeHi[[PeriodsUntilT+1]][\[Mu]t]
, \[Chi]FuncLifeHi[[PeriodsUntilT+1]]'[\[Mu]t]};
  \[Chi]N\[Chi]\[Mu]Vect[[i]]={\[Chi]t, \[Chi]\[Mu]t};
  ];
Return[\[Chi]N\[Chi]\[Mu]Vect];
];(*End Block*)

ClearAll[\[Chi]N\[Chi]\[Mu]VecLo];
\[Chi]N\[Chi]\[Mu]VecLo[\[Mu]Vect_?VectorQ,PeriodsUntilT_] := Block[{\[Chi]N\[Chi]\[Mu]Vect},
  \[Chi]N\[Chi]\[Mu]Vect=Table[{Null, Null}, {i, 1, Length[\[Mu]Vect]}];
  For[i=1, i<=Length[\[Mu]Vect], i++,
  \[Mu]t=\[Mu]Vect[[i]];
  {\[Chi]t, \[Chi]\[Mu]t}={\[Chi]FuncLifeLo[[PeriodsUntilT+1]][\[Mu]t]
, \[Chi]FuncLifeLo[[PeriodsUntilT+1]]'[\[Mu]t]};
  \[Chi]N\[Chi]\[Mu]Vect[[i]]={\[Chi]t, \[Chi]\[Mu]t};
  ];
Return[\[Chi]N\[Chi]\[Mu]Vect];
];(*End Block*)


(* \[ScriptC]N\[Kappa]Vec is a special function that calculate a vector of optimal \[ScriptC] and \[Kappa]
 corresponding to a vector of m. This is much faster than calculating
both one by one. It will be used in generating the sequence of optimal consumption function. *)

ClearAll[\[ScriptC]N\[Kappa]Vec];
\[ScriptC]N\[Kappa]Vec[mVect_?VectorQ, PeriodsUntilT_]:=Block[{
  mLowerBoundt, \[FilledUpTriangle]mVect, \[FilledUpTriangle]\[GothicH]t, \[Kappa]t, \[Kappa]Maxt, \[Mu]Vect, \[Chi]Vect, \[Chi]\[Mu]Vect
, \[Koppa]Vect, \[Koppa]\[Mu]Vect
, cVectOptmst, cVectPesmst, cVectRealst
, \[Kappa]VectOptmst, \[Kappa]VectPesmst, \[Kappa]VectRealst
, aVectRealst, aVectRealstNonpos, IndexNonpos
, mHighestBelowmCuspt, mLowestAbovemCuspt},
If[PeriodsUntilT == 0, Return[Transpose[{mVect, mVect/mVect}]]
, mLowerBoundt = mLowerBoundLife[[PeriodsUntilT+1]]; 
  mCuspt =mCuspLife[[PeriodsUntilT+1]];
	mHighestBelowmCuspt = mHighestBelowmCuspLife[[PeriodsUntilT+1]];
  mLowestAbovemCuspt = mLowestAbovemCuspLife[[PeriodsUntilT+1]]; 

  \[FilledUpTriangle]\[GothicH]t   = \[FilledUpTriangle]\[GothicH]AccessibleLife[[PeriodsUntilT+1]];
  \[Kappa]t    = \[Kappa]MinLife[[PeriodsUntilT+1]];
  \[Kappa]Maxt    = \[Kappa]MaxLife[[PeriodsUntilT+1]];

  cVectRealst=Table[Null, {i, 1, Length[mVect]}];
  \[Kappa]VectRealst=Table[Null, {i, 1, Length[mVect]}];
  For[i=1, i<=Length[mVect], i++,
  mt=mVect[[i]];
  \[FilledUpTriangle]mt   = mt-mLowerBoundt;
  \[Mu]t = Log[\[FilledUpTriangle]mt];
  ctOptmst = \[Kappa]t (\[FilledUpTriangle]mt+\[FilledUpTriangle]\[GothicH]t);
  ctPesmst = \[Kappa]t (\[FilledUpTriangle]mt); 
  \[Kappa]tOptmst=\[Kappa]t;
  \[Kappa]tPesmst=\[Kappa]t;

 If[mt>= mLowestAbovemCuspt
(* if mt >= mLoestAbovemCuspt (lowest point above mCusp), use Hi func *)
, \[Chi]t  = \[Chi]Hi[\[Mu]t,PeriodsUntilT]
; \[Chi]\[Mu]t = \[Chi]\[Mu]Hi[\[Mu]t,PeriodsUntilT]
; \[Koppa]t  =1/(1+Exp[\[Chi]t])
; \[Koppa]\[Mu]t = \[Chi]\[Mu]t (\[Koppa]t-1) \[Koppa]t
; ctRealst=ctOptmst-(ctOptmst-ctPesmst) \[Koppa]t
; \[Kappa]tRealst = \[Kappa]tOptmst-\[Koppa]\[Mu]t (ctOptmst-ctPesmst)/\[FilledUpTriangle]mt
;
];

(* if mHiestBelowmCuspt <= mt <mLowestAbovemCuspt , use Mid function *)
  If[And[mt < mLowestAbovemCuspt, mt >= mHighestBelowmCuspt]
(* then use Mid func *)
, ctRealst = \[ScriptC]FuncLifeMd[[PeriodsUntilT+1]][mt]
; \[Kappa]tRealst = \[ScriptC]FuncLifeMd[[PeriodsUntilT+1]]'[mt]
];

(* if mt <= mHighestBelowmCuspt, use Lo func *)
 If[mt < mHighestBelowmCuspt
, \[Chi]t  = \[Chi]Lo[\[Mu]t,PeriodsUntilT]
; \[Chi]\[Mu]t = \[Chi]\[Mu]Lo[\[Mu]t,PeriodsUntilT]
; \[Koppa]t  =1/(1+Exp[\[Chi]t])
; \[Koppa]\[Mu]t = \[Chi]\[Mu]t (\[Koppa]t-1) \[Koppa]t
; ctRealst=\[Kappa]Maxt*\[FilledUpTriangle]mt-(\[Kappa]Maxt*\[FilledUpTriangle]mt-ctPesmst) \[Koppa]t 
; \[Kappa]tRealst = ctRealst/\[FilledUpTriangle]mt-\[Koppa]\[Mu]t (\[Kappa]Maxt-\[Kappa]tPesmst)
]; (* End If *)

  cVectRealst[[i]]=ctRealst; 
  \[Kappa]VectRealst[[i]]=\[Kappa]tRealst;
];
  aVectRealst=mVect-cVectRealst;

(* This part is similar to the transformation from \[ScriptC]From\[Chi] to \[ScriptC].*)
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


(*

Given the piecewise properties of the consumption below and above mCusp, 

the only way to simulate is to do it one-by-one, 
i.e. {"cListable", "\[Chi]Listable"}

*)


(*
(*This is not needed any more. *)

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
  \[FilledUpTriangle]\[GothicH]t   = \[FilledUpTriangle]\[GothicH]Life[[PeriodsUntilT+1]];
  \[Kappa]t    = \[Kappa]Min[[PeriodsUntilT+1]];
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

*)


(*
(*This is not needed any more. *)
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

*)


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
