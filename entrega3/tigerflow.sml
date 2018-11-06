structure tigerflow :> tigerflow =
struct
	open tigerassem
	open tigertemp
	open tigertab
	open Splayset

(* ---------------------------------------------------------------------------------------------------------- *)
	val natToInstr = ref (tabNueva())
	
	fun fillNatToInstr ([],_) = !natToInstr
		| fillNatToInstr (x::xs,n) = tabInserta (n,x,fillNatToInstr (xs,n+1))

	val longNatToInstr = List.length(tabAList(!natToInstr))
	
	fun id x = x

(* ---------------------------------------------------------------------------------------------------------- *)
	
	fun fillDefs i = let
						val empty = empty String.compare
					 in
						case i of 
							OPER {assem=a,dst=d,src=s,jump=j} => addList (empty,d)
							| LABEL {assem=a,lab=l} => empty
							| MOVE {assem=a,dst=d,src=s} => addList(empty,[d]) 
					end
							
	val defs = ref ((tabAAplica (id,fillDefs,!natToInstr)))

(* ---------------------------------------------------------------------------------------------------------- *)
	
	fun fillUses i = let
						val empty = empty String.compare
  					 in
						case i of 
							OPER {assem=a,dst=d,src=s,jump=j} => addList (empty,s)
							| LABEL {assem=a,lab=l} => empty
							| MOVE {assem=a,dst=d,src=s} => addList(empty,[s])
					 end
							
	val uses = ref ((tabAAplica (id,fillUses,!natToInstr)))
	
(* ---------------------------------------------------------------------------------------------------------- *)
	
	fun findLabel l = tabClaves(tabFiltra ((fn i => case i of 
					   								LABEL {assem=a,lab=l1} => ((l1 <= l) andalso (l1 >= l))
													| _ => false), !natToInstr)) 
										
	
	
	val succs = ref (tabNueva())
	fun preFillSuccs () = (map (fn (x,y) => y) (tabAList (! natToInstr)))								
	fun fillSuccs ([],_) = !succs 
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

								 
	val succs = ref (fillSuccs (preFillSuccs (),0))
									
(* ---------------------------------------------------------------------------------------------------------- *)
	
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

	val liveOut = ref(tabNueva())

	val liveOutOld = ref(tabNueva())

	val liveIn = ref(tabNueva())

	val liveInOld = ref(tabNueva())
													
	fun fillInOut () = until (!liveOut, !liveOutOld, !liveIn, !liveInOld)
														
	(*******************************************************************************************************************************)
	
	(* AGREGAR TABLA DE MOVE RELATED - CREO QUE CONVIENE LLENARLA A LA VEZ QUE EL GRAFO DE INTERF *) 
	
	val moveRelated = ref (tabNueva ())
	val interf = ref (tabNueva())
	
	val adj : (tigertemp.temp, tigertemp.temp list) tigertab.Tabla ref = ref (tabNueva ())
	
	fun getAdj t = case (tabBusca (t,!adj)) of
						NONE => raise Fail "No deberia pasar (temp no encontrado)"
						| SOME l => l
	
	fun areAdj (t1,t2) = case (tabBusca (t1,!adj)) of
							NONE => raise Fail "No deberia pasar (temp no encontrado)"
							| SOME l => List.null (List.filter (fn e => ((e <= t2) andalso (e >= t2))) l)
												
	fun getDegree t = List.length (getAdj t)
	

	fun getTemps ([],l) = l 
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
	
	fun fillMoveRelated (t1,t2) = (tabInserta (t1, true, !moveRelated) ; tabInserta (t2, true, !moveRelated))
	
	fun isMoveRelated t = case (tabBusca (t,!moveRelated)) of 
								NONE => false
								| SOME v => true
								 
	fun fillInterf (0, tab) = let
									val i = buscoEnTabla (0, !natToInstr)
									val empty = empty String.compare
									fun findSet (t : temp) = (case tabBusca (t,tab) of
																NONE => empty
																| SOME c => c)
								in 
									case i of 
										OPER {assem=a,dst=d,src=s,jump=j} => if (List.length d) = 0 then tab else List.foldl (fn (tmp,t) => tabInserta (tmp,union(findSet(tmp),buscoEnTabla(0,!liveOut)),t)) tab d
										| LABEL {assem=a,lab=l} => tab
										| MOVE {assem=a,dst=d,src=s} => (fillMoveRelated (d,s) ; tabInserta (d,difference(union(findSet(d),buscoEnTabla(0,!liveOut)),addList(empty,[s])),tab))
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
										| MOVE {assem=a,dst=d,src=s} => (fillMoveRelated (d,s) ; fillInterf (n-1,tabInserta (d,difference(union(findSet(d),buscoEnTabla(n,!liveOut)),addList(empty,[s])),tab)))
								end

end
