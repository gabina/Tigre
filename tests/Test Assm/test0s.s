.globl _tigermain
.type _tigermain,@function

_tigermain:
pushq %rbp
movq %rsp, %rbp
subq $1024,%rbp

movq $4, %r8

movq %r8,  -4(%rbp)
movq  -8(%rbp), %rax
movq %rax,  -12(%rbp)
jmp L0


L0:

addq $1024,%rbp
movq %rbp, %rsp
popq %rbp
ret
