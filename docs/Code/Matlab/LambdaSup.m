function LambdaSup = LambdaSup(RFree,Beta,Rho)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
%  Perfect Foresight Marginal Propensity to Save                           %
%                                                                          %
%   Inputs:                                                                %
%       RFree - interest factor (1+r)                                      %
%       Beta - pure time discount factor                                   %
%       Rho - coefficient of relative risk aversion                        %
%   Outputs:                                                               %
%       LambdaSup - value the PF MPS                                       %
%                                                                          %                                                                          
%__________________________________________________________________________%
LambdaSup = ((1/RFree)*(RFree*Beta)^(1/Rho));
