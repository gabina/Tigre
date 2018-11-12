open tigerlex
open tigergrm
open tigerescap
open tigerseman
open tigermunch
open tigersimpleregalloc

open BasicIO Nonstdio

fun lexstream(is: instream) =
	Lexing.createLexer(fn b => fn n => buff_input is b 0 n);
fun errParsing(lbuf) = (print("Error en parsing!("
	^(makestring(!num_linea))^
	")["^(Lexing.getLexeme lbuf)^"]\n"); raise Fail "fin!")
fun main(args) =
	let	fun arg(l, s) =
			(List.exists (fn x => x=s) l, List.filter (fn x => x<>s) l)
		val (arbol, l1)		= arg(args, "-arbol")
		val (escapes, l2)	= arg(l1, "-escapes") 
		val (ir, l3)		= arg(l2, "-ir") 
		val (canon, l4)		= arg(l3, "-canon") 
		val (code, l5)		= arg(l4, "-code") 
		val (flow, l6)		= arg(l5, "-flow") 
		val (inter, l7)		= arg(l6, "-inter") 
		val entrada =
			case l7 of
			[n] => ((open_in n)
					handle _ => raise Fail (n^" no existe!"))
			| [] => std_in
			| _ => raise Fail "opcio'n dsconocida!"
		val lexbuf = lexstream entrada
		val expr = prog Tok lexbuf handle _ => errParsing lexbuf
		val _ = findEscape(expr)
		val _ = if arbol then tigerpp.exprAst expr else ()
		
		val _ = transProg(expr)
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
		(* en b tenemos la lista de PROCS*)
		val (b,c) = makelist frags
		
		fun fuAux f = case f of 
					tigerassem.OPER {assem=a,...} => a
					| tigerassem.LABEL {assem=a,...} => a
					| tigerassem.MOVE {assem=a,...} => a
		
		fun id x = x
		
		val _ = print("ANTES DEL COLOREO \n")
		(*val _ = map (fn (i) => print((tigerassem.format id i) ^ "\n")) (List.concat ((map (fn (s,f) => List.concat(map (fn (ss) => tigermunch.codeGen f ss) s))) b)*)
		fun apCode (lstm,f) = (f,List.concat(map (fn s => tigermunch.codeGen f s) lstm))
		val l11 = (List.map apCode b) : ((tigerframe.frame * tigerassem.instr list) list)
		val l12 = List.concat (map (fn (f,il) => il) l11)
		val _ = map (fn (i) => print((tigerassem.format id i) ^ "\n")) l12
		
		
		val _ = print("DESPUES DEL COLOREO \n")
		(*fun apCode (lstm,f) = (f,List.concat(map (fn s => tigermunch.codeGen f s) lstm))*)
		val l1 = (List.map apCode b) : ((tigerframe.frame * tigerassem.instr list) list)
		
		val l2 = List.concat(map (fn (f,lin) => tigersimpleregalloc.simpleregalloc f lin) l1)
		val _ = map (fn (i) => print((tigerassem.format id i) ^ "\n")) l2
		(*codeGen: frame tigertree.stm -> tigerassem.instr list *)
		(* simpleRegAlloc: frame instr list -> instr list *)
		(*
		fun apCode (lstm,f) = (f,List.concat(map (fn s => tigermunch.codeGen f s) lstm))
		val l1 = (List.map apCode b) : ((tigerframe.frame * tigerassem.instr list) list)
		
		val l2 = List.concat(map (fn (f,lin) => tigersimpleregalloc.simpleregalloc f lin) l1)
		val _ = map (fn (i) => print((tigerassem.format id i) ^ "\n")) l2
		*)
		val _ = if inter then (tigerinterp.inter true b c) else ()
		in 
		print "yes!!\n"
	end	handle Fail s => print("Fail: "^s^"\n")

val _ = main(CommandLine.arguments())
