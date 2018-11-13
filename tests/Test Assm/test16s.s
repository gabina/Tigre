.globl _tigermain
.type _tigermain,@function

.data


_tigermain:
pushq %rbp
movq %rsp, %rbp
subq $1024,%rbp

addq $1024,%rbp
movq %rbp, %rsp
popq %rbp
ret
