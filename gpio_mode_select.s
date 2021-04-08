/* gpio_mode_select.s
This function initialises Raspberry Pi 3's
selected GPIO pins for selected function.
Command will be given in r4 for every GPIO pin individually.

Input param: r5
---------------------------------------------
|  unused  | function |  pin nr  |   mode   |
---------------------------------------------
r5 byte 0: mode select
r8
000 = GPIO Pin x is an input
001 = GPIO Pin x is an output
100 = GPIO Pin x takes alternate function 0
101 = GPIO Pin x takes alternate function 1
110 = GPIO Pin x takes alternate function 2
111 = GPIO Pin x takes alternate function 3
011 = GPIO Pin x takes alternate function 4
010 = GPIO Pin x takes alternate function 5

r5 byte 1: pin number within tens group
r9
0..9, pin number in the section will be processed
e.g. pin 6: bits 20 19 18 will be processed.

r5 byte 2: tens group
r12
r12 = 0,  GPFSEL0 will be processed
r12 = 1,  GPFSEL1
r12 = 2,  GPFSEL2
r12 = 3,  GPFSEL3
r12 = 4,  GPFSEL4
r12 = 5,  GPFSEL5

r0 = base address 0x3F200000
r6 = offset from base address

Arto Rasimus 8.4.2021 */
.cpu cortex-a53
.fpu neon-fp-armv8
.syntax unified
.section .rodata
.align 2
/* ---------------------------------------
        Data Section
 --------------------------------------- */
.section .data
str_function_name:
    .asciz "gpio_mode_select()\n"
    strlen_function_name = .-str_function_name
str_nl:
    .asciz "\n"
    strlen_nl = .-str_nl
str_gpfsel0:
    .asciz "GPIO function 0 selected\n"        // 0
    strlen_str_func0_sel = .-str_gpfsel0
str_gpfsel1:
    .asciz "GPIO function 1 selected\n"        // 1
    strlen_str_func1_sel = .-str_gpfsel1
str_gpfsel2:
    .asciz "GPIO function 2 selected\n"        // 2
    strlen_str_func2_sel = .-str_gpfsel2
str_gpfsel3:
    .asciz "GPIO function 3 selected\n"        // 3
    strlen_str_func3_sel = .-str_gpfsel3
str_gpfsel4:
    .asciz "GPIO function 4 selected\n"        // 4
    strlen_str_func4_sel = .-str_gpfsel4
str_gpfsel5:
    .asciz "GPIO function 5 selected\n"        // 5
    strlen_str_func5_sel = .-str_gpfsel5
str_gpfset0:
    .asciz "GPIO SET function 0 selected\n"    // 6
    strlen_str_func0_set = .-str_gpfset0
str_gpfset1:
    .asciz "GPIO SET function 1 selected\n"    // 7
    strlen_str_func1_set = .-str_gpfset1
str_gpfclr0:
    .asciz "GPIO CLR function 0 selected\n"    // 10
    strlen_str_func0_clr = .-str_gpfclr0
str_gpfclr1:
    .asciz "GPIO CLR function 1 selected\n"    // 11
    strlen_str_func1_clr = .-str_gpfclr1

str_function:
    .asciz "function = "
    strlen_function = .-str_function

str_pin:
    .asciz "pin = "
    strlen_pin = .-str_pin

str_mode:
    .ascii "mode = "
    strlen_mode = .-str_mode

str_wrong_func_sel:
    .asciz "Wrong function selected\n"
    strlen_str_wrong_func_sel = .-str_wrong_func_sel

/* -------------------------------------
        Block Starting Symbol Section
 ---------------------------------------
 The portion of an object that contains statically-allocated variables
 that are declared but have not been assigned a value yet */

.section .bss
    .lcomm mode,     4
    .lcomm pin,      4
    .lcomm function, 4

/* ---------------------------------------
        Code Section
 --------------------------------------- */
.section .text
.align 2

.equ STDOUT_C,     0x1
.equ SYS_WRITE_C,  0x4
.equ STATUS_OK_C,  0x71 // Return value from check_hex_digit()
.equ STATUS_NOK_C, 0x82 // Return value from check_hex_digit()
.equ GPIO_BASE_C,  0x3F200000

