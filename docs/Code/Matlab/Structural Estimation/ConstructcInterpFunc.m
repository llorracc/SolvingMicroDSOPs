% ConstructcInterpFunc.m 

% Construct matrix of interpolation data
C = (0:n+1)'; 
M = (0:n+1)'; 
for l=1:PeriodsToSolve
  Beta         = (GList(length(GList)-l+1)^(1 - x(1)))*x(2)*Betacorr(length(Betacorr)-l+1);
  R            = Rhat/GList(length(GList)-l+1);
  P            = ProbOfAlive(length(ProbOfAlive)-l+1);  % Probability of being alive until next period 
  ThetaVec     = ThetaMat(length(ThetaMatProb)-l+1,:);
  ThetaVecProb = ThetaMatProb(length(ThetaMatProb)-l+1,:);
  PermVec      = PermMat(length(ThetaMatProb)-l+1,:);
  
 % Calculate ct from each grid point in AlphaVec
  ChiVec = nP(P*GothVP(AlphaVec,x(1)),x(1)); % Inverse Euler equation, P*GothVP(a,rho) is expected value given savings amount a
  MuVec  = AlphaVec+ChiVec;
  M      = [M, [0,MuVec]'];                  % Matrix of interpolation data
  C      = [C, [0,ChiVec]'];                 % Matrix of interpolation data
end;


