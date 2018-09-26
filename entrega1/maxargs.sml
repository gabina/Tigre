open tigerabs

fun max (x,y) = if x < y then y else x
fun maximum l = foldl max 0 l
 
fun (*maxargsVar: var -> int *)
  maxargsVar (SimpleVar(_)) = 0
| maxargsVar (FieldVar(v,_)) = maxargsVar v
| maxargsVar (SubscriptVar(v,e)) = max (maxargsVar v, maxargs e)  
 
and (*maxargs: exp -> int *)
  maxargs (VarExp(v, _)) = maxargsVar v
| maxargs (UnitExp(_))   = 0
| maxargs (NilExp(_)) = 0
| maxargs (IntExp(_,_)) = 0
| maxargs (StringExp(_,_)) = 0
| maxargs (CallExp({func=s, args=args},_)) = if s = "print" then length args else 0
| maxargs (OpExp({left=l,oper=_,right=r},_)) = max ((maxargs l),(maxargs r))
| maxargs (RecordExp({fields = l,typ=_},_)) =  maximum (map (maxargs o #2) l)
| maxargs (SeqExp(l,_)) = maximum (map maxargs l)
| maxargs (AssignExp({var=v,exp=e},_)) = max (maxargsVar v, maxargs e) 
| maxargs (IfExp({test=t,then'=th,else'=e},_)) = max ((max (maxargs(t), maxargs(th))),maxargs(Option.getOpt(e,UnitExp(0)))) 
| maxargs (WhileExp({test=t, body=b},_)) = max ((maxargs t),(maxargs b))
| maxargs (ForExp({var=_, escape=_, lo=e1, hi=e2, body=e3},_)) = max(max(maxargs (e1),maxargs (e2)),maxargs (e3))
| maxargs (BreakExp(_)) = 0
| maxargs (ArrayExp({typ=_, size=e1, init=e2},_)) =  max ((maxargs e1),(maxargs e2))
| maxargs (LetExp({decs=l,body=e},_)) = max( maximum (map maxargsDec l),(maxargs (e)))

and (*maxargsDec: dec -> int *)
  maxargsDec (FunctionDec(l)) =  maximum (map (maxargs o (#body o #1)) l) 
| maxargsDec (VarDec({name=n,escape=e,typ=t,init=i},k)) = maxargs i
| maxargsDec (TypeDec(v)) = 0


