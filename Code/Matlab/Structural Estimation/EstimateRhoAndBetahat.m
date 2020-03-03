% EstimateRhoAndBetahat.m
% This file estimates params based on SCF data on wealth permanent income ratio, using method of simulated moment

clear all; close all;

TimeS = cputime;
disp('=======================')

% Setup 
setup_everything
disp('sigma of Perm shocks, sigma of Tran shocks, prob of unemployment')
disp([SIGMAPerm,SIGMATran,pUnemp])
setup_GList;                        % Load GList
setup_Betacorr;                     % Load corrected beta
NumOfPeriodsToSimulate = 90-55+1;   % Length of life in simulation (simulate until age 60)
NumOfPeople            = 1000;      % Number of people to simulate
NumOfPeopleBootstrap   = 1000;      % Number of people to simulate in bootstopping process
NumOfBootstrap         = 30;        % Number of times to iterate bootstapping process
setup_shocksLists                   % Set up shock lists

% Estimation
Data_SCF_wealth                          % Load data
WealthCollege = WealthPopulationCollege; % Default WealthCollege is population itself
weight        = ones(1,7);               % Weight = 1 for each of the 7 age groups
x0            = [4.0,0.99];
options=optimset('Display','final','MaxFunEvals',10000,'MaxIter',10000,'tolx',0.01,'tolfun',1); 
  % Option on display of output, # of evaluation and convergence criteria
ParamsWithPopulation  % Estimate params with population data
% Bootstrap             % Estimate params and standard errors by bootstrapping (If this is commented, standard errors are not estimated) 
 
% Display time spent 
TimeE = cputime;
disp('Time Spent (mins)')
disp((TimeE - TimeS)/60)
