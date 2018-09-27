signature GRAPH =
sig
    type graph
    type node
    
    val nodes: graph -> node list 	(* dado un grafo obtiene la lista de nodos *)
    val succ: node -> node list 	(* dado un nodo devuelve los nodos que los suceden *)
    val pred: node -> node list 	(* dado un nodo devuelve los nodos que lo preceden *)
    val adj: node -> node list   	(* dado un nodo devuelve los nodos que lo suceden y preceden *)
    val eq: node*node -> bool 		(* dados dos nodos, establece si son equivalentes *)

    val newGraph: unit -> graph     (* crea un grafo dirigido vacio *)
    val newNode : graph -> node     (* dado un grafo, crea un nodo en el *)
    exception GraphEdge
    val mk_edge: {from: node, to: node} -> unit	(* crea una arista dirigida desde el nodo from al nodo to. Automaticamente se agregan los predecesores y sucesores *)
    val rm_edge: {from: node, to: node} -> unit (* borra una arista entre el nodo from y to *)

    (* Esta tabla se utiliza para asociar instrucciones de un programa a nodos  *)

    structure Table : TABLE 
    sharing type Table.key = node

    val nodename: node->string  (* for debugging only *)

end
