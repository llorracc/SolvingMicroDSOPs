% GothVP.m
% Gothic V prime function

function EUP = GothVP(a,rho)

% Another M-file function, Cnextp, is also involved in running this program

global Rhat uP nP ThetaVec ThetaVecProb PermVec PermVecProb Beta R

% EUP is used to take the sum of marginal utilities UP weighted by probabilities
EUP = zeros(size(a)); 

for i=1:length(ThetaVec)
  for j=1:length(PermVec)
    PermVal = PermVec(j);
    ThetaVal = ThetaVec(i);
    EUP     = EUP + Beta.*R...
    .*uP(PermVal.*Cnextp(R.*a./PermVal+ones(1,length(EUP)).*ThetaVal),rho).*ThetaVecProb(i)...
	.*PermVecProb(j);       
  end;
end;