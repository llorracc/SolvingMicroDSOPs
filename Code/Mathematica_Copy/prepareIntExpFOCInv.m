(* ::Package:: *)

(* 2periodIntExpFOCInv.m *)

<<functions_stable.m;


<<AddNewPeriodToParamLifeDates.m;

SolveAnotherPeriod := Block[{},
  AddNewPeriodToParamLifeDates;

  \[GothicA]LowerBoundt=Last[\[GothicA]LowerBoundLife];
  mLowerBoundt=Last[mLowerBoundLife];
(* Generates appropriate mVec *)

  \[GothicV]aVect = \[GothicV]a[\[GothicA]Vec,PeriodsSolved+1];
  cVect  = nP[\[GothicV]aVect];

  cVectPlusLowerBound = Prepend[cVect,0.];
  \[GothicA]VecPlusLowerBound   = Prepend[\[GothicA]Vec,\[GothicA]LowerBoundt];
  mVectPlusLowerBound = \[GothicA]VecPlusLowerBound + cVectPlusLowerBound;

  AppendTo[\[ScriptC]FuncLife,Interpolation[cInterpData = Transpose[{mVectPlusLowerBound,cVectPlusLowerBound}],InterpolationOrder->1]];
  AppendTo[\[GothicC]FuncLife,Interpolation[\[GothicC]InterpData  = Transpose[{\[GothicA]VecPlusLowerBound,cVectPlusLowerBound}],InterpolationOrder->1]];

  PeriodsSolved++
];


<<functions_Interpolate.m;
