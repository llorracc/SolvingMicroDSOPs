%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% 2PeriodIntExpFOCInvPesReaOptCon!Plot.m                                   %
% 	Plots the consumption levels obtained from the method of moderation    %
%	the two period problem. 											   %
%                                                                          %
%__________________________________________________________________________%

clear;
twoPeriodIntExpFOCInvPesReaOptCon;
%plot
figure
    set(figure(21),'Color',[1, 1, 1]);
plot(m,cfromChi,'--')
    %title(' c_{T-1} versus c_{T-1}^{\chi}')
    ylabel('c_{T-1}, c_{T-1}')
    xlabel('m_{T-1}')
    axis([0 4 0 2.5])
    set(gca,'XTick',[1 2 3 4])
    set(gca,'YTick',[0.5 1.0 1.5 2.0])
hold on
plot(m,scriptc)
hold off