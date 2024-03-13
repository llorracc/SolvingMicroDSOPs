(* ::Package:: *)

(* ::Subsection:: *)
(*Consumption function;*)


ClearAll[\[Chi]Hi];
\[Chi]Hi[\[Mu]_,PeriodsUntilT_] := \[Chi]FuncLifeHi[[PeriodsUntilT+1]][\[Mu]];
ClearAll[\[Chi]\[Mu]Hi];
\[Chi]\[Mu]Hi[\[Mu]_,PeriodsUntilT_] := \[Chi]FuncLifeHi[[PeriodsUntilT+1]]'[\[Mu]];

ClearAll[\[Chi]Lo];
\[Chi]Lo[\[Mu]_,PeriodsUntilT_] := \[Chi]FuncLifeLo[[PeriodsUntilT+1]][\[Mu]];
ClearAll[\[Chi]\[Mu]Lo];
\[Chi]\[Mu]Lo[\[Mu]_,PeriodsUntilT_] := \[Chi]FuncLifeLo[[PeriodsUntilT+1]]'[\[Mu]];


\[ScriptC]Hi[mt_,PeriodsUntilT_]:= Block[{
  mLowerBoundt, mCuspt , \[FilledUpTriangle]mt, \[FilledUpTriangle]\[GothicH]t, \[Kappa]t, \[Kappa]Maxt, \[Mu]t, \[Mu]First, \[Chi]t, \[Chi]Lowert, \[Koppa]t, \[Koppa]Lowert, ctOptmst, ctPesmst, ctRealst},
  mLowerBoundt = mLowerBoundLife[[PeriodsUntilT+1]]; 
  mCuspt =mCuspLife[[PeriodsUntilT+1]];
  \[FilledUpTriangle]mt   = mt-mLowerBoundt;
  \[FilledUpTriangle]\[GothicH]t   = \[FilledUpTriangle]\[GothicH]AccessibleLife[[PeriodsUntilT+1]];
  \[Kappa]t    = \[Kappa]MinLife[[PeriodsUntilT+1]];
  \[Kappa]Maxt    = \[Kappa]MaxLife[[PeriodsUntilT+1]]; 
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
  \[Kappa]Maxt    = \[Kappa]MaxLife[[PeriodsUntilT+1]]; 
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
\[ScriptC][mt_,PeriodsUntilT_] := Block[{
  ct},
If[PeriodsUntilT == 0
  ,(*then*) ct = mt
  ,(*else*) ct = \[ScriptC]BeforeT[mt,PeriodsUntilT]
];
  Return[ct];
];(*End Block*)

\[ScriptC]BeforeT[mt_,PeriodsUntilT_] := Block[{Constrainedt, mStart, \[GothicH]Borrowablet, ct},
  Constrainedt     =  ConstrainedLife[[PeriodsUntilT+1]];
  mStart           =  mStarLife[[PeriodsUntilT+1]];
  \[GothicH]Borrowablet     =  \[GothicH]BorrowableLife[[PeriodsUntilT+1]];
 (* mStart is the cut-off value between the binding and non-binding constraints *)
  If[mt>=mStart
, ct=\[ScriptC]From\[Chi][mt,PeriodsUntilT]
, ct=mt+\[GothicH]Borrowablet
];
  Return[ct];
];

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
; ctRealst=\[Kappa]Maxt \[FilledUpTriangle]mt-(\[Kappa]Maxt \[FilledUpTriangle]mt-ctPesmst) \[Koppa]t 
]; (* End If *)

  Return[ctRealst]
];(*End Block*)

\[ScriptC][mt_] := \[ScriptC][mt,Length[\[Beta]Life]-1]; (* Without lifeperiod argument, use most recently solved *)


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
  \[Kappa]Maxt    = \[Kappa]MaxLife[[PeriodsUntilT+1]]; (* June 2012 KT added *)
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
  ctRealst=\[Kappa]Maxt \[FilledUpTriangle]mt- (\[Kappa]Maxt \[FilledUpTriangle]mt-ctPesmst) \[Koppa]t; (* June 2012 KT fixed *)
  \[Kappa]tRealst = ctRealst/\[FilledUpTriangle]mt-\[Koppa]\[Mu]t (\[Kappa]Maxt-\[Kappa]tOptmst);
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

\[Kappa]BeforeT[mt_,PeriodsUntilT_] := Block[{Constrainedt, mStart, \[GothicH]Borrowablet, \[Kappa]t},
 Constrainedt     =  ConstrainedLife[[PeriodsUntilT+1]];
  mStart           =  mStarLife[[PeriodsUntilT+1]];
  \[GothicH]Borrowablet     =  \[GothicH]BorrowableLife[[PeriodsUntilT+1]];
 (* mStart is the cut-off value between the binding and non-binding constraints *)
  If[mt>mStart
, \[Kappa]t=\[Kappa]From\[Chi][mt,PeriodsUntilT]
, \[Kappa]t=1
];
 (* MPC is 1 if consumer is liquidity constrained *)
  Return[\[Kappa]t];
];

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
; \[Kappa]tRealst = ctRealst/\[FilledUpTriangle]mt-\[Koppa]\[Mu]t (\[Kappa]Maxt-\[Kappa]tOptmst)
;
];

  Return[\[Kappa]tRealst]
];

