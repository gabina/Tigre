.section	.rodata

.align 16
.type L0, @object
.size L0, 16
L0:
	.quad 24
	.ascii "Resolviendo 8 reinas\x0a"

.align 16
.type L4, @object
.size L4, 16
L4:
	.quad 14
	.ascii "Itero en i\x0a"

.align 16
.type L6, @object
.size L6, 16
L6:
	.quad 14
	.ascii "Itero en j\x0a"

.align 16
.type L9, @object
.size L9, 16
L9:
	.quad 2
	.ascii " O"

.align 16
.type L10, @object
.size L10, 16
L10:
	.quad 2
	.ascii " ."

.align 16
.type L14, @object
.size L14, 16
L14:
	.quad 4
	.ascii "\x0a"

.align 16
.type L17, @object
.size L17, 16
L17:
	.quad 4
	.ascii "\x0a"

.align 16
.type L22, @object
.size L22, 16
L22:
	.quad 24
	.ascii "Llamo a printboard()\x0a"

.section	.text.startup,"ax",@progbits

.globl L1
.type L1,@function
L1:

	pushq %rbp

	movq %rsp, %rbp

	subq $1024, %rsp

	movq %rbx, %rbx

	movq %r12, %r10

	movq %r10, -48(%rbp)

	movq %r13, %r10

	movq %r10, -40(%rbp)

	movq %r14, %r10

	movq %r10, -32(%rbp)

	movq %r15, %r15

	L52:

	movq %rbp, %r10

	movq $-8, %r11

	addq %r11, %r10

	movq %rdi, (%r10)

	movq $0, %r12

	movq -8(%rbp), %r10

	movq -16(%r10), %r10

	movq %r10, %r10

	subq $1, %r10

	movq %r10, %r10

	movq %r10, -16(%rbp)

	movq -16(%rbp), %r10

	cmpq %r10, %r12

	jle L18

	L3:

	jmp L51

	L18:

	movq $L4, %rdi

	call print

	movq $0, %r13

	movq -8(%rbp), %r10

	movq -16(%r10), %r10

	movq %r10, %r10

	subq $1, %r10

	movq %r10, %r10

	movq %r10, -24(%rbp)

	movq -24(%rbp), %r10

	cmpq %r10, %r13

	jle L15

	L5:

	movq $L17, %rdi

	call print

	movq -16(%rbp), %r10

	cmpq %r10, %r12

	je L3

	L19:

	movq %r12, %r10

	movq $1, %r11

	addq %r11, %r10

	movq %r10, %r12

	jmp L18

	L15:

	movq $L6, %rdi

	call print

	movq -8(%rbp), %r10

	movq -32(%r10), %r10

	movq %r10, %r14

	movq %r12, %r12

	movq %r14, %rdi

	movq %r12, %rsi

	call _checkIndexArray

	movq %r14, %r10

	movq %r12, %r11

	imul $8, %r11

	addq %r11, %r10

	movq (%r10), %r10

	cmpq %r13, %r10

	je L11

	L12:

	movq $L10, %r10

	movq %r10, %r10

	L13:

	movq %r10, %rdi

	call print

	movq $L14, %rdi

	call print

	movq -24(%rbp), %r10

	cmpq %r10, %r13

	je L5

	L16:

	movq %r13, %r10

	movq $1, %r11

	addq %r11, %r10

	movq %r10, %r13

	jmp L15

	L11:

	movq $L9, %r10

	movq %r10, %r10

	jmp L13

	L51:

	movq %rbx, %rbx

	movq -48(%rbp), %r10

	movq %r10, %r12

	movq -40(%rbp), %r10

	movq %r10, %r13

	movq -32(%rbp), %r10

	movq %r10, %r14

	movq %r15, %r15

	movq %rbp, %rsp

	pop %rbp

	ret



