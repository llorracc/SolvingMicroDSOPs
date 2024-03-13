function GothicC = GothicC(z,Rho,Beta,RFree,Gamma,NumOfThetaShockPoints,ThetaVals)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Gothic C - C given the derivative of Gothic V                            %
%                                                                          %
%   Inputs:                                                                %
%       z - derivative of Gothic V                                         %
%       Rho - coefficient of relative risk aversion                        %
%		Beta - the pure discount factor 								   %
%		RFree - interest risk factor 									   %
%		Gamma - the growth rate of human capital 						   %
%		NumOfThetaShockPoints - the number of points in the approx. 	   %
%		ThetaVals - The points of the discrete approximation. 			   %
%   Outputs:                                                               %
%       Gothic C - C given the derivative of Gothic V                      %
%                                                                          %
%__________________________________________________________________________%

GothicC = nP(GothicVa(z,Rho,Beta,RFree,Gamma,NumOfThetaShockPoints,ThetaVals),Rho);