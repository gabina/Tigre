signature tigerflow =
sig


(* tigertab.Tabla que asocia enteros (nodos) con instrucciones *)

val natToInstr : (int, tigerassem.instr) tigertab.Tabla ref	

val longNatToInstr : int

(* tigertab.Tabla que asocia cada nodo con los tigertemp.temporales que se definen en el *)

val defs: (int, tigertemp.temp Splayset.set) tigertab.Tabla ref 

(* tigertab.Tabla que asocia cada nodo con los tigertemp.temporales que se usan en el *)

val uses: (int,tigertemp.temp Splayset.set) tigertab.Tabla ref

(* tigertab.Tabla que asocia nodos con sus sucesores *)

val succs: (int,int Splayset.set) tigertab.Tabla ref

(* tigertab.Tabla que asocia nodos con tigertemp.temporales liveOut *)

val liveOut : (int, tigertemp.temp Splayset.set) tigertab.Tabla ref

val liveOutOld : (int, tigertemp.temp Splayset.set) tigertab.Tabla ref

(* tigertab.Tabla que asocia nodos con tigertemp.temporales liveIn *)

val liveIn : (int, tigertemp.temp Splayset.set) tigertab.Tabla ref

val liveInOld : (int, tigertemp.temp Splayset.set) tigertab.Tabla ref


val fillNatToInstr : tigerassem.instr list * int -> (int, tigerassem.instr) tigertab.Tabla

val fillDefs : tigerassem.instr -> tigertemp.temp Splayset.set

val fillUses : tigerassem.instr -> tigertemp.temp Splayset.set

val findLabel : tigertemp.label -> int list

val preFillSuccs : unit -> tigerassem.instr list

val fillSuccs : tigerassem.instr list * int -> (int, int Splayset.set) tigertab.Tabla



val moveRelated : (tigertemp.temp, bool) tigertab.Tabla ref

val interf : (tigertemp.temp, tigertemp.temp list) tigertab.Tabla ref

val adj : (tigertemp.temp, tigertemp.temp list) tigertab.Tabla ref

val getAdj : tigertemp.temp -> tigertemp.temp list

val areAdj : tigertemp.temp * tigertemp.temp -> bool

val getDegree : tigertemp.temp -> int

val getTemps : tigerassem.instr list * tigertemp.temp Splayset.set -> tigertemp.temp Splayset.set

val fillMoveRelated : tigertemp.temp * tigertemp.temp -> (tigertemp.temp, bool) tigertab.Tabla 

val isMoveRelated : tigertemp.temp -> bool

val fillInterf : int * (tigertemp.temp, tigertemp.temp Splayset.set) tigertab.Tabla -> (tigertemp.temp, tigertemp.temp Splayset.set) tigertab.Tabla

end
	
