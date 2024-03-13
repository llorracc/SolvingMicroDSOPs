%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% dataforinterpCon.m                                                       %
%                                                                          %
% Creates data matrix corresponding to the final period of life. They are  %
% used to store data used by interpolating functions within the solution   %
% method. 																   %
%                                                                          %
%__________________________________________________________________________%

chiIntData(:,:,1)= [zeros(length(m)+2,1) zeros(length(m)+2,1) zeros(length(m)+2,1)];
koppaIntData(:,:,1) = [zeros(length(m)+2,1) zeros(length(m)+2,1) zeros(length(m)+2,1)];
vInterpData(:,:,1) = [zeros(length(m)+2,1) zeros(length(m)+2,1)];
scriptcInterpData(:,:,1) = [zeros(length(m)+3,1) zeros(length(m)+3,1)];
gothiccInterpData(:,:,1) = [zeros(length(m)+3,1) zeros(length(m)+3,1)];
CapitalKoppaIntData(:,:,1) = [zeros(length(m)+2,1) zeros(length(m)+2,1) zeros(length(m)+2,1)];
CapitalChiIntData(:,:,1) = [zeros(length(m)+2,1) zeros(length(m)+2,1) zeros(length(m)+2,1)];
LambdaIntData(:,:,1) = [zeros(length(m)+2,1) zeros(length(m)+2,1)];