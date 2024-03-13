% ObjectFunction.m
% Function to be used in estimating param(s)

function F = ObjectFunction(x)

global PeriodsToSolve... 
    Rhat n InitialWYRatio InitialWYRatioProb...
    VarInitialLogInc ProbOfAlive LevelAdjustingParameter...
    ThetaMat ThetaVec ThetaMatProb ThetaVecProb PermMat PermVec PermVecProb ...
    AlphaVec nP uP M C GList Betacorr NumOfPeriodsToSimulate NumOfPeople...
    ThetaList PermList stIndicator pi WealthCollege weight...
    Beta R

% Construct matrix of interpolation data   
ConstructcInterpFunc              

% Simulate 
Simulate                        

% Evaluate function value 
F = WeightedSumDist(WealthCollege,stMedianListBy5Yrs,pi,weight);


    