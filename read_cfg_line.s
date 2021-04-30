/* read_cfg_line.s
This function reads one 32-bit value (8 hex characters) from file gpio_config.cfg.
Digits must be in hex. Value range: 00000000..FFFFFFFF.
It reads input and returns it.
Value is returned in r5 as 32-bit hex value.

Status is returned in r3.

Arto Rasimus 30.4.2021 */
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
    .asciz "read_cfg_file_row()\n"
    strlen_function_name = .-str_function_name

str_file_open_success:
    .asciz "cfg file opened\n"
    strlen_file_opened = .-str_file_open_success

str_file_closed:
    .asciz "cfg file closed\n"
    strlen_file_closed = .-str_file_closed

str_err_file_open_failed:
    .asciz "cfg file open failed\n"
    strlen_err_file_open_failed = .-str_err_file_open_failed

str_err_read_error:
    .asciz "\ncfg parameter out of limits error\n"
    strlen_err_read_error = .-str_err_read_error

str_buf:               // for debugging purposes
    .ascii "buf = "
    strlen_buf = .-str_buf

str_dummy:             // for debugging purposes
    .ascii "dummy = "
    strlen_dummy = .-str_dummy

str_rows_read:         // for debugging purposes
    .ascii "rows_read = "
    strlen_rows = .-str_rows_read

str_nl:                // for debugging purposes
    .asciz "\n"
    strlen_nl = .-str_nl

str_x:
    .ascii "x"
    strlen_x = .-str_x

cfg_file_name:       .asciz "gpio_config.cfg"

file_read_retval:         .word   0x12345678
.global file_read_retval
file_read_retval_addr:    .word   file_read_retval

file_rows_read:           .word   0
.global file_rows_read
file_rows_read_addr:      .word   file_rows_read


/* ---------------------------------------
        Block Starting Symbol Section
 ---------------------------------------
The portion of an object that contains statically-allocated variables
that are declared but have not been assigned a value yet */

// local common storage
.section .bss
    .lcomm hex_value,               4
    .lcomm file_descriptor,         4
    .lcomm file_read_buffer,        8
    .lcomm file_read_dummy_char,   34

/* ---------------------------------------
        Code Section
 --------------------------------------- */
.section .text
.align 2

.equ NIBBLE_LEN_C,    0x4
.equ STATUS_OK_C,    0x71 // Return value from check_hex_digit()
.equ STATUS_NOK_C,   0x82 // Return value from check_hex_digit()
.equ RET_SUCCESS_C,     0
.equ SIZEOF_VALUE_C,    8
.equ CR_C,           0x0A // carriage return

// File literals
.equ READ_C,          0x3
.equ WRITE_C,         0x4
.equ OPEN_C,          0x5
.equ CLOSE_C,         0x6
.equ CREATE_C,        0x8
.equ EXIT_C,          0x1

.equ O_RDONLY_C,      0x0
.equ O_WRONLY_C,      0x1
.equ O_RDWR_C,        0x2
.equ PERM_R_R_R_C,    444
.equ STDIN_C,         0x0
.equ STDOUT_C,        0x1
.equ SYNC_C,         0x76

// File errors
.equ EOPEN_FAILED_C,   -2
.equ EPERM_C,           1 // Operation not permitted
.equ ENOENT_C,          2 // No such file or directory
.equ EBADF_C,           9 // Bad file number
.equ EACCES_C,         13 // Permission denied

.global read_cfg_file_row
.type read_cfg_file_row, %function
read_cfg_file_row:
    push {lr}
    mov r0, STDOUT_C
    ldr r1, =str_function_name    // address of text string
    ldr r2, =strlen_function_name // number of bytes to write
    mov r7, WRITE_C
    svc $0

    ldr r0, =file_rows_read
    ldr r0, [r0]
    cmp r0, $0          // if nothing has been read yet, open the file for reading
    b open_file

    // Open the configuration text file, read-only
open_file:
    ldr r0, =cfg_file_name
    mov r1, O_RDONLY_C
    mov r2, $0         // mode TBD
    mov r7, OPEN_C
    svc $0             // open file for reading

    ldr r1, =file_descriptor
    str r0, [r1]       // save the descriptor to the variable

    // if fp == NULL: file open error
    ldr r2, =EOPEN_FAILED_C
    eor r0, r0, r2
    cmp r0, $0
    beq file_open_failed

    mov r0, STDOUT_C
    ldr r1, =str_file_open_success
    ldr r2, =strlen_file_opened
    mov r7, WRITE_C
    svc $0

read_next:
    ldr r0, =file_descriptor
    ldr r0, [r0]
    ldr r1, =file_read_buffer
    mov r2, SIZEOF_VALUE_C
    mov r7, READ_C
    svc $0

    mov r9, r1          // save the address of value for later use
/*
    mov r0, STDOUT_C
    ldr r1, =str_buf    // address of text string
    ldr r2, =strlen_buf // number of bytes to write
    mov r7, WRITE_C
    svc $0
bl debug_print
*/
    mov r0, STDOUT_C
    ldr r1, =file_read_buffer
    mov r2, SIZEOF_VALUE_C
    mov r7, WRITE_C
    svc $0

