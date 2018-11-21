.section	.rodata

	.align 16
	.type	L3, @object
	.size	L3, 16
	L3:
		.quad 8
		.ascii "Correcto"
	.align 16
	.type	L5, @object
	.size	L5, 16
	L5:
		.quad 10
		.ascii "Incorrecto"
.section	.text.startup,"ax",@progbits
.globl _tigermain
.type _tigermain,@function

_tigermain:
pushq %rbp
movq %rsp, %rbp
subq $1024,%rbp

L10:

movq $10, %rdi

movq $5, %rsi

call _initArray

movq %rax, %r8

movq %r8,  -8(%rbp)
movq  -8(%rbp), %rax
movq %rax,  -16(%rbp)
movq $0, %r8

movq %r8,  -24(%rbp)
movq  -16(%rbp), %rdi
movq  -24(%rbp), %rsi
call _checkIndexArray

movq $5, %r8

movq %r8,  -32(%rbp)
movq  -16(%rbp), %rax
movq %rax,  -48(%rbp)
movq  -24(%rbp), %rax
movq %rax,  -56(%rbp)
movq $8, %r8

movq %r8,  -64(%rbp)
movq  -64(%rbp), %r9
movq  -56(%rbp), %r8
imul %r9, %r8

movq %r8,  -56(%rbp)
movq  -56(%rbp), %r9
movq  -48(%rbp), %r8
addq %r9, %r8

movq %r8,  -48(%rbp)
movq  -48(%rbp), %r9
movq (%r9), %r8

movq %r8,  -40(%rbp)
movq  -40(%rbp), %r9
movq  -32(%rbp), %r8
cmpq %r9, %r8

je L6

L7:

movq $L5, %rdi

call print

L8:

movq $0, %rax

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
