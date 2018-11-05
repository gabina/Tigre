structure tigerflow = struct

	open tigerassem
	open tigertemp
	open tigertab
	open Splayset
	(*HOLA*)
	(* tabla que asocia enteros (nodos) con instrucciones *)
	val natToInstr: (int, tigerassem.instr) Tabla ref = ref (tabNueva())	
	
	val longNatToInstr = List.length(tabAList(!natToInstr))
	
	(* tabla que asocia cada nodo con los temporales que se definen en el *)
	
	(*val defs: (int,temp list) Tabla ref = ref (tabNueva())*)
	
	val defs: (int, temp set) Tabla ref = ref (tabNueva())
	
	(* tabla que asocia cada nodo con los temporales que se usan en el *)
	(*val uses: (int,temp list) Tabla ref = ref (tabNueva())*)
	val uses: (int,temp set) Tabla ref = ref (tabNueva())
	
	(* tabla que asocia nodos con sus sucesores *)
	(*val succs: (int,int list) Tabla ref = ref (tabNueva())*)
	val succs: (int,int set) Tabla ref = ref (tabNueva())
	
	(* tabla que asocia nodos con temporales liveOut *)
	(*val liveOut : (int, temp list) Tabla ref = ref (tabNueva())*)
	val liveOut : (int, temp set) Tabla ref = ref (tabNueva())
	
	(*val liveOutOld : (int, temp list) Tabla ref = ref (tabNueva())*)
	val liveOutOld : (int, temp set) Tabla ref = ref (tabNueva())
	
	(* tabla que asocia nodos con temporales liveIn *)
	
	(*val liveIn : (int, temp list) Tabla ref = ref (tabNueva())*)
	val liveIn : (int, temp set) Tabla ref = ref (tabNueva())
	(*val liveInOld : (int, temp list) Tabla ref = ref (tabNueva())*)
	val liveInOld : (int, temp set) Tabla ref = ref (tabNueva())
	
	(* -------------------------------------------------------------------------------------------------------- *)
	
	fun fillNatToInstr (([],_) : tigerassem.instr list * int) = !natToInstr : (int, tigerassem.instr) Tabla
		| fillNatToInstr (x::xs,n) = tabInserta (n,x,fillNatToInstr (xs,n+1))
			
		
	(*	
	
	(* UTILIZANDO LISTAS Y LISTA DE MUNCH *)
	
	fun fillDefs (([],_) : tigerassem.instr list * int) = !defs : (int, temp list) Tabla
		| fillDefs (x::xs,n) = case x of 
		                         OPER {assem=a,dst=d,src=s,jump=j} => tabInserta(n,d,fillDefs(xs,n+1))
		                         | LABEL {assem=a,lab=l} => tabInserta(n,[],fillDefs(xs,n+1))
		                         | MOVE {assem=a,dst=d,src=s} => tabInserta(n,[d],fillDefs(xs,n+1))
	
	(* UTILIZANDO SETS Y LISTA DE MUNCH *)
		                         
	fun fillDefs (([],_) : tigerassem.instr list * int) = !defs : (int, temp set) Tabla
		| fillDefs (x::xs,n) = let 
									val empty = Splayset.empty String.compare
							   in 
									case x of 
										 OPER {assem=a,dst=d,src=s,jump=j} => tabInserta(n,addList (empty,d),fillDefs(xs,n+1))
										 | LABEL {assem=a,lab=l} => tabInserta(n,empty,fillDefs(xs,n+1))
										 | MOVE {assem=a,dst=d,src=s} => tabInserta(n,addList (empty,[d]),fillDefs(xs,n+1))
							   end	                         
	*)
	
	(* UTILIZANDO TABLA ORIGNAL Y LISTAS *)
	(*
	fun fillDefs (i:tigerassem.instr) = (case i of 
						OPER {assem=a,dst=d,src=s,jump=j} => d
						| LABEL {assem=a,lab=l} => []
						| MOVE {assem=a,dst=d,src=s} => [d]) : temp list											
	*)
	
	(* UTILIZANDO TABLA ORIGINAL Y SETS *)
	
	fun id x = x
	
	fun fillDefs (i:tigerassem.instr) = let
											val empty = empty String.compare
										in
											(case i of 
												OPER {assem=a,dst=d,src=s,jump=j} => addList (empty,d)
												| LABEL {assem=a,lab=l} => empty
												| MOVE {assem=a,dst=d,src=s} => addList(empty,[d])) : temp set
										end
												
	val defs = ref ((tabAAplica (id,fillDefs,!natToInstr)))
	
	
	
	
	fun fillUses (i:tigerassem.instr) = let
											val empty = empty String.compare
										in
											(case i of 
												OPER {assem=a,dst=d,src=s,jump=j} => addList (empty,s)
												| LABEL {assem=a,lab=l} => empty
												| MOVE {assem=a,dst=d,src=s} => addList(empty,[s])) : temp set
										end
												
	val uses = ref ((tabAAplica (id,fillUses,!natToInstr)))
	
	
	
	fun findLabel (l : tigertemp.label) = (tabClaves(tabFiltra (fn i => (case i of 
																			LABEL {assem=a,lab=l1} => ((l1 <= l) andalso (l1 >= l))
																			| _ => false), !natToInstr))) : int list
										
	
	
	(* fillSuccs con lista
	
	fun fillSuccs (([],_) : tigerassem.instr list * int) = !succs : (int, int list) Tabla
		| fillSuccs ((x::xs),n) = case x of 
									OPER {assem=a,dst=d,src=s,jump=j} => (case j of
																			NONE => tabInserta(n,n+1,fillSuccs(xs,n+1))
																			| SOME l => tabInserta (n,List.concat ((List.map findLabel l) : int list list), fillSuccs(xs,n+1)))
									| LABEL {assem=a,lab=l} => tabInserta(n,[n+1],fillSuccs(xs,n+1)) 
									| MOVE {assem=a,dst=d,src=s} => tabInserta(n,[n+1],fillSuccs(xs,n+1))	
								 
	
	*)										
	fun fillSuccs (([],_) : tigerassem.instr list * int) = !succs : (int, int set) Tabla
		| fillSuccs ((x::xs),n) = let
										val empty = empty Int.compare
								  in 
										case x of 
											OPER {assem=a,dst=d,src=s,jump=j} => (case j of
																			NONE => tabInserta(n,addList (empty,[n+1]),fillSuccs(xs,n+1))
																			| SOME l => tabInserta (n,addList(empty,List.concat ((List.map findLabel l) : int list list)), fillSuccs(xs,n+1)))
											| LABEL {assem=a,lab=l} => tabInserta(n,addList(empty,[n+1]),fillSuccs(xs,n+1)) 
											| MOVE {assem=a,dst=d,src=s} => tabInserta(n,addList(empty,[n+1]),fillSuccs(xs,n+1))	
								 end
									
	(*  CON LISTAS *)
