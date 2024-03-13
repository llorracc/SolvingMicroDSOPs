(* ::Package:: *)

(* AddNewPeriodToSolvedLifeDatesPesReaOptTighterUpBd *)
ClearAll[AddNewPeriodToSolvedLifeDatesPesReaOptTighterUpBdCon];

AddNewPeriodToSolvedLifeDatesPesReaOptTighterUpBdCon := Block[{},
(* Use insight that Pesmst < Realst < TighterUpBd for c *)
    \[GothicV]Start=\[GothicV][aStart, PeriodsSolved+1];
    \[GothicV]aStart=\[GothicV]a[aStart, PeriodsSolved+1];
    cStart = nP[\[GothicV]aStart];

If[Constrainedt=="Yes"
, cStart = nP[\[GothicV]aStart];  (* This is the kink point *)
; mStart=cStart+aStart   
; \[ScriptV]Start=u[cStart]+\[GothicV]Start
; \[CapitalLambda]Start=n[\[ScriptV]Start] 
;
, cStart=0
; mStart=cStart+aStart  
; \[ScriptV]Start=+\[Infinity]
; \[CapitalLambda]Start=0
; 
];

AppendTo[mStarLife, mStart];
AppendTo[cStarLife, cStart];
AppendTo[aStarLife, aStart];
AppendTo[\[GothicV]StarLife, \[GothicV]Start];
AppendTo[\[ScriptV]StarLife, \[ScriptV]Start];
AppendTo[\[CapitalLambda]StarLife, \[CapitalLambda]Start];

(*
Print[Plot[
{\[ScriptC]From\[Chi][mt,PeriodsSolved+1]
, mt+\[GothicH]Borrowablet
}, {mt, 0.3, 0.35}]
];
Print[" LHS=", \[ScriptC]From\[Chi][mStart, PeriodsSolved+1]];
Print[" RHS=", mStart+\[GothicH]Borrowablet];
(*
mStart=mt/.FindRoot[\[ScriptC]From\[Chi][mt, PeriodsSolved+1]==mt+\[GothicH]Borrowablet, {mt, 0, 10}]
;
*)
*)
];
