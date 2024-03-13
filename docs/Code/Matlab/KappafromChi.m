function KappafromChi = KappafromChi(mt,mLowerBoundLife,DeltaGothicHLife,KappaMin,PeriodsUntilT,chiIntData)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% MPC derived using the Method of Moderation                               %
%                                                                          %
%   Inputs:                                                                %
%       mt - money balances                                                %
%       mLowerBoundt - lower bound of money balances                       %
%       DeltaGothicHLife -  change in human wealth                         %
%       KappaMin - value of the MPC                                        %
%       chiIntData - data for interpolation                                %
%       PeriodsUntilT - The current period                                 %
%   Outputs:                                                               %
%       KappafromChi - MPC                                                 %
%                                                                          %
%__________________________________________________________________________%
deltamt = mt-mLowerBoundLife(PeriodsUntilT+1);
deltaht = DeltaGothicHLife(PeriodsUntilT+1);
kappat  = KappaMin(PeriodsUntilT+1);
mut     = log(deltamt);
chit    = chiFuncLife(chiIntData,mut,PeriodsUntilT+1);
chimut  = chimuFuncLife(chiIntData,mut,PeriodsUntilT+1); % this is a problem
koppat  = 1./(1+exp(chit));
koppamut= chimut.*(koppat-1).*koppat;
ctOptmst= kappat.*(deltamt+deltaht);
ctPestmst =kappat.* deltamt;
ctRealst= ctOptmst-(ctOptmst-ctPestmst).*koppat;
kappatOptmst = kappat;
kappatPesmst = kappat;
kappatRealst = kappatOptmst-koppamut.*(ctOptmst-ctPestmst)./deltamt-(ctOptmst-ctRealst).*(kappatOptmst-kappatPesmst)./(ctOptmst-ctPestmst);
KappafromChi = kappatRealst;