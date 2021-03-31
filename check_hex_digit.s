/* check_hex_digit.s
This function reads ASCII value from r10 and checks it (valid hex or not).
In:  ASCII, r10 ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
                 'A', 'B', 'C', 'D', 'E', 'F', 'a', 'b', 'c', 'd', 'e', 'f'
Out: hex conversion, r3 (0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15)
Out: status: r10
Conversion OK, status 0 in r10
Conversion not valid: status 999 in r10
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

msg_err_wrong_value:
    .asciz "Wrong value\n"
    strlen_msg_err_wrong_value = .-msg_err_wrong_value

msg_value_ok:
    .asciz "Value ok\n"
    strlen_msg_value_ok = .-msg_value_ok

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
    push {lr}

//    mov r0, $1                    // syscall
//    ldr r1, =str_function_name    // address of text string
//    ldr r2, =strlen_function_name // number of bytes to write
//    mov r7, $4                    // SYS_WRITE = 4
//    swi 0


    mov r3, $0
    cmp r10, $48         // is == '0'?
    beq value_ok

    mov r3, $1
    cmp r10, $49         // is == '1'?
    beq value_ok

    mov r3, $2
    cmp r10, $50         // is == '2'?
    beq value_ok

    mov r3, $3
    cmp r10, $51         // is == '3'?
    beq value_ok

    mov r3, $4
    cmp r10, $52         // is == '4'?
    beq value_ok

    mov r3, $5
    cmp r10, $53         // is == '5'?
    beq value_ok

    mov r3, $6
    cmp r10, $54         // is == '6'?
    beq value_ok

    mov r3, $7
    cmp r10, $55         // is == '7'?
    beq value_ok

    mov r3, $8
    cmp r10, $56         // is == '8'?
    beq value_ok

    mov r3, $9
    cmp r10, $57         // is == '9'?
    beq value_ok

    mov r3, $10
    cmp r10, $65         // is == 'A'?
    beq value_ok

    mov r3, $11
    cmp r10, $66         // is == 'B'?
    beq value_ok

    mov r3, $12
    cmp r10, $67         // is == 'C'?
    beq value_ok

    mov r3, $13
    cmp r10, $68         // is == 'D'?
    beq value_ok

    mov r3, $14
    cmp r10, $69         // is == 'E'?
    beq value_ok

    mov r3, $15
    cmp r10, $70         // is == 'F'?
    beq value_ok

    mov r3, $10
    cmp r10, $97         // is == 'a'?
    beq value_ok

    mov r3, $11
    cmp r10, $98         // is == 'b'?
    beq value_ok

    mov r3, $12
    cmp r10, $99         // is == 'c'?
    beq value_ok

    mov r3, $13
    cmp r10, $100        // is == 'd'?
    beq value_ok

    mov r3, $14
    cmp r10, $101        // is == 'e'?
    beq value_ok

    mov r3, $15
    cmp r10, $102        // is == 'f'?
    beq value_ok

    b out_of_limits

value_ok:
    mov r10, $0

    mov r0, $1                      // syscall
    ldr r1, =msg_value_ok           // address of text string
    ldr r2, =strlen_msg_value_ok    // number of bytes to write
    mov r7, $4                      // SYS_WRITE = 4
    swi 0

    mov r10, $0x71                  // hex conversion OK

    b end

out_of_limits:
    mov r0, $1                      // syscall
    ldr r1, =msg_err_wrong_value    // address of text string
    ldr r2, =strlen_msg_err_wrong_value // number of bytes to write
    mov r7, $4                      // SYS_WRITE = 4
    swi 0

    mov r10, $0x82                  // failed. invalid character (not hex)

    b end

end:
    pop {pc}
