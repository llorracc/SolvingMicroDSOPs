function uPP = uPP(c,Rho)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% CRRA marginal marginal utility function                                  %
%                                                                          %
%   Inputs:                                                                %
%       c - consumption level                                              %
%       Rho - coefficient of relative risk aversion                        %
%   Outputs:                                                               %
%       uPP - value of the 2nd derivative of the utility function          %                                                                          %
%__________________________________________________________________________%

uPP= -Rho.*c.^(-Rho-1);