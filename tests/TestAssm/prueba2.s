.section	.rodata

.align 16
.type L6, @object
.size L6, 16
L6:
	.quad 2
	.ascii " O"

.align 16
.type L7, @object
.size L7, 16
L7:
	.quad 2
	.ascii " ."

.align 16
.type L13, @object
.size L13, 16
L13:
	.quad 4
	.ascii "\x0a"

.align 16
.type L16, @object
.size L16, 16
L16:
	.quad 4
	.ascii "\x0a"

.section	.text.startup,"ax",@progbits

.globl L0
.type L0,@function
L0:

	pushq %rbp

	movq %rsp, %rbp

	subq $1024, %rsp

	movq %rbx, %r8

	movq %r10, %r9

	movq %r11, %rax

	movq %r12, %rcx

	movq %r13, %rdx

	movq %r14, %r10

	movq %r10, -16(%rbp)

	movq %r15, %r15

	L48:

	movq %rbp, %r10

	movq $-8, %r11

	addq %r11, %r10

	movq %rdi, (%r10)

	movq $0, %r10

	movq -8(%rbp), %r11

	movq -16(%r11), %r11

	movq %r11, %r11

	subq $1, %r11

	movq %r11, %rbx

	cmpq %rbx, %r10

	jle L14

	L2:

	movq $L16, %rdi

	call print

	jmp L47

	L14:

	movq $0, %r11

	movq -8(%rbp), %r12

	movq -16(%r12), %r12

	movq %r12, %r12

	subq $1, %r12

	movq %r12, %r14

	cmpq %r14, %r11

	jle L11

	L3:

	movq $L13, %rdi

	call print

	cmpq %rbx, %r10

	je L2

	L15:

	movq %r10, %r10

	movq $1, %r11

	addq %r11, %r10

	movq %r10, %r10

	jmp L14

	L11:

	movq -8(%rbp), %r12

	movq -32(%r12), %r12

	movq %r12, %r12

	movq %r10, %r10

	movq %r12, %rdi

	movq %r10, %rsi

	call _checkIndexArray

	movq %r12, %r12

	movq %r10, %r13

	imul $8, %r13

	addq %r13, %r12

	movq (%r12), %r12

	cmpq %r11, %r12

	je L8

	L9:

	movq $L7, %r12

	movq %r12, %r12

	L10:

	movq %r12, %rdi

	call print

	cmpq %r14, %r11

	je L3

	L12:

	movq %r11, %r11

	movq $1, %r12

	addq %r12, %r11

	movq %r11, %r11

	jmp L11

	L8:

	movq $L6, %r12

	movq %r12, %r12

	jmp L10

	L47:

	movq %r8, %rbx

	movq %r9, %r10

	movq %rax, %r11

	movq %rcx, %r12

	movq %rdx, %r13

	movq -16(%rbp), %r10

	movq %r10, %r14

	movq %r15, %r15

	movq %rbp, %rsp

	pop %rbp

	ret



