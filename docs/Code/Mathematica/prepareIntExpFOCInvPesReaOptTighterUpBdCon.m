(* ::Package:: *)

(* prepareIntExpFOCInvPesReaOptTighterUpBd.m *)

<<functions_stable.m;



<<AddNewPeriodToParamLifeDates.m;
<<AddNewPeriodToParamLifeDatesTighterUpBd.m;
<<AddNewPeriodToSolvedLifeDates.m;
<<AddNewPeriodToSolvedLifeDatesPesReaOpt.m;
<<AddNewPeriodToSolvedLifeDatesPesReaOptTighterUpBd.m;
<<AddNewPeriodToSolvedLifeDatesPesReaOptTighterUpBdCon.m;


SolveAnotherPeriod := Block[{},

  AddNewPeriodToParamLifeDates;
  AddNewPeriodToParamLifeDatesTighterUpBd;
  AddNewPeriodToSolvedLifeDates;
  AddNewPeriodToSolvedLifeDatesPesReaOpt;  
  AddNewPeriodToSolvedLifeDatesPesReaOptTighterUpBd;
  AddNewPeriodToSolvedLifeDatesPesReaOptTighterUpBdCon;
  PeriodsSolved++
];


<<functions_PesReaOptTighterUpBdCon.m;
