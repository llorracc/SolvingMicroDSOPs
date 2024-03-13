% setup_functions.m

% CRRA marginal utility function
uP = inline('c.^(-rho)','c','rho');   

% Inverse of the CRRA marginal 
nP = inline('c.^(-1/rho)','c','rho'); 