.globl L1
.type L1,@function
L1:

	pushq %rbp

	movq %rsp, %rbp

	subq $1024, %rsp

	movq %rbx, %r9

	movq %r10, %rax

	movq %r11, %rcx

	movq %r12, %rdx

	movq %r13, %r10

	movq %r10, -32(%rbp)

	movq %r14, %r10

	movq %r10, -24(%rbp)

	movq %r15, %r10

	movq %r10, -16(%rbp)

	L46:

	movq %rbp, %r10

	movq $-8, %r11

	addq %r11, %r10

	movq %rdi, (%r10)

	movq %rsi, %r10

	movq -8(%rbp), %r11

	movq -16(%r11), %r11

	cmpq %r11, %r10

	je L40

	L41:

	movq $0, %r11

	movq -8(%rbp), %r12

	movq -16(%r12), %r12

	movq %r12, %r12

	subq $1, %r12

	movq %r12, %rbx

	cmpq %rbx, %r11

	jle L38

	L19:

	L42:

	jmp L45

	L40:

	movq %rbp, %r10

	movq $-8, %r11

	addq %r11, %r10

	movq (%r10), %rdi

	call L0

	jmp L42

	L38:

	movq -8(%rbp), %r12

	movq -24(%r12), %r12

	movq %r12, %r12

	movq %r11, %r11

	movq %r12, %rdi

	movq %r11, %rsi

	call _checkIndexArray

	movq $0, %r13

	movq %r12, %r12

	movq %r11, %r14

	imul $8, %r14

	addq %r14, %r12

	movq (%r12), %r12

	cmpq %r13, %r12

	je L26

	L27:

	movq $0, %r13

	L28:

	movq $0, %r12

	cmpq %r12, %r13

	jne L33

	L34:

	movq $0, %r13

	L35:

	movq $0, %r12

	cmpq %r12, %r13

	jne L36

	L37:

	cmpq %rbx, %r11

	je L19

	L39:

	movq %r11, %r11

	movq $1, %r12

	addq %r12, %r11

	movq %r11, %r11

	jmp L38

	L26:

	movq $1, %r14

	movq -8(%rbp), %r12

	movq -40(%r12), %r12

	movq %r12, %r12

	movq %r11, %r13

	addq %r10, %r13

	movq %r13, %r13

	movq %r12, %rdi

	movq %r13, %rsi

	call _checkIndexArray

	movq $0, %r15

	movq %r12, %r12

	movq %r13, %r13

	imul $8, %r13

	addq %r13, %r12

	movq (%r12), %r12

	cmpq %r15, %r12

	je L24

	L25:

	movq $0, %r14

	L24:

	movq %r14, %r13

	jmp L28

	L33:

	movq $1, %r8

	movq -8(%rbp), %r12

	movq -48(%r12), %r12

	movq %r12, %r14

	movq %r11, %r12

	movq $7, %r13

	addq %r13, %r12

	movq %r12, %r12

	subq %r10, %r12

	movq %r12, %r15

	movq %r14, %rdi

	movq %r15, %rsi

	call _checkIndexArray

	movq $0, %r12

	movq %r14, %r13

	movq %r15, %r14

	imul $8, %r14

	addq %r14, %r13

	movq (%r13), %r13

	cmpq %r12, %r13

	je L31

	L32:

	movq $0, %r8

	L31:

	movq %r8, %r13

	jmp L35

	L36:

	movq -8(%rbp), %r12

	movq -24(%r12), %r12

	movq %r12, %r12

	movq %r11, %r11

	movq %r12, %rdi

	movq %r11, %rsi

	call _checkIndexArray

	movq %r12, %r12

	movq %r11, %r13

	imul $8, %r13

	addq %r13, %r12

	movq $1, (%r12)

	movq -8(%rbp), %r12

	movq -40(%r12), %r12

	movq %r12, %r13

	movq %r11, %r12

	addq %r10, %r12

	movq %r12, %r14

	movq %r13, %rdi

	movq %r14, %rsi

	call _checkIndexArray

	movq %r13, %r12

	movq %r14, %r13

	imul $8, %r13

	addq %r13, %r12

	movq $1, (%r12)

	movq -8(%rbp), %r12

	movq -48(%r12), %r12

	movq %r12, %r14

	movq %r11, %r12

	movq $7, %r13

	addq %r13, %r12

	movq %r12, %r12

	subq %r10, %r12

	movq %r12, %r13

	movq %r14, %rdi

	movq %r13, %rsi

	call _checkIndexArray

	movq %r14, %r12

	movq %r13, %r13

	imul $8, %r13

	addq %r13, %r12

	movq $1, (%r12)

	movq -8(%rbp), %r12

	movq -32(%r12), %r12

	movq %r12, %r12

	movq %r10, %r10

	movq %r12, %rdi

	movq %r10, %rsi

	call _checkIndexArray

	movq %r12, %r12

	movq %r10, %r13

	imul $8, %r13

	addq %r13, %r12

	movq %r11, (%r12)

	movq %rbp, %r12

	movq $-8, %r13

	addq %r13, %r12

	movq (%r12), %rdi

	movq %r10, %rsi

	movq $1, %r12

	addq %r12, %rsi

	call L1

	movq -8(%rbp), %r12

	movq -24(%r12), %r12

	movq %r12, %r12

	movq %r11, %r11

	movq %r12, %rdi

	movq %r11, %rsi

	call _checkIndexArray

	movq %r12, %r12

	movq %r11, %r13

	imul $8, %r13

	addq %r13, %r12

	movq $0, (%r12)

	movq -8(%rbp), %r12

	movq -40(%r12), %r12

	movq %r12, %r13

	movq %r11, %r12

	addq %r10, %r12

	movq %r12, %r14

	movq %r13, %rdi

	movq %r14, %rsi

	call _checkIndexArray

	movq %r13, %r12

	movq %r14, %r13

	imul $8, %r13

	addq %r13, %r12

	movq $0, (%r12)

	movq -8(%rbp), %r12

	movq -48(%r12), %r12

	movq %r12, %r14

	movq %r11, %r12

	movq $7, %r13

	addq %r13, %r12

	movq %r12, %r12

	subq %r10, %r12

	movq %r12, %r13

	movq %r14, %rdi

	movq %r13, %rsi

	call _checkIndexArray

	movq %r14, %r12

	movq %r13, %r13

	imul $8, %r13

	addq %r13, %r12

	movq $0, (%r12)

	jmp L37

	L45:

	movq %r9, %rbx

	movq %rax, %r10

	movq %rcx, %r11

	movq %rdx, %r12

	movq -32(%rbp), %r10

	movq %r10, %r13

	movq -24(%rbp), %r10

	movq %r10, %r14

	movq -16(%rbp), %r10

	movq %r10, %r15

	movq %rbp, %rsp

	pop %rbp

	ret



