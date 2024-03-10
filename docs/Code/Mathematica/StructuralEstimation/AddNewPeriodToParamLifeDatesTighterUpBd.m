(* ::Package:: *)

ClearAll[
AddNewPeriodToParamLifeDatesTighterUpBd
];

AddNewPeriodToParamLifeDatesTighterUpBd[\[Rho]_?NumericQ]:= Block[{},

(* The point where TighterUpBd intersects with the optimst solution *)
AppendTo[\[FilledUpTriangle]mCuspLife, Last[\[Kappa]MinLife]*Last[\[FilledUpTriangle]\[GothicH]AccessibleLife]/(Last[\[Kappa]MaxLife]-Last[\[Kappa]MinLife])]; 

AppendTo[mCuspLife, Last[\[FilledUpTriangle]mCuspLife]-Last[\[GothicH]AccessibleLife]]; 

];
