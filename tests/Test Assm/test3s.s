.globl _tigermain
.type _tigermain,@function

.data
	L0:
		.long 6
		.ascii "Nobody"
	L1:
		.long 8
		.ascii "Somebody"

_tigermain:
pushq %rbp
movq %rsp, %rbp
subq $1024,%rbp

L3:

movq $2, %rdi

movq $L0, %rsi

movq $1000, %rdx

CALL _allocRecord

movq %rax, %r8

movq %r8,  -8(%rbp)
movq  -8(%rbp), %rax
movq %rax,  -16(%rbp)
movq $0, %r8

movq %r8,  -32(%rbp)
movq  -16(%rbp), %rdi
call _checkNil

movq $L1, %r8

movq %r8,  -40(%rbp)
movq  -16(%rbp), %rax
movq %rax,  -48(%rbp)
movq  -32(%rbp), %rax
movq %rax,  -56(%rbp)
movq $8, %r8

movq %r8,  -24(%rbp)
movq  -24(%rbp), %r8
movq  -56(%rbp), %r9
imul %r8, %r9

movq %r9,  -56(%rbp)
movq  -56(%rbp), %r9
movq  -48(%rbp), %r8
addq %r9, %r8

movq %r8,  -48(%rbp)
movq  -40(%rbp), %r8
movq  -48(%rbp), %r9
movq %r8, (%r9)

movq $0, %rax

jmp L2

L2:

addq $1024,%rbp
movq %rbp, %rsp
popq %rbp
ret

