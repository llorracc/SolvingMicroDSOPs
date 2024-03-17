function [points] = setup_grids_expMult(ming,maxg,ng,timestonest)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Setup a Grid                                                             %
%                                                                          % 
%   Inputs:                                                                %
%       ming - minimum value of the grid                                   %
%       maxg - maximum value of the grid                                   % 
%       ng   - the number of grid-points                                   %
%       timestonest - the number of periods                                %
%   Outputs:                                                               %
%       makegrid - a grid for search                                       % 
%                                                                          % 
%__________________________________________________________________________%
i=1;
gMaxNested = maxg;
while i <= timestonest
    gMaxNested = log(gMaxNested+1);
    i=i+1;
end;
index = gMaxNested/ng;

point = gMaxNested;
for j =1:ng;  
        points(ng-j+1) = exp(point)-1;
        point = point-index;
        for i = 2:timestonest
            points(ng-j+1) = exp(points(ng-j+1))-1;
        end;
end;
