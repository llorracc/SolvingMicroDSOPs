(* ::Package:: *)

(* 
'Raw' solutions use no approximations or tricks; 
they are computed for comparison with the approximate solutions
*)


\[ScriptC]Tm1Raw[mt_,PeriodsUntilT_] := Block[{cSeek,\[FilledUpTriangle]mt},
  mBot=-\[GothicH]MinLife[[PeriodsUntilT+1]];
  \[FilledUpTriangle]m=mt-mBot; 
  If[Chop[\[FilledUpTriangle]m]==0,Return[0.]];
    (*else*)
    cSeek /. 
      FindRoot[uP[cSeek] == \[GothicV]a[mt-cSeek,1]
               ,{cSeek,Max[0.01 \[FilledUpTriangle]m,0.99 \[FilledUpTriangle]m]}]];

\[ScriptC]Tm1Raw[mt_] := \[ScriptC]Tm1Raw[mt,1];
\[ScriptC]Tm2Raw[mt_,PeriodsUntilT_] := Block[{cSeek,\[FilledUpTriangle]mt},
  mBot=-\[GothicH]MinLife[[PeriodsUntilT+1]];
  \[FilledUpTriangle]m=mt-mBot; 
  If[Chop[\[FilledUpTriangle]m]==0,Return[0.]];
    (*else*)
    cSeek /. 
      FindRoot[uP[cSeek] == \[GothicV]a[mt-cSeek,2]
               ,{cSeek,Max[0.01 \[FilledUpTriangle]m,0.99 \[FilledUpTriangle]m]}]];

\[ScriptV]Tm1Raw[mt_,PeriodsUntilT_] := Block[{cOpt},
  cOpt=\[ScriptC]Tm1Raw[mt,PeriodsUntilT];
  u[cOpt]+\[GothicV][mt-cOpt,PeriodsUntilT]
  ];

\[ScriptV]mTm1Raw[mt_,PeriodsUntilT_] := Block[{cOpt},
  cOpt=\[ScriptC]Tm1Raw[mt,PeriodsUntilT];
  u'[cOpt]
  ];

\[ScriptC]Tm2RawPrint[mt_,PeriodsUntilT_] := Block[{cSeek,\[FilledUpTriangle]mt},
  mBot=-\[GothicH]MinLife[[PeriodsUntilT+1]];
  \[FilledUpTriangle]m=mt-mBot; 
  If[Chop[\[FilledUpTriangle]m]==0,Return[0.]];
    (*else*)
Print["cSeek /. FindRoot[uP[cSeek] == \[GothicV]a["<>ToString[mt]
<>"-cSeek,2],{cSeek,Max[0.01*"<>ToString[\[FilledUpTriangle]m]<>",0.99*"<>ToString[\[FilledUpTriangle]m]<>"]}]"]];

\[ScriptC]Tm2Raw[mt_] := \[ScriptC]Tm2Raw[mt,2];

\[Koppa]Tm1Raw[\[Mu]t_,PeriodsUntilT_] := Block[{ctOptmst,ctPesmst,ctRealst,\[FilledUpTriangle]mt,\[Kappa]t,\[FilledUpTriangle]\[GothicH]t, mLowerBoundt},
(*  If[PeriodsSolved == 0,Return["No periods solved."]];*)
  \[FilledUpTriangle]\[GothicH]t    =  \[GothicH]ExpLife[[PeriodsUntilT+1]]-\[GothicH]MinLife[[PeriodsUntilT+1]];(* Amount by which expected exceeds minimum human wealth *)
  mLowerBoundt  = -\[GothicH]MinLife[[PeriodsUntilT+1]]; (* With ct = 0, agent could have borrowed up to min \[GothicH] *)
  \[Kappa]t  = \[Kappa]MinLife[[PeriodsUntilT+1]];
  \[FilledUpTriangle]mt    = Exp[\[Mu]t]; (* Amount by which m exceeds its lower bound *)
  ctRealst  = \[ScriptC]Tm1Raw[mLowerBoundt+\[FilledUpTriangle]mt,1];
  ctPesmst = \[Kappa]t (\[FilledUpTriangle]mt    );
  ctOptmst  = \[Kappa]t (\[FilledUpTriangle]mt+\[FilledUpTriangle]\[GothicH]t);
  Return[(ctOptmst-ctRealst)/(\[Kappa]t \[FilledUpTriangle]\[GothicH]t)]
];

\[Koppa]Tm2Raw[\[Mu]t_,PeriodsUntilT_] := Block[{ctOptmst,ctPesmst,ctRealst,\[FilledUpTriangle]mt,\[Kappa]t,\[FilledUpTriangle]\[GothicH]t, mLowerBoundt},
(*  If[PeriodsSolved == 0,Return["No periods solved."]];*)
  \[FilledUpTriangle]\[GothicH]t    =  \[GothicH]ExpLife[[PeriodsUntilT+1]]-\[GothicH]MinLife[[PeriodsUntilT+1]];(* Amount by which expected exceeds minimum human wealth *)
  mLowerBoundt  = -\[GothicH]MinLife[[PeriodsUntilT+1]]; (* With ct = 0, agent could have borrowed up to min \[GothicH] *)
  \[Kappa]t  = \[Kappa]MinLife[[PeriodsUntilT+1]];
  \[FilledUpTriangle]mt    = Exp[\[Mu]t]; (* Amount by which m exceeds its lower bound *)
  ctRealst  = \[ScriptC]Tm2Raw[mLowerBoundt+\[FilledUpTriangle]mt,2];
  ctPesmst = \[Kappa]t (\[FilledUpTriangle]mt    );
  ctOptmst  = \[Kappa]t (\[FilledUpTriangle]mt+\[FilledUpTriangle]\[GothicH]t);
  Return[(ctOptmst-ctRealst)/(\[Kappa]t \[FilledUpTriangle]\[GothicH]t)]
];

\[Chi]Tm2Raw[\[Mu]t_,PeriodsUntilT_] := Log[(1-\[Koppa]Tm2Raw[\[Mu]t,PeriodsUntilT])/\[Koppa]Tm2Raw[\[Mu]t,PeriodsUntilT]];
