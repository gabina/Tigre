open tigerlex
open tigergrm
open tigerescap
open tigerseman
open tigermunch
open tigersimpleregalloc
open BasicIO Nonstdio
open tigercolor

fun lexstream(is: instream) =
	Lexing.createLexer(fn b => fn n => buff_input is b 0 n);
fun errParsing(lbuf) = (print("Error en parsing!("
	^(makestring(!num_linea))^
	")["^(Lexing.getLexeme lbuf)^"]\n"); raise Fail "fin!")


fun main(args) =
	let	fun arg(l, s) =
			(List.exists (fn x => x=s) l, List.filter (fn x => x<>s) l)
		val (arbol, l1)		 = arg(args, "-arbol")
		val (escapes, l2)	 = arg(l1, "-escapes") 
		val (ir, l3)		 = arg(l2, "-ir") 
		val (canon, l4)		 = arg(l3, "-canon") 
		val (code, l5)		 = arg(l4, "-code") 
		val (flow, l6)		 = arg(l5, "-flow") 
		val (inter, l7)		 = arg(l6, "-inter") 
		val (precolored, l8) = arg(l7, "-precolored")
		val (sregalloc, l9)	 = arg(l8, "-sregalloc") (*simple reg alloc*)
		val (asm, l10)		 = arg(l9, "-asm")
		val (colored, l11)	 = arg(l10, "-colored")
		val entrada =
			case l11 of
			[n] => ((open_in n)
					handle _ => raise Fail (n^" no existe!"))
			| [] => std_in
			| _ => raise Fail "opcion desconocida!"
		val lexbuf = lexstream entrada
		val expr = prog Tok lexbuf handle _ => errParsing lexbuf
		val _ = findEscape(expr)
		
		val _ = if arbol then tigerpp.exprAst expr else ()
		
		val _ = transProg(expr)
		
		(**************************************************************************************)
		val frags = tigertrans.getResult() : tigerframe.frag list
		
		val canonizar = tigercanon.traceSchedule o tigercanon.basicBlocks o tigercanon.linearize
		
		fun makelist [] = ([],[])
			| makelist (tigerframe.PROC {body, frame} :: l) = 
			let 
				val (la,lb) = makelist l 				
			in ((canonizar (body),frame) :: la, lb)
			end
			| makelist (tigerframe.STRING (lab,s) :: l) = 
			let
				val (la,lb) = makelist l
			in (la, (lab,s) :: lb)
			end
			
		val (b,c) = makelist frags
		
		(* opcion de debug -inter / imprime el codigo intermedio del programa *)
		
		val _ = if inter then (tigerinterp.inter true b c) else ()
		
		(***************************************************************************************)
		
		(* Funcion identidad *)
		
		fun id x = x
				
		(*funcion auxiliar para debuguear, imprime los label existentes en el entorno del programa *)
		
		fun printLabels [] = print("\n")
			| printLabels ((lab,s)::xs) = (print("Label: "^lab^" string: "^s^"\n") ; printLabels (xs))
		
		(* Escribe el codigo assembler de los strings para el programa *)
		fun concatInstr [] = "\n"
			| concatInstr (x::xs) = "\t"^x^"\n"^concatInstr(xs)	
		
		fun asmStrings [] = ""
			| asmStrings ((lab,s)::xs) =  let
											val fstLetter = str(hd(String.explode lab))
											val options = if s = "" then (if fstLetter = "L" then 1 else 0) else 1
											val size = Int.toString(String.size s)
										 in
											case options of
												0 => (asmStrings xs)
												| 1 => (".align 16\n.type "^lab^", @object\n.size "^lab^", 16\n"^lab^":\n\t.quad "^size^"\n\t.ascii \""^s^"\"\n\n")^(asmStrings xs)
										end
		(* funcion auxiliar, aplica el generador de codigo assembler (tigermunch)*)
			
		fun apCode (lstm,f) = let 
								val _ = print ("nuevo frame: "^(tigerframe.name f)^"\n")
							  in (f,List.concat(map (fn s => tigermunch.codeGen f s) lstm)) end
		
		(* opcion de debug -precolored / imprime el codigo assembler resultante luego de hacer el munch *)
		
		val _ = if precolored then (let
									val _ = printLabels c
									val l11 = (List.map apCode b) : ((tigerframe.frame * tigerassem.instr list) list)									
									val l12 = List.concat (map (fn (f,il) => il) l11)									
								  in map (fn (i) => print((tigerassem.format id i) ^ "\n")) l12 end) else [()]
		
		
		(* opcion del debug -sregalloc / imprime el codigo assembler resultante aplicando regalloc (por ahora manda todo a memoria) *)
		                          
		val _ = if sregalloc then (let 
								val _ = printLabels c
								val l1 = (List.map apCode b) : ((tigerframe.frame * tigerassem.instr list) list)		
								val l2 = List.concat (map (fn (f,lin) => tigersimpleregalloc.simpleregalloc f lin) l1)
							   in map (fn (i) => print((tigerassem.format id i) ^ "\n")) l2 end) else [()]
		
		(* funcion auxiliar, escribe el codigo COLOREADO como string, usado para escribir el archivo *)
		
		fun asmFunction [] = "\n"
		    | asmFunction ((body, f):: xs) = let
							  val nFrame = tigerframe.name f
							  (*val prol = ".globl "^nFrame^"\n.type "^nFrame^",@function\n"^nFrame^":\n\tpushq %rbp\n\tmovq %rsp, %rbp\n\tsubq $1024, %rsp\n\n"*)
							  val prol = ".globl "^nFrame^"\n.type "^nFrame^",@function\n"^nFrame^":\n"
							  (*val epi = "\n\tmovq %rbp, %rsp\n\tpopq %rbp\n\tret\n"*)
							  val l1 = List.concat(map (fn s => tigermunch.codeGen f s) body)	
							  val l2 = tigermunch.procEntryExit2(f,l1) (* agregar prologo y epilogo *)					  
							  val (pintar, l3) = tigercolor.colorear(l2,f,1)
							  val l4 = map (fn i => tigerassem.format pintar i) l3
								  (*
							  val l1 = (List.map apCode b) : ((tigerframe.frame * tigerassem.instr list) list)									
								 val l2 = List.concat (map (fn (f,il) => il) l1)
								 val _ = tigerbuild.build (l2,1)
								  val pintar = tigercolor.colorear()
								  val l3 = map (fn i => tigerassem.format pintar i) l2
								  *)
							  (*
							  val l1 = List.concat(map (fn s => tigermunch.codeGen f s) body)
							  val l2 = (tigersimpleregalloc.simpleregalloc f l1) : tigerassem.instr list
	   					      val l3 = map (fn i => tigerassem.format id i) l2
							*)
						     in prol^"\n"^concatInstr l4^"\n"^(asmFunction xs) end
								
		(* opcion del debug -asm / escribe un archivo llamado prueba.s con el codigo assembler del programa *)
		val _ = if asm then (let
							val _ = printLabels c
							val outfile = open_out "../tests/TestAssm/prueba.s"
							val _ = output(outfile, ".section\t.rodata\n\n")
							val _ = output(outfile, asmStrings c)
							val _ = output(outfile, ".section\t.text.startup,\"ax\",@progbits\n\n")							
							val _ = output(outfile, asmFunction b)							
							val _ = close_out outfile
						  in () end) else ()
(*
		val _ = if colored then (let
								  val l1 = (List.map apCode b) : ((tigerframe.frame * tigerassem.instr list) list)									
								  val l2 = List.concat (map (fn (f,il) => il) l1)
								  val _ = tigerbuild.build (l2,1)
								  val pintar = tigercolor.colorear()
								  val l3 = map (fn i => tigerassem.format pintar i) l2
								  
								 in () end) else () 
	*)	
		in 
		print "yes!!\n"
	end	handle Fail s => print("Fail: "^s^"\n")

val _ = main(CommandLine.arguments())
