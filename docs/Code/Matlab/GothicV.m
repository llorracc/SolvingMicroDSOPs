function GothicV = GothicV(a,Rho,Beta,RFree,Gamma,NumOfThetaShockPoints,ThetaVals)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Gothic V - The value function next period                                %
%                                                                          %
%   Inputs:                                                                %
%       a - beginning of period assets                                     %
%       Rho - Coefficient of Relative Risk Aversion                        %
%       Beta -  pure time discount factor                                  %
%       RFree - Interst Factor (1+r)                                       %
%       Gamma - Income growth                                              %
%       NumOfThetaShockPoints - Number of shocks in discrete approx.       %
%       ThetaVals - Value of the shocks                                    %
%   Outputs:                                                               %
%       GothicV - Value function next period                               %
%                                                                          %
%__________________________________________________________________________%
GothicV = zeros(size(a));
for j = 1:NumOfThetaShockPoints
    GothicV = GothicV + u((RFree/Gamma)*a + ThetaVals(j),Rho);
    %GothicV = GothicV + u(RFree * a + ThetaVals(j));
end
GothicV = GothicV.*Beta.*((Gamma).^(1-Rho)).*(1/NumOfThetaShockPoints);