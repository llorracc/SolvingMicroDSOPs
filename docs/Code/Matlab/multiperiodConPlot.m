%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% multiperiodConplot.m                                                     %
% 	Plotting the constrained multiperiod problem. 						   %
%                                                                          %
%__________________________________________________________________________%
clear;

multiperiodCon;

conplot = [consumption(:,1) consumption(:,5) consumption(:,10) consumption(:,15) consumption(:,20)];
%plot
figure
    set(figure(23),'Color',[1, 1, 1]);
plot(m,conplot)
    %title(' c_{T-1} versus c_{T-1}^{\chi}')
    ylabel('c_{T-1}')
    xlabel('m_{T-1}')
    axis([0 4 0 2])