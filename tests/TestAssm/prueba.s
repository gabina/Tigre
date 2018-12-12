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


	L48:

	movq %rbp,  -40(%rbp)
	movq $0, %r8

	movq %r8,  -48(%rbp)
	movq  -48(%rbp), %r9
	movq  -40(%rbp), %r8
	addq %r9, %r8

	movq %r8,  -40(%rbp)
	movq  -40(%rbp), %r8
	#movq %rdi, (%r8)

	movq $0, %r8

	movq %r8,  -8(%rbp)
	movq 0(%rbp), %r8

	movq %r8,  -72(%rbp)
	movq  -72(%rbp), %r9
	movq  -8(%r9), %r8

	movq %r8,  -64(%rbp)
	movq  -64(%rbp), %r9
	movq %r9, %r8

	movq %r8,  -56(%rbp)
	movq  -56(%rbp), %r8
	subq $1, %r8

	movq %r8,  -56(%rbp)
	movq  -56(%rbp), %rax
	movq %rax,  -208(%rbp)
	movq  -208(%rbp), %r9
	movq  -8(%rbp), %r8
	cmpq %r9, %r8

	jle L14

	L2:

	movq $L16, %rdi

	call print

	jmp L47

	L14:

	movq $0, %r8

	movq %r8,  -16(%rbp)
	movq 0(%rbp), %r8

	movq %r8,  -96(%rbp)
	movq  -96(%rbp), %r9
	movq  -8(%r9), %r8

	movq %r8,  -88(%rbp)
	movq  -88(%rbp), %r9
	movq %r9, %r8

	movq %r8,  -80(%rbp)
	movq  -80(%rbp), %r8
	subq $1, %r8

	movq %r8,  -80(%rbp)
	movq  -80(%rbp), %rax
	movq %rax,  -200(%rbp)
	movq  -200(%rbp), %r9
	movq  -16(%rbp), %r8
	cmpq %r9, %r8

	jle L11

	L3:

	movq $L13, %rdi

	call print

	movq  -208(%rbp), %r9
	movq  -8(%rbp), %r8
	cmpq %r9, %r8

	je L2

	L15:

	movq  -8(%rbp), %rax
	movq %rax,  -104(%rbp)
	movq $1, %r8

	movq %r8,  -112(%rbp)
	movq  -112(%rbp), %r9
	movq  -104(%rbp), %r8
	addq %r9, %r8

	movq %r8,  -104(%rbp)
	movq  -104(%rbp), %rax
	movq %rax,  -8(%rbp)
	jmp L14

	L11:

	movq 0(%rbp), %r8

	movq %r8,  -128(%rbp)
	movq  -128(%rbp), %r9
	movq  -24(%r9), %r8

	movq %r8,  -120(%rbp)
	movq  -120(%rbp), %rax
	movq %rax,  -24(%rbp)
	movq  -8(%rbp), %rax
	movq %rax,  -32(%rbp)
	movq  -24(%rbp), %rdi
	movq  -32(%rbp), %rsi
	call _checkIndexArray

	movq  -24(%rbp), %rax
	movq %rax,  -152(%rbp)
	movq  -32(%rbp), %r8
	movq %r8, %r9

	movq %r9,  -160(%rbp)
	movq  -160(%rbp), %r8
	imul $8, %r8

	movq %r8,  -160(%rbp)
	movq  -160(%rbp), %r9
	movq  -152(%rbp), %r8
	addq %r9, %r8

	movq %r8,  -152(%rbp)
	movq  -152(%rbp), %r9
	movq (%r9), %r8

	movq %r8,  -136(%rbp)
	movq  -16(%rbp), %r8
	movq  -136(%rbp), %r9
	cmpq %r8, %r9

	je L8

	L9:

	movq $L7, %r8

	movq %r8,  -168(%rbp)
	movq  -168(%rbp), %rax
	movq %rax,  -144(%rbp)
	L10:

	movq  -144(%rbp), %rdi
	call print

	movq  -200(%rbp), %r9
	movq  -16(%rbp), %r8
	cmpq %r9, %r8

	je L3

	L12:

	movq  -16(%rbp), %rax
	movq %rax,  -176(%rbp)
	movq $1, %r8

	movq %r8,  -184(%rbp)
	movq  -184(%rbp), %r9
	movq  -176(%rbp), %r8
	addq %r9, %r8

	movq %r8,  -176(%rbp)
	movq  -176(%rbp), %rax
	movq %rax,  -16(%rbp)
	jmp L11

	L8:

	movq $L6, %r8

	movq %r8,  -192(%rbp)
	movq  -192(%rbp), %rax
	movq %rax,  -144(%rbp)
	jmp L10

	L47:




	movq %rbp, %rsp
	popq %rbp
	ret
