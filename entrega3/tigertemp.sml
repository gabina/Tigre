structure tigertemp :> tigertemp = struct
(* nombres abstractos para direcciones de memoria estáticas *)
(* label refiere a una direccion en lenguaje maquina que todavia debe ser determinada*)
type label = string
(* nombres abstractos para variables locales*)
(* temp refiere a un valor que temporalmente esta almacenado en un registro*)
type temp = string
fun makeString s = s
local
	val i = ref 0
	val j = ref 0
in
	fun newtemp() =
		let
			val s = "T"^Int.toString(!i)
		in
			i := !i+1;
			s
		end
	fun newlabel() =
		let
			val s = "L"^Int.toString(!j)
		in
			j := !j+1;
			s
		end
end
end
