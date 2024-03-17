(* ::Package:: *)

(* setup_shocks.m *)

(* Construct the possible values of the shock to income *) 
{\[Theta]Vals,\[Theta]Prob,\[Sharp]OuterPts,CDFOuterPts,\[Sharp]InnerPts,CDFInnerPts} = 
  DiscreteApproxToMeanOneLogNormalWithEdges[\[Sigma]\[Theta],NumOf\[Theta]ShockPts];