.globl L1
.type L1,@function
L1:
	pushq %rbp
	movq %rsp, %rbp
	subq $1024, %rsp


	L46:

	movq %rbp,  -544(%rbp)
	movq $0, %r8

	movq %r8,  -552(%rbp)
	movq  -552(%rbp), %r9
	movq  -544(%rbp), %r8
	addq %r9, %r8

	movq %r8,  -544(%rbp)
	movq  -544(%rbp), %r8
	#movq %rdi, (%r8)

	movq %rsi,  -8(%rbp)
	movq 0(%rbp), %r8

	movq %r8,  -568(%rbp)
	movq  -568(%rbp), %r9
	movq  -8(%r9), %r8

	movq %r8,  -560(%rbp)
	movq  -560(%rbp), %r9
	movq  -8(%rbp), %r8
	cmpq %r9, %r8

	je L40

	L41:

	movq $0, %r8

	movq %r8,  -16(%rbp)
	movq 0(%rbp), %r8

	movq %r8,  -592(%rbp)
	movq  -592(%rbp), %r9
	movq  -8(%r9), %r8

	movq %r8,  -584(%rbp)
	movq  -584(%rbp), %r9
	movq %r9, %r8

	movq %r8,  -576(%rbp)
	movq  -576(%rbp), %r8
	subq $1, %r8

	movq %r8,  -576(%rbp)
	movq  -576(%rbp), %rax
	movq %rax,  -536(%rbp)
	movq  -536(%rbp), %r9
	movq  -16(%rbp), %r8
	cmpq %r9, %r8

	jle L38

	L19:

	L42:

	jmp L45

	L40:

	movq %rbp,  -600(%rbp)
	movq $0, %r8

	movq %r8,  -608(%rbp)
	movq  -608(%rbp), %r9
	movq  -600(%rbp), %r8
	addq %r9, %r8

	movq %r8,  -600(%rbp)
	movq  -600(%rbp), %r8
	movq (%r8), %rdi

	call L0

	jmp L42

	L38:

	movq 0(%rbp), %r8

	movq %r8,  -624(%rbp)
	movq  -624(%rbp), %r9
	movq  -16(%r9), %r8

	movq %r8,  -616(%rbp)
	movq  -616(%rbp), %rax
	movq %rax,  -104(%rbp)
	movq  -16(%rbp), %rax
	movq %rax,  -192(%rbp)
	movq  -104(%rbp), %rdi
	movq  -192(%rbp), %rsi
	call _checkIndexArray

	movq $0, %r8

	movq %r8,  -632(%rbp)
	movq  -104(%rbp), %rax
	movq %rax,  -648(%rbp)
	movq  -192(%rbp), %r8
	movq %r8, %r9

	movq %r9,  -656(%rbp)
	movq  -656(%rbp), %r8
	imul $8, %r8

	movq %r8,  -656(%rbp)
	movq  -656(%rbp), %r9
	movq  -648(%rbp), %r8
	addq %r9, %r8

	movq %r8,  -648(%rbp)
	movq  -648(%rbp), %r9
	movq (%r9), %r8

	movq %r8,  -640(%rbp)
	movq  -632(%rbp), %r8
	movq  -640(%rbp), %r9
	cmpq %r8, %r9

	je L26

	L27:

	movq $0, %r8

	movq %r8,  -384(%rbp)
	L28:

	movq $0, %r8

	movq %r8,  -664(%rbp)
	movq  -664(%rbp), %r9
	movq  -384(%rbp), %r8
	cmpq %r9, %r8

	jne L33

	L34:

	movq $0, %r8

	movq %r8,  -416(%rbp)
	L35:

	movq $0, %r8

	movq %r8,  -672(%rbp)
	movq  -672(%rbp), %r9
	movq  -416(%rbp), %r8
	cmpq %r9, %r8

	jne L36

	L37:

	movq  -536(%rbp), %r9
	movq  -16(%rbp), %r8
	cmpq %r9, %r8

	je L19

	L39:

	movq  -16(%rbp), %rax
	movq %rax,  -680(%rbp)
	movq $1, %r8

	movq %r8,  -688(%rbp)
	movq  -688(%rbp), %r9
	movq  -680(%rbp), %r8
	addq %r9, %r8

	movq %r8,  -680(%rbp)
	movq  -680(%rbp), %rax
	movq %rax,  -16(%rbp)
	jmp L38

	L26:

	movq $1, %r8

	movq %r8,  -376(%rbp)
	movq 0(%rbp), %r8

	movq %r8,  -704(%rbp)
	movq  -704(%rbp), %r9
	movq  -32(%r9), %r8

	movq %r8,  -696(%rbp)
	movq  -696(%rbp), %rax
	movq %rax,  -360(%rbp)
	movq  -16(%rbp), %rax
	movq %rax,  -712(%rbp)
	movq  -8(%rbp), %r8
	movq  -712(%rbp), %r9
	addq %r8, %r9

	movq %r9,  -712(%rbp)
	movq  -712(%rbp), %rax
	movq %rax,  -368(%rbp)
	movq  -360(%rbp), %rdi
	movq  -368(%rbp), %rsi
	call _checkIndexArray

	movq $0, %r8

	movq %r8,  -720(%rbp)
	movq  -360(%rbp), %rax
	movq %rax,  -736(%rbp)
	movq  -368(%rbp), %r8
	movq %r8, %r9

	movq %r9,  -744(%rbp)
	movq  -744(%rbp), %r8
	imul $8, %r8

	movq %r8,  -744(%rbp)
	movq  -744(%rbp), %r9
	movq  -736(%rbp), %r8
	addq %r9, %r8

	movq %r8,  -736(%rbp)
	movq  -736(%rbp), %r9
	movq (%r9), %r8

	movq %r8,  -728(%rbp)
	movq  -720(%rbp), %r8
	movq  -728(%rbp), %r9
	cmpq %r8, %r9

	je L24

	L25:

	movq $0, %r8

	movq %r8,  -376(%rbp)
	L24:

	movq  -376(%rbp), %rax
	movq %rax,  -384(%rbp)
	jmp L28

	L33:

	movq $1, %r8

	movq %r8,  -408(%rbp)
	movq 0(%rbp), %r8

	movq %r8,  -760(%rbp)
	movq  -760(%rbp), %r9
	movq  -40(%r9), %r8

	movq %r8,  -752(%rbp)
	movq  -752(%rbp), %rax
	movq %rax,  -392(%rbp)
	movq  -16(%rbp), %rax
	movq %rax,  -776(%rbp)
	movq $7, %r8

	movq %r8,  -784(%rbp)
	movq  -784(%rbp), %r9
	movq  -776(%rbp), %r8
	addq %r9, %r8

	movq %r8,  -776(%rbp)
	movq  -776(%rbp), %r9
	movq %r9, %r8

	movq %r8,  -768(%rbp)
	movq  -8(%rbp), %r8
	movq  -768(%rbp), %r9
	subq %r8, %r9

	movq %r9,  -768(%rbp)
	movq  -768(%rbp), %rax
	movq %rax,  -400(%rbp)
	movq  -392(%rbp), %rdi
	movq  -400(%rbp), %rsi
	call _checkIndexArray

	movq $0, %r8

	movq %r8,  -792(%rbp)
	movq  -392(%rbp), %rax
	movq %rax,  -808(%rbp)
	movq  -400(%rbp), %r9
	movq %r9, %r8

	movq %r8,  -24(%rbp)
	movq  -24(%rbp), %r8
	imul $8, %r8

	movq %r8,  -24(%rbp)
	movq  -24(%rbp), %r8
	movq  -808(%rbp), %r9
	addq %r8, %r9

	movq %r9,  -808(%rbp)
	movq  -808(%rbp), %r9
	movq (%r9), %r8

	movq %r8,  -800(%rbp)
	movq  -792(%rbp), %r8
	movq  -800(%rbp), %r9
	cmpq %r8, %r9

	je L31

	L32:

	movq $0, %r8

	movq %r8,  -408(%rbp)
	L31:

	movq  -408(%rbp), %rax
	movq %rax,  -416(%rbp)
	jmp L35

	L36:

	movq 0(%rbp), %r8

	movq %r8,  -40(%rbp)
	movq  -40(%rbp), %r9
	movq  -16(%r9), %r8

	movq %r8,  -32(%rbp)
	movq  -32(%rbp), %rax
	movq %rax,  -424(%rbp)
	movq  -16(%rbp), %rax
	movq %rax,  -432(%rbp)
	movq  -424(%rbp), %rdi
	movq  -432(%rbp), %rsi
	call _checkIndexArray

	movq  -424(%rbp), %rax
	movq %rax,  -48(%rbp)
	movq  -432(%rbp), %r9
	movq %r9, %r8

	movq %r8,  -56(%rbp)
	movq  -56(%rbp), %r8
	imul $8, %r8

	movq %r8,  -56(%rbp)
	movq  -56(%rbp), %r9
	movq  -48(%rbp), %r8
	addq %r9, %r8

	movq %r8,  -48(%rbp)
	#movq $1, (%r8)

	movq %r8,  -48(%rbp)
	movq 0(%rbp), %r8

	movq %r8,  -72(%rbp)
	movq  -72(%rbp), %r9
	movq  -32(%r9), %r8

	movq %r8,  -64(%rbp)
	movq  -64(%rbp), %rax
	movq %rax,  -440(%rbp)
	movq  -16(%rbp), %rax
	movq %rax,  -80(%rbp)
	movq  -8(%rbp), %r8
	movq  -80(%rbp), %r9
	addq %r8, %r9

	movq %r9,  -80(%rbp)
	movq  -80(%rbp), %rax
	movq %rax,  -448(%rbp)
	movq  -440(%rbp), %rdi
	movq  -448(%rbp), %rsi
	call _checkIndexArray

	movq  -440(%rbp), %rax
	movq %rax,  -88(%rbp)
	movq  -448(%rbp), %r9
	movq %r9, %r8

	movq %r8,  -96(%rbp)
	movq  -96(%rbp), %r8
	imul $8, %r8

	movq %r8,  -96(%rbp)
	movq  -96(%rbp), %r9
	movq  -88(%rbp), %r8
	addq %r9, %r8

	movq %r8,  -88(%rbp)
	#movq $1, (%r8)

	movq %r8,  -88(%rbp)
	movq 0(%rbp), %r8

	movq %r8,  -120(%rbp)
	movq  -120(%rbp), %r9
	movq  -40(%r9), %r8

	movq %r8,  -112(%rbp)
	movq  -112(%rbp), %rax
	movq %rax,  -456(%rbp)
	movq  -16(%rbp), %rax
	movq %rax,  -136(%rbp)
	movq $7, %r8

	movq %r8,  -144(%rbp)
	movq  -144(%rbp), %r9
	movq  -136(%rbp), %r8
	addq %r9, %r8

	movq %r8,  -136(%rbp)
	movq  -136(%rbp), %r9
	movq %r9, %r8

	movq %r8,  -128(%rbp)
	movq  -8(%rbp), %r8
	movq  -128(%rbp), %r9
	subq %r8, %r9

	movq %r9,  -128(%rbp)
	movq  -128(%rbp), %rax
	movq %rax,  -464(%rbp)
	movq  -456(%rbp), %rdi
	movq  -464(%rbp), %rsi
	call _checkIndexArray

	movq  -456(%rbp), %rax
	movq %rax,  -152(%rbp)
	movq  -464(%rbp), %r9
	movq %r9, %r8

	movq %r8,  -160(%rbp)
	movq  -160(%rbp), %r8
	imul $8, %r8

	movq %r8,  -160(%rbp)
	movq  -160(%rbp), %r9
	movq  -152(%rbp), %r8
	addq %r9, %r8

	movq %r8,  -152(%rbp)
	#movq $1, (%r8)

	movq %r8,  -152(%rbp)
	movq 0(%rbp), %r8

	movq %r8,  -176(%rbp)
	movq  -176(%rbp), %r9
	movq  -24(%r9), %r8

	movq %r8,  -168(%rbp)
	movq  -168(%rbp), %rax
	movq %rax,  -472(%rbp)
	movq  -8(%rbp), %rax
	movq %rax,  -480(%rbp)
	movq  -472(%rbp), %rdi
	movq  -480(%rbp), %rsi
	call _checkIndexArray

	movq  -472(%rbp), %rax
	movq %rax,  -184(%rbp)
	movq  -480(%rbp), %r9
	movq %r9, %r8

	movq %r8,  -200(%rbp)
	movq  -200(%rbp), %r8
	imul $8, %r8

	movq %r8,  -200(%rbp)
	movq  -200(%rbp), %r9
	movq  -184(%rbp), %r8
	addq %r9, %r8

	movq %r8,  -184(%rbp)
	movq  -16(%rbp), %r8
	movq  -184(%rbp), %r9
	movq %r8, (%r9)

	movq %rbp,  -208(%rbp)
	movq $0, %r8

	movq %r8,  -216(%rbp)
	movq  -216(%rbp), %r9
	movq  -208(%rbp), %r8
	addq %r9, %r8

	movq %r8,  -208(%rbp)
	movq  -208(%rbp), %r8
	movq (%r8), %rdi

	movq  -8(%rbp), %r8
	movq %r8, %rsi

	movq $1, %r8

	movq %r8,  -224(%rbp)
	movq  -224(%rbp), %r8
	addq %r8, %rsi

	call L1

	movq 0(%rbp), %r8

	movq %r8,  -240(%rbp)
	movq  -240(%rbp), %r9
	movq  -16(%r9), %r8

	movq %r8,  -232(%rbp)
	movq  -232(%rbp), %rax
	movq %rax,  -488(%rbp)
	movq  -16(%rbp), %rax
	movq %rax,  -496(%rbp)
	movq  -488(%rbp), %rdi
	movq  -496(%rbp), %rsi
	call _checkIndexArray

	movq  -488(%rbp), %rax
	movq %rax,  -248(%rbp)
	movq  -496(%rbp), %r9
	movq %r9, %r8

	movq %r8,  -256(%rbp)
	movq  -256(%rbp), %r8
	imul $8, %r8

	movq %r8,  -256(%rbp)
	movq  -256(%rbp), %r9
	movq  -248(%rbp), %r8
	addq %r9, %r8

	movq %r8,  -248(%rbp)
	#movq $0, (%r8)

	movq %r8,  -248(%rbp)
	movq 0(%rbp), %r8

	movq %r8,  -272(%rbp)
	movq  -272(%rbp), %r9
	movq  -32(%r9), %r8

	movq %r8,  -264(%rbp)
	movq  -264(%rbp), %rax
	movq %rax,  -504(%rbp)
	movq  -16(%rbp), %rax
	movq %rax,  -280(%rbp)
	movq  -8(%rbp), %r8
	movq  -280(%rbp), %r9
	addq %r8, %r9

	movq %r9,  -280(%rbp)
	movq  -280(%rbp), %rax
	movq %rax,  -512(%rbp)
	movq  -504(%rbp), %rdi
	movq  -512(%rbp), %rsi
	call _checkIndexArray

	movq  -504(%rbp), %rax
	movq %rax,  -288(%rbp)
	movq  -512(%rbp), %r9
	movq %r9, %r8

	movq %r8,  -296(%rbp)
	movq  -296(%rbp), %r8
	imul $8, %r8

	movq %r8,  -296(%rbp)
	movq  -296(%rbp), %r9
	movq  -288(%rbp), %r8
	addq %r9, %r8

	movq %r8,  -288(%rbp)
	#movq $0, (%r8)

	movq %r8,  -288(%rbp)
	movq 0(%rbp), %r8

	movq %r8,  -312(%rbp)
	movq  -312(%rbp), %r9
	movq  -40(%r9), %r8

	movq %r8,  -304(%rbp)
	movq  -304(%rbp), %rax
	movq %rax,  -520(%rbp)
	movq  -16(%rbp), %rax
	movq %rax,  -328(%rbp)
	movq $7, %r8

	movq %r8,  -336(%rbp)
	movq  -336(%rbp), %r9
	movq  -328(%rbp), %r8
	addq %r9, %r8

	movq %r8,  -328(%rbp)
	movq  -328(%rbp), %r9
	movq %r9, %r8

	movq %r8,  -320(%rbp)
	movq  -8(%rbp), %r8
	movq  -320(%rbp), %r9
	subq %r8, %r9

	movq %r9,  -320(%rbp)
	movq  -320(%rbp), %rax
	movq %rax,  -528(%rbp)
	movq  -520(%rbp), %rdi
	movq  -528(%rbp), %rsi
	call _checkIndexArray

	movq  -520(%rbp), %rax
	movq %rax,  -344(%rbp)
	movq  -528(%rbp), %r9
	movq %r9, %r8

	movq %r8,  -352(%rbp)
	movq  -352(%rbp), %r8
	imul $8, %r8

	movq %r8,  -352(%rbp)
	movq  -352(%rbp), %r9
	movq  -344(%rbp), %r8
	addq %r9, %r8

	movq %r8,  -344(%rbp)
	#movq $0, (%r8)

	movq %r8,  -344(%rbp)
	jmp L37

	L45:




	movq %rbp, %rsp
	popq %rbp
	ret
