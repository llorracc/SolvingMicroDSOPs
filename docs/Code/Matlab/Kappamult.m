function kappamult = Kappamult(mt,mLowerBoundLife,DeltaGothicHLife,KappaMin,PeriodsUntilT,chiIntData,Constrained)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% kappa - the MPC                                                          %
%                                                                          %
%   Inputs:                                                                %
%       mt - asset balance                                     			   %
%		mLowerBoundLife - lower bound of money balances                    %
%		DeltaGothicHLife - excess human wealth 							   %
%		KappaMin - MPC                                                     %
%		PeriodsUntilT - the period                                  	   %
% 		chiIntData - data for interploation of chi value 				   %
%		Constrained - indicator of whether agent is constrained 		   %
%   Outputs:                                                               %
%       kappa - the MPC                                                    %
%                                                                          %
%__________________________________________________________________________%

if PeriodsUntilT == 0;
    kappamult = 1;
else
    if Constrained == 0;
        kappamult = KappafromChi(mt,mLowerBoundLife,DeltaGothicHLife,KappaMin,PeriodsUntilT,chiIntData);
    else
        kappamult = KappafromChi(mt,mLowerBoundLife,DeltaGothicHLife,KappaMin,PeriodsUntilT,chiIntData);
        cUnconstr = scriptCfromChi(mt,mLowerBoundLife,DeltaGothicHLife,KappaMin,PeriodsUntilT,chiIntData);
        for i = 1:length(mt)
            if cUnconstr(i) > mt(i)
                kappamult(i) = 1;
            else
                kappamult(i) = kappamult(i);
            end
        end;
    end
end;