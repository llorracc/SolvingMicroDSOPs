(* ::Package:: *)

(* multiperiodCon.m *)


<<setup_workspace.m;
<<setup_params.m;

pUnem=0.005;            (* Probability of unemployment *)
\[Theta]Min=0.05;             (* When unemployed, the unemployment benefit *)

<<setup_params_2period.m;
<<setup_params_multiperiod.m;
<<setup_grids.m;
<<setup_shocks.m;
<<setup_shocks_UnEm.m;

\[Theta]Min=\[Theta]Vals[[1]];
yMin=\[Theta]Min;             (* It is just a change of notation. *)

yExp=1;  (* This is the expected (mean) level of income *)

<<setup_lastperiod.m;
<<setup_definitions.m;
<<setup_PerfectForesightSolution.m;


\[Mu]SmallGapLeft=0.05;
\[Mu]SmallGapRight=0.5;
mRatioSmallGapLeft=0.05;
mRatioSmallGapRight=0.05;
(* This is a small trick, to ensure linear extrapolation outside the grid range. *)
TimesToNest=3;GridLength=10;
(*
TimesToNest=20;GridLength=5;
*)
<<setup_grids_expMult.m;
yBorrowable=0;
<<setup_lastperiod.m;
<<setup_lastperiod_PesReaOpt.m;
<<setup_lastperiod_PesReaOptTighterUpBd.m;
<<setup_lastperiod_PesReaOptTighterUpBdCon.m;
<<setup_PerfectForesightSolutionTighterUpBd.m;

<<prepareIntExpFOCInvPesReaOptTighterUpBdCon.m;
