%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Plotting the Interpolated Next-to-Last Period Problem                    %
%   -Interpolated Consumption and Value Functions                          %
%                                                                          %
% Plots the Gothic v, consumption, value functions and two explicit values %
% of marginal Gothic V for the two period problem. The solution is based   %
% on optimization of the FOC of the utility func. A comparison is presented%
% between the direct calculation of Gothic v and interpolation from values %
% obtained from the optimization. 		   								   %
% 			                                                               %
%__________________________________________________________________________%
clear;
%do the work
twoperiodIntExp;
setup_params;
%======================
% plot comparison of Gothic v functions
%======================
figure
    set(figure(6),'Color',[1, 1, 1]);
m   = linspace(0, 4, 100);
GothvTm1Raw = GothicV(m,Rho,Beta,RFree,Gamma,NumOfThetaShockPoints,ThetaVals); 
GothvTm1InterpFunc = interp1(mVec,GothVb,m);
plot(m, GothvTm1Raw, m,GothvTm1InterpFunc)
    %title('Gothic v_{T-1}Raw(Blue) versus Gothic v_{T-1} Interpolated (green)')
    ylabel('v_{T-1}')
    xlabel('m_{T-1}')
%======================
% plot comparison of value functions
%======================
figure
    set(figure(7),'Color',[1, 1, 1]);
m = linspace(0, 4, 100);
plot(mVec, vList,'-.')
    %title('Gothic v_{T-1}Raw(Blue) versus Gothic v_{T-1} Interpolated (green)')
    ylabel('v_{T-1}')
    xlabel('m_{T-1}')
    axis([0 4 -5 0])
    hold on
twoperiodInt;
plot(mVec, vList,'--')
twoperiod;
VTM1 = interp1(mVec, vList, m);
plot (m,VTM1)
hold off

%======================
% plot comparison of consumption values
%======================
twoperiodIntExp;
figure
    set(figure(8),'Color',[1, 1, 1]);
m = linspace(0, 4, 100);
cTm1PF = cF(m,yExpPDV(2),KappaMin(2));
cTm1 = interp1(mVec, Consum, m);
twoperiodInt;
cTm2 = interp1(mVec, Consum, m);
%plot(m,cTm1PF,m,cTm1, m,cTm2) 
    %title('c_{T-1}(green) versus c_{T-1}(red)')
plot(m,cTm1, m,cTm2) 
    %title('c_{T-1}(green) versus c_{T-1}(red)')
    ylabel('c_{T-1}')
    xlabel('m_{T-1}')

%======================
% plot comparison of derivative values
%======================
setup_params;
figure
    set(figure(9),'Color',[1, 1, 1]);
c = linspace(0.1, 4, 80);
%initalize before loop
up = zeros(length(c),1)';
for i = 1:length(c)
    up(i) = uP(c(i),Rho);
end;
Vp1 = (GothicV(3-c+0.001,Rho,Beta,RFree,Gamma,NumOfThetaShockPoints,ThetaVals)-GothicV(3-c-0.001,Rho,Beta,RFree,Gamma,NumOfThetaShockPoints,ThetaVals))/0.002;
Vp2 = (GothicV(4-c+0.001,Rho,Beta,RFree,Gamma,NumOfThetaShockPoints,ThetaVals)-GothicV(4-c-0.001,Rho,Beta,RFree,Gamma,NumOfThetaShockPoints,ThetaVals))/0.002;
vinterp1 = (interp1(GothicA,Goth,3-c+0.001)-interp1(GothicA,Goth,3-c-0.001))/0.002;
vinterp2 = (interp1(GothicA,Goth,4-c+0.001)-interp1(GothicA,Goth,4-c-0.001))/0.002;
plot(c,up,c, Vp1,c, Vp2,c,vinterp1,c, vinterp2)
axis([0 3.5 0 0.8])
%title('up(c) versus GothVp(3-c), GothVp(4-c),GothVinterpp(3-c),GothVinterpp(4-c)')
    xlabel('c_{T-1}')
    ylabel('v_{T-1}(m_{T-1}- c_{T-1}),u(c_{T-1})')