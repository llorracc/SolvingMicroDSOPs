function uP = uP(c,Rho)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% CRRA marginal utility function                                           %
%                                                                          %
%   Inputs:                                                                %
%       c - consumption level                                              %
%       Rho - coefficient of relative risk aversion                        %
%   Outputs:                                                               %
%       uP - value of the 1st derivative of the utility function           %
%                                                                          %
%__________________________________________________________________________%
if Rho == 1
    uP = 1/c;
else
    if c>0
        uP= c.^-Rho;
    else
        uP= 1000000000000000000000000000000000; %large number meant to be infinity
    end;
end;