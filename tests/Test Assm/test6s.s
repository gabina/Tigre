.globl _tigermain
.type _tigermain,@function

.data
	L0:
		.long 1
		.ascii "a"
	L1:
		.long 1
		.ascii "a"
	L5:
		.long 1
		.ascii "V"
	L7:
		.long 1
		.ascii "F"

_tigermain:
pushq %rbp
movq %rsp, %rbp
subq $1024,%rbp

L12:

# muevo 1 a r8
movq $1, %r8

#Guardo en -8 el valor de r8 que es 1
movq %r8,  -8(%rbp)

# guardo en rdi "a"
movq $L0, %rdi

#guardo en rsi "a"
movq $L1, %rsi

#llamo a stringcmp
CALL _stringCompare

#Guardo el resutlado del compare en r8
movq %rax, %r8

#Guardo el resultado del compare que estaba en r8 en -16
movq %r8,  -16(%rbp)

#Muevo 0 a r8
movq $0, %r8

#Muevo r8 que tiene 0 a -24
movq %r8,  -24(%rbp)

#Muevo el resultado del compare a r8
movq  -16(%rbp), %r8

#Muevo -24 que tiene 0 a r9
movq  -24(%rbp), %r9

#Comparo el resultado del stringcmp con 0
cmpq %r8, %r9

jne L2 #Si 0 es distinto al resultado de la comparacion salta a L2

L3:

movq $0, %r8

movq %r8,  -8(%rbp)


L2:

#Muevo 0 a r8
movq $0, %r8

#muevo 0 a -32
movq %r8,  -32(%rbp)

#Muevo -8 que vale 1 a r8
movq  -8(%rbp), %r8

#muevo -32 que vale 0 a r9
movq  -32(%rbp), %r9

#comparo 1 con 0
cmpq %r8, %r9

jne L8 # como 0 es distinto que 1 va a saltar a L10

L9:

movq $L7, %rdi

call print

L10:

#mueve 0 a rax
movq $0, %rax

#salta a l11
jmp L11

L8:

movq $L5, %rdi

call print

jmp L10

L11:


addq $1024,%rbp
movq %rbp, %rsp
popq %rbp
ret

