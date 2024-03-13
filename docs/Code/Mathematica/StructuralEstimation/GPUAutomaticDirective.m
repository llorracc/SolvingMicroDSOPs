(* ::Package:: *)

OpenCLInformation[];


(*This will automatically look for the first GPU devices. *)
ClearAll[i, iGPU, GPUDeviceNo,TypeThis];
For[i=1,i<=10, i++,
TypeThis=OpenCLInformation[1,i,"Type"];
If[TypeThis == "GPU", Break[];];
];
iGPU=i;
GPUDeviceNo=iGPU;
Print["The GPU device is of No. ", GPUDeviceNo, 
"."];


ClearAll[GPUVendor];
GPUVendor=OpenCLInformation[1,GPUDeviceNo, "Vendor"];
(* GOUVendor could have three types of answers:
"NVIDIA" or "NVIDIA Corporation"
, "AMD"
, "Intel" *)
Print["The GPU vendor is ", GPUVendor, 
"."];


ClearAll[WhichGPUToUse];
Subscript[(WhichGPUToUse=If[GPUVendor=="AMD"
, "OPENCLLINK_USING_ATI"
, "OPENCLLINK_USING_NVIDIA"];), Subscript[\[Placeholder], \[Placeholder]]]
Print["The Correct GPU Define is ", WhichGPUToUse, 
"."];


(*This will be used in loading OpenCLFunctionLoad[] part. *)
(*
"Defines"->{"USING_OPENCL_FUNCTION"->1,WhichGPUToUse,
"mint"->"int","Real_t"->"float"}
*)
