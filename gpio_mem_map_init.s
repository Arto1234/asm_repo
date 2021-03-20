// https://github.com/InfinitelyManic/Raspberry-Pi-2/blob/master/gpio_init_test_via_mmap.s

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
    .asciz "gpio_mem_init()\n"
    strlen_function_name = .-str_function_name

//    .file:  .ascii          "/dev/mem\000"
.file:    .ascii          "/dev/gpiomem\000"

retval:   .word


.section .text
.align 2
.global gpio_mem_init
.type gpio_mem_init, %function
gpio_mem_init:
    mov r0, $1                    // syscall
    ldr r1, =str_function_name    // address of text string
    ldr r2, =strlen_function_name // number of bytes to write
    mov r7, $4                    // SYS_WRITE = 4
    swi 0

    .addr_file:     .word   .file           // pointer to .file
    .flags:         .word   06010002        // rw . x       // 0x181002
    .gpiobase:      .word   0x3F200000      // base address for BCM2836


open_file:
    push {r1-r3, lr}
    ldr r0, .addr_file                  // get /dev/mem file for virtual file addr
    ldr r1, .flags                      // set flag permissions         // rw - r
    bl open                             // calls open; returns file handle in r0
    pop {r1-r3, pc}

map_file:
    push {r1-r3, lr}
    str r0, [sp, #0]                    // store returned file handle to 4th level of stack
    ldr r3, [sp, #0]                    // copy file handle to r3
    // parameters for mmap              // nmap will map files or devices into memory
    str r3, [sp, #0]                    // copy file handle to 1st level of stack for mmap
    ldr r3,.gpiobase                    // GPIO base address
    str r3, [sp, #4]                    // store GPIO base to 2nd level of stack        for mmap
    mov r0, #0                          // null address - let the kernel choose the address
    mov r1, #4096                       // page size
    mov r2, #3                          // desired memory protection type ???
    mov r3, #1                          // stdout
    bl mmap                             // call mmap; returns kernel mapped addr in r0

    pop {r1-r3, pc}


close_file:                             // params for file close
    push {r1-r3, lr}

    ldr r0, [sp, #0]                    // get file handle

    bl close
    pop {r1-r3, pc}
