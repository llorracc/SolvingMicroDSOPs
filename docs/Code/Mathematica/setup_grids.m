(* ::Package:: *)

(* setup_grids.m *)
(* Construct the grid of possible values of m and \[GothicA] *)

mVec = Table[mLoop,{mLoop,mMin,mMax,(mMax-mMin)/(NumOfmPts-1)}];
\[GothicA]Vec = Table[\[GothicA]Loop,{\[GothicA]Loop,\[GothicA]Min,\[GothicA]Max,(\[GothicA]Max-\[GothicA]Min)/(NumOf\[GothicA]Pts-1)}];
