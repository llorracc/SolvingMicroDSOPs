%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% 2PeriodIntExpFOCInvPesReaOpt.m                                           %
%	Does the calculations for the teo period problem to determine the      %
%	level of precautinary saving from the method of moderation and direct  %
% 	optimization. 														   %
%                                                                          %
%__________________________________________________________________________%

clear;
PeriodsToSolve = 2;

%getting raw values
[mVec vList CTm1Raw yExpPDV KappaMin yMinPDV]=DefinecTm1Raw;

%call need parameters and grid values
setup_params;
Constrained = 0;
[ThetaVals ThetaProb] = setup_shocks(NumOfThetaShockPoints,Sigma);
GothicAVec = setup_grids_expMult(GothicAMin,GothicAMax, NumOfGothicAPts,20);

%evaluation points
m = linspace(0, 4, 5);

%Setup last period values
setup_lastperiod;
setup_lastperiod_PesReaOpt;
thorn = Thorn(RFree,Beta,Rho);
consumption = zeros(length(m),PeriodsToSolve);
consumption(:,1) = m;

%loops to solve problem (equivalent to solve another period)
PeriodsSolved=1;
while  PeriodsSolved <= PeriodsToSolve;
    AddNewPeriodsSolvedToParamLifeDates;
    PeriodsSolved = PeriodsSolved+1;
end;
PeriodsSolved=1;
while  PeriodsSolved < PeriodsToSolve;
    mLowerBoundt = mLowerBoundLife(PeriodsSolved+1);
    aLowerBoundt = GothicALowerBoundLife(PeriodsSolved+1);
    AddNewPeriodsSolvedToSolvedLifeDates;
    AddNewPeriodsSolvedToSolvedLifeDatesPesReaOpt;
    consumption(:,PeriodsSolved+1) = scriptc;
    PeriodsSolved = PeriodsSolved+1;
end;

%Doing Interpolation
m = linspace(1, 30, 30);
mugrid = m;
deltamVectg = mugrid -mLowerBoundt;
muVectg = log(deltamVectg);
mugrid = muVectg;
chiInt = chiFuncLife(chiIntData,mugrid,2);
cbar = cF(m,yExpPDV(2),KappaMin(2))';
cChiint = cbar - (1./(1+exp(chiInt))).*(KappaMin(2)*deltah); %using no uncertainty
Diff = cbar-cChiint;
% Real values
Consum = interp1(mVec,CTm1Raw,m,'linear','extrap')';
Diff1 = cbar-Consum;