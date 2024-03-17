% Bootstrap.m  
% Estimate params and SE by bootstrapping. Note that SE may be overstated
% since it also reflects simulation error. 

ParamsBootstrap = zeros(NumOfBootstrap,2);                     % This mat will be filled with params estimated below 
for m=1:NumOfBootstrap
    disp('NumOfBootstrap')
    disp(m)
    clear global NumOfPeople ThetaList PermList stIndicator WealthCollege
    global NumOfPeople ThetaList PermList stIndicator WealthCollege
    NumOfPeople = NumOfPeopleBootstrap;
    setup_shocksLists
     % Note that shock lists are different in each iteration,
     % and therefore simulation error is generated if the number of people estimated is small 
    r = ceil(rand(TotalNumOfObs,1)*TotalNumOfObs);             % Vector of random integers from 1 to num of obs
      WealthPopulationCollege1 = WealthPopulationCollege(:,1); % 1st column of WealthPopulationCollege (wealth)
      WealthPopulationCollege2 = WealthPopulationCollege(:,2); % 2nd column of WealthPopulationCollege (age class)
      WealthPopulationCollege3 = WealthPopulationCollege(:,3); % 3rd column of WealthPopulationCollege
    WealthCollege = [WealthPopulationCollege1(r),WealthPopulationCollege2(r),WealthPopulationCollege3(r)];
    [xMin,fval]= fminsearch(@ObjectFunction,x0,options); 
    disp('Rho, Betahat:')
    disp(xMin)
    ParamsBootstrap(m,:) = xMin;        
end
for i=1:2
    BootStrapSE(i) = var(ParamsBootstrap(:,i))^0.5;
end

% Display results 
disp('Estimated params by bootstrapping')
disp('Rho, Betahat (mean):')
disp(mean(ParamsBootstrap))
disp('Standard errors:')
disp(BootStrapSE)