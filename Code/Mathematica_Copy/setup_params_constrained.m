(* ::Package:: *)

(* setup_params _constrained.m *)


yMinAccess=0;
Constrained=If[aMin>-\[Theta]Min
, True
, False
]; (* Liquidity constraint: True or False *)

(* The basical requirement is that we must have aMin>=-\[Theta]Min. This leads to two scenairo
: aMin=-\[Theta]Min, which means the natural liquidity constraint is imposed
 and
 aMin>-\[Theta]Min, which means the artifical liquidity constraint is imposed
.
*)



(*
 Here the "constrained" means whether the artifical liquidity constraint is present. 
If yes, then we first solve the model, assuming that the constraint is binding for future periods onwards
, but not binding at current period (hence we have hMinLife is the discounting next-period-only income)
, then curtail the solution by assuming the constraint becomes binding at current period as well.
If no, the only constraint is the the natural constraint, hence one could borrow all future minimum income.
August 2012, Weifeng Wu added
*)
