% ConstructWIRatio_population.m
% This file constructs following three metrices:
 % MeanWIRatio_population:   means of WIRatio (wealth / after tax permanent income ratio) of the population by age group
 % MedianWIRatio_population: medians of WIRatio of the population by age group
 % WIRatio_population:       household data on WIRatio of the population 

clear all;

% Load data
load "../../../../SCF1992_2007_population";  
Data = data;  % Rename data 
TakeAverageOf5Obs                % Take averages of 5 obs (remember that SCF contains 5 obs for each household)

% Add age class var 
for i=1:length(DataAveraged)
   AgeClass(i,1) = ceil((DataAveraged(i,size(DataAveraged,2))-25)/5);
end
DataAveraged = [DataAveraged,AgeClass];

% Separate mat by age class
WeightPos   = 3; % Position of weight
IncomePos   = 4; % Position of income 
WIRatioPos  = 6; % Position of wealth / permanent income ratio
AgeClassPos = 8; % Position of age class 

WIRatio26_30 = 0; Weight26_30 = 0;
WIRatio31_35 = 0; Weight31_35 = 0;
WIRatio36_40 = 0; Weight36_40 = 0;
WIRatio41_45 = 0; Weight41_45 = 0;
WIRatio46_50 = 0; Weight46_50 = 0;
WIRatio51_55 = 0; Weight51_55 = 0;
WIRatio56_60 = 0; Weight56_60 = 0;
WIRatio61_65 = 0; Weight61_65 = 0;

for i=1:length(DataAveraged)
 % Below, FuncIncomeRatio(DataAveraged(i,IncomePos)) is multiplied in order
 % to rescale WIRatio properly. 
 % We need to do this, since WIRATIO obtained using STATA is the ratio of wealth to before tax permanent income, 
 % not to after tax permanent income.
 % (Remember that the work in the lecture notes takes parameters from Cagetti (2003)
 % which is based on after tax income.)
 if DataAveraged(i,AgeClassPos) == 1
       WIRatio26_30 = [WIRatio26_30,DataAveraged(i,WIRatioPos)*FuncIncomeRatio(DataAveraged(i,IncomePos))];
       Weight26_30  = [Weight26_30,DataAveraged(i,WeightPos)];       
 elseif DataAveraged(i,AgeClassPos) == 2
       WIRatio31_35 = [WIRatio31_35,DataAveraged(i,WIRatioPos)*FuncIncomeRatio(DataAveraged(i,IncomePos))];
       Weight31_35  = [Weight31_35,DataAveraged(i,WeightPos)];      
 elseif DataAveraged(i,AgeClassPos) == 3
       WIRatio36_40 = [WIRatio36_40,DataAveraged(i,WIRatioPos)*FuncIncomeRatio(DataAveraged(i,IncomePos))];
       Weight36_40  = [Weight36_40,DataAveraged(i,WeightPos)];       
 elseif DataAveraged(i,AgeClassPos) == 4
       WIRatio41_45 = [WIRatio41_45,DataAveraged(i,WIRatioPos)*FuncIncomeRatio(DataAveraged(i,IncomePos))];
       Weight41_45  = [Weight41_45,DataAveraged(i,WeightPos)];       
 elseif DataAveraged(i,AgeClassPos) == 5
       WIRatio46_50 = [WIRatio46_50,DataAveraged(i,WIRatioPos)*FuncIncomeRatio(DataAveraged(i,IncomePos))];
       Weight46_50  = [Weight46_50,DataAveraged(i,WeightPos)];       
 elseif DataAveraged(i,AgeClassPos) == 6
       WIRatio51_55 = [WIRatio51_55,DataAveraged(i,WIRatioPos)*FuncIncomeRatio(DataAveraged(i,IncomePos))];
       Weight51_55  = [Weight51_55,DataAveraged(i,WeightPos)];      
 elseif DataAveraged(i,AgeClassPos) == 7
       WIRatio56_60 = [WIRatio56_60,DataAveraged(i,WIRatioPos)*FuncIncomeRatio(DataAveraged(i,IncomePos))];
       Weight56_60  = [Weight56_60,DataAveraged(i,WeightPos)];       
 else
       WIRatio61_65 = [WIRatio61_65,DataAveraged(i,WIRatioPos)*FuncIncomeRatio(DataAveraged(i,IncomePos))];
       Weight61_65  = [Weight61_65,DataAveraged(i,WeightPos)];       
 end
end   

