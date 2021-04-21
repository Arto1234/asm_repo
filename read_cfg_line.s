/* read_cfg_line.s
This function reads one 32-bit value (8 hex characters) from file gpio_config.cfg.
Digits must be in hex. Value range: 00000000..FFFFFFFF.
It reads input and returns it.
Value is returned in r5 as 32-bit hex value.

Status is returned in r3.

Arto Rasimus 15.4.2021 */
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
    .asciz "cfg parameter out of limits error\n"
    strlen_err_read_error = .-str_err_read_error

str_buf:             // for debugging purposes
    .ascii "buf = "
    strlen_buf = .-str_buf

str_rows_read:             // for debugging purposes
    .ascii "rows_read = "
    strlen_rows = .-str_rows_read

str_nl:              // for debugging purposes
    .asciz "\n"
    strlen_nl = .-str_nl

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

    // Open the configuration text file, read-only
    ldr r0, =file_rows_read
    ldr r0, [r0]
    cmp r0, $0         // nothing read yet, so open the file for reading
    beq open_file
    b read_next

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
//b end

read_next:
    ldr r0, =file_descriptor
    ldr r0, [r0]
    ldr r1, =file_read_buffer
    mov r2, SIZEOF_VALUE_C
    mov r7, READ_C
    svc $0

/*
    mov r0, STDOUT_C
    ldr r1, =str_buf    // address of text string
    ldr r2, =strlen_buf // number of bytes to write
    mov r7, WRITE_C
    svc $0

    mov r0, STDOUT_C
    ldr r1, =file_read_buffer
    mov r2, SIZEOF_VALUE_C
    mov r7, WRITE_C
    svc $0

    mov r0, STDOUT_C
    ldr r1, =str_nl
    mov r2, $2
    mov r7, WRITE_C
    svc $0
*/

    mov r2, $8                // counter
    mov r5, $0                // status
    mov r9, r1                // r9 used as temporary storage
    sub r2, $1                // r2: character amount (8) --> loop counter (7..0)
    mov r8, NIBBLE_LEN_C      // Multiplier (4). Size of hex digit in bits.

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
    b value_ok
//   b line_loop


line_loop:
    ldr r0, =cfg_file_name
    ldr r1, =file_read_dummy_char
    mov r2, $1     // one character read until EOL
    mov r7, READ_C
    svc $0
/*
    mov r0, STDOUT_C
    mov r1, $65//file_read_dummy_char
    mov r2, $1     // one character read until EOL
    mov r7, WRITE_C
    svc $0

    // if not 0xA
    cmp r1, $65
*/
//    bne line_loop   // if CR was not read then read next character

    b increment_rows_read_ctr // rows += 1


increment_rows_read_ctr:
    ldr r0, =file_rows_read // variable addrss
    ldr r1, [r0]            // read its value
    add r1, r1, $1          // increment the counter of the read rows
//    ldr r2, =file_rows_read
    str r1, [r0]            // Save value to the global variable

//    b read_next

value_ok:
    mov r3, STATUS_OK_C
    b end

// parameter length <> 8 chars
wrong_parameter_length:
    mov r3, STATUS_NOK_C

// invalid character
out_of_limits:
    mov r0, STDOUT_C
    ldr r1, =str_err_read_error
    mov r2, strlen_err_read_error
    mov r7, WRITE_C
    svc $0

    mov r3, STATUS_NOK_C

file_open_failed:
    mov r3, STATUS_NOK_C

    mov r0, STDOUT_C
    ldr r1, =str_err_file_open_failed
    mov r2, strlen_err_file_open_failed
    mov r7, WRITE_C
    svc $0

end:
    // Close the cfg file
    mov r7, CLOSE_C
    svc $0

    mov r0, STDOUT_C
    ldr r1, =str_file_closed
    ldr r2, =strlen_file_closed
    mov r7, WRITE_C
    svc $0

    // debug print the row counter
    mov r0, STDOUT_C
    ldr r1, =str_rows_read
    ldr r2, =strlen_rows
    mov r7, WRITE_C
    svc $0

    // debug print the row counter
    mov r0, STDOUT_C
    ldr r1, =file_rows_read

/*
print_rows_read:
    str r2, [r1]
    mov r2, $2
    mov r7, WRITE_C
    svc $0

    mov r0, STDOUT_C
    ldr r1, =str_nl
    mov r2, $2
    mov r7, WRITE_C
    svc $0
*/

    /* This creates side effect with above loop:
       r8:  var addr
       r9:  out (to print_char)
       r11: aux addr for var addr */
    pop {pc}
