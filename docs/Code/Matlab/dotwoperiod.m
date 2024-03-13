%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Does all the work for the two period solutions presented in the notes.   %
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
%running two period problems only
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
