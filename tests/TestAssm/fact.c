#include <stdio.h>
//Compilar con -O3
// Compilar con gcc -S holamundo.c para ver el assembler

int fact (int n)
{
	if  (n == 0) 
		return 1;
	else 
		return (n * fact (n - 1));
}
int main()
{
	printf("%d",fact(3));
	return 0;
}
