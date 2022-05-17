
DoAll.m runs ConstructWIRatio_population.m  which

1) takes averages of observations for each household and 
2) rescales WIRATIO properly. 
This file constructs following three matrices:
 - MeanWIRatio_population:   means of WIRatio (wealth / after tax permanent income ratio) of the population by age group
 - MedianWIRatio_population: medians of WIRatio of the population  by age group
 - WIRatio_population:       household data on WIRatio of the population 

Note:  

The data set /Data/Constructed/SCF1992_2007_population.mat is the matlab data file version of the 
stata data file SCF1992_2007_population.dta produced by the programs in /Code/Stata. 

It should be noted that SCF1992_2007_population.dta cannot yet be used for estimation 
for following two reasons: 

1) Since each household has five (in some cases less than five due to sample selection made 
in step 1 using STATA) observations in this data set, we need to take averages. (The original 
SCF data contains five observations for each household. See SCF codebooks for details.)
2) Since WIRATIO obtained in step 1 using STATA is the ratio of wealth to before tax permanent 
income, not to after tax permanent income, we need to rescale WIRATIO properly.
(Remember that the work in the lecture notes takes parameters from Cagetti (2003) which is based on after tax income.)
 

Current date: August 30, 2011
