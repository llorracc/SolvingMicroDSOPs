(* ::Package:: *)

(* setup_workspace.m *)
Needs["PlotLegends`"];

(* Define functions to construct equiprobable discrete approximation to lognormal *)
(*
The key result on which the approximation rests is the solution to the integral 
that calculates the expectation of the value of a lognormally distributed variable z
in the interval from zMin to zMax.  The solution to this can be verified analytically 
by executing the Mathematica command

Integrate[z PDF[LogNormalDistribution[\[Mu],\[Sigma]],z],{z,zMin,zMax},Assumptions->{zMax-zMin>0&&zMax>0&&zMin>0}]

and that solution
-1/2 E^(\[Mu]+\[Sigma]^2/2) (Erf[(\[Mu]+\[Sigma]^2-Log[zMax])/(Sqrt[2] \[Sigma])]-Erf[(\[Mu]+\[Sigma]^2-Log[zMin])/(Sqrt[2] \[Sigma])])

is directly incorporated into the definition of the function below
*)

ClearAll[DiscreteApproxToMeanOneLogNormal,DiscreteApproxToMeanOneLogNormalWithEdges];

DiscreteApproxToMeanOneLogNormalWithEdges[StdDev_,NumOfPoints_] := Block[{\[Mu],\[Sigma]},
   \[Sigma]=StdDev;
   \[Mu]=-(1/2) \[Sigma]^2;  (* This is the value necessary to make the mean in levels = 1 *)
   \[Sharp]Inner = Table[Quantile[LogNormalDistribution[\[Mu],\[Sigma]],(i/NumOfPoints)],{i,NumOfPoints-1}];
   \[Sharp]Outer = Flatten[{{0}, \[Sharp]Inner,{Infinity}}];
   CDFOuter    = Table[CDF[LogNormalDistribution[\[Mu],\[Sigma]],\[Sharp]Outer[[i]]],{i,1,Length[\[Sharp]Outer]}];
   CDFInner    = Most[Rest[CDFOuter]]; (* Removes first and last elements *)
   MeanPointsProb = Table[CDFOuter[[i]]-CDFOuter[[i-1]],{i,2,Length[\[Sharp]Outer]}];
   MeanPointsVals = Table[
     {zMin,zMax}= {\[Sharp]Outer[[i-1]], \[Sharp]Outer[[i]]};
      -(1/2) E^(\[Mu]+\[Sigma]^2/2) (Erf[(\[Mu]+\[Sigma]^2-Log[zMax])/(Sqrt[2] \[Sigma])]-Erf[(\[Mu]+\[Sigma]^2-Log[zMin])/(Sqrt[2] \[Sigma])]) //N
     ,{i,2,Length[\[Sharp]Outer]}]/MeanPointsProb;
   Return[{MeanPointsVals,MeanPointsProb,\[Sharp]Outer,CDFOuter,\[Sharp]Inner,CDFInner}]
];

DiscreteApproxToMeanOneLogNormal[StdDev_,NumOfPoints_] := Take[DiscreteApproxToMeanOneLogNormalWithEdges[StdDev,NumOfPoints],2];

SetOptions[Plot
    ,PlotStyle->{
     {Black,Thickness[Medium]}
    ,{Black,Thickness[Small],Dashing[Small]}
    ,{Black,Thickness[Large],Dashing[Tiny]}}
   ,BaseStyle -> {FontSize -> 14}
   ,ImageSize->{72 6.,72 6./GoldenRatio}
];

AddBracesTo[\[Bullet]_] := Transpose[{\[Bullet]}]; (* Interpolation[] requires first argument to have braces; this puts braces around its argument list *)

ExportFigs[FigName_,FigBody_] := Block[{},
  Print["Exporting:"<>FigName];
  Export["../../Figures/"<> FigName <> ".eps", ToExpression[FigName], "EPS"];
  Export["../../Figures/"<> FigName <> ".pdf", ToExpression[FigName], "PDF"];
  Export["../../Figures/"<> FigName <> ".png", ToExpression[FigName], "PNG",ImageSize->{72 8.,72 8./GoldenRatio}];
  If[OpenFigsUsingShell != False, Run["open " <> "../../Figures/"<>FigName<>".pdf"]]
(*Export["../../Figures/"<> FigName <> ".svg", ToExpression[FigName], "SVG "]; *)  (* SVG version causes a crash on Windows based systems ! *)
];

