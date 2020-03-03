(* ::Package:: *)

(* setup_grids _eee.m *)
(* Construct the grid of possible values of \[GothicA] as a triple exponential *)
\[GothicA]MinMin = 0.01 \[GothicA]Min;
\[GothicA]MaxMax = 10  \[GothicA]Max;
lll\[GothicA]Vec = 
  Table[
   \[GothicA]Loop,
   {\[GothicA]Loop,
    Log[1+Log[1+Log[1+\[GothicA]MinMin]]]+(Log[1+Log[1+Log[1+\[GothicA]MaxMax]]]-Log[1+Log[1+Log[1+\[GothicA]MinMin]]])/NumOf\[GothicA]Pts,
    Log[1+Log[1+Log[1+\[GothicA]MaxMax]]],
   (Log[1+Log[1+Log[1+\[GothicA]MaxMax]]]-Log[1+Log[1+Log[1+\[GothicA]MinMin]]])/NumOf\[GothicA]Pts
   }];

mVect = \[GothicA]Vec = Exp[Exp[Exp[lll\[GothicA]Vec]-1]-1]-1 //N;
