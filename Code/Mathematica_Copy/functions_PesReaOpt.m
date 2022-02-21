(* ::Package:: *)

ClearAll[\[Chi]];
\[Chi][\[Mu]_,PeriodsUntilT_] := \[Chi]FuncLife[[PeriodsUntilT+1]][\[Mu]];

ClearAll[\[Chi]\[Mu]];
\[Chi]\[Mu][\[Mu]_,PeriodsUntilT_] := \[Chi]FuncLife[[PeriodsUntilT+1]]'[\[Mu]];

ClearAll[\[ScriptC], \[ScriptC]BeforeT, \[ScriptC]From\[Chi]];
\[ScriptC][mt_,PeriodsUntilT_] := If[PeriodsUntilT == 0
  ,(*then*) Return[mt]
  ,(*else*) \[ScriptC]BeforeT[mt,PeriodsUntilT]];
\[ScriptC]BeforeT[mt_,PeriodsUntilT_] := Block[{cUnconstr},
  If[Constrained==False, Return[\[ScriptC]From\[Chi][mt,PeriodsUntilT]]];
  cUnconstr = \[ScriptC]From\[Chi][mt,PeriodsUntilT];
  If[cUnconstr > mt, Return[mt]]; (* If you want to consume more than m, too bad! *)
  Return[cUnconstr];
];
\[ScriptC]From\[Chi][mt_,PeriodsUntilT_]:= Block[{
  mLowerBoundt, \[FilledUpTriangle]mt, \[FilledUpTriangle]\[GothicH]t, \[Kappa]t, \[Mu]t, \[Mu]First, \[Chi]t, \[Koppa]t, ctOptmst, ctPesmst, ctRealst},
  mLowerBoundt = mLowerBoundLife[[PeriodsUntilT+1]]; 
  \[FilledUpTriangle]mt   = mt-mLowerBoundt;
  \[FilledUpTriangle]\[GothicH]t   = \[FilledUpTriangle]\[GothicH]AccessibleLife[[PeriodsUntilT+1]];
  \[Kappa]t    = \[Kappa]MinLife[[PeriodsUntilT+1]];
  \[Mu]t = Log[\[FilledUpTriangle]mt];
  \[Chi]t  = \[Chi][\[Mu]t,PeriodsUntilT];
  \[Koppa]t=1/(1+Exp[\[Chi]t]);
(*See Derivations.nb for derivations of formulas below *)
  ctOptmst = \[Kappa]t (\[FilledUpTriangle]mt+\[FilledUpTriangle]\[GothicH]t);
  ctPesmst = \[Kappa]t (\[FilledUpTriangle]mt); 
  ctRealst = ctOptmst-(ctOptmst-ctPesmst) \[Koppa]t; 
  Return[ctRealst]
];(*End Block*)
\[ScriptC][mt_] := \[ScriptC][mt,Length[\[Beta]Life]-1]; (* Without lifeperiod argument, use most recently solved *)


