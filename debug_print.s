/* debug_print.s
This function prints several ARMv7 registers' contents as 8-difit hex to stdout.
Purpose is to help debugging in development phase.
Arto Rasimus 1.3.2021 */
@ debug_print.s
@ Identify cpu, floating-point and syntax
@.arch armv7l
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
    .asciz "debug_print()\n"
    strlen_function_name = .-str_function_name
str_r0:
    .asciz "r0 = 0x"
    strlen_r0 = .-str_r0
str_r1:
    .asciz "r1 = 0x"
    strlen_r1 = .-str_r1
str_r2:
    .asciz "r2 = 0x"
    strlen_r2 = .-str_r2
str_r3:
    .asciz "r3 = 0x"
    strlen_r3 = .-str_r3
str_r4:
    .asciz "r4 = 0x"
    strlen_r4 = .-str_r4
str_r5:
    .asciz "r5 = 0x"
    strlen_r5 = .-str_r5
str_r6:
    .asciz "r6 = 0x"
    strlen_r6 = .-str_r6
str_r7:
    .asciz "r7 = 0x"
    strlen_r7 = .-str_r7
str_r8:
    .asciz "r8 = 0x"
    strlen_r8 = .-str_r8
str_r9:
    .asciz "r9 = 0x"
    strlen_r9 = .-str_r9

@ ---------------------------------------
@       Block Starting Symbol Section
@ ---------------------------------------
@ The portion of an object that contains statically-allocated variables
@ that are declared but have not been assigned a value yet

//.section .bss
//    .lcomm times, 1     // 1 byte for local common storage

@ ---------------------------------------
@       Code Section
@ ---------------------------------------
.section .text
.align 2

.global debug_print
.type debug_print, %function
debug_print:
    // This function prints values of r0, r1, r2, r3 r4 and r5 to stdout.
    mov r0, $1                 // syscall
    ldr r1, =str_function_name // address of text string
    ldr r2, =strlen_function_name // number of bytes to write
    mov r7, $4                // SYS_WRITE = 4
    swi 0

    push {lr}

r0:
    // print "r0 = 0x..."
    mov r0, $1            // syscall
    ldr r1, =str_r0       // address of text string
    ldr r2, =strlen_r0    // number of bytes to write
    mov r7, $4            // SYS_WRITE = 4
    swi 0

    mov r12, r0           // copy the raw integer value to 'auxiliary' register
    push {r12}
    bl print_char
r1:
    // print "r1 = 0x..."
    mov r0, $1            // syscall
    ldr r1, =str_r1       // address of text string
    ldr r2, =strlen_r1    // number of bytes to write
    mov r7, $4            // SYS_WRITE = 4
    swi 0

    mov r12, r1           // copy the raw integer value to 'auxiliary' register
    push {r12}
    bl print_char
r2:
    // print "r2 = 0x..."
    mov r0, $1            // syscall
    ldr r1, =str_r2       // address of text string
    ldr r2, =strlen_r2    // number of bytes to write
    mov r7, $4            // SYS_WRITE = 4
    swi 0

    mov r12, r2           // copy the raw integer value to 'auxiliary' register
    push {r12}
    bl print_char
r3:
    // print "r3 = 0x..."
    mov r0, $1            // syscall
    ldr r1, =str_r3       // address of text string
    ldr r2, =strlen_r3    // number of bytes to write
    mov r7, $4            // SYS_WRITE = 4
    swi 0

    mov r12, r3           // copy the raw integer value to 'auxiliary' register
    push {r12}
    bl print_char

r4:
    // print "r4 = 0x..."
    mov r0, $1            // syscall
    ldr r1, =str_r4       // address of text string
    ldr r2, =strlen_r4    // number of bytes to write
    mov r7, $4            // SYS_WRITE = 4
    swi 0

    mov r12, r4           // copy the raw integer value to 'auxiliary' register
    push {r12}
    bl print_char

r5:
    // print "r5 = 0x..."
    mov r0, $1            // syscall
    ldr r1, =str_r5       // address of text string
    ldr r2, =strlen_r5    // number of bytes to write
    mov r7, $4            // SYS_WRITE = 4
    swi 0

    mov r12, r5           // copy the raw integer value to 'auxiliary' register
    push {r12}
    bl print_char

r6:
    // print "r6 = 0x..."
    mov r0, $1            // syscall
    ldr r1, =str_r6       // address of text string
    ldr r2, =strlen_r6    // number of bytes to write
    mov r7, $4            // SYS_WRITE = 4
    swi 0

    mov r12, r6           // copy the raw integer value to 'auxiliary' register
    push {r12}
    bl print_char

r7:
    // print "r7 = 0x..."
    mov r0, $1            // syscall
    ldr r1, =str_r7       // address of text string
    ldr r2, =strlen_r7    // number of bytes to write
    mov r7, $4            // SYS_WRITE = 4
    swi 0

    mov r12, r7           // copy the raw integer value to 'auxiliary' register
    push {r12}
    bl print_char

r8:
    // print "r8 = 0x..."
    mov r0, $1            // syscall
    ldr r1, =str_r8       // address of text string
    ldr r2, =strlen_r8    // number of bytes to write
    mov r7, $4            // SYS_WRITE = 4
    swi 0

    mov r12, r8           // copy the raw integer value to 'auxiliary' register
    push {r12}
    bl print_char

r9:
    // print "r9 = 0x..."
    mov r0, $1            // syscall
    ldr r1, =str_r9       // address of text string
    ldr r2, =strlen_r9    // number of bytes to write
    mov r7, $4            // SYS_WRITE = 4
    swi 0

    mov r12, r8           // copy the raw integer value to 'auxiliary' register
    push {r12}
    bl print_char

end:
    pop {lr}
    bx  lr

