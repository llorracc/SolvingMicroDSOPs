%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Approximating Precautionary Saving                                       %
%                                                                          %
%__________________________________________________________________________%

clear;
%call need parameters and grid values
setup_params
[ThetaVals ThetaProb] = setup_shocks(NumOfThetaShockPoints,Sigma);
GothicAVec = setup_grids(GothicAMin,GothicAMax, NumOfGothicAPts,1);
m = linspace(1, 30, 30);

%==============
% Plot the difference between interpolated and actual precautionary saving
%==============

%create the raw consumtpion value and consumption value using Gothic c,
%endogenous grid points and extrapolation
[mVec vList Consum yExpPDV KappaMin]=DefinecTm1Raw;
gothicC = GothicC(GothicAVec,Rho,Beta,RFree,Gamma,NumOfThetaShockPoints,ThetaVals);
emVec = GothicAVec+gothicC;
Cint = interp1(emVec,gothicC,m,'linear','extrap');
cbar = cF(mVec,yExpPDV(2),KappaMin(2));
cbarint = interp1(mVec,cbar,m,'linear','extrap');

Diff = cbarint-Cint;
Diff1 = cbarint-Consum';

%plot
figure
    set(figure(18),'Color',[1, 1, 1]);
plot(m,Diff1)
    %title(' c_{T-1} versus c_{T-1}')
    ylabel('c_{T-1} - c_{T-1}')
    xlabel('m_{T-1}')
    axis([0 30 -0.3 0.3])
    set(gca,'XTick',[5 10 15 20 25 30])
    set(gca,'YTick',[-0.3 -0.2 -0.1 0 0.1 0.2 0.3])
hold on
plot(m,Diff,'--')
legend('Truth','Approximation','Location','SouthWest')
plot(m,zeros(1,length(m)),'black')
hold off