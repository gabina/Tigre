signature tigermunch = sig
val codeGen : tigerframe.frame -> tigertree.stm -> tigerassem.instr list
val procEntryExit2 : tigerframe.frame * tigerassem.instr list -> tigerassem.instr list
end
