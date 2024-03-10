%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               % 
%                                                                          %
% Solving the Next-to-Last Period                                          %
%   - Using interpolation and  exponential grid                            %    
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
%Initialize variables
GothVb = zeros(length(GothicAVec),1)';
vList = zeros(length(GothicAVec),1)';
Consum = zeros(length(GothicAVec),1)';
MinTotWealth = zeros(length(GothicAVec),1)';
%loop for Gothic V
for k=1:length(GothicAVec)
    GothVb(k) = GothicV(GothicAVec(k),Rho,Beta,RFree,Gamma,NumOfThetaShockPoints,ThetaVals);
end
Goth = [(2*GothVb(1)-GothVb(2)) GothVb (mVec(6)-GothicAVec(6))*(GothVb(6)-GothVb(5))/(GothicAVec(6)-GothicAVec(5))+GothVb(6) ];
GothicA = [-GothicAVec(2) GothicAVec mVec(6)];
%loop for consumption and value function
for i = 1:length(mVec)                        %(* Loop optimization routine over mVec; extract maxima and optimal c's *)
    MinTotWealth(i) = mVec(i)+yMinPDV(2)-min(ThetaVals);
    [Consum(i), vList(i)] = fminbnd(@(c) -(u(c,Rho)+interp1(GothicA,Goth,mVec(i)-c)),0.001*MinTotWealth(i),0.999*MinTotWealth(i));
    vList(i) = -vList(i);
end
