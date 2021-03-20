/* saveregs.s
saveregs function saves registers' contents to global variables.
This function is used e.g. by debug_print()
Arto Rasimus 14.3.2021 */
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
    .asciz "saveregs()\n"
    strlen_function_name = .-str_function_name

// Initialised with some values.
r0_save:  .word 0x87654321
r1_save:  .word 0x10001
r2_save:  .word 0x20002
r3_save:  .word 0x30003
r4_save:  .word 0x40004
r5_save:  .word 0x50005
r6_save:  .word 0x60006
r7_save:  .word 0x70007
r8_save:  .word 0x80008
r9_save:  .word 0x90009
r10_save: .word 0xA000A
r11_save: .word 0xB000B
r12_save: .word 0xC000C
r13_save: .word 0xD000D
r14_save: .word 0xE000E
r15_save: .word 0xF000F

.global r0_save
.global r1_save
.global r2_save
.global r3_save
.global r4_save
.global r5_save
.global r6_save
.global r7_save
.global r8_save
.global r9_save
.global r10_save
.global r11_save
.global r12_save
.global r13_save
.global r14_save
.global r15_save

r0_save_addr:    .word   r0_save
r1_save_addr:    .word   r1_save
r2_save_addr:    .word   r2_save
r3_save_addr:    .word   r3_save
r4_save_addr:    .word   r4_save
r5_save_addr:    .word   r5_save
r6_save_addr:    .word   r6_save
r7_save_addr:    .word   r7_save
r8_save_addr:    .word   r8_save
r9_save_addr:    .word   r9_save
r10_save_addr:   .word  r10_save
r11_save_addr:   .word  r11_save
r12_save_addr:   .word  r12_save
r13_save_addr:   .word  r13_save
r14_save_addr:   .word  r14_save

reg_val_addr:
    .global reg_val_addr
aux_reg_val:
    .global aux_reg_val_addr


@ ---------------------------------------
@       Code Section
@ ---------------------------------------
.section .text
.align 2
.global saveregs
.type saveregs, %function
saveregs:
    ldr r10, =r0_save        // Load address for the global variable to some reg (r10)
    str r0, [r10]            // Save r0 to global variable

    ldr r10, =r1_save        // Load address for the global variable to some reg (r10)
    str r1, [r10]            // Save r1 to global variable

    ldr r10, =r2_save        // Load address for the global variable to some reg (r10)
    str r2, [r10]            // Save r2 to global variable

    ldr r10, =r3_save        // Load address for the global variable to some reg (r10)
    str r3, [r10]            // Save r3 to global variable

    ldr r10, =r4_save        // Load address for the global variable to some reg (r10)
    str r4, [r10]            // Save r4 to global variable

    ldr r10, =r5_save        // Load address for the global variable to some reg (r10)
    str r5, [r10]            // Save r5 to global variable

    ldr r10, =r6_save        // Load address for the global variable to some reg (r10)
    str r6, [r10]            // Save r6 to global variable

    ldr r10, =r7_save        // Load address for the global variable to some reg (r10)
    str r7, [r10]            // Save r7 to global variable

    ldr r10, =r8_save        // Load address for the global variable to some reg (r10)
    str r8, [r10]            // Save r8 to global variable

    ldr r10, =r9_save        // Load address for the global variable to some reg (r10)
    str r9, [r10]            // Save r9 to global variable

    ldr r9, =r10_save        // Load address for the global variable to some reg (r9)
    str r10, [r9]            // Save r10 to global variable

    bx lr
