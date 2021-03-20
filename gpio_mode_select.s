/* gpio_mode_select.s
This function initialises Raspberry Pi 3's
selected GPIO pins for selected function.
Command will be given in r4 for every GPIO pin individually.

Input param: r3
--------------------------------------------
|  unused  | register |  pin nr  |   mode   |
---------------------------------------------
r3 byte 0: mode select
r4
000 = GPIO Pin x is an input
001 = GPIO Pin x is an output
100 = GPIO Pin x takes alternate function 0
101 = GPIO Pin x takes alternate function 1
110 = GPIO Pin x takes alternate function 2
111 = GPIO Pin x takes alternate function 3
011 = GPIO Pin x takes alternate function 4
010 = GPIO Pin x takes alternate function 5

r3 byte 1: pin number within tens group
r5
0..9, pin number in the section will be processed
e.g. pin 6: bits 20 19 18 will be processed.

r3 byte 2: tens group
r6
r6 = 0,  GPFSEL0 will be processed
r6 = 1,  GPFSEL1
r6 = 2,  GPFSEL2
r6 = 3,  GPFSEL3
r6 = 4,  GPFSEL4
r6 = 5,  GPFSEL5

r0 = base address 0x3F200000
r8 = offset from base address

Arto Rasimus 6.3.2021 */
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
    .asciz "gpio_mode_select()\n"
    strlen_function_name = .-str_function_name
nl:
    .asciz "\n"
    strlen_nl = .-nl
msg_gpfsel0:
    .asciz "GPIO function 0 selected\n"        // 0
    strlen_msg_func0_sel = .-msg_gpfsel0
msg_gpfsel1:
    .asciz "GPIO function 1 selected\n"        // 1
    strlen_msg_func1_sel = .-msg_gpfsel1
msg_gpfsel2:
    .asciz "GPIO function 2 selected\n"        // 2
    strlen_msg_func2_sel = .-msg_gpfsel2
msg_gpfsel3:
    .asciz "GPIO function 3 selected\n"        // 3
    strlen_msg_func3_sel = .-msg_gpfsel3
msg_gpfsel4:
    .asciz "GPIO function 4 selected\n"        // 4
    strlen_msg_func4_sel = .-msg_gpfsel4
msg_gpfsel5:
    .asciz "GPIO function 5 selected\n"        // 5
    strlen_msg_func5_sel = .-msg_gpfsel5
msg_gpfset0:
    .asciz "GPIO SET function 0 selected\n"    // 6
    strlen_msg_func0_set = .-msg_gpfset0
msg_gpfset1:
    .asciz "GPIO SET function 1 selected\n"    // 7
    strlen_msg_func1_set = .-msg_gpfset1
msg_gpfclr0:
    .asciz "GPIO CLR function 0 selected\n"    // 10
    strlen_msg_func0_clr = .-msg_gpfclr0
msg_gpfclr1:
    .asciz "GPIO CLR function 1 selected\n"    // 11
    strlen_msg_func1_clr = .-msg_gpfclr1
msg_wrong_func_sel:
    .asciz "Wrong function selected\n"
    strlen_msg_wrong_func_sel = .-msg_wrong_func_sel

mode:
    .byte  // GPIO mode select
pin:
    .byte  // GPIO pin number
funct:
    .byte  // GPIO function


@ ---------------------------------------
@       Block Starting Symbol Section
@ ---------------------------------------
@ The portion of an object that contains statically-allocated variables
@ that are declared but have not been assigned a value yet

.section .bss
    .lcomm gpfsel0_offset,  0x00 // pins  0.. 9 function selection
    .lcomm gpfsel1_offset,  0x04 // pins 10..19 function selection
    .lcomm gpfsel2_offset,  0x08 // pins 20..29 function selection
    .lcomm gpfsel3_offset,  0x0C // pins 30..39 function selection
    .lcomm gpfsel4_offset,  0x10 // pins 40..49 function selection
    .lcomm gpfsel5_offset,  0x14 // pins 50..53 function selection

    .lcomm gpfset0_offset,  0x1C // pins  0..31 output set 0
    .lcomm gpfset1_offset,  0x20 // pins 32..53 output set 1

    .lcomm gpfclr0_offset,  0x28 // pins  0..31 output clear 0
    .lcomm gpfclr1_offset,  0x2C // pins 32..53 output clear 1

    .lcomm gpflev0_offset,  0x34 // pins  0..31 level 0
    .lcomm gpflev1_offset,  0x38 // pins 32..53 level 1


