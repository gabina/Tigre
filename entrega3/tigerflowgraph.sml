(*Flow maneja los grafos de control de flujo. Cada instruccion esta representada como un nodo en el FGRAPH*)

structure Flow =
struct
	structure Graph
    datatype flowgraph = FGRAPH of {control: Graph.graph,
				    def: Temp.temp list Graph.Table.table,
				    use: Temp.temp list Graph.Table.table,
				    ismove: bool Graph.Table.table}
				    
(* control: un grafo dirigido donde cada nodo representa una instruccion *)
(* def: tabla de temporarios definido en cada nodo *)
(* use: tabla de temporarios usados en cada nodo *)
(* ismove: dice si cada instruccion es de tipo MOVE, en ese caso se puede borrar si def y use son iguales (??) *)

  (* Note:  any "use" within the block is assumed to be BEFORE a "def" 
        of the same variable.  If there is a def(x) followed by use(x)
       in the same block, do not mention the use in this data structure,
       mention only the def.

     More generally:
       If there are any nonzero number of defs, mention def(x).
       If there are any nonzero number of uses BEFORE THE FIRST DEF,
           mention use(x).

     For any node in the graph,  
           Graph.Table.look(def,node) = SOME(def-list)
           Graph.Table.look(use,node) = SOME(use-list)
   *)

end

sig 
	val instr2graph: tigerassem.instr list -> Flow.flowgraph * Flow.Graph.node list
end


fun instr2graph [] = FGRAPH{control = Graph.newGraph(), def= Graph.Table.tabNueva(), use = Graph.Table.tabNueva(),ismove = 
	| instr2graph (x::xs) =
(* Toma una lista de instrucciones y devuelve un grafo de flujo asociado con una lista de nodos que corresponden
   exactamente a las instrucciones. Las etiquetas jump sirven para generar las aristas de control de flujo.
   Ademas los use y def de cada nodo se pueden encontrar mediante las tablas de use y def de flowgraph *
   )