.equ GPFSEL0_OFFSET_C, 0x00 // pins  0.. 9 function selection
.equ GPFSEL1_OFFSET_C, 0x04 // pins 10..19 function selection
.equ GPFSEL2_OFFSET_C, 0x08 // pins 20..29 function selection
.equ GPFSEL3_OFFSET_C, 0x0C // pins 30..39 function selection
.equ GPFSEL4_OFFSET_C, 0x10 // pins 40..49 function selection
.equ GPFSEL5_OFFSET_C, 0x14 // pins 50..53 function selection

.equ GPFSET0_OFFSET_C, 0x1C // pins  0..31 output set 0
.equ GPFSET1_OFFSET_C, 0x20 // pins 32..53 output set 1

.equ GPFCLR0_OFFSET_C, 0x28 // pins  0..31 output clear 0
.equ GPFCLR1_OFFSET_C, 0x2C // pins 32..53 output clear 1

.equ GPFLEV0_OFFSET_C, 0x34 // pins  0..31 level 0
.equ GPFLEV1_OFFSET_C, 0x38 // pins 32..53 level 1

.equ GPEDS0_OFFSET_C,    0x00000040
.equ GPEDS1_OFFSET_C,    0x00000044

.equ GPHEN0_OFFSET_C,    0x00000064
.equ GPHEN1_OFFSET_C,    0x00000068

.equ GPPUD_OFFSET_C,     0x00000094
.equ GPPUDCLK0_OFFSET_C, 0x00000098
.equ GPPUDCLK1_OFFSET_C, 0x0000009C

.global gpio_mode_select
.type gpio_mode_select, %function
gpio_mode_select:
    push {lr}

    mov r0, STDOUT_C
    ldr r1, =str_function_name    // address of text string
    ldr r2, =strlen_function_name // number of bytes to write
    mov r7, SYS_WRITE_C
    swi 0

begin:
/* Input param: r5
--------------------------------------------
|  unused  | function |  pin_nr  |   mode   |
|          |    r12   |    r9    |    r8    |
---------------------------------------------
r10 is used by read_input(), therefore r10 is not used here. */
    ldr r0, =GPIO_BASE_C            // load GPIO start address

    // mode ----------------------------------
    mov r8, r5             // save input param to local use
    and r8, $0x000000ff    // get byte 0: mode value

    mov r11, r8
    // Convert the value to ASCII to r11, just for debugging purpose
    add r11, $48
    ldr r6, =mode          // load the var addr to r6
    str r11, [r6]          // store the value to var

    // pin -----------------------------------
    mov r9, r5             // save input param to local use
    and r9, $0x0000ff00    // get byte 1: pin nr
    lsr r9, $8             // shift the bits to byte 0

    mov r11, r9
    // Convert the value to ASCII to r11, just for debugging purpose
    add r11, $48
    ldr r6, =pin           // load the var addr to r6
    str r11, [r6]          // store the value to var

    // function ------------------------------
    mov r12, r5             // save input param to local use
    and r12, $0x00ff0000    // get byte 2: register
    lsr r12, $16            // shift the bits to byte 0

    mov r11, r12
    // Convert the value to ASCII to r11, just for debugging purpose
    add r11, $48
    ldr r6, =function        // load the var addr to r6
    str r11, [r6]            // store the value to var

