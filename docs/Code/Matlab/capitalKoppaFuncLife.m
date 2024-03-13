function CapitalKoppaint = capitalKoppaFuncLife(CapitalKoppaIntData,mu,Period)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Interpolation function for Capital Koppa                                 %
%                                                                          %
%   Inputs:                                                                %
%       CapitalKoppaIntData - data for the interpolation                   %
%       Period - period of the interpolation                               %
%       mu - the value of mu to do the iterpolation for                    %
%   Outputs:                                                               %
%       chiint  - interpolated chi value                                   %
%                                                                          %
%__________________________________________________________________________%
muVect = CapitalKoppaIntData(:,1,Period);
CapitalKoppaVals = CapitalKoppaIntData(:,2,Period);
CapitalKoppamuVals = CapitalKoppaIntData(:,3,Period);

muBot = muVect(1);
muTop = muVect(length(muVect));
CapitalKoppaBot = CapitalKoppaVals(1);
CapitalKoppaTop = CapitalKoppaVals(length(CapitalKoppaVals));
CapitalKoppamuBot = CapitalKoppamuVals(1);
CapitalKoppamuTop = CapitalKoppamuVals(length(CapitalKoppamuVals));

CapitalKoppaFunc =zeros(length(mu),1);
for i = 1:length(mu)
    if mu(i) <= muBot
        CapitalKoppaFunc(i) = CapitalKoppaBot + CapitalKoppamuBot*(mu(i)-muBot);
    elseif mu(i) > muBot && mu(i) < muTop
        CapitalKoppaFunc(i) = hermite(muVect,CapitalKoppaVals,CapitalKoppamuVals,mu(i));
    else
        CapitalKoppaFunc(i) = CapitalKoppaTop + CapitalKoppamuTop*(mu(i)-muTop);
    end
end;
CapitalKoppaint = CapitalKoppaFunc;