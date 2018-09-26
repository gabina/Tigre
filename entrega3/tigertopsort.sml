structure tigertopsort:> tigertopsort =
struct

open tigerabs
open tigertab
open tigertips

infix rs ls -- ---
fun x ls f = fn y => f(x, y)
fun f rs y = fn x => f(x, y)
fun l -- e = List.filter (op<> rs e) l
fun fst(x, _) = x and snd(_, y) = y
fun lp --- e = List.filter ((op<> rs e) o fst) lp
exception Ciclo

(* P: pares.  E: elementos.
St: Stack de no tratados.
Res: resultado.  *)

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
  
fun topsort P =
	let	fun candidato E P =
			List.filter (fn e => List.all((op<> rs e) o snd) P) E
		fun tsort P [] Res = rev Res
		| tsort [] St Res = rev(St @ Res)
		| tsort P (St as (h::t)) Res =
			let	val x = (hd(candidato St P)) handle Empty => raise Ciclo
			in	tsort (P --- x) (St -- x) (x::Res) end
	fun elementos lt =
		List.foldr (fn((x, y), l) =>
			let	val l1 = case List.find (op= rs x) l of
							NONE => x::l | _ => l
				val l2 = case List.find (op= rs y) l1 of
							NONE => y::l1 | _ => l1
			in	l2 end) [] lt
	in	tsort P (elementos P) [] end

fun buscaArrRecords lt =
	let	fun buscaRecs [] res = res
		| buscaRecs({name, ty=RecordTy lf}::t) res =
			let	fun genrecs [] _ = []
				| genrecs({name, escape, typ=NameTy s}::tail) n =
					(name, TTipo (s,ref NONE), n)::genrecs tail (n+1)
				| genrecs _ _ = raise Fail "error interno 666+3"
			in	buscaRecs t ((name, TRecord(genrecs lf 0, ref()))::res) end
		| buscaRecs({name, ty=ArrayTy ty}::t) res = buscaRecs t ((name, TArray(TTipo (ty, ref NONE), ref()))::res)
		| buscaRecs(_::t) res = buscaRecs t res
	in	buscaRecs lt [] end
