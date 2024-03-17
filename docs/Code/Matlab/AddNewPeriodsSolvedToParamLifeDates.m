%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% AddNewPeriodsSolvedToParamLifeDates.m                                    %
%  Does the calculations for each period of life for a number of variables.%
% 																		   %
%   Inputs:                                                                %
%       Rho - Coefficient of Relative Risk Aversion                        %
%       Beta -  pure time discount factor                                  %
%       BetaLife -  pure time discount factor in each period of life       %
%       RFree - Interst Factor (1+r)                                       %
%       RLife - Interst Factor (1+r) in each period of life                %
%       Gamma - Income Growth                                              %
%       GammaLife - Income Growth in each periof of life                   %
%       GothicHMinLife - Minimum end-of-period human wealth                %
%       yMinPDV - Minimum human wealth each period of life                 %
%       yExpPDV - Expected human wealth                                    %
%       GothicHExpLife - E(human wealth) excluding this period's income    %
%       LambdaMax - Marginal Propensity to save                            %
%       vSum - discounted value                                            %
%       KappaMin - Marginal Propensity to consume                          %
%       mLowerBoundLife - Lower bound of money assets                      %
%       GothicALowerBoundLife - Lower bound of assets                      %
%       NumOfThetaShockPoints - Number of shocks in discrete approx.       %
%       ThetaVals - Value of the shocks                                    %
%   Outputs:                                                               %
%       Various - values with an additional period                         %
%                                                                          %
%__________________________________________________________________________%

% updating this periods values
RLife = [RLife; RFree];                                                         % Assume that the return factor for the latest period is the riskfree rate
BetaLife = [BetaLife; Beta];                                                    % Assume that the discount factor for the latest period is Beta
GammaLife = [GammaLife; Gamma];                                                 % Assume that the growth factor for the latest period is Gamma
% Minimum end-of-period human wealth (end-of-period: excluding this period's income)
if Constrained == 1
    GothicHMinLife  = [GothicHMinLife; GammaLife(end).*ThetaVals(1)./RLife(end)];
else
    GothicHMinLife = [GothicHMinLife; GammaLife(end).*yMinPDV(end)./RLife(end)];
end;
GothicHExpLife =[GothicHExpLife; GammaLife(end).*yExpPDV(end)/RLife(end)];      % Expected human wealth excluding this period's income 
DeltaGothicHLife = [DeltaGothicHLife; GothicHExpLife(end)-GothicHMinLife(end)]; % Difference between expected and minimum human wealth
yExpPDV = [yExpPDV; GothicHExpLife(end)+1];                                     % Expected human wealth including this period's income of 1
yMinPDV = [yMinPDV; GothicHMinLife(end)+min(ThetaVals)];                        % Minimum human wealth (including this period's minimum income)
LambdaMax = [LambdaMax; (RLife(end).^((1/Rho)-1)).*BetaLife(end).^(1/Rho)];     % Formula for MPS is implicit in equation eq:MinMPCInv in BufferStockTheory.tex: 
vSum = [vSum; 1+vSum(end).*LambdaMax(end)];                                     % Formula for discounted Value is sum of Lambdas 
KappaMin = [KappaMin; 1./(1+LambdaMax(end)./KappaMin(end))];                    % Formula for MPC is given by equation eq:MinMPCInv in BufferStockTheory.tex
%from functionsIntExpFOCInvPesReaOpt
mLowerBoundLife = [mLowerBoundLife; -GothicHMinLife(end)];
GothicALowerBoundLife = [GothicALowerBoundLife; -GothicHMinLife(end)];