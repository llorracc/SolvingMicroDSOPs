(* ::Package:: *)

(* prepareIntExp.m *)
<<functions_stable.m;


<<AddNewPeriodToParamLifeDates.m;

SolveAnotherPeriod := Block[{},
  AddNewPeriodToParamLifeDates;
(* Define interpolated expected value function by connecting the points (\[GothicA]Vec, \[GothicV](\[GothicA]Vec)) *)

  \[GothicA]LowerBoundt=Last[\[GothicA]LowerBoundLife];
  mLowerBoundt=Last[mLowerBoundLife];
(* Generates appropriate mVec *)

  \[GothicV]Vect  = \[GothicV][\[GothicA]Vec,PeriodsSolved+1];

  AppendTo[\[GothicV]FuncLife
    ,Interpolation[\[GothicV]InterpData = Transpose[{\[GothicA]Vec,\[GothicV]Vect}]
                   ,InterpolationOrder->1]];

  {vVect,cVect}= (* The complex syntax involving Map is more computationally efficient than looping *)
    Transpose[Map[{#[[1]],cSeek /.#[[2]] }&,
      Map[
        FindMaximum[
          {u[cSeek]+\[GothicV]Hat[#-cSeek,Length[\[Beta]Life]-1] (* Objective *)
          ,0. < cSeek < (#-mLowerBoundt)}         (* Constraints *)
         ,{cSeek,0.5 (#-mLowerBoundt)}]&,mVec]]
    ];  (* End Transpose[] *)

  (* Construct piecewise linear numerical interpolating functions and update FuncLife *)
  AppendTo[\[ScriptV]FuncLife,Interpolation[vInterpData = Transpose[{mVec,vVect}],InterpolationOrder->1]];
  AppendTo[\[ScriptC]FuncLife,Interpolation[cInterpData = Transpose[{mVec,cVect}],InterpolationOrder->1]];
  PeriodsSolved++
];


<<functions_IntExpGothicV.m;
