(* ::Package:: *)

ClearAll[AddNewPeriodToSolvedLifeDates];
AddNewPeriodToSolvedLifeDates[\[Rho]_?NumericQ] := Block[{},
  
 \[GothicA]LowerBoundt  =\[GothicA]LowerBoundLife[[PeriodsSolved+1]];
 mLowerBoundt  =mLowerBoundLife[[PeriodsSolved+1]];
(* Generates appropriate mVec *)
  \[GothicA]Vect = Sort[Join[{0.03},\[GothicA]Vec]+\[GothicA]LowerBoundt]; 
(* Make sure a point close to the bound is included *)
(* But it can not be too close, like 0.001.
In that case, the tighter upper bound consumption will be extremely close to 
the realst, and maybe a tiny smaller than the realst. That is a problem.
Hence we choose 0.03, instead of 0.001.*)
  Constrainedt=ConstrainedLife[[PeriodsSolved+1]];
  \[GothicH]Borrowablet=\[GothicH]BorrowableLife[[PeriodsSolved+1]];
  aStart=-\[GothicH]Borrowablet;
  If[Constrainedt=="Yes"
, \[GothicA]Vect=Union[\[GothicA]Vect, {aStart}]
];
(* Union provides a sorted non-duplicated list. *)

\[DoubleStruckCapitalE]Allt=\[DoubleStruckCapitalE]All[\[GothicA]Vect, PeriodsSolved+1];
If[OptionToCalValFunc==True,
  \[GothicV]Vect     = \[DoubleStruckCapitalE]Allt[[3]];
  ];
  \[GothicV]aVect    = \[DoubleStruckCapitalE]Allt[[1]];
  \[GothicV]aaVect   = \[DoubleStruckCapitalE]Allt[[2]];

  cVect     = nP[\[GothicV]aVect];
  \[GothicC]aVect    = \[GothicV]aaVect/uPP[cVect];            
  \[Kappa]Vect     = (\[GothicC]aVect/(1+\[GothicC]aVect));
  mVect     = \[GothicA]Vect + cVect;

  If[OptionToCalValFunc==True,
  vVect      = u[cVect]+\[GothicV]Vect; 
  ];

(* Add bottom points to the vectors *)
  \[GothicA]VecIncBott = Prepend[\[GothicA]Vect, \[GothicA]LowerBoundt];
  mVecIncBott = Prepend[mVect, mLowerBoundt];
  cVecIncBott = Prepend[cVect,0.];
  \[GothicC]VecIncBott = Prepend[cVect,0.];

  (* Construct piecewise linear numerical interpolating functions *)
  If[OptionToCalValFunc==True, 
  AppendTo[\[ScriptV]FuncLife,Interpolation[vInterpData = Transpose[{mVect,vVect}],InterpolationOrder->1]];
  ];
  AppendTo[\[ScriptC]FuncLife,Interpolation[cInterpData = Transpose[{mVecIncBott,cVecIncBott}],InterpolationOrder->1]];
  AppendTo[\[GothicC]FuncLife,Interpolation[\[GothicC]InterpData = Transpose[{\[GothicA]VecIncBott,\[GothicC]VecIncBott}],InterpolationOrder->1]];
];
