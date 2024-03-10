function GothicVaa = GothicVaa(a,Rho,Beta,RFree,Gamma,NumOfThetaShockPoints,ThetaVals)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% 2nd Derivative of Gothic V                                               %
%                                                                          %
%   Inputs:                                                                %
%       a - beginning of period assets                                     %
%       Rho - Coefficient of Relative Risk Aversion                        %
%       Beta -  pure time discount factor                                  %
%       RFree - Interst Factor (1+r)                                       %
%       NumOfThetaShockPoints - Number of shocks in discrete approx.       %
%       ThetaVals - Value of the shocks                                    %
%   Outputs:                                                               %
%       GothicVaa - 2nd Derivative of Gothic V                             %
%                                                                          %
%__________________________________________________________________________%

GothicVaa=zeros(size(a)); 
for i=1:length(ThetaVals)
   GothicVaa=GothicVaa+Beta.*((Gamma)^(-Rho-1))*1/NumOfThetaShockPoints*RFree^2*uPP((RFree/Gamma)*a+ThetaVals(i),Rho);
end
