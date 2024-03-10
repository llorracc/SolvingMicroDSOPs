function GothicV = GothicVmult(a,Rho,BetaLife,RLife,GammaLife,NumOfThetaShockPoints,ThetaVals,mLowerBoundLife,DeltaGothicHLife,KappaMin,PeriodsUntilT,CapitalChiIntData,thorn,chiIntData,Constrained,GothicCInterpData)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Gothic V - The value function next period                                %
%                                                                          %
%   Inputs:                                                                %
%       a - beginning of period assets                                     %
%       Rho - Coefficient of Relative Risk Aversion                        %
%       BetaLife -  pure time discount factor                              %
%       RLife - Interst Factor (1+r)                                       %
%       GammaLife - Income growth                                          %
%       NumOfThetaShockPoints - Number of shocks in discrete approx.       %
%		ThetaVals - values of theta from the discrete approx. 			   %
%       mLowerBoundLife - Lower bound for money balances                   %
%       DeltaGothicHLife - excess human wealth                             %
%       KappaMin - MPC                                                     %
%       PeriodsUntilT - period                                             %
%       CapitalChiIntData - data for interpolation of Capital Chi          %
%       thorn - Absolute patience factor                                   %
%       chiIntData - data for interpolation of chi                         %
%       Constrained - indicator of whether the individual is constrained   %
%       GothicCInterpData - data for interpolation of Gothic C             %
%   Outputs:                                                               %
%       GothicV - Value function next period                               %
%                                                                          %
%__________________________________________________________________________%

%PeriodsUntilT
GothicV = zeros(size(a));
for j = 1:NumOfThetaShockPoints
    if PeriodsUntilT == 0
        GothicV = 0;
    elseif PeriodsUntilT == 1
        for i = 1:length(a) 
            mtp1 = a(i).*(RLife(PeriodsUntilT+1)./GammaLife(PeriodsUntilT+1)) + ThetaVals(j);
            GothicV(i) = GothicV(i) + u(mtp1,Rho);
        end;
    else
        for i = 1:length(a)
            mtp1 = a(i).*(RLife(PeriodsUntilT+1)./GammaLife(PeriodsUntilT+1)) + ThetaVals(j);
            GothicV(i) = GothicV(i) + v(mtp1,mLowerBoundLife,DeltaGothicHLife,KappaMin,PeriodsUntilT-1,CapitalChiIntData,thorn,Rho,chiIntData,Constrained,GothicCInterpData);
        end
    end
end
GothicV = GothicV.*BetaLife(PeriodsUntilT+1).*((GammaLife(PeriodsUntilT+1)).^(1-Rho)).*(1/NumOfThetaShockPoints);