.globl L2
.type L2,@function
L2:

	pushq %rbp

	movq %rsp, %rbp

	subq $1024, %rsp

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

	L50:

	movq %rbp, %r10

	movq $-8, %r11

	addq %r11, %r10

	movq %rdi, (%r10)

	movq %rsi, %r12

	movq -8(%rbp), %r10

	movq -16(%r10), %r10

	cmpq %r10, %r12

	je L44

	L45:

	movq $0, %r13

	movq -8(%rbp), %r10

	movq -16(%r10), %r10

	movq %r10, %r10

	subq $1, %r10

	movq %r10, %r10

	movq %r10, -56(%rbp)

	movq -56(%rbp), %r10

	cmpq %r10, %r13

	jle L42

	L23:

	L46:

	jmp L49

	L44:

	movq $L22, %rdi

	call print

	movq %rbp, %r10

	movq $-8, %r11

	addq %r11, %r10

	movq (%r10), %rdi

	call L1

	jmp L46

	L42:

	movq -8(%rbp), %r10

	movq -24(%r10), %r10

	movq %r10, %r14

	movq %r13, %r13

	movq %r14, %rdi

	movq %r13, %rsi

	call _checkIndexArray

	movq $0, %r10

	movq %r14, %r11

	movq %r13, %r14

	imul $8, %r14

	addq %r14, %r11

	movq (%r11), %r11

	cmpq %r10, %r11

	je L30

	L31:

	movq $0, %r10

	L32:

	movq $0, %r11

	cmpq %r11, %r10

	jne L37

	L38:

	movq $0, %r10

	L39:

	movq $0, %r11

	cmpq %r11, %r10

	jne L40

	L41:

	movq -56(%rbp), %r10

	cmpq %r10, %r13

	je L23

	L43:

	movq %r13, %r10

	movq $1, %r11

	addq %r11, %r10

	movq %r10, %r13

	jmp L42

	L30:

	movq $1, %rbx

	movq -8(%rbp), %r10

	movq -40(%r10), %r10

	movq %r10, %r14

	movq %r13, %r10

	addq %r12, %r10

	movq %r10, %r15

	movq %r14, %rdi

	movq %r15, %rsi

	call _checkIndexArray

	movq $0, %r10

	movq %r14, %r11

	movq %r15, %r14

	imul $8, %r14

	addq %r14, %r11

	movq (%r11), %r11

	cmpq %r10, %r11

	je L28

	L29:

	movq $0, %rbx

	L28:

	movq %rbx, %r10

	jmp L32

	L37:

	movq $1, %rbx

	movq -8(%rbp), %r10

	movq -48(%r10), %r10

	movq %r10, %r14

	movq %r13, %r10

	movq $7, %r11

	addq %r11, %r10

	movq %r10, %r10

	subq %r12, %r10

	movq %r10, %r15

	movq %r14, %rdi

	movq %r15, %rsi

	call _checkIndexArray

	movq $0, %r10

	movq %r14, %r11

	movq %r15, %r14

	imul $8, %r14

	addq %r14, %r11

	movq (%r11), %r11

	cmpq %r10, %r11

	je L35

	L36:

	movq $0, %rbx

	L35:

	movq %rbx, %r10

	jmp L39

	L40:

	movq -8(%rbp), %r10

	movq -24(%r10), %r10

	movq %r10, %r14

	movq %r13, %r13

	movq %r14, %rdi

	movq %r13, %rsi

	call _checkIndexArray

	movq %r14, %r10

	movq %r13, %r11

	imul $8, %r11

	addq %r11, %r10

	movq $1, (%r10)

	movq -8(%rbp), %r10

	movq -40(%r10), %r10

	movq %r10, %r14

	movq %r13, %r10

	addq %r12, %r10

	movq %r10, %r15

	movq %r14, %rdi

	movq %r15, %rsi

	call _checkIndexArray

	movq %r14, %r10

	movq %r15, %r11

	imul $8, %r11

	addq %r11, %r10

	movq $1, (%r10)

	movq -8(%rbp), %r10

	movq -48(%r10), %r10

	movq %r10, %r14

	movq %r13, %r10

	movq $7, %r11

	addq %r11, %r10

	movq %r10, %r10

	subq %r12, %r10

	movq %r10, %r15

	movq %r14, %rdi

	movq %r15, %rsi

	call _checkIndexArray

	movq %r14, %r10

	movq %r15, %r11

	imul $8, %r11

	addq %r11, %r10

	movq $1, (%r10)

	movq -8(%rbp), %r10

	movq -32(%r10), %r10

	movq %r10, %r14

	movq %r12, %r12

	movq %r14, %rdi

	movq %r12, %rsi

	call _checkIndexArray

	movq %r14, %r10

	movq %r12, %r11

	imul $8, %r11

	addq %r11, %r10

	movq %r13, (%r10)

	movq %rbp, %r10

	movq $-8, %r11

	addq %r11, %r10

	movq (%r10), %rdi

	movq %r12, %rsi

	movq $1, %r10

	addq %r10, %rsi

	call L2

	movq -8(%rbp), %r10

	movq -24(%r10), %r10

	movq %r10, %r14

	movq %r13, %r13

	movq %r14, %rdi

	movq %r13, %rsi

	call _checkIndexArray

	movq %r14, %r10

	movq %r13, %r11

	imul $8, %r11

	addq %r11, %r10

	movq $0, (%r10)

	movq -8(%rbp), %r10

	movq -40(%r10), %r10

	movq %r10, %r14

	movq %r13, %r10

	addq %r12, %r10

	movq %r10, %r15

	movq %r14, %rdi

	movq %r15, %rsi

	call _checkIndexArray

	movq %r14, %r10

	movq %r15, %r11

	imul $8, %r11

	addq %r11, %r10

	movq $0, (%r10)

	movq -8(%rbp), %r10

	movq -48(%r10), %r10

	movq %r10, %r14

	movq %r13, %r10

	movq $7, %r11

	addq %r11, %r10

	movq %r10, %r10

	subq %r12, %r10

	movq %r10, %r15

	movq %r14, %rdi

	movq %r15, %rsi

	call _checkIndexArray

	movq %r14, %r10

	movq %r15, %r11

	imul $8, %r11

	addq %r11, %r10

	movq $0, (%r10)

	jmp L41

	L49:

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



