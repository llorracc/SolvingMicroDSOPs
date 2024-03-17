(* ::Package:: *)

SetDirectory[NotebookDirectory[]];
<<setup_ConsFn.m


SetOptions[VectPlot,BaseStyle->{FontSize->15}];


Plot\[Beta]hat=VectPlot[\[Beta]hat,AxesLabel->{"Age","\!\(\*SubscriptBox[OverscriptBox[\(\[Beta]\), \(^\)], \(s + 1\)]\)"},Ticks->{{{5,"30"},{15,"40"},{25,"50"},{35,"60"}
,{45,"70"},{55,"80"},{65,"90"}},All},PlotRange->All,AxesOrigin->{0,.8},PlotStyle->Black]


Plot\[ScriptCapitalG]=VectPlot[\[ScriptCapitalG]Vect,AxesLabel->{"Age","\!\(\*SubscriptBox[\(\[ScriptCapitalG]\), \(s + 1\)]\)"},Ticks->{{{5,"30"},{15,"40"},{25,"50"},{35,"60"}
,{45,"70"},{55,"80"},{65,"90"}},All},PlotRange->All,AxesOrigin->{0,.45},PlotStyle->Black]


Plot\[ScriptCapitalD]Cancel=VectPlot[\[ScriptCapitalD]Cancel,AxesLabel->{"Age","\!\(\*SubscriptBox[\(\[ScriptCapitalD]Cancel\), \(s + 1\)]\)"},Ticks->{{{5,"30"},{15,"40"},{25,"50"},{35,"60"}
,{45,"70"},{55,"80"},{65,"90"}},All},PlotRange->All,AxesOrigin->{0,.6},PlotStyle->Black]


PlotTimeVaryingParam=GraphicsArray[{{Plot\[Beta]hat,Plot\[ScriptCapitalG]},{Plot\[ScriptCapitalD]Cancel}},ImageSize->600]


Export["../../../Figures/PlotTimeVaryingParam.pdf",PlotTimeVaryingParam];
Export["../../../Figures/PlotTimeVaryingParam.eps",PlotTimeVaryingParam];
