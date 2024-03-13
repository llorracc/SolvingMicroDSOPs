(* ::Package:: *)

(* multicontrol!Plot.m *)
<<multicontrol.m;

(* 
Solve for portfolio share for someone with no labor income
(which is the limit with labor income as wealth goes to infinity).  
This is the Merton-Samuelson problem; for an exposition, see 
http://econ.jhu.edu/people/ccarroll/public/lecturenotes/assetpricing/Portfolio-CRRA/
*)
MertSamRiskyShareFind := Block[{\[GothicCapitalR],\[DoubleStruckCapitalR]},(RiskyShare /. FindRoot[ 
  0. == Sum[
      \[GothicCapitalR] = RFree \[GothicCapitalR]Prm Exp[\[Zeta]] Exp[\[Omega]Hat Log[\[Theta]Vals[[\[Theta]Loop]]]] \[CapitalXi]Vals[[\[CapitalXi]Loop]]; (* risky return taking into account correlation (if any) with \[Theta] *)
      \[DoubleStruckCapitalR] = RFree + (\[GothicCapitalR] - RFree) RiskyShare;  (* portfolio return given RiskyShare *)
    ((1 + RiskyShare (\[GothicCapitalR]/RFree - 1))^-\[Rho])(\[GothicCapitalR]/RFree - 1) \[CapitalXi]Prob[[\[CapitalXi]Loop]]\[Theta]Prob[[\[Theta]Loop]]
        ,{\[CapitalXi]Loop, Length[\[CapitalXi]Vals]},{\[Theta]Loop, Length[\[Theta]Vals]}]
  , {RiskyShare, 0., 1.}] (*boundaries for FindRoot*))
];
MertSamRiskyShare = MertSamRiskyShareFind;
If[MertSamRiskyShare > 1., MertSamRiskyShare = 1.;Print["Uninteresting problem because Merton-Samuelson Share >= 1"]; Interrupt[]];
If[MertSamRiskyShare < 0., MertSamRiskyShare = 0.];

\[GothicR]=\[GothicR]Prm+rFree;
\[CurlyTheta] = -1+1/\[Beta];
\[Kappa]MertSam = \[GothicR] - (\[GothicR]-\[CurlyTheta])/\[Rho]-(\[Rho]-1)((MertSamRiskyShare^2) (\[Sigma]\[Xi]^2)/2); (* Formula from handout *)
Clear[\[CurlyTheta]]; (* In case it is used again elsewhere *)
(*
CDC 2011/11/19 
I think there's a bug somewhere because with \[Omega] > 0, the portfolio share
and the MPC do not asymptote to the Merton-Samuelson values computed above.
See the Mma notebooks for 
http://econ.jhu.edu/people/ccarroll/public/lecturenotes/assetpricing/C-With-Optimal-Portfolio
, C-With-Optimal-Portfolio.nb 
*)

\[Omega]=0.0;
PeriodsToSolve=100;
Do[SolveAnotherPeriod,{PeriodsToSolve}];

PlotctMultContr = Plot[
      \[ScriptC][m, PeriodsSolved]
    ,{m,mMin,mMax}
    ,ImageSize->{72 6.,72 6./GoldenRatio}
    ,AxesLabel->{"m","c"}
    ,PlotRange->All
];
ExportFigs["PlotctMultContr",PlotctMultContr];
Print[PlotctMultContr];

PlotRiskySharetOfat = Show[
Plot[{\[FinalSigma]Raw[a, PeriodsSolved], MertSamRiskyShare}
     ,{a,\[GothicA]Min,\[GothicA]Max}
    ,ImageSize->{72 6.,72 6./GoldenRatio}
    ,AxesLabel->{"a","\[FinalSigma]"}
    ,AxesOrigin->{0,0}
    ,PlotRange->{{\[GothicA]Min,\[GothicA]Max},{0,1}}
    ,PlotStyle->{Dashing[{}],Dashing[{.01}]}
    ,DisplayFunction->Identity]
,Graphics[Text["Limit as a approaches \[Infinity]", {2.5,MertSamRiskyShare+.1},{-1,-1}]]
,Graphics[Text["\[DownArrow]", {2.5,MertSamRiskyShare+.1},{0,1}]]
,DisplayFunction->$DisplayFunction
];
ExportFigs["PlotRiskySharetOfat",PlotRiskySharetOfat];
Print[PlotRiskySharetOfat];