\[Kappa][mt_] := \[Kappa][mt,Length[\[Beta]Life]-1]; (* Without lifeperiod argument, use most recently solved *)


(* ::Subsection:: *)
(*Value function;*)


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
  \[GothicV]OptmstCon0at=\[GothicV]OptmstCon0aLife[[PeriodsUntilT+1]];
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


\[CapitalLambda]Md[mt_,PeriodsUntilT_]:= Block[{
  \[CapitalLambda]tRealst},
  \[CapitalLambda]tRealst = \[CapitalLambda]FuncLifeMd[[PeriodsUntilT+1]][mt];
  Return[\[CapitalLambda]tRealst];
];(*End Block*)




ClearAll[\[CapitalLambda], \[CapitalLambda]BeforeT, \[CapitalLambda]From\[CapitalChi]];
\[CapitalLambda][mt_,PeriodsUntilT_] := If[PeriodsUntilT==0,mt,(*else*)\[CapitalLambda]BeforeT[mt,PeriodsUntilT]];

\[CapitalLambda]BeforeT[mt_,PeriodsUntilT_]:= Block[{Constrainedt, mStart, \[GothicH]Borrowablet, ct,\[GothicV]Start, \[ScriptV]t, \[CapitalLambda]t},
Constrainedt=ConstrainedLife[[PeriodsUntilT+1]];
   mStart           =  mStarLife[[PeriodsUntilT+1]];
 (* mStart is the cut-off value between the binding and non-binding constraints *)
  \[GothicH]Borrowablet     =  \[GothicH]BorrowableLife[[PeriodsUntilT+1]];
  \[GothicV]Start=\[GothicV]StarLife[[PeriodsUntilT+1]];

  If[mt>=mStart
, \[CapitalLambda]t=\[CapitalLambda]From\[CapitalChi][mt,PeriodsUntilT]
, ct=mt+\[GothicH]Borrowablet
; \[ScriptV]t=u[ct]+\[GothicV]Start
; \[CapitalLambda]t=((1-\[Rho])\[ScriptV]t)^(1/(1-\[Rho]));
];

  Return[\[CapitalLambda]t];
];

\[CapitalLambda]From\[CapitalChi][mt_,PeriodsUntilT_]:= Block[{
  mLowerBoundt, mCuspt, \[FilledUpTriangle]mt, mHighestBelowmCuspt 
, mLowestAbovemCuspt, \[FilledUpTriangle]\[GothicH]t, \[Kappa]t, \[Kappa]Maxt, \[Mu]t, \[CapitalChi]t, \[CapitalKoppa]t
, ctOptmst, ctPesmst, \[CapitalLambda]tTighterUpBd, \[CapitalLambda]tOptmst, \[CapitalLambda]tPesmst, \[CapitalLambda]tRealst, \[Mu]First, vSumt
, \[GothicV]OptmstCon0at, \[ScriptV]tOptmstTighterUpBd, \[CapitalLambda]tOptmstTighterUpBd},
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
; \[ScriptV]tOptmst =  u[ctOptmst]*vSumt
; \[CapitalLambda]tOptmst =((1-\[Rho])\[ScriptV]tOptmst)^(1/(1-\[Rho])) 
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
\[ScriptV]BeforeT, \[ScriptV]From\[CapitalChi]
\[ScriptV][mt_,PeriodsUntilT_] :=If[PeriodsUntilT==0,u[mt],(*else*)\[ScriptV]BeforeT[mt,PeriodsUntilT]];
\[ScriptV]BeforeT[mt_,PeriodsUntilT_] := \[ScriptV]From\[CapitalChi][mt,PeriodsUntilT];
\[ScriptV]From\[CapitalChi][mt_,PeriodsUntilT_] := u[\[CapitalLambda][mt,PeriodsUntilT]];
*)



\[ScriptV][mt_] := \[ScriptV][mt,Length[\[Beta]Life]-1]; (* Without lifeperiod argument, use most recently solved *)


ClearAll[\[ScriptV]m, \[ScriptV]mBeforeT];
\[ScriptV]m[mt_,PeriodsUntilT_] := If[PeriodsUntilT==0,uP[mt],(*else*)\[ScriptV]mBeforeT[mt,PeriodsUntilT]];
\[ScriptV]mBeforeT[mt_,PeriodsUntilT_] := uP[\[ScriptC][mt, PeriodsUntilT]];


(* ::Subsection:: *)
(*SetAttributes*)


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

