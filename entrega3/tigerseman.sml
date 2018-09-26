structure tigerseman :> tigerseman =
struct

open tigerabs
open tigersres
open tigertrans

type expty = {exp: tigertrans.exp, ty: Tipo}
type recfun = {name: symbol, params: field list, result: symbol option, body: tigerabs.exp}
type rectype = {name: symbol, ty: ty}

type venv = (string, EnvEntry) tigertab.Tabla
type tenv = (string, Tipo) tigertab.Tabla

val tab_tipos : (string, Tipo) Tabla = tabInserList(
	tabNueva(),
	[("int", TInt), ("string", TString)])

val levelPila: tigertrans.level tigerpila.Pila = tigerpila.nuevaPila1(tigertrans.outermost) 

fun pushLevel l = tigerpila.pushPila levelPila l
fun popLevel() = tigerpila.popPila levelPila 
fun topLevel() = tigerpila.topPila levelPila

val tab_vars : (string, EnvEntry) Tabla = tabInserList(
	tabNueva(),
	[("print", Func{level=topLevel(), label="print",
		formals=[TString], result=TUnit, extern=true}),
	("flush", Func{level=topLevel(), label="flush",
		formals=[], result=TUnit, extern=true}),
	("getchar", Func{level=topLevel(), label="getchar",
		formals=[], result=TString, extern=true}),
	("ord", Func{level=topLevel(), label="ord",
		formals=[TString], result=TInt, extern=true}),
	("chr", Func{level=topLevel(), label="chr",
		formals=[TInt], result=TString, extern=true}),
	("size", Func{level=topLevel(), label="size",
		formals=[TString], result=TInt, extern=true}),
	("substring", Func{level=topLevel(), label="substring",
		formals=[TString, TInt, TInt], result=TString, extern=true}),
	("concat", Func{level=topLevel(), label="concat",
		formals=[TString, TString], result=TString, extern=true}),
	("not", Func{level=topLevel(), label="not",
		formals=[TInt], result=TInt, extern=true}),
	("exit", Func{level=topLevel(), label="exit",
		formals=[TInt], result=TUnit, extern=true})
	])


fun tipoReal (TTipo (s, ref NONE)) = raise Fail "no deberia pasar"
	| tipoReal ((TTipo (s, ref (SOME (t))))) = t
    | tipoReal t = t

fun tiposIguales (TRecord _) TNil = true
  | tiposIguales TNil (TRecord _) = true 
  | tiposIguales (TRecord (_, u1)) (TRecord (_, u2 )) = (u1=u2)
  | tiposIguales (TArray (_, u1)) (TArray (_, u2)) = (u1=u2)
  | tiposIguales (TTipo (_, r)) b =
		let
			val a = case !r of
				SOME t => t
				| NONE => raise Fail "No debería pasar! (1)"
		in
			tiposIguales a b
		end
  | tiposIguales a (TTipo (_, r)) =
		let
			val b = case !r of
				SOME t => t
				| NONE => raise Fail "No debería pasar! (2)"
		in
			tiposIguales a b
		end
  | tiposIguales a b = (a=b)

fun eqList ([] : (Tipo * Tipo) list) : bool = true
	| eqList ((t1, t2) :: tss) = if (tiposIguales t1 t2) then eqList tss else false

