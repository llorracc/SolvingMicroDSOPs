function u = u(c,Rho)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% CRRA utility function                                                    %
%                                                                          %
%   Inputs:                                                                %
%       c - consumption level                                              %
%       Rho - coefficient of relative risk aversion                        %
%   Outputs:                                                               %
%       u - value of utility given consumption c                           %
%                                                                          %
%__________________________________________________________________________%
if Rho==1;
    u=log(c);
else
    u = (c.^(1-Rho))./(1-Rho);
end;