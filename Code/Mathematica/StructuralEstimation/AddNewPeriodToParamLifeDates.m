(* ::Package:: *)

ClearAll[AddNewPeriodToParamLifeDates];

AddNewPeriodToParamLifeDates[\[Rho]_?NumericQ]:= Block[{},

(*** Here is the update from the beginning of period t+1 to the end of period t. ***)
(* Assume that return factor for the latest period matches the riskfree rate *)
AppendTo[RLife, RLifeYoungToOld[[-(PeriodsSolved+1)]]]; 

(* Assume that discount factor for the latest period is \[Beta] *)
AppendTo[\[Beta]Life, \[Beta]LifeYoungToOld[[-(PeriodsSolved+1)]]]; 

(* Assume that growth factor for the latest period is \[Beta] *)
AppendTo[\[ScriptCapitalG]Life, \[ScriptCapitalG]LifeYoungToOld[[-(PeriodsSolved+1)]]]; 

(*** Here we proceed to the end of period t. ***)
(* First we consider whether this period is liquidity constrained
, which is related to whether the consumer is able to borrow against
next period's income. *)

AppendTo[ConstrainedLife
, If[Last[yBorrowableLife]<Last[yMinLife], "Yes", "No"]
];


AppendTo[\[GothicH]AccessibleLife, Last[\[ScriptCapitalG]Life]*(Last[yAccessibleLife]
+Last[\[GothicH]BorrowableLife])/Last[RLife]];

(*
\[GothicH]AccessibleLife is the maximum accessible and its negation is the lower bound for 
cash-on-hand and end-of-period asset.
*)
AppendTo[\[GothicA]LowerBoundLife, -Last[\[GothicH]AccessibleLife]];
AppendTo[mLowerBoundLife, -Last[\[GothicH]AccessibleLife]];

(* \[GothicH] (gothic h) means end-of-period, and h (normal h) means beginning-of-period. *)
(* Expected end-of-period human wealth ('end-of-period': excluding this period's income) *)
AppendTo[\[GothicH]ExpLife, Last[\[ScriptCapitalG]Life] Last[hExpLife]/Last[RLife]];

(* Minimum end-of-period human wealth ('end-of-period': excluding this period's income) *)
AppendTo[\[GothicH]MinLife, Last[\[ScriptCapitalG]Life] Last[hMinLife]/Last[RLife]];

(* Minimum end-of-period human wealth that is borrowable ('end-of-period': 
excluding this period's borrowable income) *)
AppendTo[\[GothicH]BorrowableLife, Last[\[ScriptCapitalG]Life] Last[hBorrowableLife]/Last[RLife]];

(* Difference between expected and minimum human wealth *)
AppendTo[\[FilledUpTriangle]\[GothicH]MinLife, Last[\[GothicH]ExpLife]-Last[\[GothicH]MinLife]];

(* Difference between expected and borrowable human wealth *)
AppendTo[\[FilledUpTriangle]\[GothicH]BorrowableLife, Last[\[GothicH]ExpLife]-Last[\[GothicH]BorrowableLife]];

(* Difference between expected and accessible human wealth *)
AppendTo[\[FilledUpTriangle]\[GothicH]AccessibleLife, Last[\[GothicH]ExpLife]-Last[\[GothicH]AccessibleLife]];

(*** Here we proceed to the middle of period t. ***)
(* yMinLife is a collection of minimum income each period throughout the life cycle 
It could easily accommodate the time-varying unemployment benefits. *)
AppendTo[yMinLife, yMin];

(* yMinBorrowableLife is a collection of borrowable minimum income each period throughout the life cycle.
By assumption, natural borrowing constraint is always present. Hence yMinBorrowable<=yMin.
If yMinBorrowable=yMin, there is only a natural borrowing constraint.
If yMinBorrowable<yMin, there is an artifical borrowing constraint.
For example the usual case of can-not-end-of-negative-asset means yMinBorrowable=0<yMin.
*)
AppendTo[yBorrowableLife, yBorrowable];

AppendTo[yAccessibleLife, Max[Last[yBorrowableLife], Last[yMinLife]] ];

(* yExpLife is a collection of (potentially time-varying) expected income *)
AppendTo[yExpLife, yExp];

(*** Here we proceed to the beginning of period t. ***)
(* Minimum begin-of-period human wealth (including this period's minimum income)    *)
AppendTo[hMinLife, Last[\[GothicH]MinLife]+Last[yMinLife]];

(* Minimum begin-of-period human wealth (including this period's minimum income)    *)
AppendTo[hBorrowableLife, Last[\[GothicH]BorrowableLife]+Last[yBorrowableLife]];

(* Expected begin-of-period human wealth *including* this period's income of 1        *)
AppendTo[hExpLife, Last[\[GothicH]ExpLife]+Last[yExpLife]];


(*** Here are some parameters used in the solution method ***)
(* Formula for MPS is implicit in equation eq:MinMPCInv in BufferStockTheory.tex: *)
AppendTo[\[Lambda]MaxLife,Last[RLife]^((1/\[Rho])-1) Last[\[Beta]Life]^(1/\[Rho])];

(* Formula for discounted value is sum of \[Lambda]s *)
AppendTo[vSumLife,1+Last[vSumLife]Last[\[Lambda]MaxLife]];

(* Formula for min MPC is equation eq:MinMPCInv in BufferStockTheory.tex: *)
AppendTo[\[Kappa]MinLife,1/(1+Last[\[Lambda]MaxLife]/Last[\[Kappa]MinLife])];

(* Formula for max MPC is in BufferStockTheory.tex: *)
AppendTo[\[Kappa]MaxLife,1/(1+\[Theta]Probs[[1]]^(1/\[Rho])*Last[\[Lambda]MaxLife]/Last[\[Kappa]MaxLife])];

];
