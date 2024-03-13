(* ::Package:: *)

(*
This adjusts for the presence of the unemployment risk and the corresponding benefit.
After the adjustment, the mean of transitory shock is still 1. 
*)


If[pUnem>0,
\[Theta]Vals=Prepend[\[Theta]Min+\[Theta]Vals*(1-\[Theta]Min)/(1-pUnem), \[Theta]Min];
\[Theta]Prob=Prepend[(1-pUnem)*\[Theta]Prob, pUnem];
];