% Drop 0 in the first column
WIRatio26_30 = WIRatio26_30(1,2:end); Weight26_30 = Weight26_30(1,2:end);
WIRatio31_35 = WIRatio31_35(1,2:end); Weight31_35 = Weight31_35(1,2:end);
WIRatio36_40 = WIRatio36_40(1,2:end); Weight36_40 = Weight36_40(1,2:end);
WIRatio41_45 = WIRatio41_45(1,2:end); Weight41_45 = Weight41_45(1,2:end);
WIRatio46_50 = WIRatio46_50(1,2:end); Weight46_50 = Weight46_50(1,2:end);
WIRatio51_55 = WIRatio51_55(1,2:end); Weight51_55 = Weight51_55(1,2:end);
WIRatio56_60 = WIRatio56_60(1,2:end); Weight56_60 = Weight56_60(1,2:end);
WIRatio61_65 = WIRatio61_65(1,2:end); Weight61_65 = Weight61_65(1,2:end);

% Sort data by WIRatio (wealth / after tax permanent income ratio)
[WIRatio26_30 r] = sort(WIRatio26_30);
Weight26_30      = Weight26_30(r);
[WIRatio31_35 r] = sort(WIRatio31_35);
Weight31_35      = Weight31_35(r);
[WIRatio36_40 r] = sort(WIRatio36_40);
Weight36_40      = Weight36_40(r);
[WIRatio41_45 r] = sort(WIRatio41_45);
Weight41_45      = Weight41_45(r);
[WIRatio46_50 r] = sort(WIRatio46_50);
Weight46_50      = Weight46_50(r);
[WIRatio51_55 r] = sort(WIRatio51_55);
Weight51_55      = Weight51_55(r);
[WIRatio56_60 r] = sort(WIRatio56_60);
Weight56_60      = Weight56_60(r);
[WIRatio61_65 r] = sort(WIRatio61_65);
Weight61_65      = Weight61_65(r);

% Make sum of weight = 1
Weight26_30 = Weight26_30/sum(Weight26_30);
Weight31_35 = Weight31_35/sum(Weight31_35);
Weight36_40 = Weight36_40/sum(Weight36_40);
Weight41_45 = Weight41_45/sum(Weight41_45);
Weight46_50 = Weight46_50/sum(Weight46_50);
Weight51_55 = Weight51_55/sum(Weight51_55);
Weight56_60 = Weight56_60/sum(Weight56_60);
Weight61_65 = Weight61_65/sum(Weight61_65);

% Compute mean and median of WIRatio (wealth / after tax permanent income
% ratio) of each age group
MeanWIRatio_population(1,1)   = WIRatio26_30*Weight26_30';
MedianWIRatio_population(1,1) = WIRatio26_30(CalculateMedianPos(Weight26_30));
MeanWIRatio_population(1,2)   = WIRatio31_35*Weight31_35';
MedianWIRatio_population(1,2) = WIRatio31_35(CalculateMedianPos(Weight31_35));
MeanWIRatio_population(1,3)   = WIRatio36_40*Weight36_40';
MedianWIRatio_population(1,3) = WIRatio36_40(CalculateMedianPos(Weight36_40));
MeanWIRatio_population(1,4)   = WIRatio41_45*Weight41_45';
MedianWIRatio_population(1,4) = WIRatio41_45(CalculateMedianPos(Weight41_45));
MeanWIRatio_population(1,5)   = WIRatio46_50*Weight46_50';
MedianWIRatio_population(1,5) = WIRatio46_50(CalculateMedianPos(Weight46_50));
MeanWIRatio_population(1,6)   = WIRatio51_55*Weight51_55';
MedianWIRatio_population(1,6) = WIRatio51_55(CalculateMedianPos(Weight51_55));
MeanWIRatio_population(1,7)   = WIRatio56_60*Weight56_60';
MedianWIRatio_population(1,7) = WIRatio56_60(CalculateMedianPos(Weight56_60));
save MeanWIRatio_population MeanWIRatio_population
save MedianWIRatio_population MedianWIRatio_population 

% Construct final (household) data on WIRatio (wealth / after tax permanent income ratio)
WIRatio_population = [WIRatio26_30',  ones(length(WIRatio26_30),1),Weight26_30'*length(Weight26_30);...
                      WIRatio31_35',2*ones(length(WIRatio31_35),1),Weight31_35'*length(Weight31_35);...
                      WIRatio36_40',3*ones(length(WIRatio36_40),1),Weight36_40'*length(Weight36_40);...
                      WIRatio41_45',4*ones(length(WIRatio41_45),1),Weight41_45'*length(Weight41_45);...
                      WIRatio46_50',5*ones(length(WIRatio46_50),1),Weight46_50'*length(Weight46_50);...
                      WIRatio51_55',6*ones(length(WIRatio51_55),1),Weight51_55'*length(Weight51_55);...
                      WIRatio56_60',7*ones(length(WIRatio56_60),1),Weight56_60'*length(Weight56_60)];
                       % Unlike Cagetti (2003)'s original data, those who are aged > 60 are not contained 
save WIRatio_population WIRatio_population
           