%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% multicontrolPlot.m                                                       %
%	Plots the solution to the multicontrol problem. 					   %
%                                                                          %
%__________________________________________________________________________%
clear;
multicontrol;

conplot = consumption(:,19);
%plot
figure
    set(figure(24),'Color',[1, 1, 1]);
plot(m,conplot)
    %title(' c_{T-1} versus c_{T-1}^{\chi}')
    ylabel('c_{T-1}')
    xlabel('m_{T-1}')
    axis([0 4 0 1.23])
    
%plot
figure25= figure('Color',[1, 1, 1]);
plot(a,VSig)
    ylabel('\varsigma')
    xlabel('a')
    axis([0 6 0 1.01])
hold on
plot(a,MertSamRiskyShare)
annotation(figure25,'arrow',[0.2724 0.2724],[0.3002 0.2536],'HeadLength',6,...
    'HeadStyle','vback3');
annotation(figure25,'textbox',[0.1595 0.3002 0.2800 0.09198],...
    'String',{'Limit as a approaches \infty'},...
    'FitBoxToText','off',...
    'LineStyle','none');
hold off
