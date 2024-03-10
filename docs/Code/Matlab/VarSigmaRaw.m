function VarSigmaRaw = VarSigmaRaw(a,Rho,BetaLife,RLife,GammaLife,NumOfThetaShockPoints,ThetaVals,mLowerBoundLife,DeltaGothicHLife,KappaMin,PeriodsUntilT,chiIntData,Constrained,calRVals)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Optimal value of portfolio held in the risky asset                       %
%                                                                          %
%   Inputs:                                                                %
%       a - beginning of period assets                                     %
%       Rho - Coefficient of Relative Risk Aversion                        %
%       BetaLife -  pure time discount factor                              %
%       RLife - Interst Factor (1+r)                                       %
%       GammaLife - Income growth                                          %
%       NumOfThetaShockPoints - Number of shocks in discrete approx.       %
%       mLowerBoundLife - Lower bound for money balances                   %
%       DeltaGothicHLife - excess human wealth                             %
%       KappaMin - MPC                                                     %
%       PeriodsUntilT - period                                             %
%       CapitalChiIntData - data for interpolation of Capital Chi          %
%       thorn - Impatience condition                       				   %
%       chiIntData - data for interpolation of chi                         %
%       Constrained - indicator of whether the individual is constrained   %
%       GothicCInterpData - data for interpolation of Gothic C             %
%       yExpPDV -                                                          %
%       calRVals - values for return on the risky asset                    %
%   Outputs:                                                               %
%       VarSigmaRaw - Optimal value of the risky share                     %
%                                                                          %
%__________________________________________________________________________%
 optimset('TolX',1e-18);
if a <= 0
    VarSigmaRaw = 0;
else
    VarSigmaOpt = fzero(@(VarSigma) GothicVVarSigma(a,Rho,BetaLife,RLife,GammaLife,NumOfThetaShockPoints,ThetaVals,mLowerBoundLife,DeltaGothicHLife,KappaMin,PeriodsUntilT,chiIntData,Constrained,calRVals,VarSigma),[-10000,10000]);
    if VarSigmaOpt > 1
        VarSigmaRaw = 1;
    elseif VarSigmaOpt < 0
        VarSigmaRaw = 0;
    else
        VarSigmaRaw = VarSigmaOpt;
    end;
end;
        