BeginPackage["EquationPackage`"]

getEquation::usage = "create equation string from parameter";

Begin["`Private`"];

getEquation[arr_] := Block [{r, equation, param, i, j, k, a },
  leftParts = List[];

  For[i = 1, i <= Length[arr], i++,
    eq = arr[[i]];
    equation = 0;
    For[j = 1, j <= Length[eq], j++,
         param = eq[[j]];

      equation +=
       param[[1]]*Subscript[x[param[[2]]], param[[3]], param[[4]]]
      ]
     AppendTo[leftParts, equation];
    ]
   	Return leftParts
  ]

End[]

EndPackage[]



