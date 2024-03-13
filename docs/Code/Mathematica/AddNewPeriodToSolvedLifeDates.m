(* ::Package:: *)

ClearAll[AddNewPeriodToSolvedLifeDates];
AddNewPeriodToSolvedLifeDates := Block[{},

  \[GothicA]LowerBoundt=Last[\[GothicA]LowerBoundLife];
  mLowerBoundt=Last[mLowerBoundLife];
(* Generates appropriate mVec *)
  \[GothicA]Vect = Sort[Join[{0.03},\[GothicA]Vec]+\[GothicA]LowerBoundt]; 
(* Make sure a point close to the bound is included *)
(* But it can not be too close, like 0.001.
In that case, the tighter upper bound consumption will be extremely close to 
the realst, and maybe a tiny smaller than the realst. That is a problem.
Hence we choose 0.03, instead of 0.001.*)
  Constrainedt=Last[ConstrainedLife];
  \[GothicH]Borrowablet=Last[\[GothicH]BorrowableLife];
  aStart=-\[GothicH]Borrowablet;
  If[Constrainedt=="Yes"
, \[GothicA]Vect=Union[\[GothicA]Vect, {aStart}]
];
(* Union provides a sorted non-duplicated list. *)

  \[GothicV]Vect     = \[GothicV][  \[GothicA]Vect,PeriodsSolved+1];
  \[GothicV]aVect    = \[GothicV]a[ \[GothicA]Vect,PeriodsSolved+1];
  \[GothicV]aaVect   = \[GothicV]aa[\[GothicA]Vect,PeriodsSolved+1];

  cVect     = nP[\[GothicV]aVect];

  \[GothicC]aVect    = \[GothicV]aaVect/uPP[cVect];            
  \[Kappa]Vect     = (\[GothicC]aVect/(1+\[GothicC]aVect));
  mVect     = \[GothicA]Vect + cVect;

  \[FilledUpTriangle]mVect    = mVect-mLowerBoundt;
  \[Mu]Vect     = Log[\[FilledUpTriangle]mVect];

  vVect      = u[cVect]+\[GothicV]Vect; 

(* Add bottom points to the vectors *)
(*  If[Min[\[Theta]Vals] > 0. && Constrained==True
, 
  \[GothicA]VecIncBott = \[GothicA]Vect;
  mVecIncBott = mVect;
  cVecIncBott = cVect;
  \[GothicC]VecIncBott = cVect;
, *)
  \[GothicA]VecIncBott = Prepend[\[GothicA]Vect,\[GothicA]LowerBoundt];
  mVecIncBott = Prepend[mVect,mLowerBoundt];
  cVecIncBott = Prepend[cVect,0.];
  \[GothicC]VecIncBott = Prepend[cVect,0.];
(*];*)


  (* Construct piecewise linear numerical interpolating functions *)

 AppendTo[\[ScriptV]FuncLife,Interpolation[vInterpData = Transpose[{mVect,vVect}],InterpolationOrder->1]];

 AppendTo[\[ScriptC]FuncLife,Interpolation[cInterpData = Transpose[{mVecIncBott,cVecIncBott}],InterpolationOrder->1]];
 AppendTo[\[GothicC]FuncLife,Interpolation[\[GothicC]InterpData = Transpose[{\[GothicA]VecIncBott,\[GothicC]VecIncBott}],InterpolationOrder->1]];
];