/*
    mov r0, STDOUT_C
    ldr r1, =str_mode        // address of text string
    ldr r2, =strlen_mode     // number of bytes to write
    mov r7, SYS_WRITE_C
    swi 0

    mov r0, STDOUT_C
    ldr r1, =mode
    ldr r2, =strlen_nl
    mov r7, SYS_WRITE_C
    swi 0

    mov r0, STDOUT_C
    ldr r1, =str_nl
    ldr r2, =strlen_nl
    mov r7, SYS_WRITE_C
    swi 0

    mov r0, STDOUT_C
    ldr r1, =str_pin
    ldr r2, =strlen_pin
    mov r7, SYS_WRITE_C
    swi 0

    mov r0, STDOUT_C
    ldr r1, =pin
    ldr r2, =strlen_nl
    mov r7, SYS_WRITE_C
    swi 0

    mov r0, STDOUT_C
    ldr r1, =str_nl
    ldr r2, =strlen_nl
    mov r7, SYS_WRITE_C
    swi 0

    mov r0, STDOUT_C
    ldr r1, =str_function
    ldr r2, =strlen_function
    mov r7, SYS_WRITE_C
    swi 0

    mov r0, STDOUT_C
    ldr r1, =function
    ldr r2, =strlen_nl
    mov r7, SYS_WRITE_C
    swi 0

    mov r0, STDOUT_C
    ldr r1, =str_nl
    ldr r2, =strlen_nl
    mov r7, SYS_WRITE_C
    swi 0

    mov r0, STDOUT_C
    ldr r1, =str_nl         // address of text string
    ldr r2, =strlen_nl      // number of bytes to write
    mov r7, SYS_WRITE_C
    swi 0
*/
    cmp r12, $0              // checked if r12 == 0: GPFSEL0
    beq gpfsel0

    cmp r12, $1              // checked if r12 == 1: GPFSEL1
    beq gpfsel1

    cmp r12, $2              // checked if r12 == 2: GPFSEL2
    beq gpfsel2

    cmp r12, $3              // checked if r12 == 3: GPFSEL3
    beq gpfsel3

    cmp r12, $4              // checked if r12 == 4: GPFSEL4
    beq gpfsel4

    cmp r12, $5              // checked if r12 == 5: GPFSEL5
    beq gpfsel5

    cmp r12, $7              // checked if r12 == 7: GPFSET0
    beq gpfset0

    cmp r12, $8              // checked if r12 == 8: GPFSET1
    beq gpfset1

    cmp r12, $10             // checked if r12 == 10: GPFCLR0
    beq gpfclr0

    cmp r12, $11             // checked if r12 == 11: GPFCLR1
    beq gpfclr1

    b print_wrong_func_sel    // otherwise print error & quit

print_wrong_func_sel:
    mov r0, STDOUT_C
    ldr r1, =str_wrong_func_sel        // address of text string
    ldr r2, =strlen_str_wrong_func_sel // number of bytes to write
    mov r7, SYS_WRITE_C
    swi 0

    b end

/* Input param: r5
--------------------------------------------
|  unused  | function |  pin nr  |   mode   |
|          |    r12   |    r9    |    r8    |
---------------------------------------------
r0 = GPIO base address
r1 = GPIO mode bit location (0..31)
r3 = bit location
r8 = mode
r9 = pin_nr
r6 = address, where mode selection bits will be shifted to
*/

gpfsel0:
    mov r0, STDOUT_C
    ldr r1, =str_gpfsel0            // address of text string
    ldr r2, =strlen_str_func0_sel   // number of bytes to write
    mov r7, SYS_WRITE_C
    swi 0

    // 3 * pin_nr: to the place of correct bit
    // r9: pin_nr * 3 is the amount by which the 3 mode bits are shifted
    add r9, r9, r9, lsl $1          // r9 * 3.  r9 = r9 + (r9 << 1)
    lsl r8, r9                      // mode bits are shifted left (3 x pin_nr)

    mov r2, GPFSEL0_OFFSET_C        // function offset
    add r2, r0, r2                  // target address = base + function offset

    // TODO: move the mode bits to correct location

gpfsel1:
    mov r0, STDOUT_C
    ldr r1, =str_gpfsel1            // address of text string
    ldr r2, =strlen_str_func1_sel   // number of bytes to write
    mov r7, SYS_WRITE_C
    swi 0

    // 3 * pin_nr: to the place of correct bit
    // r9: pin_nr * 3 is the amount by which the 3 mode bits are shifted
    add r9, r9, r9, lsl $1          // r9 * 3.  r9 = r9 + (r9 << 1)
    lsl r8, r9                      // mode bits are shifted left (3 x pin_nr)

    mov r2, GPFSEL1_OFFSET_C        // function offset
    add r2, r0, r2                  // target address = base + function offset

    // TODO: move the mode bits to correct location

    b end

