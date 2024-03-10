(* ::Package:: *)

(* ::Title:: *)
(*Structural estimation*)


(* ::Subsubtitle:: *)
(*This file estimates \[Rho] and \[Bet] for college graduates by matching simulated and empirical medians of the wealth to income ratio across 7 age groups.*)


ClearAll["Global`*"];
OpenFigsUsingShell=True;
If[Length[$FrontEnd] > 0,NBDir=SetDirectory[NotebookDirectory[]];OpenFigsUsingShell=False];
SeedRandom[100];
Off[General::"spell1"]; 
Off[InterpolatingFunction::"dmval"];


ClearAll[PrintMemoryInUse];
PrintMemoryInUse:= Block[{},
Print["Current Memory in Use is: ", N[MemoryInUse[]/1024/1024]," Mb."];
];
PrintMemoryInUse;


(* ::Section:: *)
(*Setup*)


<<setup_ConsFn.m;               (* Load parameters and routines to solve for the age-varying consumption functions *)


<<setup_Sim.m;                      (* Load parameters and routines to compute simulated medians *)


<<setup_Estimation.m;      (* Load "GapEmpiricalSimulatedMedians" function *)


<<SCFdata.m ;                          (* Load SCF data *)


PrintMemoryInUse;


(* ::Section:: *)
(*Estimation*)


VerboseOutput=True;
T0=SessionTime[];
ConstructShockDistribution;  (* Constructs shocks for each agent, function defined in setup_Sim.m *) 
ConstructSimShocks;                    (* Constructs shocks for each agent at each time, function defined in setup_Sim.m  *)
T1=SessionTime[];
If[VerboseOutput==True, Print["Time used (min): ", (T1 - T0)/60];];
(* Around 0.12 minutes for simulating 10000 people under the new analytical method. *)


VerboseOutput=False;
{\[Rho]Min,\[Rho]Guess,\[Rho]Max,\[Bet]Min,\[Bet]Guess,\[Bet]Max}   = {2,4,8,0.85,0.98,1.05};    
(* Boundaries of the search region *)


PrintMemoryInUse;


(* ::Subsection:: *)
(*Using CPU vs GPU: *)


ClearAll[CPUVsGPUFunc];
CPUVsGPUFunc[\[Rho]_,\[Bet]_] := Block[{UseGPU, GapCPU, GapGPU , TimeMatrix, GapMatrix, TimeCPU, TimeGPU
, TEnd1, TStart1
, TEnd2, TStart2
, TEnd3, TStart3},

CPUVsGPUTestOption=True;
VerboseOutput=False;


UseGPU = False;
T0=SessionTime[];
GapCPU=GapEmpiricalSimulatedMedians[\[Rho],\[Bet]];
T1=SessionTime[];
If[VerboseOutput==True, Print["Total Time used (min): ", (T1 - T0)/60]
; Print["GapEmpiricalSimulatedMedians[\[Rho],\[Bet]]=", GapCPU, " under CPU"];
];
TimeCPU={(TEnd1 - TStart1)
, (TEnd2 - TStart2)
, (TEnd3 - TStart3)
,  (T1 - T0)}/60;

 UseGPU = OpenCLQ[];
 If[UseGPU==False
, Print["Error: No GPU supported on this computer!"];
Quit[];
];
T0=SessionTime[];
GapGPU=GapEmpiricalSimulatedMedians[\[Rho],\[Bet]];
T1=SessionTime[];
If[VerboseOutput==True, Print["Total Time used (min): ", (T1 - T0)/60];
;Print["GapEmpiricalSimulatedMedians[\[Rho],\[Bet]]=", GapGPU, " under GPU"];
];
TimeGPU={(TEnd1 - TStart1)
, (TEnd2 - TStart2)
, (TEnd3 - TStart3)
,  (T1 - T0)}/60;


TimeMatrix={{ TimeCPU[[1]], TimeGPU[[1]],TimeCPU[[1]]/ TimeGPU[[1]]}
, { TimeCPU[[2]], TimeGPU[[2]],TimeCPU[[2]]/ TimeGPU[[2]]}
, { TimeCPU[[3]], TimeGPU[[3]],TimeCPU[[3]]/ TimeGPU[[3]]}
, { TimeCPU[[4]], TimeGPU[[4]],TimeCPU[[4]]/ TimeGPU[[4]]}
};
GapMatrix={{GapCPU, GapGPU,(GapGPU-GapCPU)/GapCPU
}};
Print["Running Time Comparison under {\[Rho], \[Bet]}= {", \[Rho], ",", \[Bet], "}:"];
Print[TableForm[TimeMatrix,TableHeadings->{{"SolveConFunc","SimulateEcon","ComputeTheGap", "TotTimeUsed"},{"TimeCPU", "TimeGPU", "TimeCPU/TimeGPU"}}
,TableAlignments->Center,TableSpacing->{1.8,5}]];
Print["Computed Gap Comparison under {\[Rho], \[Bet]}= {", \[Rho], ",",  \[Bet], "}:"];
Print[TableForm[GapMatrix,TableHeadings->{{},{"GapCPU", "GapGPU", "(GapGPU-GapCPU)/GapCPU"}}
,TableAlignments->Center,TableSpacing->{1.8,5}]];
PrintMemoryInUse;
];


