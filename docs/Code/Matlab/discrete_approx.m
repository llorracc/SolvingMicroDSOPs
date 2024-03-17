%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
%  Plotting discrete approximation of shocks                               %
%                                                                          %
%__________________________________________________________________________%

NumOfThetaShockPoints=7;
SIGMA_DA =0.1;

[ThetaVals_DA ThetaProb_DA] = setup_shocks(NumOfThetaShockPoints,SIGMA_DA);

figure
    %set(figure,'Position',[700,500,700,500])
    set(figure(1),'Color',[1, 1, 1]);
m   = logncdf(ThetaVals_DA,-1/2*(SIGMA_DA)^2,SIGMA_DA);
b   = linspace(0.7, 1.28,100);
d   = logncdf(b,-1/2*(SIGMA_DA)^2,SIGMA_DA);
%plot(ThetaVals_DA, m, 'b:p', b,d)
hold on
plot(ThetaVals_DA, m, 'o','MarkerEdgeColor','k','MarkerFaceColor','k','MarkerSize',8)%, b,d)
plot(b,d,'-k')
    axis([0.7,1.28,0,1])
    grid
    set(gca,'XGrid','off','YGrid','on','ZGrid','off')
    title('Discrete Approximation to Lognormal Distribution', 'FontSize', 12)
    xlabel('\theta');
    ylabel('CDF'); 
hold off