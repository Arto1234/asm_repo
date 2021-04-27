/* number_units_by_10.s
This function reads 32 bit value from r5 and returns
       1s in variable: value_1s
      10s in variable: value_10s
     100s in variable: value_100s
    1000s in variable: value_1000s
   10000s in variable: value_10000s
Arto Rasimus 25.4.2021 */
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
    .asciz "\nnumber_units_by_10()\n"
    strlen_function_name = .-str_function_name

str_err_wrong_value:
    .asciz "Wrong value\n"
    strlen_msg_err_wrong_value = .-str_err_wrong_value

str_value_ok:
    .asciz "Value ok\n"
    strlen_msg_value_ok = .-str_value_ok


value_1s:             .word   0
value_10s:            .word   0
value_100s:           .word   0
value_1000s:          .word   0

.global value_1s
.global value_10s
.global value_100s
.global value_1000s

value_1s_addr:        .word   value_1s
value_10s_addr:       .word   value_10s
value_100s_addr:      .word   value_100s
value_1000s_addr:     .word   value_1000s


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

.equ STDOUT_C,           0x1
.equ WRITE_C,            0x4
.equ STATUS_OK_C,       0x71
.equ STATUS_NOK_C,      0x82
.equ SIZEOF_VALUE_C,       2

.global number_units_by_10
.type number_units_by_10, %function
number_units_by_10:
    push {lr}
/*
    mov r0, STDOUT_C
    ldr r1, =str_function_name    // address of text string
    ldr r2, =strlen_function_name // number of bytes to write
    mov r7, WRITE_C
    svc $0
*/
    // Precondition: R0 % R1 is the required computation
    // Postcondition: R0 has the result of R0 % R1
    //              : R2 has R0 / R1
    mov r0, r5              // r5: the value to be divided
    mov r1, $10             // divisor
    udiv r2, r5, r1         // division <- a / b       ; r2 <- r0 / r1
    mls  r0, r1, r2, r0     // modulo <- a - (b * 1) ; r0 <- r0 - (r1 * r2 )

    ldr r8, =value_1s        // Load address for the global variable to some reg (r8)
    str r0, [r8]             // Save units to the global variable

    // division and modulo by 10:
    udiv r6, r5, r1         // division <- a / b       ; r2 <- r0 / r1
    mov r0, r6              // r5: the value to be divided
    mov r1, $10             // divisor
    udiv r2, r0, r1         // division <- a / b       ; r3 <- r0 / r1
    mls  r0, r1, r2, r0     // modulo <- a - (b * 1) ; r0 <- r0 - (r1 * r2 )

    ldr r8, =value_10s       // Load address for the global variable to some reg (r8)
    str r0, [r8]             // Save 10s to the global variable

    // division and modulo by 100:
    mov r1, $100             // division and modulo by 100
    udiv r6, r5, r1         // division <- a / b       ; r2 <- r0 / r1
    mov r0, r6              // r5: the value to be divided

    udiv r2, r6, r1         // division <- a / b       ; r2 <- r0 / r1
    mls  r0, r1, r2, r0      // result2 <- a - (b * 1) ; r0 <- r0 - (r1 * r2 )

    ldr r8, =value_100s      // Load address for the global variable to some reg (r8)
    str r0, [r8]             // Save 100s to the global variable

    // divide by 1000:
    ldr r1, =$1000           // division and modulo by 1000
    udiv r6, r5, r1         // division <- a / b       ; r2 <- r0 / r1
    mov r0, r6              // r5: the value to be divided

    udiv r2, r0, r1          // result1 <- a / b       ; r2 <- r0 / r1
    mls  r0, r1, r2, r0      // result2 <- a - (b * 1) ; r0 <- r0 - (r1 * r2 )

    ldr r8, =value_1000s     // Load address for the global variable to some reg (r8)
    str r0, [r8]             // Save 1000s to the global variable

    b end

value_ok:
    mov r0, STDOUT_C
    ldr r1, =str_value_ok           // address of text string
    ldr r2, =strlen_msg_value_ok    // number of bytes to write
    mov r7, WRITE_C
    swi 0

    mov r10, STATUS_OK_C

    b end

out_of_limits:
    mov r0, STDOUT_C
    ldr r1, =str_err_wrong_value        // address of text string
    ldr r2, =strlen_msg_err_wrong_value // number of bytes to write
    mov r7, WRITE_C
    swi 0

    mov r10, STATUS_NOK_C               // failed

    b end

end:
    pop {pc}
