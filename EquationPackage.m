BeginPackage["EquationPackage`"]

getEquation::usage = "create equation string from parameter";

Begin["`Private`"];

getEquation[arr_] :=
 Block [{r, equation, param, leftParts = {}, i, j, k, a , eq},
  For[i = 1, i <= Length[arr], i++,
   equation = 0;
   eq = arr[[i]];
   For[j = 1, j <= Length[eq], j++,
       param = eq[[j]];
       equation +=
     param[[1]]* Subscript[x[param[[2]]], param[[3]], param[[4]]];
    ];
   AppendTo[leftParts, equation];
   ];
  Return[leftParts]
  ]

End[]

EndPackage[]



