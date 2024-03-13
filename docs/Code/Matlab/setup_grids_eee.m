function makegrid_eee = setup_grids_eee(ming,maxg,ng)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Setup a Grid                                                             %
%                                                                          %
%   Inputs:                                                                %
%       ming - minimum value of the grid                                   %
%       maxg - maximum value of the grid                                   %
%       ng   - the number of grid-points                                   %
%   Outputs:                                                               %
%       makegrid - a grid for search                                       % 
%                                                                          %
%__________________________________________________________________________%

gMinMin = 0.01*ming;
gMaxMax = 10*maxg;
gridMin = log(1+log(1+log(1+gMaxMax)));
gridMax = (log(1+log(1+log(1+gMaxMax)))-log(1+log(1+log(1+gMinMin))))/ng;
index = log(1+log(1+log(1+gMinMin))) + (log(1+log(1+log(1+gMaxMax)))-log(1+log(1+log(1+gMinMin))))/ng;
i=1;
point = 0;
while point < gridMin
    point = point+index;
    points(i) = point;
    i=i+1;
end;
makegrid_eee = exp(exp(exp(points)-1)-1)-1;
