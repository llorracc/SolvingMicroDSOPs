(* ::Package:: *)

Print["Use the 'method of moderation' to solve constrained model.'"];
<<2periodIntExpFOCInvPesReaOptTighterUpBdCon.m;                            


cTm1IntExpFOCInvPesReaOptTighterUpBdCon = 
    Plot[{\[ScriptC][m, 1]},{m, -\[GothicH]BorrowableLife[[2]],mMax}
    ,DisplayFunction->Identity
    ];

cTm1IntExpFOCInvPesReaOptTighterUpBd = 
    Plot[{\[ScriptC]From\[Chi][m,1]},{m, -\[GothicH]AccessibleLife[[2]],mMax}
    ,PlotStyle->{Dashing[{0.01}]}
    ,DisplayFunction->Identity
    ];

cVScCon = 
  Show[cTm1IntExpFOCInvPesReaOptTighterUpBdCon,cTm1IntExpFOCInvPesReaOptTighterUpBd
    ,DisplayFunction->$DisplayFunction
    ,AxesLabel->{"\!\(\*SubscriptBox[\(m\), \(T - 1\)]\)","\!\(\*SubscriptBox[\(c\), \(T - 1\)]\)"}
(*    ,PlotLabel->"Comparison of \[ScriptC]Tm1[m] with cTm1FOCInvCon[m]"*)
    ];
ExportFigs["cVScCon",cVScCon];
Print[cVScCon];


















