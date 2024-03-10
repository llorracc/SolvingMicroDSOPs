%function [lambdaSup kappaInf thorn thornRet] = setup_definitions(RFree,Beta,Rho)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
%  Definitions                                                             %
%                                                                          %
%   Inputs:                                                                %
%       Rho - Coefficient of Relative Risk Aversion                        %
%       Beta -  pure time discount factor                                  %
%       RFree - Interst Factor (1+r)                                       %
%   Outputs:                                                               %
%       See seprate function files for a description                       %
%                                                                          %
%__________________________________________________________________________%
lambdaSup = LambdaSup(RFree,Beta,Rho);
kappaInf = KappaInf(RFree,Beta,Rho);
thorn = Thorn(RFree,Beta,Rho);
thornRet = ThornRet(RFree,Beta,Rho);

