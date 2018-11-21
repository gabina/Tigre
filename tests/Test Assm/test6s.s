.section	.rodata

	.align 16
	.type	L5, @object
	.size	L5, 16
	L5:
		.quad 1
		.ascii "F"
	.align 16
	.type	L3, @object
	.size	L3, 16
	L3:
		.quad 1
		.ascii "V"

.section	.text.startup,"ax",@progbits
.globl _tigermain
.type _tigermain,@function

_tigermain:
pushq %rbp
movq %rsp, %rbp
subq $1024,%rbp

L10:

movq $1, %r8

movq %r8,  -8(%rbp)
jmp L0

L1:

movq $0, %r8

movq %r8,  -8(%rbp)
L0:

movq $0, %r8

movq %r8,  -16(%rbp)
movq  -8(%rbp), %r8
movq  -16(%rbp), %r9
cmpq %r8, %r9

jne L6

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

