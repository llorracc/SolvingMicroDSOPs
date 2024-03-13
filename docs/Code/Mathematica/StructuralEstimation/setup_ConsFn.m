(* ::Package:: *)

(* ::Section:: *)
(*Model Parameters*)


\[DoubleStruckCapitalR]= 1.03;                                   (* Gross interest rate *)
PeriodsToSolve = 90-25;(* Number of periods to iterate the value function. We need consumption fn from 25 to 89 years old *)

{\[GothicA]GridMin,\[GothicA]GridMax,\[GothicA]GridN} = {0.001,4.,5};             (* Saving gridpoints parameters *)


\[Sigma]\[Theta] = Table[0.10,{i,1,PeriodsToSolve}];  (*JYao: Allow for age-varying variance*)
(*\[Sigma]\[Theta] = Join[Table[Sqrt[0.0273],{i,1,33-25}],Table[Sqrt[0.0130],{i,1,52-33}],Table[Sqrt[0.0258],{i,1,65-52}],Table[0.10,{i,1,PeriodsToSolve-(65-25)}]];*) (*JYao: From Karahan&Ozkan2012 *)
(*\[Sigma]\[Theta] = Join[Table[Sqrt[0.0518-0.0405*i/10+0.0105*(i/10)^2-0.0002*(i/10)^3],{i,1,65-25}],Table[0.10,{i,1,PeriodsToSolve-(65-25)}]];*) (*JYao: From Karahan&Ozkan2012, cubic setup *)
\[Sigma]\[CapitalPsi] = Table[0.10,{i,1,PeriodsToSolve}];       (* Standard deviation of lognormal distribution of permanent shocks *)
(*\[Sigma]\[CapitalPsi] = Join[Table[Sqrt[0.0558],{i,1,33-25}],Table[Sqrt[0.0588],{i,1,52-33}],Table[Sqrt[0.0675],{i,1,65-52}],Table[0.10,{i,1,PeriodsToSolve-(65-25)}]];*) (*JYao: From Karahan&Ozkan2012 *)
(*\[Sigma]\[CapitalPsi] = Table[Sqrt[0.0564],{i,1,PeriodsToSolve}];*) (*JYao: Allow for age-varying variance, from Karahan&Ozkan2012*)
\[Mho] = 0.5/100;  (* Probability of zero income *)
NumOf\[Theta]ShockPoints = 6;  (* Number of points of the discrete approximation to lognormal distribution of transitory shocks  *)
NumOf\[CapitalPsi]ShockPoints = 6; (* Number of points of the discrete approximation to
 lognormal distribution of permanent shocks *)


(* ::Subsection:: *)
(*Probability of being alive*)


(* 1st element is the probability of being alive at age 26 (everybody lives at least until age 65) *)
\[ScriptCapitalD]Cancel=Join[ConstantArray[1,40],Flatten[Import["Cagetti2003Data/ProbOfAliveAfterRet.txt","Table"],1]];


(* ::Subsection:: *)
(*Income growth factors*)


(* Income growth factors from Carroll QJE1997 (operatives) *)
\[ScriptCapitalG]Vect=Join[Table[1.025,{indx,1,25}],Table[1.01,{indx,1,15}],{.7},Table[1.0,{indx,1,24}]];


(* ::Subsection:: *)
(*Discount factor correction*)


(* Discount factor corrections for College grads (C), High-School Grads (HS) and No-High-School(NHG) - from Cagetti (2003) *)
\[Beta]hatC=Flatten[Import["Cagetti2003Data/betcorr_college.txt","Table"],1];
\[Beta]hatHS=Flatten[Import["Cagetti2003Data/betcorr_hs.txt","Table"],1];
\[Beta]hatNHS=Flatten[Import["Cagetti2003Data/betcorr_nohigh.txt","Table"],1];


(* Population discount factor correction as simple average of discount factor correction by education groups *)
\[Beta]hat=Drop[Mean[{\[Beta]hatC,\[Beta]hatHS,\[Beta]hatNHS}],-1];


(* ::Subsection:: *)
(*Lifecycle Interest and Income Growth*)


