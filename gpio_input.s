/* gpio_input.s
This function initialises Raspberry Pi 3's
selected GPIO pins for selected function.
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
str_function_name:
    .asciz "gpio_input()\n"
    strlen_function_name = .-str_function_name

nl:
    .asciz "\n"
    strlen_nl = .-nl

msg_gpfsel0:
    .asciz "GPIO function 0 selected\n"
    strlen_msg_func0_sel = .-msg_gpfsel0
msg_gpfsel1:
    .asciz "GPIO function 1 selected\n"
    strlen_msg_func1_sel = .-msg_gpfsel1
msg_gpfsel2:
    .asciz "GPIO function 2 selected\n"
    strlen_msg_func2_sel = .-msg_gpfsel2
msg_gpfsel3:
    .asciz "GPIO function 3 selected\n"
    strlen_msg_func3_sel = .-msg_gpfsel3
msg_gpfsel4:
    .asciz "GPIO function 4 selected\n"
    strlen_msg_func4_sel = .-msg_gpfsel4
msg_gpfsel5:
    .asciz "GPIO function 5 selected\n"
    strlen_msg_func5_sel = .-msg_gpfsel5
msg_gpfset0:
    .asciz "GPIO SET function 0 selected\n"
    strlen_msg_func0_set = .-msg_gpfset0
msg_gpfset1:
    .asciz "GPIO SET function 1 selected\n"
    strlen_msg_func1_set = .-msg_gpfset1
msg_gpfclr0:
    .asciz "GPIO CLR function 0 selected\n"
    strlen_msg_func0_clr = .-msg_gpfclr0
msg_gpfclr1:
    .asciz "GPIO CLR function 1 selected\n"
    strlen_msg_func1_clr = .-msg_gpfclr1

msg_wrong_func_sel:
    .asciz "Wrong function selected\n"
    strlen_msg_wrong_func_sel = .-msg_wrong_func_sel

@ ---------------------------------------
@       Block Starting Symbol Section
@ ---------------------------------------
@ The portion of an object that contains statically-allocated variables
@ that are declared but have not been assigned a value yet

//.section .bss
//    .lcomm times, 1     // 1 byte for local common storage

@ ---------------------------------------
@	Code Section
@ ---------------------------------------
.section .text
.align 2

.global gpio_input
.type gpio_input, %function
gpio_input:
    mov r0, $1            // syscall
    ldr r1, =str_function_name // address of text string
    ldr r2, =strlen_function_name // number of bytes to write
    mov r7, $4            // SYS_WRITE = 4
    swi 0

    push     {lr}
//    b print_msg_input

alku:
    bl debug_print

function_selection:
    ldr     r3, gpiobase      // load GPIO start address

    cmp     r4, $0             // GPFSEL0
    beq     gpfsel0
    cmp     r4, $1             // checked if r4 == 1
    beq     gpfsel1            // GPFSEL1
    cmp     r4, $2             // GPFSEL2
    beq     gpfsel2
    cmp     r4, $3             // GPFSEL3
    beq     gpfsel3
    cmp     r4, $4             // GPFSEL4
    beq     gpfsel4
    cmp     r4, $5             // GPFSEL5
    beq     gpfsel5
    cmp     r4, $7             // GPFSET0
    beq     gpfset0
    cmp     r4, $8             // GPFSET1
    beq     gpfset1
    cmp     r4, $10            // GPFCLR0
    beq     gpfclr0
    cmp     r4, $11            // GPFCLR1
    beq     gpfclr1

    b       print_wrong_func_sel    // otherwise quit


/*
input params:
r4 = 0,  GPFSEL0 will be processed
r4 = 1,  GPFSEL1
r4 = 2,  GPFSEL2
r4 = 3,  GPFSEL3
r4 = 4,  GPFSEL4
r4 = 5,  GPFSEL5
r4 = 7,  GPSET0
r4 = 8,  GPSET1
r4 = 10, GPFCLR0
r4 = 11, GPFCLR1

r5 = 0..9, pin number in the section will be processed
e.g. pin 6: bits 20 19 18 will be processed */

print_wrong_func_sel:
    mov r0, $1                         // syscall
    ldr r1, =msg_wrong_func_sel        // address of text string
    ldr r2, =strlen_msg_wrong_func_sel // number of bytes to write
    mov r7, $4                         // SYS_WRITE = 4
    swi 0

    b end
gpfsel0:
    mov r0, $1                         // syscall
    ldr r1, =msg_gpfsel0               // address of text string
    ldr r2, =strlen_msg_func0_sel      // number of bytes to write
    mov r7, $4                         // SYS_WRITE = 4
    swi 0

    // r4: tämä funktio
    // r5: bitti
    // i = 0
// loop:
    // 6 * r5 + i (select)
    // i += 1
    // i < 3 ?
    // goto loop

    b end
