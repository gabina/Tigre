.section	.rodata

	.align 16
	.type	L0, @object
	.size	L0, 16
	L0:
		.quad 1
		.ascii "a"
	.align 16
	.type	L1, @object
	.size	L1, 16
	L1:
		.quad 1
		.ascii "a"
	.align 16
	.type	L5, @object
	.size	L5, 16
	L5:
		.quad 1
		.ascii "V"
	.align 16
	.type	L7, @object
	.size	L7, 16
	L7:
		.quad 1
		.ascii "F"

.section	.text.startup,"ax",@progbits
.globl _tigermain
.type _tigermain,@function

_tigermain:
pushq %rbp
movq %rsp, %rbp
subq $1024,%rbp

L12:

movq $1, %r8

movq %r8,  -8(%rbp)
movq $L0, %rdi

movq $L1, %rsi

call _stringCompare

movq %rax, %r8

movq %r8,  -16(%rbp)
movq $0, %r8

movq %r8,  -24(%rbp)
movq  -16(%rbp), %r8
movq  -24(%rbp), %r9
cmpq %r8, %r9

je L2

L3:

movq $0, %r8

movq %r8,  -8(%rbp)
L2:

movq $0, %r8

movq %r8,  -32(%rbp)
movq  -8(%rbp), %r8
movq  -32(%rbp), %r9
cmpq %r8, %r9

jne L8

L9:

movq $L7, %rdi

call print

L10:

movq $0, %rax

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
