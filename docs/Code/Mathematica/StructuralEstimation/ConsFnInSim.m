(* ::Package:: *)

(* ::Title:: *)
(*Alternative methods for ConsFnInSim*)


(* This file considers alternative consumption functions used in simulating the economy of a large number of people. *)


ClearAll["Global`*"];
SetDirectory[NotebookDirectory[]];
SeedRandom[100]
Off[General::"spell1"]; 
Off[InterpolatingFunction::"dmval"];


(* ::Section:: *)
(*Setup*)


<<setup_ConsFn.m               (* Loading parameters and routines to solve for the age-varying consumption functions *)


<<setup_Sim.m                      (* Loading parameters and routines to compute simulated medians *)


<<setup_Estimation.m      (* Loading "GapEmpiricalSimulatedMedians" function *)


<<SCFdata.m                           (* Loading SCF data *)


(* ::Section:: *)
(*Five Options*)


(* ::Subsection:: *)
(*Construct Shocks*)


VerboseOutput=True;
T0=SessionTime[];
ConstructShockDistribution;  (* Constructs shocks for each agent, function defined in setup_Sim.m *) 
ConstructSimShocks;                    (* Constructs shocks for each agent at each time, function defined in setup_Sim.m  *)
T1=SessionTime[];
If[VerboseOutput==True, Print["Time used (min): ", (T1 - T0)/60];];
(* Around 6.5 minutes for simulating 10000 people
, 0.6 minutes for simulating 1000 people. *)


ListOptionConsFnInSim={{"cInterp"}
, {"cListable", "\[Chi]Listable"}
, {"cVecMoM", "\[Chi]Interp"}
, {"cVecMoM", "\[Chi]Listable"}
, {"cVecMoM", "\[Chi]VecSort"}};


\[Rho]=2;
\[Bet]=1.2;
{ListTime, ListGap, ListwtSimMat}=ConstantArray[Null, {3, Length[ListOptionConsFnInSim]}];
Table[
OptionConsFnInSim=ListOptionConsFnInSim[[OptionLoop]];
T0=SessionTime[]; 
ListGap[[OptionLoop]]=GapEmpiricalSimulatedMedians[\[Rho],\[Bet]];
T1=SessionTime[];
ListTime[[OptionLoop]]=(T1 - T0)/60;
If[VerboseOutput==True, Print[
 "Under Option ", ListOptionConsFnInSim[[OptionLoop]]
, ", Gap: ", ListGap[[OptionLoop]]
, ", Time used (min): ",ListTime[[OptionLoop]]
, "."
];
];
ListwtSimMat[[OptionLoop]]=wtSimMat;
, {OptionLoop, 1, Length[ListOptionConsFnInSim]}];


\[Rho]=5;
\[Bet]=0.99;
{ListTime, ListGap, ListwtSimMat}=ConstantArray[Null, {3, Length[ListOptionConsFnInSim]}];
Table[
OptionConsFnInSim=ListOptionConsFnInSim[[OptionLoop]];
T0=SessionTime[]; 
ListGap[[OptionLoop]]=GapEmpiricalSimulatedMedians[\[Rho],\[Bet]];
T1=SessionTime[];
ListTime[[OptionLoop]]=(T1 - T0)/60;
If[VerboseOutput==True, Print[
 "Under Option ", ListOptionConsFnInSim[[OptionLoop]]
, ", Gap: ", ListGap[[OptionLoop]]
, ", Time used (min): ",ListTime[[OptionLoop]]
, "."
];
];
ListwtSimMat[[OptionLoop]]=wtSimMat;
, {OptionLoop, 1, Length[ListOptionConsFnInSim]}];


(* ::Section:: *)
(*Compare*)


(* Accuracy *)
(* Option {"cListable","\[Chi]Listable"} is the most accurate method. *)
(* The difference in Gaps *)  
 Table[ ListGap[[OptionLoop]]-ListGap[[2]]
, {OptionLoop, 1, Length[ListOptionConsFnInSim]}]
(* The maximal difference in wtSimMat *)  
Table[Max[Abs[ListwtSimMat[[OptionLoop]]-ListwtSimMat[[2]]]
], {OptionLoop, 1, Length[ListOptionConsFnInSim]}]


(* Speed *)
(* Option {"cInterp"} is the most rapid method. *)Table[Max[ListTime[[OptionLoop]]-ListTime[[1]]]
, {OptionLoop, 1, Length[ListOptionConsFnInSim]}]


(* Summary:
There are 5 different ways of obtaining the gap between the simulated
medians and the actual medians. 
Option {"cInterp"} is the least accurate method but fast. 
Option {"cListable","\[Chi]Listable"} is the accurate method but slow. 
Option {"cVecMoM","\[Chi]Interp"} is very close to in Option 1.0 in terms of speed, and also is very close to Option 2.0 in terms of accuracy
*)
(* Conclusion: 
in terms of a tradeoff between accuracy and speed
, Option {"cVecMoM","\[Chi]Interp"} is best. *)
OptionConsFnInSim={"cVecMoM","\[Chi]Interp"};
