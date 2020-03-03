function values = hermite2(muVect,chiVals,chimuVals,intpoint)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Doing a Hermite approximation of the slope.                              %
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
gap = (muVect-intpoint).^2;
[val index] = min(gap);
if muVect(index) >= intpoint
    a=muVect(index-1); 
    b=muVect(index); 
    ga = chiVals(index-1); 
    gb = chiVals(index);
    dga = chimuVals(index-1);
    dgb = chimuVals(index);
elseif muVect(index) < intpoint
    a=muVect(index); 
    b=muVect(index+1); 
    ga = chiVals(index); 
    gb = chiVals(index+1);
    dga = chimuVals(index);
    dgb = chimuVals(index+1);
%elseif muVect(index) = intpoint
end;
values = Hermpol2(ga, gb, dga, dgb, a, b, intpoint);

function yi = Hermpol2(ga, gb, dga, dgb, a, b, x)
h = b-a;
d = x-a;
yi=(((6.*d.^2)./(h.^3))-((6.*d)./(h.^2))).*ga+((2.*d.*(d/h-1))./(h)).*dga+((d./h-1).^2).*dga-((2.*d.^2)./(h.^3)).*gb+(((2.*d.*(3-2.*d./h))./(h.^2))).*gb+((d.^2)./(h.^2)).*dgb+((2.*d.*(d/h-1))./h).*dgb;