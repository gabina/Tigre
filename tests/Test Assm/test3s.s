.section	.rodata

	.align 16
	.type	L0, @object
	.size	L0, 16
	L0:
		.quad 6
		.ascii "Nobody"
	.align 16
	.type	L1, @object
	.size	L1, 16
	L1:
		.quad 8
		.ascii "Somebody"
	.align 16
	.type	L2, @object
	.size	L2, 16
	L2:
		.quad 8
		.ascii "Somebody"
	.align 16
	.type	L5, @object
	.size	L5, 16	
	L6:
		.quad 8
		.ascii "Correcto"	
	.align 16
	.type	L8, @object
	.size	L8, 16
	L8:
		.quad 10
		.ascii "Incorrecto"

.section	.text.startup,"ax",@progbits
.globl _tigermain
.type _tigermain,@function


_tigermain:
pushq %rbp
movq %rsp, %rbp
subq $1024,%rbp

L13:

movq $2, %rdi

movq $L0, %rsi

movq $1000, %rdx

call _allocRecord

movq %rax, %r8

movq %r8,  -8(%rbp)
movq  -8(%rbp), %rax
movq %rax,  -16(%rbp)
movq $0, %r8

movq %r8,  -72(%rbp)
movq  -16(%rbp), %rdi
call _checkNil

movq $L1, %r8

movq %r8,  -112(%rbp)
movq  -16(%rbp), %rax
movq %rax,  -120(%rbp)
movq  -72(%rbp), %rax
movq %rax,  -128(%rbp)
movq $8, %r8

movq %r8,  -24(%rbp)
movq  -24(%rbp), %r8
movq  -128(%rbp), %r9
imul %r8, %r9

movq %r9,  -128(%rbp)
movq  -128(%rbp), %r9
movq  -120(%rbp), %r8
addq %r9, %r8

movq %r8,  -120(%rbp)
movq  -112(%rbp), %r8
movq  -120(%rbp), %r9
movq %r8, (%r9)

movq $1, %r8

movq %r8,  -96(%rbp)
movq  -8(%rbp), %rax
movq %rax,  -80(%rbp)
movq $0, %r8

movq %r8,  -88(%rbp)
movq  -80(%rbp), %rdi
call _checkNil

movq  -80(%rbp), %rax
movq %rax,  -32(%rbp)
movq  -88(%rbp), %rax
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
movq  -32(%rbp), %rdi
movq $L2, %rsi

call _stringCompare

movq %rax, %r8

movq %r8,  -104(%rbp)
movq $0, %r8

movq %r8,  -56(%rbp)
movq  -104(%rbp), %r9
movq  -56(%rbp), %r8
cmpq %r9, %r8

je L3

L4:

movq $0, %r8

movq %r8,  -96(%rbp)
L3:

movq $0, %r8

movq %r8,  -64(%rbp)
movq  -96(%rbp), %r9
movq  -64(%rbp), %r8
cmpq %r9, %r8

jne L9

L10:

movq $L8, %rdi

call print

L11:

movq $0, %rax

jmp L12

L9:

movq $L6, %rdi

call print

jmp L11

L12:



addq $1024,%rbp
movq %rbp, %rsp
popq %rbp
ret

