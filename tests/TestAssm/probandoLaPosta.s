.section	.rodata

.align 16
.type L8, @object
.size L8, 16
L8:
	.quad 18
	.ascii "Reinas de la noche"

.align 16
.type L9, @object
.size L9, 16
L9:
	.quad 6
	.ascii "Burras"

.section	.text.startup,"ax",@progbits

.globl L0
.type L0,@function
L0:
	pushq %rbp
	movq %rsp, %rbp
	subq $1024, %rsp

	cmpq $0, %rdi
	je L3
	
	subq $1, %rdi
	call L0

	L3:

	movq $1, %rax

	movq %rbp, %rsp
	popq %rbp
	ret
.globl _tigermain
.type _tigermain,@function
_tigermain:
	pushq %rbp
	movq %rsp, %rbp
	subq $1024, %rsp

	movq $2, %rdi

	call L0

	movq $L9, %rdi

	call print

	movq %rbp, %rsp
	popq %rbp
	ret
