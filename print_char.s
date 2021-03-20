/* print_char.s
This function reads value from r12 and prints it in 8-digit hex to stdout.
Arto Rasimus 1.3.2021 */
.cpu cortex-a53
.fpu neon-fp-armv8
.syntax unified
.section .rodata
.align 2
@ ---------------------------------------
@       Data Section
@ ---------------------------------------
.section .data
str_function_name:
    .asciz "print_char()\n"
    strlen_function_name = .-str_function_name
str_x:
    .ascii "x"
    strlen_x = .-str_x
/*
str_nl:
    .asciz "\n"
    strlen_nl = .-str_nl
*/
@ ---------------------------------------
@       Block Starting Symbol Section
@ ---------------------------------------
@ The portion of an object that contains statically-allocated variables
@ that are declared but have not been assigned a value yet

/*
.section .bss
    .lcomm reg_tmp, 4     // 4 bytes for local common storage
*/

@ ---------------------------------------
@       Code Section
@ ---------------------------------------
.section .text
.align 2

.global print_char
.type print_char, %function
print_char:
/*
    mov r0, $1            // syscall
    ldr r1, =str_function_name // address of text string
    ldr r2, =strlen_function_name // number of bytes to write
    mov r7, $4            // SYS_WRITE = 4
    swi 0
*/
//    pop {r12}

// r12 --> reg_val_addr
// r11 --> aux_reg_val_addr

    mov r11, $8            // counter of 8 hex digits (32 bits)
loop:
    ror r12, $28            // bits 31, 30, 29, 28 go to bits 3, 2, 1, 0
    and r9, r12, 0xF       // lowest 4 bits are masked in for following comparisons

    mov r0, $48
    cmp r9, $0            // 0x0000
    beq print_hex_digit

    mov r0, $49
    cmp r9, $1            // 0x0001
    beq print_hex_digit

    mov r0, $50
    cmp r9, $2            // 0x0002
    beq print_hex_digit

    mov r0, $51
    cmp r9, $3            // 0x0003
    beq print_hex_digit

    mov r0, $52
    cmp r9, $4            // 0x0004
    beq print_hex_digit

    mov r0, $53
    cmp r9, $5            // 0x0005
    beq print_hex_digit

    mov r0, $54
    cmp r9, $6            // 0x0006
    beq print_hex_digit

    mov r0, $55
    cmp r9, $7            // 0x0007
    beq print_hex_digit

    mov r0, $56
    cmp r9, $8            // 0x0008
    beq print_hex_digit

    mov r0, $57
    cmp r9, $9            // 0x0009
    beq print_hex_digit

    mov r0, $65
    cmp r9, $10           // 0x000A
    beq print_hex_digit

    mov r0, $66
    cmp r9, $11           // 0x000B
    beq print_hex_digit

    mov r0, $67
    cmp r9, $12           // 0x000C
    beq print_hex_digit

    mov r0, $68
    cmp r9, $13           // 0x000D
    beq print_hex_digit

    mov r0, $69
    cmp r9, $14           // 0x000E
    beq print_hex_digit

    mov r0, $70
    cmp r9, $15           // 0x000F
    beq print_hex_digit

print_hex_digit:
    mov r9, r0            // hex digit to print
    ldr r10, =str_x       // just to get the address of the text string to r9
    str r9, [r10]         /* address of r9 (i.e. start of the string)
                             used for storing the ASCII char number */

    mov r0, $1            // syscall
    ldr r1, =str_x        // address of text string
    ldr r2, =strlen_x     // number of bytes to write
    mov r7, $4            // SYS_WRITE = 4
    swi 0

    sub r11, $1          // loop_count -= 1
    cmp r11, $4          // if loop_count == 4
    beq print_space      // then print_space
    cmp r11, $0          // if loop_count > 0
    bgt loop             // then continue loop
    cmp r11, $0          // if loop_count == 0
    beq nl               // then "\n"

print_space:
    mov r9, $32
    ldr r10, =str_x       // just to get the address of the text string to r9
    str r9, [r10]         /* address of r9 (i.e. start of the string)
                             used for storing the ASCII char number */
    mov r0, $1            // syscall
    ldr r1, =str_x        // address of text string
    ldr r2, =strlen_x     // number of bytes to write
    mov r7, $4            // SYS_WRITE = 4
    swi 0
    b loop

nl:
    mov r9, $10           // CR
    ldr r10, =str_x       // just to get the address of the text string to r9
    str r9, [r10]         /* address of r9 (i.e. start of the string)
                             used for storing the ASCII char number */

    mov r0, $1            // syscall
    ldr r1, =str_x       // address of text string
    ldr r2, =strlen_x    // number of bytes to write
    mov r7, $4            // SYS_WRITE = 4
    swi 0

end:
    bx  lr

