/* read_input.s
This function reads one 32-bit value (8 hex characters) from stdin.
Digits must be in hex. Value range: 00000000..FFFFFFFF.
It reads input and returns it to _start.
Value is returned in r5 as 32-bit hex value.

TODO: better input handling. Now is read only one char.
TODO: reading from parameter file.
Later could be read until <enter>.
Program is meant to be run in Raspberry Pi 3 and compatible.
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

@ ---------------------------------------
@	Code Section
@ ---------------------------------------
.section .text
.align 2

.global read_input
read_input:
.type read_input, %function
begin_function:
    push {lr}
    // print question string
    mov r0, $1         // syscall
    ldr r1, =message   // address of text string
    ldr r2, =strlen    // number of bytes to write
    mov r7, $4         // SYS_WRITE = 4
    swi 0

    mov r0, $0         // syscall: SYS_READ
    ldr r1, =hex_value //
    mov r2, $8         // Set max input size to 8 bytes: 8 chars
    mov r7, $3         // Load syscall SYS_READ (3) into r7
    swi $0             // Invoke the system call

    mov r9, r1
/* TODO: if value is shorter that 8 digits, then zero padding must be done
         into MSB bits. */
    mov r5, $0
// TODO: check string actual length !!!
    cmp r2, $8
    bne wrong_parameter_length

    ldrb r10, [r9], $1
    bl check_hex_digit // ret val: r3 int. status: r10 0=ok, 999=nok
    cmp r10, $0x71
    bne out_of_limits
    lsl r4, r3, $28
    orr r5, r4

    ldrb r10, [r9], $1
    bl check_hex_digit // ret val: r3 int. status: r10 0=ok, 999=nok
    cmp r10, $0x71
    bne out_of_limits
    lsl r4, r3, $24
    orr r5, r4

    ldrb r10, [r9], $1
    bl check_hex_digit // ret val: r3 int. status: r10 0=ok, 999=nok
    cmp r10, $0x71
    bne out_of_limits
    lsl r4, r3, $20
    orr r5, r4

    ldrb r10, [r9], $1
    bl check_hex_digit // ret val: r3 int. status: r10 0=ok, 999=nok
    cmp r10, $0x71
    bne out_of_limits
    lsl r4, r3, $16
    orr r5, r4

    ldrb r10, [r9], $1
    bl check_hex_digit // ret val: r3 int. status: r10 0=ok, 999=nok
    cmp r10, $0x71
    bne out_of_limits
    lsl r4, r3, $12
    orr r5, r4

    ldrb r10, [r9], $1
    bl check_hex_digit // ret val: r3 int. status: r10 0=ok, 999=nok
    cmp r10, $0x71
    bne out_of_limits
    lsl r4, r3, $8
    orr r5, r4

    ldrb r10, [r9], $1
    bl check_hex_digit // ret val: r3 int. status: r10 0=ok, 999=nok
    cmp r10, $0x71
    bne out_of_limits
    lsl r4, r3, $4
    orr r5, r4

    ldrb r10, [r9], $1
    bl check_hex_digit // ret val: r3 int. status: r10 0=ok, 999=nok
    cmp r10, $0x71
    bne out_of_limits
    lsl r4, r3, $0
    orr r5, r4

loop:
// lue merkki
// maskaa 0xFF:n kanssa
// vertaa, että 48-57 (0..9) tai 65-70 (A..F) tai 97-102 (a..f)
// siirrä nibble oikeaan kohtaan: alkaen paikasta 7
// looppaa paikkaan 0
// paluuarvo 32-bit, 8 hex digit arvo on valmis!
//    ldr r0, [r1]//, r6]      // save reference of character to r0

//    ror r0, $16           // bits 31, 30, 29, 28 go to bits 3, 2, 1, 0
//    ror r0, $16           // bits 31, 30, 29, 28 go to bits 3, 2, 1, 0

    // ASCII code is stored in lowest nibble in r1 in hex



value_ok:
    /* hex digit is left-shifted to correct place
    with the amount of (r2) counter (in nibbles)
    r2 = 28, 24, 20, 16, 12, 8, 4, 0 */

//    mov r6, $4
//    mul r5, r2, r6
//    lsl r3, r3, r5 // hex digit shifted to left to correct place

//    add r6, r6, $1  // hex_value loop counter for reading the string
//    add r1, r1, $1

//    subs r2, $1
//    cmp r6, $3
//    blt loop   // counter > 0, continue looping

    mov r3, $0x71
    b end

// parameter length <> 8 chars
wrong_parameter_length:
    mov r0, $1        // syscall
    ldr r1, =msg_err_wrong_length // address of text string
    ldr r2, =strlen_msg_err_wrong_length  // number of bytes to write
    mov r7, $4          // SYS_WRITE = 4
    swi 0

    mov r3, $0x82
    b end

// invalid character
out_of_limits:
    mov r0, $1        // syscall
    ldr r1, =msg_err_wrong_input // address of text string
    ldr r2, =strlen_msg_err_wrong_input  // number of bytes to write
    mov r7, $4          // SYS_WRITE = 4
    swi 0

    mov r3, $0x82
    b end

end:
    pop {pc}
