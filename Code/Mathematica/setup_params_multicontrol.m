(* ::Package:: *)

(* setup_params _multicontrol.m *)

\[Rho] = 6.;     (* Need high risk aversion to prevent portfolios always > 1 *)
{\[FinalSigma]Min,\[FinalSigma]Max} = {0.,1.};

\[GothicCapitalR]Prm = 1.04;   (* Modest estimate of the equity premium of 4 percent *)
\[GothicR]Prm = Log[\[GothicCapitalR]Prm];
\[GothicR]Std = 0.15;   (* Standard deviation of (log) equity returns *)
\[GothicCapitalR]Vals = RFree \[GothicCapitalR]Prm \[CapitalXi]Vals;
NumOf\[GothicCapitalR]ShkPts = NumOf\[Theta]ShockPts;

\[Sigma]\[Xi] = \[GothicR]Std; (* This is the 'independent' part of the shock to risky returns (independent of \[Theta]) *)

(* 
Parameters needed to construct the equiprobable returns in the case where 
there is correlation between \[Theta] and \[Xi], where the correlation 
is governed by the parameter \[Omega].  

See http://econ.jhu.edu/people/ccarroll/public/lecturenotes/assetpricing/Equiprobable/
for details 
*)
ClearAll[\[Omega]Hat,\[Zeta],\[Omega]];
\[Zeta]=0.5 \[Omega]Hat(1-\[Omega]Hat) \[Sigma]\[Theta]^2;
\[Omega]Hat=(\[Sigma]\[Xi]/\[Sigma]\[Theta])\[Omega]; 
\[Omega] = 0.; (* Default is no correlation between labor and financial shocks *)
