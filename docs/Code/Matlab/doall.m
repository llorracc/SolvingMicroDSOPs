%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Does all the work used to produce the solutions in the notes up to the   %
% structural estimation.                                                   %
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
discrete_approx;
twoperiodplot;
twoperiodIntplot;
twoperiodIntExpplot;
twoperiodIntExpFOCplot;
twoperiodIntExpFOCInvPlot;
twoperiodIntExpFOCInvEEEPlot;
ExtrapProblemPlot;
ExtrapProblemSolvedPlot;
twoPeriodIntExpFOCInvPesReaOptPlot;
twoPeriodIntExpFOCInvPesReaOptConPlot;
multiperiodPlot;
multiperiodConPlot;
multicontrolPlot;
