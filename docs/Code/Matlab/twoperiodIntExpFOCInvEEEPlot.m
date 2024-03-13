%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Plotting the Interpolated Next-to-Last Period Problem using Inv FOC      %
%	Using a triple exponential grid for GothicAVec.                        %
%                                                                          %
%__________________________________________________________________________%

clear;
%Initialize parameters and values needed
setup_params
GothicAVec = setup_grids(GothicAMin,GothicAMax,NumOfGothicAPts,4);
%GothicAVec = [GothicAVec GothicAHuge];
[ThetaVals ThetaProb] = setup_shocks(NumOfThetaShockPoints,Sigma);

%======================
% plot comparison of interpolated consumption vs. inverse of Gothic V
% derivative
%======================
%doing calculations
m   = linspace(0, 4, 100);

dGothV = GothicVa(m,Rho,Beta,RFree,Gamma,NumOfThetaShockPoints,ThetaVals);
dGothicVInv = nP(dGothV,Rho);
gothicC = GothicC(GothicAVec,Rho,Beta,RFree,Gamma,NumOfThetaShockPoints,ThetaVals);
% em = GothicAVec+gothicC;
% gothicCP=interp1(em,gothicC,m);
gothicCP=interp1(GothicAVec,gothicC,m);
%plot
figure
    set(figure(15),'Color',[1, 1, 1]);
plot(m, dGothicVInv, m,gothicCP,'--')
    %title('Gothic v_{T-1}Raw(Blue) versus Gothic v_{T-1} Interpolated (green)')
    ylabel('(v^-_{T-1}(a_{T-1}))^{-1/\rho}, c^-_{T-1}(a_{T-1})')
    xlabel('a_{T-1}')
    axis([0 4 0 5])

%======================
% plot comparison of derivatives of Gothic V
%======================
figure
    set(figure(16),'Color',[1, 1, 1]);   
dhatGothicV = (gothicCP').^(-Rho);
plot(m,dGothV, m,dhatGothicV,'--') 
    %title('c_{T-1}(green) versus c_{T-1}(red)')
    ylabel('v^-_{T-1}(a_{T-1}),hat v^-_{T-1}(a_{T-1})')
    xlabel('m_{T-1}') 
    
%======================
% plot comparison of consumption values
%======================

%doing calculations
twoperiod;
cTm1A = interp1(mVec, Consum, m);
twoperiodIntExpFOCInv;
cTm1D = interp1(mVec, Consum, m);
GothicAVec = setup_grids(GothicAMin,GothicAMax,NumOfGothicAPts,4);
gothicC = GothicC(GothicAVec,Rho,Beta,RFree,Gamma,NumOfThetaShockPoints,ThetaVals);
mVeci = gothicC+GothicAVec;
gothicCP = interp1(mVeci,gothicC,m);
%plot
figure
    set(figure(17),'Color',[1, 1, 1]);
m = linspace(0, 4, 100);
plot(m,cTm1A, m,gothicCP,'-.') 
    %title(' c_{T-1} versus c_{T-1}')
    ylabel('c_{T-1}(m_{T-1}),c_{T-1}(a_{T-1})')
    xlabel('m_{T-1}') 
