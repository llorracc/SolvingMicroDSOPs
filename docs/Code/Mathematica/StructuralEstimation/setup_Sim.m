(* ::Package:: *)

(* ::Section:: *)
(*Simulation parameters*)


SimPeople=10000;                                                                   (* Number of people to simulate *)
SimPeriods=60-25;                                                               (* Length of life in simulation (from 25 to 60 years old) *)
(*InitialWYRatio = {0.17, .5, .83}; *)             (* Initial wealth-income ratio (from Cagetti (2003) p .13) *)
Subscript[\[Sigma], WY] = 1.784;  
Subscript[\[Mu], WY] = -2.794;
InitialWYRatio = Exp[Log[DiscreteMeanOneLogNormal[Subscript[\[Sigma], WY],7][[1]]]+Subscript[\[Mu], WY]+1/2*Subscript[\[Sigma], WY]^2];
(* JYao: richer intial WY ratio (from Gourinchas and Parker 2002, Table II). 
We assume initial WY ratio follows a lognormal distribution with mean Subscript[\[Mu], WY] and 
standard deviation Subscript[\[Sigma], WY]. We then discretize the distribution into equiprobable 
5 values *)
OptionConsFnInSim={"cVecMoM", "\[Chi]Interp"};
(* This is the default option
, on which consumption functions will be used in Simulate. *)
(* Details are in functions_ConNVal.m. *)

(* begin{CDCPrivate} *)
OptionConsFnInSim={"cListable", "\[Chi]Listable"};
(* With the TighterUpBd refinement, compute consumptions vectorwise is impossible, 
and we have to do one by one. Hence we repy on the two listable functions.
Details are in functions_ConNValTighterUpBd.m. *)
(* end{CDCPrivate} *)


(* ::Section:: *)
(*Drawing shocks for simulation*)


(* "ConstructShockDistribution" constructs shock distribution (JYao: varying for each time of simulation during working life) *)  
\[Theta]AgeSim[t_] := Block[{\[Sigma]\[Theta]Age,\[Theta]Age,\[Theta]Sim,\[Theta]SimProb},
\[Sigma]\[Theta]Age= \[Sigma]\[Theta][[t]];
UnemployedPeople   = SimPeople \[Mho];
{\[Theta]Sim, \[Theta]SimProb} = DiscreteMeanOneLogNormal[\[Sigma]\[Theta]Age,SimPeople - UnemployedPeople];
\[Theta]Sim=\[Theta]Sim/(1 - \[Mho]);
\[Theta]Sim   = Join[\[Theta]Sim, Table[0,{UnemployedPeople}]];
\[Theta]SimProb = \[Theta]SimProb (1 - \[Mho]) ;
\[Theta]SimProb = Join[\[Theta]SimProb, Table[\[Mho]/UnemployedPeople,{UnemployedPeople}]];
\[Theta]Age = {\[Theta]Sim, \[Theta]SimProb};
Return[\[Theta]Age];
];

\[CapitalPsi]AgeSim[t_] := Block[{\[Sigma]\[CapitalPsi]Age,\[CapitalPsi]Age},
\[Sigma]\[CapitalPsi]Age = \[Sigma]\[CapitalPsi][[t]];
\[CapitalPsi]Age = DiscreteMeanOneLogNormal[\[Sigma]\[CapitalPsi]Age,SimPeople];
Return[\[CapitalPsi]Age];
];    

(* "ConstructSimShocks" constructs simulation shocks for each period and each individual and assigns initial wealth holdings *)
ConstructSimShocks := Block[{},
\[Theta]SimMat=Table[RandomSample[\[Theta]AgeSim[t][[1]]],{t,1,SimPeriods}];
\[CapitalPsi]SimMat=Table[RandomSample[\[CapitalPsi]AgeSim[t][[1]]],{t,1,SimPeriods}];
w0Sim=RandomChoice[InitialWYRatio,SimPeople]               (* Initial wealth to income ratio *)
]; 


(* ::Section:: *)
(*Simulated medians*)


(* ::Subsection:: *)
(*Using CPU*)


