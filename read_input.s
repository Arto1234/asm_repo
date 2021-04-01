/* read_input.s
This function reads one 32-bit value (8 hex characters) from stdin.
Digits must be in hex. Value range: 00000000..FFFFFFFF.
It reads input and returns it to _start.
Value is returned in r5 as 32-bit hex value.

TODO: reading from parameter file or fixed constant data.
Arto Rasimus 31.3.2021 */
.cpu cortex-a53
.fpu neon-fp-armv8
.syntax unified
.section .rodata
.align 2
/* ---------------------------------------
        Data Section
 --------------------------------------- */
.section .data
message:
    .asciz "Give number (0 = quit): "
    strlen = .-message

msg_err_wrong_input:
    .asciz "Wrong input\n"
    strlen_msg_err_wrong_input = .-msg_err_wrong_input

msg_err_wrong_length:
    .asciz "Wrong parameter length\n"
    strlen_msg_err_wrong_length = .-msg_err_wrong_length

/* ---------------------------------------
        Block Starting Symbol Section
 ---------------------------------------
The portion of an object that contains statically-allocated variables
that are declared but have not been assigned a value yet */

// local common storage
.section .bss
    .lcomm hex_value, 4

/* ---------------------------------------
        Code Section
 --------------------------------------- */
.section .text
.align 2

.equ STDIN_C,      0x0
.equ STDOUT_C,     0x1
.equ SYS_READ_C,   0x3
.equ SYS_WRITE_C,  0x4
.equ NIBBLE_LEN_C, 0x4
.equ STATUS_OK_C,  0x71 // Return value from check_hex_digit()
.equ STATUS_NOK_C, 0x82 // Return value from check_hex_digit()


.global read_input
read_input:
.type read_input, %function

begin_function:
    push {lr}
    // print question string
    mov r0, STDOUT_C
    ldr r1, =message     // address of text string
    ldr r2, =strlen      // number of bytes to write
    mov r7, SYS_WRITE_C
    swi 0

    mov r0, STDIN_C
    ldr r1, =hex_value   //
    mov r2, $8           // Set max input size to 8 bytes: 8 chars
    mov r7, SYS_READ_C
    swi $0               // Invoke the system call

    mov r3, STATUS_NOK_C // status initialised
    mov r9, r1           // r9 used as temporary storage
    mov r5, $0           // result register initialised

    // TODO: check string actual length !!!
    cmp r2, $8           // Now this succeeds always...
    bne wrong_parameter_length

    sub r2, $1           // r2: character amount (8) --> loop counter (7..0)
    mov r8, NIBBLE_LEN_C // Multiplier (4). Size of hex digit.
loop:
    // r6 = counter * 4 (bit shift index)
    // r2 = digit counter (ASCII chars)
    mov r6, r2
    ldrb r10, [r9], $1
    bl check_hex_digit   // in: r10. ret val: r3 int. status: r10 0x71=ok, 0x82=nok
    cmp r10, STATUS_OK_C
    bne out_of_limits
    mul r6, r6, r8       // counter * 4 = left shift in bits

    lsl r4, r3, r6       // r3 is left shifted by ctr * 4 bits, to r4
    orr r5, r4           // bit pattern is placed intofinal result

    sub r2, $1           // decrement the char counter
    cmp r2, $0
    bge loop
    b value_ok

value_ok:
    mov r3, STATUS_OK_C
    b end

// parameter length <> 8 chars
wrong_parameter_length:
    mov r0, STDOUT_C
    ldr r1, =msg_err_wrong_length         // address of text string
    ldr r2, =strlen_msg_err_wrong_length  // number of bytes to write
    mov r7, SYS_WRITE_C
    swi 0

    mov r3, STATUS_NOK_C
    b end

// invalid character
out_of_limits:
    mov r0, STDOUT_C
    ldr r1, =msg_err_wrong_input          // address of text string
    ldr r2, =strlen_msg_err_wrong_input   // number of bytes to write
    mov r7, SYS_WRITE_C
    swi 0

    mov r3, STATUS_NOK_C
    b end

end:
    /* This creates side effect with above loop:
       r8:  var addr
       r9:  out (to print_char)
       r11: aux addr for var addr */
    bl debug_print
    pop {pc}