gpfsel2:
    mov r0, STDOUT_C
    ldr r1, =str_gpfsel2            // address of text string
    ldr r2, =strlen_str_func2_sel   // number of bytes to write
    mov r7, SYS_WRITE_C
    swi 0

    // 3 * pin_nr: to the place of correct bit
    // r9: pin_nr * 3 is the amount by which the 3 mode bits are shifted
    add r9, r9, r9, lsl $1          // r9 * 3.  r9 = r9 + (r9 << 1)
    lsl r8, r9                      // mode bits are shifted left (3 x pin_nr)

    mov r2, GPFSEL2_OFFSET_C        // function offset
    add r2, r0, r2                  // target address = base + function offset

    // TODO: move the mode bits to correct location

    b end
gpfsel3:
    mov r0, STDOUT_C
    ldr r1, =str_gpfsel3            // address of text string
    ldr r2, =strlen_str_func3_sel   // number of bytes to write
    mov r7, SYS_WRITE_C
    swi 0
    b end
gpfsel4:
    mov r0, STDOUT_C
    ldr r1, =str_gpfsel4            // address of text string
    ldr r2, =strlen_str_func4_sel   // number of bytes to write
    mov r7, SYS_WRITE_C
    swi 0
    b end
gpfsel5:
    mov r0, STDOUT_C
    ldr r1, =str_gpfsel5            // address of text string
    ldr r2, =strlen_str_func5_sel   // number of bytes to write
    mov r7, SYS_WRITE_C
    swi 0
    b end
gpfset0:
    mov r0, STDOUT_C
    ldr r1, =str_gpfset0            // address of text string
    ldr r2, =strlen_str_func0_set   // number of bytes to write
    mov r7, SYS_WRITE_C
    swi 0
    b end
gpfset1:
    mov r0, STDOUT_C
    ldr r1, =str_gpfset1            // address of text string
    ldr r2, =strlen_str_func1_set   // number of bytes to write
    mov r7, SYS_WRITE_C
    swi 0
    b end
gpfclr0:
    mov r0, STDOUT_C
    ldr r1, =str_gpfclr0            // address of text string
    ldr r2, =strlen_str_func0_clr   // number of bytes to write
    mov r7, SYS_WRITE_C
    swi 0
    b end
gpfclr1:
    mov r0, STDOUT_C
    ldr r1, =str_gpfclr1            // address of text string
    ldr r2, =strlen_str_func1_clr   // number of bytes to write
    mov r7, SYS_WRITE_C
    swi 0
    b end
end:
    pop {pc}

/*
GPFSEL0 pins 0-9
31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
un un 09 09 09 08 08 08 07 07 07 06 06 06 05 05 05 04 04 04 03 03 03 02 02 02 01 01 01 00 00 00
GPFSEL1 pins 10-19
31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
un un 19 19 19 18 18 18 17 17 17 16 16 16 15 15 15 14 14 14 13 13 13 12 12 12 11 11 11 10 10 10
GPFSEL2 pins 20-29
31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
un un 29 29 29 28 28 28 27 27 27 26 26 26 25 25 25 24 24 24 23 23 23 22 22 22 21 21 21 20 20 20
GPFSEL3 pins 30-39
31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
un un 39 39 39 38 38 38 37 37 37 36 36 36 35 35 35 34 34 34 33 33 33 32 32 32 31 31 31 30 30 30
GPFSEL4 pins 40-49
31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
un un 49 49 49 48 48 48 47 47 47 46 46 46 45 45 45 44 44 44 43 43 43 42 42 42 41 41 41 40 40 40
GPFSEL5 pins 50-53
31 30 29 28 27 26 25 24 23 22 21 20 19 18 17 16 15 14 13 12 11 10 09 08 07 06 05 04 03 02 01 00
un un un un un un un un un un un un un un un un un un un un 53 53 53 52 52 52 51 51 51 50 50 50
GPFSEL10 GPCLR0 pins 0-31
GPFSEL11 GPCLR1 pins 32-53

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
14 base + 0x38 GPFLEV1  pins 32..53 level 1

000 = GPIO Pin x is an input
001 = GPIO Pin x is an output
100 = GPIO Pin x takes alternate function 0
101 = GPIO Pin x takes alternate function 1
110 = GPIO Pin x takes alternate function 2
111 = GPIO Pin x takes alternate function 3
011 = GPIO Pin x takes alternate function 4
010 = GPIO Pin x takes alternate function 5
*/
