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

	val empty = empty String.compare 
	
	(*Estructuras*)
	val natToInstr = ref (tabNueva())
	val longNatToInstr = ref 0
	val defs = ref (tabNueva())
	val uses = ref (tabNueva())
	val succs = ref (tabNueva())
	val liveIn = ref (tabNueva())
	val liveOut = ref (tabNueva())
	val interf = ref (tabNueva())
	val moveRelated = ref empty
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
		
		val _ = longNatToInstr := List.length(tabAList(!natToInstr)) - 1
		
		val _ = if (pFlag = 1) then (print("Cantidad de instrucciones "^Int.toString(!longNatToInstr)^"\n\nImprimo natToInstr\n");tigertab.tabPrintIntInstr(!natToInstr)) else ()
		
	(* ---------------------------------------------------------------------------------------------------------- *)
		(* Página 237:
		the CALL instructions in the Assem language have been annotated to define (interfere with) all the caller-save registers*)
		
		fun fillDefs i = case i of
							OPER {assem=s,dst=d,src=_,jump=_} =>  addList (empty,d)	
																(*let val isCall = String.isSubstring "call" s
																	 val isPop = String.isSubstring "popq" s
																	 val isPush = String.isSubstring "pushq" s
																	 val callThen = addList (empty,"rsp"::callersaves)																	 
																	 val popThen = addList (empty,"rsp"::d)
																	 val pushThen = addList (empty, ["rsp"])
																	 val genElse = addList (empty,d)																	  
																 in if isCall then callThen else (if isPop then popThen else (if isPush then pushThen else genElse)) end*)
							| LABEL {assem=_,lab=_} => empty
							| MOVE {assem=_,dst=d,src=_} => singleton String.compare d 
								
		val _ = defs := (tabAAplica (id,fillDefs,!natToInstr))
		
		val _ = if (pFlag = 1) then (print ("\nImprimo defs\n");tigertab.tabPrintIntTempSet(!defs)) else ()

	(* ---------------------------------------------------------------------------------------------------------- *)
		
		fun fillUses i = case i of 
							OPER {assem=a,dst=_,src=s,jump=_} =>  addList (empty,s)		
																(*let val isPop = String.isSubstring "popq" a
																	 val isPush = String.isSubstring "pushq" a																	 
																	 val popThen = addList (empty,["rsp"])
																	 val pushThen = addList (empty, "rsp"::s)
																	 val genElse = addList (empty,s)																	  
																 in if isPop then popThen else (if isPush then pushThen else genElse) end*)
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
																																			
		fun forEachN (0,outNueva,outVieja,inNueva,inVieja) = let
															fun buscoEnTabla (x,t) = (case (tabBusca (x,t)) of 
																						NONE => empty
																						| SOME v => v)
															fun buscoEnTablaInt (x,t) = (case (tabBusca (x,t)) of 
																						NONE => Splayset.empty Int.compare
																						| SOME v => v)
															val b = buscoEnTabla (0,inVieja)
															val inNueva' = tabRInserta (0,b,inNueva)
															
															val b1 = buscoEnTabla (0,outVieja)
															val outNueva' = tabRInserta (0,b1,outNueva)
															
															val useN = buscoEnTabla (0,!uses)										
															val outN = buscoEnTabla (0,outVieja)									
															val defN = buscoEnTabla (0,!defs)									
															val inVieja' = tabRInserta(0,union(useN,difference(outN,defN)),inVieja)
															
															val succsN = listItems (buscoEnTablaInt (0,!succs))
															fun index n = listItems (buscoEnTabla (0,inVieja'))
															
															val m = Splayset.addList(empty,List.concat (List.map index succsN))
															val outVieja' = tabRInserta (0,m,outVieja)
														in
															(outNueva',outVieja',inNueva',inVieja')
														end
		| forEachN (n,outNueva,outVieja,inNueva,inVieja) = let
															fun buscoEnTabla (x,t) = (case (tabBusca (x,t)) of 
																						NONE => empty
																						| SOME v => v)
															fun buscoEnTablaInt (x,t) = (case (tabBusca (x,t)) of 
																						NONE => Splayset.empty Int.compare
																						| SOME v => v)
															val b = buscoEnTabla (n,inVieja)
															val inNueva' = tabRInserta (n,b,inNueva)
															
															val b1 = buscoEnTabla (n,outVieja)
															val outNueva' = tabRInserta (n,b1,outNueva)
															
															val useN = buscoEnTabla (n,!uses)										
															val outN = buscoEnTabla (n,outVieja)									
															val defN = buscoEnTabla (n,!defs)									
															val inVieja' = tabRInserta(n,union(useN,difference(outN,defN)),inVieja)
															
															val succsN = listItems (buscoEnTablaInt (n,!succs))
															fun index n = listItems (buscoEnTabla (n,inVieja'))
															
															val m = Splayset.addList(empty,List.concat (List.map index succsN))
															val outVieja' = tabRInserta (n,m,outVieja)
														in
															forEachN (n-1, outNueva',outVieja',inNueva',inVieja')
														end
														
		fun repeatUntil (outNueva,outVieja,inNueva,inVieja) = let 
															val (outNueva',outVieja',inNueva',inVieja') = forEachN (!longNatToInstr,outNueva,outVieja,inNueva,inVieja)
															val fin = tabIgual (Splayset.equal,outNueva,outNueva') andalso tabIgual (Splayset.equal,inNueva,inNueva')
														in 
															if fin then (outNueva',outVieja',inNueva',inVieja') else  repeatUntil(outNueva',outVieja',inNueva',inVieja')
														end						
														
		fun liveness (0,(outNueva,outVieja,inNueva,inVieja)) = (outNueva,outVieja,inNueva,inVieja)
			| liveness (n,(outNueva,outVieja,inNueva,inVieja)) = let
																	val inVieja' = tabRInserta(n,empty,inVieja)
																	val outVieja' = tabRInserta(n,empty,outVieja)
																in liveness(n-1,repeatUntil(outNueva,outVieja',inNueva,inVieja'))
																end
														
		fun referenciar (a,b,c,d) =(ref a, ref b, ref c, ref d)
		
		val (liveOut, liveOutOld, liveIn, liveInOld) = referenciar (liveness(!longNatToInstr,(tabNueva(),tabNueva(),tabNueva(),tabNueva())))
		
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
														
		val _ = moveRelated := fillMoveRelated (!longNatToInstr)
				
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

		val _ = interf := fillInterf(!longNatToInstr,tabNueva())
		val _ = if (pFlag = 1) then (print ("\nImprimo interf\n");tigertab.tabPrintTempTempSet(!interf)) else ()
		   
	in print("ok build\n") end	 
end