(*
	fun forEachN (longNatToInstr,outNueva,outVieja,inNueva,inVieja) = (outNueva,outVieja,inNueva,inVieja)
		| forEachN (n,outNueva,outVieja,inNueva,inVieja) = let
															val b = case (tabBusca (n,inVieja)) of 
																						NONE => raise Fail "error forEachN"
																						| SOME v => v
															val in' = tabRInserta (n,b,inNueva)
															val b1 = case (tabBusca (n,outVieja)) of 
																						NONE => raise Fail "error forEachN"
																						| SOME v => v
															val out' = tabRInserta (n,b1,outNueva)
															
															val empty = Splayset.empty String.compare
															
															val useN = case (tabBusca (n,!uses)) of 
																						NONE => raise Fail "error forEachN"
																						| SOME l => l
															
															val useNSet = Splayset.addList (empty, useN)
																														
															val outN =  case (tabBusca (n,outVieja)) of 
																						NONE => raise Fail "error forEachN"
																						| SOME l => l
															val outNSet = Splayset.addList (empty, outN)							
															
															val defN = case (tabBusca (n,!defs)) of 
																						NONE => raise Fail "error forEachN"
																						| SOME l => l
															val defNSet = Splayset.addList (empty, defN)							
															
															val in'' = tabRInserta(n,Splayset.listItems(Splayset.union(useNSet,(Splayset.difference(outNSet,defNSet)))),inNueva)
															
															val succsN = case (tabBusca (n,!succs)) of
																			NONE => raise Fail "error forEachN succs"
																			| SOME l => l
														    
														    fun index n = case (tabBusca (n,in'')) of
																			NONE => raise Fail "error index"
																			| SOME l => l
														    val m = Splayset.listItems(Splayset.addList(empty,List.concat (List.map index succsN)))
																		
															val out'' = tabRInserta (n,m,in'')
														in
															forEachN (n+1, out',out'',in',in'')
														end
														
	fun until (outNueva,outVieja,inNueva,inVieja) = let 
														val (outNueva',outVieja',inNueva',inVieja') = forEachN (0,outNueva,outVieja,inNueva,inVieja)
														fun cmpTable (l1,l2) = let 
																				val empty = Splayset.empty String.compare
																			 in Splayset.equal (Splayset.addList(empty,l1),Splayset.addList(empty,l2))
																			 end
													in 
														tabIgual (cmpTable,outNueva,outNueva') andalso tabIgual (cmpTable,inNueva,inNueva')
													end						
*)
	
		fun buscoEnTabla (x,t) = (case (tabBusca (x,t)) of 
									NONE => raise Fail "error buscoEnTabla"
									| SOME v => v)
																						
		fun forEachN (longNatToInstr,outNueva,outVieja,inNueva,inVieja) = (outNueva,outVieja,inNueva,inVieja)
		| forEachN (n,outNueva,outVieja,inNueva,inVieja) = let
															val b = buscoEnTabla (n,inVieja)
															val in' = tabRInserta (n,b,inNueva)
															
															val b1 = buscoEnTabla (n,outVieja)
															val out' = tabRInserta (n,b1,outNueva)														
															
															val useN = buscoEnTabla (n,!uses)										
																														
															val outN = buscoEnTabla (n,outVieja)							
															
															val defN = buscoEnTabla (n,!defs)																				
															
															val in'' = tabRInserta(n,union(useN,difference(outN,defN)),inNueva)
															
															val succsN = listItems (buscoEnTabla (n,!succs))
														    
														    fun index n = listItems (buscoEnTabla (n,in''))
														    
														    val empty = empty String.compare
														    
														    val m = Splayset.addList(empty,List.concat (List.map index succsN))
																		
															val out'' = tabRInserta (n,m,in'')
														in
															forEachN (n+1, out',out'',in',in'')
														end
														
	fun until (outNueva,outVieja,inNueva,inVieja) = let 
														val (outNueva',outVieja',inNueva',inVieja') = forEachN (0,outNueva,outVieja,inNueva,inVieja)
													in 
														tabIgual (Splayset.equal,outNueva,outNueva') andalso tabIgual (Splayset.equal,inNueva,inNueva')
													end						

														
	fun fillInOut () = until ( tabNueva(), tabNueva(), tabNueva(), tabNueva())
														
	(*******************************************************************************************************************************)
	
	(* AGREGAR TABLA DE MOVE RELATED - CREO QUE CONVIENE LLENARLA A LA VEZ QUE EL GRAFO DE INTERF *) 
	
	val interf: (temp, temp list) Tabla ref = ref (tabNueva())
	
	val adj: (temp, temp list) Tabla ref = ref (tabNueva())
	
	fun getAdj (t : temp) = (case (tabBusca (t,!adj)) of
								NONE => raise Fail "No deberia pasar (temp no encontrado)"
								| SOME l => l) : temp list
	
	fun areAdj ((t1,t2) : (temp * temp)) = (case (tabBusca (t1,!adj)) of
												NONE => raise Fail "No deberia pasar (temp no encontrado)"
												| SOME l => List.null (List.filter (fn e => ((e <= t2) andalso (e >= t2))) l)) : bool
												
	fun getDegree (t : temp) = List.length (getAdj t)
	

	fun getTemps (([],l) : (tigerassem.instr list * temp set)) = l : temp set
		| getTemps ((x::xs,ts)) = case x of 
								OPER {assem=a,dst=d,src=s,jump=j} => let 
																		val _ = Splayset.addList (ts,s)
																		val _ = Splayset.addList (ts,d)
																	 in ts
																	 end
								| LABEL {assem=a,lab=l} => ts
								| MOVE {assem=a,dst=d,src=s} => let
																	val _ = add (ts,d)
																	val _ = add (ts,s)
																in
																	ts
																end
	(*
	fun fillInterf ([] : tigerassem.instr list) = !inferf : (temp, temp set) Tabla
		| fillInterf (x:xs) = case x of 
								OPER {assem=a,dst=d,src=s,jump=j} => 
								| LABEL {assem=a,lab=l} => 
								| MOVE {assem=a,dst=d,src=s} =>  
	
	*)
	fun fillInterf ((0, tab) : (int * (temp, temp set) Tabla)) = let
																	val i = buscoEnTabla (0, !natToInstr)
																	val empty = empty String.compare
																	fun findSet (t : temp) = (case tabBusca (t,tab) of
																								NONE => empty
																								| SOME c => c)
																in 
																	case i of 
																		OPER {assem=a,dst=d,src=s,jump=j} => if (List.length d) = 0 then tab else List.foldl (fn (tmp,t) => tabInserta (tmp,union(findSet(tmp),buscoEnTabla(0,!liveOut)),t)) tab d
																		| LABEL {assem=a,lab=l} => tab
																		| MOVE {assem=a,dst=d,src=s} => tabInserta (d,difference(union(findSet(d),buscoEnTabla(0,!liveOut)),addList(empty,[s])),tab)
																end
		| fillInterf (n,tab) = let
									val i = buscoEnTabla (n, !natToInstr)
									val empty = empty String.compare
									fun findSet (t : temp) = (case tabBusca (t,tab) of
																NONE => empty
																| SOME c => c)
								in 
									case i of 
										OPER {assem=a,dst=d,src=s,jump=j} => if (List.length d) = 0 then fillInterf (n-1,tab) else fillInterf (n-1,List.foldl (fn (tmp,t) => tabInserta (tmp,union(findSet(tmp),buscoEnTabla(n,!liveOut)),t)) tab d)
										| LABEL {assem=a,lab=l} => fillInterf (n-1,tab)
										| MOVE {assem=a,dst=d,src=s} => fillInterf (n-1,tabInserta (d,difference(union(findSet(d),buscoEnTabla(n,!liveOut)),addList(empty,[s])),tab))
								end

end
