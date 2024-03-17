function CapitalLambdatRealst = CapitalLambdafromCapitalChi(mt,mLowerBoundLife,DeltaGothicHLife,KappaMin,PeriodsUntilT,CapitalChiIntData,thorn,Rho)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Consumption value derived using the Method of Moderation                 %
%                                                                          %
%   Inputs:                                                                %
%		mt - money balances 											   %
%		mLowerBoundLife - lower bound of money balances 				   %
%		DeltaGothicHLife - excess human wealth 							   % 
%		KappaMin - MPC 													   %
%		PeriodsUntilT - period being evaluated 							   %
%		CapitalChiIntData - data for interpolation of Capital Chi 		   %
%		thorn - the absolute patience condition 						   %
%		Rho - Coefficient of Relative Risk Aversion 					   %
%   Outputs:                                                               %
%       CapitalLambdatRealst  - value of capital Lambda for the realist    %
%                                                                          %
%__________________________________________________________________________%
deltamt = mt-mLowerBoundLife(PeriodsUntilT+1);
deltamt = deltamt';
deltaht = DeltaGothicHLife(PeriodsUntilT+1); 
kappat  = KappaMin(PeriodsUntilT+1);
mut     = log(deltamt);
CapitalChit    = CapitalChiFuncLife(CapitalChiIntData,mut,PeriodsUntilT+1);
frakCt = (1-thorn^(PeriodsUntilT+1))./(1-thorn);
ctOptmst= kappat.*(deltamt+deltaht);
ctOptmst = ctOptmst';
ctPestmst =kappat.* deltamt;
ctPestmst = ctPestmst';
CapitalLambdatOptmst = ctOptmst.*(frakCt)^(1./(1-Rho));
CapitalLambdatPestmst = ctPestmst.*(frakCt)^(1./(1-Rho));
CapitalKoppat  = 1./(1+exp(CapitalChit));
CapitalLambdatRealst = CapitalLambdatOptmst-(CapitalLambdatOptmst-CapitalLambdatPestmst).*CapitalKoppat;