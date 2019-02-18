Programa reescrito
pushq %rbp

movq %rsp, %rbp

subq $1024, %rsp

movq %rbx, %T14

movq %r12, %T15

movq %r13, %T16

movq %r14, %T17

movq %r15, %T18

L16:

movq %rbp, %T7

movq $-8, %T8

addq %T8, %T7

movq %rdi, (%T7)

movq %rsi, %T0

movq $0, %T9

cmpq %T9, %T0

je L3

L4:

movq %T0, %T6

movq %rbp, %T10

movq $-8, %T11

addq %T11, %T10

movq (%T10), %rdi

movq %T0, %rsi

movq $1, %T12

subq %T12, %rsi

call L0

movq %rax, %T5

movq %T6, %T13

imul %T5, %T13

movq %T13, %T2

L5:

movq %T2, %rax

jmp L15

L3:

movq $1, %T2

jmp L5

L15:

movq %T14, %rbx

movq %T15, %r12

movq %T16, %r13

movq %T17, %r14

movq %T18, %r15

movq %rbp, %rsp

pop %rbp

ret
