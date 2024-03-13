%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Plotting the Next-to-Last Period Problem                                 %
%   -The Approximate Consumption and Value Functions                       %
%                                                                          %
% Plots the consumption and value functions for the two period problem.	   %
% The solution is based on optimization at the level of the utility func.  %
% A large number of points must be used to produce a smooth curve.		   %
% 			                                                               %
%__________________________________________________________________________%

clear;

%call two period solution
twoperiod;

%======================
% plot consumption function
%======================
figure
    set(figure(2),'Color',[1, 1, 1]);
m   = linspace(0,4,100);
%cTm1PF = (m-1+yExpPDV(2))*KappaMin(2);
cTm1 = interp1(mVec, Consum, m);  
%plot(m,cTm1,'.',m,cTm1PF)
plot(m,cTm1)
    %title('c_{T-1}(blue dotted line) vs Perfect Foresight c_{T-1}(green)')
    ylabel('c_{T-1}')
    xlabel('m_{T-1}')
%======================
% plot value function
%======================
figure
    set(figure(3),'Color',[1, 1, 1]);
m = linspace(0,4,100);
VTM1 = interp1(mVec, vList, m);
plot(m, VTM1), %title('v_{T-1}')
    axis([0 4 -5 0])
    ylabel('v_{T-1}')
    xlabel('m_{T-1}')