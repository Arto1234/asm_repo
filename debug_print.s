/* debug_print.s
This function prints several ARM registers' contents as 8 digit hex to stdout.
Purpose is to help debugging in development phase.
Saved variables get their values in saveregs.s.
Arto Rasimus 20.3.2021 */
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
    .asciz "\n\ndebug_print()\n"
    strlen_function_name = .-str_function_name
str_r0:
    .ascii "r0  = 0x"
    strlen_r0 = .-str_r0
str_r1:
    .ascii "r1  = 0x"
    strlen_r1 = .-str_r1
str_r2:
    .ascii "r2  = 0x"
    strlen_r2 = .-str_r2
str_r3:
    .ascii "r3  = 0x"
    strlen_r3 = .-str_r3
str_r4:
    .ascii "r4  = 0x"
    strlen_r4 = .-str_r4
str_r5:
    .ascii "r5  = 0x"
    strlen_r5 = .-str_r5
str_r6:
    .ascii "r6  = 0x"
    strlen_r6 = .-str_r6
str_r7:
    .ascii "r7  = 0x"
    strlen_r7 = .-str_r7
str_r8:
    .ascii "r8  = 0x"
    strlen_r8 = .-str_r8
str_r9:
    .ascii "r9  = 0x"
    strlen_r9 = .-str_r9
str_r10:
    .ascii "r10 = 0x"
    strlen_r10 = .-str_r10

@ ---------------------------------------
@       Block Starting Symbol Section
@ ---------------------------------------
// The portion of an object that contains statically-allocated variables
// that are declared but have not been assigned a value yet

@ ---------------------------------------
@       Code Section
@ ---------------------------------------
.section .text
.align 2
.global debug_print
.type debug_print, %function

debug_print:

    bl saveregs
    // This function prints values of r0, r1, r2, r3 r4 and r5 to stdout.
    mov r0, $1                 // syscall
    ldr r1, =str_function_name // address of text string
    ldr r2, =strlen_function_name // number of bytes to write
    mov r7, $4                // SYS_WRITE = 4
    swi 0

r0:
    // print "r0 = 0x..."
    mov r0, $1            // syscall
    ldr r1, =str_r0       // address of text string
    ldr r2, =strlen_r0    // number of bytes to write
    mov r7, $4            // SYS_WRITE = 4
    swi 0

    ldr r8, =r0_save     // copy the raw 32bit value to 'aux' register
    ldr r11, [r8]        // copy the raw integer value to 'auxiliary' register
    mov r12, r11
    bl print_char

r1:
    // print "r1 = 0x..."
    mov r0, $1            // syscall
    ldr r1, =str_r1       // address of text string
    ldr r2, =strlen_r1    // number of bytes to write
    mov r7, $4            // SYS_WRITE = 4
    swi 0

    ldr r8, =r1_save     // copy the raw 32bit value to 'aux' register
    ldr r11, [r8]        // copy the raw integer value to 'auxiliary' register
    mov r12, r11
    bl print_char

r2:
    // print "r2 = 0x..."
    mov r0, $1            // syscall
    ldr r1, =str_r2       // address of text string
    ldr r2, =strlen_r2    // number of bytes to write
    mov r7, $4            // SYS_WRITE = 4
    swi 0

    ldr r8, =r2_save     // copy the raw 32bit value to 'aux' register
    ldr r11, [r8]        // copy the raw integer value to 'auxiliary' register
    mov r12, r11
    bl print_char

r3:
    // print "r3 = 0x..."
    mov r0, $1            // syscall
    ldr r1, =str_r3       // address of text string
    ldr r2, =strlen_r3    // number of bytes to write
    mov r7, $4            // SYS_WRITE = 4
    swi 0

    ldr r8, =r3_save     // copy the raw 32bit value to 'aux' register
    ldr r11, [r8]        // copy the raw integer value to 'auxiliary' register
    mov r12, r11
    bl print_char

r4:
    // print "r4 = 0x..."
    mov r0, $1            // syscall
    ldr r1, =str_r4       // address of text string
    ldr r2, =strlen_r4    // number of bytes to write
    mov r7, $4            // SYS_WRITE = 4
    swi 0

    ldr r8, =r4_save     // copy the raw 32bit value to 'aux' register
    ldr r11, [r8]        // copy the raw integer value to 'auxiliary' register
    mov r12, r11
    bl print_char

r5:
    // print "r5 = 0x..."
    mov r0, $1            // syscall
    ldr r1, =str_r5       // address of text string
    ldr r2, =strlen_r5    // number of bytes to write
    mov r7, $4            // SYS_WRITE = 4
    swi 0

    ldr r8, =r5_save     // copy the raw 32bit value to 'aux' register
    ldr r11, [r8]        // copy the raw integer value to 'auxiliary' register
    mov r12, r11
    bl print_char

r6:
    // print "r6 = 0x..."
    mov r0, $1            // syscall
    ldr r1, =str_r6       // address of text string
    ldr r2, =strlen_r6    // number of bytes to write
    mov r7, $4            // SYS_WRITE = 4
    swi 0

    ldr r8, =r6_save     // copy the raw 32bit value to 'aux' register
    ldr r11, [r8]        // copy the raw integer value to 'auxiliary' register
    mov r12, r11
    bl print_char

r7:
    // print "r7 = 0x..."
    mov r0, $1            // syscall
    ldr r1, =str_r7       // address of text string
    ldr r2, =strlen_r7    // number of bytes to write
    mov r7, $4            // SYS_WRITE = 4
    swi 0

    ldr r8, =r7_save     // copy the raw 32bit value to 'aux' register
    ldr r11, [r8]        // copy the raw integer value to 'auxiliary' register
    mov r12, r11
    bl print_char

r8:
    // print "r8 = 0x..."
    mov r0, $1            // syscall
    ldr r1, =str_r8       // address of text string
    ldr r2, =strlen_r8    // number of bytes to write
    mov r7, $4            // SYS_WRITE = 4
    swi 0

                         // r9 just here, r8 for others...
    ldr r9, =r8_save     // copy the raw 32bit value to 'aux' register
    ldr r11, [r9]        // copy the raw integer value to 'auxiliary' register
    mov r12, r11
    bl print_char

r9:
    // print "r9 = 0x..."
    mov r0, $1            // syscall
    ldr r1, =str_r9       // address of text string
    ldr r2, =strlen_r9    // number of bytes to write
    mov r7, $4            // SYS_WRITE = 4
    swi 0

    ldr r8, =r9_save     // copy the raw 32bit value to 'aux' register
    ldr r11, [r8]        // copy the raw integer value to 'auxiliary' register
    mov r12, r11
    bl print_char

r10:
    // print "r10 = 0x..."
    mov r0, $1            // syscall
    ldr r1, =str_r10      // address of text string
    ldr r2, =strlen_r10   // number of bytes to write
    mov r7, $4            // SYS_WRITE = 4
    swi 0

    ldr r8, =r10_save     // copy the raw 32bit value to 'aux' register
    ldr r11, [r8]        // copy the raw integer value to 'auxiliary' register
    mov r12, r11

    bl print_char

end:
    mov r0, $1                 // syscall
    ldr r1, =str_function_name // address of text string
    ldr r2, =strlen_function_name // number of bytes to write
    mov r7, $4                // SYS_WRITE = 4
    swi 0

//    pop {lr} //  loop forever
    bx lr
