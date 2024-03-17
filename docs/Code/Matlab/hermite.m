function values = hermite(muVect,chiVals,chimuVals,intpoint)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Doing a Hermite approximation of the level.                              %
%                                                                          %
%   Inputs:                                                                %
%       muVect - vector of mus (x) 										   %
%		chiVals - vector of corresponding chi values (f(x)) 			   %
%		chimuVals - vector of corresponding chimu values (f'(x)) 		   %
%		intpoint - point to do the interpolation at                        %
%   Outputs:                                                               %
%       KappafromChi - MPC                                                 %
%                                                                          %
%__________________________________________________________________________%
%gap = abs(muVect-intpoint);
gap = (muVect-intpoint).^2;
[val index] = min(gap);
if muVect(index) >= intpoint
    a=muVect(index-1); 
    b=muVect(index); 
    ga = chiVals(index-1); 
    gb = chiVals(index);
    dga = chimuVals(index-1);
    dgb = chimuVals(index);
    values = Hermpol(ga, gb, dga, dgb, a, b, intpoint);
elseif muVect(index) < intpoint
    a=muVect(index); 
    b=muVect(index+1); 
    ga = chiVals(index); 
    gb = chiVals(index+1);
    dga = chimuVals(index);
    dgb = chimuVals(index+1);
    values = Hermpol(ga, gb, dga, dgb, a, b, intpoint);
% elseif muVect(index) == intpoint
%     values = intpoint;
end;


%----------------------
% The following is taken from Math 465 Numerical Analysis with MATLAB at SIUC
 function yi = Hermpol(ga, gb, dga, dgb, a, b, xi)
% Two-point cubic Hermite interpolant. Points of interpolation
% are a and b. Values of the interpolant and its first order
% derivatives at a and b are equal to ga, gb, dga and dgb,
% respectively.
% Vector yi holds values of the interpolant at the points xi.
h = b - a;
t = (xi - a)./h;
t1 = 1 - t;
t2 = t1.*t1;
yi = (1 + 2*t).*t2*ga + (3 - 2*t).*(t.*t)*gb + h.*(t.*t2*dga + t.^2.*(t - 1)*dgb);