(* ::Input:: *)
(*{\[Rho]This,\[Bet]This}={\[Rho]Guess,\[Bet]Guess};*)
(*CPUVsGPUFunc[\[Rho]This,\[Bet]This];*)


{Max[Abs[mtSimMatCPU[[-1]]-mtSimMatGPU[[-1]]]]
, Max[Abs[ctSimMatCPU[[-1]]-ctSimMatGPU[[-1]]]]
, Max[Abs[atSimMatCPU[[-1]]-atSimMatGPU[[-1]]]]
, Max[Abs[wtSimMatCPU[[-1]]-wtSimMatGPU[[-1]]]]}


ClearAll[mtSimMatCPU, ctSimMatCPU, atSimMatCPU, wtSimMatCPU];
ClearAll[mtSimMatGPU, ctSimMatGPU, atSimMatGPU, wtSimMatGPU];
PrintMemoryInUse;


{\[Rho]This,\[Bet]This}={\[Rho]Min,\[Bet]Min};
CPUVsGPUFunc[\[Rho]This,\[Bet]This];
ClearAll[mtSimMatCPU, ctSimMatCPU, atSimMatCPU, wtSimMatCPU];
ClearAll[mtSimMatGPU, ctSimMatGPU, atSimMatGPU, wtSimMatGPU];
PrintMemoryInUse;


{\[Rho]This,\[Bet]This}={\[Rho]Min,\[Bet]Max};
CPUVsGPUFunc[\[Rho]This,\[Bet]This];
ClearAll[mtSimMatCPU, ctSimMatCPU, atSimMatCPU, wtSimMatCPU];
ClearAll[mtSimMatGPU, ctSimMatGPU, atSimMatGPU, wtSimMatGPU];
PrintMemoryInUse;


{\[Rho]This,\[Bet]This}={\[Rho]Max,\[Bet]Min};
CPUVsGPUFunc[\[Rho]This,\[Bet]This];
ClearAll[mtSimMatCPU, ctSimMatCPU, atSimMatCPU, wtSimMatCPU];
ClearAll[mtSimMatGPU, ctSimMatGPU, atSimMatGPU, wtSimMatGPU];
PrintMemoryInUse;


{\[Rho]This,\[Bet]This}={\[Rho]Max,\[Bet]Max};
CPUVsGPUFunc[\[Rho]This,\[Bet]This];
ClearAll[mtSimMatCPU, ctSimMatCPU, atSimMatCPU, wtSimMatCPU];
ClearAll[mtSimMatGPU, ctSimMatGPU, atSimMatGPU, wtSimMatGPU];
PrintMemoryInUse;


(* ::Subsection:: *)
(*Estimate Under CPU:*)


VerboseOutput=False;
UseGPU = False;
CPUVsGPUTestOption=False;
PrintMemoryInUse;


(*
(* Solving for \[Rho] and \[Bet] which minimize the "GapEmpiricalSimulatedMedians" function *)
TimeFMin = SessionTime[];
{min,{steps}} =Reap[FindMinimum[GapEmpiricalSimulatedMedians[\[Rho],\[Bet]],{\[Rho],\[Rho]Guess,\[Rho]Min,\[Rho]Max},{\[Bet],\[Bet]Guess,\[Bet]Min,\[Bet]Max},WorkingPrecision->20, StepMonitor :> Sow[{\[Rho],\[Bet]}]]] 
Print["Time for FindMinimum (min): ", NumberForm[(SessionTime[] - TimeFMin)/60,3]];
(* Old method needs 0.06 minutes for each trial. New method needs 0.40 minutes for each trial. 
Total minutes needed: 50*20 minutes expected. *)
That is too long. Hence I comment this part out. 
*)


(*

\[Rho]Estimate =\[Rho]/.min[[2, 1]];
\[Bet]Estimate =\[Bet]/.min[[2, 2]];

*)


(* ::Subsection:: *)
(*Estimate Under GPU:*)


VerboseOutput=False;
UseGPU = OpenCLQ[];
PrintMemoryInUse;


