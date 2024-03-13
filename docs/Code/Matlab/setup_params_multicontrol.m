%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Parameters needed for the multicontol problem                            %
%                                                                          %
%  Outputs:                                                                %
%	GothicAMax - maximum point in the Gothic A grid                        %
%	Rho - Coefficient of relative risk aversion                            %
%	VarSigmaMin - Minimum value of the risky share                         %
%	VarSigmaMax - Maximum value of the risky share                         %
%	VarSigmaPts - Number of points in risk share grid                      %
%	VarSigmaVect - Vector of risk share points                             %
%	calRPrm - Estimate of the equity premium                               %
%	calRStd - Standard deviation of (log) equity returns                   %
%	NumOfcalRPts - No. of points in approx. to distribution of returns     %
%	calRProb - Probability of approx. return value                         %
%	calRVals - Approx. return values                                       %
%   MertSamRiskyShare - optimal share of risky assets                      %
%                                                                          %
%__________________________________________________________________________%

GothicAMax = 6; % Need slightly larger GothicAMax to see the portfolio share decline
Rho = 6; % Need high risk aversion to prevent portfolios always > 1
VarSigmaMin = 0;
VarSigmaMax = 1;
VarSigmaPts = 6;
VarSigmaVect = setup_grids(VarSigmaMin,VarSigmaMax,VarSigmaPts,1);
calRPrm = 1.04; % Modest estimate of the equity premium of 4 percent
calRStd = 0.15; % Standard deviation of (log) equity returns
NumOfcalRPts = 7;
[calRVals calRProb] = setup_shocks(NumOfcalRPts,calRStd);
calRVals = calRPrm.*calRVals;

% calRVals = [0.813129, 0.912314, 0.973218, 1.02849, 1.08694, 1.15972, 1.30619]';
% calRProb = [0.142857, 0.142857, 0.142857, 0.142857, 0.142857, 0.142857, 0.142857]';

% Solve for portfolio share for someone with no labor income (which is the limit with labor income as wealth goes to infinity).  
% This is the Merton-Samuelson problem; see http://econ.jhu.edu/people/ccarroll/public/lecturenotes/assetpricing/Portfolio-CRRA

MertSamRiskyShare = fzero(@(RiskyShare) rsharefunc(RiskyShare,calRVals,calRProb,RLife,Rho,PeriodsSolved),[0,1]);

%MertSamRiskyShare = 0.152723;
if MertSamRiskyShare > 1
    MertSamRiskyShare = 1;
    disp('Uninteresting problem because Merton-Samuelson Share >= 1');
elseif MertSamRiskyShare < 0
    MertSamRiskyShare = 0;
end;
VarSigmaVect = union(MertSamRiskyShare,VarSigmaVect);
