BeginPackage["Labs23Solver`"]

SolveLabs23::eqnpartsmismatch="There are `1` left parts and `2` right parts.";
SolveLabs23::nobalance="Bad a's for flow type `1`: sum `2` is not 0.";
SolveLabs23::badnode="Wrong node number `1`: it must be in range [1, `2`].";
SolveLabs23::unknownarc="Arc `1` for flow `2` is mentioned in Ut or Uc, but not in U.";
SolveLabs23::nottree="Ut arcs for flow `1` do not form a spanning tree.";
SolveLabs23::wronguccount="Total size of all Uc's must be equal to the number of equations.";
SolveLabs23::ucuthavecommon="Uc and Ut for flow type `1` have some common arcs.";
SolveLabs23::badeqn="Equation no. `1` has some unrecognized tokens in left part: `2` != 0.";
getEquation::usage = "create equation string from parameter";
getSubscription::usage = "create equation string from parameter";
TestSolve::usage = "create equation string from parameter";

Begin["`Private`"]
(*
Table[expr, n] - generates a list of n copies of expr. 
*)
getEquation[arr_, x_] :=
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
  ];

getSubscription[arr_,a_] :=
  Block [{i},
    For[i = 1, i <= Length[arr], i++,
      Subscript[a,i]=arr[[i]];
     ];
  ];

TestSolve[ x_, y_, ks_,is_,UArray_, UtArray_, UcArray_, aArray_,leftParts_,rightParts_]:=Block[{U,Ut,Uc,a},
getSubscription[UArray, U];
getSubscription[UtArray, Ut];
getSubscription[UcArray, Uc];
getSubscription[aArray, a];
lefts=getEquation[leftParts,x];
Return[SolveLabs23[x,y,ks,is,U,Ut,Uc,a,lefts,rightParts]];
]

BuildNodeEquations[x_,u_,rightParts_]:=Block[{nodeBalanceList=Table[0,{Length[rightParts]}],res={},i},
Clear[x];
Do[Block[{a=arc[[1]],b=arc[[2]]},
nodeBalanceList[[a]]+=Subscript[x, a,b];
nodeBalanceList[[b]]-=Subscript[x, a,b];
],{arc,u}];
For[i=1,i<=Length[rightParts],++i,AppendTo[res,nodeBalanceList[[i]]==rightParts[[i]]]];
Return[res];
];

BuildThreadPredDir[is_,ut_,root_]:=Block[{
thread={},
pred=Table[0,{is}],
dir=Table[0,{is}],
used=Table[False,{is}],
queue={root},
v,a,b},

used[[root]]=True;
While[Length[queue]>0,
v=First[queue];
thread=Append[thread,v];
queue=Delete[queue,1];
(*Print["in vertex ",v];*)
Do[Do[
a=pair[[i]];
b=pair[[3-i]];
(*Print["considering edge ",u," ",w];*)
If[a==v&&!(used[[b]]),
pred[[b]]=v;
dir[[b]]=If[i==1,+1,-1];
queue=Append[queue,b];
used[[b]]=True;
];
,{i,{1,2}}],
{pair,ut}]
];
thread=Reverse[thread];
Return[{thread,pred,dir}];
];

FindTreeDeltas[x_,thread_,pred_,dir_,system0_,\[Delta]_]:=Block[{
system1=system0/.\[Delta],
tmpd=\[Delta],
is=Length[system0],
i,t,pt,from,to,solvingResult},
(* Fill the system with known vars *)
(* Determining the rest of \[Delta] *)
For[i=1,i<=is-1,i++,{
t=thread[[i]];
pt=pred[[t]];
from=If[dir[[t]]==1,pt,t];
to=If[dir[[t]]==1,t,pt];
solvingResult=Solve[system1[[t]],Subscript[x, from,to]][[1]];
If[pred[[pt]]!=0,
system1[[pt]]=system1[[pt]]/.solvingResult];
tmpd=Join[tmpd,solvingResult];
}];
Return[tmpd];
];