fun genPares lt =
	let
		val lrecs = buscaArrRecords lt
		fun genP [] res = res
		| genP ({name, ty=NameTy s'}::t) res = (print("NameTy "^s'^"\n"); genP t ((s', name)::res)   )
		| genP ({name, ty=ArrayTy s'}::t) res = genP t ((s', name)::res)
		| genP ({name, ty=RecordTy lf}::t) res = genP t res
	in	genP lt [] end
fun procesa [] pares env _ = env: (string, Tipo) Tabla
| procesa (sorted as (h::t)) (pares:{name:symbol, ty:ty} list) env recs =
	let
		fun filt h {name, ty = NameTy t} = h=t
		| filt h {name, ty = ArrayTy t} = h=t
		| filt h {name, ty = RecordTy lt} = List.exists (((NameTy h) ls op=) o #typ) lt
		val (ps, ps') = List.partition (filt h) pares
		val ttopt = case tabBusca(h, env) of
					SOME t => SOME t
					| _ =>
						case List.find((h ls op=) o #1) recs of
						SOME (n, tr) =>
								(tabRInserta(h, tr, env);
								SOME tr) (* OJOOOOOOOOOOOOOOOO *)
						| _ => raise Fail (h^" **no existe!!!")
		val env' = case ttopt of
					SOME tt =>
						List.foldr
							(fn({name, ty=NameTy ty}, env') => tabRInserta(name, tt, env')
							| ({name, ty=ArrayTy s}, env') =>
								let val (k, v) =
										case List.find((name ls op=) o #1) recs of
										SOME x => x | _ => raise Fail "error 666+45"
								in	tabRInserta(k, v , env') end
							| ({name, ty=RecordTy s}, env') =>
								let val (k, v) =
										case List.find((name ls op=) o #1) recs of
										SOME x => x | _ => raise Fail "error 666+46"
								in	tabRInserta(k, v , env') end)
					 		env ps
					| _ => env
	in procesa t ps' env' recs end

fun fijaNONE [] (env : (string, Tipo) Tabla) = env
| fijaNONE((name, TArray(ar as ((TTipo (s : string,r)), u)))::t) env =
	(case tabBusca(s, env) of
	NONE => raise Fail "error interno 666+1"
	| (SOME ras) : Tipo option  => (r := SOME ras; fijaNONE t env))
| fijaNONE((name, TRecord(lf, u))::t) (env : (string, Tipo) Tabla) =
	let	fun busNONE(s, ar as (TTipo (t,r)), _) =
			(r := SOME (tabSaca(t : string, env : (string, Tipo) Tabla)) handle _ => raise noExiste)
		| busNONE _ = ()
		val _ = List.app busNONE lf
	in	fijaNONE t env end
| fijaNONE(_::t) env = fijaNONE t env
(*
fun fijaNONE [] (env : (string, Tipo) Tabla) = env
| fijaNONE((name, TArray(ar as ((TTipo (s : string,r)), u)))::t) env =
	(case tabBusca(s, env) of
	NONE => raise Fail "error interno 666+1"
	| (SOME ras) : Tipo option  =>  fijaNONE t (tabRInserta (name, TArray (ras,u), env)))
| fijaNONE((name, TRecord(lf, u))::t) (env : (string, Tipo) Tabla) =
	let	fun busNONE(s, ar as (TTipo (t,r)), _) =
			(r := SOME (tabSaca(t : string, env : (string, Tipo) Tabla)) handle _ => raise noExiste)
		| busNONE _ = ()
		val _ = List.app busNONE lf
	in	fijaNONE t env end
| fijaNONE(_::t) env = fijaNONE t env
*)
fun sacaTTipo (TTipo (s : string,ref(NONE))) env =  raise Fail "error interno 666+1"
| sacaTTipo (TTipo (s : string,ref(SOME ras))) env = ras
| sacaTTipo (TArray(ar as ((TTipo (s : string,ref(NONE))), u))) env = raise Fail "error interno 666+1"
| sacaTTipo (TArray(ar as ((TTipo (s : string,ref(SOME ras))), u))) env = TArray ((sacaTTipo ras env),u)
| sacaTTipo (rcd as(TRecord(lf : (string * Tipo * int) list, u))) env = (*TRecord(List.map (fn (s,t,n) =>  if (tiposIguales rcd t) then (s,t,n) else (s,sacaTTipo t env,n)) lf,u)*)  TRecord(List.map (fn (s,t,n) =>  (s,sacaTTipo t env,n)) lf,u)
| sacaTTipo t env = t			
	
fun sacaTTipos [] env = env : (string, Tipo) Tabla
| sacaTTipos ((s,t)::xs) env = sacaTTipos xs (tabRInserta(s,sacaTTipo t env,env))
(*				
fun sacaTTipo [] env = env
| sacaTTipo ((name, TTipo (s : string,ref(NONE)))::t) env = raise Fail "fijaNONE no anduvo correctamente"
| sacaTTipo ((name, TTipo (s : string,ref(SOME r)))::t) env = sacaTTipo t (tabRInserta (name, r, env))
| sacaTTipo((name, TArray(ar as ((TTipo (s : string,ref(NONE))), u)))::t) env = raise Fail "fijaNONE no anduvo correctamente"
| sacaTTipo((name, TArray(ar as ((TTipo (s : string,ref(SOME r))), u)))::t) env = sacaTTipo t (tabRInserta (name, TArray (r,u), env))
| sacaTTipo ((name, TRecord(lf, u))::t) (env : (string, Tipo) Tabla) =
	let	fun busNONE [] = []
		| busNONE ((s, ar as (TTipo (t,ref(SOME r))), n)::xs) = (s,r,n)::(busNONE xs)
		| busNONE ((s, ar as (TTipo (t,ref(NONE))), n)::xs) = raise Fail "fijaNONE no anduvo correctamente"
		| busNONE (x::xs) = x::(busNONE xs) 
		val nlf = busNONE lf
		val nenv =  (tabRInserta (name, TRecord (nlf,u), env))
	in	sacaTTipo t nenv end
| sacaTTipo (_::t) env = sacaTTipo t env
*)
(*	
fun equalTipos (TUnit, TUnit) = true
	| equalTipos (TNil, TNil) = true
	| equalTipos (TInt, TInt) = true
	| equalTipos (TString, TString) = true
	| equalTipos ((ar1 as TArray(t,_)), (ar2 as TArray(t',_))) = equalTipos (t, t')
	| equalTipos ((rc1 as TRecord(l,_)), (rc2 as TRecord(l',_))) = 
		let
			val lis = List.map (fn (_,t,_) => t) l
			val lis' = List.map (fn (_,t,_) => t) l'
			val lista : (Tipo * Tipo) list = ListPair.zip (lis,lis')
			val listBool = List.filter equalTipos lista
		in 
			if ((length listBool) = (length lista)) then true else false
		end
	| equalTipos ((tt1 as TTipo(_,ref(SOME t))), (tt2 as TTipo(_,ref(SOME t')))) = equalTipos (t, t')
	| equalTipos (t, t') = false

fun sacaTTipos (env : (string, Tipo) Tabla) = 
	let
		val sinTipos : (string, Tipo) Tabla = (sacaTTipo (tabAList env) env)
	in 
		if tigertab.tabIgual(equalTipos,sinTipos,env) then env else (sacaTTipos sinTipos)
	end 
*)
(*	
fun fijaNONE [] (env : (string, Tipo) Tabla) = env
| fijaNONE((name, TArray(ar as ((TTipo (s : string,r)), u)))::t) env =
	(case tabBusca(s, env) of
	NONE => raise Fail "error interno 666+1"
	| (SOME ras) : Tipo option  => 
	(let
		(* Agrego el tipo correctamente al entorno *)
		val nenv = fijaNONE [(s,ras)] env
		val ras' = (case tabBusca(s, nenv) of
					NONE => raise Fail "error interno 666+1"
					| (SOME ras) : Tipo option  => ras)
		val nenv' = (tabRInserta (name, TArray (ras',u), nenv))
		(*val _ = print(name^"(TTipo "^s^") es reemplazado por ")*)
		(*val _ = tigermuestratipos.printTipo("",TArray (ras,u),tabAList nenv)*)
		(*val _ = (case tabBusca(name,nenv) of
		NONE => raise Fail "nada de sentido"
		| (SOME ras) =>  tigermuestratipos.printTipo("",ras,tabAList nenv))*)
	in fijaNONE t nenv' end))
| fijaNONE((name, TRecord(lf, u))::t) (env : (string, Tipo) Tabla) =
	let	fun busNONE [] = []
		| busNONE ((s, ar as (TTipo (t,r)), n)::xs) = 
		(case tabBusca(t, env) of
		NONE => raise Fail "error interno 666+1"
		| (SOME ras) : Tipo option  => 
		(let
			val nenv = fijaNONE [(t,ras)] env
			val ras' = (case tabBusca(t, nenv) of
					   NONE => raise Fail "error interno 666+1"
					   | (SOME ras) : Tipo option  => ras)
		in (s,ras',n) :: (busNONE xs) end))
		| busNONE (x::xs) = x::(busNONE xs) 
		val nlf = busNONE lf
		val nenv =  (tabRInserta (name, TRecord (nlf,u), env))
	in	fijaNONE t nenv end
| fijaNONE(_::t) env = fijaNONE t env*)
fun agregarecs env [] = env
| agregarecs env ((k, v)::t) =
	agregarecs (tabRInserta(k, v, env)) t



fun fijaTipos batch env =
	let	val pares = genPares batch
		val recs = buscaArrRecords batch
		val orden = topsort pares
		val env' : (string, Tipo) Tabla = procesa orden batch env recs
		val env'' : (string, Tipo) Tabla = (agregarecs env' recs) : (string, Tipo) Tabla
		(*val _ = print("Segundo entorno:\n")
		val _ = tigermuestratipos.printTTipos(tabAList env'')*)
		val env''' = fijaNONE (tabAList env'') (env'' : (string, Tipo) Tabla)
		val env'''' = sacaTTipos (tabAList env''') env'''
		(*val _ = print("Entorno final:\n")
		val _ = tigermuestratipos.printTTipos(tabAList env'''')
		val _ = print("Fin entorno\n")*)
	in	env'''' end
end
