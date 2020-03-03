function ctRealst = scriptCfromChi(mt,mLowerBoundLife,DeltaGothicHLife,KappaMin,PeriodsUntilT,chiIntData)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Consumption value derived using the Method of Moderation                 %
%                                                                          %
%   Inputs:                                                                %
%       mt - money balances                                                %
%       mLowerBoundt - lower bound of money balances                       %
%       DeltaGothicHLife -  change in human wealth                         %
%       KappaMin - value of the MPC                                        %
%       PeriodsUntilT - The current period                                 %
% 		chiIntData - data for interpolated value of chi 				   %
%   Outputs:                                                               %
%       ctRealst - Consumption value                                       %
%                                                                          %
%__________________________________________________________________________%

deltamt = mt-mLowerBoundLife(PeriodsUntilT+1);
deltaht = DeltaGothicHLife(PeriodsUntilT+1);
kappat  = KappaMin(PeriodsUntilT+1);
mut     = log(deltamt);
chit    = chiFuncLife(chiIntData,mut,PeriodsUntilT+1);
koppat  = 1./(1+exp(chit));
ctOptmst= kappat.*(deltamt+deltaht);
ctOptmst = ctOptmst';
ctPestmst =kappat.* deltamt;
ctPestmst = ctPestmst';
ctRealst= ctOptmst-(ctOptmst-ctPestmst).*koppat;


