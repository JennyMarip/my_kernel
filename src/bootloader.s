.section .text
.globl _start


_start:
    # bootloader(M mode)
    li t0, 1 << 8
    csrw medeleg, t0
    li t0, (1 << 1) | (1 << 5) | (1 << 9) 
    csrw mideleg, t0 # deleg trap(exception, interrupt) to S

    # set mtimecmp a1:a0
    li a1, 0x0
    li a0, 10000000 # 1 second = 10 ^ 7
    la t0, 0x2004000
    li t1, -1
    sw t1, 0(t0)
    sw a1, 4(t0)
    sw a0, 0(t0)

    # set M mode csr
    li   t0, (0b01 << 11) | (1 << 7) | (1 << 3) | (1 << 1)
    csrw mstatus, t0
    li t0, (1 << 5) |  (1 << 7)
    csrw mie, t0
    la t0, _Interrupt
    csrw mtvec, t0
    la t0, 0x80200000
    csrw mepc, t0 # kernel entry
    mret

# time interrupt vector
_Interrupt:
    csrr t3, mepc
    addi t3, t3, 4 # t3 hold the return address

    la t5, 0x80308000
    beqz t4, _1_to_2

    # app2 to app1
    sw t3, 16(t5)
    sw sp, 20(t5)
    sw a0, 24(t5)
    sw t0, 28(t5)
    j _set_timer
_1_to_2: # app1 to app2
    sw t3, 0(t5)
    sw sp, 4(t5)
    sw a0, 8(t5)
    sw t0, 12(t5)

_set_timer:
    # update mtimecmp a1:a0
    la t0, 0x2004000
    li a1, 0
    lw a0, 0(t0)
    li t2, 10000000
    add a0, a0, t2
    li t1, -1
    sw t1, 0(t0)
    sw a1, 4(t0)
    sw a0, 0(t0)

    la t0, M_mode
    li a0, 0x10000000
_loop:
    lb t1, 0(t0)
    beqz t1, _end
    sb t1, 0(a0)
    addi t0, t0, 1
    j _loop

_end:
    beqz t4, _1_to_2_
    lw t3, 0(t5)
    lw sp, 4(t5)
    lw a0, 8(t5)
    lw t0, 12(t5)
    li t4, 0
    j _ret
_1_to_2_:
    lw t3, 16(t5)
    lw sp, 20(t5)
    lw a0, 24(t5)
    lw t0, 28(t5)
    li t4, 1
_ret:
    csrw mepc, t3
    mret
    

.section .data
M_mode:
    .align 4
    .asciz "\nMachine mode\n"