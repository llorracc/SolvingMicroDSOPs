function Thorn = Thorn(RFree,Beta,Rho)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Absolute Patience Factor                                                 %
%                                                                          %
%   Inputs:                                                                %
%       RFree - interest factor (1+r)                                      %
%       Beta - pure time discount factor                                   %
%       Rho - coefficient of relative risk aversion                        %
%   Outputs:                                                               %
%       Thorn - value of the Absolute Patience Factor                      %
%                                                                          %
%__________________________________________________________________________%
Thorn = (RFree*Beta)^(1/Rho);
