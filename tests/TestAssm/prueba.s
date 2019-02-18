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

	movq %rbx, %rbx

	movq %r12, %r12

	movq %r13, %r13

	movq %r14, %r14

	movq %r15, %r15

	L11:

	movq %rbp, %r10

	movq $-8, %r11

	addq %r11, %r10

	movq %rdi, (%r10)

	movq %rsi, %r10

	movq %rdx, %r10

	movq %rcx, %r10

	movq %r8, %r10

	movq %r9, %r10

	movq 16(%rbp), %r10

	movq %r10, %r10

	movq 24(%rbp), %r10

	movq %r10, %r10

	movq 32(%rbp), %r10

	movq %r10, %r11

	movq 40(%rbp), %r10

	movq %r10, %r10

	movq %r11, %rax

	jmp L10

	L10:

	movq %rbx, %rbx

	movq %r12, %r12

	movq %r13, %r13

	movq %r14, %r14

	movq %r15, %r15

	movq %rbp, %rsp

	pop %rbp

	ret



.globl _tigermain
.type _tigermain,@function
_tigermain:

	pushq %rbp

	movq %rsp, %rbp

	subq $1024, %rsp

	L9:

	movq $15, %r10

	movq %rbp, %rdi

	movq $2, %rsi

	movq $3, %rdx

	movq $4, %rcx

	movq $5, %r8

	movq $6, %r9

	pushq $10

	pushq $9

	pushq $8

	pushq $7

	call L0

	movq %rax, %r10

	movq $9, %r11

	cmpq %r11, %r10

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

	pop %rbp

	ret




