(* ::Package:: *)

(* prepareIntExpFOC.m *)

<<functions_stable.m;


<<AddNewPeriodToParamLifeDates.m;

SolveAnotherPeriod := Block[{},
  AddNewPeriodToParamLifeDates;
  (* Define interpolated expected value function by connecting the points (\[GothicA]Vec, \[GothicV](\[GothicA]Vec)) *)
  \[GothicA]LowerBoundt=Last[\[GothicA]LowerBoundLife];
  mLowerBoundt=Last[mLowerBoundLife];
 (* Generates appropriate mVec *)

  \[GothicV]Vect  = \[GothicV][\[GothicA]Vec ,PeriodsSolved+1];
  \[GothicV]aVect = \[GothicV]a[\[GothicA]Vec,PeriodsSolved+1];
  AppendTo[\[GothicV]FuncLife ,Interpolation[Transpose[{\[GothicA]Vec,\[GothicV]Vect }],InterpolationOrder->1]];
  AppendTo[\[GothicV]aFuncLife,Interpolation[Transpose[{\[GothicA]Vec,\[GothicV]aVect}],InterpolationOrder->1]];
  mLowerBoundt = -Last[\[GothicH]MinLife];

  cVect = 
   Map[ cSeek /. #  &
    ,Map[
      FindRoot[
        uP[cSeek] == \[GothicV]Hata[#-cSeek,PeriodsSolved+1]
      ,{cSeek,0.5 (#-mLowerBoundt)}]&,mVec]];

  vVect = u[cVect]+\[GothicV]Vect;

(* Construct piecewise linear numerical interpolating functions and update FuncLife *)
  AppendTo[\[ScriptV]FuncLife,Interpolation[vInterpData = Transpose[{mVec,vVect}],InterpolationOrder->1]];
  AppendTo[\[ScriptC]FuncLife,Interpolation[cInterpData = Transpose[{mVec,cVect}],InterpolationOrder->1]];
  PeriodsSolved++
];


<<functions_IntExpGothicV.m;
