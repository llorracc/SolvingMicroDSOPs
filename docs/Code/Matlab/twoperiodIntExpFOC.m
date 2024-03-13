%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Solving the Next-to-Last Period                                          %
%   -The Approximate Consumption and Value Functions                       %
%                                                                          %
%__________________________________________________________________________%

%================
%   Parameters
%================
setup_params;
%================
%   Setup Grids
%================
mVec = setup_grids(mMin,mMax,NumOfmPts,1);
mVec = [mVec mHuge];
GothicAVec = setup_grids(GothicAMin,GothicAMax,NumOfGothicAPts,1);
GothicAVec = [GothicAVec GothicAHuge];
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
cFuncLife(2) = cF(KappaMin(2),yExpPDV(2),KappaMin(2));  % consumption eqauls nonhuman wealth times the MPC in the perfect forsight case if theres' no uncertainty
%=========================
%determine the optimal c's in T-1
%=========================
%initialize values
MinTotWealth = zeros(length(mVec),1);
ConsumR       = zeros(length(mVec),1);
vList1       = zeros(length(mVec),1);
vList        = zeros(length(mVec),1);
%loop for Gothic V
for k=1:length(GothicAVec)
    dGothV(k) = GothicVa(GothicAVec(k),Rho,Beta,RFree,Gamma,NumOfThetaShockPoints,ThetaVals);
end
%Initialize variables
C = zeros(length(mVec),1)';
C(1)=fzero(@(c) uP(c,Rho)- GothicVaInterp(mVec(1)-c,Rho,Beta,RFree,Gamma,NumOfThetaShockPoints,ThetaVals,mVec,GothicAVec,NumOfGothicAPts), [0.01 1]);
for i=2:length(mVec)                       %(* Loop optimization routine over mVec; extract maxima and optimal c's *)
    C(i)=fzero(@(c) uP(c,Rho)- GothicVaInterp(mVec(i)-c,Rho,Beta,RFree,Gamma,NumOfThetaShockPoints,ThetaVals,mVec,GothicAVec,NumOfGothicAPts), [0.01 mVec(i)]);
end

