.globl _tigermain
.type _tigermain,@function

_tigermain:
pushq %rbp
movq %rsp, %rbp
subq $1024,%rbp
L4:

movq $0, %r8

movq %r8,  -8(%rbp)
movq $0, %r8

movq %r8,  -16(%rbp)
movq $100, %r8

movq %r8,  -24(%rbp)
movq  -32(%rbp), %r8
movq  -40(%rbp), %r9
cmp %r8, %r9

JLE L1

L0:

movq $0, %r8

movq %r8,  -48(%rbp)
jmp L3

L1:

movq  -56(%rbp), %rax
movq %rax,  -64(%rbp)
movq $1, %r8

movq %r8,  -72(%rbp)
movq  -72(%rbp), %r9
addq %r9, %r8

movq %r8,  -64(%rbp)
movq  -64(%rbp), %rax
movq %rax,  -56(%rbp)
movq  -80(%rbp), %r8
movq  -88(%rbp), %r9
cmp %r8, %r9

JE L0

L2:

movq  -96(%rbp), %rax
movq %rax,  -104(%rbp)
movq $1, %r8

movq %r8,  -112(%rbp)
movq  -112(%rbp), %r9
addq %r9, %r8

movq %r8,  -104(%rbp)
movq  -104(%rbp), %rax
movq %rax,  -96(%rbp)
jmp L1

L3:


addq $1024,%rbp
movq %rbp, %rsp
popq %rbp
ret

