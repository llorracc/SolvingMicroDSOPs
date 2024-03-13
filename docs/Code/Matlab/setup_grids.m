function makegrid = setup_grids(ming,maxg,ng,type)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Setup a Grid                                                             %
%                                                                          %
%   Inputs:                                                                %
%       ming - minimum value of the grid                                   %
%       maxg - maximum value of the grid                                   %
%       ng   - the number of grid-points                                   %
%       type - space the grid:                                             %
%               1 = equally spaced                                         %
%               2 = logarithmic spacing                                    %
%               3 = Chebyshev nodes                                        %
%               4 = Exponential grid                                       %
%                                                                          %
%   Outputs:                                                               %
%       makegrid - a grid for search                                       %                                                                          
%__________________________________________________________________________%

if type == 1;
    makegrid = (linspace(ming,maxg,ng));
elseif type == 2;
    makegrid = logspace(log(ming)/log(10),log(maxg)/log(10),ng);
elseif type == 3;
    Z=-cos((2*[1:ng]'-1)*pi/(2*ng));
    makegrid = (Z+1)*(maxg-ming)/2+ming;
    makegrid = makegrid';
elseif type == 4; 
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
    makegrid = exp(exp(exp(points)-1)-1)-1;
end;