(* Computing simulated medians *)
Simulate := Block[{},
Do[FuncToDefine\[ScriptC]VecN\[Chi]Vec[OptionConsFnInSim], {1}];
ClearAll[mtSimMatCPU, ctSimMatCPU, atSimMatCPU, wtSimMatCPU];

mtSimMat= ctSimMat=atSimMat={};
wtSimMat={w0Sim};
Table[
AppendTo[mtSimMat, wtSimMat[[-1]]+\[Theta]SimMat[[t]]];
AppendTo[ctSimMat, \[ScriptC]Vec[mtSimMat[[-1]], PeriodsToSolve+1-t]]; 
AppendTo[atSimMat, (mtSimMat[[-1]]-ctSimMat[[-1]])]; 
AppendTo[wtSimMat,\[DoubleStruckCapitalR]/(\[ScriptCapitalG]Vect[[t]]\[CapitalPsi]SimMat[[t]])*atSimMat[[-1]]],
{t,1,SimPeriods}];
wtSimMat=Drop[wtSimMat,1]; (* Dropping the initial wealth to income *)


SimMedian= Table[Median[Flatten[Table[wtSimMat[[5 (t - 1) + s]], {s, 1, 5}], 1]], {t, 1, 7}];

(* The following three lines are added for comparing CPU and GPU results. *)
If[CPUVsGPUTestOption==True
,
mtSimMatCPU=mtSimMat;
ctSimMatCPU=ctSimMat;
atSimMatCPU=atSimMat;
wtSimMatCPU=wtSimMat;
];
ClearAll[mtSimMat, ctSimMat, atSimMat, wtSimMat];
];


(* ::Subsection:: *)
(*Using GPU*)


CPUVsGPUTestOption=False;


(* MNW: Computes simulated medians using the GPU routine below. *)
SimulateGPU := Block[{},
Do[FuncToDefine\[ScriptC]VecN\[Chi]Vec[OptionConsFnInSim], {1}];
ClearAll[mtSimMatGPU, ctSimMatGPU, atSimMatGPU, wtSimMatGPU];

{mtSimMat, ctSimMat, atSimMat, wtSimMat} = GPUsimFunc[w0Sim];
SimMedian= Table[Median[Flatten[Table[wtSimMat[[5 (t - 1) + s]], {s, 1, 5}], 1]], {t, 1, 7}];

(* The following three lines are added for comparing CPU and GPU results. *)
If[CPUVsGPUTestOption==True
,
mtSimMatGPU=mtSimMat;
ctSimMatGPU=ctSimMat;
atSimMatGPU=atSimMat;
wtSimMatGPU=wtSimMat;
];
ClearAll[mtSimMat, ctSimMat, atSimMat, wtSimMat];

];


