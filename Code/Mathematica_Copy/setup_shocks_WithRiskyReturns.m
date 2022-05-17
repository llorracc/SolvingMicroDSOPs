(* ::Package:: *)

(* setup_shocks _WithRiskyReturns.m *)

(* 
Constructs equiprobable grid in which the correlation between stock 
returns \[GothicR] labor income \[Theta] is governed by the parameter \[Omega].  
See http://econ.jhu.edu/people/ccarroll/public/lecturenotes/consumption/Equiprobable/
for details 
*)

\[Sigma]\[Xi] = \[GothicR]Std; (* This is the 'independent' part of the shock to risky returns (independent of \[Theta]) *)
{\[CapitalXi]Vals,\[CapitalXi]Prob} =  DiscreteApproxToMeanOneLogNormal[\[Sigma]\[Xi],NumOf\[GothicCapitalR]ShkPts];
\[GothicCapitalR]Prob=\[CapitalXi]Prob;
(*
\[GothicCapitalR]Mat  = RFree \[GothicCapitalR]Prm Exp[\[Zeta]] Table[
    Exp[\[Omega]Hat Log[\[Theta]Vals[[i]]]] \[CapitalXi]Vals[[j]]
  ,{j,Length[\[CapitalXi]Vals]},{i,Length[\[Theta]Vals]}];
*)

