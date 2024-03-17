function chiint = chiint(chiIntData,mu,Period)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Interpolated value of chi for method of moderation.                      %
%                                                                          %
%   Inputs:                                                                %
%       chiIntData - data used for the interpolation                       %
%       mu - the value of mu to do the iterpolation for                    %
%		Period - the period to the interpolation for 					   %
%   Outputs:                                                               %
%       chiint  - interpolated chi value                                   %
%                                                                          %
%__________________________________________________________________________%
muVect = chiIntData(:,1,Period);
chiVals = chiIntData(:,2,Period);
chimuVals = chiIntData(:,3,Period);

muBot = muVect(1);
muTop = muVect(length(muVect));
chiBot = chiVals(1);
chiTop = chiVals(length(chiVals));
chimuBot = chimuVals(1);
chimuTop = chimuVals(length(chimuVals));

chiFunc =zeros(length(mu),1);
for i = 1:length(mu)
    if mu(i) <= muBot
        chiFunc(i) = chiBot + chimuBot*(mu(i)-muBot);
    elseif mu(i) > muBot && mu(i) < muTop
        chiFunc(i) = hermite(muVect,chiVals,chimuVals,mu(i));
    else
        chiFunc(i) = chiTop + chimuTop*(mu(i)-muTop);
    end
end;
chiint = chiFunc;