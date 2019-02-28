.section	.rodata

.align 16
.type L32, @object
.size L32, 16
L32:
	.quad 1
	.ascii "0"

.align 16
.type L37, @object
.size L37, 16
L37:
	.quad 1
	.ascii "-"

.align 16
.type L40, @object
.size L40, 16
L40:
	.quad 1
	.ascii "0"

.align 16
.type L49, @object
.size L49, 16
L49:
	.quad 4
	.ascii "\x0a"

.align 16
.type L50, @object
.size L50, 16
L50:
	.quad 1
	.ascii " "

.section	.text.startup,"ax",@progbits

.globl L0
.type L0,@function
L0:

	pushq %rbp

	movq %rsp, %rbp

	subq $80, %rsp

	movq %rbx, %r10

	movq %r10, -48(%rbp)

	movq %r12, %r10

	movq %r10, -40(%rbp)

	movq %r13, %r10

	movq %r10, -32(%rbp)

	movq %r14, %r10

	movq %r10, -24(%rbp)

	movq %r15, %r10

	movq %r10, -16(%rbp)

	L65:

	movq %rbp, %r10

	movq $-8, %r11

	addq %r11, %r10

	movq %rdi, (%r10)

	movq %rsi, %r12

	movq %rdx, %r13

	movq $0, %r10

	cmpq %r10, %r12

	je L8

	L9:

	movq $0, %r10

	cmpq %r10, %r13

	je L5

	L6:

	movq %r12, %r12

	movq $0, %r14

	movq %r12, %rdi

	call _checkNil

	movq %r12, %r10

	movq %r14, %r11

	imul $8, %r11

	addq %r11, %r10

	movq (%r10), %r10

	movq %r10, %r15

	movq -8(%rbp), %r10

	movq %r10, %r14

	movq %r12, %r12

	movq $1, %rbx

	movq %r12, %rdi

	call _checkNil

	movq %r14, %rdi

	movq %r12, %r10

	movq %rbx, %r11

	imul $8, %r11

	addq %r11, %r10

	movq (%r10), %rsi

	movq %r13, %rdx

	call L0

	movq %rax, %r10

	movq $2, %rdi

	movq %r15, %rsi

	movq %r10, %rdx

	movq $0, %rax

	call _allocRecord

	movq %rax, %r10

	L7:

	movq %r10, %r10

	L10:

	movq %r10, %rax

	jmp L64

	L8:

	movq %r13, %r10

	jmp L10

	L5:

	movq %r12, %r10

	jmp L7

	L64:

	movq -48(%rbp), %r10

	movq %r10, %rbx

	movq -40(%rbp), %r10

	movq %r10, %r12

	movq -32(%rbp), %r10

	movq %r10, %r13

	movq -24(%rbp), %r10

	movq %r10, %r14

	movq -16(%rbp), %r10

	movq %r10, %r15

	movq %rbp, %rsp

	pop %rbp

	ret



