(* ::Package:: *)

(* Set up for solution of 2 period model and construction of figures *)
<<setup_workspace.m;
<<setup_params.m;
<<setup_params_2period.m;
<<setup_grids.m;
<<setup_shocks.m;
<<setup_shocks_UnEm.m;

\[Theta]Min=\[Theta]Vals[[1]];
yMin=\[Theta]Min;             (* It is just a change of notation. *)
yBorrowable=yMin;   (* This implies there is only natural borrowing constraint
					, no artifical one.*)
yExp=1;  (* This is the expected (mean) level of income *)

<<setup_lastperiod.m;
<<setup_definitions.m;
<<setup_PerfectForesightSolution.m;