@ ---------------------------------------
@	Code Section
@ ---------------------------------------
.section .text
.align 2

.global gpio_input
.type gpio_input, %function
gpio_input:
    mov r0, $1                    // syscall
    ldr r1, =str_function_name_mode_select // address of text string
    ldr r2, =strlen_function_name // number of bytes to write
    mov r7, $4                    // SYS_WRITE = 4
    swi 0

    push     {lr}
//    b print_msg_input

begin:
//    bl  debug_print


/* Input param: r3
--------------------------------------------
|  unused  | register |  pin_nr  |   mode   |
|          |    r6    |    r5    |    r4    |
--------------------------------------------- */
function_selection:
    .equ GPFSEL0,   0x00000000 // pins  0.. 9 function selection
    .equ GPFSEL1,   0x00000004 // pins 10..19 function selection
    .equ GPFSEL2,   0x00000008 // pins 20..29 function selection
    .equ GPFSEL3,   0x0000000C // pins 30..39 function selection
    .equ GPFSEL4,   0x00000010 // pins 40..49 function selection
    .equ GPFSEL5,   0x00000014 // pins 50..53 function selection

    .equ GPSET0,    0x0000001C // pins  0..31 output set 0
    .equ GPSET1,    0x00000020 // pins 32..53 output set 1

    .equ GPCLR0,    0x00000028 // pins  0..31 output clear 0
    .equ GPCLR1,    0x0000002C // pins 32..53 output clear 1

    .equ GPLEV0,    0x00000034 // pins  0..31 level 0
    .equ GPLEV1,    0x00000038 // pins 32..53 level 1

    .equ GPEDS0,    0x00000040 
    .equ GPEDS1,    0x00000044 

    .equ GPHEN0,    0x00000064 
    .equ GPHEN1,    0x00000068 

    .equ GPPUD,     0x00000094 
    .equ GPPUDCLK0, 0x00000098 
    .equ GPPUDCLK1, 0x0000009C 


ldr r3, =$0x00000201 // just testing

    mov r4, r3
    and r4, $0x000000ff    // get byte 0: mode value

    mov r5, r3
    and r5, $0x0000ff00    // get byte 1: pin nr
    lsr r5, $8             // shift the bits to byte 0

    mov r6, r3
    and r6, $0x00ff0000    // get byte 2: register
    lsr r6, $16            // shift the bits to byte 0

//    bl  debug_print

//    ldr r0, =mode          // load address of mode to r0
//    ldr r4, [r0]

//    ldr r0, =pin
//    ldr r5, [r0]

//    ldr r0, =funct
//    ldr r6, [r0]

    tst r6, $0              // checked if r4 == 0: GPFSEL0
    beq gpfsel0

    tst r6, $1              // checked if r4 == 1: GPFSEL1
    beq gpfsel1

    tst r6, $2              // checked if r4 == 2: GPFSEL2
    beq gpfsel2

    tst r6, $3              // checked if r4 == 3: GPFSEL3
    beq gpfsel3

    tst r6, $4              // checked if r4 == 4: GPFSEL4
    beq gpfsel4

    tst r6, $5              // checked if r4 == 5: GPFSEL5
    beq gpfsel5

    tst r6, $7              // GPFSET0
    beq gpfset0

    tst r6, $8              // GPFSET1
    beq gpfset1

    tst r6, $10             // GPFCLR0
    beq gpfclr0

    tst r6, $11             // GPFCLR1
    beq gpfclr1


    b       print_wrong_func_sel    // otherwise quit

print_wrong_func_sel:
    mov r0, $1                         // syscall
    ldr r1, =msg_wrong_func_sel        // address of text string
    ldr r2, =strlen_msg_wrong_func_sel // number of bytes to write
    mov r7, $4                         // SYS_WRITE = 4
    swi 0

    b end

