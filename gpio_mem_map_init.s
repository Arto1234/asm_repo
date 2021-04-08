/* Function copied from:
   https://github.com/InfinitelyManic/Raspberry-Pi-2/blob/master/gpio_init_test_via_mmap.s
   This function is run under userland, therefore used gpiomem device.
   For bare metal usage, mem device. */
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

//    .file:  .ascii          "/dev/mem\000"
.file:    .ascii          "/dev/gpiomem\000"

mmap_retval:   .word
.global mmap_retval
mmap_retval_addr:    .word   mmap_retval

/* ---------------------------------------
        Code Section
 --------------------------------------- */
.section .text
.align 2

.equ STDOUT_C,     0x1
.equ SYS_WRITE_C,  0x4
.equ PAGE_SIZE_C,  0x4096
.equ FLAGS_C,      06010002
.equ GPIO_BASE_C,  0x3F200000

.global gpio_mem_init
.type gpio_mem_init, %function
gpio_mem_init:
    mov r0, STDOUT_C
    ldr r1, =str_function_name    // address of text string
    ldr r2, =strlen_function_name // number of bytes to write
    mov r7, SYS_WRITE_C
    swi 0

    .addr_file:     .word   .file          // pointer to .file
    .flags:         .word   FLAGS_C        // rw . x       // 0x181002
    .gpiobase:      .word   GPIO_BASE_C    // base address for BCM2836

open_file:
    push {r1-r3, lr}
    ldr r0, .addr_file              // get /dev/mem file for virtual file addr
    ldr r1, .flags                  // set flag permissions         // rw - r
    bl open                         // calls open; returns file handle in r0
    pop {r1-r3, pc}

map_file:
    push {r1-r3, lr}
    str r0, [sp, #0]                // store returned file handle to 4th level of stack
    ldr r3, [sp, #0]                // copy file handle to r3
    // parameters for mmap          // nmap will map files or devices into memory
    str r3, [sp, #0]                // copy file handle to 1st level of stack for mmap
    ldr r3, .gpiobase               // GPIO base address
    str r3, [sp, #4]                // store GPIO base to 2nd level of stack for mmap
    mov r0, #0                      // null address - let the kernel choose the address
    mov r1, PAGE_SIZE_C
    mov r2, #3                      // desired memory protection type ???
    mov r3, #1
    bl mmap                         // call mmap; returns kernel mapped addr in r0

    ldr r10, =mmap_retval           // Load address for the global variable to some reg (r10)
    str r0, [r10]                   // Save r0 to global variable
    pop {r1-r3, pc}


close_file:                             // params for file close
    push {r1-r3, lr}

    ldr r0, [sp, #0]                    // get file handle

    bl close
    pop {r1-r3, pc}
