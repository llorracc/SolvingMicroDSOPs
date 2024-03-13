function KappaInf = KappaInf(RFree,Beta,Rho)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Perfect Foresight Marginal Propensity to Consume                         %
%                                                                          %
%   Inputs:                                                                %
%       RFree - interest factor (1+r)                                      %
%       Beta - pure time discount factor                                   %
%       Rho - coefficient of relative risk aversion                        %
%   Outputs:                                                               %
%       KappaInf - value of the Marginal Propensity to Consume             %
%                                                                          %
%__________________________________________________________________________%
KappaInf = 1-((1/RFree)*(RFree*Beta)^(1/Rho));