.globl _tigermain
.type _tigermain,@function
_tigermain:

	pushq %rbp

	movq %rsp, %rbp

	subq $1024, %rsp

	L44:

	movq %rbp, %r10

	movq $-16, %r11

	addq %r11, %r10

	movq $8, (%r10)

	movq %rbp, %r10

	movq $-24, %r11

	addq %r11, %r10

	movq %r10, %r11

	movq %rbp, %r10

	movq $-16, %r12

	addq %r12, %r10

	movq (%r10), %rdi

	movq $0, %rsi

	call _initArray

	movq %rax, %r10

	movq %r10, (%r11)

	movq %rbp, %r10

	movq $-32, %r11

	addq %r11, %r10

	movq %r10, %r11

	movq %rbp, %r10

	movq $-16, %r12

	addq %r12, %r10

	movq (%r10), %rdi

	movq $0, %rsi

	call _initArray

	movq %rax, %r10

	movq %r10, (%r11)

	movq %rbp, %r10

	movq $-40, %r11

	addq %r11, %r10

	movq %r10, %r11

	movq -16(%rbp), %r10

	movq %r10, %r10

	movq -16(%rbp), %r12

	addq %r12, %r10

	movq %r10, %rdi

	movq $1, %r10

	subq %r10, %rdi

	movq $0, %rsi

	call _initArray

	movq %rax, %r10

	movq %r10, (%r11)

	movq %rbp, %r10

	movq $-48, %r11

	addq %r11, %r10

	movq %r10, %r11

	movq -16(%rbp), %r10

	movq %r10, %r10

	movq -16(%rbp), %r12

	addq %r12, %r10

	movq %r10, %rdi

	movq $1, %r10

	subq %r10, %rdi

	movq $0, %rsi

	call _initArray

	movq %rax, %r10

	movq %r10, (%r11)

	movq %rbp, %rdi

	movq $0, %rsi

	call L1

	movq $0, %rax

	jmp L43

	L43:

	movq %rbp, %rsp

	pop %rbp

	ret




