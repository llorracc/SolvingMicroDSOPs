function scriptCint = scriptCFuncLife(scriptCInterpData,m,Period)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Interpolated consumption                                                 %
%                                                                          %
%   Inputs:                                                                %
%       scriptCInterpData - data for the interpolation                     %
%       Period - period of the interpolation                               %
%       m - the value of mu to do the iterpolation for                     %
%   Outputs:                                                               %
%       scriptCint  - interpolated consumption value                       %
%                                                                          %
%__________________________________________________________________________%
mVecIncBott  = scriptCInterpData(:,1,Period);
cVecIncBott  = scriptCInterpData(:,2,Period);

scriptCint = interp1(mVecIncBott,cVecIncBott,m,'linear','extrap');
