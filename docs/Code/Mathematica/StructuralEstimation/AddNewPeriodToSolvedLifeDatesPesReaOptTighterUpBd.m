(* ::Package:: *)

(* AddNewPeriodToSolvedLifeDatesPesReaOptTighterUpBd *)
ClearAll[AddNewPeriodToSolvedLifeDatesPesReaOptTighterUpBd];

AddNewPeriodToSolvedLifeDatesPesReaOptTighterUpBd[\[Rho]_?NumericQ] := Block[{},
(* Use insight that Pesmst < Realst < TighterUpBd for c *)
 
  AppendTo[\[Chi]FuncLifeHi, \[Chi]Func];
 
  \[Kappa]Maxt   =  Last[\[Kappa]MaxLife]; 
  \[GothicH]Expt   =  Last[\[GothicH]ExpLife];
  \[GothicH]Accessiblet   =  Last[\[GothicH]AccessibleLife];
  \[FilledUpTriangle]mCuspt =  Last[\[FilledUpTriangle]mCuspLife];
  mCuspt  =  Last[mCuspLife];

(*
Print["cVectOptmst=", cVectOptmst];
Print["cVectOptmstTighter=", \[Kappa]Maxt*\[FilledUpTriangle]mVect];
Print["cVectRealst=", cVectRealst];
Print["cVectPesmst=", cVectPesmst];
*)

(* Values for different variables at the cusp point are all calculated *)

(* cCuspt needs to be calculated 
 using \[ScriptC]Hi funciton because \[ScriptC]From\[Chi] or \[ScriptC]Lo is not defined at mCuspt yet. 
 Should keep this line to show IntExpFOCInvPesReaOptTighterUpBdGapPlot 
(difference between \[ScriptC]Hi and \[ScriptC]Lo right. 
*)
  cCuspt  = \[ScriptC]Hi[mCuspt, PeriodsSolved+1]; 
  \[GothicA]Cuspt  = mCuspt - cCuspt;
  \[Kappa]Cuspt = \[Kappa]Hi[mCuspt, PeriodsSolved+1];

  \[Mu]Cuspt = Log[\[FilledUpTriangle]mCuspt];

(* Divide gridpoins into three parts: lower, middle and higher part around the cusp point *)
 
(*
If[ TrueQ[mCuspt<=mVect[[1]]]==True
, Print["mCuspt is less than the smallest element on mVect.
         No need to do the TighterUpBd revision for this period. 
         We will directly jump to next period."]
; Continue[]
;
];
*)

  mHighestBelowmCusp    = Select[mVect, # < mCuspt &][[-1]];
  mLowestAbovemCusp     = Select[mVect, # >= mCuspt &, 1][[1]];
  {{iHighestBelowmCusp}}  = Position[mVect, mHighestBelowmCusp];
  {{iLowestAbovemCusp}}   = Position[mVect, mLowestAbovemCusp];

  mVectLo    = Table[mVect[[i]], {i, 1, iHighestBelowmCusp}];
  \[FilledUpTriangle]mVectLo   = mVectLo-mLowerBoundt;
  \[Mu]VectLo    = Table[\[Mu]Vect[[i]], {i, 1, iHighestBelowmCusp}];
  cVectLo    = Table[cVect[[i]], {i, 1, iHighestBelowmCusp}];
  \[Kappa]VectLo    = Table[\[Kappa]Vect[[i]], {i, 1, iHighestBelowmCusp}];
 
  AppendTo[mHighestBelowmCuspLife, mHighestBelowmCusp];    (* highest value below mCusp *) 
  AppendTo[mLowestAbovemCuspLife, mLowestAbovemCusp];      (* lowest value below mCusp *) 

  \[ScriptC]DataMd = Table[{{mVect[[i]]}, cVect[[i]], \[Kappa]Vect[[i]]}
            , {i, iHighestBelowmCusp, iLowestAbovemCusp}];
(* Data for interpolation, matching derivatives. *)
  \[ScriptC]FuncMd = Interpolation[\[ScriptC]DataMd]; (* Interpolation of mid c function *)
  AppendTo[\[ScriptC]FuncLifeMd, \[ScriptC]FuncMd];   

 (* Added these lines to set up coefficients for GPU simulation *)
  \[ScriptC]\[Kappa]CoeffsMd = Table[FindCubicSpline[
  mVect[[j]], cVect[[j]], \[Kappa]Vect[[j]]
, mVect[[j+1]], cVect[[j+1]], \[Kappa]Vect[[j+1]]
], {j, iHighestBelowmCusp, iLowestAbovemCusp-1}];

  AppendTo[\[Mu]GridsLifeMd, Table[\[Mu]Vect[[i]]
            , {i, iHighestBelowmCusp, iLowestAbovemCusp}]
	];
  AppendTo[mGridsLifeMd, Table[mVect[[i]]
            , {i, iHighestBelowmCusp, iLowestAbovemCusp}]
	];
  AppendTo[\[ScriptC]DataLifeMd, \[ScriptC]DataMd];
  AppendTo[\[ScriptC]\[Kappa]CoeffsLifeMd, \[ScriptC]\[Kappa]CoeffsMd];

  (* If length of mVectLo (Length[mVectLo]) is 1, run the following because "Length[mVectLo]-1" 
above become zero and does not make sense. 
The following lines set mHighestBelowmCuspLife at mCuspt. 
This adjustment does not change the substance of the solution 
at all but is useful to avoid an error. *)
(*  If[Length[mVectLo]==1, 
     mHighestBelowmCuspLife[[-1]] = mCuspt;
     \[ScriptC]DataMid = {{{mCuspt}, cCuspt, \[Kappa]Cuspt}, {{mVect[[Length[mVectLo]]]}, cVect[[Length[cVectLo]]], \[Kappa]Vect[[Length[\[Kappa]VectLo]]]}}; 
   ]; 
*)
 
  cVectRealstLo = cVectLo;   (* Realst's solution already obtained in AddNewPeriodToSolvedLifeDates  *)
  cVectOptmstLo = \[Kappa]Maxt*\[FilledUpTriangle]mVectLo;  (* Optimst *) 
  cVectPesmstLo = \[Kappa]t*\[FilledUpTriangle]mVectLo;  (* Pessimist *)
  \[Kappa]VectRealstLo = \[Kappa]VectLo;

If[ cVectRealstLo[[1]]>=cVectOptmstLo[[1]]
, cVectRealstLo[[1]]=cVectOptmstLo[[1]]-0.01*(cVectOptmstLo[[2]]-cVectRealstLo[[2]])
];
 
 
  \[Koppa]ValsLo  = (cVectOptmstLo-cVectRealstLo)/(cVectOptmstLo-cVectPesmstLo);
  \[Koppa]\[Mu]ValsLo = (cVectRealstLo-\[Kappa]VectRealstLo*\[FilledUpTriangle]mVectLo)/(cVectOptmstLo-cVectPesmstLo);

  \[Chi]ValsLo  = Log[(1/\[Koppa]ValsLo)-1];
  \[Chi]\[Mu]ValsLo = \[Koppa]\[Mu]ValsLo/((\[Koppa]ValsLo-1) \[Koppa]ValsLo);  (* Derivative of \[Chi] wrt \[Mu] *)

  \[Mu]VectLoAug=Join[{\[Mu]VectLo[[1]]-\[Mu]SmallGapLeft}
, \[Mu]VectLo
];
  \[Koppa]ValsLoAug=Join[{\[Koppa]ValsLo[[1]]-\[Koppa]\[Mu]ValsLo[[1]]*\[Mu]SmallGapLeft}
, \[Koppa]ValsLo
];
  \[Koppa]\[Mu]ValsLoAug=Join[{\[Koppa]\[Mu]ValsLo[[1]]}
, \[Koppa]\[Mu]ValsLo
];
  \[Chi]ValsLoAug=Join[{\[Chi]ValsLo[[1]]-\[Chi]\[Mu]ValsLo[[1]]*\[Mu]SmallGapLeft}
, \[Chi]ValsLo
];
  \[Chi]\[Mu]ValsLoAug=Join[{\[Chi]\[Mu]ValsLo[[1]]}
, \[Chi]\[Mu]ValsLo
];

  \[Koppa]DataLo=Transpose[{AddBracesTo[\[Mu]VectLoAug],\[Koppa]ValsLoAug,\[Koppa]\[Mu]ValsLoAug}];
  \[Chi]DataLo=Transpose[{AddBracesTo[\[Mu]VectLoAug],\[Chi]ValsLoAug,\[Chi]\[Mu]ValsLoAug}];

   AppendTo[\[Koppa]FuncLifeLo,Interpolation[\[Koppa]DataLo]];
 (* This is a clever way to avoid the mannual linear extrapolation below the first and above the last grid points. *)
  \[Chi]FuncLo=Interpolation[\[Chi]DataLo];
  AppendTo[\[Chi]FuncLifeLo, \[Chi]FuncLo];

  (* Added these lines to set up coefficients for GPU simulation *)
  \[Chi]\[Mu]CoeffsLo = Table[FindCubicSpline[
  \[Mu]VectLoAug[[j]], \[Chi]ValsLoAug[[j]], \[Chi]\[Mu]ValsLoAug[[j]]
, \[Mu]VectLoAug[[j+1]], \[Chi]ValsLoAug[[j+1]], \[Chi]\[Mu]ValsLoAug[[j+1]]]
, {j,1, Length[\[Mu]VectLoAug]-1}
];

  AppendTo[\[Mu]GridsLifeLo, \[Mu]VectLoAug];
  AppendTo[\[Chi]DataLifeLo, \[Chi]DataLo];
  AppendTo[\[Chi]\[Mu]CoeffsLifeLo, \[Chi]\[Mu]CoeffsLo];



(* Final reconciliation of Hi, Md, and Lo*)
    AppendTo[mGridsLifeAll, mVect];
  AppendTo[\[Mu]GridsLifeAll, \[Mu]Vect];
  AppendTo[MdPosLifeAll, {iHighestBelowmCusp, iLowestAbovemCusp}];
  AppendTo[CoeffsLifeAll
, Join[\[Chi]\[Mu]CoeffsLo
, \[ScriptC]\[Kappa]CoeffsMd
, Table[\[Chi]\[Mu]Coeffs[[i]], {i, iLowestAbovemCusp+1, Length[\[Chi]\[Mu]Coeffs]}]
]
];



  If[OptionToCalValFunc==True, 

	AppendTo[\[CapitalChi]FuncLifeHi, \[CapitalChi]Func];
    vCuspt = \[ScriptV]Hi[mCuspt, PeriodsSolved+1];
    vVectLo    = Table[vVect[[i]], {i, 1, iHighestBelowmCusp}];
    vmVectLo   = Table[vmVect[[i]], {i, 1, iHighestBelowmCusp}];
    \[CapitalLambda]VectLo    = Table[\[CapitalLambda]Vect[[i]], {i, 1, iHighestBelowmCusp}];
    \[CapitalLambda]mVectLo   = Table[\[CapitalLambda]mVect[[i]], {i, 1, iHighestBelowmCusp}];


  \[CapitalLambda]DataMd = Table[{{mVect[[i]]}, \[CapitalLambda]Vect[[i]], \[CapitalLambda]mVect[[i]]}
            , {i, iHighestBelowmCusp, iLowestAbovemCusp}];
(* Data for interpolation, matching derivatives. *)
  \[CapitalLambda]FuncMd = Interpolation[\[CapitalLambda]DataMd]; (* Interpolation of mid c function *)
  AppendTo[\[CapitalLambda]FuncLifeMd, \[CapitalLambda]FuncMd];   



(* First we construct the value function for the consumer who consumes according to the TighterUpBd. *)
\[ScriptC]\[Digamma]TighterUpBdVect  =  \[ScriptC]\[Digamma]TighterUpBd[mVectLo, PeriodsSolved+1];
u\[Digamma]TighterUpBdVect  = u[\[ScriptC]\[Digamma]TighterUpBdVect];
a\[Digamma]TighterUpBdVect  =  mVectLo-\[ScriptC]\[Digamma]TighterUpBdVect;
\[GothicV]\[Digamma]TighterUpBdVect  =  \[GothicV]\[Digamma]TighterUpBd[a\[Digamma]TighterUpBdVect, PeriodsSolved+1];
v\[Digamma]TighterUpBdVect  = u\[Digamma]TighterUpBdVect + \[GothicV]\[Digamma]TighterUpBdVect;
vm\[Digamma]TighterUpBdVect  = uP[\[ScriptC]\[Digamma]TighterUpBdVect];

\[CapitalLambda]\[Digamma]TighterUpBdVect  = ((1-\[Rho])v\[Digamma]TighterUpBdVect)^(1/(1-\[Rho]));
\[CapitalLambda]m\[Digamma]TighterUpBdVect  = ((1-\[Rho])v\[Digamma]TighterUpBdVect)^(-1+1/(1-\[Rho]))*vm\[Digamma]TighterUpBdVect;

\[CapitalLambda]\[Digamma]TighterUpBdData=Transpose[{AddBracesTo[mVectLo]
, \[CapitalLambda]\[Digamma]TighterUpBdVect
, \[CapitalLambda]m\[Digamma]TighterUpBdVect}];

\[CapitalLambda]\[Digamma]TighterUpBdFunc=Interpolation[\[CapitalLambda]\[Digamma]TighterUpBdData];
AppendTo[\[CapitalLambda]\[Digamma]TighterUpBdFuncLife, \[CapitalLambda]\[Digamma]TighterUpBdFunc];

(* Now we construct the approximation to the value function of a realist. *)
(** Value function approximation **)
  vVectOptmstLo = v\[Digamma]TighterUpBdVect;
  vVectRealstLo = vVectLo;
  vVectPesmstLo = u[cVectPesmstLo]*vSumt;

  vmVectOptmstLo = uP[cVectOptmstLo];
  vmVectRealstLo = vmVectLo;
  vmVectPesmstLo = uP[cVectPesmstLo];  (* Using Envelope relation uP[c]=vm[m] *)

  \[CapitalLambda]VectOptmstLo = ((1-\[Rho])vVectOptmstLo)^(1/(1-\[Rho]));
  \[CapitalLambda]VectRealstLo = \[CapitalLambda]VectLo;
  \[CapitalLambda]VectPesmstLo = ((1-\[Rho])vVectPesmstLo)^(1/(1-\[Rho]));

  \[CapitalLambda]mVectOptmstLo = ((1-\[Rho])vVectOptmstLo)^(-1+1/(1-\[Rho]))vmVectOptmstLo;
  \[CapitalLambda]mVectRealstLo = \[CapitalLambda]mVectLo;
  \[CapitalLambda]mVectPesmstLo = ((1-\[Rho])vVectPesmstLo)^(-1+1/(1-\[Rho]))vmVectPesmstLo;
(*
  \[CapitalLambda]mVectPesmstLo = Table[\[Kappa]t, {i, 1, Length[mVectLo]}]*(\[DoubleStruckCapitalC]t)^(1/(1-\[Rho]));
*)
  \[CapitalKoppa]ValsLo = (\[CapitalLambda]VectOptmstLo - \[CapitalLambda]VectRealstLo)/(\[CapitalLambda]VectOptmstLo-\[CapitalLambda]VectPesmstLo);
  \[CapitalKoppa]\[Mu]ValsLo = \[FilledUpTriangle]mVectLo ((\[CapitalLambda]mVectOptmstLo - \[CapitalLambda]mVectRealstLo)-\[CapitalKoppa]ValsLo(\[CapitalLambda]mVectOptmstLo - \[CapitalLambda]mVectPesmstLo))/(\[CapitalLambda]VectOptmstLo-\[CapitalLambda]VectPesmstLo);

  \[CapitalChi]ValsLo = Log[(1/\[CapitalKoppa]ValsLo)-1];
  \[CapitalChi]\[Mu]ValsLo = \[CapitalKoppa]\[Mu]ValsLo/((\[CapitalKoppa]ValsLo-1) \[CapitalKoppa]ValsLo);  (* Derivative of \[CapitalChi] wrt \[Mu] *)
  

  \[CapitalKoppa]ValsLoAug=Join[{\[CapitalKoppa]ValsLo[[1]]-\[CapitalKoppa]\[Mu]ValsLo[[1]]*\[Mu]SmallGapLeft}
, \[CapitalKoppa]ValsLo
];
  \[CapitalKoppa]\[Mu]ValsLoAug=Join[{\[CapitalKoppa]\[Mu]ValsLo[[1]]}
, \[CapitalKoppa]\[Mu]ValsLo
];
  \[CapitalChi]ValsLoAug=Join[{\[CapitalChi]ValsLo[[1]]-\[CapitalChi]\[Mu]ValsLo[[1]]*\[Mu]SmallGapLeft}
, \[CapitalChi]ValsLo
];
  \[CapitalChi]\[Mu]ValsLoAug=Join[{\[CapitalChi]\[Mu]ValsLo[[1]]}
, \[CapitalChi]\[Mu]ValsLo
];


  mVectLoAug=Join[{mVectLo[[1]]-mSmallGapLeft}
, mVectLo
];

\[CapitalLambda]VectLoAug=Join[
  {\[CapitalLambda]VectLo[[1]]-\[CapitalLambda]mVectLo[[1]]*mSmallGapLeft}
,  \[CapitalLambda]VectLo
];

\[CapitalLambda]mVectLoAug=Join[
 {\[CapitalLambda]mVectLo[[1]]}
, \[CapitalLambda]mVectLo
];

\[CapitalLambda]DataLo=Transpose[{AddBracesTo[mVectLoAug], \[CapitalLambda]VectLoAug, \[CapitalLambda]mVectLoAug}];
\[CapitalKoppa]DataLo=Transpose[{AddBracesTo[\[Mu]VectLoAug], \[CapitalKoppa]ValsLoAug, \[CapitalKoppa]\[Mu]ValsLoAug}];
\[CapitalChi]DataLo=Transpose[{AddBracesTo[\[Mu]VectLoAug], \[CapitalChi]ValsLoAug, \[CapitalChi]\[Mu]ValsLoAug}];

  AppendTo[\[CapitalLambda]FuncLifeLo,Interpolation[\[CapitalLambda]DataLo,InterpolationOrder->1]];
  AppendTo[\[CapitalKoppa]FuncLifeLo,Interpolation[\[CapitalKoppa]DataLo]];
  \[CapitalChi]FuncLo= Interpolation[\[CapitalChi]DataLo];
  AppendTo[\[CapitalChi]FuncLifeLo,\[CapitalChi]FuncLo];

 ]; (* End of Calculating the value function. *)

];
