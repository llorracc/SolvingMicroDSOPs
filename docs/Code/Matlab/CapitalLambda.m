function capitalLambda = CapitalLambda(m,mLowerBoundLife,DeltaGothicHLife,KappaMin,PeriodsUntilT,CapitalChiIntData,thorn,Rho,chiIntData,Constrained,GothicCInterpData)
%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Capital Lambda                                       					   %
%                                                                          %
%   Inputs:                                                                %
%		m - money balances 												   %
%		mLowerBoundLife - lower bound of money balances 				   %
%		DeltaGothicHLife - excess human wealth 							   % 
%		KappaMin - MPC 													   %
%		PeriodsUntilT - period being evaluated 							   %
%		CapitalChiIntData - data for interpolation of Capital Chi 		   %
%		thorn - the absolute patience condition 						   %
%		Rho - Coefficient of Relative Risk Aversion 					   %
%		chiIntData - data for interpolation of chi 						   % 
%		Constrained - indicator of whether the agent is constrained 	   %
%		GothicCInterpData - data for interploation of Gothic C 			   %
%   Outputs:                                                               %
%       capitalLambda - Value of capital Lambda                            %
%                                                                          %
%__________________________________________________________________________%

if PeriodsUntilT == 0;
    capitalLambda = m ;
else
   if Constrained == 0
       capitalLambda = CapitalLambdafromCapitalChi(m,mLowerBoundLife,DeltaGothicHLife,KappaMin,PeriodsUntilT,CapitalChiIntData,thorn,Rho);
   else
       capitalLambda = CapitalLambdafromCapitalChi(m,mLowerBoundLife,DeltaGothicHLife,KappaMin,PeriodsUntilT,CapitalChiIntData,thorn,Rho);
       cUnconstr = scriptCfromChi(m',mLowerBoundLife,DeltaGothicHLife,KappaMin,PeriodsUntilT,chiIntData);
       for i = 1:length(cUnconstr)
           if cUnconstr(i) > m(i)
              cWhereConstrBinds = GothicCFuncLife(GothicCInterpData,0,PeriodsUntilT+1);
              vWhereConstrBinds=u(CapitalLambdafromCapitalChi(cWhereConstrBinds,mLowerBoundLife,DeltaGothicHLife,KappaMin,PeriodsUntilT,CapitalChiIntData,thorn,Rho),Rho);
              vConstr = vWhereConstrBinds + u(m(i),Rho)- u(cWhereConstrBinds,Rho);
              capitalLambda(i) = ((1-Rho)*vConstr)^(1/(1-Rho));
           else
              capitalLambda(i) = capitalLambda(i);
           end
       end
   end
end;