(* ::Package:: *)

(* multiperiodCon_NoModeration.m *)
(* Sets up to solve constrained multiperiod problem without Method of Moderation *)

<<prepareIntExpFOCInv.m;

<<setup_params.m;
<<setup_params_multiperiod.m;
TimesToNest=3;GridLength=10;<<setup_grids_expMult.m;
<<setup_shocks.m;
<<setup_lastperiod.m;
Constrained=True;
