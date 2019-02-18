(*
	Layout del frame real. Los primeros 6 argumentos son pasados por registros

		|    argn    |	
		|    ...     |
		|    arg8    |	fp+24
		|    arg7    |	fp+16
		|  retorno   |	fp+8
		|   rbp ant  |	fp
		--------------	fp
		| static link|	fp-8
		|    arg7    |	fp-16
		|    arg8    |  fp-24
		|    ...     |	
		|   local1   |
*)

structure tigerframe :> tigerframe = struct

open tigertree

(*type level = int*)

val fp = "rbp"				(* frame pointer *)
val sp = "rsp"				(* stack pointer *)
val rv = "rax"				(* return value  *)
val rdi ="rdi"
val rsi = "rsi"
val rdx = "rdx"
val rcx = "rcx"
val r8 = "r8"
val r9 = "r9"
val wSz = 8				(* word size in bytes *)
val log2WSz = 3				(* base two logarithm of word size in bytes *)
val fpPrev = 0				(* offset (bytes) *)
val offStaticLink = ~8			(* offset (bytes) *)
val offArgs = 16 (* cuanto arriba del fp empiezan a estar los argumentos pasados por pila*)

val argsInicial = 0			(* el primer argumento *)
val argsOffInicial = ~16		(* words *)
val argsGap = wSz			(* bytes *)

val regInicial = 1			(* reg *)
val localsInicial = 0		(* la primera variable local *)
val localsGap = 8 			(* bytes *)

val calldefs = [rv]
val specialregs = [rv, fp, sp]
val argregs = []
val callersaves = [rv,rcx,rdx,rsi,rdi,r8,r9,"r10", "r11"]	
val calleesaves = ["rbx", fp, sp, "r12", "r13", "r14", "r15"]
val calleesaves' = ["rbx", "r12", "r13", "r14", "r15"]
val registers = [rv,"rbx",rcx,rdx,rsi,rdi,fp,sp,r8,r9,"r10","r11","r12","r13","r14","r15"]
val K = length registers

fun its n =  if n<0 then "-" ^ Int.toString(~n) else Int.toString(n) 

datatype access = InFrame of int | InReg of tigertemp.label

type frame = {
	name: string,
	nameViejo: string,
	formals: bool list,
	arguments: access list ref, (*Esto es una bolasa nuestra*)
	locals: bool list,
	actualArg: int ref,
	actualLocal: int ref,
	actualReg: int ref
}
type register = string

datatype frag = PROC of {body: tigertree.stm, frame: frame}
	| STRING of tigertemp.label * string

fun newFrame{name, nameViejo,formals} = {
	name=name,
	nameViejo=nameViejo,
	formals=formals,
	arguments=ref [],
	locals=[],
	actualArg=ref argsInicial, (*Cantidad de argumentos guardados en la pila*)
	actualLocal=ref localsInicial, (*Cantidad de variables locales guardadas en la pila*)
	actualReg=ref regInicial
}
fun name (f: frame) = #name f
fun nameViejo (f: frame) = #nameViejo f
(* Representación de Tiger de un string
   "3dia\n"*)
fun string(l, s) = l^tigertemp.makeString(s)^"\n"

fun getFormals(f: frame) = #formals f
fun getLocals(f: frame) = #locals f

(* El InFrame que se agrega al inicio corresponde al static link*)
fun formals({arguments=ar, ...}: frame) = [InFrame (offStaticLink)] @ !ar 

fun maxRegFrame(f: frame) = !(#actualReg f)

fun allocArg (f: frame) b = 
	let val acc = 
		(case b of
		true =>
			let	val _ = print("allocARg InFrame \n")
				val ret = (argsOffInicial-(!(#actualArg f)*wSz))
				val _ = #actualArg f := !(#actualArg f)+1
			in	InFrame ret end
		| false => (print("allorArg InReg \n");InReg(tigertemp.newtemp())))
	in (#arguments f := !(#arguments f) @ [acc];acc) end
	(* malloc *)

fun allocLocal (f: frame) b = 
	case b of
	true =>
		let	val ret = InFrame ((~(!(#actualLocal f))-(!(#actualArg f)))*localsGap+argsOffInicial) (* REVISAR MULTIPLICAR *)
			val _ = print "allocLocal true"
		in	#actualLocal f:=(!(#actualLocal f)+1); ret end
	| false => InReg(tigertemp.newtemp())

(* Habría que verificar que esto ande correctamente *)
(* Para acceder a variables. ¿Siempre que accedo a variable serán hijas? *)	
fun getFrame 0 = TEMP(fp)
	| getFrame n = MEM(BINOP(PLUS, (getFrame (n-1)), CONST offStaticLink))

fun exp (InFrame k) e = MEM(BINOP(PLUS, getFrame e, CONST k))
(*  | exp (InReg l) e = (print("Entro en temp "^l^"\n\n");TEMP l) *)
	| exp (InReg l) e = (TEMP l)	


fun externalCall(s, l) = CALL(NAME s, l)

fun seq [] = EXP (CONST 0)
	| seq [s] = s
	| seq (x::xs) = SEQ (x, seq xs)

fun procEntryExit1 (f : frame,body) =  
					let
					    val isMain = (#name f) = "_tigermain"
					    fun zipear [] _ = []
					    | zipear (x::xs) n = [(x,n)] @ zipear xs (n+1)
						
						val lacc : (access * int) list = zipear (formals f) 0	
						
						fun natToReg 0 = rdi
						| natToReg 1 = rsi
						| natToReg 2 = rdx
						| natToReg 3 = rcx
						| natToReg 4 = r8
						| natToReg 5 = r9
						| natToReg _ = raise Fail "No deberia pasar (natToReg)"				
						
						fun accToMove ((InReg t),n) = if n<6 then (print("inreg <6\n");MOVE (TEMP t,TEMP (natToReg n))) else MOVE(TEMP t,MEM(BINOP(PLUS, TEMP(fp), CONST (offArgs + (n-6)*localsGap)))) (*A partir del fp hay que sumar porque estamos queriendo acceder a la pila del llamante*)
						  | accToMove ((InFrame k),n) = if n<6 then (print("inframe <6  "^its(k)^"\n");MOVE (MEM(BINOP(PLUS, TEMP(fp), CONST k)) ,TEMP (natToReg n))) else MOVE (MEM(BINOP(PLUS, TEMP(fp), CONST k)) ,MEM(BINOP(PLUS, TEMP(fp), CONST (offArgs + (n-6)*localsGap))))                                         						
				   in  if isMain then body else SEQ (seq (map accToMove lacc),body) end
				   
			   
end