(* Interest factor over the lifecycle *)
RLifeYoungToOld = Table[\[DoubleStruckCapitalR], {i, 1, PeriodsToSolve}];
(* Income growth factor over the lifecycle *)
\[ScriptCapitalG]LifeYoungToOld  = \[ScriptCapitalG]Vect;


(* ::Subsection:: *)
(*Various Options :*)


OptionToCalValFunc=False;
Constrained=True;
atTiny=10^(-6);
OptionPrintNonposAsset=False;

PeriodsSolved = 0; (* Number of periods back from T for which the model has already been solved *)
Constrained = False; (* Liquidity constraint: True or False *)

\[Mu]SmallGapLeft=0.05;
\[Mu]SmallGapRight=0.5;
mRatioSmallGapLeft=0.05;
mRatioSmallGapRight=0.05;
(* This is a small trick, to ensure linear extrapolation outside the grid range. *)


(* ::Section:: *)
(*Gridpoints for end of period savings*)


(* Triple exponential distribution of GridN points between GridMin and GridMax *)
lll\[GothicA]Grid = Table[\[GothicA]Loop,{\[GothicA]Loop,
Log[1 + Log[1 + Log[1 + \[GothicA]GridMin]]],
Log[1 + Log[1 + Log[1 + \[GothicA]GridMax]]],
(Log[1 + Log[1 + Log[1 + \[GothicA]GridMax]]] - Log[1 + Log[1 + Log[1 + \[GothicA]GridMin]]])/(\[GothicA]GridN - 1)
}];
\[GothicA]Grid=Exp[Exp[Exp[lll\[GothicA]Grid]-1]-1]-1//N;
\[GothicA]Vec=\[GothicA]Grid;


(* ::Section:: *)
(*Discrete distribution of shocks*)


(* "DiscreteMeanOneLogNormal" creates discrete approximation to mean one lognormal shocks *)

(* WWu on 2012M04D16: This is the old method using NIntegrate[]. It is slow. *)
(*
 DiscreteMeanOneLogNormal[sigma_?NumericQ,nBins_?NumericQ]:=Block[{\[Mu]=-sigma^2/2},
If[sigma==0.,
BinMeans={1};
BinProbs={1},
ShockDist=LogNormalDistribution[\[Mu],sigma];
EdgePoints=Union[{0},Quantile[ShockDist,Table[i/nBins,{i,nBins-1}]],{\[Infinity]}];
BinMeans=Table[NIntegrate[nBins PDF[ShockDist,x] x,{x,EdgePoints[[i]],EdgePoints[[i+1]]}],{i,nBins}];
BinProbs=Table[1/nBins,{nBins}]];
{BinMeans,BinProbs}];
*)

(* WWu on 2012M04D16: This is the new faster method using analytical solution for the lognormal distribution. Details are on the setup_workspace.m. *)
ClearAll[DiscreteApproxToMeanOneLogNormal,DiscreteApproxToMeanOneLogNormalWithEdges];

DiscreteApproxToMeanOneLogNormalWithEdges[StdDev_,NumOfPoints_] := Block[{\[Mu],\[Sigma]},
   \[Sigma]=StdDev;
   \[Mu]=-(1/2) \[Sigma]^2;  (* This is the value necessary to make the mean in levels = 1 *)
   \[Sharp]Inner = Table[Quantile[LogNormalDistribution[\[Mu],\[Sigma]],(i/NumOfPoints)],{i,NumOfPoints-1}];
   \[Sharp]Outer = Flatten[{{0}, \[Sharp]Inner,{Infinity}}];
   CDFOuter    = Table[CDF[LogNormalDistribution[\[Mu],\[Sigma]],\[Sharp]Outer[[i]]],{i,1,Length[\[Sharp]Outer]}];
   CDFInner    = Most[Rest[CDFOuter]]; (* Removes first and last elements *)
   MeanPointsProb = Table[CDFOuter[[i]]-CDFOuter[[i-1]],{i,2,Length[\[Sharp]Outer]}];
   MeanPointsVals = Table[
     {zMin,zMax}= {\[Sharp]Outer[[i-1]], \[Sharp]Outer[[i]]};
      -(1/2) E^(\[Mu]+\[Sigma]^2/2) (Erf[(\[Mu]+\[Sigma]^2-Log[zMax])/(Sqrt[2] \[Sigma])]-Erf[(\[Mu]+\[Sigma]^2-Log[zMin])/(Sqrt[2] \[Sigma])]) //N
     ,{i,2,Length[\[Sharp]Outer]}]/MeanPointsProb;
   Return[{MeanPointsVals,MeanPointsProb,\[Sharp]Outer,CDFOuter,\[Sharp]Inner,CDFInner}]
];

