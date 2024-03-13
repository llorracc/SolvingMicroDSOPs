% DiscreteApproxToMeanOneLogNormal.m
% Function which is used for constructing shock vectors (PermVec, TranVec, PermShockDraws, TranShockDraws) 
 
function shocklist= DiscreteApproxToMeanOneLogNormal(std,numofshockpoints)

global LevelAdjustingParameter sigma 
 % need to declare global variables since these are used in function FuncToIntegrate

LevelAdjustingParameter = -(1/2)*(std)^2;
for i=1:numofshockpoints-1
    ListOfEdgePoints(i) = logninv(i/numofshockpoints,LevelAdjustingParameter,std);
end

sigma = std; 

shocklist(1) = quad(@FuncToIntegrate,0,ListOfEdgePoints(1))*numofshockpoints;
for i=2:numofshockpoints-1
    shocklist(i) = quad(@FuncToIntegrate,ListOfEdgePoints(i-1),ListOfEdgePoints(i))*numofshockpoints;
end
shocklist(numofshockpoints) = quad(@FuncToIntegrate,ListOfEdgePoints(numofshockpoints-1),10)*numofshockpoints;
