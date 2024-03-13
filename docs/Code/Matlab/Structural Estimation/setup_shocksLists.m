% setup_shocksLists.m

%% Construct income shock draw lists
% Tran shock draw list
ThetaDraws = DiscreteApproxToMeanOneLogNormal(SIGMATran,NumOfPeople);
 if pUnemp>0 % If assume unemployment
     ThetaDraws = DiscreteApproxToMeanOneLogNormal(SIGMATran,NumOfPeople-pUnemp*NumOfPeople);
     ThetaDraws = ThetaDraws/(1 - pUnemp);
     ThetaDraws = [0*ones(1,pUnemp*NumOfPeople),ThetaDraws];
 end 

% Perm shock draw list
PermShockDraws = DiscreteApproxToMeanOneLogNormal(SIGMAPerm,NumOfPeople);

%% Construct income shock lists
for i     = 1:NumOfPeriodsToSimulate
    tTepm = randperm(NumOfPeople);
    pTepm = randperm(NumOfPeople);
    for j=1:NumOfPeople
        ThetaList(i,j) = ThetaDraws(tTepm(j));     % List of Theta (tran shock) 
        PermList(i,j)  = PermShockDraws(pTepm(j)); % List of perm shock 
    end
end

%% Construct wtIndicator (list of indicators for initial wealth)
for i=1:NumOfPeople
    r = rand;
    if r < InitialWYRatioProb(1)
        stIndicator(i) = 1;
    elseif r < InitialWYRatioProb(1)+InitialWYRatioProb(2)
        stIndicator(i) = 2;
    else
        stIndicator(i) = 3;
    end
end