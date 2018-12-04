#!/bin/bash

echo -e "\nHAGO MAKE \n" 
make 
echo -e "\nGENERO ASSEMBLER DEL TEST $1 \n" 
./tiger ../tests/good/test$1.tig -asm 
echo -e "\nCOMPILO ASSEMBLER DEL TEST $1 \n" 
gcc -g ../tests/TestAssm/prueba.s ../tests/TestAssm/runtime.o
./a.out
geany ../tests/good/test$1.tig
geany ../tests/TestAssm/prueba.s


