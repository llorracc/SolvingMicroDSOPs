function GothicVaa = GothicVaaMult(a,Rho,BetaLife,RLife,GammaLife,NumOfThetaShockPoints,ThetaVals,PeriodsUntilT,mLowerBoundLife,DeltaGothicHLife,KappaMin,chiIntData,Constrained,yExpPDV)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% 2nd Derivative of Gothic V                                               %
%                                                                          %
%   Inputs:                                                                %
%       a - beginning of period assets                                     %
%       Rho - Coefficient of Relative Risk Aversion                        %
%       BetaLife -  pure time discount factor                              %
%       RLife - Interst Factor (1+r)                                       %
%       NumOfThetaShockPoints - Number of shocks in discrete approx.       %
%       ThetaVals - Value of the shocks                                    %
%		PeriodsUntilT - the period                                  	   %
%		mLowerBoundLife - lower bound of money balances                    %
%		DeltaGothicHLife - excess human wealth 							   %
%		KappaMin - MPC                                                     %
% 		chiIntData - data for interploation of chi value 				   %
%		Constrained - indicator of whether agent is constrained 		   %
%		yExpPDV - PDV of income 										   %
%   Outputs:                                                               %
%       GothicVaa - 2nd Derivative of Gothic V                             %
%                                                                          %
%__________________________________________________________________________%

GothicVaa=zeros(size(a)); 
for i=1:length(ThetaVals)
   if PeriodsUntilT == 0;
        GothicVaa = 0;
   elseif PeriodsUntilT == 1;
        mtp1 = (RLife(PeriodsUntilT+1)/GammaLife(PeriodsUntilT+1))*a+ThetaVals(i);
        GothicVaa=GothicVaa+BetaLife(PeriodsUntilT+1).*((GammaLife(PeriodsUntilT+1))^(-Rho-1))*1/NumOfThetaShockPoints*RLife(PeriodsUntilT+1).^2*uPP(mtp1,Rho);
   else
       for j = 1:length(a)
        mtp1 = (RLife(PeriodsUntilT+1)/GammaLife(PeriodsUntilT+1))*a(j)+ThetaVals(i);
        con = ScriptC(mtp1,mLowerBoundLife,DeltaGothicHLife,KappaMin,PeriodsUntilT-1,chiIntData,Constrained);
        kappa = Kappamult(mtp1,mLowerBoundLife,DeltaGothicHLife,KappaMin,PeriodsUntilT-1,chiIntData,Constrained);
        GothicVaa(j)=GothicVaa(j)+BetaLife(PeriodsUntilT+1).*((GammaLife(PeriodsUntilT+1)).^(-Rho-1))*1/NumOfThetaShockPoints*RLife(PeriodsUntilT).^2*uPP(con,Rho).*kappa;
       end
   end
end