.globl _tigermain
.type _tigermain,@function
_tigermain:

	pushq %rbp

	movq %rsp, %rbp

	subq $1024, %rsp

	L48:

	movq $L0, %rdi

	call print

	movq $0, %r10

	movq %rbp, %r10

	movq $-16, %r11

	addq %r11, %r10

	movq $8, (%r10)

	movq %rbp, %r10

	movq $-24, %r11

	addq %r11, %r10

	movq %r10, %r12

	movq %rbp, %r10

	movq $-16, %r11

	addq %r11, %r10

	movq (%r10), %rdi

	movq $0, %rsi

	call _initArray

	movq %rax, %r10

	movq %r10, (%r12)

	movq %rbp, %r10

	movq $-32, %r11

	addq %r11, %r10

	movq %r10, %r12

	movq %rbp, %r10

	movq $-16, %r11

	addq %r11, %r10

	movq (%r10), %rdi

	movq $0, %rsi

	call _initArray

	movq %rax, %r10

	movq %r10, (%r12)

	movq %rbp, %r10

	movq $-40, %r11

	addq %r11, %r10

	movq %r10, %r12

	movq -16(%rbp), %r10

	movq %r10, %r10

	movq -16(%rbp), %r11

	addq %r11, %r10

	movq %r10, %rdi

	movq $1, %r10

	subq %r10, %rdi

	movq $0, %rsi

	call _initArray

	movq %rax, %r10

	movq %r10, (%r12)

	movq %rbp, %r10

	movq $-48, %r11

	addq %r11, %r10

	movq %r10, %r12

	movq -16(%rbp), %r10

	movq %r10, %r10

	movq -16(%rbp), %r11

	addq %r11, %r10

	movq %r10, %rdi

	movq $1, %r10

	subq %r10, %rdi

	movq $0, %rsi

	call _initArray

	movq %rax, %r10

	movq %r10, (%r12)

	movq %rbp, %rdi

	movq $0, %rsi

	call L2

	movq $0, %rax

	jmp L47

	L47:

	movq %rbp, %rsp

	pop %rbp

	ret




