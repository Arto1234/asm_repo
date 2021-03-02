/* read_input.s
This function reads one character from stdin and accepts values 0..9.
It reads input and returns it to _start.
Value is returned in r5 as plain 1-byte digit.
'0' (ASCII 48) returned as 0
'1' (ASCII 49) returned as 1
'2' (ASCII 50) returned as 2
'3' (ASCII 51) returned as 3
'4' (ASCII 52) returned as 4
'5' (ASCII 53) returned as 5
'6' (ASCII 54) returned as 6
'7' (ASCII 55) returned as 7
'8' (ASCII 56) returned as 8
'9' (ASCII 57) returned as 9
TODO: better input handling. Now is read only one char.
Later could be read until <enter>.
Identify cpu, floating-point and syntax
Arto Rasimus 1.3.2021 */
.cpu cortex-a53
.fpu neon-fp-armv8
.syntax unified
.section .rodata
.align 2
@ ---------------------------------------
@	Data Section
@ ---------------------------------------
.section .data
message:
        .asciz "Give number (0 = quit): "
        strlen = .-message

msg_err_wrong_input:
        .asciz "Wrong input\n"
        strlen_msg_err_wrong_input = .-msg_err_wrong_input

@ ---------------------------------------
@       Block Starting Symbol Section
@ ---------------------------------------
@ The portion of an object that contains statically-allocated variables
@ that are declared but have not been assigned a value yet

.section .bss
    .lcomm times, 1     // 2 bytes for local common storage

@ ---------------------------------------
@	Code Section
@ ---------------------------------------
.section .text
.align 2

.global read_input
read_input:
.type read_input, %function
begin_function:
    // print question string
    mov r0, $1         // syscall
    ldr r1, =message   // address of text string
    ldr r2, =strlen    // number of bytes to write
    mov r7, $4         // SYS_WRITE = 4
    swi 0

    mov r0, $0         // syscall: SYS_READ
    ldr r1, =times     // Load our reserved 3 bytes for the buffer into r4
    mov r2, $1         // Set max input size to 1 byte: char
    mov r7, $3         // Load syscall SYS_READ (3) into r7
    swi $0             // Invoke the system call

    ldr r5, [r1]       // save reference of character to r5
    and r5, r5, $0x0FF // the enter is masked off

begin_if:
    // check input: 0 - 9
    cmp r5, $48         // is < '0'
    blt out_of_limits

    cmp r5, $57         // is > '9'
    bgt out_of_limits

value_ok:
    sub r5, $48         // value is valid. Convert ASCII to number
    b end

out_of_limits:
    mov r0, $1        // syscall
    ldr r1, =msg_err_wrong_input // address of text string
    ldr r2, =strlen_msg_err_wrong_input  // number of bytes to write
    mov r7, $4          // SYS_WRITE = 4
    swi 0

    b begin_function    // invalid character

end:
    bx  lr
