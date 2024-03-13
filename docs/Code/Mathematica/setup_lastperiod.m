(* ::Package:: *)

(* setup_lastperiod.m *)
(* Construct behavior for last period of life                       *)
(* The sequence of this file is similar to that in AddNewPeriodToParamLifeDates.m. *)

(* Interest factor for last period of life *)
RLife   = { RFree };
(* Time preference factor for last period of life *)
\[Beta]Life   = { \[Beta] };
(* Income growth factor *)
\[ScriptCapitalG]Life   = { \[ScriptCapitalG] };

(* Lower bound for end-of-period asset and beginning-of-period cash. *)
(* Minimum value of assets with which life might be ended *)
\[GothicA]LowerBoundLife = { 0. };
mLowerBoundLife = { 0. };
(* Whether this period is constrained. *)
(* At T, next period's *)
ConstrainedLife = { "Yes" };

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
(* Last period consumption function is same as PF in t=T since no risk remains *)
vSumLife = { 1. };
(* Marginal propensity to consume \[Kappa] in last period of life is 1.   *)
\[Kappa]MinLife = { 1. };

(* Marginal propensity to consume \[Kappa]Max in last period of life is 1.   *)
\[Kappa]MaxLife = { 1. }; 

(* Consumption function in last period is to consume everything *)
\[ScriptC]FuncLife = { # &};
(* Set period-T value function                                      *)
\[ScriptV]FuncLife = {u}; (* value equals utility because \[ScriptC] = \[ScriptM] *)
