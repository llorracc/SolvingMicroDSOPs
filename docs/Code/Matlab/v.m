function v = v(m,mLowerBoundLife,DeltaGothicHLife,KappaMin,PeriodsUntilT,CapitalChiIntData,thorn,Rho,chiIntData,Constrained,GothicCInterpData)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% v - The value function next period                                       %
%                                                                          %
%   Inputs:                                                                %
%       m - money balances                                     			   %
% 		mLowerBoundLife - lower bound for money balances 				   %
%       DeltaGothicHLife - Excess human capital in each period of life     %
%       KappaMin - MPC 													   %
%       PeriodsUntilT - period											   %
%       CapitalChiIntData - data used for interpolation of Capital Chi     %
%       thorn - impatience condition 									   %
%       Rho - Coefficient of Relative Risk Aversion 					   %
%       chiIntData - data used for interpolation of chi amd chimu   	   %
%       Constrained - Indicates if the agent is constrained 			   %
%       GothicCInterpData - data used for interpolation of Gothic C  	   %
%       yExpPDV - PDV of expected income 								   %
%   Outputs:                                                               %
%       v - Value function next period                                     %
%                                                                          %
%__________________________________________________________________________%

if PeriodsUntilT == 0;
    v = u(m,Rho);
else
    v = u(CapitalLambda(m,mLowerBoundLife,DeltaGothicHLife,KappaMin,PeriodsUntilT,CapitalChiIntData,thorn,Rho,chiIntData,Constrained,GothicCInterpData),Rho);
end;