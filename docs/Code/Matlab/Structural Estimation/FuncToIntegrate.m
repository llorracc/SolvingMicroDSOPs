% FuncToIntegrate.m
% Function used to integrate in DiscreteApproxToMeanOneLogNormal

function F = FuncToIntegrate(x)

global LevelAdjustingParameter sigma 

F = x.*lognpdf(x,LevelAdjustingParameter,sigma);
