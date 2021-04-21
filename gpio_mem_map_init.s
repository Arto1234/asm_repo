/* This function is run under userland, therefore used gpiomem device.
   For bare metal approach, /dev/mem device must be used. */
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
    .asciz "gpio_mem_init()\n"
    strlen_function_name = .-str_function_name

gpiomem:    .asciz          "/dev/gpiomem"

mmap_retval:   .word  0x12345678
.global mmap_retval
mmap_retval_addr:    .word   mmap_retval

/* ---------------------------------------
        Code Section
 --------------------------------------- */
.section .text
.align 2

.equ STDOUT_C,      0x1
.equ SYS_WRITE_C,   0x4
.equ PAGE_SIZE_C,   0x4096
.equ FLAGS_C,       0x101002
//.equ GPIO_BASE_C,   0x3F200000
.equ OPEN_C,        5
.equ PROT_RW_C,     3
.equ MAP_SHARED_C,  1
.equ MMAP2_C,       192
//.equ EXIT_C,        248
.equ RET_SUCCESS_C, 0

.global gpio_mem_init
.type gpio_mem_init, %function
gpio_mem_init:
    mov r0, STDOUT_C
    ldr r1, =str_function_name    // address of text string
    ldr r2, =strlen_function_name // number of bytes to write
    mov r7, SYS_WRITE_C
    swi 0

map_file:
    ldr     r0, =gpiomem
    ldr     r1, =FLAGS_C    // O_RDWR | O_SYNC
    mov     r7, OPEN_C      // open
    svc     $0

    mov     r4, r0          // file descriptor
    mov     r0, #0          // kernel chooses address
    mov     r1, PAGE_SIZE_C // map size
    mov     r2, PROT_RW_C   // PROT_READ | PROT_WRITE
    mov     r3, MAP_SHARED_C// MAP_SHARED
    mov     r5, #0          // offset
    mov     r7, MMAP2_C     // mmap2
    svc     #0

    mov     r0, #0          // return code
//  mov     r7, EXIT_C      // exit
//  svc     #0

    ldr r10, =mmap_retval           // Load address for the global variable to some reg (r10)
    str r0, [r10]                   // Save r0 to global variable


    bx lr
