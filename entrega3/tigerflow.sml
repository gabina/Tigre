structure tigerflow = struct

	open tigerassem
	open tigertab
	
	val natToInstr: (int, tigerassem.instr) Tabla ref = ref (tabNueva())
	
	val succ: (int,int list) Tabla ref = ref (tabNueva())
	
	
	fun fillNatToInstr (([],_) : tigerassem.instr list * int) = !natToInstr : (int, tigerassem.instr) Tabla
		| fillNatToInstr (x::xs,n) = tabInserta (n,x,fillNatToInstr (xs,n+1))
	
	fun instrToSucc x
	
	

end
