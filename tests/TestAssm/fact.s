	.file	"fact.c"
	.section	.text.unlikely,"ax",@progbits
.LCOLDB3:
	.text
.LHOTB3:
	.p2align 4,,15
	.globl	fact
	.type	fact, @function
fact:
.LFB23:
	.cfi_startproc
	testl	%edi, %edi
	je	.L9
	leal	-4(%rdi), %eax
	leal	-1(%rdi), %edx
	movl	%edi, %esi
	shrl	$2, %eax
	addl	$1, %eax
	cmpl	$8, %edx
	leal	0(,%rax,4), %ecx
	jbe	.L10
	movl	%edi, -12(%rsp)
	xorl	%edx, %edx
	movd	-12(%rsp), %xmm5
	movdqa	.LC0(%rip), %xmm0
	pshufd	$0, %xmm5, %xmm2
	movdqa	.LC2(%rip), %xmm4
	paddd	.LC1(%rip), %xmm2
.L5:
	movdqa	%xmm2, %xmm3
	addl	$1, %edx
	movdqa	%xmm2, %xmm1
	cmpl	%edx, %eax
	paddd	%xmm4, %xmm2
	pmuludq	%xmm0, %xmm3
	psrlq	$32, %xmm0
	psrlq	$32, %xmm1
	pmuludq	%xmm0, %xmm1
	pshufd	$8, %xmm3, %xmm0
	pshufd	$8, %xmm1, %xmm1
	punpckldq	%xmm1, %xmm0
	ja	.L5
	movdqa	%xmm0, %xmm1
	subl	%ecx, %edi
	movdqa	%xmm0, %xmm2
	psrlq	$32, %xmm0
	cmpl	%ecx, %esi
	psrldq	$8, %xmm1
	pmuludq	%xmm1, %xmm2
	psrlq	$32, %xmm1
	pshufd	$8, %xmm2, %xmm2
	pmuludq	%xmm1, %xmm0
	pshufd	$8, %xmm0, %xmm1
	punpckldq	%xmm1, %xmm2
	movdqa	%xmm2, %xmm0
	movdqa	%xmm2, %xmm1
	psrldq	$4, %xmm1
	pmuludq	%xmm1, %xmm0
	movd	%xmm0, %eax
	je	.L2
	leal	-1(%rdi), %edx
.L3:
	imull	%edi, %eax
	testl	%edx, %edx
	je	.L2
	imull	%edx, %eax
	movl	%edi, %edx
	subl	$2, %edx
	je	.L2
	imull	%edx, %eax
	movl	%edi, %edx
	subl	$3, %edx
	je	.L2
	imull	%edx, %eax
	movl	%edi, %edx
	subl	$4, %edx
	je	.L2
	imull	%edx, %eax
	movl	%edi, %edx
	subl	$5, %edx
	je	.L2
	imull	%edx, %eax
	movl	%edi, %edx
	subl	$6, %edx
	je	.L2
	imull	%edx, %eax
	movl	%edi, %edx
	subl	$7, %edx
	je	.L2
	imull	%edx, %eax
	subl	$8, %edi
	movl	%eax, %edx
	imull	%edi, %edx
	testl	%edi, %edi
	cmovne	%edx, %eax
	ret
	.p2align 4,,10
	.p2align 3
.L9:
	movl	$1, %eax
.L2:
	rep ret
	.p2align 4,,10
	.p2align 3
.L10:
	movl	$1, %eax
	jmp	.L3
	.cfi_endproc
.LFE23:
	.size	fact, .-fact
	.section	.text.unlikely
.LCOLDE3:
	.text
.LHOTE3:
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC4:
	.string	"%d"
	.section	.text.unlikely
.LCOLDB5:
	.section	.text.startup,"ax",@progbits
.LHOTB5:
	.p2align 4,,15
	.globl	main
	.type	main, @function
main:
.LFB24:
	.cfi_startproc
	subq	$8, %rsp
	.cfi_def_cfa_offset 16
	movl	$6, %edx
	movl	$.LC4, %esi
	movl	$1, %edi
	xorl	%eax, %eax
	call	__printf_chk
	xorl	%eax, %eax
	addq	$8, %rsp
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE24:
	.size	main, .-main
	.section	.text.unlikely
.LCOLDE5:
	.section	.text.startup
.LHOTE5:
	.section	.rodata.cst16,"aM",@progbits,16
	.align 16
.LC0:
	.long	1
	.long	1
	.long	1
	.long	1
	.align 16
.LC1:
	.long	0
	.long	-1
	.long	-2
	.long	-3
	.align 16
.LC2:
	.long	-4
	.long	-4
	.long	-4
	.long	-4
	.ident	"GCC: (Ubuntu 5.4.0-6ubuntu1~16.04.10) 5.4.0 20160609"
	.section	.note.GNU-stack,"",@progbits
