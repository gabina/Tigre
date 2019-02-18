structure tigercolor :> tigercolor =
struct
	open tigerassem
	open tigertemp
	open tigertab
	open Splayset
	open tigerbuild
	open tigerframe

	val emptyStr = empty String.compare														
	val emptyInt = empty Int.compare	
	
	val selectStack = ref ([])	
	val spillWorkSet = ref (emptyStr)
	val simplifyWorkSet = ref(emptyStr)
	val degree = ref (tabNueva())
	val color = ref (tabNueva())
	val precoloredList = ref([])
	val precoloredSet = ref(emptyStr)
	val spilledNodes = ref ([])
	val registersSet = ref(emptyStr)
	
	(* ESTRUCTURAS PARA COALESCE*)
	val workSetMoves = ref (emptyInt) (* intrucciones moves que pueden ser coaleasced --- workSetMoves: int Splayset.set ref *)
	val alias = ref (tabNueva()) (* cuando un move (a,b) se une, v se pone en coalescedNodes y alias(v) = u --- alias: (tigertemp.temp, tigertemp.temp) tigertab.Tabla ref *)
	val coalescedNodes = ref(emptyStr) (* temporales que han sido unidos, si tengo move (v,u) entonces v se une a este conjunto y u es puesto en alguna work list o viceversa --- coalescedNodes: tigertemp.temp Splayset.set ref*) 
	val freezeWorkSet = ref (emptyStr) (* temporales relacionados con moves y con grado menor a k --- freezeWorkSet: tigertemp.temp ref*)
	val activeMoves = ref(emptyInt) (* moves que todavia no estan listos para ser unidos --- activeMoves: int Splayset.set ref*)
	val moveSet = ref (tabNueva()) (*equivale a moveList del libro. pagina 243 --- moveSet: (tigertemp.temp, tigertemp.temp Splayset.set) tigertab.Tabla ref *)
	(* FIN ESTRUCTURAS PARA COALESCE *)
	
	(*FUNCIONES PARA COALESCE*)    
    (* getAlias: tigertemp.temp -> tigertemp.temp *)
    fun getAlias (t) = if member(!coalescedNodes,t) then getAlias(buscoEnTabla(t,!alias)) else t
    
    (* fillMoves: (instr list, int,tigertemp.temp Splayset.set, (tigertemp.temp, tigertemp.temp) tigertab.Tabla) ->  (tigertemp.temp Splayset.set, (tigertemp.temp, tigertemp.temp) tigertab.Tabla) ??? conviene el numero de instruccion o mejor (src,dst,numero)????*)
    (* esta funcion llena tanto el conjunto que contiene el n° de instrucciones que son moves como la tabla a la que a cada temp le corresponde el conjunto de n° de instrucciones donde este interviene en un move*)
    fun fillMoves (_,0,sMoves,tabMoves) = (sMoves,tabMoves)
		| fillMoves ((i::xs),n,sMoves,tabMoves) = case i of 
													OPER {assem=_,dst=_,src=s,jump=_} => fillMoves(xs,n-1,sMoves,tabMoves) 
													| LABEL {assem=_,lab=_} => fillMoves(xs,n-1,sMoves,tabMoves) 
													| MOVE {assem=_,dst=d,src=s} => (let 
																						val nSet = add(emptyInt,n)
																						val sMoves' = if member(buscoEnTabla(s,!interf),d) then sMoves else union(sMoves, nSet)
																						val tabMoves' = tabRInserta(d,n,tabRInserta(s,n,tabMoves))
																					in fillMoves(xs,n-1,sMoves',tabMoves') end)
    
    (* nodeMoves: tigertemp.temp -> tigertemp.temp Splayset.set*)
    fun nodeMoves n = intersection (buscoEnTabla(n,!moveSet), union(!activeMoves,!workSetMoves))
    
    (* moveRelated: tigertemp.temp -> bool *)
    (* nuestro moveRelated es un conjunto donde estan todos los nodos involucrados en un move, aca determina si un nodo en especial todavia tiene que ver con un move o no *)
    fun moveRelatedFun n = equal(nodeMoves(n),emptyInt) 
    
    (* enableMoves: tigertemp.temp Splayset.set -> unit *)
    fun enableMoves nodes = let 
								val nList = listItems(nodes)
								val l1 = map nodeMoves nList (* (tigertemp.temp Splayset.set ) list*)
								val l2 = map (fn n => intersection (n,!activeMoves)) l1 
							in List.app (fn n => (activeMoves := difference(!activeMoves,n); workSetMoves := union (!workSetMoves, n))) l2 end
    
    (* areAdj: (tigertemp.temp * tigertemp.temp) -> bool*)
    fun areAdj (t1,t2) = member(buscoEnTabla(t1,!interf),t2)
    
    (* ok: (tigertemp.temp * tigertemp.temp) -> bool *)
    fun ok (t,r) = (buscoEnTabla(t,!degree) < K) orelse member(!precoloredSet,t) orelse areAdj (t,r)
    
    (* fillFreezeWorkSet: unit-> tigertemp.temp Splayset.set*)
    fun fillFreezeWorkSet () = let 
								val lowDegreeList = tabClaves (tabFiltra ((fn n => n < K ),!degree))								
							   in addList (!moveRelated,lowDegreeList) end
							   
	(* conservative: tigertemp.temp list -> bool*)
	fun conservative xs = length(List.filter (fn n => (buscoEnTabla(n,!degree) >= K)) xs) < K
	
	(* addWorkList: tigertemp.temp -> unit *)
	fun addWorkList u = let 
							val c1 = not (member (!precoloredSet,u))
							val c2 = not ((member (!moveRelated, u)) andalso (buscoEnTabla(u,!degree) < K))
							val cond = c1 andalso c2
							val uSet = add(emptyStr,u)
						in (if cond then (freezeWorkSet := difference(!freezeWorkSet,uSet) ; simplifyWorkSet := union(!simplifyWorkSet,uSet)) else ()) end	
	
	(* freezeMoves : falta definir*)
	fun freezeMoves n = ()
						
	(* freeze: unit -> unit *)
	fun freeze () = let
						val u = hd (listItems(!freezeWorkSet))
						val uSet = add(emptyStr,u)
						val _ = freezeWorkSet := difference(!freezeWorkSet, uSet)
						val _ = simplifyWorkSet := union(!simplifyWorkSet,uSet)
					in freezeMoves(u) end
	
	
	
	(* tempsInMove: int -> (tigertemp.temp,tigertemp.temp) toma un entero que representa una instruccion move y devuelve (src,dst) *)
	(* funcion auxiliar que toma un entero que es el numero de instruccion y devuelve la tupla (src,dst) de un move *)
	(* se usa para cuando el libro dice m (copy(x,y))*)
	fun tempsInMove n = case buscoEnTabla (n,!natToInstr) of
							MOVE {assem=_,dst=d,src=s} => (s,d)
							| _ => raise Fail "tempsInMove no deberia pasar"	
							
												  
    (*FIN FUNCIONES PARA COALESCE*)
    
	fun getDegree t = buscoEnTabla (t,!degree)
		
	fun fillSimplifyWorkSet () = let
									val lowDegreeList = tabClaves (tabFiltra ((fn n => n < K ),(!degree)))
									(*val nonMoveRelSet = difference (setOfAllTemps, !tMoveRel)*)
									(* agregar para coalese y spill in addList (nonMoveRelSet,lowDegreeList) end*)
								 in addList (emptyStr,lowDegreeList) end
													  
	fun minusOneSet s x = x-1 
														
	fun decrementDegree (s) = let 								
								(* paso a lista el conjunto de temporales*)
								val listTemps = listItems s
								(* me quedo con los temps de la lista cuyo grado es K *)									
								
								val listKNeig = List.filter (fn n => (buscoEnTabla(n,!degree)) = K) listTemps
								(* a cada temp de la lista original le resto un vecino *)
								
								fun minusOne n = case tabBusca(n,!degree) of
													NONE => raise Fail "No deberia pasar minusOne"
													| SOME i => i-1
								val _ = map (fn n => tabRInserta (n,minusOne n,!degree)) listTemps
								(*elimino del conjunto spillWorkSet los elementos de listKNeig*)
								val setKNeig = addList(emptyStr,listKNeig)
								val _ = spillWorkSet := difference (!spillWorkSet,setKNeig)
								(*llamo a la funcion*)
								(*val _ = enableMoves (setKNeig)*)
								(* para cada temp del conjunto evaluo lo que hace aux *)
								(*
								fun aux n = if isMoveRelated n then freezeWorkSet := add (!freezeWorkSet,n)
															   else simplifyWorkSet := add (!simplifyWorkSet,n)
								val _ = Splayset.app aux setKNeig
								*)
								in addList(emptyStr,listKNeig) end 
								

	fun fillColor ([],c) = c
	  | fillColor ((x::xs),c) = tabRInserta(x,x,(fillColor (xs,c)))
	  												
	fun selectSpill () = let
							val m = hd(listItems (!spillWorkSet))
							val _ = spillWorkSet := difference (!spillWorkSet,add(emptyStr,m))
							val _ = simplifyWorkSet := union (!simplifyWorkSet,add(emptyStr,m))
						in repeatUntil() end
	
	and simplify () = case (numItems(!simplifyWorkSet)) of 
								0 => repeatUntil()
								| _ => (let val n = hd(listItems (!simplifyWorkSet))											
											val _ = selectStack := !selectStack @ [n]				
											val adjN = difference(buscoEnTabla (n,!interf),addList(emptyStr,!selectStack))
											val setK = decrementDegree (adjN)
											val _ = simplifyWorkSet :=	difference (union(!simplifyWorkSet,setK),addList(emptyStr,[n]))
											in  simplify () end)

	and repeatDo () = let
						val lsws = numItems (!simplifyWorkSet)
						val lspillws = numItems(!spillWorkSet)
						(*COALESCE (agrego) val lwsmov = numItems(!workSetMoves) *)
						(*COALESCE (modifico) in if (lsws <> 0) then simplify() else (if (lwsmov <> 0) then coalesce () else (if lspillws <> 0 then selectSpill() else ()) end *)
					   in if (lsws <> 0) then simplify() else (if lspillws <> 0 then selectSpill() else ()) end
					   
	and repeatUntil () = let
							val lsws = numItems (!simplifyWorkSet)
							val lspillws = numItems(!spillWorkSet)
							(*COALESCE (agrego) val lwsmov = numItems(!workSetMoves) *)
							(*COALESCE (modifico) val fin = ((lsws = 0) andalso (lspillws = 0)) andalso (lwsmov = 0)*)
							val fin = (lsws = 0) andalso (lspillws = 0)
						  in if fin then () else repeatDo () end												
													
	fun assignColors (cNodes, stack) = case (length (stack)) of
						
								0 => (print("stack:\n");List.app (fn n => print (n^"\n")) (!selectStack);selectStack:=[];print ("Tabla colores\n");tigertab.tabPrintTempTemp(!color);cNodes)
								| _ => case (member(!precoloredSet,hd (stack))) of
									false =>
										(let 
											val n = hd (stack)
											val stack' = tl(stack)
											val adj = buscoEnTabla (n,!interf) : tigertemp.temp Splayset.set
											val uni = union (cNodes, !precoloredSet) : tigertemp.temp Splayset.set
											(*val _ = print "\nuni es\n"
											val _ = List.app print (listItems uni)*)
											fun discardColors (n : tigertemp.temp,s) = let 
																					val isMember = member (uni,n)
																					val colorUsed = if isMember then add(emptyStr,buscoEnTabla(n,!color)) else emptyStr
																					(*val _ = print ("Descarto\n")
																					val _ =  List.app print (listItems colorUsed)*)
																				in difference (s,colorUsed) end
											val okColors = Splayset.foldl discardColors (!registersSet) adj
											(*val _ = print "\nokColors es\n"
											val _ = List.app print (listItems okColors)*)
											val cNodes' = case length (listItems(okColors)) of
														0 => (let val _ = print ("\nEL NODO SPILL ES "^n^"\n")
																val _ = spilledNodes := n::(!spilledNodes)
															 in cNodes end)
														| _ => (let 
																	val c = hd(listItems(okColors))
																	val _ = color := tabRInserta (n,c,!color)					
																in union (cNodes, add(emptyStr, n)) end)
										in assignColors (cNodes', stack') end)
									| true => assignColors (cNodes, tl(stack))											

	(* Tomará la lista de instrucciones, un temporal, un offset*)

	fun its n =  if n<0 then "-" ^ Int.toString(~n) else Int.toString(n) 

	fun forEachSpilled ([] : instr list, tmp : tigertemp.temp, offset : int) = ([],[]): (instr list * tigertemp.temp list)
		| forEachSpilled (i::instr, tmp, offset) = 
			case i of
			OPER {assem=a,dst=d,src=s,jump=j} => 
				(let	
					fun igual n = (n=tmp)
					val isDst = List.exists igual d
					val isSrc = List.exists igual s
				 in (case (isDst andalso isSrc) of
					true => let val _ = print "Es fuente y destino"
								val newTemp = newtemp()
								val newInstr1 = OPER {assem="movq "^its(offset)^"(%'s0), %'d0\n",dst=[newTemp],src=[fp],jump=NONE}
								val d' = map (fn n => if n = tmp then newTemp else n) d
								val s' = map (fn n => if n = tmp then newTemp else n) s
								val rewInstr = OPER {assem=a,dst=d',src=s',jump=j}
								val newInstr2 = OPER {assem="movq %'s0, "^its(offset)^"(%'s1)\n",dst=[],src=[fp,newTemp],jump=NONE}
								val (instructions, temps) = forEachSpilled(instr,tmp,offset)
							in ([newInstr1,rewInstr,newInstr2]@instructions, newTemp::temps)end
					| false => let val newTemp = newtemp()
								in (case isDst of
									true => let val _ = print "Es destino"
												val d' = map (fn n => if n = tmp then newTemp else n) d
												val rewInstr = OPER {assem=a,dst=d',src=s,jump=j}
												val newInstr = OPER {assem="movq %'s0, "^its(offset)^"(%'s1)\n",dst=[],src=[newTemp,fp],jump=NONE}
												val (instructions, temps) = forEachSpilled(instr,tmp,offset)
											in ([rewInstr,newInstr]@instructions, newTemp::temps)end
									| false => (case isSrc of
										true => let 
													val s' = map (fn n => if n = tmp then newTemp else n) s
													val newInstr = OPER {assem="movq "^its(offset)^"(%'s0), %'d0\n",dst=[newTemp],src=[fp],jump=NONE}
													val rewInstr = OPER {assem=a,dst=d,src=s',jump=j}
													val (instructions, temps) = forEachSpilled(instr,tmp,offset)
												in ([newInstr,rewInstr]@instructions, newTemp::temps)end
										| false => let val (instructions, temps) = forEachSpilled(instr,tmp,offset)
													in (i::instructions,temps) end))end)end)
			 | MOVE {assem=a,dst=d,src=s} => 
				(let	val isDst = (d = tmp)
						val isSrc = (s = tmp)
				 in (case (isDst andalso isSrc) of
					true => forEachSpilled(instr,tmp,offset)
					| false => let val newTemp = newtemp()
								in (case isDst of
									true => let val rewInstr = MOVE {assem=a,dst=newTemp,src=s}
												val newInstr = OPER {assem="movq %'s0, "^its(offset)^"(%'s1)\n",dst=[],src=[newTemp,fp],jump=NONE}
												val (instructions, temps) = forEachSpilled(instr,tmp,offset)
											in ([rewInstr,newInstr]@instructions, newTemp::temps)end
									| false => (case isSrc of
										true => let val newInstr = OPER {assem="movq "^its(offset)^"(%'s0), %'d0\n",dst=[newTemp],src=[fp],jump=NONE}
													val rewInstr = MOVE {assem=a,dst=d,src=newTemp}
													val (instructions, temps) = forEachSpilled(instr,tmp,offset)
												in ([newInstr,rewInstr]@instructions, newTemp::temps)end
										| false => let val (instructions, temps) = forEachSpilled(instr,tmp,offset)
													in (i::instructions,temps) end))end)end)
				| _ => let val (instructions, temps) = forEachSpilled(instr,tmp,offset)
						in (i::instructions,temps) end																			
														
	(* La lista de instrucciones y el frame serán importados. La lista de temporales primera debe ser vacía*) 
	fun rewriteProgram(linstr : instr list, f : frame, ltemp : tigertemp.temp list) = case length(!spilledNodes) of
												0 => (print("Programa reescrito\n");printInstrList linstr;(linstr,ltemp))
												| _ => 	let 
															val n = hd(!spilledNodes) 
															val _ = spilledNodes := tl(!spilledNodes)
															val InFrame k = allocLocal f true
															val (instructions, temps) = forEachSpilled(linstr,n,k)
														in rewriteProgram(instructions,f,ltemp@temps) end

	fun initialize() = let 	val _ = selectStack := []
							val _ = spillWorkSet := emptyStr
							val _ = simplifyWorkSet := emptyStr
							val _ = degree := tabNueva()
							val _ = color := tabNueva()
							val _ = precoloredSet := emptyStr
							val _ = spilledNodes := []
							val _ = registersSet := emptyStr
						in () end

	fun pintar n = (case tabBusca(n,!color) of
						NONE => raise Fail ("Temporal sin color asignado "^n)
						| SOME c => c) 	
										
	fun colorear'(l,f,initial) = 
		let 
			val _ = tigerbuild.build(l,0)		
		
			val _ = spilledNodes := []
			
			(*makeWorkList()*)
			val _ = degree := tabAAplica (id,Splayset.numItems,!interf)
			val _ = precoloredList := ["rbx", "rsp","rdi", "rsi", "rdx", "rcx", "r8", "r9", "rbp", "rax","r10","r11","r12","r13","r14","r15"]
			
			val _ = color := fillColor(!precoloredList,!color)	
			val _ = precoloredSet := addList(emptyStr, !precoloredList)		
			val _ = simplifyWorkSet := initial
			
			val _ = spillWorkSet := addList (emptyStr,tabClaves (tabFiltra ((fn n => n >= K),!degree)))		
									
			(*repeat until*)		
			val _ = repeatUntil()	

			(* assign colors*)
			val coloredNodes = assignColors(emptyStr, !selectStack)

			(* rewrite program*)
			val (instructions, temps) = rewriteProgram(l,f,[])
			
			val _ = (print("Temporales agregados\n");List.app print temps)
			
		in if temps = [] then (pintar,instructions) else colorear'(instructions,f, addList (coloredNodes, temps) ) end	
		
	fun colorear (l,f,printt) = 
		let
			(* OJOO: HAY QUE VACIAR TODAS LAS LISTAS Y CONJUNTOS CADA VEZ QUE EMPIEZO EL ALGORITMO*)
			val _ = initialize()
			
			val _ = tigerbuild.build(l,printt)		
			(*makeWorkList()*)
			val _ = degree := tabAAplica (id,Splayset.numItems,!interf)
			val _ = precoloredList := ["rbx", sp,"rdi", "rsi", "rdx", "rcx", "r8", "r9", fp, "rax","r10","r11","r12","r13","r14","r15"]

			val _ = registersSet := addList (emptyStr, registers) 
				
			val _ = color := fillColor(!precoloredList,!color)			
			val _ = precoloredSet := addList(emptyStr, !precoloredList)
			val _ = simplifyWorkSet := fillSimplifyWorkSet ()
			
			val _ = spillWorkSet := addList (emptyStr,tabClaves (tabFiltra ((fn n => n >= K),!degree)))								
			(*repeat until*)		
			val _ = repeatUntil()	

			(* assign colors*)
			val coloredNodes = assignColors(emptyStr, !selectStack)

			(* rewrite program*)
			val (instructions, temps) = rewriteProgram(l,f,[])
			
			val _ = (print("Temporales agregados\n");List.app print temps)
									 		 				
		in if temps = [] then (print("No hizo spill\n");(pintar,instructions)) else colorear'(instructions,f, addList (coloredNodes, temps) ) end	 
end

