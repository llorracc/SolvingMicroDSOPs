function [ThetaVals ThetaProb] = setup_shocks(NumOfThetaShockPoints,Sigma)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Setting up shock values (discrete approximation to log normal)           %
%                                                                          %
%   Inputs:                                                                %
%       NumOfThetaShockPoints - Number of shock points                     %
%       Sigma                 - Standard deviation of shock points         %
%   Outputs:                                                               %
%       ThetaVals - shock values                                           %
%       ThetaProb - Probability associated with shock point                %
%                                                                          %
% Note: values are different (~10^-6) from those produced in Mathematica.  %
%                                                                          %
%__________________________________________________________________________%

%Initializing variables
X = zeros(NumOfThetaShockPoints+1,1);
ProbOfMeanPoints = zeros(NumOfThetaShockPoints,1)';
MeanPoints = zeros(NumOfThetaShockPoints,1)';

for i = 0:NumOfThetaShockPoints;
    P = i/NumOfThetaShockPoints;
    X(i+1) = logninv(P,-1/2*(Sigma)^2,Sigma);
end;
X(NumOfThetaShockPoints+1)=100000000000;

for i=1:NumOfThetaShockPoints;
    ProbOfMeanPoints(i) = logncdf(X(i+1),-1/2*(Sigma)^2,Sigma)-logncdf(X(i),-1/2*(Sigma)^2,Sigma);
end
F = @(x) x.*lognpdf(x,-1/2*(Sigma)^2,Sigma);
for i=1:NumOfThetaShockPoints
    MeanPoints(i)=quad(F,X(i),X(i+1))/ProbOfMeanPoints(i);
end

ThetaVals=MeanPoints;
ThetaProb=ProbOfMeanPoints;

% % Values from Mathematica for two periods
% ThetaVals = [0.13538149173275824, 0.275380604304689, 0.42222143699525244, 0.6097975230674095, 0.8820984148673217,1.3636742080029376, 3.311446325988296]';
% ThetaProb = repmat(1/length(ThetaVals),length(ThetaVals),1);
% Values from Mathematica for multiple periods
% ThetaVals = [0.7173297732486918, 0.8356438674325397, 0.9108031747555964, 0.9804095254805039, 1.0554022326121744, 1.1507082161943467, 1.3497032102991895]';
% ThetaProb = repmat(1/length(ThetaVals),length(ThetaVals),1);