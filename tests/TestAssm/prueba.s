.section	.rodata

.align 16
.type L0, @object
.size L0, 16
L0:
	.quad 6
	.ascii "Nobody"

.align 16
.type L1, @object
.size L1, 16
L1:s
	.quad 8
	.ascii "Somebody"

.align 16
.type L2, @object
.size L2, 16
L2:
	.quad 8
	.ascii "Somebody"

.align 16
.type L5, @object
.size L5, 16
L5:
	.quad 8
	.ascii "Correcto"

.align 16
.type L6, @object
.size L6, 16
L6:
	.quad 10
	.ascii "Incorrecto"

.section	.text.startup,"ax",@progbits

.globl _tigermain
.type _tigermain,@function
_tigermain:
	pushq %rbp
	movq %rsp, %rbp
	subq $1024, %rsp


	L11:

	movq $2, %rdi

	movq $L0, %rsi

	movq $1000, %rdx

	call _allocRecord

	movq %rax, %r8

	movq %r8,  -8(%rbp)
	movq  -8(%rbp), %rax
	movq %rax,  -16(%rbp)
	movq $0, %r8

	movq %r8,  -64(%rbp)
	movq  -16(%rbp), %rdi
	call _checkNil

	movq $L1, %r8

	movq %r8,  -96(%rbp)
	movq  -16(%rbp), %rax
	movq %rax,  -104(%rbp)
	movq  -64(%rbp), %rax
	movq %rax,  -112(%rbp)
	movq $8, %r8

	movq %r8,  -24(%rbp)
	movq  -24(%rbp), %r8
	movq  -112(%rbp), %r9
	imul %r8, %r9

	movq %r9,  -112(%rbp)
	movq  -112(%rbp), %r9
	movq  -104(%rbp), %r8
	addq %r9, %r8

	movq %r8,  -104(%rbp)
	movq  -96(%rbp), %r8
	movq  -104(%rbp), %r9
	movq %r8, (%r9)

	movq  -8(%rbp), %rax
	movq %rax,  -72(%rbp)
	movq $0, %r8

	movq %r8,  -80(%rbp)
	movq  -72(%rbp), %rdi
	call _checkNil

	movq  -72(%rbp), %rax
	movq %rax,  -32(%rbp)
	movq  -80(%rbp), %rax
	movq %rax,  -40(%rbp)
	movq $8, %r8

	movq %r8,  -48(%rbp)
	movq  -48(%rbp), %r9
	movq  -40(%rbp), %r8
	imul %r9, %r8

	movq %r8,  -40(%rbp)
	movq  -40(%rbp), %r9
	movq  -32(%rbp), %r8
	addq %r9, %r8

	movq %r8,  -32(%rbp)
	movq  -32(%rbp), %r8
	movq (%r8), %rdi

	movq $L2, %rsi

	call _stringCompare

	movq %rax, %r8

	movq %r8,  -88(%rbp)
	movq $0, %r8

	movq %r8,  -56(%rbp)
	movq  -88(%rbp), %r9
	movq  -56(%rbp), %r8
	cmpq %r9, %r8

	je L7

	L8:

	movq $L6, %rdi

	call print

	L9:

	movq $0, %rax

	jmp L10

	L7:

	movq $L5, %rdi

	call print

	jmp L9

	L10:




	movq %rbp, %rsp
	popq %rbp
	ret

