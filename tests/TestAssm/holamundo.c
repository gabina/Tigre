#include <stdio.h>
//Compilar con -O3
// Compilar con gcc -S holamundo.c para ver el assembler
long int a=10;
int extra ()
{
	return 0;
}
int main()
{
	printf("Hola mundo %ld",a);
	int r =	extra();
	return 0;
}