DiscreteApproxToMeanOneLogNormal[StdDev_,NumOfPoints_] := Take[DiscreteApproxToMeanOneLogNormalWithEdges[StdDev,NumOfPoints],2];

ClearAll[DiscreteMeanOneLogNormal];
DiscreteMeanOneLogNormal[StdDev_,NumOfPoints_] := Block[{},
LevelAdjustingParameter = -(1/2) (StdDev)^2;  (* This parameter takes on the value necessary to make the mean in levels = 1 *)

If[StdDev==0.,
MeanPoints={1};
ProbOfMeanPoints={1},
{MeanPoints,ProbOfMeanPoints}=DiscreteApproxToMeanOneLogNormal[StdDev, NumOfPoints]; 
];
Return[{MeanPoints,ProbOfMeanPoints}];
];


(* Discrete distribution of shocks at each period of life -> used to solve for the policy functions *)

(* JYao: Allow for age-varying variance of shocks *)
\[Theta]AgeYoung[t_] := Block[{\[Sigma]\[Theta]Age,\[Theta]Age,\[Theta]ValsWork,\[Theta]ProbsWork},
\[Sigma]\[Theta]Age= \[Sigma]\[Theta][[t]];
{\[Theta]ValsWork,\[Theta]ProbsWork} = DiscreteMeanOneLogNormal[\[Sigma]\[Theta]Age,NumOf\[Theta]ShockPoints]; 
\[Theta]Age = {\[Theta]ValsWork,\[Theta]ProbsWork};
If[\[Mho]>0,
\[Theta]ValsWork=Prepend[(1/(1-\[Mho])) \[Theta]ValsWork,0];
\[Theta]ProbsWork=Prepend[(1-\[Mho]) \[Theta]ProbsWork,\[Mho]];
\[Theta]Age = {\[Theta]ValsWork,\[Theta]ProbsWork}];
Return[\[Theta]Age];
];

\[Theta]AgeOld[t_] := Block[{\[Sigma]\[Theta]Age,\[Theta]Age,\[Theta]ValsRetire,\[Theta]ProbsRetire},
\[Sigma]\[Theta]Retire=10^(-2)*\[Sigma]\[Theta][[65-(90-65)+t]]; (* Essentially no shocks after retirement *)
\[Mho]Retire=10^(-1)*\[Mho]; 
NumOf\[Theta]ShockPointsRetire=NumOf\[Theta]ShockPoints/6;
{\[Theta]ValsRetire, \[Theta]ProbsRetire}={{1}, {1}};
\[Theta]Age = {\[Theta]ValsRetire,\[Theta]ProbsRetire};
(* DiscreteMeanOneLogNormal[\[Sigma]\[Theta]Retire,NumOf\[Theta]ShockPointsRetire];  *)
If[\[Mho]Retire>0,
\[Theta]ValsRetire=Prepend[(1/(1-\[Mho]Retire)) \[Theta]ValsRetire,0];
\[Theta]ProbsRetire=Prepend[(1-\[Mho]Retire) \[Theta]ProbsRetire, \[Mho]Retire];
\[Theta]Age = {\[Theta]ValsRetire,\[Theta]ProbsRetire}];
Return[\[Theta]Age];
];

\[Theta]MatYoungToOld=Join[Table[\[Theta]AgeYoung[t]
, {t,1,PeriodsToSolve-(90-65)}]
, Table[\[Theta]AgeOld[t]
, {t,1,90-65}]];
\[Theta]Mat=Reverse[\[Theta]MatYoungToOld];

