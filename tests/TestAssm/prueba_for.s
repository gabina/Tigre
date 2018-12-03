.section	.rodata

.align 16
.type L5, @object
.size L5, 16
L5:
	.quad 2
	.ascii "OK"

.align 16
.type L6, @object
.size L6, 16
L6:
	.quad 4
	.ascii "nook"

.section	.text.startup,"ax",@progbits

.globl _tigermain
.type _tigermain,@function
_tigermain:
	pushq %rbp
	movq %rsp, %rbp
	subq $1024, %rsp


	L11:
	## a = 0 = t0
	movq $0, %r8

	movq %r8,  -8(%rbp)

	## t1 = 0 = i
	movq $0, %r8
	movq %r8,  -16(%rbp)

	## t2 = 2	
	movq $2, %r8
	movq %r8,  -24(%rbp)

	## compara  i con el límite (2)
	movq  -16(%rbp), %r8
	movq  -24(%rbp), %r9
	cmpq %r8, %r9

	jle L1

	L0:

	## if -> comparar el a con el 2
	movq $2, %r8

	movq %r8,  -32(%rbp)
	movq  -8(%rbp), %r8
	movq  -32(%rbp), %r9
	cmpq %r8, %r9

	##si es true, salta a print ok
	je L7

	L8:

	##si es false, imprime nook
	movq $L6, %rdi

	call print

	L9:

	movq  -8(%rbp), %rax
	jmp L10

	L1: ##cuerpo del for

	#t4 = a
	movq  -8(%rbp), %rax
	movq %rax,  -40(%rbp)
	movq $1, %r8

	## a = a+1
	movq %r8,  -48(%rbp)
	movq  -48(%rbp), %r9
	movq  -40(%rbp), %r8
	addq %r9, %r8

	movq %r8,  -40(%rbp)
	movq  -40(%rbp), %rax
	movq %rax,  -8(%rbp)

	## reestablece el límite(t2) y el i (t1)
	movq  -16(%rbp), %r8
	movq  -24(%rbp), %r9
	cmpq %r8, %r9

	je L0

	L2:

	## i = i +1
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

	L7:

	movq $L5, %rdi

	call print

	jmp L9

	L10:




	movq %rbp, %rsp
	popq %rbp
	ret

