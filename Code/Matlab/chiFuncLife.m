function chiint = chiFuncLife(chiIntData,mu,PeriodsUntilT)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Interpolation value of chi used in the Method of Moderation              %
%                                                                          %
%   Inputs:                                                                %
%       chiIntData - data for the interpolation                            %
%       PeriodsUntilT - period of the interpolation                        %
%       mu - the value of mu to do the iterpolation for                    %
%   Outputs:                                                               %
%       chiint  - interpolated chi value                                   %
%                                                                          %
%__________________________________________________________________________%
muVect = chiIntData(:,1,PeriodsUntilT);
chiVals = chiIntData(:,2,PeriodsUntilT);
chimuVals = chiIntData(:,3,PeriodsUntilT);

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