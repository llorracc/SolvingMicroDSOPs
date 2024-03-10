function ThornRet = ThornRet(RFree,Beta,Rho)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Return Patience Factor                                                   %
%                                                                          %
%   Inputs:                                                                %
%       RFree - interest factor (1+r)                                      %
%       Beta - pure time discount factor                                   %
%       Rho - coefficient of relative risk aversion                        %
%   Outputs:                                                               %
%       Thorn - value of the Return Patience Factor                        %                                                                          
%                                                                          %
%__________________________________________________________________________%
ThornRet = ((RFree*Beta)^(1/Rho))/RFree;
