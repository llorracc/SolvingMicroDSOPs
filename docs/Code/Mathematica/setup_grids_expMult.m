(* ::Package:: *)

(* setup_grids _expMult.m *)

\[GothicA]MaxNested  = Nest[Log[#+1]&,\[GothicA]Max,TimesToNest]//N;

mVec = \[GothicA]Vec = 
  Table[Nest[Exp[#]-1 &,aNestLoop,TimesToNest]
    ,{aNestLoop,\[GothicA]MaxNested/GridLength,\[GothicA]MaxNested,\[GothicA]MaxNested/GridLength}]; 


