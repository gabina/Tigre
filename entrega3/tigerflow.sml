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
	
	(* funcion que "llena" natToInstr *)
	
	fun fillNatToInstr (([],_) : tigerassem.instr list * int) = !natToInstr : (int, tigerassem.instr) Tabla
		| fillNatToInstr (x::xs,n) = tabInserta (n,x,fillNatToInstr (xs,n+1))
		
	fun fillDefs (([],_) : tigerassem.instr list * int) = !defs : (int, temp list) Tabla
		| fillDefs (x::xs,n) = case x of 
		                         OPER {assem=a,dst=d,src=s,jump=j} => tabInserta(n,d,fillDefs(xs,n+1))
		                         | LABEL {assem=a,lab=l} => tabInserta(n,[],fillDefs(xs,n+1))
		                         | MOVE {assem=a,dst=d,src=s} => tabInserta(n,[d],fillDefs(xs,n+1))
	(* alternativa
	
	defs = natToInstr
	fun fillDefs1 (i : tigerassem.instr) = case i of 
											OPER {assem=a,dst=d,src=s,jump=j} => d
											| LABEL {assem=a,lab=l} => []
											| MOVE {assem=a,dst=d,src=s} => [d]
	defs = tabAplica fillDefs1 defs
	
	*)
	fun fillUses (([],_) : tigerassem.instr list * int) = !uses : (int, temp list) Tabla
		| fillUses (x::xs,n) = case x of 
		                         OPER {assem=a,dst=d,src=s,jump=j} => tabInserta(n,d,fillUses(xs,n+1))
		                         | LABEL {assem=a,lab=l} => tabInserta(n,[],fillUses(xs,n+1))
		                         | MOVE {assem=a,dst=d,src=s} => tabInserta(n,[d],fillUses(xs,n+1))		

	(* alternativa (usa las mismas keys que la tabla original creo que igual nunca cambiaria pero por las dudas asi nos aseguramos	
	
	uses = natToInstr
	fun fillUses1 (i : tigerassem.instr) = case i of 
											OPER {assem=a,dst=d,src=s,jump=j} => s
											| LABEL {assem=a,lab=l} => []
											| MOVE {assem=a,dst=d,src=s} => [s]
	uses = tabAplica fillUses1 uses
	
	
											
	fun auxiSuccs ((n,[],xs)) : (int * string list * int list) = xs 
		| auxiSuccs (n,(x::xs),ys) = auxiSuccs(n,xs,((tabClaves(tabFiltra (fn i => case i of 
																						LABEL {assem=a,lab=l} => if (l == x) then true else false
																						| _ => false) natToInstr)) :: ys))
	
	
											
	fun fillSuccs (([],_) : tigerassem.instr list * int) = !succs : (int, int list) Tabla
		| fillSuccs ((x::xs),n) = case x of 
									OPER {assem=a,dst=d,src=s,jump=j} => case j of
																			NONE => tabInserta(n,[n+1],fillSuccs(xs,n+1))
																			| SOME l => tabInserta (n,auxiSuccs (n,l,[n+1]),fillSuccs(xs,n+1))
									| LABEL {assem=a,lab=l} => tabInserta(n,[n+1],fillSuccs(xs,n+1)) (*OK??*)
									| MOVE {assem=a,dst=d,src=s} => tabInserta(n,[n+1],fillSuccs(xs,n+1))	
	
	*)
end
