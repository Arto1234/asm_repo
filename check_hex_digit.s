/* hex_hex_digit.s
In:  ASCII, r12
Out: hex conversion, r3
Out: status: r12
This function reads ASCII value from r12 and checks it (valid hex or not).
Value as integer returned in r3.
Conversion OK, status 0 in r12
Conversion not valid: status 999 in r12.
Arto Rasimus 30.3.2021 */
.cpu cortex-a53
.fpu neon-fp-armv8
.syntax unified
.section .rodata
.align 2
/* ---------------------------------------
        Data Section
   ---------------------------------------*/
.section .data
str_function_name:
    .asciz "check_hex_digit()\n"
    strlen_function_name = .-str_function_name

/* ---------------------------------------
        Block Starting Symbol Section
   ---------------------------------------
The portion of an object that contains statically-allocated variables
that are declared but have not been assigned a value yet. */


/* ---------------------------------------
        Code Section
 ---------------------------------------*/
.section .text
.align 2

.global check_hex_digit
.type check_hex_digit, %function
check_hex_digit:
    mov r3, $0
    cmp r12, $48         // is == '0'?
    beq value_ok

    mov r3, $1
    cmp r12, $49         // is == '1'?
    beq value_ok

    mov r3, $2
    cmp r12, $50         // is == '2'?
    beq value_ok

    mov r3, $3
    cmp r12, $51         // is == '3'?
    beq value_ok

    mov r3, $4
    cmp r12, $52         // is == '4'?
    beq value_ok

    mov r3, $5
    cmp r12, $53         // is == '5'?
    beq value_ok

    mov r3, $6
    cmp r12, $54         // is == '6'?
    beq value_ok

    mov r3, $7
    cmp r12, $55         // is == '7'?
    beq value_ok

    mov r3, $8
    cmp r12, $56         // is == '8'?
    beq value_ok

    mov r3, $9
    cmp r12, $57         // is == '9'?
    beq value_ok

    mov r3, $10
    cmp r12, $65         // is == 'A'?
    beq value_ok

    mov r3, $11
    cmp r12, $66         // is == 'B'?
    beq value_ok

    mov r3, $12
    cmp r12, $67         // is == 'C'?
    beq value_ok

    mov r3, $13
    cmp r12, $68         // is == 'D'?
    beq value_ok

    mov r3, $14
    cmp r12, $69         // is == 'E'?
    beq value_ok

    mov r3, $15
    cmp r12, $70         // is == 'F'?
    beq value_ok

    mov r3, $10
    cmp r12, $97         // is == 'a'?
    beq value_ok

    mov r3, $11
    cmp r12, $98         // is == 'b'?
    beq value_ok

    mov r3, $12
    cmp r12, $99         // is == 'c'?
    beq value_ok

    mov r3, $13
    cmp r12, $100        // is == 'd'?
    beq value_ok

    mov r3, $14
    cmp r12, $101        // is == 'e'?
    beq value_ok

    mov r3, $15
    cmp r12, $102        // is == 'f'?
    beq value_ok

    b out_of_limits

value_ok:
    mov r12, $0
    b end

out_of_limits:
    mov r0, $1        // syscall
    ldr r1, =msg_err_wrong_input // address of text string
    ldr r2, =strlen_msg_err_wrong_input  // number of bytes to write
    mov r7, $4          // SYS_WRITE = 4
    swi 0

    mov r12, $999  // invalid character (not hex)
    b end

end:
    pop {pc}
