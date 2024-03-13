%==========================================================================%
% Solution Methods for Micro Dymanic Stochastic Optimization               %
%                                                                          %
% Perfect foresight consumption function                                   %
%                                                                          %
%   Inputs:                                                                %
%       m - needed to get the number of points to evaluate                 %
%       Constrained - indicator of whether the agent is constrained        %
%   Outputs:                                                               %
%        Various - matrices for data storage.                         	   %
%                                                                          %
%__________________________________________________________________________%

% GothicCFuncLife =  NaN ;     %(* Consumed function meaningless in last period of life *)
% GothicVFuncLife   =  repmat(0,length(m),1);
% GothicVaFuncLife  =  repmat(0,length(m),1);
% GothicVaaFuncLife =  repmat(0,length(m),1);
% 
% KoppaFuncLife = repmat(NaN,length(m),1);%(* Not well defined in last period *) Needs to be the same dimension as koppaFunc (have as many points as grid m)
% ChiFuncLife =  repmat(NaN,length(m),1);%(* Not well defined in last period *) Needs to be the same dimension as chiFunc
% KappaFuncLife =  1;
% CapitalKoppaFuncLife =  NaN; %(* Not well defined in last period *)
% CapitalChiFuncLife =  NaN;   %(* Not well defined in last period *)
% CapitalLambdaFuncLife =  NaN;%(* Not well defined in last period *)

if Constrained == 0;
    dataforinterp;
else
    dataforinterpCon;
end