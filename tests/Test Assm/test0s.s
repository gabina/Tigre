.section	.rodata

	.align 16
	.type	L5, @object
	.size	L5, 16
	L5:
		.quad 10
		.ascii "Incorrecto"
	.align 16
	.type	L3, @object
	.size	L3, 16
	L3:
		.quad 8
		.ascii "Correcto"


.section	.text.startup,"ax",@progbits
.globl _tigermain
.type _tigermain,@function

_tigermain:
pushq %rbp
movq %rsp, %rbp
subq $1024,%rbp

L10:

#CAMBIAR ESTE VALOR PARA VARIAR EL RESULTADO		
movq $4, %r8

movq %r8,  -8(%rbp)
movq $1, %r8

movq %r8,  -16(%rbp)
movq $4, %r8

movq %r8,  -24(%rbp)
movq  -8(%rbp), %r8
movq  -24(%rbp), %r9
cmpq %r8, %r9

je L0

L1:

movq $0, %r8

movq %r8,  -16(%rbp)
L0:

movq $0, %r8

movq %r8,  -32(%rbp)
movq  -16(%rbp), %r8
movq  -32(%rbp), %r9
cmpq %r8, %r9

jne L6

L7:

movq $L5, %rdi

call print

L8:

movq  -8(%rbp), %rax
jmp L9

L6:

movq $L3, %rdi

call print

jmp L8

L9:

addq $1024,%rbp
movq %rbp, %rsp
popq %rbp
ret
