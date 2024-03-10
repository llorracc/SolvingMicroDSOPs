% setup_grids.m

% Construct the grid of possible values of Alpha as a triple exponential
AlphaVec = exp(exp(exp(linspace(log(log(log(AlphaMin+1)+1)+1),log(log(log(AlphaMax+1)+1)+1),n))-1)-1)-1;
AlphaVec = [AlphaVec,AlphaHuge];

