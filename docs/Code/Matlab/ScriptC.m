function scriptc = ScriptC(m,mLowerBoundLife,DeltaGothicHLife,KappaMin,PeriodsUntilT,chiIntData,Constrained)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Consumption value derived using the Method of Moderation                 %
%                                                                          %
%   Inputs:                                                                %
%       m - beginning of period assets                                     %
%		mLowerBoundLife - lower bound of money balances                    %
%		DeltaGothicHLife - excess human wealth 							   %
%		KappaMin - MPC                                                     %
%		PeriodsUntilT - the period                                  	   %
% 		chiIntData - data for interploation of chi value 				   %
%		Constrained - indicator of whether agent is constrained 		   %
%   Outputs:                                                               %
%       scriptc  - consumption value                                       %
%                                                                          %
%__________________________________________________________________________%

if PeriodsUntilT == 0;
    scriptc = m;
else
    cfromChi =scriptCfromChi(m,mLowerBoundLife,DeltaGothicHLife,KappaMin,PeriodsUntilT,chiIntData);
    scriptc = cfromChi;
    for i =1:length(m)
        scriptc(i) = cfromChi(i);
        if Constrained == 0
            scriptc(i) = cfromChi(i);
        else
            if scriptc(i) > m(i)
                scriptc(i) = m(i);
            else
                scriptc(i) = scriptc(i);
            end;    
        end;
    end
end
