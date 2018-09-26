load "TextIO";

fun sacanl s = implode(List.filter (fn x=>x<> #"\n") (explode s))
val s = TextIO.inputLine TextIO.stdIn
val x = explode(valOf s)
val y = sacanl (valOf s)
val z = "abc"="abc\n"
