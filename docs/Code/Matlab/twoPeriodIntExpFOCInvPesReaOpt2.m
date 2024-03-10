%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% twoPeriodIntExpFOCInvPesReaOpt.m                                         %
%	Uses the method of moderation to calculate the difference between 	   %
% 	consumption using optimization and that using the method of moderation %
%	to obtain chi and the interpolating. 								   %
%                                                                          %
%__________________________________________________________________________%

clear;
PeriodsToSolve = 2;

%getting raw values
[mVec vList CTm1Raw yExpPDV KappaMin yMinPDV]=DefinecTm1Raw2;

%call need parameters and grid values
setup_params;
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
m = linspace(1, 30, 100);
mugrid = m;
deltamVectg = mugrid -mLowerBoundt;
muVectg = log(deltamVectg);
mugrid = muVectg;

chiInt = chiFuncLife(chiIntData,mugrid,2);

cbar = cF(m,yExpPDV(2),KappaMin(2))';
cChiint = cbar - (1./(1+exp(chiInt))).*(KappaMin(2)*deltah); %using no uncertainty
Diff = CTm1Raw-cChiint;