.globl _tigermain
.type _tigermain,@function
_tigermain:
	pushq %rbp
	movq %rsp, %rbp
	subq $1024, %rsp


	L44:

	movq %rbp,  -48(%rbp)
	movq $ -8, %r8

	movq %r8,  -56(%rbp)
	movq  -56(%rbp), %r9
	movq  -48(%rbp), %r8
	addq %r9, %r8

	movq %r8,  -48(%rbp)
	#movq $8, (%r8)

	movq %r8,  -48(%rbp)
	movq %rbp,  -64(%rbp)
	movq $ -16, %r8

	movq %r8,  -72(%rbp)
	movq  -72(%rbp), %r9
	movq  -64(%rbp), %r8
	addq %r9, %r8

	movq %r8,  -64(%rbp)
	movq  -64(%rbp), %rax
	movq %rax,  -232(%rbp)
	movq %rbp,  -80(%rbp)
	movq $ -8, %r8

	movq %r8,  -88(%rbp)
	movq  -88(%rbp), %r9
	movq  -80(%rbp), %r8
	addq %r9, %r8

	movq %r8,  -80(%rbp)
	movq  -80(%rbp), %r8
	movq (%r8), %rdi

	movq $0, %rsi

	call _initArray

	movq %rax, %r8

	movq %r8,  -224(%rbp)
	movq  -224(%rbp), %r8
	movq  -232(%rbp), %r9
	movq %r8, (%r9)

	movq %rbp,  -96(%rbp)
	movq $ -24, %r8

	movq %r8,  -104(%rbp)
	movq  -104(%rbp), %r9
	movq  -96(%rbp), %r8
	addq %r9, %r8

	movq %r8,  -96(%rbp)
	movq  -96(%rbp), %rax
	movq %rax,  -248(%rbp)
	movq %rbp,  -112(%rbp)
	movq $ -8, %r8

	movq %r8,  -120(%rbp)
	movq  -120(%rbp), %r9
	movq  -112(%rbp), %r8
	addq %r9, %r8

	movq %r8,  -112(%rbp)
	movq  -112(%rbp), %r8
	movq (%r8), %rdi

	movq $0, %rsi

	call _initArray

	movq %rax, %r8

	movq %r8,  -240(%rbp)
	movq  -240(%rbp), %r8
	movq  -248(%rbp), %r9
	movq %r8, (%r9)

	movq %rbp,  -128(%rbp)
	movq $ -32, %r8

	movq %r8,  -136(%rbp)
	movq  -136(%rbp), %r9
	movq  -128(%rbp), %r8
	addq %r9, %r8

	movq %r8,  -128(%rbp)
	movq  -128(%rbp), %rax
	movq %rax,  -264(%rbp)
	movq $1, %r8

	movq %r8,  -144(%rbp)
	movq  -144(%rbp), %r8
	movq %r8, %rdi

	movq  -8(%rbp), %r8

	movq %r8,  -160(%rbp)
	movq  -160(%rbp), %r9
	movq %r9, %r8

	movq %r8,  -152(%rbp)
	movq  -8(%rbp), %r8

	movq %r8,  -168(%rbp)
	movq  -168(%rbp), %r9
	movq  -152(%rbp), %r8
	addq %r9, %r8

	movq %r8,  -152(%rbp)
	movq  -152(%rbp), %r8
	subq %r8, %rdi

	movq $0, %rsi

	call _initArray

	movq %rax, %r8

	movq %r8,  -256(%rbp)
	movq  -256(%rbp), %r8
	movq  -264(%rbp), %r9
	movq %r8, (%r9)

	movq %rbp,  -176(%rbp)
	movq $ -40, %r8

	movq %r8,  -184(%rbp)
	movq  -184(%rbp), %r9
	movq  -176(%rbp), %r8
	addq %r9, %r8

	movq %r8,  -176(%rbp)
	movq  -176(%rbp), %rax
	movq %rax,  -280(%rbp)
	movq $1, %r8

	movq %r8,  -192(%rbp)
	movq  -192(%rbp), %r8
	movq %r8, %rdi

	movq  -8(%rbp), %r8

	movq %r8,  -208(%rbp)
	movq  -208(%rbp), %r9
	movq %r9, %r8

	movq %r8,  -200(%rbp)
	movq  -8(%rbp), %r8

	movq %r8,  -216(%rbp)
	movq  -216(%rbp), %r9
	movq  -200(%rbp), %r8
	addq %r9, %r8

	movq %r8,  -200(%rbp)
	movq  -200(%rbp), %r8
	subq %r8, %rdi

	movq $0, %rsi

	call _initArray

	movq %rax, %r8

	movq %r8,  -272(%rbp)
	movq  -272(%rbp), %r8
	movq  -280(%rbp), %r9
	movq %r8, (%r9)

	movq %rbp, %rdi

	movq $0, %rsi

	call L1

	movq $0, %rax

	jmp L43

	L43:




	movq %rbp, %rsp
	popq %rbp
	ret

