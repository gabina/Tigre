open tigerlex
open tigergrm
open tigerescap
open tigerseman
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
		(*
		fun makelist [] = ([],[])
			| makelist (tigerframe.PROC {body, frame} :: l) = 
			let 
				val (la,lb) = makelist l 
			in (([body],frame) :: la, lb)
			end
			| makelist (tigerframe.STRING (lab,s) :: l) = 
			let
				val (la,lb) = makelist l
			in (la, (lab,s) :: lb)
			end
		*)
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
		(*
		val _ = print ("#[PROC]="^Int.toString (length b))
		*)
		val _ = if inter then (tigerinterp.inter false b c) else ()
		in 
		print "yes!!\n"
	end	handle Fail s => print("Fail: "^s^"\n")

val _ = main(CommandLine.arguments())
