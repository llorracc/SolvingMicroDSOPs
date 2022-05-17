(* ::Package:: *)

(* ::Title:: *)
(*Alternative methods for FindMinimum*)


ClearAll["Global`*"];
SetDirectory[NotebookDirectory[]];
<<Combinatorica`
SeedRandom[100]
Off[General::"spell1"]; 
Off[InterpolatingFunction::"dmval"];


Developer`SetSystemOptions["EvaluateNumericalFunctionArgument"->False]; (* This is to avoid analytical evaluation *)


(* ::Section:: *)
(*Setup*)


<<setup_ConsFn.m               (* Loading parameters and routines to solve for the age-varying consumption functions *)


<<setup_Sim.m                      (* Loading parameters and routines to compute simulated medians *)


<<setup_Estimation.m      (* Loading "GapEmpiricalSimulatedMedians" function *)


<<SCFdata.m                           (* Loading SCF data *)


First[Timing[ConstructShockDistribution]]  (* Constructs shocks for each agent, function defined in setup_Sim.m *) 


First[Timing[ConstructSimShocks]] (* Constructs shocks for each agent at each time, function defined in setup_Sim.m  *)


{\[Rho]Min,\[Rho]Guess,\[Rho]Max,\[Bet]Min,\[Bet]Guess,\[Bet]Max}   = {2,4,8,0.85,0.98,1.05};            (* Search region boundaries *)


(* ::Subsection:: *)
(*Time required for 1 evaluation of the "GapEmpiricalSimulatedMedians" function*)


First[Timing[GapEmpiricalSimulatedMedians[4,1]]]


(* ::Section:: *)
(*Method->Automatic, WorkingPrecision->Automatic*)


TimeFMin = SessionTime[];
Block[{e=0,s=0},{min,{evaluations}} =Reap[FindMinimum[
GapEmpiricalSimulatedMedians[\[Rho],\[Bet]],{{\[Rho],\[Rho]Guess,\[Rho]Min,\[Rho]Max},{\[Bet],\[Bet]Guess,\[Bet]Min,\[Bet]Max}},EvaluationMonitor:>(e++;Sow[{\[Rho],\[Bet],GapEmpiricalSimulatedMedians[\[Rho],\[Bet]]}]),StepMonitor:>s++]];
Print[s," steps and ",e," evaluations"]];
TimeAutomAutom=(SessionTime[] - TimeFMin)/60;
Print["Time for FindMinimum (min) : ", NumberForm[TimeAutomAutom,3]];
Print["Minimum value ",min[[1]]," at {\[Rho],\[Bet]} = ",min[[2]]]


evaluationsAutomAutom=evaluations;


VectPlot[evaluationsAutomAutom[[All,1;;2]],PlotRange->All]


VectPointPlot3D[evaluationsAutomAutom,PlotRange->All]


(* ::Section:: *)
(*Method->Automatic, WorkingPrecision->20*)


TimeFMin = SessionTime[];
Block[{e=0,s=0},{min,{evaluations}} =Reap[FindMinimum[
GapEmpiricalSimulatedMedians[\[Rho],\[Bet]],{{\[Rho],\[Rho]Guess,\[Rho]Min,\[Rho]Max},{\[Bet],\[Bet]Guess,\[Bet]Min,\[Bet]Max}},WorkingPrecision->20,EvaluationMonitor:>(e++;Sow[{\[Rho],\[Bet],GapEmpiricalSimulatedMedians[\[Rho],\[Bet]]}]),StepMonitor:>s++]];
Print[s," steps and ",e," evaluations"]];
TimeAutomWP20=(SessionTime[] - TimeFMin)/60;
Print["Time for FindMinimum (min) : ", NumberForm[TimeAutomWP20,3]];
Print["Minimum value ",min[[1]]," at {\[Rho],\[Bet]} = ",min[[2]]]


evaluationsAutomWP20=evaluations;


VectPlot[evaluationsAutomWP20[[All,1;;2]],PlotRange->All]


VectPointPlot3D[evaluationsAutomWP20,PlotRange->All]


(* ::Section:: *)
(*Method->PrincipalAxis, WorkingPrecision->20*)


TimeFMin = SessionTime[];
Block[{e=0,s=0},{min,{evaluations}} =Reap[FindMinimum[
GapEmpiricalSimulatedMedians[\[Rho],\[Bet]],{{\[Rho],\[Rho]Guess,\[Rho]Min,\[Rho]Max},{\[Bet],\[Bet]Guess,\[Bet]Min,\[Bet]Max}},WorkingPrecision->20,Method->"PrincipalAxis",EvaluationMonitor:>(e++;Sow[{\[Rho],\[Bet],GapEmpiricalSimulatedMedians[\[Rho],\[Bet]]}]),StepMonitor:>s++]];
Print[s," steps and ",e," evaluations"]];
TimePrAxisWP20=(SessionTime[] - TimeFMin)/60;
Print["Time for FindMinimum (min) : ", NumberForm[TimePrAxisWP20,3]];
Print["Minimum value ",min[[1]]," at {\[Rho],\[Bet]} = ",min[[2]]]


evaluationsPrAxisWP20=evaluations;


VectPlot[evaluationsPrAxisWP20[[All,1;;2]],PlotRange->All]


VectPointPlot3D[evaluationsPrAxisWP20,PlotRange->All]


(* ::Section:: *)
(*Method->Gradient, WorkingPrecision->20*)


TimeFMin = SessionTime[];
Block[{e=0,s=0},{min,{evaluations}} =Reap[FindMinimum[
GapEmpiricalSimulatedMedians[\[Rho],\[Bet]],{{\[Rho],\[Rho]Guess,\[Rho]Min,\[Rho]Max},{\[Bet],\[Bet]Guess,\[Bet]Min,\[Bet]Max}},WorkingPrecision->20,Method->"Gradient",EvaluationMonitor:>(e++;Sow[{\[Rho],\[Bet],GapEmpiricalSimulatedMedians[\[Rho],\[Bet]]}]),StepMonitor:>s++]];
Print[s," steps and ",e," evaluations"]];
TimeGradientWP20=(SessionTime[] - TimeFMin)/60;
Print["Time for FindMinimum (min) : ", NumberForm[TimeGradientWP20,3]];
Print["Minimum value ",min[[1]]," at {\[Rho],\[Bet]} = ",min[[2]]]


evaluationsGradientWP20=evaluations;


VectPlot[evaluationsGradientWP20[[All,1;;2]],PlotRange->All]


VectPointPlot3D[evaluationsGradientWP20,PlotRange->All]


(* ::Section:: *)
(*Summary (\[Rho], \[Bet],GapEmpiricalSimulatedMedians[\[Rho], \[Bet]],minutes)*)


{NumberForm[Last[evaluationsAutomAutom],10],{NumberForm[TimeAutomAutom,3]}} (* Method->Automatic, WorkingPrecision-> Automatic *)


{NumberForm[Last[evaluationsAutomWP20],10],{NumberForm[TimeAutomWP20,3]}}(* Method->Automatic, WorkingPrecision-> 20 *)


{NumberForm[Last[evaluationsPrAxisWP20],10],{NumberForm[TimePrAxisWP20,3]}}(* Method->PrincipalAxis, WorkingPrecision-> 20 *)


{NumberForm[Last[evaluationsGradientWP20],10],{NumberForm[TimeGradientWP20,3]}}(* Method->Gradient, WorkingPrecision-> 20 *)