(* MNW: This fills in the necessary information to pass to the GPU simulation kernel *)
GPUsimFunc[WealthVec_] := Block[{MoneyVec, ConsVec, AssetVec, NewWealthVec},

WealthMatrix = ConstantArray[0,{SimPeople*SimPeriods}];
MoneyMatrix = ConstantArray[0,{SimPeople*SimPeriods}];
ConsMatrix = ConstantArray[0,{SimPeople*SimPeriods}];
AssetMatrix = ConstantArray[0,{SimPeople*SimPeriods}];

{MoneyVec, ConsVec, AssetVec, NewWealthVec} = GPUkernelSim[
  MoneyMatrix, ConsMatrix, AssetMatrix, WealthMatrix
, WealthVec
, Flatten[\[Theta]SimMat]
, Flatten[\[CapitalPsi]SimMat]
, Flatten[Reverse[Take[\[Mu]GridsLifeAll,-SimPeriods]]]
, Flatten[Reverse[Take[Map[Flatten[#] &, CoeffsLifeAll],-SimPeriods]]]
, Reverse[Take[mHighestBelowmCuspLife,-SimPeriods]]
, Reverse[Take[mLowestAbovemCuspLife,-SimPeriods]]
, Reverse[Take[\[GothicA]LowerBoundLife,-SimPeriods]]
, Reverse[Take[\[FilledUpTriangle]\[GothicH]AccessibleLife,-SimPeriods]]
, Reverse[Take[\[Kappa]MinLife,-SimPeriods]]
, Reverse[Take[\[Kappa]MaxLife,-SimPeriods]]
, Take[\[ScriptCapitalG]Vect,SimPeriods]
];
(* 4 outputs, and 12 inputs *)

Return[{
  Partition[MoneyVec, SimPeople]
, Partition[ConsVec, SimPeople]
, Partition[AssetVec, SimPeople]
, Partition[NewWealthVec, SimPeople]

}];

ClearAll[WealthMatrix
, MoneyMatrix 
, ConsMatrix 
, AssetMatrix];

];


(* MNW: This is the source code for the GPU simulation routine. *)
NGridPoints = \[GothicA]GridN + 1 ;
(* Here NGridPoints=6 *)
(* It is not affected by whether 
we augment the grid at the far-left and the far-right end. *)

SimSrcMulti = "#ifdef USING_DOUBLE_PRECISIONQ
#pragma OPENCL EXTENSION cl_khr_fp64 : enable
#pragma OPENCL EXTENSION cl_amd_fp64 : enable
#endif /* USING_DOUBLE_PRECISIONQ */

__kernel void SimMultiPeriod_kernel(
  __global float * mtSimMatOut
, __global float * ctSimMatOut
, __global float * atSimMatOut
, __global float * wtSimMatOut
, __global float * WealthInit
, __global float * TempShocks
, __global float * PermShocks
, __global float * muGrid
, __global float * Coeffs
, __global float * mHighestBelowVec
, __global float * mLowestAboveVec
, __global float * LowerBound
, __global float * Deltah
, __global float * PFMPCMin
, __global float * PFMPCMax
, __global float * Gamma) {
    int index = get_global_id(0);
    if (index >= " <> ToString[SimPeople] <>") return;
    float Wealth = WealthInit[index];
    int t;
    float Theta;
    float Psi;
    float Bound;
    float Resources; 
    float mHighestBelow; 
    float mLowestAbove; 
    float DeltaM;
    float mu;
    int SegmentStart;
    int ii;
    float b0;
    float b1;
    float b2;
    float b3;
    float chi;
    float Q;
    float Cons;
    float Assets;
    float NextWealth;
    int Loc;
    for (t = 0; t<" <> ToString[SimPeriods] <>"; t++) {
        Loc = t*" <> ToString[SimPeople] <>" + index;
        Theta = TempShocks[Loc];
        Psi = PermShocks[Loc];
        Bound = LowerBound[t];
		mHighestBelow =  mHighestBelowVec[t];
		mLowestAbove  =  mLowestAboveVec[t];
        Resources = Wealth + Theta;
        DeltaM = Resources - Bound;
        mu = log(DeltaM);
        SegmentStart = t*(" <> ToString[NGridPoints] <>"+1)*4;
        for (ii = 0; ii<" <> ToString[NGridPoints] <>"; ii++) {
            if (mu > muGrid[t*" <> ToString[NGridPoints] <>" + ii]) {
				SegmentStart += 4;
            }
        };

        b0 = Coeffs[SegmentStart+0];
        b1 = Coeffs[SegmentStart+1];
        b2 = Coeffs[SegmentStart+2];
        b3 = Coeffs[SegmentStart+3];


        if (  Resources  >= mLowestAbove  )
		{
		chi = b0 + mu*(b1 + mu*(b2 + mu*(b3)));
        Q = 1/(1 + exp(chi));
        Cons = PFMPCMin[t]*(DeltaM + (1 - Q)*Deltah[t]);
		}

        else if (  Resources  <= mHighestBelow  )
		{
        chi = b0 + mu*(b1 + mu*(b2 + mu*(b3)));
        Q = 1/(1 + exp(chi));
        Cons = PFMPCMax[t]*DeltaM -(PFMPCMax[t]-PFMPCMin[t])*DeltaM*Q;
		}

        /*
if (  Resources > mHighestBelow  && Resources < mLowestAbove  )
		*/

		else
{
        Cons = b0 + Resources*(b1 + Resources*(b2 + Resources*(b3)));
        }
		
		Cons = min(Cons, Resources);
        /* 
        This is to impose the 45 degree line constraint. 
        */
		Assets = Resources - Cons;
        NextWealth = Assets*(" <> ToString[\[DoubleStruckCapitalR]] <>"/(Gamma[t]*Psi));
        Wealth = NextWealth;

        mtSimMatOut[Loc]=Resources;
        ctSimMatOut[Loc]=Cons;
        atSimMatOut[Loc]=Assets;
        wtSimMatOut[Loc] = NextWealth;

    }
}";


Needs["OpenCLLink`"];
<<GPUAutomaticDirective.m;


(* MNW: This loads the GPU simulation kernel from the source code in SimSrcMulti. *)
(* CDC: For some machines with Nvidia GPUs, the kernel wrongly tries to compile assuming ATI; the line beginning Defines-> fixes this *)

GPUkernelSim = OpenCLFunctionLoad[SimSrcMulti
, "SimMultiPeriod_kernel"
, {
  {"Float", 1, "Output"}
, {"Float", 1, "Output"}
, {"Float", 1, "Output"}
, {"Float", 1, "Output"}
, {"Float", 1, "Input"}
, {"Float", 1, "Input"}
, {"Float", 1, "Input"}
, {"Float", 1, "Input"}
, {"Float", 1, "Input"}
, {"Float", 1, "Input"}
, {"Float", 1, "Input"}
, {"Float", 1, "Input"}
, {"Float", 1, "Input"}
, {"Float", 1, "Input"}
, {"Float", 1, "Input"}
, {"Float", 1, "Input"}
}
, 100
, "Defines" -> {"USING_OPENCL_FUNCTION"->1,WhichGPUToUse,"mint"->"int","Real_t"->"float"}
, "ShellOutputFunction"->None];
(* 4 outputs, and 12 inputs *)
