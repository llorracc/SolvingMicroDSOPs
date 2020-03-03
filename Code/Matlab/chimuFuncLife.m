function chimuint = chimuFuncLife(chiIntData,mu,Period)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Chimu value for using in the Method of Moderation                        %
%                                                                          %
%   Inputs:                                                                %
%       chiIntData - data for the interpolation                            %
%       Period - period of the interpolation                               %
%       mu - the value of mu to do the iterpolation for                    %
%   Outputs:                                                               %
%       chimuint  - interpolated chi value                                 %
%                                                                          %
%__________________________________________________________________________%
muVect = chiIntData(:,1,Period);
chiVals = chiIntData(:,2,Period);
chimuVals = chiIntData(:,3,Period);

muBot = muVect(1);
muTop = muVect(length(muVect));
chimuBot = chimuVals(1);
chimuTop = chimuVals(length(chimuVals));
%constructing a piecewise function
for i = 1:length(mu)
    if mu(i) <= muBot
        chimuint(i) = chimuBot;
    elseif mu(i) >= muTop
        chimuint(i) = chimuTop;
    else
        chimuint= hermite2(muVect,chiVals,chimuVals,mu(i));
    end
end
