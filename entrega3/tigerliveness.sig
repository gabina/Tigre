structure Liveness:
sig
	datatype igraph =
		IGRAPH of {graph: IGraph.graph,
				   tnode: tigertemp.temp -> IGraph node,
				   gtemp: IGraph.node -> tigertemp.temp,
				   moves: (IGraph.node * IGraph.node) list}
	
	(* graph: contiene el grafo de interderencia *)
	(* tnode: es un mapeo entre los temporarios del programa assem con los nodos del grafo *)
	(* gtemp: mapeo inverso. de nodos de grafos a temporarios *)
	(* moves: una lista de instrucciones move *)
	val interferenceGraph: Flow.flowgraph -> igraph * (Flow.Graph.node -> tigertemp.temp list)

	val show : outstream * igraph -> unit

	(* show: imprime la lista de nodos del grafo de interferencia. solo con proposito de debug *)

	type liveSet = unit tigertemp.Table.table * tigertemp.temp list
	type liveMap = liveSet Flow.Graph.Table.table
end