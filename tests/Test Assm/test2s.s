.globl _tigermain
.type _tigermain,@function

_tigermain:
pushq %rbp
movq %rsp, %rbp
subq $1024,%rbp

L1:

movq $10, %rdi

movq $5, %rdi

CALL _initArray

movq %r8, %rax

movq %r8,  -4(%rbp)
movq $0, %r8

movq %r8,  -8(%rbp)
jmp L0

L0:

addq $1024,%rbp
movq %rbp, %rsp
popq %rbp
ret
