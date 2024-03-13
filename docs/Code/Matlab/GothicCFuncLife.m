function GothicCint = GothicCFuncLife(GothicCInterpData,m,Period)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Interpolated consumption                                                 %
%                                                                          %
%   Inputs:                                                                %
%       GothicCInterpData - data for the interpolation                     %
%       Period - period of the interpolation                               %
%       m - the value of mu to do the iterpolation for                     %
%   Outputs:                                                               %
%       GothicCint  - interpolated consumption value                       %
%                                                                          %
%__________________________________________________________________________%
mVecIncBott  = GothicCInterpData(:,1,Period);
cVecIncBott  = GothicCInterpData(:,2,Period);

GothicCint = interp1(mVecIncBott,cVecIncBott,m,'linear','extrap');