%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% 2PeriodIntExpFOCInvPesReaOpt!Plot.m                                      %
%	Uses the method of moderation to plot the difference between 		   %
% 	consumption using optimization and that using the method of moderation %
%	to obtain chi and the interpolating. 								   %
%                                                                          %
%__________________________________________________________________________%

clear;
twoPeriodIntExpFOCInvPesReaOpt2;
%==============
% Plot the difference between interpolated and actual precautionary saving
%==============
%plot
figure
    set(figure(20),'Color',[1, 1, 1]);
plot(m,Diff)
    %title(' c_{T-1} versus c_{T-1}^{\chi}')
    ylabel('c_{T-1} - c_{T-1}')
    xlabel('m_{T-1}')
hold on
m = linspace(0, 30, 30);
plot(m,zeros(1,length(m)),'black')
hold off