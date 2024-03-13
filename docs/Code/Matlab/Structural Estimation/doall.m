%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Does all the work used for the structural estimation.                    %
% 			                                                               %
%__________________________________________________________________________%
%================
%   clean up
%================
clc;
clear;
close all;
fclose('all');
%================
%running all problems
%================
EstimateRhoAndBetahat;
plotWealthPermIncRatio;
plotFigA1_ProbOfALive;
plotFigA1_ProbOfALive;
plotFigA2_Beta;
plotFigA3_G; 