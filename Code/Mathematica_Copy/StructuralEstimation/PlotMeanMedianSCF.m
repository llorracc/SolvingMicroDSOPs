(* ::Package:: *)

SetDirectory[NotebookDirectory[]];
<<SCFdata.m                                                              (* Loading SCF data and "WeightedMeansMediansSCF" function *)


(* "WeightedMeansMediansSCF" computes weighted means and medians by age group of the wealth to income ratio from SCF data *)
WeightedMeansMediansSCF[SCFdata_]:=Block[{},
SCFbyAgeGroup=Table[Select[SCFdata,#[[2]]==AgeGroup&],{AgeGroup,1,7}];
SCFMeanMedian=Table[
Weights=Round[1000SCFbyAgeGroup[[AgeGroup,All,3]]];SCFreplicated=Flatten[Table[ConstantArray[SCFbyAgeGroup[[AgeGroup,indx,1]],Weights[[indx]]],{indx,1,Length[SCFbyAgeGroup[[AgeGroup]]]}],1];{Mean[SCFreplicated],Median[SCFreplicated]}
,{AgeGroup,1,7}];
SCFMean=SCFMeanMedian[[All,1]];
SCFMedian=SCFMeanMedian[[All,2]];
];


WeightedMeansMediansSCF[SCFdata];
SCFMean
SCFMedian


 PlotMeanMedianSCF=VectLinePlot[{SCFMean,SCFMedian},PlotStyle->{{Black,Dashed,Thickness[0.005]},{Black,Thickness[0.005]}},AxesLabel->{"Age",None},AxesOrigin->{.5,0},Ticks->{{{1,"26-30"},{2,"26-30"},{3,"36-40"},{4,"41-45"},{5,"46-50"},{6,"51-55"},{7,"56-60"}},All}]


Export["../../../Figures/PlotMeanMedianSCF.pdf",PlotMeanMedianSCF];
Export["../../../Figures/PlotMeanMedianSCF.eps",PlotMeanMedianSCF];