.globl L11
.type L11,@function
L11:

	pushq %rbp

	movq %rsp, %rbp

	subq $80, %rsp

	movq %rbx, %r10

	movq %r10, -48(%rbp)

	movq %r12, %r10

	movq %r10, -40(%rbp)

	movq %r13, %r10

	movq %r10, -32(%rbp)

	movq %r14, %r10

	movq %r10, -24(%rbp)

	movq %r15, %r10

	movq %r10, -16(%rbp)

	L63:

	movq %rbp, %r10

	movq $-8, %r11

	addq %r11, %r10

	movq %rdi, (%r10)

	movq %rsi, %r12

	movq %rdx, %r13

	movq $0, %r10

	cmpq %r10, %r12

	je L26

	L27:

	movq $0, %r10

	cmpq %r10, %r13

	je L23

	L24:

	movq %r12, %r12

	movq $0, %r14

	movq %r12, %rdi

	call _checkNil

	movq %r12, %r10

	movq %r14, %r11

	imul $8, %r11

	addq %r11, %r10

	movq (%r10), %r10

	movq %r10, %r15

	movq %r13, %r13

	movq $0, %r14

	movq %r13, %rdi

	call _checkNil

	movq %r13, %r10

	movq %r14, %r11

	imul $8, %r11

	addq %r11, %r10

	movq (%r10), %r10

	cmpq %r10, %r15

	jl L20

	L21:

	movq %r13, %r13

	movq $0, %r14

	movq %r13, %rdi

	call _checkNil

	movq %r13, %r10

	movq %r14, %r11

	imul $8, %r11

	addq %r11, %r10

	movq (%r10), %r10

	movq %r10, %rbx

	movq -8(%rbp), %r10

	movq %r10, %r15

	movq %r12, %r14

	movq %r13, %r12

	movq $1, %r13

	movq %r12, %rdi

	call _checkNil

	movq %r15, %rdi

	movq %r14, %rsi

	movq %r12, %r10

	movq %r13, %r11

	imul $8, %r11

	addq %r11, %r10

	movq (%r10), %rdx

	call L11

	movq %rax, %r10

	movq $2, %rdi

	movq %rbx, %rsi

	movq %r10, %rdx

	movq $0, %rax

	call _allocRecord

	movq %rax, %r10

	L22:

	movq %r10, %r10

	L25:

	movq %r10, %r10

	L28:

	movq %r10, %rax

	jmp L62

	L26:

	movq %r13, %r10

	jmp L28

	L23:

	movq %r12, %r10

	jmp L25

	L20:

	movq %r12, %r12

	movq $0, %r14

	movq %r12, %rdi

	call _checkNil

	movq %r12, %r10

	movq %r14, %r11

	imul $8, %r11

	addq %r11, %r10

	movq (%r10), %r10

	movq %r10, %rbx

	movq -8(%rbp), %r10

	movq %r10, %r15

	movq %r12, %r12

	movq $1, %r14

	movq %r12, %rdi

	call _checkNil

	movq %r15, %rdi

	movq %r12, %r10

	movq %r14, %r11

	imul $8, %r11

	addq %r11, %r10

	movq (%r10), %rsi

	movq %r13, %rdx

	call L11

	movq %rax, %r10

	movq $2, %rdi

	movq %rbx, %rsi

	movq %r10, %rdx

	movq $0, %rax

	call _allocRecord

	movq %rax, %r10

	jmp L22

	L62:

	movq -48(%rbp), %r10

	movq %r10, %rbx

	movq -40(%rbp), %r10

	movq %r10, %r12

	movq -32(%rbp), %r10

	movq %r10, %r13

	movq -24(%rbp), %r10

	movq %r10, %r14

	movq -16(%rbp), %r10

	movq %r10, %r15

	movq %rbp, %rsp

	pop %rbp

	ret



.globl L29
.type L29,@function
L29:

	pushq %rbp

	movq %rsp, %rbp

	subq $80, %rsp

	movq %rbx, %rbx

	movq %r12, %r10

	movq %r10, -16(%rbp)

	movq %r13, %r13

	movq %r14, %r14

	movq %r15, %r15

	L61:

	movq %rbp, %r10

	movq $-8, %r11

	addq %r11, %r10

	movq %rdi, (%r10)

	movq %rsi, %r12

	movq $0, %r10

	cmpq %r10, %r12

	jg L33

	L34:

	jmp L60

	L33:

	movq %rbp, %r10

	movq $-8, %r11

	addq %r11, %r10

	movq (%r10), %rdi

	movq $10, %r10

	movq %r12,%rax; cqto; idiv %r10; movq %rax, %rdx; movq %rax, %rsi

	call L29

	movq %r12, %r10

	movq $10, %r11

	movq %r12,%rax; cqto; idiv %r11; movq %rax, %r11

	movq %r11, %r11

	imul $10, %r11

	subq %r11, %r10

	movq %r10, %r12

	movq $L32, %rdi

	call ord

	movq %rax, %r10

	movq %r12, %rdi

	addq %r10, %rdi

	call chr

	movq %rax, %r10

	movq %r10, %rdi

	call print

	jmp L34

	L60:

	movq %rbx, %rbx

	movq -16(%rbp), %r10

	movq %r10, %r12

	movq %r13, %r13

	movq %r14, %r14

	movq %r15, %r15

	movq %rbp, %rsp

	pop %rbp

	ret



