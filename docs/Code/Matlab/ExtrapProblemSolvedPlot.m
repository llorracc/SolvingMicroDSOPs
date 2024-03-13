%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Approximating Precautionary Saving Using Method of Moderation            %
%                                                                          %
%__________________________________________________________________________%

clear;
twoPeriodIntExpFOCInvPesReaOpt;
%plot
figure
    set(figure(19),'Color',[1, 1, 1]);
plot(m,Diff1)
    %title(' c_{T-1} versus c_{T-1}^{\chi}')
    ylabel('c_{T-1} - c_{T-1}')
    xlabel('m_{T-1}')
    axis([0 30 -0.3 0.3])
    set(gca,'XTick',[5 10 15 20 25 30])
    set(gca,'YTick',[-0.3 -0.2 -0.1 0 0.1 0.2 0.3])
hold on
plot(m,Diff,'--')
legend('Truth','Approximation','Location','SouthWest')
m = linspace(0, 30, 30);
plot(m,zeros(1,length(m)),'black')
hold off