signature tigerframe =
sig

type frame
type register = string
val rv : tigertemp.temp
val fp : tigertemp.temp
val rdi : tigertemp.temp
val rsi : tigertemp.temp
val rdx : tigertemp.temp
val rcx : tigertemp.temp
val r8 : tigertemp.temp
val r9 : tigertemp.temp
val K : int
datatype access = InFrame of int | InReg of tigertemp.label
val MAX_ARGS : int
val MAX_ARGS_REG : int
val MAX_ARGS_STACK : int
val fpPrev : int
val offStaticLink : int
val calleesaves : tigertemp.temp list
val newFrame : {name: tigertemp.label, nameViejo: tigertemp.label,formals: bool list} -> frame
val name : frame -> tigertemp.label
val nameViejo : frame -> tigertemp.label
val getFormals : frame -> bool list
val getLocals : frame -> bool list
val string : tigertemp.label * string -> string
val formals : frame -> access list
val allocArg : frame -> bool -> access
val allocLocal : frame -> bool -> access
val sp : tigertemp.temp
val maxRegFrame : frame -> int
val wSz : int
val log2WSz : int
val calldefs : tigertemp.temp list
val callersaves : tigertemp.temp list
val calleesaves' : tigertemp.temp list
val registers : tigertemp.temp list
val registersSet : tigertemp.temp Splayset.set
(* Cambié el tipo
val exp : access -> tigertree.exp -> tigertree.exp *)
val exp : access -> int -> tigertree.exp
val getFrame : int -> tigertree.exp
val externalCall : string * tigertree.exp list -> tigertree.exp
val procEntryExit1 : frame * tigertree.stm -> tigertree.stm
val procEntryExit2 : frame * tigerassem.instr list -> tigerassem.instr list
val procEntryExit3 : frame * tigerassem.instr list -> tigerassem.instr list
datatype frag = PROC of {body: tigertree.stm, frame: frame}
	| STRING of tigertemp.label * string

end
