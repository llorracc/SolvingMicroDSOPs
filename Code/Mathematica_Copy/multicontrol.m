(* ::Package:: *)

(* multicontrol.m *)

<<prepareIntExpFOCInv.m;
<<functions_multicontrol.m;
<<setup_params.m;
<<setup_params_multiperiod.m;
\[GothicA]Max=100.; (* Use large \[GothicA]Max because portfolio choice depends heavily on wealth *)
TimesToNest=3;GridLength=30;<<setup_grids_expMult.m;
<<setup_shocks.m;
<<setup_lastperiod.m;
<<setup_params_multicontrol.m; 
<<setup_shocks_WithRiskyReturns.m;

Constrained=True;

\[GothicC]FuncLife = { Indeterminate & }; (* Consumed function meaningless in last period of life *)

