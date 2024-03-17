(* ::Package:: *)

(* functions_Interpolate.m *)
(* Define functions as solved interpolating approximations *)
\[ScriptC][mt_,PeriodsUntilT_] := \[ScriptC]FuncLife[[PeriodsUntilT+1]][mt];

\[Kappa][mt_,PeriodsUntilT_] := \[ScriptC]FuncLife[[PeriodsUntilT+1]]'[mt];

\[ScriptV][mt_,PeriodsUntilT_] := \[ScriptV]FuncLife[[PeriodsUntilT+1]][mt];

SetAttributes[{\[ScriptC],\[Kappa],\[ScriptV]}, Listable]; (* Allows funcs to operate on lists *)