\[CapitalPsi]AgeYoung[t_] := Block[{\[Sigma]\[CapitalPsi]Age,\[CapitalPsi]Age,\[CapitalPsi]ValsWork,\[CapitalPsi]ProbsWork},
\[Sigma]\[CapitalPsi]Age= \[Sigma]\[CapitalPsi][[t]];
\[CapitalPsi]Age = DiscreteMeanOneLogNormal[\[Sigma]\[CapitalPsi]Age,NumOf\[Theta]ShockPoints]; 
Return[\[CapitalPsi]Age];
];

{\[CapitalPsi]ValsRetire, \[CapitalPsi]ProbsRetire}={{1}, {1}}; (* No permanent shocks after retirement *)
\[CapitalPsi]MatYoungToOld=Join[Table[\[CapitalPsi]AgeYoung[t] 
, {t,1,PeriodsToSolve-(90-65)}]
, Table[{\[CapitalPsi]ValsRetire, \[CapitalPsi]ProbsRetire}
, {90-65}]
]; (* No shocks after retirement *)
\[CapitalPsi]Mat=Reverse[\[CapitalPsi]MatYoungToOld];


\[Theta]Min=0;
yMin=\[Theta]Min;             (* It is just a change of notation. *)
yBorrowable=yMin;   (* This implies there is only natural borrowing constraint
					, no artifical one.*)
yExp=1;  (* This is the expected (mean) level of income *)


(* ::Section:: *)
(*Functions*)


AddBracesTo[\[Bullet]_] := Transpose[{\[Bullet]}];
 (* Interpolation[] requires first argument to have braces; this puts braces around its argument list *)

ClearAll[FuncToDefineUtility];
FuncToDefineUtility[\[Rho]_?NumericQ]:=Block[{},

u[c_?NumericQ]  := (c^(1-\[Rho]))/(1-\[Rho]); (* CRRA utility function      *)
uP[c_?NumericQ] := c^-\[Rho] /; c>0.   ;   (* CRRA marginal utility function *)
uP[c_?NumericQ] := Infinity /; c<=0. ;     (* CRRA marginal utility function *)
uPP[c_?NumericQ] := -\[Rho] c^(-\[Rho]-1);    (* CRRA marginal marginal utility function *)
n[z_?NumericQ] :=(z*(1-\[Rho]))^(1/(1-\[Rho]));     (* Define the inverse of the utility function *)
nP[z_?NumericQ] := z^(-1/\[Rho]);        (* Define the inverse function of the utility function *)
SetAttributes[{u,uP,uPP,n,nP},Listable];

];

<<setup_PerfectForesightSolutionTighterUpBd.m;


