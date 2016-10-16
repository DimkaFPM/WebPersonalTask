BeginPackage["TestArray`"]

main::usage = "main[] returns the count of vertex for test graph";
SumArray::usage = "SumArray[arr] returns the sum of all elements of array arr";

Begin["`Private`"];

g = Graph[{1 <-> 2, 2 <-> 3, 1 <-> 3}];

main[] := VertexCount[g]

SumArray[arr_] := Module[
{sumR = 0},
For[i=1, i<=Length[arr], i++, sumR+=arr[[i]] ];
Return[sumR]
]

End[]

EndPackage[]



