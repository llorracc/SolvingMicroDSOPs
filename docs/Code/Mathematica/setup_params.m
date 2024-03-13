(* ::Package:: *)

(* setup_params.m *)

(* Set baseline values of model parameters *)
\[Rho] = 2;                  (* Coefficient of Relative Risk Aversion *)
\[Beta] = 0.96;               (* Discount factor *)
NumOf\[Theta]ShockPts = 7;    (* Number of points in the discrete approximation to lognormal dist *)
\[Sigma]\[Theta] =  0.1;               (* Standard deviation of lognormal distribution; chosen to make figures look good, not for realism *)
rFree=Log[RFree = 1.02];(* Gross and net riskfree interest rate *)
\[ScriptCapitalG] = 1.00;               (* Permanent income growth factor *)

(*
pUnem=0.0.05;            (* Probability of unemployment *)
\[Theta]Min=0.05;             (* When unemployed, the unemployment benefit *)
yMin=\[Theta]Min;             (* It is just a change of notation. *)

yBorrowable=yMin;   (* This implies there is only natural borrowing constraint
						, no artifical one.*)
yExp=1;  (* This is the expected (mean) level of income *)
*)

mMin  = 0;             (* Minimum point in mVec *)
mMax  = 4.;            (* Maximum point in mVec *)
NumOfmPts = 5;         (* Number of points in mVec *)

\[GothicA]Min  = 0.;            (* Lower bound for \[GothicA]Vec *)
\[GothicA]Max  = 4.;            (* Maximum point in \[GothicA]Vec *)
NumOf\[GothicA]Pts = 5;         (* Number of points in \[GothicA]Vec *)

PeriodsSolved = 0; (* Number of periods back from T for which the model has already been solved *)
Constrained = False; (* Liquidity constraint: True or False *)
