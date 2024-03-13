function GothicVa = GothicVa(a,Rho,Beta,RFree,Gamma,NumOfThetaShockPoints,ThetaVals)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Derivative of Gothic V - Derivative of the value function next period    %
%                                                                          %
%   Inputs:                                                                %
%       a - beginning of period assets                                     %
%       Rho - Coefficient of Relative Risk Aversion                        %
%       Beta -  pure time discount factor                                  %
%       RFree - Interst Factor (1+r)                                       %
%       Gamma - Income Growth                                              %
%       NumOfThetaShockPoints - Number of shocks in discrete approx.       %
%       ThetaVals - Value of the shocks                                    %
%   Outputs:                                                               %
%       GothicVa - Marginal Value function next period                     %
%                                                                          %
%__________________________________________________________________________%

GothicVa=zeros(size(a)); 
for i=1:length(ThetaVals)
    GothicVa=GothicVa+Beta.*((Gamma)^(-Rho))*1/NumOfThetaShockPoints*RFree*uP((RFree/Gamma)*a+ThetaVals(i),Rho);
end