/*  using this overwrites r1 and r2
    mov r0, STDOUT_C
    ldr r1, =str_nl
    mov r2, $2
    mov r7, WRITE_C
    svc $0
*/
/*
    mov r0, STDOUT_C
    ldr r1, =str_dummy    // address of text string
    ldr r2, =strlen_dummy // number of bytes to write
    mov r7, WRITE_C
    svc $0
*/

    mov r9, r1
    mov r5, $0
    sub r2, $1           // r2: character amount (8) --> loop counter (7..0)
    mov r8, NIBBLE_LEN_C // Multiplier (4). Size of hex digit.

loop:
    // r6 = counter * 4 (bit shift index)
    // r2 = digit counter (of ASCII chars)
    mov r6, r2
    ldrb r10, [r9], $1

    // in: r10, out: r3 ASCII to hex
    bl check_hex_digit   // status: r10 0x71=ok, 0x82=nok
    cmp r10, STATUS_OK_C
    bne out_of_limits
    mul r6, r6, r8       // counter * 4 = left shift in bits

    lsl r4, r3, r6       // r3 is left shifted by ctr * 4 bits, to r4
    orr r5, r4           // bit pattern is placed into final result

    sub r2, $1           // decrement the char counter

    cmp r2, $0
    bge loop
    b dummy

dummy:
    ldr r0, =file_descriptor
    ldr r0, [r0]
    ldr r1, =file_read_dummy_char
    mov r2, $1
    mov r7, READ_C
    svc $0

    ldr r1, [r1]
    cmp r1, CR_C
    bne dummy       // characters are read from line until CR found

increment_rows_read_ctr:
    ldr r0, =file_rows_read // variable address
    ldr r1, [r0]            // read its value
    add r1, r1, $1          // increment the counter of the read rows
    str r1, [r0]            // Save value to the global variable

    mov r11, r1              // save the row counter value before NL print overwrites r1

    mov r0, STDOUT_C
    ldr r1, =str_nl
    mov r2, $2
    mov r7, WRITE_C
    svc $0

    mov r0, STDOUT_C
    ldr r1, =str_rows_read
    ldr r2, =strlen_rows
    mov r7, WRITE_C
    svc $0

    // print tens digit of row number
    bl number_units_by_10

    ldr r4, =value_10000s
    ldr r4, [r4]
    add r4, r4, $48          // for print

    mov r0, STDOUT_C
    ldr r1, =str_x
    str r4, [r1]
    mov r2, $1
    svc $0

    ldr r4, =value_1000s
    ldr r4, [r4]
    add r4, r4, $48          // for print

    mov r0, STDOUT_C
    ldr r1, =str_x
    str r4, [r1]
    mov r2, $1
    svc $0

    ldr r4, =value_100s
    ldr r4, [r4]
    add r4, r4, $48          // for print

    mov r0, STDOUT_C
    ldr r1, =str_x
    str r4, [r1]
    mov r2, $1
    svc $0

    ldr r4, =value_10s
    ldr r4, [r4]
    add r4, r4, $48          // for print

    mov r0, STDOUT_C
    ldr r1, =str_x
    str r4, [r1]
    mov r2, $1
    svc $0

    ldr r4, =value_1s
    ldr r4, [r4]
    add r4, r4, $48          // for print

    mov r0, STDOUT_C
    ldr r1, =str_x
    str r4, [r1]
    mov r2, $1
    svc $0

    mov r0, STDOUT_C
    ldr r1, =str_nl
    mov r2, $1
    mov r7, WRITE_C
    svc $0

    ldr r0, =file_rows_read // variable address
    ldr r6, [r0]            // read its value

    mov r1, r9

   // in:r5. func: r12, pin: r9, mode: r8
    bl gpio_mode_select

    // TBD: 0x99999999 as end mark does not work yet
    ldr r0, =0x00040000
    cmp r5, r0
    beq end
    b read_next

    mov r3, STATUS_OK_C
    b end

// parameter length <> 8 chars, TBD
wrong_parameter_length:
    mov r3, STATUS_NOK_C
    b end

// invalid character (not hex) in config file parameter
out_of_limits:
    mov r3, STATUS_NOK_C

    mov r0, STDOUT_C
    ldr r1, =str_err_read_error
    mov r2, strlen_err_read_error
    mov r7, WRITE_C
    svc $0
    b end

file_open_failed:
    mov r3, STATUS_NOK_C

    mov r0, STDOUT_C
    ldr r1, =str_err_file_open_failed
    mov r2, strlen_err_file_open_failed
    mov r7, WRITE_C
    svc $0
    b end

end:
    // Close the cfg file
    mov r7, CLOSE_C
    svc $0

    mov r0, STDOUT_C
    ldr r1, =str_file_closed
    ldr r2, =strlen_file_closed
    mov r7, WRITE_C
    svc $0

    pop {pc}
