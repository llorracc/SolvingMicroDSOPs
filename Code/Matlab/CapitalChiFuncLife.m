function CapitalChiint = CapitalChiFuncLife(CapitalChiIntData,mu,Period)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
%  CapitalChiint derived using the Method of Moderation                    %
%                                                                          %
%   Inputs:                                                                %
%       CapitalChiIntData - data for the interpolation                     %
%       Period - period of the interpolation                               %
%       mu - the value of mu to do the iterpolation for                    %
%   Outputs:                                                               %
%       CapitalChiint  - interpolated CapitalChi value                     %
%                                                                          %
%__________________________________________________________________________%
muVect = CapitalChiIntData(:,1,Period);
CapitalChiVals = CapitalChiIntData(:,2,Period);
CapitalChimuVals = CapitalChiIntData(:,3,Period);

muBot = muVect(1);
muTop = muVect(length(muVect));
CapitalChiBot = CapitalChiVals(1);
CapitalChiTop = CapitalChiVals(length(CapitalChiVals));
CapitalChimuBot = CapitalChimuVals(1);
CapitalChimuTop = CapitalChimuVals(length(CapitalChimuVals));

CapitalChiFunc =zeros(length(mu),1);
for i = 1:length(mu)
    if mu(i) <= muBot
        CapitalChiFunc(i) = CapitalChiBot + CapitalChimuBot*(mu(i)-muBot);
    elseif mu(i) > muBot && mu(i) < muTop
        CapitalChiFunc(i) = hermite(muVect,CapitalChiVals,CapitalChimuVals,mu(i));
    else
        CapitalChiFunc(i) = CapitalChiTop + CapitalChimuTop*(mu(i)-muTop);
    end
end;
CapitalChiint = CapitalChiFunc;