/* Input param: r3
--------------------------------------------
|  unused  | register |  pin nr  |   mode   |
|          |    r6    |    r5    |    r4    |
---------------------------------------------
r0 = GPIO base address
r1 = GPIO mode bit location (0..31)
r3 = bit location
r4 = mode
r5 = pin_nr
r8 = address, where mode selection bits will be shifted to
*/
gpfsel0:
    mov r0, $1                         // syscall
    ldr r1, =msg_gpfsel0               // address of text string
    ldr r2, =strlen_msg_func0_sel      // number of bytes to write
    mov r7, $4                         // SYS_WRITE = 4
    swi 0

//    ldr r0, gpio_start_addr            // load GPIO start address
//    mov r2, r4                         // mode value (for 'output' it is 001)

    // Pin_nr * 3  --> r1
    // E.g. if r5 = (pin) 4, then r1 = r5 * 3 = 12 (bit position)

    // shiftin määrä
    mov r1, r4  // mode

    // 3* pin_nr: oikean bitin kohdalle
    mov r2, $0
    add r2, r5, r5, lsl $1             // r5 * 3 --> r3   r5 = r5 + (r5 << 1)
    lsl r1, r2   // mode bits are shifted left (3 x pin_nr)

    // r2 contains correct bit shift conter
//    lsl r4, r2  // mode bits are shifted to the GPIO pin's place

    // mode bits are transferred to GPIO driver

//    str r1, [r0, $GPFSEL0] // 0 = function offset  CRASH!!!!!
              //  |
              // gpfsel offset 0..0x34


//    mov r8, r4
//    bl  debug_print


    b end

gpfsel1:
    mov r0, $1                         // syscall
    ldr r1, =msg_gpfsel1               // address of text string
    ldr r2, =strlen_msg_func1_sel      // number of bytes to write
    mov r7, $4                         // SYS_WRITE = 4
    swi 0


gpfsel2:
    mov r0, $1                         // syscall
    ldr r1, =msg_gpfsel2               // address of text string
    ldr r2, =strlen_msg_func2_sel      // number of bytes to write
    mov r7, $4                         // SYS_WRITE = 4
    swi 0


gpfsel3:
    mov r0, $1                         // syscall
    ldr r1, =msg_gpfsel3               // address of text string
    ldr r2, =strlen_msg_func3_sel      // number of bytes to write
    mov r7, $4                         // SYS_WRITE = 4
    swi 0


gpfsel4:
    mov r0, $1                         // syscall
    ldr r1, =msg_gpfsel4               // address of text string
    ldr r2, =strlen_msg_func4_sel      // number of bytes to write
    mov r7, $4                         // SYS_WRITE = 4
    swi 0


gpfsel5:
    mov r0, $1                         // syscall
    ldr r1, =msg_gpfsel5               // address of text string
    ldr r2, =strlen_msg_func5_sel      // number of bytes to write
    mov r7, $4                         // SYS_WRITE = 4
    swi 0


gpfset0:
    mov r0, $1                         // syscall
    ldr r1, =msg_gpfset0               // address of text string
    ldr r2, =strlen_msg_func0_set      // number of bytes to write
    mov r7, $4                         // SYS_WRITE = 4
    swi 0


gpfset1:
    mov r0, $1                         // syscall
    ldr r1, =msg_gpfset1               // address of text string
    ldr r2, =strlen_msg_func1_set      // number of bytes to write
    mov r7, $4                         // SYS_WRITE = 4
    swi 0


gpfclr0:
    mov r0, $1                         // syscall
    ldr r1, =msg_gpfclr0               // address of text string
    ldr r2, =strlen_msg_func0_clr      // number of bytes to write
    mov r7, $4                         // SYS_WRITE = 4
    swi 0


gpfclr1:
    mov r0, $1                         // syscall
    ldr r1, =msg_gpfclr1               // address of text string
    ldr r2, =strlen_msg_func1_clr      // number of bytes to write
    mov r7, $4                         // SYS_WRITE = 4
    swi 0


print_msg_input:
//    b begin

//end:
    pop {lr}
    bx  lr
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
