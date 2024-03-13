% Data_SCF_wealth_.m
% Data on wealth / permanent income ratio of graduates, SCF

% Load data
load data

% Make sum of weight = 1 in each age group
WealthDens26_30 = WealthDens26_30/sum(WealthDens26_30);
WealthDens31_35 = WealthDens31_35/sum(WealthDens31_35);
WealthDens36_40 = WealthDens36_40/sum(WealthDens36_40);
WealthDens41_45 = WealthDens41_45/sum(WealthDens41_45);
WealthDens46_50 = WealthDens46_50/sum(WealthDens46_50);
WealthDens51_55 = WealthDens51_55/sum(WealthDens51_55);
WealthDens56_60 = WealthDens56_60/sum(WealthDens56_60);

% Compute median and so on in each age group
WealthCum26_30  = WealthCum(WealthDens26_30);
MeanWealthSCF(1,1)   = Wealth26_30*WealthDens26_30';
MedianWealthSCF(1,1) = Wealth26_30(Quantile(WealthCum26_30,0.5));
Top25WealthSCF(1,1)  = Wealth26_30(Quantile(WealthCum26_30,0.25));
Bot25WealthSCF(1,1)  = Wealth26_30(Quantile(WealthCum26_30,0.75));

WealthCum31_35  = WealthCum(WealthDens31_35);
MeanWealthSCF(1,2)   = Wealth31_35*WealthDens31_35';
MedianWealthSCF(1,2) = Wealth31_35(Quantile(WealthCum31_35,0.5));
Top25WealthSCF(1,2)  = Wealth31_35(Quantile(WealthCum31_35,0.25));
Bot25WealthSCF(1,2)  = Wealth31_35(Quantile(WealthCum31_35,0.75));

WealthCum36_40  = WealthCum(WealthDens36_40);
MeanWealthSCF(1,3)   = Wealth36_40*WealthDens36_40';
MedianWealthSCF(1,3) = Wealth36_40(Quantile(WealthCum36_40,0.5));
Top25WealthSCF(1,3)  = Wealth36_40(Quantile(WealthCum36_40,0.25));
Bot25WealthSCF(1,3)  = Wealth36_40(Quantile(WealthCum36_40,0.75));

WealthCum41_45  = WealthCum(WealthDens41_45);
MeanWealthSCF(1,4)   = Wealth41_45*WealthDens41_45';
MedianWealthSCF(1,4) = Wealth41_45(Quantile(WealthCum41_45,0.5));
Top25WealthSCF(1,4)  = Wealth41_45(Quantile(WealthCum41_45,0.25));
Bot25WealthSCF(1,4)  = Wealth41_45(Quantile(WealthCum41_45,0.75));

WealthCum46_50  = WealthCum(WealthDens46_50);
MeanWealthSCF(1,5)   = Wealth46_50*WealthDens46_50';
MedianWealthSCF(1,5) = Wealth46_50(Quantile(WealthCum46_50,0.5));
Top25WealthSCF(1,5)  = Wealth46_50(Quantile(WealthCum46_50,0.25));
Bot25WealthSCF(1,5)  = Wealth46_50(Quantile(WealthCum46_50,0.75));

WealthCum51_55  = WealthCum(WealthDens51_55);
MeanWealthSCF(1,6)   = Wealth51_55*WealthDens51_55';
MedianWealthSCF(1,6) = Wealth51_55(Quantile(WealthCum51_55,0.5));
Top25WealthSCF(1,6)  = Wealth51_55(Quantile(WealthCum51_55,0.25));
Bot25WealthSCF(1,6)  = Wealth51_55(Quantile(WealthCum51_55,0.75));

WealthCum56_60  = WealthCum(WealthDens56_60);
MeanWealthSCF(1,7)   = Wealth56_60*WealthDens56_60';
MedianWealthSCF(1,7) = Wealth56_60(Quantile(WealthCum56_60,0.5));
Top25WealthSCF(1,7)  = Wealth56_60(Quantile(WealthCum56_60,0.25));
Bot25WealthSCF(1,7)  = Wealth56_60(Quantile(WealthCum56_60,0.75));

% Construct population data
WealthPopulationCollege = [Wealth26_30',  ones(length(Wealth26_30),1),WealthDens26_30'*length(WealthDens26_30);...
                           Wealth31_35',2*ones(length(Wealth31_35),1),WealthDens31_35'*length(WealthDens31_35);...
                           Wealth36_40',3*ones(length(Wealth36_40),1),WealthDens36_40'*length(WealthDens36_40);...
                           Wealth41_45',4*ones(length(Wealth41_45),1),WealthDens41_45'*length(WealthDens41_45);...
                           Wealth46_50',5*ones(length(Wealth46_50),1),WealthDens46_50'*length(WealthDens46_50);...
                           Wealth51_55',6*ones(length(Wealth51_55),1),WealthDens51_55'*length(WealthDens51_55);...
                           Wealth56_60',7*ones(length(Wealth56_60),1),WealthDens56_60'*length(WealthDens56_60)];
                            % Unlike Cagetti (2003)'s original data, those who are aged > 60 are dropped 
           
TotalNumOfObs           = length(WealthPopulationCollege); % Total number of observations


   