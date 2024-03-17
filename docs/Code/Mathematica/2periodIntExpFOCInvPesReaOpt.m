(* ::Package:: *)

(* 2periodIntExpFOCInvPesReaOpt.m *)
(* Use the 'method of moderation' fact:
Pessimist < Realist < Optimist 
(PesReaOpt)
*)
<<setup_everything.m;
\[Mu]SmallGapLeft=0.05;
\[Mu]SmallGapRight=0.5;
mRatioSmallGapLeft=0.05;
mRatioSmallGapRight=0.05;
(* This is a small trick, to ensure linear extrapolation outside the grid range. *)
TimesToNest=20;GridLength=5;
<<setup_grids_expMult.m;
<<setup_lastperiod_PesReaOpt.m;

<<prepareIntExpFOCInvPesReaOpt.m;

SolveAnotherPeriod;
