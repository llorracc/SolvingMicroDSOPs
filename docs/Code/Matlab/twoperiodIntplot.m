%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Plotting the Interpolated Next-to-Last Period Problem                    %
%   -Interpolated Consumption and Value Functions                          %
%                                                                          %
% Plots the consumption and value functions for the two period problem.	   %
% The solution is based on optimization at the level of the utility func.  %
% A small number of points is used and then the remainder is interpolated. %
% 			                                                               %
%__________________________________________________________________________%

clear;
%call two period interpolated solution
twoperiodInt;
%======================
% plot consumption function
%======================
figure
    set(figure(4),'Color',[1, 1, 1]);
m   = linspace(0,4,100);
%cTm1PF = (m-1+yExpPDV(2))*KappaMin(2);
cintTm1 = interp1(mVec, Consum, m);  
%plot(m,cTm1,'.',m,cTm1PF)
plot(m,cintTm1)
    %title('c_{T-1}(blue dotted line) vs Perfect Foresight c_{T-1}(green)')
    ylabel('c_{T-1}')
    xlabel('m_{T-1}')
hold on
twoperiod;
cTM1 = interp1(mVec, Consum, m);
plot (m,cTM1) %only works
hold off

%======================
% plot value function
%======================
twoperiodInt;
figure
    set(figure(5),'Color',[1, 1, 1]);
m = linspace(0,4,100);
VintTM1 = interp1(mVec, vList, m);
plot(m, VintTM1), %title('v_{T-1}')
    axis([0 4 -5 0])
    ylabel('v_{T-1}')
    xlabel('m_{T-1}')
hold on
twoperiod;
VTM1 = interp1(mVec, vList, m);
plot (m,VTM1)
% hold off