structure tigermunch :> tigermunch = struct

open tigerassem
val asMOVE = MOVE
val asLABEL = LABEL

open tigertemp
open tigerframe
open tigertree

fun codeGen (frame: tigerframe.frame) (stm:tigertree.stm) : tigerassem.instr list =
let
	val ITS = Int.toString
	val ilist = ref ([] : tigerassem.instr list)
	
	fun emit x = ilist := x :: !ilist
	
	fun result (gen) = let val t = tigertemp.newtemp() in gen t; t end
	
	fun natToReg 0 = tigerframe.rdi
		| natToReg 1 = tigerframe.rsi
		| natToReg 2 = tigerframe.rdx
		| natToReg 3 = tigerframe.rcx
		| natToReg 4 = tigerframe.r8
		| natToReg 5 = tigerframe.r9
		| natToReg _ = raise Fail "error fatal natToReg"

	fun munchStm s = 
		case s of
			SEQ(a,b) 							=> (munchStm a; munchStm b)
			| EXP (TEMP _) 						=> ()
			| MOVE (TEMP t,CONST i) 	=> emit (OPER {assem = "movq $"^ITS(i)^", %'d0\n",src=[], dst= [munchExp (TEMP t)], jump = NONE})
			| MOVE (MEM(e1),CONST i) 	=>  emit (OPER {assem = "movq $"^ITS(i)^", (%'d0)\n",src=[], dst= [munchExp e1], jump = NONE})
		    | MOVE (MEM(e1),MEM(e2)) 	=> let val t = tigertemp.newtemp () (*¿no debería estar en orden inverso? *)
		                                           in ((emit (OPER {assem="movq (%'s0), %'d0\n",src=[munchExp e2],dst=[t],jump=NONE}));
												        emit (OPER {assem="movq %'s0, (%'s1)\n", src=[t,munchExp e1], dst=[],jump=NONE}))
												   end
			| MOVE (TEMP t, CALL(NAME e,args)) => (munchArgs (0,args); (emit (OPER {assem="CALL "^e^"\n",src=[],dst=[],jump=NONE})); 
														     emit (OPER {assem = "movq %'d0, %rax\n",src=[], dst= [munchExp (TEMP t)], jump = NONE}))							   
			| tigertree.MOVE (MEM(e1),e2) => emit (OPER {assem = "movq %'s1, (%'s0)\n",src=[munchExp e1, munchExp e2], dst= [], jump = NONE})
			| tigertree.MOVE (TEMP i,e2) => emit (asMOVE {assem="movq %'s0, %'d0\n",src=(munchExp e2),dst=i})
			| JUMP (NAME n, l) =>  emit (OPER {assem="jmp "^n^"\n",src=[],dst=[],jump=SOME l})
			| JUMP (_, l) =>  emit (OPER {assem="NO COMPLETO jump\n",src=[],dst=[],jump=SOME l})
			| CJUMP (oper,CONST i,CONST j,l1,l2) => let val res = case oper of
																	EQ => i = j
																	| NE => i <> j
																	| LT => i < j
																	| GT => i > j
																	| LE => i <= j
																	| GE => i >= j
																	| ULT => raise Fail "No deberia pasar CJUMP ULT"
																	| ULE => raise Fail "No deberia pasar CJUMP ULE"
																	| UGT => raise Fail "No deberia pasar CJUMP UGT"
																	| UGE => raise Fail "No deberia pasar CJUMP UGE"													
												    in emit (OPER {assem="jmp "^(if res then l1 else l2)^"\n",src=[],dst=[],jump=SOME [if res then l1 else l2]})
												    end	
		    | CJUMP (oper,e1,CONST i,l1,l2) => let val res = case oper of
														  		EQ => "je"
																| NE => "jne"
																| LT => "jl"
																| GT => "jg"
																| LE => "jle"
																| GE => "jge"
																| ULT => raise Fail "No deberia pasar CJUMP ULT"
																| ULE => raise Fail "No deberia pasar CJUMP ULE"
																| UGT => raise Fail "No deberia pasar CJUMP UGT"
																| UGE => raise Fail "No deberia pasar CJUMP UGE"																																									
										       in (emit(OPER {assem="cmp %'s0, "^ITS(i)^"\n",src=[munchExp e1],dst=[],jump=NONE});
										           emit(OPER {assem=res^" "^l1^"\n",src=[],dst=[],jump=SOME [l1,l2]}))
										       end
			| CJUMP (oper,CONST i,e1,l1,l2) => let val res = case oper of
																EQ => "je"
																| NE => "jne"
																| LT => "jl"
																| GT => "jg"
																| LE => "jle"
																| GE => "jge"
																| ULT => raise Fail "No deberia pasar CJUMP ULT"
																| ULE => raise Fail "No deberia pasar CJUMP ULE"
																| UGT => raise Fail "No deberia pasar CJUMP UGT"
																| UGE => raise Fail "No deberia pasar CJUMP UGE"																																									
											   in (emit(OPER {assem="cmp %'s0, "^ITS(i)^"\n",src=[munchExp e1],dst=[],jump=NONE});
												   emit(OPER {assem=res^" "^l1^"\n",src=[],dst=[],jump=SOME [l1,l2]}))
											   end										
			| CJUMP (oper,e1,e2,l1,l2) => let val res = case oper of
															EQ => "JE"
															| NE => "JNE"
															| LT => "JL"
															| GT => "JG"
															| LE => "JLE"
															| GE => "JGE"
															| ULT => raise Fail "No deberia pasar CJUMP ULT"
															| ULE => raise Fail "No deberia pasar CJUMP ULE"
															| UGT => raise Fail "No deberia pasar CJUMP UGT"
															| UGE => raise Fail "No deberia pasar CJUMP UGE"																																										
										   in (emit(OPER {assem="cmp %'s0, %'s1\n",src=[munchExp e1,munchExp e2],dst=[],jump=NONE});
										 	   emit(OPER {assem=res^" "^l1^"\n",src=[],dst=[],jump=SOME [l1,l2]}))
										   end
			| LABEL lab => emit(asLABEL {assem=lab^":\n",lab=lab})
			| EXP (CALL (NAME n,args)) => (munchArgs(0,args);(emit (OPER {assem="call "^n^"\n",src=[],dst=[],jump=NONE})))
			| EXP (CALL (e,args)) => raise Fail "No deberia pasar CALL\n"
			| _ => emit (OPER {assem = "Falta munchStm\n",src=[],dst=[],jump=NONE})
		     
	and munchExp e = case e of
						CONST i => result (fn r => emit (OPER {assem = "movq "^ITS(i)^", %d0\n",src=[],dst=[r],jump=NONE}))
						| TEMP t => t		
						| NAME l => result (fn r => emit (OPER {assem = "movq "^l^", %d0\n",src=[],dst=[r],jump=NONE})) 
						| BINOP(PLUS,CONST i,CONST j) => result (fn r => (emit (OPER{assem="movq "^ITS(i+j)^", %'d0\n",src=[], dst=[r], jump=NONE})))
						| BINOP(MUL,CONST i,CONST j) => result (fn r => (emit (OPER{assem="movq "^ ITS(i*j)^", %'d0\n",src=[], dst=[r], jump=NONE})))
						| BINOP(MINUS,CONST i,CONST j) => result (fn r => (emit (OPER{assem="movq "^ITS(i-j)^", %'d0\n",src=[], dst=[r], jump=NONE})))
						
						| BINOP(PLUS,TEMP t,e1) => result (fn r=> (emit (asMOVE {assem = "movq "^t^", %'d0\n",src=t,dst=r});
						                                          (emit (OPER {assem ="addq %'s0, %'d0\n",src=[munchExp e1], dst=[r],jump=NONE}))))
						| BINOP(MUL,TEMP t,e1) => result (fn r=> (emit (asMOVE {assem = "movq "^t^", %'d0\n",src=t,dst=r});
						                                         (emit (OPER{assem="imul %'s0, %'d0\n",src=[munchExp e1], dst=[r],jump=NONE}))))		 
						| BINOP(MINUS,TEMP t,e1) => result (fn r=> (emit (asMOVE {assem = "movq "^t^", %'d0\n",src=t,dst=r});
						                                          (emit (OPER {assem ="subq %'s0, %'d0\n",src=[munchExp e1], dst=[r],jump=NONE}))))
						(*AGREGAR BINOP (_,e1,cte) y viceversa*)	   
						| BINOP (PLUS,e,CONST i) => result (fn r => (emit (asMOVE {assem="movq %'s0+"^ ITS(i)^", %'d0\n",src=(munchExp e),dst=r})))                                      
						| BINOP (MINUS,e,CONST i) => result (fn r => (emit (asMOVE {assem="movq %'s0-"^ ITS(i)^", %'d0\n",src=(munchExp e),dst=r})))
						| BINOP (MUL,e,CONST i) => result (fn r => (emit (asMOVE {assem="movq %'s0*"^ ITS(i)^", %'d0\n",src=(munchExp e),dst=r})))
						| BINOP (PLUS,CONST i,e) => result (fn r => (emit (asMOVE {assem="movq %'s0+"^ ITS(i)^", %'d0\n",src=(munchExp e),dst=r})))
						| BINOP (MINUS,CONST i,e) => result (fn r => (emit (asMOVE {assem="movq "^ ITS(i)^"- %'s0, %'d0\n",src=(munchExp e),dst=r})))
						| BINOP (MUL,CONST i,e) => result (fn r => (emit (asMOVE {assem="movq %'s0*"^ ITS(i)^", %'d0\n",src=(munchExp e),dst=r})))												
						
						| BINOP(PLUS,e1, TEMP t) => result (fn r=> (emit (asMOVE {assem = "movq "^t^", %'d0\n",src=t,dst=r});
																	emit (OPER{assem="addq %'s0, %'d0\n",src=[munchExp e1], dst=[r],jump=NONE})))
						| BINOP(MINUS,e1, TEMP t) => result (fn r=> (emit (OPER{assem="subq %'s0, %'d0\n",src=[munchExp e1], dst=[r],jump=NONE});
						                                           (emit (asMOVE {assem = "movq "^t^", %'d0\n",src=t,dst=r}))))                                           
						| BINOP(MUL,e1, TEMP t) => result (fn r=> (emit (OPER{assem="imul %'s0, %'d0\n",src=[munchExp e1], dst=[r],jump=NONE});
						                                           (emit (asMOVE {assem = "movq "^t^", %'d0\n",src=t,dst=r}))))                                           
						
						| BINOP(PLUS,MEM e,CONST i) =>  result(fn r =>emit (asMOVE {assem ="movq (%'s0)+"^ ITS(i)^", %'d0\n",src=(munchExp e),dst=r}))
						| BINOP(MINUS,MEM e,CONST i) =>  result(fn r =>emit (asMOVE {assem ="movq (%'s0)-"^ ITS(i)^", %'d0\n",src=(munchExp e),dst=r}))	                                           
						| BINOP(MUL,MEM e,CONST i) =>  result(fn r =>emit (asMOVE {assem ="movq (%'s0)*"^ ITS(i)^", %'d0\n",src=(munchExp e),dst=r}))
						
						| BINOP(DIV,e1,e2) => result (fn r => emit (OPER {assem="movq %'s0,%'d0; cqto; idiv %'s1; movq %'s2, %'d1\n",src=[munchExp e2,munchExp e2, tigerframe.rv],dst=[tigerframe.rv,r,tigerframe.rdx],jump=NONE}))
						 
						(*| BINOP (PLUS,e1,e2) => result (fn r => emit (OPER {assem= "movq %'s0, %'d0; "}))                                          *)
						| MEM (CONST i) => result (fn r => emit (OPER {assem="movq ($"^ITS(i)^"), %'d0\n",src=[],dst=[r],jump=NONE}))
						| MEM (BINOP(PLUS,e1,CONST i)) => result (fn r => emit (asMOVE {assem = "movq (%'s0+"^ ITS(i)^"), %'d0\n",src=(munchExp e1),dst=r}))						
						| MEM (BINOP(PLUS,CONST i,e1)) => result (fn r => emit (asMOVE {assem = "movq (%'s0+"^ ITS(i)^"), %'d0\n",src=(munchExp e1),dst=r}))						
						(*| MEM (BINOP(PLUS,TEMP t,CONST i)) => result (fn r => emit (OPER {assem = "Este es el caso munchExp 4\n",src=[],dst=[],jump=NONE}))	*)					
						| MEM (e1) => result(fn r => emit(asMOVE {assem="movq (%'s0), %'d0\n",src=(munchExp e1),dst=r}))	
						| _ => result (fn r => emit (OPER {assem = "Falta munchExp\n",src=[],dst=[],jump=NONE}))
		    
	and munchArgs ((_,[]) : (int * exp list)) : unit = ()
		| munchArgs (n,((TEMP x)::xs)) 		= ((if (n<6) then emit (asMOVE {assem = "movq %'s0, "^(natToReg n)^"\n",src=(munchExp (TEMP x)),dst=(natToReg n)}) 
														 else emit (OPER {assem = "pushq %'s0\n",src=[munchExp (TEMP x)],dst=[],jump=NONE})); munchArgs(n+1,xs))
		| munchArgs (n,((CONST i)::xs)) 	= ((if (n<6) then emit (OPER {assem = "movq %"^ITS(i)^", "^(natToReg n)^"\n",src=[],dst=[natToReg n],jump=NONE}) 
														 else emit (OPER {assem = "pushq $"^ITS(i)^"\n",src=[],dst=[],jump=NONE})); munchArgs(n+1,xs))
		| munchArgs (n,((NAME l)::xs)) 		= ((if (n<6) then emit (OPER {assem = "movq %"^l^", "^(natToReg n)^"\n",src=[],dst=[natToReg n],jump=NONE}) 
														 else emit (OPER {assem = "pushq $"^l^"\n",src=[],dst=[],jump=NONE})); munchArgs(n+1,xs))
		| munchArgs (n,(MEM(CONST i))::xs) 	= ((if (n<6) then emit (OPER {assem = "movq %"^ITS(i)^", "^(natToReg n)^"\n",src=[],dst=[natToReg n],jump=NONE}) 
														 else emit (OPER {assem = "pushq $"^ITS(i)^"\n",src=[],dst=[],jump=NONE})); munchArgs(n+1,xs))										
		| munchArgs (n,(MEM e)::xs) 		= ((if (n<6) then emit (asMOVE {assem = "movq (%'s0), "^(natToReg n)^"\n",src=(munchExp e),dst=(natToReg n)}) 
										                 else emit (OPER {assem = "pushq (%'s0)\n",src=[munchExp e],dst=[],jump=NONE})); munchArgs(n+1,xs))
		| munchArgs (n,(BINOP(PLUS,CONST i,CONST j)::xs)) = 	((if (n<6) then emit (OPER {assem = "movq $"^ITS(i+j)^", "^(natToReg n)^"\n",src=[],dst=[natToReg n],jump=NONE}) 
										                 else emit (OPER {assem = "pushq $"^ITS(i+j)^"\n",src=[],dst=[],jump=NONE})); munchArgs(n+1,xs))
	    | munchArgs (n,(BINOP(MINUS,CONST i,CONST j)::xs)) = 	((if (n<6) then emit (OPER {assem = "movq $"^ITS(i-j)^", "^(natToReg n)^"\n",src=[],dst=[natToReg n],jump=NONE}) 
										                 else emit (OPER {assem = "pushq $"^ITS(i-j)^"\n",src=[],dst=[],jump=NONE})); munchArgs(n+1,xs))			
		| munchArgs (n,(BINOP(MUL,CONST i,CONST j)::xs)) = 	((if (n<6) then emit (OPER {assem = "movq $"^ITS(i*j)^", "^(natToReg n)^"\n",src=[],dst=[natToReg n],jump=NONE}) 
										                 else emit (OPER {assem = "pushq $"^ITS(i*j)^"\n",src=[],dst=[],jump=NONE})); munchArgs(n+1,xs))	
		| munchArgs (n,(BINOP(DIV,e1,e2))::xs) = ((if (n<6) then emit (OPER {assem="movq %'s0,%'d0; cqto; idiv %'s1; movq %'s2, %'d1; movq %rax, "^(natToReg n)^"\n",src=[munchExp e1,munchExp e2, tigerframe.rv],dst=[natToReg n,tigerframe.rv,tigerframe.rdx],jump=NONE}) 
		                                                    else emit (OPER {assem="movq %'s0,%'d0; cqto; idiv %'s1; movq %'s2, %'d1; pushq %rax\n",src=[munchExp e1,munchExp e2, tigerframe.rv],dst=[tigerframe.rv,tigerframe.rdx],jump=NONE})))								                 							                 					
		| munchArgs (n,(BINOP(PLUS,TEMP t,e1))::xs) = ((if (n<6) then (emit (OPER {assem ="addq %'s0, "^t^"\n",src=[munchExp e1], dst=[t],jump=NONE});
													emit (asMOVE{assem="movq "^t^", "^(natToReg n)^"\n",src=t, dst=(natToReg n)}))
											  else (emit (OPER {assem ="addq %'s0, "^t^"\n",src=[munchExp e1], dst=[t],jump=NONE});
													(emit (OPER{assem="pushq "^t^"\n",src=[],dst=[],jump=NONE}))));munchArgs(n+1,xs))
													
		| munchArgs (n,(BINOP(MUL,TEMP t,e1))::xs) = ((if (n<6) then (emit (OPER {assem ="imul %'s0, "^t^"\n",src=[munchExp e1], dst=[t],jump=NONE});
													emit (asMOVE{assem="movq "^t^", "^(natToReg n)^"\n",src=t, dst=(natToReg n)}))
											  else (emit (OPER {assem ="imul %'s0, "^t^"\n",src=[munchExp e1], dst=[t],jump=NONE});
													(emit (OPER{assem="pushq "^t^"\n",src=[],dst=[],jump=NONE}))));munchArgs(n+1,xs)) 
		| munchArgs (n,(BINOP(MINUS,TEMP t,e1))::xs) = ((if (n<6) then (emit (OPER {assem ="subq %'s0, "^t^"\n",src=[munchExp e1], dst=[t],jump=NONE});
													emit (asMOVE{assem="movq "^t^", "^(natToReg n)^"\n",src=t, dst=(natToReg n)}))
											  else (emit (OPER {assem ="subq %'s0, "^t^"\n",src=[munchExp e1], dst=[t],jump=NONE});
													(emit (OPER{assem="pushq "^t^"\n",src=[],dst=[],jump=NONE}))));munchArgs(n+1,xs))
	    | munchArgs (n,(BINOP(PLUS,e1,TEMP t))::xs) = ((if (n<6) then (emit (OPER {assem ="addq %'s0, "^t^"\n",src=[munchExp e1], dst=[t],jump=NONE});
													emit (asMOVE{assem="movq "^t^", "^(natToReg n)^"\n",src=t, dst=(natToReg n)}))
											  else (emit (OPER {assem ="addq %'s0, "^t^"\n",src=[munchExp e1], dst=[t],jump=NONE});
													(emit (OPER{assem="pushq "^t^"\n",src=[],dst=[],jump=NONE}))));munchArgs(n+1,xs))
													
		| munchArgs (n,(BINOP(MUL,e1,TEMP t))::xs) = ((if (n<6) then (emit (OPER {assem ="imul %'s0, "^t^"\n",src=[munchExp e1], dst=[t],jump=NONE});
													emit (asMOVE{assem="movq "^t^", "^(natToReg n)^"\n",src=t, dst=(natToReg n)}))
											  else (emit (OPER {assem ="imul %'s0, "^t^"\n",src=[munchExp e1], dst=[t],jump=NONE});
													(emit (OPER{assem="pushq "^t^"\n",src=[],dst=[],jump=NONE}))));munchArgs(n+1,xs))
													
		| munchArgs (n,(BINOP(MINUS,e1,TEMP t))::xs) = ((if (n<6) then (emit (OPER {assem ="subq %'s0, "^t^"\n",src=[munchExp e1], dst=[t],jump=NONE});
													                    emit (asMOVE{assem="movq "^t^", "^(natToReg n)^"\n",src=t, dst=(natToReg n)}))
		       									                  else (emit (OPER {assem ="subq %'s0, "^t^"\n",src=[munchExp e1], dst=[t],jump=NONE});
													                   (emit (OPER{assem="pushq "^t^"\n",src=[],dst=[],jump=NONE}))));munchArgs(n+1,xs))										
		
		| munchArgs (_,_) 					= emit (OPER {assem = "Falta munchArgs\n",src=[],dst=[],jump=NONE}) 
		
in 
	(munchStm stm; List.rev (!ilist))

end
end