BuildOutOfTreeArcs[u_,ut_]:=Block[{outOfTreeArcs},
outOfTreeArcs={};
Do[If[!MemberQ[ut,arc],AppendTo[outOfTreeArcs,arc]],{arc,u}];
Return[outOfTreeArcs];
];

SolveLabs23::eqnpartsmismatch="There are `1` left parts and `2` right parts.";
SolveLabs23::nobalance="Bad a's for flow type `1`: sum `2` is not 0.";
SolveLabs23::badnode="Wrong node number `1`: it must be in range [1, `2`].";
SolveLabs23::unknownarc="Arc `1` for flow `2` is mentioned in Ut or Uc, but not in U.";
SolveLabs23::nottree="Ut arcs for flow `1` do not form a spanning tree.";
SolveLabs23::wronguccount="Total size of all Uc's must be equal to the number of equations.";
SolveLabs23::ucuthavecommon="Uc and Ut for flow type `1` have some common arcs.";
SolveLabs23::badeqn="Equation no. `1` has some unrecognized tokens in left part: `2` != 0.";

SolveLabs23[x_,y_,ks_,is_,u0_,ut0_,uc0_,a0_,longSystemLeftParts_,longSystemRightParts_]:=Block[{
fullSystem={},
roots={},
\[Delta]s,\[Delta]hs,allArcs={},zeroForArcs,
allEqs=Length[longSystemLeftParts],
i,eqNo,A,\[Beta],Y,DD,rule1,rule2,solution,yPtr,testResult
},

(* We construct full system of equations from given graph description and long equation left and right parts. *)
If[Length[longSystemLeftParts]!=Length[longSystemRightParts],Message[SolveLabs23::eqnpartsmismatch,Length[longSystemLeftParts],Length[longSystemRightParts]];Abort[]];
Do[fullSystem=Join[fullSystem,BuildNodeEquations[x,Subscript[u0, k],Subscript[a0, k]]/.{x->x[k]}],{k,ks}];
For[i=1,i<=Length[longSystemLeftParts],++i,
AppendTo[fullSystem,longSystemLeftParts[[i]]==longSystemRightParts[[i]]];
];
Print["Full system of equations to be solved: ",fullSystem];

(* For internal use only: make a list of all arcs (all flow types together) *)
Do[AppendTo[allArcs,Subscript[u0, k]],{k,ks}];
allArcs=Union[Flatten[allArcs, 1]];
Do[Subscript[zerosForArcs, arc[[1]],arc[[2]]]=0,{arc,allArcs}];


(* Perform simple input data validation with trivial error reporting *)
If[Max[Flatten[allArcs]]>is,Message[SolveLabs23::badnode,Max[Flatten[allArcs]],is];Abort[]];
If[Min[Flatten[allArcs]]<1,Message[SolveLabs23::badnode,Min[Flatten[allArcs]],is];Abort[]];
Do[
If[Total[Subscript[a0, k]]!=0,Message[SolveLabs23::nobalance,Total[Subscript[a0, k]],k];Abort[]];
If[Length[Subscript[ut0, k]]!=is-1,Message[SolveLabs23::nottree,k];Abort[]];
If[Length[Union[Subscript[uc0, k],Subscript[ut0, k]]]!=Length[Subscript[uc0, k]]+Length[Subscript[ut0, k]],Message[SolveLabs23::ucuthavecommon,k];Abort[]];
Do[If[!MemberQ[Subscript[u0, k],arc],Message[SolveLabs23::unknownarc,arc,k];Abort[]],{arc,Join[Subscript[uc0, k],Subscript[ut0, k]]}];
,{k,ks}];
If[Total[Table[Length[Subscript[uc0, k]],{k,ks}]]!=allEqs,Message[SolveLabs23::wronguccount];Abort[]];
For[eqNo=1,eqNo<=allEqs,++eqNo,Block[{eq,localZerosForArcs,unk},
eq=longSystemLeftParts[[eqNo]];
Do[
Do[Subscript[localZerosForArcs, arc[[1]],arc[[2]]]=0,{arc,Subscript[u0, k]}];
eq=eq/.{x[k]->localZerosForArcs};
eq=eq/.{localZerosForArcs->unk[k]};
Do[Subscript[localZerosForArcs, arc[[1]],arc[[2]]]=.,{arc,Subscript[u0, k]}];
,{k,ks}];
eq=Simplify[eq];
If[Count[{eq},0]!=1,Message[SolveLabs23::badeqn,eqNo,eq];Abort[]];
]];


Print["STAGE 1"];
Do[Block[{u,ut,\[Delta],root,thread,pred,dir,system0,outOfTreeArcs},
Print["\n*** FLOW TYPE ",k," ***"];
u=Subscript[u0, k];ut=Subscript[ut0, k];
\[Delta]=\[Delta]s[k];
(* Take any vertex of the tree for kth flow as root *)
root=First[DeleteDuplicates[Flatten[ut]]];
AppendTo[roots,root];

(* Calculating thread, pred, dir *)
{thread,pred,dir}=BuildThreadPredDir[is,ut,root];
Print["thread: ",thread];
Print["pred: ",pred];
Print["dir: ",dir];

(* Check the tree is correct *)
If[Count[pred,0]!=1,Message[SolveLabs23::nottree,k];Abort[]];

(* Forming system *)
system0=BuildNodeEquations[x,u,Table[0,{is}]];
Print["System for flow type ",k,": ",system0];

(* Find arcs that do not belong to tree *)
outOfTreeArcs=BuildOutOfTreeArcs[u,ut];
Print["------------------------------------"];

Do[Block[
{a=arcToAdd[[1]],b=arcToAdd[[2]]},
Print["Arc to add: ",a,", ",b];

Subscript[\[Delta], a,b]={};
Do[AppendTo[Subscript[\[Delta], a,b],Subscript[x, arc[[1]],arc[[2]]]->If[arc==arcToAdd, 1,0]],{arc,outOfTreeArcs}];
Subscript[\[Delta], a,b]=FindTreeDeltas[x,thread,pred,dir,system0,Subscript[\[Delta], a,b]];

Print[Subsuperscript["\[Delta]",StringJoin[ToString[a],",",ToString[b]],k]," = ",Subscript[\[Delta], a,b]];
Print["Test: ",Simplify[system0/.Subscript[\[Delta], a,b]]];
Print["===================================="];
],{arcToAdd,outOfTreeArcs}];

],{k,ks}];

Print["STAGE 2"];
Do[Block[{u,ut,\[Delta],root,thread,pred,dir,system0,outOfTreeArcs},
Print[""];
Print["*** FLOW TYPE ",k," ***"];
u=Subscript[u0, k];ut=Subscript[ut0, k];root=roots[[k]];
{thread,pred,dir}=BuildThreadPredDir[is,ut,root];

(* Forming system *)
system0=BuildNodeEquations[x,u,Subscript[a0, k]];
Print["System for flow type ",k,": ",system0];

(* Find arcs that do not belong to tree *)
outOfTreeArcs=BuildOutOfTreeArcs[u,ut];




\!\(\*OverscriptBox[\(\[Delta]\), \(_\)]\)={};
Do[AppendTo[


\!\(\*OverscriptBox[\(\[Delta]\), \(_\)]\),Subscript[x, arc[[1]],arc[[2]]]->0],{arc,outOfTreeArcs}];



\!\(\*OverscriptBox[\(\[Delta]\), \(_\)]\)=FindTreeDeltas[x,thread,pred,dir,system0,


\!\(\*OverscriptBox[\(\[Delta]\), \(_\)]\)];

\[Delta]hs[k]=


\!\(\*OverscriptBox[\(\[Delta]\), \(_\)]\);
Print[Superscript["\!\(\*OverscriptBox[\"\[Delta]\", \"_\"]\)",k]," = ",


\!\(\*OverscriptBox[\(\[Delta]\), \(_\)]\)];
Print["Test: ",Simplify[system0/.


\!\(\*OverscriptBox[\(\[Delta]\), \(_\)]\)]];
],{k,ks}];


Do[Block[{u,ut,outOfTreeArcs},
u=Subscript[u0, k];ut=Subscript[ut0, k];uc=Subscript[uc0, k];
(* Find arcs that do not belong to tree *)
outOfTreeArcs=BuildOutOfTreeArcs[u,ut];

Do[Block[
{a=arcToAdd[[1]],b=arcToAdd[[2]]},
For[eqNo=1,eqNo<=Length[longSystemLeftParts],++eqNo,
eq=longSystemLeftParts[[eqNo]];
(*Print["before: ",eq];*)
Do[If[nk!=k,
eq=eq/.{x[nk]->zerosForArcs};
],{nk,ks}];
(*Print["after: ",eq];*)
eq=eq/.(Subscript[\[Delta]s[k], a,b]/.{x->x[k]});
(*Print["finally: ",eq];*)
eq=Simplify[eq];
Print["R ",eqNo," ",k," "Subscript["",a,b]," = ",eq];
R[eqNo][k][{a,b}]=eq;
];
],{arcToAdd,outOfTreeArcs}];
],{k,ks}];

For[eqNo=1,eqNo<=Length[longSystemLeftParts],++eqNo,Block[{eq},
eq=longSystemLeftParts[[eqNo]];
(*Print["before: ",eq];*)
Do[eq=eq/.(\[Delta]hs[k]/.{x->x[k]});
,{k,ks}];
(*Print["after: ",eq];*)
(*eq=Simplify[eq];*)
eq=longSystemRightParts[[eqNo]]-eq;
Print["A ",eqNo," = ",eq];
A[eqNo]=eq;
]];

\[Beta]=Table[A[i],{i,allEqs}];
DD=Table[{},{allEqs}];

rule1={};rule2={};
Do[Block[{u=Subscript[u0, k],ut=Subscript[ut0, k],uc=Subscript[uc0, k],outOfTreeArcs},
(* Find arcs that do not belong to tree *)
outOfTreeArcs=BuildOutOfTreeArcs[u,ut];

(* Building DD *)
For[eqNo=1,eqNo<=Length[longSystemLeftParts],++eqNo,
Do[If[MemberQ[uc,arc],
AppendTo[DD[[eqNo]],R[eqNo][k][arc]],
\[Beta][[eqNo]]=\[Beta][[eqNo]]-R[eqNo][k][arc]*Subscript[y[k], arc[[1]],arc[[2]]]
],{arc,outOfTreeArcs}]
]
],{k,ks}];

Print["DD = ",MatrixForm[DD]];
Print["Det[DD] = ",Det[DD]];
Print["\[Beta] = ",\[Beta]];

Y=Simplify[Inverse[DD].Transpose[{\[Beta]}]];
Print["Y = ",MatrixForm[Y]];

yPtr=0;
Do[Block[{u=Subscript[u0, k],ut=Subscript[ut0, k],uc=Subscript[uc0, k]},
outOfTreeArcs=BuildOutOfTreeArcs[u,ut];
Do[If[MemberQ[uc,arc],
AppendTo[rule1,Subscript[x[k], arc[[1]],arc[[2]]]->Y[[ ++yPtr ]] [[1]] ],AppendTo[rule1,Subscript[x[k], arc[[1]],arc[[2]]]->Subscript[y[k], arc[[1]],arc[[2]]] ];
],{arc,outOfTreeArcs}];

(* Building rule2 *)
Do[Block[{sum=0},
Do[sum+=(Subscript[x, arc[[1]],arc[[2]]]/.Subscript[\[Delta]s[k], innerArc[[1]],innerArc[[2]]])*Subscript[x[k], innerArc[[1]],innerArc[[2]]],{innerArc,outOfTreeArcs}];
sum+=(Subscript[x, arc[[1]],arc[[2]]]/.\[Delta]hs[k]);
AppendTo[rule2,Subscript[x[k], arc[[1]],arc[[2]]]->sum]]
,{arc,ut}]
],{k,ks}];
solution=Simplify[Join[rule1,rule2/.rule1]];
Print["The final solution: ",solution];
testResult=Simplify[fullSystem/.solution];
Print["Test: ",testResult];
If[Count[testResult,True]==Length[testResult],Print["Congratulations! All is OK."],Print["FAIL!"]];
Return[solution];
];


End[ ]

EndPackage[ ]



