function GothicVa = GothicVaMult(a,Rho,BetaLife,RLife,GammaLife,NumOfThetaShockPoints,ThetaVals,PeriodsUntilT,mLowerBoundLife,DeltaGothicHLife,KappaMin,chiIntData,Constrained)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Derivative of Gothic V - Derivative of the value function next period    %
%                                                                          %
%   Inputs:                                                                %
%       a - beginning of period assets                                     %
%       Rho - Coefficient of Relative Risk Aversion                        %
%       BetaLife -  pure time discount factor                              %
%       RLife - Interst Factor (1+r)                                       %
%       GammaLife - Income Growth                                          %
%       NumOfThetaShockPoints - Number of shocks in discrete approx.       %
%       ThetaVals - Value of the shocks                                    %
%		PeriodsUntilT - the period                                  	   %
%		mLowerBoundLife - lower bound of money balances                    %
%		DeltaGothicHLife - excess human wealth 							   %
%		KappaMin - MPC                                                     %
% 		chiIntData - data for interploation of chi value 				   %
%		Constrained - indicator of whether agent is constrained 		   %
%   Outputs:                                                               %
%       GothicVa - Marginal Value function next period                     %
%                                                                          %
%__________________________________________________________________________%

GothicVa=zeros(size(a));
for i=1:length(ThetaVals)
    if PeriodsUntilT == 0;
        GothicVa = 0;
     elseif PeriodsUntilT == 1;
         for j = 1:length(a)
         mtp1 = a(j).*(RLife(PeriodsUntilT+1)./GammaLife(PeriodsUntilT+1))+ThetaVals(i);
         GothicVa(j)=GothicVa(j)+BetaLife(PeriodsUntilT).*((GammaLife(PeriodsUntilT))^(-Rho))*1/NumOfThetaShockPoints*RLife(PeriodsUntilT)*uP(mtp1,Rho);
         end;
    else
        for j = 1:length(a)
        mtp1 = a(j).*(RLife(PeriodsUntilT+1)./GammaLife(PeriodsUntilT+1))+ThetaVals(i);
        con=ScriptC(mtp1,mLowerBoundLife,DeltaGothicHLife,KappaMin,PeriodsUntilT-1,chiIntData,Constrained);
        GothicVa(j)=GothicVa(j)+BetaLife(PeriodsUntilT+1).*((GammaLife(PeriodsUntilT+1))^(-Rho))*1/NumOfThetaShockPoints*RLife(PeriodsUntilT+1)*uP(con,Rho);
        end;
    end
end