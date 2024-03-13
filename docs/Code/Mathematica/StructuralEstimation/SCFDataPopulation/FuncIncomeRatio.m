% FuncIncomeRatio.m

% Function to give ratio (before tax permanent income/after permanent tax income)

% This function is necessary; we need to rescale WIRATIO properly, 
% since WIRATIO obtained using STATA is the ratio of wealth to before tax permanent income, 
% not to after tax permanent income.
% (Remember that the work in the lecture notes takes parameters from Cagetti (2003)
% which is based on after tax income.)

function F = FuncIncomeRatio(x)

 Income      = [39497, 49262, 61057, 68224, 86353, 96983, 98786, 1.0223e+005, 1e+010];
 IncomeRatio = [1.1758, 1.221, 1.2874, 1.2594, 1.4432, 1.5055, 1.5509, 1.5663, 1.5663];
 % Income and IncomeRatio are calculated using data in Cagetti (2003) and SCF data 
 
F = interp1(Income,IncomeRatio,x,'linear','extrap');

% Replace if less than 1 (since after tax income <= before tax income)
if F < 1
    F = 1;
end

    