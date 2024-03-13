%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Plotting the Interpolated Next-to-Last Period Problem using FOCs         %
%   -Interpolated Consumption and Value Functions                          %
%                                                                          %
%__________________________________________________________________________%

clear;

twoperiodIntExpFOC;
setup_params;
[ThetaVals ThetaProb] = setup_shocks(NumOfThetaShockPoints,Sigma);

%======================
% plot comparison of derivative of Gothic v actual vs. interpolated
%======================
figure
    set(figure(10),'Color',[1, 1, 1]);
m   = linspace(0, 4, 100);
dGothvRaw = GothicVa(m,Rho,Beta,RFree,Gamma,NumOfThetaShockPoints,ThetaVals);
dGothVInterp = interp1(mVec,dGothV,m);
plot(m, dGothvRaw, m,dGothVInterp)
    %title('Gothic v_{T-1}Raw(Blue) versus Gothic v_{T-1} Interpolated (green)')
    ylabel('v^-_{T-1}, v^-_{T-1}')
    xlabel('a_{T-1}')
    axis([0 4 0 2.5])


%======================
% plot comparison of consumption values
%======================
twoperiodIntExp;
figure
    set(figure(11),'Color',[1, 1, 1]);
m = linspace(0, 4, 100);
twoperiod;
cTm1A = interp1(mVec, Consum, m);
twoperiodIntExp;
cTm1B = interp1(mVec, Consum, m);
twoperiodIntExpFOC;
cTm1C = interp1(mVec, C, m);

plot(m,cTm1A, m,cTm1B,'-.',m,cTm1C,'--') 
    %title('c_{T-1}(green) versus c_{T-1}(red)')
    ylabel('c_{T-1}')
    xlabel('m_{T-1}') 
