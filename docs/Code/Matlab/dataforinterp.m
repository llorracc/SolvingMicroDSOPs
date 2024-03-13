%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% dataforinterp.m                                                          %
%                                                                          %
% Creates data matrix corresponding to the final period of life. They are  %
% used to store data used by interpolating functions within the solution   %
% method. 																   %
%                                                                          %
%__________________________________________________________________________%

chiIntData(:,:,1)= [zeros(length(m)+1,1) zeros(length(m)+1,1) zeros(length(m)+1,1)];
koppaIntData(:,:,1) = [NaN(length(m)+1,1) NaN(length(m)+1,1) NaN(length(m)+1,1)];
vInterpData(:,:,1) = [zeros(length(m)+1,1) zeros(length(m)+1,1)];
scriptcInterpData(:,:,1) = [NaN(length(m)+2,1) NaN(length(m)+2,1)];
gothiccInterpData(:,:,1) = [ NaN(length(m)+2,1)  NaN(length(m)+2,1)];
CapitalKoppaIntData(:,:,1) = [zeros(length(m)+1,1) zeros(length(m)+1,1) zeros(length(m)+1,1)];
CapitalChiIntData(:,:,1) = [zeros(length(m)+1,1) zeros(length(m)+1,1) zeros(length(m)+1,1)];
LambdaIntData(:,:,1) = [zeros(length(m)+1,1) zeros(length(m)+1,1)];