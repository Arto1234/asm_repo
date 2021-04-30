/* main.s
_start function calls subfunctions
Program is meant to be run in Raspberry Pi 3 and compatible.
Arto Rasimus 1.3.2021 */
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
    .asciz "_start()\n"
    strlen_function_name = .-str_function_name

message1:
    .asciz "Hello, World!\n"
    len_msg1 = .-message1

message2:
    .asciz "Bye, World!\n"
    len_msg2 = .-message2


/* ---------------------------------------
        Code Section
 --------------------------------------- */
.section .text
.align 2

.equ STDOUT_C,     0x1
.equ SYS_EXIT_C,   0x1
.equ SYS_WRITE_C,  0x4
.equ EOF_C,        999

.global _start
.type _start, %function
_start:
    mov r0, STDOUT_C
    ldr r1, =str_function_name    // address of text string
    ldr r2, =strlen_function_name // number of bytes to write
    mov r7, SYS_WRITE_C
    swi 0

    bl gpio_mem_init     // kernel mapped address is returned in mmap_retval variable
//    bl read_input        // return value is stored in r5
    bl read_cfg_file_row   // return value is stored in r5
//    bl gpio_mode_select    // receives modeset value in r5


/*
loop:
    cmp r4, $0         // if count = 0, then no print
    beq end_msg

    mov r0, $1         // use syscall
    ldr r1, =message1  // address of text string
    ldr r2, =len_msg1  // number of bytes to write
    mov r7, $4         // SYS_WRITE = 4
    swi 0

    sub r4, $1
    cmp r4, $1
    bge loop
*/
/*
end_msg:
    cmp r5, $0        // compared the given value (from sub routine)
    bgt end

    mov r0, $1        // stdout
    ldr r1, =message2 // address of text string
    ldr r2, =len_msg2 // number of bytes to write
    mov r7, $4        // SYS_WRITE
    swi 0

end:
*/
    mov r0, $0        // exit with 0 exit code
    mov r7, SYS_EXIT_C
    swi 0             // SW interrupt