gpfsel1:
    mov r0, $1                         // syscall
    ldr r1, =msg_gpfsel1               // address of text string
    ldr r2, =strlen_msg_func1_sel      // number of bytes to write
    mov r7, $4                         // SYS_WRITE = 4
    swi 0

    b end
gpfsel2:
    mov r0, $1                         // syscall
    ldr r1, =msg_gpfsel2               // address of text string
    ldr r2, =strlen_msg_func2_sel      // number of bytes to write
    mov r7, $4                         // SYS_WRITE = 4
    swi 0

    b end
gpfsel3:
    mov r0, $1                         // syscall
    ldr r1, =msg_gpfsel3               // address of text string
    ldr r2, =strlen_msg_func3_sel      // number of bytes to write
    mov r7, $4                         // SYS_WRITE = 4
    swi 0

    b end
gpfsel4:
    mov r0, $1                         // syscall
    ldr r1, =msg_gpfsel4               // address of text string
    ldr r2, =strlen_msg_func4_sel      // number of bytes to write
    mov r7, $4                         // SYS_WRITE = 4
    swi 0

    b end
gpfsel5:
    mov r0, $1                         // syscall
    ldr r1, =msg_gpfsel5               // address of text string
    ldr r2, =strlen_msg_func5_sel      // number of bytes to write
    mov r7, $4                         // SYS_WRITE = 4
    swi 0

    b end
gpfset0:
    mov r0, $1                         // syscall
    ldr r1, =msg_gpfset0               // address of text string
    ldr r2, =strlen_msg_func0_set      // number of bytes to write
    mov r7, $4                         // SYS_WRITE = 4
    swi 0

    b end
gpfset1:
    mov r0, $1                         // syscall
    ldr r1, =msg_gpfset1               // address of text string
    ldr r2, =strlen_msg_func1_set      // number of bytes to write
    mov r7, $4                         // SYS_WRITE = 4
    swi 0

    b end
gpfclr0:
    mov r0, $1                         // syscall
    ldr r1, =msg_gpfclr0               // address of text string
    ldr r2, =strlen_msg_func0_clr      // number of bytes to write
    mov r7, $4                         // SYS_WRITE = 4
    swi 0

    b end
gpfclr1:
    mov r0, $1                         // syscall
    ldr r1, =msg_gpfclr1               // address of text string
    ldr r2, =strlen_msg_func1_clr      // number of bytes to write
    mov r7, $4                         // SYS_WRITE = 4
    swi 0

    b end

gpiobase:
    .word   0x3F200000
//.load_rpi3_startup:  originaali koodi
//    .word   1059061808         // 0x3F20 0030


print_msg_input:
    b alku

end:
    pop {lr}
    bx  lr
/*
GPFSEL0
31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
un un 09 09 09 08 08 08 07 07 07 06 06 06 05 05 05 04 04 04 03 03 03 02 02 02 01 01 01 00 00 00
GPFSEL1
31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
un un 19 19 19 18 18 18 17 17 17 16 16 16 15 15 15 14 14 14 13 13 13 12 12 12 11 11 11 10 10 10
GPFSEL2
31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
un un 29 29 29 28 28 28 27 27 27 26 26 26 25 25 25 24 24 24 23 23 23 22 22 22 21 21 21 20 20 20
GPFSEL3
31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
un un 39 39 39 38 38 38 37 37 37 36 36 36 35 35 35 34 34 34 33 33 33 32 32 32 31 31 31 30 30 30
GPFSEL4
31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
un un 49 49 49 48 48 48 47 47 47 46 46 46 45 45 45 44 44 44 43 43 43 42 42 42 41 41 41 40 40 40
GPFSEL5
31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
un un un un un un un un un un un un un un un un un un un un 53 53 53 52 52 52 51 51 51 50 50 50
*/



/*
Raspberry Pi 3 and Raspberry Pi 4 GPIO addresses
base = 0x3F20 0000
 0 base + 0x00 GPFSEL0  pins  0..9  function selection
 1 base + 0x04 GPFSEL1  pins 10..19 function selection
 2 base + 0x08 GPFSEL2  pins 20..29 function selection
 3 base + 0x0C GPFSEL3  pins 30..39 function selection
 4 base + 0x10 GPFSEL4  pins 40..49 function selection
 5 base + 0x14 GPFSEL5  pins 50..53 function selection
 6 base + 0x18 -
 7 base + 0x1C GPSET0   pins  0..31 output set 0
 8 base + 0x20 GPSET1   pins 32..53 output set 1
 9 base + 0x24 -
10 base + 0x28 GPFCLR0  pins  0..31 output clear 0
11 base + 0x2C GPFCLR1  pins 32..53 output clear 1
12 base + 0x30 -
13 base + 0x34 GPFLEV0  pins  0..31 level 0
14 base + 0c38 GPFLEV1  pins 32..53 level 1

input  = 0
output = 1
low    = 0
high   = 1

*/
