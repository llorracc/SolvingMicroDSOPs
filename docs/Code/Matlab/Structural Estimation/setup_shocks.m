% setup_shocks.m

%% Construct the possible values of the shock to income
% Construct ThetaVec 
ThetaVec     = DiscreteApproxToMeanOneLogNormal(SIGMATran,NumOfShockPoints);
 if pUnemp>0 % If assume unemployment
    ThetaVec = [0,ThetaVec/(1-pUnemp)];
 end
ThetaMat     = [repmat(ThetaVec,PeriodsToSolve-(90-65),1);repmat([ones(1,length(ThetaVec))],90-65,1)];

ThetaVecProb = (1/NumOfShockPoints)*ones(1,NumOfShockPoints);
 if pUnemp>0 % If assume unemployment
    ThetaVecProb = [pUnemp,ThetaVecProb*(1-pUnemp)];
 end
 
for i=1:PeriodsToSolve
    ThetaMatProb(i,:) = ThetaVecProb;
end

% Construct PermVec
PermVec     = DiscreteApproxToMeanOneLogNormal(SIGMAPerm,NumOfShockPoints);
PermMat     = [repmat(PermVec,PeriodsToSolve-(90-65),1);repmat(ones(1,NumOfShockPoints),90-65,1)];
PermVecProb = (1/NumOfShockPoints)*ones(1,NumOfShockPoints);

% clear unnecessary variables
clear ThetaVec ThetaVecProb PermVec