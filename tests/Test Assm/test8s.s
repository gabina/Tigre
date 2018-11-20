.section	.rodata

	.align 16
	.type	L4, @object
	.size	L4, 16
	L4:
		.quad 2
		.ascii "OK"
	.align 16
	.type	L6, @object
	.size	L6, 16
	L6:
		.quad 4
		.ascii "nook"

.section	.text.startup,"ax",@progbits

.globl L0
.type L0,@function

L0:
pushq %rbp
movq %rsp, %rbp
subq $1024,%rbp

movq  -8(%rbp), %rax
jmp L12

L12:

addq $1024,%rbp
movq %rbp, %rsp
popq %rbp
ret



.globl _tigermain
.type _tigermain,@function

_tigermain:
pushq %rbp
movq %rsp, %rbp
subq $1024,%rbp

L11:

movq $15, %r8

movq %r8,  -8(%rbp)
movq %rbp, %rdi

movq $2, %rsi

call L0

movq %rax, %r8

movq %r8,  -16(%rbp)
movq $1, %r8

movq %r8,  -24(%rbp)
movq $2, %r8

movq %r8,  -32(%rbp)
movq  -16(%rbp), %r8
movq  -32(%rbp), %r9
cmpq %r8, %r9

je L1

L2:

movq $0, %r8

movq %r8,  -24(%rbp)
L1:

movq $0, %r8

movq %r8,  -40(%rbp)
movq  -24(%rbp), %r8
movq  -40(%rbp), %r9
cmpq %r8, %r9

jne L7

L8:

movq $L6, %rdi

call print

L9:

movq $0, %rax

jmp L10

L7:

movq $L4, %rdi

call print

jmp L9

L10:

addq $1024,%rbp
movq %rbp, %rsp
popq %rbp
ret
