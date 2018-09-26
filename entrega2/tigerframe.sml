(*
	Frames para el 80386 (sin displays ni registers).

		|    argn    |	fp+4*(n+1)
		|    ...     |
		|    arg2    |	fp+16
		|    arg1    |	fp+12
		|	fp level |  fp+8
		|  retorno   |	fp+4
		|   fp ant   |	fp
		--------------	fp
		|   local1   |	fp-4
		|   local2   |	fp-8
		|    ...     |
		|   localn   |	fp-4*n
*)

structure tigerframe :> tigerframe = struct

open tigertree

(*type level = int*)

val fp = "FP"				(* frame pointer *)
val sp = "SP"				(* stack pointer *)
val rv = "RV"				(* return value  *)
val ov = "OV"				(* overflow value (edx en el 386) *)
val wSz = 4					(* word size in bytes *)
val log2WSz = 2				(* base two logarithm of word size in bytes *)
val fpPrev = 0				(* offset (bytes) *)
val fpPrevLev = 8			(* offset (bytes) *)
val argsInicial = 0			(* words *)
val argsOffInicial = 0		(* words *)
val argsGap = wSz			(* bytes *)
val regInicial = 1			(* reg *)
val localsInicial = 0		(* words *)
val localsGap = ~4 			(* bytes *)
val calldefs = [rv]
val specialregs = [rv, fp, sp]
val argregs = []
val callersaves = []
val calleesaves = []

datatype access = InFrame of int | InReg of tigertemp.label

type frame = {
	name: string,
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
fun newFrame{name, formals} = {
	name=name,
	formals=formals,
	arguments=ref [],
	locals=[],
	actualArg=ref argsInicial, (*Cantidad de veces que se llama a allocArg*)
	actualLocal=ref localsInicial,
	actualReg=ref regInicial
}
fun name(f: frame) = #name f
(* Representación de Tiger de un string
   "3dia\n"*)
fun string(l, s) = l^tigertemp.makeString(s)^"\n"

fun getFormals(f: frame) = #formals f
fun getLocals(f: frame) = #locals f

(* Función original*)
(*fun formals({formals=f, ...}: frame) = 
	let	fun aux(n, []) = []
		| aux(n, h::t) = InFrame(n)::aux(n+argsGap, t)
		(*| aux(n, false::t) = InReg(tigertemp.newtemp())::aux(n, t)*)
	in aux(argsInicial, f) end
*)

(* El InFrame que se agrega al inicio corresponde al static link*)
fun formals({arguments=ar, ...}: frame) = [InFrame (argsOffInicial)] @ !ar 

fun maxRegFrame(f: frame) = !(#actualReg f)

fun allocArg (f: frame) b = 
	let val acc = 
		(case b of
		true =>
			let	val ret = (!(#actualArg f)+argsOffInicial+1)*wSz
				val _ = #actualArg f := !(#actualArg f)+1
			in	InFrame ret end
		| false => InReg(tigertemp.newtemp()))
	in (#arguments f := !(#arguments f) @ [acc];acc) end
	(* malloc *)

fun allocLocal (f: frame) b = 
	case b of
	true =>
		let	val ret = InFrame(!(#actualLocal f)+localsGap)
		in	#actualLocal f:=(!(#actualLocal f)-1); ret end
	| false => InReg(tigertemp.newtemp())

(* Habría que verificar que esto ande correctamente *)
(* Para acceder a variables. ¿Siempre que accedo a variable serán hijas? *)	
fun getFrame 0 = TEMP(fp)
	| getFrame n = MEM(BINOP(PLUS, (getFrame (n-1)), CONST fpPrev))

fun exp (InFrame k) e = MEM(BINOP(PLUS, getFrame e, CONST k))
(*  | exp (InReg l) e = (print("Entro en temp "^l^"\n\n");TEMP l) *)
	| exp (InReg l) e = (TEMP l)	

fun externalCall(s, l) = CALL(NAME s, l)

fun procEntryExit1 (frame,body) = body
end
