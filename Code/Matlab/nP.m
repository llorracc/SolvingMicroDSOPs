function nP = nP(z,Rho)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Inverse of the CRRA marginal utility function                            %
%                                                                          %
%   Inputs:                                                                %
%       z - marginal end of period value function amount                   %
%       Rho - coefficient of relative risk aversion                        %
%   Outputs:                                                               %
%       nP - consumption value                                             %
%                                                                          %
%__________________________________________________________________________%
nP = z.^(-1/Rho);