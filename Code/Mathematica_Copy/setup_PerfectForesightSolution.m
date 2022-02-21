(* ::Package:: *)

(* Perfect foresight consumption function; \[Digamma] stands for 'foresight' *)

\[ScriptC]\[Digamma][mt_,PeriodsUntilT_]:=\[Kappa]MinLife[[PeriodsUntilT+1]](mt + \[GothicH]ExpLife[[PeriodsUntilT+1]]);
 
\[ScriptC]\[Digamma]Pes[mt_,PeriodsUntilT_]:=\[Kappa]MinLife[[PeriodsUntilT+1]](mt + \[GothicH]MinLife[[PeriodsUntilT+1]]);

\[Kappa]\[Digamma][mt_,PeriodsUntilT_]:=\[Kappa]MinLife[[PeriodsUntilT+1]];

\[GothicC]\[Digamma][at_,PeriodsUntilT_]:=(1-\[Kappa]MinLife[[PeriodsUntilT+1]])^(-1)* \[ScriptC]\[Digamma][at + \[GothicH]ExpLife[[PeriodsUntilT+1]], PeriodsUntilT];

\[GothicC]\[Digamma]a[at_,PeriodsUntilT_]:=\[Kappa]MinLife[[PeriodsUntilT+1]]/(1-\[Kappa]MinLife[[PeriodsUntilT+1]]);

(* Perfect foresight value function *)
\[ScriptV]\[Digamma][mt_,PeriodsUntilT_]:=u[\[ScriptC]\[Digamma][mt,PeriodsUntilT]]vSumLife[[PeriodsUntilT+1]];
\[ScriptV]\[Digamma]Pes[mt_,PeriodsUntilT_]:=u[\[ScriptC]\[Digamma]Pes[mt,PeriodsUntilT]]vSumLife[[PeriodsUntilT+1]];

(* Perfect foresight marginal value function *)
\[ScriptV]\[Digamma]m[mt_,PeriodsUntilT_]:=uP[\[ScriptC]\[Digamma][mt,PeriodsUntilT]]\[Kappa]MinLife[[PeriodsUntilT+1]]vSumLife[[PeriodsUntilT+1]];

(* Perfect foresight marginal marginal value function *)
\[ScriptV]\[Digamma]mm[mt_,PeriodsUntilT_]:=uPP[\[ScriptC]\[Digamma][mt,PeriodsUntilT]](\[Kappa]MinLife[[PeriodsUntilT+1]])^2 vSumLife[[PeriodsUntilT+1]];

(* Perfect foresight Gothic (end-of-period) value function *)
\[GothicV]\[Digamma][at_,PeriodsUntilT_]:=u[\[GothicC]\[Digamma][at,PeriodsUntilT]](vSumLife[[PeriodsUntilT+1]]-1);

(* Perfect foresight Gothic marginal value function *)
\[GothicV]\[Digamma]a[at_,PeriodsUntilT_]:=uP[\[GothicC]\[Digamma][at,PeriodsUntilT]]\[GothicC]\[Digamma]a[at,PeriodsUntilT](vSumLife[[PeriodsUntilT+1]]-1);

(* Perfect foresight Gothic marginal marginal value function *)
\[GothicV]\[Digamma]aa[at_,PeriodsUntilT_]:=uPP[\[GothicC]\[Digamma][at,PeriodsUntilT]](\[GothicC]\[Digamma]a[at,PeriodsUntilT])^2 (vSumLife[[PeriodsUntilT+1]]-1);

SetAttributes[{\[ScriptC]\[Digamma],\[GothicC]\[Digamma],\[GothicC]\[Digamma]a,\[ScriptV]\[Digamma],\[ScriptV]\[Digamma]m,\[ScriptV]\[Digamma]mm,\[GothicV]\[Digamma],\[GothicV]\[Digamma]a,\[GothicV]\[Digamma]aa}, Listable];
