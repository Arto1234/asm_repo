/* main.s
Arto Rasimus 1.3.2021
My first assembly program :) */
@ _start function calls subfunctions
@ Identify cpu, floating-point and syntax
@.arch armv7l
.cpu cortex-a53
.fpu neon-fp-armv8
.syntax unified
.section .rodata
.align 2
@ ---------------------------------------
@	Data Section
@ ---------------------------------------
.section .data
str_function_name:
    .asciz "_start()\n"
    strlen_function_name = .-str_function_name

message1:
    .asciz "Hello, World!\n"
    len_msg1 = .-message1

message2:
    .asciz "Bye, World!\n"
    len_msg2 = .-message2

@ ---------------------------------------
@	Code Section
@ ---------------------------------------
.section .text
.align 2

.global _start
_start:
.type _start, %function
    mov r0, $1                    // syscall
    ldr r1, =str_function_name    // address of text string
    ldr r2, =strlen_function_name // number of bytes to write
    mov r7, $4                    // SYS_WRITE = 4
    swi 0

    bl  read_input     // returns value is stored in r4
    bl gpio_input

loop:
    cmp r4, $0         // if count = 0, then no print
    beq end_msg

    mov r0, $1         // use syscall
    ldr r1, =message1  // address of text string
    ldr r2, =len_msg1  // number of bytes to write
    mov r7, $4         // SYS_WRITE = 4
    swi 0

    sub r4, $1
    cmp r4, $1
    bge loop

end_msg:
    cmp r5, $0        // compared the given value (from sub routine)
    bgt end

    mov r0, $1        // syscall
    ldr r1, =message2 // address of text string
    ldr r2, =len_msg2 // number of bytes to write
    mov r7, $4        // SYS_WRITE = 4
    swi 0

end:
    // STDOUT_FILENO is 1
    mov r0, $0        // exit with 0 exit code
    mov r7, $1        // SYS_EXIT
    swi 0             // SW interrupt
