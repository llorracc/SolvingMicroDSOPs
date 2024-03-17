function [mVec vList Consum yExpPDV KappaMin yMinPDV]=cTm1Raw3
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Getting cTm1                                                             %
%	Calculates the value of consumption using optimization.				   %
%                                                                          %
%__________________________________________________________________________%

%================
%   Parameters
%================
setup_params;
%adjsutments needed from standard params
mHuge = 5;
NumOfmPts = 100;
%================
%   Setup Grids
%================
mVec = setup_grids(0,4,100,1);
aVec = setup_grids(GothicAMin,GothicAMax,NumOfGothicAPts,1);
%================
%   Setup Shocks
%================
[ThetaVals ThetaProb] = setup_shocks(NumOfThetaShockPoints,Sigma);
%================
%   Setup Last Period
%================
setup_definitions;
setup_lastperiod;
%construct behavior for one interation back from last period (t=T-1)
yExpPDV(2) = yExpPDV/RFree+1;                   %Expected human wealth including this period's income of 1
yMinPDV(2) = yMinPDV/RFree + min(ThetaVals);    %Minimum human wealth including this period's minimum income
KappaMin(2) = 1/(1+Lambda/KappaMin);                    % MPC in the PF case in the second to last period.
cFuncLife(2) = (KappaMin(2)-1+yExpPDV(2))*KappaMin(2);  % consumption eqauls nonhuman wealth times the MPC in the perfect forsight case if theres' no uncertainty
cf = cF(KappaMin(2),yExpPDV(2),KappaMin(2));
%-------------------------
%determine the optimal c's in T-1
%-------------------------
%initialize values
MinTotWealth = zeros(length(mVec),1);
Consum       = zeros(length(mVec),1);
vList1       = zeros(length(mVec),1);
vList        = zeros(length(mVec),1);
%loops for optimization
for i = 1:length(mVec)
    MinTotWealth(i) = mVec(i) + yMinPDV(2) - min(ThetaVals);
    [Consum(i), vList1(i)] =fzero(@(c) (uP(c,Rho)-GothicVa(mVec(i)-c, Rho,Beta,RFree,Gamma,NumOfThetaShockPoints,ThetaVals)),0.001*MinTotWealth(i),0.999*MinTotWealth(i));
    vList(i)=-vList1(i); 
end