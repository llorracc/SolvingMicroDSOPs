% Simulate.m
% This file runs simulation

% Firat period
for i=1:NumOfPeople
    stList(i) = InitialWYRatio(stIndicator(i)); % stList      : list of normalized s (savings at the beginning of age)      
end    
mtList        = stList(1,:)+ThetaList(1,:);     % mtList      : list of normalized m (cash on hand)

for i=1:NumOfPeople
    ctList(1,i) = interp1(M(:,end),C(:,end),mtList(1,i));
    if mtList(1,i) == 0;
        ctList(1,i) =0;                         % ctList      : list of normalized consumption 
    end
end

% Continue simulstion
for t=2:NumOfPeriodsToSimulate
    for j=1:NumOfPeople           
        stList(t,j) = (Rhat/GList(t-1)/PermList(t,j))*(mtList(t-1,j)-ctList(t-1,j));
        mtList(t,j) = stList(t,j) + ThetaList(t,j);
        ctList(t,j) = interp1(M(:,end-t+1),C(:,end-t+1),mtList(t,j));
         if mtList(t,j) == 0;
          ctList(t,j) =0;                       % ctList      : list of normalized consumption 
         end
    end % End of j loop
end % End of t loop 
stMedianList      = (median(stList'))';         % stLevelMedianList: list of median of savings level 

for t=1:7
    stMedianListBy5Yrs(t) = mean(stMedianList((t-1)*5+2:t*5+1));    
end