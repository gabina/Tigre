structure tigertrans :> tigertrans = struct

open tigerframe
open tigertree
open tigertemp
open tigerabs

exception breakexc
exception divCero

fun generateUniqueLab () = tigertemp.newlabel()
	
type level = {parent:frame option , frame: frame, levelInt: int}
type access = tigerframe.access

type frag = tigerframe.frag
val fraglist = ref ([]: frag list)

val actualLevel = ref ~1 (* _tigermain debe tener level = 0. *)
fun getActualLev() = !actualLevel

fun levInt{parent = _,frame = _,levelInt = l}  = l

val outermost: level = {parent=NONE,
	frame=newFrame{name="_tigermain", formals=[]}, levelInt=getActualLev()}

(* Según página 142 se debe agregar un true correspondiente al static link*)
fun newLevel{parent={parent, frame, levelInt}, name, formals} =
	{
	parent=SOME frame,
	frame=newFrame{name=name, formals=true::formals},
	levelInt=levelInt+1}

fun allocArg{parent, frame, levelInt} b = tigerframe.allocArg frame b

fun allocLocal{parent, frame, levelInt} b = tigerframe.allocLocal frame b

fun formals{parent, frame, levelInt} = tigerframe.formals frame

datatype exp =
	Ex of tigertree.exp
	| Nx of tigertree.stm
	| Cx of label * label -> tigertree.stm

fun seq [] = EXP (CONST 0)
	| seq [s] = s
	| seq (x::xs) = SEQ (x, seq xs)

fun unEx (Ex e) = e
	| unEx (Nx s) = ESEQ(s, CONST 0)
	| unEx (Cx cf) =
	let
		val r = newtemp()
		val t = newlabel()
		val f = newlabel()
	in
		ESEQ(seq [MOVE(TEMP r, CONST 1),
			cf (t, f),
			LABEL f,
			MOVE(TEMP r, CONST 0),
			LABEL t],
			TEMP r)
	end

fun unNx (Ex e) = EXP e
	| unNx (Nx s) = s
	| unNx (Cx cf) =
	let
		val t = newlabel()
		val f = newlabel()
	in
		seq [cf(t,f),
			LABEL t,
			LABEL f]
	end

fun unCx (Nx s) = raise Fail ("Error (UnCx(Nx..))")
	| unCx (Cx cf) = cf
	| unCx (Ex (CONST 0)) =
	(fn (t,f) => JUMP(NAME f, [f]))
	| unCx (Ex (CONST _)) =
	(fn (t,f) => JUMP(NAME t, [t]))
	| unCx (Ex e) =
	(fn (t,f) => CJUMP(NE, e, CONST 0, t, f))

fun Ir(e) =
	let	fun aux(Ex e) = tigerit.tree(EXP e)
		| aux(Nx s) = tigerit.tree(s)
		| aux _ = raise Fail "bueno, a completar!"
		fun aux2(PROC{body, frame}) = aux(Nx body)
		| aux2(STRING(l, "")) = l^":\n"
		| aux2(STRING("", s)) = "\t"^s^"\n"
		| aux2(STRING(l, s)) = l^":\t"^s^"\n"
		fun aux3 [] = ""
		| aux3(h::t) = (aux2 h)^(aux3 t)
	in	aux3 e end
	
fun nombreFrame frame = print(".globl " ^ tigerframe.name frame ^ "\n")

local
	val salidas: label option tigerpila.Pila = tigerpila.nuevaPila1 NONE
in
	val pushSalida = tigerpila.pushPila salidas
	fun popSalida() = tigerpila.popPila salidas
	fun topSalida() =
		case tigerpila.topPila salidas of
		SOME l => l
		| NONE => raise Fail "break incorrecto!"			
end

val datosGlobs = ref ([]: frag list)

