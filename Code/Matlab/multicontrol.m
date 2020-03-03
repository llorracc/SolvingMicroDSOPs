%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% multicontrol.m                                                           %
%	Does the calculates and plots the multicontrol problem using the 	   %
%	method of moderation. 												   %
%                                                                          %
%__________________________________________________________________________%
PeriodsToSolve = 19;

%call need parameters and grid values
setup_params;
MC=1; % indicate that it is the multicontrol problem
setup_params_multiperiod;
GothicAVec = setup_grids_expMult(GothicAMin,GothicAMax, NumOfGothicAPts,20);
[ThetaVals ThetaProb] = setup_shocks(NumOfThetaShockPoints,Sigma);

%evaluation points
m = linspace(0, 4, 5);

%Setup last period values
setup_lastperiod;
setup_lastperiod_PesReaOptCon;
setup_lastperiod_PesReaOpt;
setup_params_multicontrol;
thorn = Thorn(RFree,Beta,Rho);
consumption = zeros(length(m),PeriodsToSolve);
consumption(:,1) = m;

% DatachiintMC;
%   chiIntData(:,1,2:20)= reshape(M_chiIntData(:,1),7,1,19);
%   chiIntData(:,2,2:20)= reshape(M_chiIntData(:,2),7,1,19);
%   chiIntData(:,3,2:20)= reshape(M_chiIntData(:,3),7,1,19);

PeriodsSolved=0;
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
a = linspace(0.001, 6, 50);
for i = 1:length(a)
    A = a(i);
    VSig(i) = VarSigmaRaw(A,Rho,BetaLife,RLife,GammaLife,NumOfThetaShockPoints,ThetaVals,mLowerBoundLife,DeltaGothicHLife,KappaMin,14,chiIntData,Constrained,calRVals);
end;