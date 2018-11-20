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
		val (precolor, l8)	= arg(l7, "-precolored")
		val (color, l9)		= arg(l8, "-colored")
		val entrada =
			case l9 of
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
		val _ = if inter then (tigerinterp.inter true b c) else ()
		
		(***************************************************************************************)
		fun id x = x
		fun printLabels [] = print("\n")
			| printLabels ((lab,s)::xs) = (print("Label: "^lab^" string: "^s^"\n") ; printLabels (xs))
		fun apCode (lstm,f) = (f,List.concat(map (fn s => tigermunch.codeGen f s) lstm))
		
		val _ = if precolor then (let
									val _ = print("ANTES DEL COLOREO \n")	
									val l11 = (List.map apCode b) : ((tigerframe.frame * tigerassem.instr list) list)
									val l12 = List.concat (map (fn (f,il) => il) l11)									
								  in map (fn (i) => print((tigerassem.format id i) ^ "\n")) l12 end) else [()]
		
		val _ = if color then (let 
								val _ = print("DESPUES DEL COLOREO \n")
								val _ = printLabels c
								val l1 = (List.map apCode b) : ((tigerframe.frame * tigerassem.instr list) list)		
								val l2 = List.concat(map (fn (f,lin) => tigersimpleregalloc.simpleregalloc f lin) l1)
							   in map (fn (i) => print((tigerassem.format id i) ^ "\n")) l2 end) else [()]
		
		
		in 
		print "yes!!\n"
	end	handle Fail s => print("Fail: "^s^"\n")

val _ = main(CommandLine.arguments())
