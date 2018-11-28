.section	.rodata

	.align 16
	.type	L6, @object
	.size	L6, 16
	L6:
		.quad 2
		.ascii "OK"
	.align 16
	.type	L8, @object
	.size	L8, 16
	L8:
		.quad 4
		.ascii "nook"

.section	.text.startup,"ax",@progbits
.globl _tigermain
.type _tigermain,@function

_tigermain:
pushq %rbp
movq %rsp, %rbp
subq $1024,%rbp

L13:

movq $0, %r8

movq %r8,  -8(%rbp)
movq $0, %r8

movq %r8,  -16(%rbp)
movq $100, %r8

movq %r8,  -24(%rbp)
movq  -16(%rbp), %r8
movq  -24(%rbp), %r9
cmpq %r8, %r9

jle L1

L0:

movq $99, %r8

movq %r8,  -32(%rbp)
movq  -8(%rbp), %r8
movq  -32(%rbp), %r9
cmpq %r8, %r9

je L9

L10:

movq $L8, %rdi

call print

L11:

movq  -8(%rbp), %rax
jmp L12

L1:

movq  -8(%rbp), %rax
movq %rax,  -40(%rbp)
movq $1, %r8

movq %r8,  -48(%rbp)
movq  -48(%rbp), %r9
movq  -40(%rbp), %r8
addq %r9, %r8

movq %r8,  -40(%rbp)
movq  -40(%rbp), %rax
movq %rax,  -8(%rbp)
movq  -16(%rbp), %r8
movq  -24(%rbp), %r9
cmpq %r8, %r9

je L0

L2:

movq  -16(%rbp), %rax
movq %rax,  -56(%rbp)
movq $1, %r8

movq %r8,  -64(%rbp)
movq  -64(%rbp), %r9
movq  -56(%rbp), %r8
addq %r9, %r8

movq %r8,  -56(%rbp)
movq  -56(%rbp), %rax
movq %rax,  -16(%rbp)
jmp L1

L9:

movq $L6, %rdi

call print

jmp L11

L12:



addq $1024,%rbp
movq %rbp, %rsp
popq %rbp
ret

