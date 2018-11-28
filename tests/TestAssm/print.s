.section	.rodata.str1.1,"aMS",@progbits,1
.align 64
	L0:
		.quad 3
		.ascii "alo"

.section	.text.startup,"ax",@progbits
.globl _tigermain
.type _tigermain,@function

_tigermain:
pushq %rbp
movq %rsp, %rbp
subq $1024,%rbp

movq $L0, %rdi
call print

addq $1024,%rbp
movq %rbp, %rsp
popq %rbp
ret
