.align 2

.equ UART_BASE, 0x10000000
.equ LINE_STATUS_REGISTER, 0x5
.equ LINE_CONTROL_REGISTER, 0x3
.equ FIFO_CONTROL_REGISTER, 0x2
.equ INTERRUPT_ENABLE_REGISTER, 0x1
.equ LINE_STATUS_DATA_READY, 0x1

.globl _start

_start:
    csrr t0, mhartid
    bnez t0, halt

    la sp, stack_top

    j inituart

halt: j halt

inituart: 
    # t0 = 0x10000000
    li t0, UART_BASE

    # set an 8 bit word length
    li t1, 0x3                          # put value of t1 into mem address of t0 added to immediate
    sb t1, LINE_CONTROL_REGISTER(t0)    # ie. 0x10000003 = 0x3
    
    # enable FIFO
    li t1, 0x1
    sb t1, FIFO_CONTROL_REGISTER(t0) 

    # enable interrupts
    sb t1, INTERRUPT_ENABLE_REGISTER(t0)

    # Divisor handling
    # unhandled.

main:
    li a0, 0x00000068 # h
    jal putchar
    li a0, 0x00000069 # i
    jal putchar

wait:   
    jal readchar
    beqz a0, wait # wait for any non-null character

    li t0, 0xD # Carriage Return
    beq a0, t0, newline

    li t0, 0x2B # +
    beq a0, t0, cool

    jal putchar # send the received character out to screen
    j wait

newline:
    li a0, 0xA # Line Feed
    ret

cool:
    jal newline # add a new line first
    jal putchar

loop:    
    li a0, 0x2B # +
    jal putchar # send it out
    li t1, 0x20 # in this case, 32
    addi t4, t4, 1 # increase counter
    blt t4, t1, loop # loop until t4 is more than 32
    mv t4, zero # reset counter
    jal newline # add a newline again
    jal putchar 
    j main      # return and start program again

readchar:
    li t0, UART_BASE
    # check that data is ready for reading
    lbu t1, LINE_STATUS_REGISTER(t0)
    andi t1, t1, LINE_STATUS_DATA_READY

    bnez t1, readuart

    mv a0, zero # return zero if there is no character to read
    j getend

readuart:
    lbu a0, (t0) # just load a byte from UART address
    j getend

getend: 
    ret

putchar: 
    li t0, UART_BASE

    sb a0, (t0) # just store a byte to UART address
    ret
    