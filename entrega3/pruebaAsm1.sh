#!/bin/bash
# ejeccutar: bash pruebaAsm.sh 2> /dev/null si quiero evitar ver los segfault en terminal.

echo "HAGO MAKE" > resultado.txt
make 

for (( i=35; i<=42; i++))
	do			
			echo "TEST "$i; 			
			./tiger ../tests/good/test$i.tig -asm 2>&1 >/dev/null;			
			echo "**********************************************" >> resultado.txt;
			echo "TEST "$i >> resultado.txt;			
			gcc -s -no-pie ../tests/TestAssm/prueba.s ../tests/TestAssm/runtime.o;
					
			./a.out &>> resultado.txt; 
			if [ "$?" -eq 139 ];
			then echo "segfault" &>> resultado.txt;
		        fi;
			echo " " >> resultado.txt;
	done

echo "TERMINO!"
