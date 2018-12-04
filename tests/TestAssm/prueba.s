.section	.rodata

.align 16
.type L3, @object
.size L3, 16
L3:
	.quad 2
	.ascii "OK"

.align 16
.type L4, @object
.size L4, 16
L4:
	.quad 4
	.ascii "NOOK"

.section	.text.startup,"ax",@progbits

.globl L0
.type L0,@function
L0:
	pushq %rbp
	movq %rsp, %rbp
	subq $1024, %rsp


	L11:

	movq %rbp,  -16(%rbp)
	movq $0, %r8

	movq %r8,  -24(%rbp)
	movq  -24(%rbp), %r9
	movq  -16(%rbp), %r8
	addq %r9, %r8

	movq %r8,  -16(%rbp)
	movq  -16(%rbp), %r8
	movq %rdi, (%r8)

	movq %rsi,  -8(%rbp)
	movq  -8(%rbp), %rax
	jmp L10

	L10:




	movq %rbp, %rsp
	popq %rbp
	ret
.globl _tigermain
.type _tigermain,@function
_tigermain:
	pushq %rbp
	movq %rsp, %rbp
	subq $1024, %rsp


	L9:

	movq $15, %r8

	movq %r8,  -8(%rbp)
	movq %rbp, %rdi

	movq $2, %rsi

	movq $3, %rdx

	movq $4, %rcx

	movq $5, %r8

	movq $6, %r9

	pushq $7

	pushq $8

	pushq $9

	pushq $10

	call L0

	movq %rax, %r8

	movq %r8,  -16(%rbp)
	movq $2, %r8

	movq %r8,  -24(%rbp)
	movq  -24(%rbp), %r9
	movq  -16(%rbp), %r8
	cmpq %r9, %r8

	je L5

	L6:

	movq $L4, %rdi

	call print

	L7:

	movq $0, %rax

	jmp L8

	L5:

	movq $L3, %rdi

	call print

	jmp L7

	L8:




	movq %rbp, %rsp
	popq %rbp
	ret

