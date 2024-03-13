% setup_params.m
% Model parameters 

% Set baseline values of model parameters
PeriodsToSolve     = 90-25;                        % Number of periods to iterate
NumOfShockPoints   = 6;                            % Number of points in the discrete approximation to lognormal dist
SIGMAPerm          = 0.128;                        % Standard deviation of lognormal distribution of perm shocks
SIGMATran          = 0.164;                        % Standard deviation of lognormal distribution of tran shocks
 % Note: these parameters are from Carroll (1992), a little more conservative than Carroll and Samwick (1997) 
pUnemp             = 0.5/100;                      % Probability of unemployment (when unemployed inc level is zero) 
Rhat               = 1.03;                         % Gross interest rate
AlphaMin           = 0.00001;                      % Minimum point in AlphaVec (glid of possible saving)
AlphaMax           = 4;                            % Maximum point in AlphaVec
AlphaHuge          = 9000;                         % Value of Alpha at which we connect to perf foresight function
n                  = 20;                           % Number of points in AlphaVec
InitialWYRatio     = [0.17, .5, .83];              % Initial wy ratio (from the program on the paper (p.13))
InitialWYRatioProb = [.33333, .33333, .333334];    % Prob associated with initial wy ratio 
VarInitialLogInc   = .3329;                        % Variance of initial log income

% Probability of being alive after retirement 
% (1st element is the prob of being alive until age 66)
ProbOfAlive = [9.8438596e-01   9.8438596e-01   9.8438596e-01   9.8438596e-01   9.8438596e-01   9.7567062e-01   9.7567062e-01   9.7567062e-01   9.7567062e-01   9.7567062e-01   9.6207901e-01   9.6207901e-01   9.6207901e-01   9.6207901e-01   9.6207901e-01   9.3721595e-01   9.3721595e-01   9.3721595e-01   9.3721595e-01   9.3721595e-01   6.3095734e-01   6.3095734e-01   6.3095734e-01   6.3095734e-01   6.3095734e-01];
ProbOfAlive = [ones(1,PeriodsToSolve-length(ProbOfAlive)),ProbOfAlive];

% Position of match 
pi              = 0.50; % pith quantile is matched 

