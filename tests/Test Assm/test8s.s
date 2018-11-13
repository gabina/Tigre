.globl _tigermain
.type _tigermain,@function

.data


_tigermain:
pushq %rbp
movq %rsp, %rbp
subq $1024,%rbp

L4:

movq  -8(%rbp), %rax
jmp L3

L3:

L2:

movq $15, %r8

movq %r8,  -8(%rbp)
movq %rbp, %rdi

movq $2, %rsi

CALL L0

movq %rax, %rax

jmp L1

L1:


addq $1024,%rbp
movq %rbp, %rsp
popq %rbp
ret
