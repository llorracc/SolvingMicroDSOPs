(* ::Package:: *)

(* prepareIntExpFOCInvPesReaOpt.m *)

<<functions_stable.m;


<<AddNewPeriodToParamLifeDates.m;
<<AddNewPeriodToSolvedLifeDates.m;
<<AddNewPeriodToSolvedLifeDatesPesReaOpt.m;

SolveAnotherPeriod := Block[{},
  AddNewPeriodToParamLifeDates;
  AddNewPeriodToSolvedLifeDates;
  AddNewPeriodToSolvedLifeDatesPesReaOpt;
  PeriodsSolved++
];



<<functions_PesReaOpt.m;