(* Solving for \[Rho] and \[Bet] which minimize the "GapEmpiricalSimulatedMedians" function *)
TimeFMin = SessionTime[];
{min,{steps}} =Reap[FindMinimum[GapEmpiricalSimulatedMedians[\[Rho],\[Bet]],{\[Rho],\[Rho]Guess,\[Rho]Min,\[Rho]Max},{\[Bet],\[Bet]Guess,\[Bet]Min,\[Bet]Max},WorkingPrecision->20, StepMonitor :> Sow[{\[Rho],\[Bet]}]]] 
Print["Time for FindMinimum (min): ", NumberForm[(SessionTime[] - TimeFMin)/60,3]];
PrintMemoryInUse;
(* Old method needs 0.06 minutes for each trial. New method needs 0.02 minutes for each trial. 
Total minutes needed: 50 minutes or less. *)


(* Solving for \[Rho] and \[Bet] which minimize the "GapEmpiricalSimulatedMedians" function *)
TimeFMin = SessionTime[];
RecordProgress = True;
TriedTheseGuesses = {};
If [UseGPU,
{\[Rho]LB,\[Rho]UB,\[Bet]LB,\[Bet]UB} = MNWgridSearch[\[Rho]Min,\[Rho]Max,\[Bet]Min,\[Bet]Max,15];
{\[Rho]LB2,\[Rho]UB2,\[Bet]LB2,\[Bet]UB2} = MNWgridSearch[\[Rho]LB,\[Rho]UB,\[Bet]LB,\[Bet]UB,15];
\[Rho]Guess = (\[Rho]LB2+\[Rho]UB2)/2;
\[Bet]Guess = (\[Bet]LB2+\[Bet]UB2)/2;
\[Rho]Min = \[Rho]Guess-0.2;
\[Rho]Max = \[Rho]Guess+0.2;
\[Bet]Min = \[Bet]Guess-0.01;
\[Bet]Max = \[Bet]Guess+0.01;
(*
UseGPU = False;
*)
];
{min,{steps}} =Reap[FindMinimum[GapEmpiricalSimulatedMedians[\[Rho],\[Bet]],{\[Rho],\[Rho]Guess,\[Rho]Min,\[Rho]Max},{\[Bet],\[Bet]Guess,\[Bet]Min,\[Bet]Max}, StepMonitor :> Sow[{\[Rho],\[Bet]}]]];
Print["Time for FindMinimum (minutes): ", NumberForm[(SessionTime[] - TimeFMin)/60,3]];
PrintMemoryInUse;
(* Old method needs 0.06 minutes for each trial. New method needs 0.02 minutes for each trial. 
Total minutes needed: 20 minutes. *)


\[Rho]Estimate =\[Rho]/.min[[2, 1]];
\[Bet]Estimate =\[Bet]/.min[[2, 2]];


(* ::Subsection:: *)
(*Contour Plot:*)


UseGPU = OpenCLQ[];
{\[Rho]Min,\[Rho]Max,\[Bet]Min,\[Bet]Max}   = {2,8,0.85,1.05};    


(* Contour plot of the "GapEmpiricalSimulatedMedian" function. With MaxRecursion->1 40 minutes are needed to obtain the contourplot*)
TimeContourPlot = SessionTime[];
ContourPlotMedianStrEst=ContourPlot[GapEmpiricalSimulatedMedians[\[Rho],\[Bet]],{\[Rho],\[Rho]Min,\[Rho]Max},{\[Bet],\[Bet]Min,\[Bet]Max},Mesh->None, MaxRecursion->2,PlotPoints->10,Contours->100];
PlotContourMedianStrEst=Show[{ContourPlotMedianStrEst,
ListPlot[{{\[Rho]Estimate,\[Bet]Estimate}},PlotStyle->Directive[PointSize[Large],Red]]}]
Print["Time for contour plot (min): ", NumberForm[(SessionTime[] - TimeContourPlot)/60,3]] ;
(* Total minutes needed: 90 minutes. *)
PrintMemoryInUse;


Export["../../../Figures/PlotContourMedianStrEst.pdf",PlotContourMedianStrEst];
Export["../../../Figures/PlotContourMedianStrEst.eps",PlotContourMedianStrEst];
If[OpenFigsUsingShell,Run["open ../../../Figures/PlotContourMedianStrEst.pdf"]];


ClearAll[ContourPlotMedianStrEst];
ClearAll[PlotContourMedianStrEst];
PrintMemoryInUse;


(* ::Section:: *)
(*Bootstrap*)


{\[Rho]Min,\[Rho]Max,\[Bet]Min,\[Bet]Max}   = {2,8,0.85,1.05};    


<<setup_Bootstrap.m   (* Loading bootstrap parameters and "Bootstrap" routine *)
(* In the nootstrap.m, we use the method of "principal axis" in the FindMin. This turns out to be better than the "Automatic" method. *)


PrintMemoryInUse;


TimeBootstrap=SessionTime[];
Bootstrap (* Computing standard errors *)


{\[Rho]Min,\[Rho]Guess,\[Rho]Max,\[Bet]Min,\[Bet]Guess,\[Bet]Max}   = {2,4,8,0.85,0.98,1.05};    
