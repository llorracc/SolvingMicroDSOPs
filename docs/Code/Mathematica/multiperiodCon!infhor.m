(* ::Package:: *)

<<multiperiodCon.m;

ClearAll[SolveAnotherPeriod];
SolveAnotherPeriod := Block[{},
  AddNewPeriodToParamLifeDates; 
  AppendTo[\[GothicA]LowerBoundLife,\[GothicA]LowerBoundt=-Last[\[GothicH]MinLife]];
  AppendTo[mLowerBoundLife,mLowerBoundt=-Last[\[GothicH]MinLife]];
  mTarget = mSeek /. FindRoot[(RLife[[PeriodsSolved+2]]/\[ScriptCapitalG]Life[[PeriodsSolved+2]])*(mSeek-\[ScriptC][mSeek, PeriodsSolved])+1 == mSeek
    , {mSeek,1}];
  (* WWu comments on 2011/06/21: this mTarget corresponds to the consumption PeriodsSolved. *)
  (*Unconstrained consumer can borrow against certain future income*)
  AddNewPeriodToSolvedLifeDates;
  AddNewPeriodToSolvedLifeDatesPesReaOpt;
  PeriodsSolved++;
];

VerboseOutput=True;


SolveToToleranceOf[mTargetTol_] := Block[{mTargetPrev,mTargetNext},
  {mTargetPrev,mTargetNext} = {mTarget,0.};
  While[Abs[mTargetPrev-mTargetNext]>mTargetTol,
    mTargetPrev = mTarget;
    SolveAnotherPeriod; (* New target is found for this period just solved. *)
    mTargetNext = mTarget;
    If[VerboseOutput==True, Print[mTargetPrev-mTargetNext," is latest tolerance for target change."]]
  ]; (* end While *)
  If[VerboseOutput==True,
  Print["Converged; Finished solving!"];
  Print["Currently ", PeriodsSolved," Periods From End."];];
];


SolveInfHorizToToleranceAtTarget[mTargetTol_] := Block[{},
  (* Solve for successively finer approximations to the shock distribution *)
  (* This is much faster than solving for fine approximations all the way from the start, *)
  (* and ultimately just as accurate *)

  NumOf\[Theta]ShockPts=3;
  <<setup_shocks.m;
  <<setup_lastperiod.m;
  Print[{\[Theta]Vals,\[Theta]Prob}];
  SolveAnotherPeriod;
  SolveToToleranceOf[mTargetTol/8];

  NumOf\[Theta]ShockPts=5;
  <<setup_shocks.m;
  Print[{\[Theta]Vals,\[Theta]Prob}];
  SolveToToleranceOf[mTargetTol/4];
 
  NumOf\[Theta]ShockPts=7;
  <<setup_shocks.m;
  Print[{\[Theta]Vals,\[Theta]Prob}];
  SolveToToleranceOf[mTargetTol/2];
  
  NumOf\[Theta]ShockPts=13;
  <<setup_shocks.m;
  Print[{\[Theta]Vals,\[Theta]Prob}];
  SolveToToleranceOf[mTargetTol];
  
  ModelIsSolved=True
];

