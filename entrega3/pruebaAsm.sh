#!/bin/bash
# ejecutar: bash pruebaAsm.sh 2> /dev/null si quiero evitar ver los segfault en terminal.

noEntry=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 21 22 23 24 26 27 28 29 30 31 32 33 36 37 38 39 40 41)
withEntry=(20 25 34 35 42)

echo "HAGO MAKE" > resultado.txt

make 

for i in "${noEntry[@]}" 
	do			
			echo "TEST "$i; 			
			./tiger ../tests/good/test$i.tig -asm 2>&1 >/dev/null;			
			echo "**********************************************" >> resultado.txt;
			echo "TEST "$i >> resultado.txt;			
			gcc -s ../tests/TestAssm/prueba.s ../tests/TestAssm/runtime.o;					
			./a.out &>> resultado.txt; 
			if [ "$?" -eq 139 ];
			then echo "segfault" &>> resultado.txt;
		        fi;
			echo " " >> resultado.txt;	
	done

echo "TERMINO PARA TESTS SIN ENTRADA POR TECLADO. BUSCAR ARCHIVO RESULTADO.TXT EN ENTREGA3"



