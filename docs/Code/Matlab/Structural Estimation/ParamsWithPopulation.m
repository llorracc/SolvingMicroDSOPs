% ParamsWithPopulation.m
% This file estimates params with population data

[xMin,fval]   = fminsearch(@ObjectFunction,x0,options); 

% Display results
disp('Estimated params with population data')
disp('Rho, Betahat:')
disp(xMin)