(* ::Package:: *)

(* Infinite horizon perfect foresight MPS and MPC's *)
(* See BufferStockTheory.tex, eq:MinMPCDef, eq:MinMPSDef *)

\[Lambda]Sup = (1/RFree)(RFree \[Beta])^(1/\[Rho]);
\[Kappa]Inf = (1-\[Lambda]Sup);
\[CapitalThorn]    = (RFree \[Beta])^(1/\[Rho]);
\[CapitalThorn]Ret = \[CapitalThorn]/RFree;

u[c_]  := (c^(1-\[Rho]))/(1-\[Rho]); (* CRRA utility function      *)
uP[c_] := c^-\[Rho] /; c>0.      (* CRRA marginal utility function *)
uP[c_] := Infinity /; c<=0.     (* CRRA marginal utility function *)
uPP[c_] := -\[Rho] c^(-\[Rho]-1);    (* CRRA marginal marginal utility function *)

n[z_] :=(z*(1-\[Rho]))^(1/(1-\[Rho]));     (* Define the inverse of the CRRA utility function *)
nP[z_] := z^(-(1/\[Rho]));        (* Define the inverse function of the CRRA marginal utility function *)
nPP[z_] := (-z/\[Rho])^(-1/(\[Rho]+1));        (* Define the inverse function of the CRRA marginal marginal utility function *)
SetAttributes[{u,uP,uPP,n,nP, nPP},Listable];