fun transExp((venv, tenv, levNest) : ( venv * tenv * tigertrans.level)) : (tigerabs.exp -> expty) =
	let fun error(s, p) = raise Fail ("Error -- línea "^Int.toString(p)^": "^s^"\n")
		fun trexp(VarExp v) = trvar(v)
		| trexp(UnitExp _) = {exp=unitExp(), ty=TUnit}
		| trexp(NilExp _)= {exp=nilExp(), ty=TNil}
		| trexp(IntExp(i, _)) = {exp=intExp i, ty=TInt}
		| trexp(StringExp(s, _)) = {exp=stringExp(s), ty=TString}
		| trexp(CallExp({func, args}, nl)) = 	
			let 
				val (ts,t,lab,lev : tigertrans.level,ext) = case tabBusca(func, venv) of
							NONE => error("Funcion no existente",nl)
							| SOME (VIntro _) => error("No es funcion 1",nl)
							| SOME (Var _) => error("No es funcion 2",nl)
							| SOME (Func {level=lev,label=lab,formals=l,result=tip,extern=ext}) => (l,tip,lab,lev,ext)							
				val _ = if (length ts <> length args) then error("Argumentos extras o faltantes",nl) else ()
				val m = ListPair.zip (map (fn x => #ty (trexp x)) args, ts)
				val argsExp = map (fn x => #exp (trexp x)) args : (tigertrans.exp list)			
			in
				case t of
					TUnit => if eqList m then {exp=callExp(lab,ext,true,lev,argsExp), ty= t} else error("Tipos erroneos",nl)
				    | _ => if eqList m then {exp=callExp(lab,ext,false,lev,argsExp), ty= t} else error("Tipos erroneos",nl) 
			end
		| trexp(OpExp({left, oper=EqOp, right}, nl)) =
			let 
				val {exp= expl, ty=tyl} = trexp left
				val {exp= expr, ty=tyr} = trexp right
			in 
				if tiposIguales tyl tyr andalso not (tyl=TNil andalso tyr=TNil) andalso tyl<>TUnit then 
					{exp= if tiposIguales tyl TString then binOpStrExp {left=expl,oper=EqOp,right=expr} else binOpIntRelExp {left=expl,oper=EqOp,right=expr}, ty=TInt}
					else error("Tipos no comparables", nl)
			end
		| trexp(OpExp({left, oper=NeqOp, right}, nl)) = 
			let
				val {exp=expl, ty=tyl} = trexp left
				val {exp=expr, ty=tyr} = trexp right
			in
				if tiposIguales tyl tyr andalso not (tyl=TNil andalso tyr=TNil) andalso tyl<>TUnit then 
					{exp=if tiposIguales tyl TString then binOpStrExp {left=expl,oper=NeqOp,right=expr} else binOpIntRelExp {left=expl,oper=NeqOp,right=expr}, ty=TInt}
					else error("Tipos no comparables", nl)
			end
		| trexp(OpExp({left, oper, right}, nl)) = 
			let
				val {exp=expl, ty=tyl} = trexp left
				val {exp=expr, ty=tyr} = trexp right
			in
				if tiposIguales tyl tyr then
					case oper of
						PlusOp => (case tipoReal tyl of
									TInt  => {exp=binOpIntExp {left=expl, oper=oper, right=expr},ty=TInt}
									| _ => error ("Error de tipos", nl))
						| MinusOp => (case tipoReal tyl of
									 	TInt => {exp=binOpIntExp {left=expl, oper=oper, right=expr},ty=TInt}
									 	| _ => error("Error de tipos", nl))
						| TimesOp => (case tipoReal tyl of
									 	TInt => {exp=binOpIntExp {left=expl, oper=oper, right=expr},ty=TInt}
									 	| _ => error("Error de tipos", nl))
						| DivideOp => (case tipoReal tyl of
									 	TInt => {exp=binOpIntExp {left=expl, oper=oper, right=expr},ty=TInt}
									 	| _ => error("Error de tipos", nl))
						| LtOp => (case tipoReal tyl of
									TInt => {exp= binOpIntRelExp {left=expl,oper=oper,right=expr},ty=TInt} 
									| TString => {exp= binOpStrExp {left=expl,oper=oper,right=expr}, ty=TInt}
									| _ => error("Error de tipos", nl))
						| LeOp => (case tipoReal tyl of
									TInt => {exp= binOpIntRelExp {left=expl,oper=oper,right=expr},ty=TInt} 
									| TString => {exp= binOpStrExp {left=expl,oper=oper,right=expr}, ty=TInt}
									| _ => error("Error de tipos", nl))
						| GtOp => (case tipoReal tyl of
									TInt => {exp= binOpIntRelExp {left=expl,oper=oper,right=expr},ty=TInt} 
									| TString => {exp= binOpStrExp {left=expl,oper=oper,right=expr}, ty=TInt}
									| _ => error("Error de tipos", nl))
						| GeOp => (case tipoReal tyl of
									TInt => {exp= binOpIntRelExp {left=expl,oper=oper,right=expr},ty=TInt} 
									| TString => {exp= binOpStrExp {left=expl,oper=oper,right=expr}, ty=TInt}
									| _ => error("Error de tipos", nl))
						| _ => raise Fail "No debería pasar! (3)"
				else error("Error de tipos", nl)
			end
		| trexp(RecordExp({fields : (symbol * tigerabs.exp) list, typ : symbol}, nl)) =
			let
				(* Traducir cada expresión de fields *)
				val tfields = map (fn (sy,ex) => (sy, trexp ex)) fields

				(* Buscar el tipo *)
				val (tyr, cs) = case tabBusca(typ, tenv) of
					SOME t => (case tipoReal t of
						TRecord (cs, u) => (TRecord (cs : (string * Tipo * int) list , u), cs)
						| _ => error(typ^" no es de tipo record", nl))
					| NONE => error("Tipo inexistente ("^typ^")", nl)
				
				(* Verificar que cada campo esté en orden y tenga una expresión del tipo que corresponde *)
				fun verificar _ [] [] = []
				  | verificar _ (c::cs) [] = error("Faltan campos", nl)
				  | verificar _ [] (c::cs) = error("Sobran campos", nl)
				  | verificar n ((s,t,_)::cs) ((sy,{exp,ty})::ds) =
						if s<>sy then error("Error de campo", nl)
						else if tiposIguales ty t then (exp, n)::(verificar (n+1) cs ds)
							 else error("Error de tipo del campo "^s, nl)
				val lf = verificar 0 cs tfields
			in
				{exp=recordExp lf, ty=tyr}
			end
		| trexp(SeqExp(s, nl)) =
			let	val lexti = map trexp s
				val exprs = map (fn{exp, ty} => exp) lexti
				val {exp, ty=tipo} = hd(rev lexti)
			in	{ exp=seqExp (exprs), ty=tipo } end
		| trexp(AssignExp({var=SimpleVar s, exp}, nl)) = 
			let
				val r = case tabBusca(s, venv) of
							NONE => error("Variable no existente",nl)
							| SOME (VIntro _) => error("No es variable.Solo lectura",nl)
							| SOME (Var {ty = tip,...}) => tip 
							| SOME (Func _)  => error("No es variable",nl)
				val {exp=eexp,ty=texp} = trexp exp
				val {exp=evar,ty=_} = trvar (SimpleVar s, nl)
			in if (tiposIguales texp r) then {exp=assignExp{var =evar ,exp = eexp},ty= TUnit} else error("Tipos erroneos",nl) end	
		| trexp(AssignExp({var=FieldVar (v,s), exp}, nl)) = 
			let 
				val {exp=evar,ty=r} = trvar (FieldVar (v,s),nl)
				val {exp=eexp,ty=texp} = trexp exp
			(* Esta comparación estaba hecha con un =, en lugar de con tiposIguales *)	
			in if tiposIguales texp r then {exp=assignExp{var =evar ,exp = eexp},ty = TUnit} else error("Tipos erroneos",nl) end
		| trexp(AssignExp({var=SubscriptVar(v,s), exp}, nl)) =	
			let 
				val {exp=evar,ty=r} = trvar (SubscriptVar (v,s),nl)
				val {exp=eexp,ty=texp} = trexp exp
			in if tiposIguales texp r then {exp=assignExp{var =evar ,exp = eexp},ty = TUnit} else error("Tipos erroneos",nl) end
			
		| trexp(IfExp({test, then', else'=SOME else'}, nl)) =
			let val {exp=testexp, ty=tytest} = trexp test
			    val {exp=thenexp, ty=tythen} = trexp then'
			    val {exp=elseexp, ty=tyelse} = trexp else'
			in
				if tipoReal tytest=TInt andalso tiposIguales tythen tyelse then
				{exp=if tipoReal tythen=TUnit then ifThenElseExpUnit {test=testexp,then'=thenexp,else'=elseexp}
				else ifThenElseExp {test=testexp,then'=thenexp,else'=elseexp}, ty=tythen}
				else error("Error de tipos en if" ,nl)
			end
		| trexp(IfExp({test, then', else'=NONE}, nl)) =
			let val {exp=exptest,ty=tytest} = trexp test
			    val {exp=expthen,ty=tythen} = trexp then'
			in
				if tipoReal tytest=TInt andalso tythen=TUnit then
				{exp=ifThenExp{test=exptest, then'=expthen}, ty=TUnit}
				else error("Error de tipos en if", nl)
			end
		| trexp(WhileExp({test, body}, nl)) =
			let
				val ttest = trexp test
				val _ = preWhileForExp ()
				val tbody = trexp body
				val (exp, ty) = if tipoReal (#ty ttest) = TInt andalso #ty tbody = TUnit then (whileExp {test=(#exp ttest), body=(#exp tbody), lev=topLevel()}, TUnit)
				else if tipoReal (#ty ttest) <> TInt then error("Error de tipo en la condición", nl)
				else error("El cuerpo de un while no puede devolver un valor", nl)
				val _ = postWhileForExp()
			in
				{exp = exp, ty = ty}
			end
		| trexp(ForExp({var, escape, lo, hi, body}, nl)) =  
			let
				val tlo = trexp lo
				val thi = trexp hi			
				val venv' = tabRInserta (var, VIntro {access= allocLocal levNest (!escape), level= levInt levNest}, venv) 
				val _ = preWhileForExp()
				val tbody =  transExp (venv', tenv,levNest) body 
				val evar = transExp (venv', tenv,levNest) (VarExp ((SimpleVar var), nl))
				val (exp,ty) = if tipoReal (#ty tlo) = TInt andalso tipoReal (#ty thi) = TInt andalso (#ty tbody) = TUnit then (forExp {lo= #exp tlo,hi= #exp thi,var= #exp evar,body= #exp tbody}, TUnit)
				else if tipoReal(#ty tlo) <> TInt orelse tipoReal (#ty thi) <> TInt then error("Error de tipo en la condición", nl)
				else error("El cuerpo de un for no puede devolver un valor", nl)  
				(*Habría que ver si el postWhileForExp está bien ubicado*)
				val _ = postWhileForExp()
			in
				{exp = exp, ty = ty} 				
			end		
		| trexp(LetExp({decs, body}, _)) =
			let
				fun aux ((d, (v, t, exps1)) : (dec * ( venv * tenv * exp list))) : (venv * tenv * exp list) =
				let
					val (v', t', exps2) = trdec (v, t) d
				in
					(v', t', exps1@exps2)
				end 
				val (venv', tenv', expdecs) = List.foldl aux (venv, tenv, []) decs
				val {exp=expbody,ty=tybody}=transExp (venv', tenv',levNest) body
			in 
				{exp=seqExp(expdecs@[expbody]), ty=tybody}
			end
		| trexp(BreakExp nl) =
			{exp=breakExp(), ty=TUnit}
		| trexp(ArrayExp({typ, size, init}, nl)) = 
			let
				val {exp=einit, ty=tinit}  = trexp init
				val {exp=esize, ty=tsize} = trexp size
				(* val _ = print (typ) *)
				val (r,r3) = case tabBusca (typ,tenv) of
					(*NONE => ((print "hola";tigermuestratipos.printTTipos(tigertab.tabAList (tenv:  (string, Tipo) tigertab.Tabla)));error ("El tipo no se encuentra en el entorno 230", nl)) 	*)					
					  NONE => error ("El tipo no se encuentra en el entorno", nl)
					| SOME (TArray (tipo,r2)) =>  (tipo,r2)
					| SOME _ => error ("El arreglo no es de tipo arreglo", nl)
			in if (tiposIguales tinit r) andalso tsize = TInt then {exp = tigertrans.arrayExp({init=einit, size=esize}),ty = TArray (r, r3 )} else error ("size no es int o tipo de init incorrecto",nl)
			end	
and trvar(SimpleVar s, nl) = 
			let 
			val r = case tabBusca(s,venv) of
				NONE => error("La variable no se encuentra en el entorno: "^s,nl)
				| SOME (VIntro {access = acc, level = lvl}) => {exp = (tigertrans.simpleVar (acc, lvl)), ty = TInt} 
				| SOME (Var {ty = tip, access = acc, nivel = lvl}) => {exp = (tigertrans.simpleVar (acc, lvl) ), ty = tip} 
				| SOME (Func _)  => error("No es variable",nl)

			in r end
		| trvar(FieldVar(v, s), nl) = 
			let 
				val {exp=expfield, ty=tip} = trvar (v,nl)
				val r = case (tipoReal tip) of 
					(* Supongo que el int del TRecord es el número de campo *)
					(TRecord (l,_)) => List.filter (fn (a,_,_) => a = s) l
					| _ => error("Accediendo a un record inexistente",nl)
			in if length r = 1 then  {exp=tigertrans.fieldVar (expfield, #3 (hd r)),ty= (#2 (hd r))}  else error("Campo inexistente",nl) end
			
		| trvar(SubscriptVar(v, e), nl) = 
			let 
				val {exp=expint,ty=tipex} = trexp e
				val r1 = case tipex of
					TInt => ()
					| _ => error("El indice no es un int",nl)
				val {exp=exparr, ty=tip} = trvar (v,nl)
				val r = case (tipoReal tip) of 
					(TArray (tr,_)) => {exp=(tigertrans.subscriptVar (exparr, expint)),ty=(tr)} 
					| _ => error("Accediendo a un arreglo inexistente",nl)
			in r end

(*
	ENTREGA 2:

dec = FunctionDec of ({name: symbol, params: field list,
		result: symbol option, body: exp} * pos) list
	| VarDec of {name: symbol, escape: bool ref,
		     typ: symbol option, init: exp} * pos
	| TypeDec of ({name: symbol, ty: ty} * pos) list

datatype EnvEntry =
	VIntro of {access: tigertrans.access, level: int}	(* int readonly *)
	| Var of {ty: Tipo, access: tigertrans.access, nivel: int}
	| Func of {level: tigertrans.level, label: tigertemp.label,
		formals: Tipo list, result: Tipo, extern: bool}

	Cosas a tener en cuenta de EnvEntry Func: 
	label es un string que debe ser único, para identificar funciones anidadas con el mismo nombre.
    result será el result de FunctionDec en caso de que esté presente, sino será TUnit (las funciones siempre deben indicar su tipo)
    extern por ahora siempre será false. Será true con funciones de librería
*)
		and trdec (venv, tenv) (VarDec ({name,escape,typ=NONE,init},nl)) = 
				let
					(* ¿Por qué llamamos a transExp en lugar de a trexp?*)
					val {ty=texp,exp=eexp} = transExp (venv, tenv,levNest) init
					val acc = tigertrans.allocLocal levNest (!escape)
					val niv = tigertrans.levInt(levNest)								
					val v = tigertrans.assignExp{var=tigertrans.varDec (acc),exp=eexp}			   					
				in (tabRInserta (name, Var {ty= texp,access= acc,nivel= niv}, venv),tenv,[v])
				end
				
	       | trdec (venv, tenv) (VarDec ({name,escape,typ=SOME t,init},nl)) =
				let
					val {ty=texp,exp=eexp} = transExp (venv, tenv,levNest) init
					val r = case tabBusca (t,tenv) of
						NONE => error ("El tipo no se encuentra en el entorno", nl) 						
						| SOME tipo => tipo
					val acc = tigertrans.allocLocal levNest (!escape)
					val niv = tigertrans.levInt(levNest)
					val v = tigertrans.assignExp{var=tigertrans.varDec (acc),exp=eexp}	
         (*val _ = (tigermuestratipos.printTipo("Tipo de init",texp,[]))
          val _ = (tigermuestratipos.printTipo("Tipo de r:",r,[])) *)
				in if (tiposIguales texp r) then (tabRInserta (name, Var {ty=r, access= acc,nivel= niv}, venv),tenv,[v]) else error ("La inicializacion no tiene el tipo de la variable",nl) end	
		
		| trdec (venv,tenv) (FunctionDec xs) =  
			let
				val nombreFuncion = (#name (#1 (hd xs))) : string
				val _ = tigertrans.preFunctionDec() (* Aumenta el nivel actual *)
				val listlistParams = map (fn ({params=paramsFun,...},nl) => paramsFun) xs
				val listEscapes = map (fn xs => (map (fn {escape=e,...} => !e) xs)) listlistParams : bool list list	
				val listPos = map (fn (a,b) => b) xs				

			    val empty = Splayset.empty String.compare
	            val ts' = Splayset.addList (empty, List.map (fn ({name = n,...},_) => n) xs)	            
		        val _ = if (Splayset.numItems ts' <> length xs) then error("Funciones con el mismo nombre",length xs) else()  
			    (* val _ = print ("Entro a trdec (venv, tenve) FunctionDec \n") *)
			    
			    (*aux0 : Retorna la lista de Tipo correspondiente a la lista de fields, corroborando que los tipos estén en el entorno*) 			    
			    fun aux0 (([], nl) : (field list * int)) : (Tipo list) = []
			      | aux0 (f :: lf, nl) = case #typ f of 
											NameTy s => (case tabBusca (s,tenv) of
															NONE => error ("El tipo no se encuentra en el entorno", nl) 			
														  | SOME tipo => tipo :: (aux0 (lf, nl)))
										    | _ => error ("Error en aux0", nl) 			      
			    (* decideResult : (Symbol Option) Int -> Tipo *)
			    fun decideResult ((NONE, nl) : (symbol option * int)) : Tipo  = TUnit
			      | decideResult ((SOME t, nl) : (symbol option * int)) : Tipo = 
						case tabBusca (t,tenv) of
		               	      NONE => error ("El tipo no se encuentra en el entorno", nl) 						
	                        | SOME tipo => tipo  
			    (* insertFun inserta las funciones al entorno*) 
			    fun insertFuns (([], l, venv) :((recfun * int) list * bool list list * venv)) : venv = venv
			      | insertFuns (xs,[], venv) = venv (* no deberia pasar nunca *)
		    	  | insertFuns (({name = nom, params = p, result = r, ...}, n) :: rns, f::fs,venv) =  
		    	  let
					val res = decideResult(r, n)
					val form = aux0 (p, n)
					val lab = if nom = "_tigermain" then "_tigermain" else tigertrans.generateUniqueLab()
					val nlevel = tigertrans.newLevel {parent = levNest, name = lab,nameViejo=nom,formals = f}					
					val _ = print ("Agregando.."^nom^"como "^lab^"\n")
					(* PREGUNTA: ¿por qué inserto la función con nom en lugar de hacerlo con lab que es único? *)
		    	  in insertFuns(rns, fs, tabRInserta (nom, Func {level = nlevel, label = lab, formals = form, result = res, extern = false}, venv))
		    	  end
		    	                                                 
			    val env1 = insertFuns (xs, listEscapes, venv) (* Este es el entorno en donde ya agregué las funciones *)
			   (* Agrega los argumentos de la función nom como variables al entorno *) 
			   fun insertArgs (([],_,venv) : ((field * Tipo * int) list * symbol *venv)) : venv = venv
  			     | insertArgs ((f, t,pos) :: fts, nom, venv) =
  			     let
					val lvl = case tabBusca (nom,venv) of
									NONE => error("Agregando argumentos de una función que no está en el entorno",100)
								  | SOME (VIntro _) => error("No es funcion 3", pos) 
								  | SOME (Var _) =>	error("No es funcion 4", pos)
								  | SOME (Func {level = l, ...}) => l
					val lvlint = (tigertrans.levInt lvl) : int
				 in
					insertArgs (fts, nom, tabRInserta (#name f, Var {ty= t, access=tigertrans.allocArg lvl (!(#escape f)), nivel= lvlint}, venv)) 
				 end
  			     (*(#level (levNest : tigertrans.level)) : int}*)
			   (* Genera una lista de entornos donde se agregaron los argumentos de las funciones *)
			   fun newEnvs (([], venv) : ((recfun * int) list * venv)) : venv list = []
			     | newEnvs (({name = nom, params = p, ...}, n) :: rns, venv) =  
					let
						val tipos = aux0(p, n)
						val auxiliar = ListPair.zip (p, tipos)
						val auxiliar2 = ListPair.zip (auxiliar, listPos)
						val auxiliar3 = List.map (fn ((a,b),c) => (a,b,c)) auxiliar2
						val nvenv = insertArgs (auxiliar3, nom, venv)
					in 
						 nvenv :: (newEnvs (rns, venv))
					end
			   
			   val venvs : venv list = newEnvs(xs, env1) (* venvs es la lista de entornos con las variables agregadas para cada función *)
			   (* Corroboramos cada body con su respectivo env 
			   Agregar las expresiones de los cuerpos a la lista global*)				   
			fun aux4 ([] : (recfun * venv * int) list) : Tipo list = []
			     | aux4 (({body = b, name=nom, ... }, venv, pos) :: rvs) = let
							(* val b = (#body (hd lf)) *) (*Tiene tipo Exp*)
							val lvl = case tabBusca (nom,env1) of
									NONE => error("Agregando argumentos de una función que no está en el entorno",pos)
								  | SOME (VIntro _) => error("No es funcion 5", pos) 
								  | SOME (Var _) =>	error("No es funcion 6", pos)
								  | SOME (Func {level = l, ...}) => l
							val f = transExp (venv , tenv, lvl) (*Deberìa ser una función que toma una exp*)
							(* Agregar las expresiones de los cuerpos a la lista*)
							val {ty = elem,exp =expr} = (f b)
							val _ = tigertrans.functionDec(expr,lvl, (tiposIguales elem TUnit))
						    in elem :: (aux4 rvs) end	
			   val auxiliar = 	ListPair.zip(List.map (fn (fs,_) => fs) xs, venvs)	   
			   val auxiliar2 = ListPair.zip (auxiliar,listPos)
			   val auxiliar3 = List.map (fn ((a,b),c) => (a,b,c)) auxiliar2
			   val tipos : Tipo list = aux4 auxiliar3

			   (* aux5 :  *)
			fun aux5 ([] : ((Tipo * Tipo) * int) list) : bool * int = (true,0)
			  | aux5 (((t1, t2), n) :: ttns) = if (tiposIguales t1 t2) then aux5 ttns else (false, n)
			val lp = List.map (fn ((r, n) : recfun * int) => (decideResult (#result r, n))) xs
           (* val _ = (print ("probando algo: ");tigermuestratipos.printTTipos(tigertab.tabAList (tenv: (string, Tipo) tigertab.Tabla))) *)
			val ok = aux5 (ListPair.zip (ListPair.zip(lp,tipos), List.map (fn (_,n) => n) xs))
			val _ = tigertrans.postFunctionDec() (* Disminuye el nivel actual *)
			in if (#1 ok) then (env1, tenv, []) else error("Error en el cuerpo de la función 446", (#2 ok)) end
				
		| trdec (venv,tenv) (TypeDec ts) = 
			let 
            	val empty = Splayset.empty String.compare
            	val ts' = Splayset.addList (empty, List.map (fn ({name = n,...},_) => n) ts)
            	val tenv' = if (Splayset.numItems ts' = length ts) then tigertopsort.fijaTipos (List.map (fn (r, n) => r) ts) tenv else error("Tipos con el mismo nombre", #2 (hd ts))
            in (venv, tenv', []) (* before (print"Entro a trdec (venv, tenve) TypeDec \n Agregado \n \n \n ";tigermuestratipos.printTTipos(tigertab.tabAList (tenv': (string, Tipo) tigertab.Tabla))) *) end
    in trexp end

fun transProg ex =
	let	val main =
				LetExp({decs=[FunctionDec[({name="_tigermain", params=[],
								result=SOME "int", body=ex}, 0)]],
						body=UnitExp 0}, 0)
		val _ = transExp(tab_vars, tab_tipos, tigertrans.outermost : tigertrans.level) main
	in	print "bien!\n" end
end
