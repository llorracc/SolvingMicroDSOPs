function n = n(z,Rho)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Inverse of the CRRA utility function                                     %
%                                                                          %
%   Inputs:                                                                %
%       z - utility value                                                  %
%       Rho - coefficient of relative risk aversion                        %
%   Outputs:                                                               %
%       c - consumption value                                              %
%                                                                          %
% Date:  26/7                                                              %
%__________________________________________________________________________%
n = (z*(1-Rho))^(1/(1-Rho));