ClearAll[FuncToSetupLastPeriod];
FuncToSetupLastPeriod[]:=Block[{},

(* Interest factor for last period of life *)
RLife   = { Null };
(* Time preference factor for last period of life *)
\[Beta]Life   = { Null };
(* Income growth factor for last period of life *)
\[ScriptCapitalG]Life = { Null };



(* Lower bound for end-of-period asset and beginning-of-period cash. *)
(* Minimum value of assets with which life might be ended *)
\[GothicA]LowerBoundLife = { 0. };
mLowerBoundLife = { 0. };
(* Whether this period is constrained. *)
(* At T, next period's *)
ConstrainedLife = { "No" };

(* Value of human wealth at end of last period of life *)
\[GothicH]ExpLife           = { 0. };
\[GothicH]MinLife           = { 0. };
\[GothicH]BorrowableLife    = { 0. };
\[GothicH]AccessibleLife    = { 0. };
\[FilledUpTriangle]\[GothicH]MinLife          = { 0. };
\[FilledUpTriangle]\[GothicH]BorrowableLife   = { 0. };
\[FilledUpTriangle]\[GothicH]AccessibleLife   = { 0. };

(* Expected income *)
yExpLife   = { yExp };

(* Minimum income *)
yMinLife = { yMin };

(* The part of minimum income that could be borrowed against *)
yBorrowableLife ={ yBorrowable };

(* How much is accessible for an unconstrained person one period before *)
yAccessibleLife ={ Max[Last[yBorrowableLife], Last[yMinLife]] };

(* Expected human wealth at beg. of per.; 1 in period T reflects that period's inc*)
hExpLife = { yExp };

(* Minimum possible human wealth;occurs if this per.'s inc is min*)
hMinLife = { yMin };

(* Minimum possible human wealth that can be borrowed against one period before *)
hBorrowableLife = { yBorrowable };


(* Marginal propensity to save Last[\[Lambda]Life] in last period of life is 0.   *)
\[Lambda]MaxLife = { 0. };
(* Marginal propensity to consume \[Kappa] in last period of life is 1.   *)
\[Kappa]MinLife = { 1. };
(* Last period consumption function is same as PF in t=T since no uncer remains      *)
vSumLife = { 1. };


(* Marginal propensity to consume \[Kappa]Max in last period of life is 1.   *)
\[Kappa]MaxLife = { 1. }; 

ClearAll[\[ScriptC]FuncLife, \[ScriptV]FuncLife, \[GothicC]FuncLife
, \[GothicV]FuncLife, \[GothicV]aFuncLife, \[GothicV]aaFuncLife 
, \[Koppa]FuncLife, \[Chi]FuncLife, \[Kappa]FuncLife
, \[CapitalKoppa]FuncLife, \[CapitalChi]FuncLife, \[CapitalLambda]FuncLife];

(* Period T means age 90. *)
\[ScriptC]FuncLife =  { # & };
(* Consumption function in last period is to consume everything *)
\[ScriptV]FuncLife = { u };   (* value equals utility because \[ScriptC] = \[ScriptM] *)
\[GothicC]FuncLife = { Indeterminate & }; (* Consumed function meaningless in last period of life *)
\[GothicV]FuncLife = { 0. & };
\[GothicV]aFuncLife  = { 0. & };
\[GothicV]aaFuncLife = { 0. & };
\[Koppa]FuncLife = { Indeterminate & }; (* Not well defined in last period *)
\[Chi]FuncLife = { Indeterminate & }; (* Not well defined in last period *)
\[Kappa]FuncLife = { 1. & };
\[CapitalKoppa]FuncLife = { Indeterminate & }; (* Not well defined in last period *)
\[CapitalChi]FuncLife = { Indeterminate & }; (* Not well defined in last period *)
\[CapitalLambda]FuncLife = { Indeterminate & }; (* Not well defined in last period *)

(* Added these lines to set up coefficients for GPU simulation *)
\[Mu]GridsLife = {Indeterminate & };
\[Chi]DataLife = {Indeterminate & };
\[Chi]\[Mu]CoeffsLife = {Indeterminate & };

(* Added these for TighterUpBd refinement *)
\[FilledUpTriangle]mCuspLife = {Null};
mCuspLife  = {Null}; 
mHighestBelowmCuspLife   = { Null }; (* list of highest value below mCusp *) (* July 13, 2012 KT added *)
mLowestAbovemCuspLife    = { Null }; (* list of lowest value above mCusp *) (* July 13, 2012 KT added *)

\[Koppa]FuncLifeHi = { Indeterminate & }; (* Not well defined in last period *)
\[Chi]FuncLifeHi = { Indeterminate & }; (* Not well defined in last period *)
\[CapitalKoppa]FuncLifeHi = { Indeterminate & }; (* Not well defined in last period *)
\[CapitalChi]FuncLifeHi = { Indeterminate & }; (* Not well defined in last period *)
\[CapitalLambda]FuncLifeHi = { Indeterminate & }; (* Not well defined in last period *)

\[Koppa]FuncLifeLo = { Indeterminate & }; (* Not well defined in last period *)
\[Chi]FuncLifeLo = { Indeterminate & }; (* Not well defined in last period *)
\[CapitalKoppa]FuncLifeLo = { Indeterminate & }; (* Not well defined in last period *)
\[CapitalChi]FuncLifeLo = { Indeterminate & }; (* Not well defined in last period *)
\[CapitalLambda]FuncLifeLo = { Indeterminate & }; (* Not well defined in last period *)

(**)
\[CapitalLambda]\[Digamma]TighterUpBdFuncLife= {  # & }; (* Not well defined in last period *)
\[ScriptC]FuncLifeMd  = { # &}; (* Last period mid consumption function in last period is to consume everything *) 
\[CapitalLambda]FuncLifeMd= { # &};(* Last period mid \[CapitalLambda] function in last period is45 degree line *) 


(* For GPU use *)
\[Mu]GridsLifeLo = {Indeterminate & };
\[Chi]DataLifeLo = {Indeterminate & };
\[Chi]\[Mu]CoeffsLifeLo = {Indeterminate & };

mGridsLifeMd = {Indeterminate & };
\[Mu]GridsLifeMd = {Indeterminate & };
\[ScriptC]DataLifeMd = {Indeterminate & };
\[ScriptC]\[Kappa]CoeffsLifeMd = {Indeterminate & };


(* Final reconciliation of Hi, Md, and Lo*)
MdPosLifeAll = {Indeterminate & };
\[Mu]GridsLifeAll = {Indeterminate & };
mGridsLifeAll = {Indeterminate & };
CoeffsLifeAll = {Indeterminate & };
];


<<functions_stable.m;
<<AddNewPeriodToParamLifeDates.m;
<<AddNewPeriodToSolvedLifeDates.m;
<<AddNewPeriodToSolvedLifeDatesPesReaOpt.m;
<<functions_ConsNVal.m;


SolveAnotherPeriod[\[Rho]_?NumericQ,\[Bet]_?NumericQ] := Block[{},
  Do[AddNewPeriodToParamLifeDates[\[Rho]], {1}];
  Do[AddNewPeriodToSolvedLifeDates[\[Rho]], {1}];
  Do[AddNewPeriodToSolvedLifeDatesPesReaOpt[\[Rho]], {1}];
];



(* begin{CDCPrivate}*)
<<functions_stable.m;
<<AddNewPeriodToParamLifeDates.m;
<<AddNewPeriodToParamLifeDatesTighterUpBd.m;
<<AddNewPeriodToSolvedLifeDates.m;
<<AddNewPeriodToSolvedLifeDatesPesReaOpt.m;
<<AddNewPeriodToSolvedLifeDatesPesReaOptTighterUpBd.m;
<<functions_ConsNValTighterUpBd.m;
(*end{CDCPrivate}*)



(*begin{CDCPrivate}*)
SolveAnotherPeriod[\[Rho]_?NumericQ,\[Bet]_?NumericQ] := Block[{},
  Do[AddNewPeriodToParamLifeDates[\[Rho]], {1}];
  Do[AddNewPeriodToParamLifeDatesTighterUpBd[\[Rho]], {1}];
  Do[AddNewPeriodToSolvedLifeDates[\[Rho]], {1}];
  Do[AddNewPeriodToSolvedLifeDatesPesReaOpt[\[Rho]], {1}];
  Do[AddNewPeriodToSolvedLifeDatesPesReaOptTighterUpBd[\[Rho]], {1}];
];
(*end{CDCPrivate}*)


(* ::Section:: *)
(*Consumption function solution*)


(* "Construct\[ScriptC]FuncLife" constructs the consumption functions at each period of life *)  
Construct\[ScriptC]FuncLife[\[Rho]_?NumericQ, \[Bet]_?NumericQ] := Block[{},
(* Time preference factor over the lifecycle *)

\[Beta]LifeYoungToOld = Table[\[Bet]*\[Beta]hat[[i]]*\[ScriptCapitalD]Cancel[[i]]
, {i, 1, PeriodsToSolve}];
Do[FuncToDefineUtility[\[Rho]], {1}];
Do[FuncToDefine\[GothicV]Func[\[Rho]], {1}];
Do[FuncToDefine\[CapitalLambda]Func[\[Rho]], {1}];
Do[FuncToSetupLastPeriod[], {1}];


For[LifePosn  = 1
, LifePosn <=PeriodsToSolve
, LifePosn++
,

\[Theta]Vals = \[Theta]Mat[[LifePosn, 1]];
\[Theta]Probs = \[Theta]Mat[[LifePosn, 2]];
\[CapitalPsi]Vals = \[CapitalPsi]Mat[[LifePosn, 1]];
\[CapitalPsi]Probs = \[CapitalPsi]Mat[[LifePosn, 2]];
PeriodsSolved=LifePosn-1;
SolveAnotherPeriod[\[Rho],\[Bet]];
] (* End of For Loop *)
]; (* End of Block *)


(* This is the old version of Construct\[ScriptC]FuncLife before 2011/07/04: *)
(*

uP[c_,\[Rho]_] := c^-\[Rho];              (* CRRA - marginal utility of consumption *)
nP[x_,\[Rho]_] :=x^(-1/\[Rho]);        (* CRRA - inverse of marginal utility of consumption *) 

(* Expected marginal value of saving Subscript[\[GothicV], t]'(Subscript[a, t]) = \[Beta] R Subscript[E, t][u'((\[CapitalPsi]\[ScriptCapitalG])Subscript[c, t+1][Subscript[a, t]R/(\[CapitalPsi]\[ScriptCapitalG])+\[Theta]]] *)  
\[GothicV]P[at_,\[Rho]_]:= \[Beta] \[DoubleStruckCapitalR] Sum[\[Theta]VecProb[[\[Theta]Loop]]\[CapitalPsi]VecProb[[\[CapitalPsi]Loop]]uP[\[CapitalPsi]Vec[[\[CapitalPsi]Loop]]\[ScriptCapitalG] Last[\[ScriptC]FuncLife][at \[DoubleStruckCapitalR]/(\[CapitalPsi]Vec[[\[CapitalPsi]Loop]]\[ScriptCapitalG]) + \[Theta]Vec[[\[Theta]Loop]]],\[Rho]],
{\[Theta]Loop,1,Length[\[Theta]Vec]}, {\[CapitalPsi]Loop,1,Length[\[CapitalPsi]Vec]}];  

(* "SolveAnotherPeriod" constructs interpolated consumption function for one period earlier and appends it to \[ScriptC]FuncLife *)
SolveAnotherPeriod[\[Rho]_,\[Bet]_] := Block[{},
AppendTo[\[ScriptC]FuncLife,
Interpolation[                                 (* Constructs interpolated consumption fn by connecting the points (\[Mu],\[Chi]) *)
Union[
Chop[
Prepend[
Table[                                          (* Loop over \[GothicA]GridVec; extracts optimal c's and corresponding m's *)
\[GothicA] = \[GothicA]Grid[[\[GothicA]Loop]];
\[Chi] = nP[\[GothicV]P[\[GothicA],\[Rho]],\[Rho]];      (* First order condition *)
\[Mu] = \[GothicA]+\[Chi];                           
{\[Mu],\[Chi]}
,{\[GothicA]Loop,1,Length[\[GothicA]Grid]}]
,{0.,0.}]                                (* The unemployment risk leads to self imposed borrowing constraint *)
]                                                          (* Chop cuts off numerically insignificant digits *)
]                                                            (* Union removes duplicate entries *)
,InterpolationOrder->1]      (* Piecewise linear interpolation *)
];                                                              (* End of AppendTo *)
];

(* "Construct\[ScriptC]FuncLife" constructs the consumption functions at each period of life *)  
Construct\[ScriptC]FuncLife[\[Rho]_, \[Bet]_] := Block[{},
\[ScriptC]FuncLife = {Interpolation[{{0. , 0. }, {1000. , 1000. }},InterpolationOrder->1]};
For[LifePosn  = 1,
LifePosn <= PeriodsToSolve,
\[Beta] = \[Bet] \[Beta]hat[[PeriodsToSolve-LifePosn+1]]\[ScriptCapitalD]Cancel[[PeriodsToSolve-LifePosn+1]];
\[ScriptCapitalG] = \[ScriptCapitalG]Vect[[PeriodsToSolve-LifePosn+1]];
\[Theta]Vec = \[Theta]Mat[[PeriodsToSolve-LifePosn+1]];
\[CapitalPsi]Vec = \[CapitalPsi]Mat[[PeriodsToSolve-LifePosn+1]];
SolveAnotherPeriod[\[Rho],\[Bet]];
LifePosn  = LifePosn + 1]; 
];

*)


(* MNW: This function finds the coefficients of a cubic function defined at two end points *)
FindCubicSpline[Bot\[Mu]_,Bot\[Chi]_,Bot\[Chi]d\[Mu]_,Top\[Mu]_,Top\[Chi]_,Top\[Chi]d\[Mu]_] := Block[{A,b,X},
(* A = {{1,Bot\[Mu],Bot\[Mu]^2,Bot\[Mu]^3},{1,Top\[Mu],Top\[Mu]^2,Top\[Mu]^3},{0,1,2*Bot\[Mu],3*Bot\[Mu]^2},{0,1,2*Top\[Mu],3*Top\[Mu]^2}};
b = {Bot\[Chi],Top\[Chi],Bot\[Chi]d\[Mu],Top\[Chi]d\[Mu]};
X = LinearSolve[A,b];
Return X; *)
(* Lines above can be condensed into single line below.  No need to solve identical system repeatedly. *)
X = {1/(Bot\[Mu]-Top\[Mu])^3 (3 Bot\[Mu] Bot\[Chi] Top\[Mu]^2-Bot\[Mu]^2 Bot\[Chi]d\[Mu] Top\[Mu]^2-Bot\[Chi] Top\[Mu]^3+Bot\[Mu] Bot\[Chi]d\[Mu] Top\[Mu]^3+Bot\[Mu]^3 Top\[Chi]-3 Bot\[Mu]^2 Top\[Mu] Top\[Chi]-Bot\[Mu]^3 Top\[Mu] Top\[Chi]d\[Mu]+Bot\[Mu]^2 Top\[Mu]^2 Top\[Chi]d\[Mu])
, (-Bot\[Chi]d\[Mu] Top\[Mu]+Bot\[Mu] Top\[Chi]d\[Mu])/(Bot\[Mu]-Top\[Mu])+(3 Bot\[Mu] Top\[Mu] (-2 Bot\[Chi]+Bot\[Mu] Bot\[Chi]d\[Mu]-Bot\[Chi]d\[Mu] Top\[Mu]+2 Top\[Chi]+Bot\[Mu] Top\[Chi]d\[Mu]-Top\[Mu] Top\[Chi]d\[Mu]))/(Bot\[Mu]-Top\[Mu])^3
, 1/(Bot\[Mu]-Top\[Mu])^3 (3 Bot\[Mu] Bot\[Chi]-Bot\[Mu]^2 Bot\[Chi]d\[Mu]+3 Bot\[Chi] Top\[Mu]-Bot\[Mu] Bot\[Chi]d\[Mu] Top\[Mu]+2 Bot\[Chi]d\[Mu] Top\[Mu]^2-3 Bot\[Mu] Top\[Chi]-3 Top\[Mu] Top\[Chi]-2 Bot\[Mu]^2 Top\[Chi]d\[Mu]+Bot\[Mu] Top\[Mu] Top\[Chi]d\[Mu]+Top\[Mu]^2 Top\[Chi]d\[Mu])
, (-2 Bot\[Chi]+Bot\[Mu] Bot\[Chi]d\[Mu]-Bot\[Chi]d\[Mu] Top\[Mu]+2 Top\[Chi]+Bot\[Mu] Top\[Chi]d\[Mu]-Top\[Mu] Top\[Chi]d\[Mu])/(Bot\[Mu]-Top\[Mu])^3};
Return[X];
];


(* MNW: This function finds the coefficients of a linear function defined around one end point. *)
FindLinearSpline[\[Mu]_,\[Chi]_,\[Chi]d\[Mu]_] := Block[{X},
X={\[Chi]-\[Mu] \[Chi]d\[Mu],\[Chi]d\[Mu]};
Return[{X[[1]],X[[2]],0,0}];
];
