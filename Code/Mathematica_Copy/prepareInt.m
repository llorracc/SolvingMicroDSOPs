(* ::Package:: *)

(* prepareInt.m *)
<<functions_stable.m;


<<AddNewPeriodToParamLifeDates.m;

SolveAnotherPeriod := Block[{},
  AddNewPeriodToParamLifeDates;
  (* Extract maxima and optimal c's from numerical solution for all the \[ScriptM]'s in mVec *)

  \[GothicA]LowerBoundt=Last[\[GothicA]LowerBoundLife];
  mLowerBoundt=Last[mLowerBoundLife];
(* Generates appropriate mVec *)

  {vVect,cVect}= (* Associated  with that mVec *)
    Transpose[Map[{#[[1]],cSeek /.#[[2]] }&, (* Syntax to extract the answer from the Map[] function *)
      Map[
        FindMaximum[
         {u[cSeek]+\[GothicV][#-cSeek,1]           (* Objective *)
         ,0. < cSeek < (#-mLowerBoundt)} (* Constraints *)
        ,{cSeek,0.5 (#-mLowerBoundt), 0., (#-mLowerBoundt)} (* Search boundaries *)
       ]&,mVec]] 
    ];  (* End Transpose[] *)

  (* Construct piecewise linear numerical interpolating functions and update FuncLife *)
  AppendTo[\[ScriptV]FuncLife,Interpolation[vInterpData = Transpose[{mVec,vVect}],InterpolationOrder->1]];
  AppendTo[\[ScriptC]FuncLife,Interpolation[cInterpData = Transpose[{mVec,cVect}],InterpolationOrder->1]];
  PeriodsSolved++
];



<<functions_Interpolate.m;
