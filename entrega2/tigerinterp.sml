(*
	Intérprete de código intermedio canonizado
	inter a b c recibe:
	a: bool - false sólo ejecuta el código, true muestra en cada paso la instrucción a ejecutar y el estado de la memoria y temporarios
	b: (tigertree.stm list*tigerframe.frame) list - cada elemento de la lista es un par con la lista de tigertree.stm devuelta por el canonizador y el frame de cada función
	c: (tigertemp.label*string) list - Una lista con un elemento por cada string definido en el código. Cada elemento es un par formado por el label y el string.
	inter usa: 
		Constantes de tigerframe: wSz, rv, fp
		Funciones de tigerframe: formals, exp. formals (Appel, pág 135) debe devolver una lista con los tigerframe.access de cada argumento pasado a la función, esto es el tigerframe.access que se usa en el body de la función para referirse a cada argumento. También debe devolver un tigerframe.access para el static link, como primer elemento de la lista.
	Nota: en una máquina de N bits los enteros de ML tienen N-1 bits. El intérprete fallará si se usan números muy grandes.
*)
structure tigerinterp =
struct
	open tigertab
	open Dynarray
	open tigertree

	fun inter showdebug (funfracs: (stm list*tigerframe.frame) list) (stringfracs: (tigertemp.label*string) list) =
	let
		(* Memoria y registros *)
		local
			val tabTemps: (tigertemp.temp, int ref) Tabla ref = ref (tabNueva())
			val tabMem: (int, int ref) Tabla ref = ref (tabNueva())

			fun load tab a =
				case tabBusca(a, !tab) of
					SOME v => !v
					| NONE => (tab := tabInserta(a, ref 0, !tab); 0)
			fun store tab a x = (* almacenar *)
				case tabBusca(a, !tab) of
					SOME v => v := x
					| NONE => tab := tabInserta(a, ref x, !tab)
		in
			val loadMem = load tabMem
			val storeMem = store tabMem
			fun printMem () =
			let
				val ls = tabAList(!tabMem)
				fun p (a,b) = (print(Int.toString(a)); print(" -> "); print(Int.toString(!b)); print("\n"))
			in
				(print("MEM:\n"); List.app p ls)
			end
			val loadTemp = load tabTemps
			val storeTemp = store tabTemps
			fun getTemps () = 
			let
				val tabL = tabAList(!tabTemps)
			in
				map (fn (x,y) => (x, !y)) tabL
			end
			fun restoreTemps temps = map (fn (x,y) => storeTemp x y) temps
			fun printTemps () =
			let
				val ls = tabAList(!tabTemps)
				fun p (a,b) = (print(a); print(" -> "); print(Int.toString(!b)); print("\n"))
			in				
				(print("TEMPS:\n"); List.app p ls)	
			end
		end

		(* alocación de memoria *)
		local
			val nextfree = ref 0
		in
			fun getNewMem(n) =
			let
				val r = !nextfree
			in
				(nextfree := !nextfree + (n*tigerframe.wSz); r)
			end
		end

		(* tabla de labels -> direcciones *)
		local
			val tabLabels: (tigertemp.label, int) Tabla ref = ref (tabNueva())
		in
			fun loadLabel lab = case tabBusca(lab, !tabLabels) of
				SOME a => a
				| NONE => raise Fail("Label no encontrado: "^lab^"\n")
			fun storeLabel lab addr = tabLabels := tabRInserta(lab, addr, !tabLabels)
			fun printLabel() = List.app (fn (s,_) => print (s^"\n")) (tabAList (!tabLabels))			
		end

		(* Guardado de strings *)
		local
			val stringArray = array(10, "") 
			val next = ref 0;
		in
			fun loadString addr = sub(stringArray, loadMem addr)
			fun storeString str =
				let
					val addr = getNewMem(1)
					val idx = !next;
					val _ = next := !next + 1;
				in					
					(update(stringArray, idx, str) (*;print("EL STRING AGREGADO "^str^"\n")*); storeMem addr idx; addr)
				end
		end
		val listLab = List.map (fn (lab, str) => ((* print("EL STRING AGREGADO A TABLABEL COMO "^lab^" ES "^str^"\n"); *)storeLabel lab (storeString str))) (stringfracs : (string * string) list)
		(*
		val _ = print("IMPRIMIENDO FUNFRACS \n\n")				
		val _ = printLabel()		
		*)
		(* Funciones de biblioteca *)
		fun arregloBarraN [] = []
			| arregloBarraN (#"\\"::(#"x"::(#"0"::(#"a"::xs)))) = #"\n"::arregloBarraN xs
			| arregloBarraN (x::xs) = x::arregloBarraN xs

		fun initArray(siz::init::rest) =
		let
			val mem = getNewMem(siz+1)
			val l = (mem, siz)::(List.tabulate(siz, (fn x => (mem+tigerframe.wSz*(x+1), init))))
			val _ = List.map (fn (a,v) => storeMem a v) l
		in
			mem+tigerframe.wSz
		end
		| initArray _ = raise Fail("No debería pasar (initArray)")

		fun checkIndexArray(arr::idx::rest) =
		let
			val siz = loadMem (arr-tigerframe.wSz)			
			(*
			val _ = print ("\nSIZE"^Int.toString(siz)^"\n") 
			val _ = print("arr "^Int.toString(arr)^"\n")
			val _ = print("idx "^Int.toString(idx)^"\n")
			*)
			val _ = if (idx>=siz orelse idx<0) then raise Fail("Índice fuera de rango\n") else ()
		in
			0
		end
		| checkIndexArray _ = raise Fail("No debería pasar (checkIndexArray)")
		
		fun allocRecord(ctos::vals) =
		let
			val mem = getNewMem(ctos+1)
			val addrs = List.tabulate(ctos, (fn x => mem + (x+1)*tigerframe.wSz))
			val l = (mem,ctos)::ListPair.zip(addrs, vals)
			val _ = List.map (fn (a,v) => storeMem a v) l
		in
			mem+tigerframe.wSz
		end
		| allocRecord _ = raise Fail("No debería pasar (allocRecord)")
		
		fun checkNil(r::rest) =
		let
			val _ = if (r=0) then raise Fail("Nil\n") else ()
		in
			0
		end
		| checkNil _ = raise Fail("No debería pasar (checkNil)")

		fun stringCompare(strPtr1::strPtr2::rest) =
		let
			val str1 = implode(arregloBarraN(explode(loadString strPtr1)))
			val str2 = implode(arregloBarraN(explode(loadString strPtr2)))
			val res = String.compare(str1, str2)
		in
			case res of
				LESS => ~1
				| EQUAL => 0
				| GREATER => 1
		end
		| stringCompare _ = raise Fail("No debería pasar (stringCompare)")
			
		fun printFun(strPtr::rest) =
		let
			val str1 = loadString strPtr	
			val str = arregloBarraN (explode(str1))
			val _ = print(implode(str))
		in
			0
		end
		| printFun _ = raise Fail("No debería pasar (printFun)")

		fun flushFun(args) = 0

		fun ordFun(strPtr::rest) =
		let
			val str = loadString strPtr
			val ch = hd(explode(str))
			(* val _ = print("ord") *)
		in
			ord ch
		end
		| ordFun _ = raise Fail("No debería pasar (ordFun)")

		fun chrFun(i::rest) =
		let
			val ch = chr(i) (* chr toma un entero y lo pasa a char *)
			val str = implode([ch]) (* implode convierte lista de chars a un string *)
			(* val _ = print("chr") *)
		in
			storeString str
		end
		| chrFun _ = raise Fail("No debería pasar (chrFun)")

		fun sizeFun(strPtr::rest) =
		let
			val str = loadString strPtr
		in
			String.size(str)
		end
		| sizeFun _ = raise Fail("No debería pasar (sizeFun)")

		fun substringFun(strPtr::first::n::rest) =
		let
			val str = loadString strPtr
			val substr = String.substring(str, first, n)
		in
			storeString substr
		end
		| substringFun _ = raise Fail("No debería pasar (substringFun)")

		fun concatFun(strPtr1::strPtr2::rest) =
		let
			val str1 = loadString strPtr1
			val str2 = loadString strPtr2
			val res = str1^str2
		in
			storeString res
		end
		| concatFun _ = raise Fail("No debería pasar (concatFun)")

		fun notFun(v::rest) =
			if (v=0) then 1 else 0
		| notFun _ = raise Fail("No debería pasar (notFun)")

		fun getstrFun(args) = 
			let val c = TextIO.input1 TextIO.stdIn
			in
				storeString(case c of
				SOME e => str e
				| _ => "")
			end
	(*
		let
			val str = ((TextIO.inputLine : TextIO.instream -> string option) (TextIO.stdIn : TextIO.instream)) : string option
		in
			case str of 
			  NONE => raise Fail("El string fue nulo")
			| SOME s => storeString (s : string)
		end
*)
		val tabLib: (tigertemp.label, int list -> int) Tabla =
			tabInserList(tabNueva(),
				[("_initArray", initArray),
				("_checkIndexArray", checkIndexArray),
				("_allocRecord", allocRecord),
				("_checkNil", checkNil),
				("_stringcmp", stringCompare),
				("print", printFun),
				("flush", flushFun),
				("ord", ordFun),
				("chr", chrFun),
				("size", sizeFun),
				("substring", substringFun),
				("concat", concatFun),
				("not", notFun),
				("getchar", getstrFun)])

		(* Evalúa una expresión, devuelve el valor (entero) *)
		fun evalExp(CONST t) = t
		| evalExp(NAME n) = loadLabel n
		| evalExp(TEMP t) = loadTemp t
		| evalExp(BINOP(b, e1, e2)) =
			let
				val ee1 = evalExp(e1)
				val ee2 = evalExp(e2)
			in
				case b of
					PLUS => ee1+ee2
					| MINUS => ee1-ee2
					| MUL => ee1*ee2
					| DIV => ee1 div ee2
					| AND => Word.toInt(Word.andb(Word.fromInt(ee1), Word.fromInt(ee2)))
					| OR => Word.toInt(Word.orb(Word.fromInt(ee1), Word.fromInt(ee2)))
					| LSHIFT => Word.toInt(Word.<<(Word.fromInt(ee1), Word.fromInt(ee2)))
					| RSHIFT => Word.toInt(Word.>>(Word.fromInt(ee1), Word.fromInt(ee2)))
					| ARSHIFT => Word.toInt(Word.~>>(Word.fromInt(ee1), Word.fromInt(ee2)))
					| XOR => Word.toInt(Word.xorb(Word.fromInt(ee1), Word.fromInt(ee2)))
			end
		| evalExp(MEM(e)) =
			let
				val ee = evalExp(e)
			in
				loadMem ee
			end
		| evalExp(CALL(f, args)) =
			let
				val lab = case f of
					NAME l => l
					| _ => raise Fail("CALL a otra cosa (no implemetado)\n")
				val eargs = List.map evalExp args
				(* val _ = print ("Primer elemento: "^Int.toString(hd(eargs))) *)
				(*Si lab es de biblioteca, usar la función de la tabla*)
				val rv = case tabBusca(lab, tabLib) of
					SOME f => f(eargs)
					| NONE => evalFun(lab, eargs)
			in
				(storeTemp tigerframe.rv rv; rv)
			end
		| evalExp(ESEQ(s, e)) = raise Fail("No canonizado\n")
		(* ejecuta un comando, devuelve NONE si no salta, SOME l si salta al label l *)
		and evalStm(MOVE(TEMP t, e)) = (storeTemp t (evalExp(e)); NONE)
		| evalStm(MOVE(MEM(e1), e2)) = (storeMem (evalExp(e1)) (evalExp(e2)); NONE)
		| evalStm(MOVE(_, _)) = raise Fail("MOVE a otra cosa\n")
		| evalStm(EXP e) = (evalExp(e); NONE)
		| evalStm(JUMP(e, ls)) =
			let
				val lab = case e of
					NAME l => l
					| _ => raise Fail("JUMP a otra cosa\n")
			in
				SOME lab
			end
		| evalStm(CJUMP(rop, e1, e2, lt, lf)) =
			let
				val ee1 = evalExp(e1)
				val ee2 = evalExp(e2)
				val b = case rop of
					EQ => ee1=ee2 
					| NE => ee1<>ee2
					| LT => ee1<ee2
					| GT => ee1>ee2
					| LE => ee1<=ee2
					| GE => ee1>=ee2
					| ULT => Word.fromInt(ee1)<Word.fromInt(ee2)
					| UGT => Word.fromInt(ee1)>Word.fromInt(ee2)
					| ULE => Word.fromInt(ee1)<=Word.fromInt(ee2)
					| UGE => Word.fromInt(ee1)>=Word.fromInt(ee2)
			in
				if b then SOME lt else SOME lf
		end
		| evalStm(SEQ(_,_)) = raise Fail("No canonizado\n")
		| evalStm(LABEL _) = NONE
		(* Ejecuta una llamada a función *)
		and evalFun(f, args) =
			let
				(* Encontrar la función*)
				val ffrac = List.filter (fn (body, frame) => (tigerframe.name(frame)=f)) funfracs
				val _ = if (List.length(ffrac)<>1) then raise Fail ("No se encuentra la función, o repetida: "^f^"\n") else ()
				val [(body, frame)] = ffrac
				(* Mostrar qué se está haciendo, si showdebug *)	
				
				val _ = if showdebug then (print((tigerframe.name frame)^":\n");List.app (print o tigerit.tree) body; print("Argumentoss: "); List.app (fn n => (print(Int.toString(n)); print("  "))) args; print("\n")) else ()

				fun execute l =
				let
					fun exe [] = ()
					| exe (x::xs) =
						let
						(* (printTemps(); printMem(); print("****************\n"); print(tigerit.tree(x)); print("****************\n"))*)
							val _ = if showdebug then (printTemps(); printMem(); print("****************\n"); print(tigerit.tree(x)); print("****************\n")) else ()
						in
							case evalStm x of
								SOME lab =>
									let
										fun f [] = raise Fail("No está el label en la función\n")
										| f (x::xs) =
											(case x of
												LABEL y => if (y=lab) then (x::xs) else f xs
												| _ => f xs)
									in
										exe (f l)
									end
								| NONE => exe xs
						end
				in
					exe l
				end

				(* Guardar temporarios *)
				val temps : (tigertemp.temp * int) list = getTemps()
				fun printLista [] = ()
					| printLista (x::xs) = let 
											val _ = print x
											val _ = print ("\n")
										  in printLista xs end				
				(* Mover fp lo suficiente *)

				(* Recupero la dirección del fp actual*)
				val fpPrev : int = loadTemp tigerframe.fp
				(* Actualizo el fp a una dirección mas abajo. Estimo que cada fp tiene una capacidad de 1024*1024 *)
				val _ = storeTemp tigerframe.fp (fpPrev-1024*1024)

				(* Poner argumentos donde la función los espera *)
				(* La función original decía (TEMP (tigerframe.fp : tigertemp.temp)). Lo cambiamos a 0*)
				
				(*
				val forlist = tigerframe.formals2 frame
				val _ = if  length(forlist) = 2 then print(Bool.toString(List.nth(forlist,0))) else ()
				*)
				(* Veamos que onda esto: 
				val forlist = tigerframe.getFormals frame
				val _ = print ("NOMBRE FRAME: "^(tigerframe.name frame)^"\n")
				val _ = print ("LONG FORMALS FRAME: "^Int.toString(length(tigerframe.getFormals frame))^"\n")
				val _ = print ("ELEMENTO FRAME: "^Bool.toString(List.nth(forlist,0))^"\n")
				val _ = print ("LONG LOCALS FRAME: "^Int.toString(length(tigerframe.getLocals frame))^"\n")
				*)
				val formals = map (fn x => tigerframe.exp x 0) (tigerframe.formals frame)
				val formalsValues = ListPair.zip(formals, args)	

				(*Creo que para que genere el T1 con el valor 2 tiene que ser la segunda componente de formals algo asi como
				(TEMP T1,2) voy a forzar que eso pase.
				Para eso, hago la variable prueba. En el caso de main que no tiene argumentos lo dejo como antes.
				En el caso de la funcion g del test 8 hago que el segundo argumento se guarde en un temp y no en memoria.
				Le puse 17 para no confundir con otros valores, pero deberia tomar el 2						
				val prueba = if (length formalsValues) = 0 then formalsValues else (hd(formalsValues) :: [(TEMP "T1", 17)])				
				*)
				val _ = map (fn (x,y) => 
					case x of
						TEMP t => storeTemp t y
						| MEM m => storeMem (evalExp m) y
						| _ => raise Fail "No deberia pasar (tigerinterp)\n") formalsValues
				
				(* Ejecutar la lista de instrucciones *)
				val _ = execute body
				val rv = loadTemp tigerframe.rv

				(* Restaurar temporarios *)
				val _ = restoreTemps temps
				val _ = storeTemp tigerframe.rv rv
				(*
				val _ = print ("temporarios\n")
				val _ = printLista (map (fn (a,b) => a) (getTemps()))
				*)
			in
				rv
			end
	in (print("Comienzo de ejecución...\n"); evalFun("_tigermain", []); print("Fin de ejecución.\n")) end
end
