function Value = rsharefunc(RiskyShare,calRVals,calRProb,RLife,Rho,PeriodsSolved)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% function for determining the Merton-Samuelson portolio share             %
%                                                                          %
% Inputs:                                                                  %
%   RiskyShare - the amount of portfolio held in the risky asset           %
%   calRVals - values of possible interest factors from a discrete approx. %
%   calRProb - probablility of each value in the discrete approx.          %
%   RLife - the interest factor                                            %
%   Rho - the coefficient of relative risk aversion                        %
%	PeriodsSolved - indicator of period 								   %
% Outputs:                                                                 %
%   Value - the value from each riskyshare value                           %
%                                                                          %
%__________________________________________________________________________%
val = zeros(length(calRVals),1);
for i = 1:length(calRVals)
    val(i) = calRProb(i).*((1+RiskyShare.*(calRVals(i)./RLife(PeriodsSolved+1)-1))^(-Rho)).*(calRVals(i)./RLife(PeriodsSolved+1)-1);
end;
Value = sum(val);
