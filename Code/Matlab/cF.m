function cF = cF(m,yExpPDV,kappaMin)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Perfect foresight consumption function                                   %
%                                                                          %
%   Inputs:                                                                %
%       m - money balances                                                 %
%       yExpPDV - PDV of human wealth at T-1                               %
%       kappaMin - perfect foresight marginal propensity to consume        %
%   Outputs:                                                               %
%       cF - Perfect foresight consumption value                           %
%                                                                          %
%__________________________________________________________________________%
cF = (m-1+yExpPDV)*kappaMin;