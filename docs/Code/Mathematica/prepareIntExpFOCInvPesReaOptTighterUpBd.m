(* ::Package:: *)

(* prepareIntExpFOCInvPesReaOptTighterUpBd.m *)

<<functions_stable.m;



<<AddNewPeriodToParamLifeDates.m;
<<AddNewPeriodToParamLifeDatesTighterUpBd.m;
<<AddNewPeriodToSolvedLifeDates.m;
<<AddNewPeriodToSolvedLifeDatesPesReaOpt.m;
<<AddNewPeriodToSolvedLifeDatesPesReaOptTighterUpBd.m;


SolveAnotherPeriod := Block[{},

  AddNewPeriodToParamLifeDates;
  AddNewPeriodToParamLifeDatesTighterUpBd;
  AddNewPeriodToSolvedLifeDates;
  AddNewPeriodToSolvedLifeDatesPesReaOpt;  
  AddNewPeriodToSolvedLifeDatesPesReaOptTighterUpBd;
  PeriodsSolved++
];


<<functions_PesReaOptTighterUpBd.m;
