signature tigertopsort =
sig
	exception Ciclo
	val fijaTipos : {name : string, ty : tigerabs.ty} list ->
		(string, tigertips.Tipo) tigertab.Tabla ->
		(string, tigertips.Tipo) tigertab.Tabla
		
	(*val equalTipos : tigertips.Tipo * tigertips.Tipo ->
		bool*)
end
