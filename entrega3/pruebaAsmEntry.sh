#!/bin/bash

withEntry=(20 25 34 35 42)

echo "HAGO MAKE" > resultado.txt

make 

for i in "${withEntry[@]}" 
	do			
			echo "TEST "$i; 			
			./tiger ../tests/good/test$i.tig -asm 2>&1 >/dev/null;			
			echo "**********************************************";
			echo "TEST "$i;			
			gcc -s ../tests/TestAssm/prueba.s ../tests/TestAssm/runtime.o;					
			./a.out;
	done

echo "TERMINO PARA TESTS CON ENTRADA POR TECLADO."
