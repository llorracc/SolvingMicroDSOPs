%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% AddNewPeriodsSolvedToSolvedLifeDatesPesReaOpt.m                          %
%	Does calculations for one period for values needed to do the method of %
%	moderation. 														   %
%                                                                          %
%__________________________________________________________________________%
kappat = KappaMin(PeriodsSolved+1);
deltah = DeltaGothicHLife(PeriodsSolved+1);

cVectRealst = cVect;
cVectOptmst = kappat.*(deltamVect+deltah);
cVectPestmst = kappat.*deltamVect;
kappaVectRealst = kappaVect;
kappaVectOptmst = kappat;
kappaVectPestmst = kappat;
koppaVals = (cVectOptmst-cVectRealst)./(cVectOptmst-cVectPestmst);
koppamuVals = deltamVect.*(kappaVectOptmst-kappaVectRealst)./(kappat*deltah);

chiVals = log((1./koppaVals)-1);
chimuVals = koppamuVals./((koppaVals-1).*koppaVals);

%store values for interpolation later
chiIntData(:,:,PeriodsSolved+1) = [muVect chiVals chimuVals];
koppaIntData(:,:,PeriodsSolved+1) = [muVect koppaVals koppamuVals];

thorn = Thorn(RFree,Beta,Rho);
frakCt = (1-(thorn./RFree)^(PeriodsSolved+1))/(1-(thorn./RFree)); %need to change so as to match Mathematica values produced
LambdaVectRealst = ((1-Rho).*vVect).^(1/(1-Rho));
LambdaVectOptmst = cVectOptmst.*(frakCt).^(1/(1-Rho));
LambdaVectPesmst = cVectPestmst.*(frakCt).^(1/(1-Rho));

LambdamVectRealst = ((1-Rho).*vVect).^(-1+1/(1-Rho)).*uP(cVect,Rho);
LambdamVectOptmst = kappat.*(frakCt).^(1/(1-Rho));
LambdamVectPesmst = kappat.*(frakCt).^(1/(1-Rho));

CapitalKoppaVals = (LambdaVectOptmst - LambdaVectRealst)./(LambdaVectOptmst-LambdaVectPesmst);
CapitalKoppamuVals = deltamVect.*(LambdamVectOptmst - LambdamVectRealst)./(LambdaVectOptmst-LambdaVectPesmst);

CapitalChiVals = log((1./CapitalKoppaVals)-1);
CapitalChimuVals = CapitalKoppamuVals./((CapitalKoppaVals-1).*CapitalKoppaVals);

%store values for interpolation later
CapitalKoppaIntData(:,:,PeriodsSolved+1) = [muVect CapitalKoppaVals CapitalKoppamuVals];
CapitalChiIntData(:,:,PeriodsSolved+1) = [muVect CapitalChiVals CapitalChimuVals];
LambdaIntData(:,:,PeriodsSolved+1) = [mVect LambdamVectRealst];

KappatRealst=kappaVectOptmst-koppamuVals .*(cVectOptmst-cVectPestmst)./deltamVect -(cVectOptmst-cVectRealst).*(kappaVectOptmst-kappaVectPestmst)./(cVectOptmst-cVectPestmst);

scriptc = ScriptC(m,mLowerBoundLife,DeltaGothicHLife,KappaMin,PeriodsSolved,chiIntData,Constrained);

%  if PeriodsSolved == 0
%      
%  else
% AA_TEST(:,PeriodsSolved+1) = GothicAVect;
% AA_TEST1(:,PeriodsSolved+1) = gothicVVect;
% AA_TEST2(:,PeriodsSolved+1) = gothicVaVect;
% AA_TEST3(:,PeriodsSolved+1) = gothicVaaVect;
% AA_TEST4(:,PeriodsSolved+1) = cVect;
% AA_TEST5(:,PeriodsSolved+1) = caVect;
% AA_TEST6(:,PeriodsSolved+1) = kappaVect;
% AA_TEST7(:,PeriodsSolved+1) = mVect;
% AA_TEST8(:,PeriodsSolved+1) = deltamVect;
% AA_TEST9(:,PeriodsSolved+1) = muVect;
% AA_TEST10(:,PeriodsSolved+1) = vVect;
% AA_TEST11(:,PeriodsSolved+1) = GothicAVecIncBott;
% AA_TEST12(:,PeriodsSolved+1) = mVecIncBott;
% AA_TEST13(:,PeriodsSolved+1) = cVecIncBott;
% AA_TEST14(:,PeriodsSolved+1) = kappat;
% AA_TEST15(:,PeriodsSolved+1) = deltah;
% AA_TEST16(:,PeriodsSolved+1) = cVectRealst;
% AA_TEST17(:,PeriodsSolved+1) = cVectOptmst;
% AA_TEST18(:,PeriodsSolved+1) = cVectPestmst;
% AA_TEST19(:,PeriodsSolved+1) = kappaVectRealst;
% AA_TEST20(:,PeriodsSolved+1) = kappaVectOptmst;
% AA_TEST21(:,PeriodsSolved+1) = koppaVals;
% AA_TEST22(:,PeriodsSolved+1) = koppamuVals;
% AA_TEST23(:,PeriodsSolved+1) = chiVals;
% AA_TEST24(:,PeriodsSolved+1) = chimuVals;
% AA_TEST25(:,PeriodsSolved+1) = frakCt;
%  end
