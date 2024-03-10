%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Perfect foresight consumption function                                   %
%                                                                          %
%   Inputs:                                                                %
%       RFree - Interest Factor                                            %
%       Beta - Pure time discount rate                                     %
%       Gamma - Rate of productivity growth                                %
%       ThetaVals- shock values                                            %
%   Outputs:                                                               %
%        Various - parmater values in last period                          %
%                                                                          %
%__________________________________________________________________________%

RLife     =  RFree;                         %(* Interest factor for last period of life *)
BetaLife  =  Beta;                          %(* Time preference factor for last period of life *)
GammaLife = Gamma;                          %(* Income growth factor *)
DeltaGothicHLife = 0;                       %(* Value of human wealth at end of last period of life *)
GothicHMinLife = 0;                         %(* Value of human wealth at end of last period of life *)
GothicHExpLife =  0;                        %(* Value of human wealth at end of last period of life *)
yExpPDV = 1;                                %(* Expected human wealth at beg. of per.; 1 in per. T reflects that per.'s inc*)
yMinPDV = min(ThetaVals);                   %(* Minimum possible human wealth;occurs if this per.'s inc is min*)
LambdaMax = 0;                              %(* Marginal propensity to save LastLambdaLife in last period of life is 0.   *)
vSum = 1;                                   %(* Last period consumption function is same as PF in t=T since no uncer remains      *)
KappaMin = 1;                               %(* Marginal propensity to consume Kappa in last period of life is 1.   *)
mLowerBoundLife =  0;                       
GothicALowerBoundLife =  0;                 %(* Minimum value of assets with which life might be ended *)
cFuncLife = cF(KappaMin,yExpPDV,KappaMin); % consumption level in t=T is equal to the perfect foresight level
Lambda = LambdaSup(RFree,Beta,Rho);        % marginal propensity to save
