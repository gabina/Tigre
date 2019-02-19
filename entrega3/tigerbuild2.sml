structure tigerbuild :> tigerbuild =
struct
	open tigerassem
	open tigertemp
	open tigertab
	open Splayset
	open tigerframe
	
	fun name x = x
	fun id x = x
	type interfTab = (tigertemp.temp, tigertemp.temp Splayset.set) tigertab.Tabla

	val emptyStr = empty String.compare														
	val emptyInt = empty Int.compare	
	val empty = empty String.compare 
	
	(*Estructuras*)
	val natToInstr = ref (tabNueva())
	val defs = ref (tabNueva())
	val uses = ref (tabNueva())
	val succs = ref (tabNueva())
	val liveIn = ref (tabNueva())
	val liveOut = ref (tabNueva())
	val interf = ref (tabNueva())
	val moveRelated = ref empty
	val workSetMoves = ref (emptyInt) (* intrucciones moves que pueden ser coaleasced *)
	val moveSet = ref (tabNueva()) (*equivale a moveList del libro. pagina 243  *)
	
	(*--------------*)

	(* 
	val fp = "rbp"				(* frame pointer *)
	val sp = "rsp"				(* stack pointer *)
	val rv = "rax"				(* return value  *)
	val rdi ="rdi"
	val rsi = "rsi"
	val rdx = "rdx"
	val rcx = "rcx"
	val r8 = "r8"
	val r9 = "r9"	
	val callersaves = [rv,rcx,rdx,rsi,rdi,r8,r9]	
	val calleesaves = ["rbx", fp, sp, "r10", "r11", "r12", "r13", "r14", "r15"]
	val registers = [rv,"rbx",rcx,rdx,rsi,rdi,fp,sp,r8,r9,"r10","r11","r12","r13","r14","r15"]
	*)
	fun isMoveRelated t = member (!moveRelated,t)
	
	fun build (instrList : instr list,pFlag) = 
	let
	
	(* ---------------------------------------------------------------------------------------------------------- *)
		
		fun fillNatToInstr ([],_) = tabNueva()
			| fillNatToInstr (x::xs,n) = tabInserta (n,x,fillNatToInstr (xs,n+1))
			
		val _ = natToInstr := fillNatToInstr(instrList,0) 	
		
		val longNatToInstr = List.length(instrList) 
		val lastInstrNumber = longNatToInstr - 1
		
		val _ = if (pFlag = 1) then (print("Cantidad de instrucciones "^Int.toString(longNatToInstr)^"\n\nImprimo natToInstr\n");tigertab.tabPrintIntInstr(!natToInstr)) else ()
		
	(* ---------------------------------------------------------------------------------------------------------- *)
		
		fun fillDefs i = case i of
							OPER {assem=s,dst=d,src=_,jump=_} =>  addList (empty,d)	
							| LABEL {assem=_,lab=_} => empty
							| MOVE {assem=_,dst=d,src=_} => singleton String.compare d 
								
		val _ = defs := (tabAAplica (id,fillDefs,!natToInstr))
		
		val _ = if (pFlag = 1) then (print ("\nImprimo defs\n");tigertab.tabPrintIntTempSet(!defs)) else ()

	(* ---------------------------------------------------------------------------------------------------------- *)
		
		fun fillUses i = case i of 
							OPER {assem=a,dst=_,src=s,jump=_} =>  addList (empty,s)		
							| LABEL {assem=_,lab=_} => empty
							| MOVE {assem=_,dst=_,src=s} => singleton String.compare s
								
		val _ = uses := (tabAAplica (id,fillUses,!natToInstr))
		val _ = if (pFlag = 1) then (print ("\nImprimo uses\n");tigertab.tabPrintIntTempSet(!uses)) else ()
		
	(* ---------------------------------------------------------------------------------------------------------- *)
		
		(* Retorna los nodos del natToInstr que tienen como etiqueta a l *)
		fun findLabel l = tabClaves(tabFiltra ((fn i => case i of 
														LABEL {assem=_,lab=l1} => ((l1 <= l) andalso (l1 >= l))
														| _ => false), !natToInstr)) 
			
								
		fun fillSuccs ([],_) = tabNueva()
			| fillSuccs ((x::xs),n) = let
											val empty = Splayset.empty Int.compare
									  in 
											case x of 
												OPER {assem=a,dst=d,src=s,jump=j} => (case j of
																				NONE => tabInserta(n,addList (empty,[n+1]),fillSuccs(xs,n+1))
																				| SOME l => tabInserta (n,addList(empty,List.concat ((List.map findLabel l) : int list list)), fillSuccs(xs,n+1)))
												| LABEL {assem=a,lab=l} => tabInserta(n,addList(empty,[n+1]),fillSuccs(xs,n+1)) 
												| MOVE {assem=a,dst=d,src=s} => tabInserta(n,addList(empty,[n+1]),fillSuccs(xs,n+1))	
									 end
									 
		val _ = succs := fillSuccs (instrList ,0)
		val _ = if (pFlag = 1) then (print ("\nImprimo succs\n"); tigertab.tabPrintIntIntSet(!succs)) else ()
					
	(* ---------------------------------------------------------------------------------------------------------- *)			
									
		(* dado un nodo retorna si es un MOVE o no*)							
		fun isMove i = case tabBusca (i,!natToInstr) of
						SOME (MOVE {assem=a,dst=d,src=s}) => true
						| _ => false												
																																			
		fun forEachN (0,outNueva,outVieja,inNueva,inVieja) = (outNueva,outVieja,inNueva,inVieja)
		| forEachN (n,outNueva,outVieja,inNueva,inVieja) = let
															val nReal = longNatToInstr - n
															fun buscoEnTabla (x,t) = (case (tabBusca (x,t)) of 
																						NONE => empty
																						| SOME v => v)
															fun buscoEnTablaInt (x,t) = (case (tabBusca (x,t)) of 
																						NONE => Splayset.empty Int.compare
																						| SOME v => v)
															val b = buscoEnTabla (nReal,inVieja)
															val inNueva' = tabRInserta (nReal,b,inNueva)
															
															val b1 = buscoEnTabla (nReal,outVieja)
															val outNueva' = tabRInserta (nReal,b1,outNueva)
															
															val useN = buscoEnTabla (nReal,!uses)										
															val outN = buscoEnTabla (nReal,outVieja)									
															val defN = buscoEnTabla (nReal,!defs)									
															val inVieja' = tabRInserta(nReal,union(useN,difference(outN,defN)),inVieja)
															
															val succsN = listItems (buscoEnTablaInt (nReal,!succs))
															fun index m = listItems (buscoEnTabla (m,inVieja'))
															
															val m = Splayset.addList(empty,List.concat (List.map index succsN))
															val outVieja' = tabRInserta (nReal,m,outVieja)
														in
															forEachN (n-1, outNueva',outVieja',inNueva',inVieja')
														end
														
		fun repeatUntil (outNueva,outVieja,inNueva,inVieja) = let 
															val (outNueva',outVieja',inNueva',inVieja') = forEachN (longNatToInstr,outNueva,outVieja,inNueva,inVieja)
															val fin = tabIgual (Splayset.equal,outNueva,outNueva') andalso tabIgual (Splayset.equal,inNueva,inNueva')
														in 
															if fin then (outNueva',outVieja',inNueva',inVieja') else  repeatUntil(outNueva',outVieja',inNueva',inVieja')
														end						
														
		fun liveness (0,(outNueva,outVieja,inNueva,inVieja)) = (outNueva,outVieja,inNueva,inVieja)
			| liveness (n,(outNueva,outVieja,inNueva,inVieja)) = let
																	val nReal = longNatToInstr - n
																	val inVieja' = tabRInserta(nReal,empty,inVieja)
																	val outVieja' = tabRInserta(nReal,empty,outVieja)
																in liveness(n-1,repeatUntil(outNueva,outVieja',inNueva,inVieja'))
																end
														
		fun referenciar (a,b,c,d) =(ref a, ref b, ref c, ref d)
		
		val (liveOut, liveOutOld, liveIn, liveInOld) = referenciar (liveness(longNatToInstr,(tabNueva(),tabNueva(),tabNueva(),tabNueva())))
		
		val _ = if (pFlag = 1) then (print ("\nImprimo liveIn\n");tigertab.tabPrintIntTempSet(!liveIn)) else ()		
		val _ = if (pFlag = 1) then (print ("\nImprimo liveOut\n");tigertab.tabPrintIntTempSet(!liveOut)) else ()
			
	(* ---------------------------------------------------------------------------------------------------------- *)			

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
	(* ---------------------------------------------------------------------------------------------------------- *)			
		
		
		fun fillMoveRelated 0 = let
									val i = buscoEnTabla (0, !natToInstr)
								in case i of
									OPER {assem=_,dst=_,src=_,jump=_} => empty
									| LABEL {assem=_,lab=_} => empty
									| MOVE {assem=_,dst=d,src=s} => add (add (empty,s),d)
								end				
		  | fillMoveRelated n = let
									val i = buscoEnTabla (n, !natToInstr)
								in case i of
									OPER {assem=_,dst=_,src=_,jump=_} => fillMoveRelated (n-1)
									| LABEL {assem=_,lab=_} => fillMoveRelated (n-1)
									| MOVE {assem=_,dst=d,src=s} => add (add (fillMoveRelated (n-1),s),d) 
								end																		
														
		val _ = moveRelated := fillMoveRelated (lastInstrNumber)
				

	(* ---------------------------------------------------------------------------------------------------------- *)			
													
		fun fillInterf (~1,tab) = tab							
			| fillInterf (n,tab) = let
									val i = buscoEnTabla (n, !natToInstr)
									fun findSet (t : temp, tabla) = (case tabBusca (t,tabla) of
																	NONE => empty
																	| SOME c => c)
									val liveouts = buscoEnTabla(n,!liveOut)
									(* f inserta en la tabla la tupla (tmp, A union B)
									donde A son todos los nodos n donde ya existe la arista (tmp,n)
									B son todos los liveouts en la instrucción donde se define tmp*)									
									in case i of
											OPER {assem=a,dst=d,src=_,jump=_} => 
												if List.null(d) then fillInterf(n-1,tab) else (let 
													val dSet = Splayset.addList(empty, d)
													
													(*val _ = print ("OPER DESTINO NO NULO\n")*)
													(*val _ = print(Int.toString(numItems(liveouts'))^"\n")*)
													fun f ((tmp, t) : (temp * interfTab)) : interfTab = 
														let val tmpSet = singleton String.compare tmp
															val liveouts' = difference (liveouts,tmpSet)
														in (tabRInserta (tmp,union(findSet(tmp,tab),liveouts'),t))	end
														(* tab' tiene todos las aristas que comienzan con di*)
													val tab' = List.foldl f tab d
													fun g (tmp,t) =
														let val tmpSet = singleton String.compare tmp
															val interfSet = difference (Splayset.union(findSet(tmp,tab'),dSet),tmpSet)
														in tabRInserta (tmp,interfSet,t) end
													val liveoutsList = Splayset.listItems liveouts
													(*val _ = print(Int.toString(numItems(dSet))^"\n")*)			
													val tab'' = List.foldl g tab' liveoutsList
												in (*print(Int.toString(n)^" "^tigerassem.format name i^"\n");tigertab.tabPrintTempTempSet(tab'');print("\n");*)fillInterf(n-1,tab'')(*)*) end)
												
											| LABEL {assem=a,lab=_} => (*(print(Int.toString(n)^" "^tigerassem.format name i^"\n");tigertab.tabPrintTempTempSet(tab);print("\n");*)fillInterf(n-1,tab)(*)*)
											
											| MOVE {assem=a,dst=d,src=s} =>
												let
													val dSet = Splayset.addList(empty, [s,d])
													val liveouts' = difference (liveouts,dSet)
													(*val liveouts' = if member(liveouts,s) then delete (liveouts,s) else liveouts  todos los liveouts menos el destino y la fuente*)
													fun f' ((tmp, t) : (temp * interfTab)) : interfTab = (tabRInserta (tmp,union(findSet(tmp,tab),liveouts'),t)) 
													val tab' = f'(d,tab)		
													val g = (fn (tmp,t) => tabRInserta (tmp,Splayset.add(findSet(tmp,tab'),d),t)) : (temp * interfTab) -> interfTab	val liveoutsList = Splayset.listItems liveouts'				
													val tab'' = List.foldl g tab' liveoutsList												
												in (*(print(Int.toString(n)^" MOVE"^tigerassem.format name i^"\n");tigertab.tabPrintTempTempSet(tab'');print("\n");*)fillInterf(n-1,tab'')(*)*) end
								end		

		val _ = interf := fillInterf(lastInstrNumber,tabNueva())
		
		val _ = if (pFlag = 1) then (print ("\nImprimo interf\n");tigertab.tabPrintTempTempSet(!interf)) else ()
		
	(* ---------------------------------------------------------------------------------------------------------- *)			

	(* fillMoves: (instr list, int,tigertemp.temp Splayset.set, (tigertemp.temp, tigertemp.temp) tigertab.Tabla) ->  (tigertemp.temp Splayset.set, (tigertemp.temp, tigertemp.temp) tigertab.Tabla) ??? conviene el numero de instruccion o mejor (src,dst,numero)????*)
    (* esta funcion llena tanto el conjunto que contiene el n° de instrucciones que son moves como la tabla a la que a cada temp le corresponde el conjunto de n° de instrucciones donde este interviene en un move*)
    fun fillMoves ([],_,sMoves,tabMoves) = (sMoves,tabMoves)
		| fillMoves ((i::xs),n,sMoves,tabMoves) = case i of 
													MOVE {assem=_,dst=d,src=s} => (let 
																						fun findSet (t : temp, tabla) = (case tabBusca (t,tabla) of
																										NONE => emptyInt
																										| SOME c => c)
																						val nSet = singleton Int.compare n
																						
																						(* Instrucciones con las que ya están relacionados la fuente y el destino*)
																						val dSet = findSet(d,tabMoves)					
																						val sSet = findSet (s,tabMoves)																			val _ = print ("hola "^s^"\n")				
																						val sMoves' = if member(buscoEnTabla(s,!interf),d) then sMoves else union(sMoves, nSet)
																						val _  = print ("chau\n")
																						
																						val tabMoves' = tabRInserta(d,union(dSet,nSet),tabRInserta(s,union(sSet,nSet),tabMoves))
																						
																					in fillMoves(xs,n+1,sMoves',tabMoves') end)
													| _ =>  fillMoves(xs,n+1,sMoves,tabMoves)

	val (workSetMoves',moveSet') = fillMoves (instrList,0,emptyInt,tabNueva())
	val _ = workSetMoves := workSetMoves'
	val _ = moveSet := moveSet'
	val _ = (print ("\nImprimo workSetMoves\n"); List.app (fn n => print(Int.toString(n)^" ")) (listItems (!workSetMoves)))
		   
	in print("ok build\n") end	 
end