fun procEntryExit{level: level, body} =
	let	val label = STRING(name(#frame level), "")
		val body' = PROC{frame= #frame level, body=unNx body}
		val final = STRING(";;-------", "")
	in	datosGlobs:=(!datosGlobs@[label, body', final]) end
fun getResult() = !datosGlobs

fun stringLen s =
	let	fun aux[] = 0
		| aux(#"\\":: #"x"::_::_::t) = 1+aux(t)
		| aux(_::t) = 1+aux(t)
	in	aux(explode s) end

fun stringExp(s: string) =
	let	val l = newlabel()
		val len = ".long "^makestring(stringLen s) : string (* .long 3*)
		val str = (*".string \""^*)s(*^"\"" : string (* .string "dia" *)*)
		val _ = datosGlobs:=(!datosGlobs @ [STRING(l, (*len), STRING("",*) str)])
	in	Ex(NAME l) end
	
fun preFunctionDec() =
	(pushSalida(NONE);
	actualLevel := !actualLevel+1)

fun functionDec(e, l, proc) =
	let	val body =
				if proc then unNx e
				else MOVE(TEMP rv, unEx e)
		val body' = procEntryExit1(#frame l, body)
		val () = procEntryExit{body=Nx body', level=l}
	in	Ex(CONST 0) end
	
fun postFunctionDec() =
	(popSalida(); actualLevel := !actualLevel-1)

fun unitExp() = Ex (CONST 0)

fun nilExp() = Ex (CONST 0)

fun intExp i = Ex (CONST i)

(* A la función tigergrame.exp le paso la cantidad de niveles que debe saltar para llegar al frame donde la variable está definida*)
(* Habría que verificar que esto ande correctamente *)	
(* nivel representa el número de nivel en el cual la variable fue definida*)
fun simpleVar ((acc, nivel) : (access * int)) : exp = ((*print("Cantidad de niveles a saltar "^ Int.toString(getActualLev() - nivel) ^"\n");*)Ex (tigerframe.exp acc (getActualLev() - nivel)))

fun varDec(acc) = simpleVar(acc, getActualLev())

fun fieldVar(var, field) = 
let
	val a = unEx var
	val i = CONST field
	val ra = newtemp()
	val ri = newtemp()
in
	Ex( ESEQ(seq[MOVE(TEMP ra, a),
		MOVE(TEMP ri, i),
		EXP(externalCall("_checkNil", [TEMP ra]))],
		MEM(BINOP(PLUS, TEMP ra,
			BINOP(MUL, TEMP ri, CONST tigerframe.wSz)))))
end

fun subscriptVar(arr, ind) =
let
	val a = unEx arr
	val i = unEx ind
	val ra = newtemp()
	val ri = newtemp()
in
	Ex( ESEQ(seq[MOVE(TEMP ra, a),
		MOVE(TEMP ri, i),
		EXP(externalCall("_checkIndexArray", [TEMP ra, TEMP ri]))],
		MEM(BINOP(PLUS, TEMP ra,
			BINOP(MUL, TEMP ri, CONST tigerframe.wSz)))))
end

fun recordExp l =
let
	val s = CONST (length l)
	val is = map (fn (e,n) => unEx e) l
in
	Ex (externalCall("_allocRecord", s :: is))
end

fun arrayExp{size, init} =
let
	val s = unEx size
	val i = unEx init
in
	Ex (externalCall("_initArray", [s, i]))
end

(* lev : tigertrans.level es el nivel en donde la función fue definida*)
fun callExp(name,ext,isproc,lev : level, ls : exp list) = 
let	
	val dif = getActualLev() - levInt (lev)	
	(* val _ = print ("LA DIFERENCIA DEL CALL A "^name^" ES "^Int.toString(dif)^"\n") *)
	
	fun calcSL 0 = MEM (BINOP (PLUS, TEMP fp, CONST (tigerframe.fpPrev)))
		| calcSL n = MEM (BINOP (PLUS, calcSL (n-1), CONST (tigerframe.fpPrev)))

	val sl = if (dif = (~1)) then (TEMP fp) else (calcSL dif)	

	val ls = map unEx ls
in
	case isproc of
		true => if (ext) then Nx (EXP (CALL (NAME name,ls))) else Nx (EXP (CALL (NAME name, sl :: ls)))
		| false => if (ext) then Ex (CALL (NAME name,ls)) else Ex (CALL (NAME name, sl :: ls))
end

fun letExp ([], body) = Ex (unEx body)
 |  letExp (inits, body) = Ex (ESEQ(seq inits,unEx body))

fun breakExp() = 
let
	val s = topSalida()
in
	Nx (JUMP (NAME s, [s]))
end 

fun seqExp ([]:exp list) = Nx (EXP(CONST 0))
	| seqExp (exps:exp list) =
		let
			fun unx [e] = []
				| unx (s::ss) = (unNx s)::(unx ss)
				| unx[] = []
		in
			case List.last exps of
				Nx s =>
					let val unexps = map unNx exps
					in Nx (seq unexps) end
				| Ex e => Ex (ESEQ(seq(unx exps), e))
				| cond => Ex (ESEQ(seq(unx exps), unEx cond))
		end

fun preWhileForExp() = pushSalida(SOME(newlabel()))

fun postWhileForExp() = (popSalida(); ())

fun whileExp {test: exp, body: exp, lev:level} =
let
	val cf = unCx test
	val expb = unNx body
	val (l1, l2, l3) = (newlabel(), newlabel(), topSalida())
in
	Nx (seq[LABEL l1,
		cf(l2,l3),
		LABEL l2,
		expb,
		JUMP(NAME l1, [l1]),
		LABEL l3])
end

fun forExp {lo, hi, var, body} =
let
	val var = unEx var
	val hi = unEx hi 
	val lo = unEx lo
	val body = unNx body
	val tmp = newtemp()
	val (sigue, sigue1, salida) = (newlabel(), newlabel(), topSalida())
in	 
	Nx (seq [MOVE (var,lo), 
		MOVE (TEMP tmp, hi),
		CJUMP (LE, var, TEMP tmp, sigue, salida),
		LABEL sigue, 
		body, 
		CJUMP (EQ, var, TEMP tmp, salida, sigue1),
		LABEL sigue1, 
		MOVE (var, BINOP (PLUS, var, CONST 1)),
		JUMP (NAME sigue, [sigue]),
		LABEL salida])
end

fun ifThenExp{test, then'} =
let
	val cf = unCx test
	val expthen = unNx then'
	val (t,f) = (newlabel(), newlabel())
in
	Nx (seq[cf(t,f),
		LABEL t,
		expthen,
		LABEL f])		
end

fun ifThenElseExp {test,then',else'} =
let
	val cf = unCx test
	val expthen = unEx then'
	val expelse = unEx else'
	val (t,f,fin,r) = (newlabel(), newlabel(), newlabel(), newtemp())
in
	Ex (ESEQ(seq[cf(t,f),
			LABEL t,
			MOVE(TEMP r, expthen),
			JUMP (NAME fin, [fin]),
		    LABEL f,
		    MOVE(TEMP r, expelse),
		    LABEL fin],
		    TEMP r))
end
(*COMPLETADO - DISTINTO A LA CARPETA*)

fun ifThenElseExpUnit {test,then',else'} =
let
	val cf = unCx test
	val expthen = unNx then'
	val expelse = unNx else'
	val (t,f,fin) = (newlabel(),newlabel(),newlabel())
in
	Nx (seq[cf(t,f),
			LABEL t,
			expthen,
			JUMP (NAME fin, [fin]),
			LABEL f,
			expelse,
			LABEL fin])		
end

fun assignExp{var, exp} =
let
	val v = unEx var
	val vl = unEx exp
in
	Nx (MOVE(v,vl))
end

fun binOpIntExp {left, oper, right} = 
let 
	val l = unEx left
	val r = unEx right
in
	case oper of
		PlusOp	  	=> Ex (BINOP(PLUS,l,r))
		| MinusOp	=> Ex (BINOP(MINUS,l,r))
		| TimesOp 	=> Ex (BINOP(MUL,l,r))
		| DivideOp 	=> if (r = CONST 0) then raise Fail "División por cero" else Ex (BINOP(DIV,l,r))
		| _ 		=> raise Fail "Error en binOpIntExp" 
end

fun fromOperToRelOp EqOp = EQ
	|  fromOperToRelOp NeqOp = NE
	|  fromOperToRelOp LtOp = LT 
	|  fromOperToRelOp LeOp = LE
	|  fromOperToRelOp GtOp = GT
	|  fromOperToRelOp GeOp = GE
	|  fromOperToRelOp _ = raise Fail "Operacion no permitida" 

fun binOpIntRelExp {left,oper,right} =
let
	val etiq = fromOperToRelOp oper
	val l = unEx left
	val r = unEx right
	val (t,f,tmp) = (newlabel(), newlabel(), newtemp())
in
	Ex (ESEQ(seq[MOVE(TEMP tmp, CONST 1),
			CJUMP(etiq,l,r,t,f),
		    LABEL f,
		    MOVE(TEMP tmp, CONST 0),
		    LABEL t],
		    TEMP tmp))
end	

fun binOpStrExp {left, oper, right} =
	let 
		val etiq = fromOperToRelOp oper
		val l = unEx left
		val r = unEx right
		val (t,f,tmp) = (newlabel(),newlabel(),newtemp())
	in
		case oper of
			PlusOp 		=> raise Fail "no deberia llegar"
			| MinusOp 	=> raise Fail "no deberia llegar"
			| TimesOp 	=> raise Fail "no deberia llegar"
			| DivideOp 	=> raise Fail "no deberia llegar"				
			| _		=> Ex (ESEQ(seq[MOVE(TEMP tmp, CONST 1),
								CJUMP(etiq,externalCall("_stringcmp", [l , r]),CONST 0,t,f),
								LABEL f,
								MOVE(TEMP tmp, CONST 0),
								LABEL t],
								TEMP tmp))	
			
			(*| _ => raise Fail "No existe caso binOpStrExp"*)
			
	end
end
