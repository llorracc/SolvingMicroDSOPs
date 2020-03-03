(* ::Package:: *)

Clear[\[GothicV]\[FinalSigma],\[FinalSigma]Raw,\[GothicV]aOpt,\[GothicV]a,\[GothicV],\[GothicV]aa,\[GothicC],\[GothicC]a];

(* \[DoubleStruckCapitalE] marg value of portfolio share fn \[GothicV]\[FinalSigma]_t(at,\[FinalSigma]t)=\[Beta]Life[[PeriodsSolved]] (1/mn) \[Sum] \[Sum] (Re_{i,j}-RLife[[PeriodsSolved]]) u'(c_{t+1}(Re_{i,j} at + \[Theta]i))*)
\[GothicV]\[FinalSigma][at_?NumericQ, \[FinalSigma]t_?NumericQ, PeriodsUntilT_] := Block[{mtp1,\[DoubleStruckCapitalR],\[GothicCapitalR]},
  If[PeriodsUntilT == 0,(*then*)Return[0.]]; (* No value of risky share in last period *)
  (*else*)
  (\[Beta]Life[[PeriodsUntilT+1]] \[ScriptCapitalG]Life[[PeriodsUntilT+1]]^(-\[Rho]))*Sum[
      \[GothicCapitalR] = RFree \[GothicCapitalR]Prm Exp[\[Zeta]] Exp[\[Omega]Hat Log[\[Theta]Vals[[\[Theta]Loop]]]] \[CapitalXi]Vals[[\[CapitalXi]Loop]]; (* risky return taking into account correlation (if any) with \[Theta] *)
      \[DoubleStruckCapitalR] = RLife[[PeriodsUntilT+1]] + (\[GothicCapitalR] - RLife[[PeriodsUntilT+1]]) \[FinalSigma]t;  (* portfolio return given \[Stigma] *)
      mtp1=at \[DoubleStruckCapitalR]/\[ScriptCapitalG]Life[[PeriodsUntilT+1]] + \[Theta]Vals[[\[Theta]Loop]];
      \[Theta]Prob[[\[Theta]Loop]] \[CapitalXi]Prob[[\[CapitalXi]Loop]] (\[GothicCapitalR]-RLife[[PeriodsUntilT+1]]) uP[\[ScriptC][mtp1,PeriodsUntilT-1]]
  ,{\[Theta]Loop,Length[\[Theta]Vals]}, {\[CapitalXi]Loop,Length[\[CapitalXi]Vals]}        (* Loop over \[Theta]Vals and \[CapitalXi]Vals *)
]                                                      (* End Sum *)
]; (* End Block[] *)

(* \[FinalSigma]Raw calculates optimal portfolio share given level of saving *)
\[FinalSigma]Raw[at_?NumericQ, PeriodsUntilT_] := Block[{\[FinalSigma]Opt},
 If[at <= 0,(*then*)Return[0.]];
  \[FinalSigma]Opt =                        (* \[FinalSigma]Opt is solution to first order condition *)
    (\[FinalSigma] /.                       (* Remove replacement rule "->" from FindRoot result *)
      FindRoot[                 (* Find optimal \[FinalSigma] by rootfinding operation *)
        0. == \[GothicV]\[FinalSigma][at,\[FinalSigma],PeriodsUntilT]          (* First order condition with respect to \[FinalSigma] *)
      ,{\[FinalSigma],0,1}]                 (* Initialize search at 0<\[FinalSigma]<1 *)
    );                          (* End replacement *)
  If[\[FinalSigma]Opt > 1.,\[FinalSigma]Opt = 1.];      (* If \[FinalSigma]*>1, set \[FinalSigma]*=1 *)
  If[\[FinalSigma]Opt < 0.,\[FinalSigma]Opt = 0.];      (* If \[FinalSigma]*<0, set \[FinalSigma]*=0 *)
  Return[\[FinalSigma]Opt]                  (* Returns constrained optimum *)
];                              (* End Block *)

(* Expected marginal value of saving fn \[GothicV]*_t'(at) = \[Beta]Life[[PeriodsSolved]] (1/mn) \[Sum] \[Sum] Re_{i,t+1} u'(c_{t+1}(R_{i,t+1} at + \[Theta]i)) *)
\[GothicV]aOpt[at_?NumericQ,PeriodsUntilT_] := Block[{mtp1,\[FinalSigma]Opt,\[DoubleStruckCapitalR],\[GothicCapitalR]},
  If[PeriodsUntilT == 0,(*then*)Return[0.]];
  (*else*)
  \[FinalSigma]Opt = \[FinalSigma]Raw[at, PeriodsUntilT];   (* Compute and save optimal portfolio share first *)
  Return[
    (\[Beta]Life[[PeriodsUntilT+1]] \[ScriptCapitalG]Life[[PeriodsUntilT+1]]^(-\[Rho]))*Sum[                                          (* Since \[GothicV]*_t'(at) = \[GothicV]a_t(at,\[FinalSigma]*t) by definition *)
      \[GothicCapitalR] = RFree \[GothicCapitalR]Prm Exp[\[Zeta]] Exp[\[Omega]Hat Log[\[Theta]Vals[[\[Theta]Loop]]]] \[CapitalXi]Vals[[\[CapitalXi]Loop]]; (* risky return taking into account correlation (if any) with \[Theta] *)
      \[DoubleStruckCapitalR] = RLife[[PeriodsUntilT+1]] + (\[GothicCapitalR] - RLife[[PeriodsUntilT+1]]) \[FinalSigma]Opt; (* portfolio return given \[Stigma] *)
      mtp1=at \[DoubleStruckCapitalR]/\[ScriptCapitalG]Life[[PeriodsUntilT+1]] + \[Theta]Vals[[\[Theta]Loop]];
        \[Theta]Prob[[\[Theta]Loop]] \[CapitalXi]Prob[[\[CapitalXi]Loop]] \[DoubleStruckCapitalR] uP[\[ScriptC][mtp1,PeriodsUntilT-1]]
    ,{\[Theta]Loop,Length[\[Theta]Vals]} ,{\[CapitalXi]Loop,Length[\[CapitalXi]Vals]}   (* Loop over \[Theta]Vals and \[GothicCapitalR]Vals *)
    ]                                               (* End Sum *)
  ]                                                 (* End Return *)
];                                                  (* End Block *)

\[GothicV]a[at_,PeriodsUntilT_] :=\[GothicV]aOpt[at, PeriodsUntilT];

\[GothicV][at_?NumericQ,PeriodsUntilT_] := Block[{mtp1,\[GothicCapitalR],\[DoubleStruckCapitalR]},
  If[PeriodsUntilT == 0,(*then*)Return[0.]];
  (*else*)
  \[FinalSigma]Opt = \[FinalSigma]Raw[at, PeriodsUntilT];   (* Compute and save optimal portfolio share first *)
  Return[
    (\[Beta]Life[[PeriodsUntilT+1]] \[ScriptCapitalG]Life[[PeriodsUntilT+1]]^(1-\[Rho]))*Sum[                                          (* Since \[GothicV]*_t'(at) = \[GothicV]a_t(at,\[FinalSigma]*t) by definition *)
      \[GothicCapitalR] = RFree \[GothicCapitalR]Prm Exp[\[Zeta]] Exp[\[Omega]Hat Log[\[Theta]Vals[[\[Theta]Loop]]]] \[CapitalXi]Vals[[\[CapitalXi]Loop]]; (* risky return taking into account correlation (if any) with \[Theta] *)
      \[DoubleStruckCapitalR] = RLife[[PeriodsUntilT+1]] + (\[GothicCapitalR] - RLife[[PeriodsUntilT+1]]) \[FinalSigma]Opt; (* portfolio return given \[Stigma] *)
      mtp1=at \[DoubleStruckCapitalR]/\[ScriptCapitalG]Life[[PeriodsUntilT+1]] + \[Theta]Vals[[\[Theta]Loop]];
        \[Theta]Prob[[\[Theta]Loop]] \[CapitalXi]Prob[[\[CapitalXi]Loop]] \[ScriptV][mtp1,PeriodsUntilT-1]
    ,{\[Theta]Loop,Length[\[Theta]Vals]},{\[CapitalXi]Loop,Length[\[CapitalXi]Prob]}    (* Loop over \[Theta]Vals and \[GothicCapitalR]Vals *)
    ]                                               (* End Sum *)
  ]                                                 (* End Return *)
]; (* End Block[]*)

\[GothicV]aa[at_?NumericQ,PeriodsUntilT_] := Block[{mtp1,\[GothicV]aaVal,\[DoubleStruckCapitalR],\[GothicCapitalR]},
  If[PeriodsUntilT == 0,(*then*)Return[0.]];
  (*else*)
  \[FinalSigma]Opt = \[FinalSigma]Raw[at, PeriodsUntilT];                                  (* Compute and save optimal portfolio share first *)
  \[GothicV]aaVal=(\[Beta]Life[[PeriodsUntilT+1]] \[ScriptCapitalG]Life[[PeriodsUntilT+1]]^(-\[Rho]-1))*
  Sum[
      \[GothicCapitalR] = RFree \[GothicCapitalR]Prm Exp[\[Zeta]] Exp[\[Omega]Hat Log[\[Theta]Vals[[\[Theta]Loop]]]] \[CapitalXi]Vals[[\[CapitalXi]Loop]]; (* risky return taking into account correlation (if any) with \[Theta] *)
      \[DoubleStruckCapitalR] = RLife[[PeriodsUntilT+1]] + (\[GothicCapitalR] - RLife[[PeriodsUntilT+1]]) \[FinalSigma]Opt; (* portfolio return given \[Stigma] *)
      mtp1=at \[DoubleStruckCapitalR]/\[ScriptCapitalG]Life[[PeriodsUntilT+1]]+\[Theta]Vals[[\[Theta]Loop]];
      \[Theta]Prob[[\[Theta]Loop]] \[CapitalXi]Prob[[\[CapitalXi]Loop]] \[DoubleStruckCapitalR]^2 uPP[\[ScriptC][mtp1,PeriodsUntilT-1]]*\[Kappa][mtp1,PeriodsUntilT-1]
  ,{\[Theta]Loop,Length[\[Theta]Vals]}, {\[CapitalXi]Loop,Length[\[CapitalXi]Vals]}];
  Return[\[GothicV]aaVal]
];(*End Block[]*)

SetAttributes[{\[GothicV]\[FinalSigma],\[FinalSigma]Raw,\[GothicV]aOpt,\[GothicV]a,\[GothicV],\[GothicV]aa,\[GothicC],\[GothicC]a}, Listable]; (* Allows funcs to operate on lists *)
