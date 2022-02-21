(* ::Package:: *)

(* prepare.m: Prepares workspace so that SolveAnotherPeriod will do its job *)

<<functions_stable.m;


<<AddNewPeriodToParamLifeDates.m;

SolveAnotherPeriod := Block[{},
  AddNewPeriodToParamLifeDates;
  PeriodsSolved++
];


Clear[\[ScriptC],\[ScriptV]];
\[ScriptC][mt_,PeriodsUntilT_] := Block[{\[GothicA]LowerBoundt, mLowerBoundt,\[FilledUpTriangle]mtc,cFound},
  If[PeriodsUntilT==0,(*then*)Return[mt]]; (* \[ScriptC]=mt in last period *)
  (*else*)
  \[GothicA]LowerBoundt=Last[\[GothicA]LowerBoundLife];
  mLowerBoundt=Last[mLowerBoundLife];
 (* Can't borrow more than future income *)
  \[FilledUpTriangle]mtc = mt-\[GothicA]LowerBoundt;  (* Amount by which mt exceeds its minimum possible value *)
  cFound = cSeek /. (
      FindMaximum[
        {u[cSeek]+\[GothicV][mt-cSeek,PeriodsUntilT] (* Objective   *)
        ,0 < cSeek < \[FilledUpTriangle]mtc                   (* Constraints *)}
     ,{cSeek,0.5 \[FilledUpTriangle]mtc}] (* start the search at the 50 percent mark *)
     (* End FindMaximum *))[[2]];(* Element 2 is the rule from which cSeek /. extracts the answer *)
  Return[cFound]
];(*End \[ScriptC] Block[]*)

\[ScriptC][mt_] := \[ScriptC][mt,Length[\[Beta]Life]-1]; (* Without lifeperiod argument, use last period solved *)

\[ScriptV][mt_,PeriodsUntilT_] := Block[{cRealst},
  If[PeriodsUntilT==0
    ,(*then*)Return[u[mt]]];
     (*else*)cRealst = \[ScriptC][mt,PeriodsUntilT];
             Return[u[cRealst]+\[GothicV][mt-cRealst, PeriodsUntilT]
]
];
