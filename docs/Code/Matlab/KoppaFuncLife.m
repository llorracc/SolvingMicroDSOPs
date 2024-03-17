function Koppaint = KoppaFuncLife(KoppaIntData,mu,Period)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Interpolation function for  Koppa                                        %
%                                                                          %
%   Inputs:                                                                %
%       KoppaIntData - data for the interpolation                          %
%       Period - period of the interpolation                               %
%       mu - the value of mu to do the iterpolation for                    %
%   Outputs:                                                               %
%       chiint  - interpolated chi value                                   %
%                                                                          %
%__________________________________________________________________________%
muVect = KoppaIntData(:,1,Period);
KoppaVals = KoppaIntData(:,2,Period);
KoppamuVals = KoppaIntData(:,3,Period);

muBot = muVect(1);
muTop = muVect(length(muVect));
KoppaBot = KoppaVals(1);
KoppaTop = KoppaVals(length(KoppaVals));
KoppamuBot = KoppamuVals(1);
KoppamuTop = KoppamuVals(length(KoppamuVals));

KoppaFunc =zeros(length(mu),1);
for i = 1:length(mu)
    if mu(i) <= muBot
        KoppaFunc(i) = KoppaBot + KoppamuBot*(mu(i)-muBot);
    elseif mu(i) > muBot && mu(i) < muTop
        KoppaFunc(i) = hermite(muVect,KoppaVals,KoppamuVals,mu(i));
    else
        KoppaFunc(i) = KoppaTop + KoppamuTop*(mu(i)-muTop);
    end
end;
Koppaint = KoppaFunc;