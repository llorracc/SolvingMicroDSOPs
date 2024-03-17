function GothicVaInterp = GothicVaInterp(a,Rho,Beta,RFree,Gamma,NumOfThetaShockPoints,ThetaVals,mVec,GothicAVec,NumOfGothicAPts)
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
% 		mVec - vector of money balances 								   %
% 		GothicAVec - vector of asset values 							   %
% 		NumOfGothicAPts - number of points of assets 					   %
%   Outputs:                                                               %
%       GothicV - Value function next period                               %                                                                          
%                                                                          %
%__________________________________________________________________________%

%Initialize variables
GothVPb = zeros(NumOfGothicAPts+1,1)';

%loop for exact values at interpolation points
for d=1:NumOfGothicAPts+1
    GothVPb(d)=GothicVa(GothicAVec(d),Rho,Beta,RFree,Gamma,NumOfThetaShockPoints,ThetaVals);
end
Gothvp = [(2*GothVPb(1)-GothVPb(2)) GothVPb (mVec(6)-GothicAVec(6))*(GothVPb(6)-GothVPb(5))/(GothicAVec(6)-GothicAVec(5))+GothVPb(6) ];
GothicA = [-GothicAVec(2) GothicAVec mVec(6)];

GothicVaInterp = interp1(GothicA,Gothvp,a);