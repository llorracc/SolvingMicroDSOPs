%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% multiperiod.m                                                            %
%	Doing the calculations for the multiperiod problem using the method of %
% 	moderation. 														   %
%                                                                          %
%__________________________________________________________________________%

PeriodsToSolve = 21;

%call need parameters and grid values
setup_params;
setup_params_multiperiod;
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