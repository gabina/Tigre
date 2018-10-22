structure tigerflow = struct

	open tigerassem
	open tigertemp
	open tigertab
	
	(* tabla que asocia enteros (nodos) con instrucciones *)
	val natToInstr: (int, tigerassem.instr) Tabla ref = ref (tabNueva())
	
	(* tabla que asocia cada nodo con los temporales que se definen en el *)
	val defs: (int,temp list) Tabla ref = ref (tabNueva())
	
	(* tabla que asocia cada nodo con los temporales que se usan en el *)
	val uses: (int,temp list) Tabla ref = ref (tabNueva())
	
	(* tabla que asocia nodos con sus sucesores *)
	val succs: (int,int list) Tabla ref = ref (tabNueva())
	
	(**)
	val liveOut : (int, temp list) Tabla ref = ref (tabNueva())
	
	val liveOutOld : (int, temp list) Tabla ref = ref (tabNueva())
	(**)
	val liveIn : (int, temp list) Tabla ref = ref (tabNueva())
	val liveInOld : (int, temp list) Tabla ref = ref (tabNueva())
	
	(* funcion que "llena" natToInstr *)
	
	fun fillNatToInstr (([],_) : tigerassem.instr list * int) = !natToInstr : (int, tigerassem.instr) Tabla
		| fillNatToInstr (x::xs,n) = tabInserta (n,x,fillNatToInstr (xs,n+1))
		
	fun fillDefs (([],_) : tigerassem.instr list * int) = !defs : (int, temp list) Tabla
		| fillDefs (x::xs,n) = case x of 
		                         OPER {assem=a,dst=d,src=s,jump=j} => tabInserta(n,d,fillDefs(xs,n+1))
		                         | LABEL {assem=a,lab=l} => tabInserta(n,[],fillDefs(xs,n+1))
		                         | MOVE {assem=a,dst=d,src=s} => tabInserta(n,[d],fillDefs(xs,n+1))
	
	fun fillUses (([],_) : tigerassem.instr list * int) = !uses : (int, temp list) Tabla
		| fillUses (x::xs,n) = case x of 
		                         OPER {assem=a,dst=d,src=s,jump=j} => tabInserta(n,s,fillUses(xs,n+1))
		                         | LABEL {assem=a,lab=l} => tabInserta(n,[],fillUses(xs,n+1))
		                         | MOVE {assem=a,dst=d,src=s} => tabInserta(n,[s],fillUses(xs,n+1))		
	
	
	
	fun findLabel (l : tigertemp.label) = (tabClaves(tabFiltra (fn i => (case i of 
																			LABEL {assem=a,lab=l1} => ((l1 <= l) andalso (l1 >= l))
																			| _ => false), !natToInstr))) : int list
										
	
	
											
	fun fillSuccs (([],_) : tigerassem.instr list * int) = !succs : (int, int list) Tabla
		| fillSuccs ((x::xs),n) = case x of 
									OPER {assem=a,dst=d,src=s,jump=j} => (case j of
																			NONE => tabInserta(n,[n+1],fillSuccs(xs,n+1))
																			| SOME l => tabInserta (n,List.concat ((List.map findLabel l) : int list list), fillSuccs(xs,n+1)))
									| LABEL {assem=a,lab=l} => tabInserta(n,[n+1],fillSuccs(xs,n+1)) 
									| MOVE {assem=a,dst=d,src=s} => tabInserta(n,[n+1],fillSuccs(xs,n+1))	
									
	fun fillInOut (outNueva,outVieja,inNueva,inVieja) = 
	
end
