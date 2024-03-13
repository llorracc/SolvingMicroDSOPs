%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% AddNewPeriodsSolvedToSolvedLifeDates.m                                   %
%	Does the calculations for one period in the problem for consumption    %
%	and the value function. 											   %
%                                                                          %
%__________________________________________________________________________%
if MC ==1
    if min(ThetaVals) > 0 && Constrained == 1;
        mt = (mt -min(ThetaVals)*GammaLife(end)+0.001)./RLife(end);
        GothicAVect = GothicAVec + aLowerBoundt;
        GothicAVect = [0,GothicAVect,mt];
        GothicAVect = sort(GothicAVect);
        test = GothicVaOpt(0,Rho,BetaLife,RLife,GammaLife,NumOfThetaShockPoints,ThetaVals,mLowerBoundLife,DeltaGothicHLife,KappaMin,PeriodsSolved,chiIntData,Constrained,calRVals);
        mt = nP(test,Rho);
    else
        GothicAVect = sort([0.005 GothicAVec])+ aLowerBoundt;
        GothicAVect = sort(GothicAVect);
    end;
    GothicAVect = GothicAVect';
    %calculating Gothic c - step 2 on page 32
    gothicVVect = GothicVmc(GothicAVect,Rho,BetaLife,RLife,GammaLife,NumOfThetaShockPoints,ThetaVals,mLowerBoundLife,DeltaGothicHLife,KappaMin,PeriodsSolved,CapitalChiIntData,thorn,chiIntData,Constrained,gothiccInterpData,calRVals);
    gothicVaVect = GothicVaOpt(GothicAVect,Rho,BetaLife,RLife,GammaLife,NumOfThetaShockPoints,ThetaVals,mLowerBoundLife,DeltaGothicHLife,KappaMin,PeriodsSolved,chiIntData,Constrained,calRVals);
    gothicVaaVect = GothicVaaMC(GothicAVect,Rho,BetaLife,RLife,GammaLife,NumOfThetaShockPoints,ThetaVals,mLowerBoundLife,DeltaGothicHLife,KappaMin,PeriodsSolved,chiIntData,Constrained,calRVals);
else
    if min(ThetaVals) > 0 && Constrained == 1;
        mt = (mt -min(ThetaVals)*GammaLife(end)+0.001)./RLife(end);
        GothicAVect = GothicAVec + aLowerBoundt;
        GothicAVect = [0,GothicAVect,mt];
        GothicAVect = sort(GothicAVect);
        test = GothicVaMult(0,Rho,BetaLife,RLife,GammaLife,NumOfThetaShockPoints,ThetaVals,PeriodsSolved,mLowerBoundLife,DeltaGothicHLife,KappaMin,chiIntData,Constrained);
        mt = nP(test,Rho);
    else
        GothicAVect = sort([0.005 GothicAVec])+ aLowerBoundt;
        GothicAVect = sort(GothicAVect);
    end;
    GothicAVect = GothicAVect';
    gothicVVect = GothicVmult(GothicAVect,Rho,BetaLife,RLife,GammaLife,NumOfThetaShockPoints,ThetaVals,mLowerBoundLife,DeltaGothicHLife,KappaMin,PeriodsSolved,CapitalChiIntData,thorn,chiIntData,Constrained,gothiccInterpData);
    gothicVaVect = GothicVaMult(GothicAVect,Rho,BetaLife,RLife,GammaLife,NumOfThetaShockPoints,ThetaVals,PeriodsSolved,mLowerBoundLife,DeltaGothicHLife,KappaMin,chiIntData,Constrained);
    gothicVaaVect = GothicVaaMult(GothicAVect,Rho,BetaLife,RLife,GammaLife,NumOfThetaShockPoints,ThetaVals,PeriodsSolved,mLowerBoundLife,DeltaGothicHLife,KappaMin,chiIntData,Constrained,yExpPDV);
end
cVect = nP(gothicVaVect,Rho);
caVect = gothicVaaVect./uPP(cVect,Rho);
kappaVect= caVect./(1+caVect);
mVect = GothicAVect+cVect;

%calculating deltamVec - step 3 on page 32
deltamVect = mVect-mLowerBoundt;
muVect = log(deltamVect);
vVect = u(cVect,Rho)+gothicVVect;

%add bottom points to the vectors
GothicAVecIncBott = [aLowerBoundt; GothicAVect];
mVecIncBott = [mLowerBoundt; mVect];
cVecIncBott = [0; cVect];
gothiccVecIncBott = [0; cVect];

%store data for interpolation later
vInterpData(:,:,PeriodsSolved+1) = [mVect vVect];
scriptcInterpData(:,:,PeriodsSolved+1) = [mVecIncBott cVecIncBott];
gothiccInterpData(:,:,PeriodsSolved+1) = [GothicAVecIncBott gothiccVecIncBott];
