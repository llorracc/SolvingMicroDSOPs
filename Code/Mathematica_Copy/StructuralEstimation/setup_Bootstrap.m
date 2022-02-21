(* ::Package:: *)

(* ::Section:: *)
(*Parameters for bootstrap*)


NumOfBootstrap=20;                       (* Number of bootstrap iterations *)


(* ::Section:: *)
(*Bootstrap routine*)


Bootstrap:=Block[{},
ParamsBootstrap = Table[0, {NumOfBootstrap}, {2}];            (* This table collects the parameter estimates for each bootstrap *)
For[BootstrapLoop  = 1,
BootstrapLoop <= NumOfBootstrap,
Print["Number of bootstrap: ", BootstrapLoop];

(* Drawing new shocks for the simulation *)
(*ConstructShockDistribution; *)(* Constructs shocks for each agent *) 
ConstructSimShocks;                   (* Constructs shocks for each agent at each time *)

(* Random sample with replacement of the data *)
SCFBootstrap=RandomChoice[SCFdata,Length[SCFdata]]; (* Random sample of SCF data *)

(* Estimating the parameters *)
minFMin=Block[{SCFdata},
SCFdata=SCFBootstrap;
FindMinimum[GapEmpiricalSimulatedMediansSecondRound[\[Rho],\[Bet]],{\[Rho],\[Rho]EstimateSecondRound,\[Rho]Min, \[Rho]Max},{\[Bet],\[Bet]EstimateSecondRound,\[Bet]Min,\[Bet]Max},WorkingPrecision->20
(*,Method->"PrincipalAxis"*)]];

Print["\[Rho],\[Bet]: ", {NumberForm[\[Rho] /.minFMin[[2, 1]],3], NumberForm[\[Bet]/.minFMin[[2, 2]],3]}];
Print["Cumulative boostrap time (min): ",NumberForm[(SessionTime[] - TimeBootstrap)/60,3]];
PrintMemoryInUse;
ParamsBootstrap[[BootstrapLoop]] ={\[Rho]/.minFMin[[2, 1]],\[Bet]/.minFMin[[2, 2]]};
ClearAll[\[Theta]SimMat,\[CapitalPsi]SimMat,w0Sim,SCFBootstrap,minFMin];
BootstrapLoop++
];
      
BootStrapSE = Variance[ParamsBootstrap]^0.5;    (* Standard errors *)

(* Displaying results *)
Print["Estimated params: ",ParamsBootstrap//MatrixForm];
Print["Standard errors for {\[Rho],\[Bet]}: ", BootStrapSE];
];