.globl L12
.type L12,@function
L12:

	pushq %rbp

	movq %rsp, %rbp

	subq $80, %rsp

	movq %rbx, %rbx

	movq %r12, %r10

	movq %r10, -16(%rbp)

	movq %r13, %r13

	movq %r14, %r14

	movq %r15, %r15

	L59:

	movq %rbp, %r10

	movq $-8, %r11

	addq %r11, %r10

	movq %rdi, (%r10)

	movq %rsi, %r12

	movq $0, %r10

	cmpq %r10, %r12

	jl L44

	L45:

	movq $0, %r10

	cmpq %r10, %r12

	jg L41

	L42:

	movq $L40, %rdi

	call print

	L43:

	L46:

	jmp L58

	L44:

	movq $L37, %rdi

	call print

	movq %rbp, %rdi

	movq $0, %r10

	movq %r10, %rsi

	subq %r12, %rsi

	call L29

	jmp L46

	L41:

	movq %rbp, %rdi

	movq %r12, %rsi

	call L29

	jmp L43

	L58:

	movq %rbx, %rbx

	movq -16(%rbp), %r10

	movq %r10, %r12

	movq %r13, %r13

	movq %r14, %r14

	movq %r15, %r15

	movq %rbp, %rsp

	pop %rbp

	ret



.globl L13
.type L13,@function
L13:

	pushq %rbp

	movq %rsp, %rbp

	subq $80, %rsp

	movq %rbx, %rbx

	movq %r12, %r10

	movq %r10, -40(%rbp)

	movq %r13, %r10

	movq %r10, -32(%rbp)

	movq %r14, %r14

	movq %r15, %r15

	L57:

	movq %rbp, %r10

	movq $-8, %r11

	addq %r11, %r10

	movq %rdi, (%r10)

	movq %rsi, %r12

	movq $0, %r10

	cmpq %r10, %r12

	je L51

	L52:

	movq -8(%rbp), %r10

	movq %r10, %r10

	movq %r10, -24(%rbp)

	movq %r12, %r12

	movq $0, %r13

	movq %r12, %rdi

	call _checkNil

	movq -24(%rbp), %r10

	movq %r10, %rdi

	movq %r12, %r10

	movq %r13, %r11

	imul $8, %r11

	addq %r11, %r10

	movq (%r10), %rsi

	call L12

	movq $L50, %rdi

	call print

	movq -8(%rbp), %r10

	movq %r10, %r10

	movq %r10, -16(%rbp)

	movq %r12, %r12

	movq $1, %r13

	movq %r12, %rdi

	call _checkNil

	movq -16(%rbp), %r10

	movq %r10, %rdi

	movq %r12, %r10

	movq %r13, %r11

	imul $8, %r11

	addq %r11, %r10

	movq (%r10), %rsi

	call L13

	L53:

	jmp L56

	L51:

	movq $L49, %rdi

	call print

	jmp L53

	L56:

	movq %rbx, %rbx

	movq -40(%rbp), %r10

	movq %r10, %r12

	movq -32(%rbp), %r10

	movq %r10, %r13

	movq %r14, %r14

	movq %r15, %r15

	movq %rbp, %rsp

	pop %rbp

	ret



.globl _tigermain
.type _tigermain,@function
_tigermain:

	pushq %rbp

	movq %rsp, %rbp

	subq $80, %rsp

	L55:

	movq $2, %rdi

	movq $144, %rsi

	movq $0, %rdx

	movq $0, %rax

	call _allocRecord

	movq %rax, %r10

	movq $2, %rdi

	movq $71, %rsi

	movq %r10, %rdx

	movq $0, %rax

	call _allocRecord

	movq %rax, %r10

	movq $2, %rdi

	movq $70, %rsi

	movq %r10, %rdx

	movq $0, %rax

	call _allocRecord

	movq %rax, %r12

	movq $2, %rdi

	movq $112, %rsi

	movq $0, %rdx

	movq $0, %rax

	call _allocRecord

	movq %rax, %r10

	movq $2, %rdi

	movq $64, %rsi

	movq %r10, %rdx

	movq $0, %rax

	call _allocRecord

	movq %rax, %r10

	movq $2, %rdi

	movq $72, %rsi

	movq %r10, %rdx

	movq $0, %rax

	call _allocRecord

	movq %rax, %r10

	movq %rbp, %r13

	movq %rbp, %rdi

	movq %r10, %rsi

	movq %r12, %rdx

	call L11

	movq %rax, %r10

	movq %r13, %rdi

	movq %r10, %rsi

	call L13

	movq $0, %rax

	jmp L54

	L54:

	movq %rbp, %rsp

	pop %rbp

	ret




