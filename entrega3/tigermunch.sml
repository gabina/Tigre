structure tigermunch :> tigermunch = struct

open tigerassem
open tigertemp
open tigerframe
open tigertree
open tigerit

(* Da vuelta los argumentos a partir del septimo, para que sean correctamente pusheados (en orden inverso) *)
fun sortArgs xs = if length xs > 6 then (List.take(xs,6)) @ rev(List.drop(xs,6)) else xs

fun its n =  if n<0 then "-" ^ Int.toString(~n) else Int.toString(n) 

fun procEntryExit2 (f : tigerframe.frame,body : instr list) =  
					let
					    val isMain = (tigerframe.name f) = "_tigermain"
					    fun store r = 
							let 
								val newTemp = newtemp()
							in (tigerassem.MOVE {assem="movq %'s0, %'d0\n",dst=newTemp,src=r},newTemp) end
						val (storeList,tempList) = ListPair.unzip (map store tigerframe.calleesaves')
						val fetchTemps = ListPair.zip (tempList, tigerframe.calleesaves')
						fun fetch (t,c) = tigerassem.MOVE {assem="movq %'s0, %'d0\n",dst=c,src=t}
						val fetchList = map fetch fetchTemps
						val i = 1024
						val prol = [OPER {assem = "pushq %'s0\n",src=["rbp",sp],dst=[sp],jump=NONE},tigerassem.MOVE {assem="movq %'s0, %'d0\n",dst="rbp",src="rsp"},OPER {assem="subq $"^its(i)^", %'d0\n",src=["rsp"],dst=["rsp"],jump=NONE}]
						val epil = [tigerassem.MOVE {assem="movq %'s0, %'d0\n",dst="rsp",src="rbp"},OPER {assem = "pop %'d0\n",src=[sp],dst=["rbp",sp],jump=NONE},OPER {assem = "ret\n",src=[],dst=[],jump=NONE}]
						val ret = OPER {assem = "ret\n",src=[],dst=[],jump=NONE}
				   in  if isMain then prol@body@epil(*body@[ret]*) else prol@storeList@body@fetchList@epil end	
				   
fun codeGen (frame: tigerframe.frame) (stm:tigertree.stm) : tigerassem.instr list =
let
	val ilist = ref ([] : tigerassem.instr list)
	
	fun emit x = ilist := x :: !ilist
	
	fun result (gen) = let val t = tigertemp.newtemp() in gen t; t end
	
	fun natToReg 0 = tigerframe.rdi
		| natToReg 1 = tigerframe.rsi
		| natToReg 2 = tigerframe.rdx
		| natToReg 3 = tigerframe.rcx
		| natToReg 4 = tigerframe.r8
		| natToReg 5 = tigerframe.r9
		| natToReg _ = raise Fail "No deberia pasar (natToReg)"

	fun munchStm s = 
		case s of
			SEQ(a,b) 							=> (munchStm a; munchStm b)
			| EXP (TEMP _) 						=> ()
			| MOVE (TEMP t,CONST i) 			=> emit (OPER {assem="movq $"^its(i)^", %'d0\n",src=[],dst=[t],jump=NONE})
			| MOVE (MEM(e1),CONST i) 			=> emit (OPER {assem="movq $"^its(i)^", (%'d0)\n",src=[],dst=[munchExp e1],jump=NONE})
		    | MOVE (MEM(e1),MEM(e2)) 			=> let val t = tigertemp.newtemp () 
		                                           in ((emit (OPER {assem="movq (%'s0), %'d0\n",src=[munchExp e2],dst=[t],jump=NONE}));
												        emit (OPER {assem="movq %'s0, (%'s1)\n",src=[t,munchExp e1],dst=[],jump=NONE}))
												   end
			| MOVE (TEMP t, CALL(NAME e,args)) 	=> (munchArgs (0,sortArgs args); emit (OPER {assem="call "^e^"\n",src=[sp],dst=callersaves,jump=NONE}); 
																		emit (OPER {assem="movq %rax, %'d0\n",src=[],dst=[t],jump=NONE}))							   
			| MOVE (MEM(e1),e2) 				=> emit (OPER {assem="movq %'s0, (%'s1)\n",src=[munchExp e2,munchExp e1],dst=[],jump=NONE})
			| MOVE (TEMP i,e2) 					=> emit (tigerassem.MOVE {assem="movq %'s0, %'d0\n",src=(munchExp e2),dst=i})
			| JUMP (NAME n,l) 					=> emit (OPER {assem="jmp "^n^"\n",src=[],dst=[],jump=SOME l})
			| JUMP (_, l) 						=> emit (OPER {assem="No deberia pasar (jump)\n",src=[],dst=[],jump=SOME l})
			| CJUMP (oper,CONST i,CONST j,l1,l2)=> let val res = case oper of
																	EQ => i = j
																	| NE => i <> j
																	| LT => i < j
																	| GT => i > j
																	| LE => i <= j
																	| GE => i >= j
																	| ULT => raise Fail "No deberia pasar (cjump ULT)"
																	| ULE => raise Fail "No deberia pasar (cjump ULE)"
																	| UGT => raise Fail "No deberia pasar (cjump UGT)"
																	| UGE => raise Fail "No deberia pasar (cjump UGE)"
														val lab = if res then l1 else l2												
												    in emit (OPER {assem="jmp "^lab^"\n",src=[],dst=[],jump=SOME [lab]})
												    end	
		    | CJUMP (oper,e1,CONST i,l1,l2) 	=> let val res = case oper of
														  		EQ => "je"
																| NE => "jne"
																| LT => "jl"
																| GT => "jg"
																| LE => "jle"
																| GE => "jge"
																| ULT => raise Fail "No deberia pasar (cjump ULT)"
																| ULE => raise Fail "No deberia pasar (cjump ULE)"
																| UGT => raise Fail "No deberia pasar (cjump UGT)"
																| UGE => raise Fail "No deberia pasar (cjump UGE)"	
													   val t = tigertemp.newtemp () 																																								
												   in (emit (OPER {assem="movq $"^its(i)^", %'d0\n",src=[],dst=[t],jump=NONE});
												       emit (OPER {assem="cmpq %'s0, %'s1\n",src=[t,munchExp e1],dst=[],jump=NONE});
													   emit (OPER {assem=res^" "^l1^"\n",src=[],dst=[],jump=SOME [l1,l2]}))
												   end
			| CJUMP (oper,CONST i,e1,l1,l2) 	=> let val res = case oper of
																EQ => "je"
																| NE => "jne"
																| LT => "jl"
																| GT => "jg"
																| LE => "jle"
																| GE => "jge"
																| ULT => raise Fail "No deberia pasar (cjump ULT)"
																| ULE => raise Fail "No deberia pasar (cjump ULE)"
																| UGT => raise Fail "No deberia pasar (cjump UGT)"
																| UGE => raise Fail "No deberia pasar (cjump UGE)"		
														val t = tigertemp.newtemp ()																																									
												   in (emit (OPER {assem="movq $"^its(i)^", %'d0\n",src=[],dst=[t],jump=NONE});
												       emit (OPER {assem="cmpq %'s0, %'s1\n",src=[munchExp e1,t],dst=[],jump=NONE});
												       emit (OPER {assem=res^" "^l1^"\n",src=[],dst=[],jump=SOME [l1,l2]}))
												   end										
			| CJUMP (oper,e1,e2,l1,l2) 			=> let val res = case oper of
															EQ => "je"
															| NE => "jne"
															| LT => "jl"
															| GT => "jg"
															| LE => "jle"
															| GE => "jge"
															| ULT => raise Fail "No deberia pasar (cjump ULT)"
															| ULE => raise Fail "No deberia pasar (cjump ULE)"
															| UGT => raise Fail "No deberia pasar (cjump UGT)"
															| UGE => raise Fail "No deberia pasar (cjump UGE)"																																										
												   in (emit (OPER {assem="cmpq %'s0, %'s1\n",src=[munchExp e2,munchExp e1],dst=[],jump=NONE});
										 	           emit (OPER {assem=res^" "^l1^"\n",src=[],dst=[],jump=SOME [l1,l2]}))
										           end
			| LABEL lab 						=> emit (tigerassem.LABEL {assem=lab^":\n",lab=lab})
			| EXP (CALL (NAME n,args)) 			=> (munchArgs(0,sortArgs args);(emit (OPER {assem="call "^n^"\n",src=[sp],dst=callersaves,jump=NONE})))
			| EXP (CALL (e,args)) 				=> raise Fail "No deberia pasar (call)\n"
			| _ 								=> emit (OPER {assem = "No hay mas casos (munchStm)\n",src=[],dst=[],jump=NONE})
		     
	and munchExp e = 
		case e of
			CONST i 			=> result (fn r => emit (OPER {assem="movq $"^its(i)^", %'d0\n",src=[],dst=[r],jump=NONE}))
			| TEMP t 			=> t		
			| NAME l 			=> result (fn r => emit (OPER {assem="movq $"^l^", %'d0\n",src=[],dst=[r],jump=NONE})) 
			| BINOP(PLUS,CONST i,CONST j) 	=> result (fn r => emit (OPER{assem="movq $"^its(i+j)^", %'d0\n",src=[],dst=[r],jump=NONE}))
			| BINOP(MUL,CONST i,CONST j) 	=> result (fn r => emit (OPER{assem="movq $"^its(i*j)^", %'d0\n",src=[],dst=[r],jump=NONE}))
			| BINOP(MINUS,CONST i,CONST j) 	=> result (fn r => emit (OPER{assem="movq $"^its(i-j)^", %'d0\n",src=[],dst=[r],jump=NONE}))

			| BINOP(PLUS,TEMP t,e1) 	=> result (fn r => (emit (tigerassem.MOVE {assem="movq %'s0, %'d0\n",src=t,dst=r});
								            emit (OPER {assem="addq %'s0, %'d0\n",src=[munchExp e1,r],dst=[r],jump=NONE})))
(*
			| BINOP(MUL,TEMP t,e1) 		=> result (fn r => (emit (tigerassem.MOVE {assem = "movq %'s0, %'d0\n",src=t,dst=r});
								            emit (OPER {assem="imul %'s0, %'d0\n",src=[munchExp e1,r],dst=[r],jump=NONE})))
	*)										            
			
			| BINOP(MUL,e1, TEMP t) 	=> result (fn r => (emit (OPER{assem = "movq %'s0, %'d0\n",src=[munchExp e1],dst=[r],jump=NONE});
										    emit (OPER{assem="imul %'s0, %'d0\n",src=[t,r],dst=[r],jump=NONE})))  
										    
			| BINOP(MINUS,TEMP t,e1) 	=> result (fn r => (emit (tigerassem.MOVE {assem="movq %'s0, %'d0\n",src=t,dst=r});
								            emit (OPER {assem="subq %'s0, %'d0\n",src=[munchExp e1,r],dst=[r],jump=NONE})))		
			| BINOP (PLUS,e,CONST i) 	=> result (fn r => (emit (OPER {assem="movq %'s0, %'d0\n",src=[munchExp e],dst=[r],jump=NONE});
						   				    emit (OPER {assem="addq $"^its(i)^", %'d0\n",src=[r],dst=[r],jump=NONE})))   
                                   
			| BINOP (MINUS,e,CONST i) 	=> result (fn r => (emit (OPER {assem="movq %'s0, %'d0\n",src=[munchExp e],dst=[r],jump=NONE});
						   				    emit (OPER {assem="subq $"^its(i)^", %'d0\n",src=[r],dst=[r],jump=NONE})))
			| BINOP (MUL,e,CONST i) 	=> result (fn r => (emit (OPER {assem="movq %'s0, %'d0\n",src=[munchExp e],dst=[r],jump=NONE});
						   				    emit (OPER {assem="imul $"^its(i)^", %'d0\n",src=[r],dst=[r],jump=NONE})))

			| BINOP (PLUS,CONST i,e) 	=> result (fn r => (emit (OPER {assem="movq $"^its(i)^", %'d0\n",src=[],dst=[r],jump=NONE});
									    emit (OPER {assem="addq11 %'s0, %'d0\n",src=[munchExp e,r],dst=[r],jump=NONE})))

			| BINOP (MINUS,CONST i,e) 	=> result (fn r => (emit (OPER {assem="movq $"^its(i)^", %'d0\n",src=[],dst=[r],jump=NONE});
										    emit (OPER {assem="subq %'s0, %'d0\n",src=[munchExp e,r],dst=[r],jump=NONE})))

			| BINOP (MUL,CONST i,e)		 => result (fn r => (emit (OPER {assem="movq $"^its(i)^", %'d0\n",src=[],dst=[r],jump=NONE});
										    emit (OPER {assem="imul %'s0, %'d0\n",src=[munchExp e,r],dst=[r],jump=NONE})))												

			| BINOP(PLUS,e1, TEMP t) 	=> result (fn r => (emit (OPER{assem = "movq %'s0, %'d0\n",src=[munchExp e1],dst=[r],jump=NONE});
										    emit (OPER{assem="addq %'s0, %'d0\n",src=[t,r],dst=[r],jump=NONE})))

			| BINOP(MINUS,e1, TEMP t) 	=> result (fn r => (emit (OPER{assem = "movq %'s0, %'d0\n",src=[munchExp e1],dst=[r],jump=NONE});
										    emit (OPER{assem="subq %'s0, %'d0\n",src=[t,r],dst=[r],jump=NONE})))
												
			| BINOP(PLUS,MEM e,CONST i) 	=> result (fn r => (emit (OPER {assem ="movq (%'s0), %'d0\n",src=[munchExp e],dst=[r],jump=NONE});
									    emit (OPER {assem="addq $"^its(i)^", %'d0\n",src=[r],dst=[r],jump=NONE})))
			| BINOP(MINUS,MEM e,CONST i) 	=> result (fn r => (emit (OPER {assem ="movq (%'s0), %'d0\n",src=[munchExp e],dst=[r],jump=NONE});
									    emit (OPER {assem="subq $"^its(i)^", %'d0\n",src=[r],dst=[r],jump=NONE})))	                                           
			| BINOP(MUL,MEM e,CONST i) 	=> result (fn r => (emit (OPER {assem ="movq (%'s0), %'d0\n",src=[munchExp e],dst=[r],jump=NONE});
									    emit (OPER {assem="imul $"^its(i)^", %'d0\n",src=[r],dst=[r],jump=NONE})))			
			| BINOP(DIV,e1,e2) 		=> result (fn r => emit (OPER {assem="movq %'s0,%'d0; cqto; idiv %'s1; movq %'s2, %'d1\n",src=[munchExp e1,munchExp e2, 						tigerframe.rv],dst=[tigerframe.rv,r,tigerframe.rdx],jump=NONE}))
			| MEM (CONST i)			=> result (fn r => emit (OPER {assem="movq ($"^its(i)^"), %'d0\n",src=[],dst=[r],jump=NONE}))
			| MEM (BINOP(PLUS,e1,CONST i)) 	=> result (fn r => emit (OPER {assem="movq "^its(i)^"(%'s0), %'d0\n",src=[munchExp e1],dst=[r],jump=NONE}))						
			| MEM (BINOP(PLUS,CONST i,e1)) 	=> result (fn r => emit (OPER {assem="movq "^its(i)^"(%'s0), %'d0\n",src=[munchExp e1],dst=[r],jump=NONE}))					
			| MEM (e1) 			=> result (fn r 	=> emit(OPER {assem="movq (%'s0), %'d0\n",src=[munchExp e1],dst=[r],jump=NONE}))	
			| BINOP (PLUS, e1,e2) => result (fn r => (emit (OPER {assem="movq %'s0, %'d0\n",src=[munchExp e2], dst=[r],jump=NONE});
                                                       emit (OPER {assem ="addq %'s0, %'d0\n",src=[munchExp e1,r], dst=[r],jump=NONE})))
            | BINOP (MINUS, e1,e2) => result (fn r => (emit (OPER {assem="movq %'s0, %'d0\n",src=[munchExp e2], dst=[r],jump=NONE});
                                                       emit (OPER {assem ="subq %'s0, %'d0\n",src=[munchExp e1,r], dst=[r],jump=NONE})))                                                                                               
            | BINOP (MUL, e1,e2) => result (fn r => (emit (OPER {assem="movq %'s0, %'d0\n",src=[munchExp e2], dst=[r],jump=NONE});
                                                       emit (OPER {assem ="imul %'s0, %'d0\n",src=[munchExp e1,r], dst=[r],jump=NONE})))                                           
			| _ 				=> result (fn r => emit (OPER {assem="No hay mas casos (munchExp)\n",src=[],dst=[],jump=NONE}))
		    
	and munchArgs ((_,[]) : (int * exp list)) : unit = ()
		| munchArgs (n,((TEMP x)::xs)) 		= ((if (n<6) then emit (tigerassem.MOVE {assem = "movq %'s0, %"^(natToReg n)^"\n",src=(munchExp (TEMP x)),dst=(natToReg n)}) 
														 else emit (OPER {assem = "pushq %'s0\n",src=[x,sp],dst=[sp],jump=NONE})); munchArgs(n+1,xs))
		| munchArgs (n,((CONST i)::xs)) 	= ((if (n<6) then emit (OPER {assem = "movq $"^its(i)^", %"^(natToReg n)^"\n",src=[],dst=[natToReg n],jump=NONE}) 
														 else emit (OPER {assem = "pushq $"^its(i)^"\n",src=[sp],dst=[sp],jump=NONE})); munchArgs(n+1,xs))
		| munchArgs (n,((NAME l)::xs)) 		= ((if (n<6) then emit (OPER {assem = "movq $"^l^", %"^(natToReg n)^"\n",src=[],dst=[natToReg n],jump=NONE}) 
														 else emit (OPER {assem = "pushq $"^l^"\n",src=[sp],dst=[sp],jump=NONE})); munchArgs(n+1,xs))
		| munchArgs (n,(MEM(CONST i))::xs) 	= ((if (n<6) then emit (OPER {assem = "movq $"^its(i)^", %"^(natToReg n)^"\n",src=[],dst=[natToReg n],jump=NONE}) 
														 else emit (OPER {assem = "pushq $"^its(i)^"\n",src=[sp],dst=[sp],jump=NONE})); munchArgs(n+1,xs))										
		| munchArgs (n,(MEM e)::xs) 		= ((if (n<6) then emit (OPER {assem = "movq (%'s0), %"^(natToReg n)^"\n",src=[munchExp e],dst=[natToReg n],jump=NONE}) 
										                 else emit (OPER {assem = "pushq (%'s0)\n",src=[munchExp e,sp],dst=[sp],jump=NONE})); munchArgs(n+1,xs))
		



        | munchArgs (n,(BINOP(PLUS,CONST i,CONST j)::xs)) = 	((if (n<6) then emit (OPER {assem = "movq $"^its(i+j)^", %"^(natToReg n)^"\n",src=[],dst=[natToReg n],jump=NONE}) 
										                 else emit (OPER {assem = "pushq $"^its(i+j)^"\n",src=[sp],dst=[sp],jump=NONE})); munchArgs(n+1,xs))
	    | munchArgs (n,(BINOP(MINUS,CONST i,CONST j)::xs)) = 	((if (n<6) then emit (OPER {assem = "movq $"^its(i-j)^", %"^(natToReg n)^"\n",src=[],dst=[natToReg n],jump=NONE}) 
										                 else emit (OPER {assem = "pushq $"^its(i-j)^"\n",src=[sp],dst=[sp],jump=NONE})); munchArgs(n+1,xs))			
		| munchArgs (n,(BINOP(MUL,CONST i,CONST j)::xs)) = 	((if (n<6) then emit (OPER {assem = "movq $"^its(i*j)^", %"^(natToReg n)^"\n",src=[],dst=[natToReg n],jump=NONE}) 
										                 else emit (OPER {assem = "pushq $"^its(i*j)^"\n",src=[sp],dst=[sp],jump=NONE})); munchArgs(n+1,xs))	
		| munchArgs (n,(BINOP(DIV,e1,e2))::xs) = ((if (n<6) then emit (OPER {assem="movq %'s0,%'d0; cqto; idiv %'s1; movq %'s2, %'d1; movq %rax, %"^(natToReg n)^"\n",src=[munchExp e1,munchExp e2, tigerframe.rv],dst=[tigerframe.rv,tigerframe.rdx,natToReg n],jump=NONE}) 
		                                                    else emit (OPER {assem="movq %'s0,%'d0; cqto; idiv %'s1; movq %'s2, %'d1; pushq %rax\n",src=[munchExp e1,munchExp e2, tigerframe.rv,sp],dst=[tigerframe.rv,tigerframe.rdx,sp],jump=NONE})))								                 							                 					



		| munchArgs (n,(BINOP(PLUS,TEMP t,e1))::xs) = ((if (n<6) then (emit (OPER {assem="movq %'s0, %'d0\n",src=[t], dst=[natToReg n],jump=NONE});
                                                                              emit (OPER {assem ="addq %'s0, %'d0\n",src=[munchExp e1,natToReg n], dst=[natToReg n],jump=NONE}))
								 else ((result (fn r => (emit (OPER {assem="movq %'s0, %'d0\n",src=[t], dst=[r],jump=NONE});
	                                                                                      emit (OPER {assem ="addq %'s0, %'d0\n",src=[munchExp e1,r], dst=[r],jump=NONE});
									                       emit (OPER{assem="pushq %'s0\n",src=[r,sp],dst=[sp],jump=NONE}))));()));munchArgs(n+1,xs))
													
		| munchArgs (n,(BINOP(MUL,TEMP t,e1))::xs) = ((if (n<6) then (emit (OPER {assem="movq %'s0, %'d0\n",src=[t], dst=[natToReg n],jump=NONE});
                                                                              emit (OPER {assem ="imul %'s0, %'d0\n",src=[munchExp e1,natToReg n], dst=[natToReg n],jump=NONE}))
								 else ((result (fn r => (emit (OPER {assem="movq %'s0, %'d0\n",src=[t], dst=[r],jump=NONE});
	                                                                                      emit (OPER {assem ="imul %'s0, %'d0\n",src=[munchExp e1,r], dst=[r],jump=NONE});
									                       emit (OPER{assem="pushq %'s0\n",src=[r,sp],dst=[sp],jump=NONE}))));()));munchArgs(n+1,xs))
 
		| munchArgs (n,(BINOP(MINUS,TEMP t,e1))::xs) = ((if (n<6) then (emit (OPER {assem="movq %'s0, %'d0\n",src=[t], dst=[natToReg n],jump=NONE});
                                                                              emit (OPER {assem ="subq %'s0, %'d0\n",src=[munchExp e1,natToReg n], dst=[natToReg n],jump=NONE}))
								 else ((result (fn r => (emit (OPER {assem="movq %'s0, %'d0\n",src=[t], dst=[r],jump=NONE});
	                                                                                      emit (OPER {assem ="subq %'s0, %'d0\n",src=[munchExp e1,r], dst=[r],jump=NONE});
									                       emit (OPER{assem="pushq %'s0\n",src=[r,sp],dst=[sp],jump=NONE}))));()));munchArgs(n+1,xs))




	    | munchArgs (n,(BINOP(PLUS,e1,TEMP t))::xs) = ((if (n<6) then (emit (OPER {assem="movq %'s0, %'d0\n",src=[munchExp e1], dst=[natToReg n],jump=NONE});
                                                                              emit (OPER {assem ="addq %'s0, %'d0\n",src=[t,natToReg n], dst=[natToReg n],jump=NONE}))
								 else ((result (fn r => (emit (OPER {assem="movq %'s0, %'d0\n",src=[munchExp e1], dst=[r],jump=NONE});
	                                                                                      emit (OPER {assem ="addq %'s0, %'d0\n",src=[t,r], dst=[r],jump=NONE});
									                       emit (OPER{assem="pushq %'s0\n",src=[r,sp],dst=[sp],jump=NONE}))));()));munchArgs(n+1,xs))
													
		| munchArgs (n,(BINOP(MUL,e1,TEMP t))::xs) =((if (n<6) then (emit (OPER {assem="movq %'s0, %'d0\n",src=[munchExp e1], dst=[natToReg n],jump=NONE});
                                                                              emit (OPER {assem ="imul %'s0, %'d0\n",src=[t,natToReg n], dst=[natToReg n],jump=NONE}))
								 else ((result (fn r => (emit (OPER {assem="movq %'s0, %'d0\n",src=[munchExp e1], dst=[r],jump=NONE});
	                                                                                      emit (OPER {assem ="imul %'s0, %'d0\n",src=[t,r], dst=[r],jump=NONE});
									                       emit (OPER{assem="pushq %'s0\n",src=[r,sp],dst=[sp],jump=NONE}))));()));munchArgs(n+1,xs))
													
		| munchArgs (n,(BINOP(MINUS,e1,TEMP t))::xs) = ((if (n<6) then (emit (OPER {assem="movq %'s0, %'d0\n",src=[munchExp e1], dst=[natToReg n],jump=NONE});
                                                                              emit (OPER {assem ="subq %'s0, %'d0\n",src=[t,natToReg n], dst=[natToReg n],jump=NONE}))
								 else ((result (fn r => (emit (OPER {assem="movq %'s0, %'d0\n",src=[munchExp e1], dst=[r],jump=NONE});
	                                                                                      emit (OPER {assem ="subq %'s0, %'d0\n",src=[t,r], dst=[r],jump=NONE});
									                       emit (OPER{assem="pushq %'s0\n",src=[r,sp],dst=[sp],jump=NONE}))));()));munchArgs(n+1,xs))		

        | munchArgs (n,(BINOP(PLUS, e1,e2))::xs) =  ((if (n<6) then (emit (OPER {assem="movq %'s0, %'d0\n",src=[munchExp e2], dst=[natToReg n],jump=NONE});
                                                                     emit (OPER {assem ="addq %'s0, %'d0\n",src=[munchExp e1,natToReg n], dst=[natToReg n],jump=NONE}))
								                     else ((result (fn r => (emit (OPER {assem="movq %'s0, %'d0\n",src=[munchExp e2], dst=[r],jump=NONE});
	                                                                         emit (OPER {assem ="addq %'s0, %'d0\n",src=[munchExp e1,r], dst=[r],jump=NONE});
									                                         emit (OPER{assem="pushq %'s0\n",src=[r,sp],dst=[sp],jump=NONE}))));()));munchArgs(n+1,xs))		
		| munchArgs (n,(BINOP(MINUS, e1,e2))::xs) =  ((if (n<6) then (emit (OPER {assem="movq %'s0, %'d0\n",src=[munchExp e1], dst=[natToReg n],jump=NONE});
                                                                     emit (OPER {assem ="subq %'s0, %'d0\n",src=[munchExp e2,natToReg n], dst=[natToReg n],jump=NONE}))
								                     else ((result (fn r => (emit (OPER {assem="movq %'s0, %'d0\n",src=[munchExp e1], dst=[r],jump=NONE});
	                                                                         emit (OPER {assem ="subq %'s0, %'d0\n",src=[munchExp e2,r], dst=[r],jump=NONE});
									                                         emit (OPER{assem="pushq %'s0\n",src=[r,sp],dst=[sp],jump=NONE}))));()));munchArgs(n+1,xs))
		| munchArgs (n,(BINOP(MUL, e1,e2))::xs) =  ((if (n<6) then (emit (OPER {assem="movq %'s0, %'d0\n",src=[munchExp e2], dst=[natToReg n],jump=NONE});
                                                                     emit (OPER {assem ="imul %'s0, %'d0\n",src=[munchExp e1,natToReg n], dst=[natToReg n],jump=NONE}))
								                     else ((result (fn r => (emit (OPER {assem="movq %'s0, %'d0\n",src=[munchExp e2], dst=[r],jump=NONE});
	                                                                         emit (OPER {assem ="imul %'s0, %'d0\n",src=[munchExp e1,r], dst=[r],jump=NONE});
									                                         emit (OPER{assem="pushq %'s0\n",src=[r,sp],dst=[sp],jump=NONE}))));()));munchArgs(n+1,xs))							                                         							                                         																	
		
		| munchArgs (n,xs) 					= ((List.app (print o tigerit.treeExp) xs);())(*(print("el n es:"^its(n)^"\n"^"la lista long: "^its(List.length(xs))^"\n");(raise Fail "No hay mas casos (munchArgs)"))*)
		
in 
	(munchStm stm; List.rev (!ilist))

end
end