ClearAll[\[Kappa], \[Kappa]BeforeT, \[Kappa]From\[Chi]];
\[Kappa][mt_,PeriodsUntilT_] := If[PeriodsUntilT == 0,Return[1.]
, (*else*)\[Kappa]BeforeT[mt,PeriodsUntilT]];
\[Kappa]BeforeT[mt_,PeriodsUntilT_] := Block[{cUnconstr,\[Kappa]Unconstr},
  If[Constrained==False, Return[\[Kappa]From\[Chi][mt,PeriodsUntilT]]];
  cUnconstr = \[ScriptC]From\[Chi][mt,PeriodsUntilT];
  If[cUnconstr > mt,Return[1.]]; (* MPC is 1 if consumer is liquidity constrained *)
  Return[\[Kappa]From\[Chi][mt,PeriodsUntilT]]
];
\[Kappa]From\[Chi][mt_,PeriodsUntilT_]:=Block[{mLowerBoundt, \[FilledUpTriangle]mt, \[FilledUpTriangle]\[GothicH]t, \[Kappa]t, \[Mu]t, \[Mu]First, \[Chi]t, \[Chi]\[Mu]t, \[Koppa]t, \[Koppa]\[Mu]t, ctOptmst, ctPesmst, ctRealst, \[Kappa]tOptmst, \[Kappa]tPesmst, \[Kappa]tRealst},
  mLowerBoundt = mLowerBoundLife[[PeriodsUntilT+1]]; 
  \[FilledUpTriangle]mt   = mt-mLowerBoundt;
  \[FilledUpTriangle]\[GothicH]t   = \[FilledUpTriangle]\[GothicH]AccessibleLife[[PeriodsUntilT+1]];
  \[Kappa]t    = \[Kappa]MinLife[[PeriodsUntilT+1]];
  \[Mu]t = Log[\[FilledUpTriangle]mt];If[Chop[mt - mLowerBoundt]==0,\[Mu]t=-Infinity];
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
\[Kappa][mt_] := \[Kappa][mt,Length[\[Beta]Life]-1]; (* Without lifeperiod argument, use most recently solved *)


ClearAll[\[CapitalChi]];
\[CapitalChi][\[Mu]_,PeriodsUntilT_] := \[CapitalChi]FuncLife[[PeriodsUntilT+1]][\[Mu]];

ClearAll[\[CapitalChi]\[Mu]];
\[CapitalChi]\[Mu][\[Mu]_,PeriodsUntilT_] := \[CapitalChi]FuncLife[[PeriodsUntilT+1]]'[\[Mu]];

ClearAll[\[CapitalLambda], \[CapitalLambda]BeforeT, \[CapitalLambda]From\[CapitalChi]];
\[CapitalLambda][mt_,PeriodsUntilT_] := If[PeriodsUntilT==0,mt,(*else*)\[CapitalLambda]BeforeT[mt,PeriodsUntilT]];
\[CapitalLambda]BeforeT[mt_,PeriodsUntilT_]:= Block[{\[CapitalLambda]Unconstr,cUnconstr},
 If[Constrained==False, Return[\[CapitalLambda]From\[CapitalChi][mt,PeriodsUntilT]]];
  cUnconstr = \[ScriptC]From\[Chi][mt,PeriodsUntilT];
 If[cUnconstr > mt,
    cWhereConstrBinds = \[GothicC]FuncLife[[PeriodsUntilT+1]][0.];
    vWhereConstrBinds=u[\[CapitalLambda]From\[CapitalChi][cWhereConstrBinds,PeriodsUntilT]];
    vConstr = vWhereConstrBinds+u[mt]-u[cWhereConstrBinds]; (* Because MPC is 1 below point where constraint binds *)
    Return[((1-\[Rho])vConstr)^(1/(1-\[Rho]))]];
 Return[\[CapitalLambda]From\[CapitalChi][mt,PeriodsUntilT]];
];
\[CapitalLambda]From\[CapitalChi][mt_,PeriodsUntilT_]:= Block[{mLowerBoundt,vSumt, \[FilledUpTriangle]mt,\[FilledUpTriangle]\[GothicH]t,\[Kappa]t,\[Mu]t,\[CapitalChi]t, ctOptmst, ctPesmst,\[CapitalLambda]tOptmst,\[CapitalLambda]tPesmst, \[CapitalLambda]tRealst, \[CapitalKoppa]t, \[Mu]First,\[DoubleStruckCapitalC]t},
  mLowerBoundt = \[GothicA]LowerBoundLife[[PeriodsUntilT+1]]; 
 vSumt=vSumLife[[PeriodsUntilT+1]];
  \[FilledUpTriangle]mt   = mt-mLowerBoundt;
  \[FilledUpTriangle]\[GothicH]t   = \[FilledUpTriangle]\[GothicH]AccessibleLife[[PeriodsUntilT+1]];
  \[Kappa]t    = \[Kappa]MinLife[[PeriodsUntilT+1]];
  \[Mu]t = Log[\[FilledUpTriangle]mt];
  \[CapitalChi]t = \[CapitalChi][\[Mu]t,PeriodsUntilT];
(*See Derivations.nb for derivations of formulas below *)
  ctOptmst = \[Kappa]t (\[FilledUpTriangle]mt+\[FilledUpTriangle]\[GothicH]t);
  ctPesmst = \[Kappa]t (\[FilledUpTriangle]mt); 
  \[CapitalLambda]tOptmst = ctOptmst (vSumt)^(1/(1-\[Rho]));
  \[CapitalLambda]tPesmst = ctPesmst (vSumt)^(1/(1-\[Rho]));
  \[CapitalKoppa]t=1/(1+Exp[\[CapitalChi]t]);
  \[CapitalLambda]tRealst = \[CapitalLambda]tOptmst-\[CapitalKoppa]t*(\[CapitalLambda]tOptmst-\[CapitalLambda]tPesmst); 
  Return[\[CapitalLambda]tRealst] 
];(*End Block*)

ClearAll[\[ScriptV], \[ScriptV]BeforeT, \[ScriptV]From\[CapitalChi]];
\[ScriptV][mt_,PeriodsUntilT_] := If[PeriodsUntilT==0,u[mt],(*else*)\[ScriptV]BeforeT[mt,PeriodsUntilT]];
\[ScriptV]BeforeT[mt_,PeriodsUntilT_] := \[ScriptV]From\[CapitalChi][mt,PeriodsUntilT];
\[ScriptV]From\[CapitalChi][mt_,PeriodsUntilT_] := u[\[CapitalLambda][mt,PeriodsUntilT]];
\[ScriptV][mt_] := \[ScriptV][mt,Length[\[Beta]Life]-1]; (* Without lifeperiod argument, use most recently solved *)

ClearAll[\[ScriptV]m, \[ScriptV]mBeforeT];
\[ScriptV]m[mt_,PeriodsUntilT_] := If[PeriodsUntilT==0,uP[mt],(*else*)\[ScriptV]mBeforeT[mt,PeriodsUntilT]];
\[ScriptV]mBeforeT[mt_,PeriodsUntilT_] := uP[\[ScriptC][mt, PeriodsUntilT]];

SetAttributes[{\[Chi], \[Chi]\[Mu]
, \[ScriptC], \[ScriptC]BeforeT, \[ScriptC]From\[Chi]
, \[Kappa], \[Kappa]BeforeT, \[Kappa]From\[Chi]
, \[CapitalChi], \[CapitalChi]\[Mu]
, \[CapitalLambda], \[CapitalLambda]BeforeT, \[CapitalLambda]From\[CapitalChi]
, \[ScriptV], \[ScriptV]BeforeT, \[ScriptV]From\[CapitalChi]
, \[ScriptV]m, \[ScriptV]mBeforeT}, Listable]; (* Allows funcs to operate on lists *)

