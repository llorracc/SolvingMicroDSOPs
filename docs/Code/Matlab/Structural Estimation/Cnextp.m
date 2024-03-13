% Cnextp.m
% Ct+1 function 

function c = Cnextp(m)
% Cnextp is constructed by interpolation to be the next-period consumption function Ct+1()

global M C

mtp1 = M(:,end);  % data for the next-period consumption function
ctp1 = C(:,end);  % data for the next-period consumption function

c = zeros(size(m));

% extrapolate above maximal m
iAbove = m >= mtp1(end);
slopeAbove  = (ctp1(end)-ctp1(end-1))/(mtp1(end)-mtp1(end-1));
c(iAbove)   = ctp1(end) + (m(iAbove)-mtp1(end))*slopeAbove;

% extrapolate below minimal m
iBelow = m <= mtp1(1);
slopeBelow  = 1;
c(iBelow)   = ctp1(1) + (m(iBelow)-mtp1(1))*slopeBelow;

% interpolate
iInterp = ~(iAbove | iBelow);
c(iInterp)  = interp1(mtp1,ctp1,m(iInterp));  

