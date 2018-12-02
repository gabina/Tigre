#!/bin/bash

echo -e "\nHAGO MAKE \n" 
make 
echo -e "\nGENERO ASSEMBLER DEL TEST $1 \n" 
./tiger ../tests/good/test$1.tig -asm 
echo -e "\nCOMPILO ASSEMBLER DEL TEST $1 \n" 
gcc -g ../tests/TestAssm/prueba.s ../tests/TestAssm/runtime.o
./a.out
gedit ../tests/good/test$1.tig
gedit ../tests/TestAssm/prueba.s



