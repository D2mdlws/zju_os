    .extern trap_handler
    .section .text.entry
    .align 2
    .globl _traps 
_traps:

    # judge whether the trap is from user mode
    csrr t0, sscratch
    beq t0, x0, _no_change_stack

    # sscratch not zero, so it's from user mode
    mv t1, sp    
    csrw sscratch, t1
    mv sp, t0

    # save 32 registers and sepc and sstatus to stack
_no_change_stack:

    addi sp, sp, -34*8

    sd x0, 0*8(sp)
    sd x1, 1*8(sp)
    sd x2, 2*8(sp)
    sd x3, 3*8(sp)
    sd x4, 4*8(sp)
    sd x5, 5*8(sp)
    sd x6, 6*8(sp)
    sd x7, 7*8(sp)
    sd x8, 8*8(sp)
    sd x9, 9*8(sp)
    sd x10, 10*8(sp)
    sd x11, 11*8(sp)
    sd x12, 12*8(sp)
    sd x13, 13*8(sp)
    sd x14, 14*8(sp)
    sd x15, 15*8(sp)
    sd x16, 16*8(sp)
    sd x17, 17*8(sp)
    sd x18, 18*8(sp)
    sd x19, 19*8(sp)
    sd x20, 20*8(sp)
    sd x21, 21*8(sp)
    sd x22, 22*8(sp)
    sd x23, 23*8(sp)
    sd x24, 24*8(sp)
    sd x25, 25*8(sp)
    sd x26, 26*8(sp)
    sd x27, 27*8(sp)
    sd x28, 28*8(sp)
    sd x29, 29*8(sp)
    sd x30, 30*8(sp)
    sd x31, 31*8(sp)

    csrr t0, sepc
    sd t0, 32*8(sp)

    csrr t0, sstatus
    sd t0, 33*8(sp)

    # 2. call trap_handler

    csrr t1, scause
    mv a0, t1   # scause
    mv a1, t0   # sepc
    mv a2, sp   # pt_regs
    call trap_handler

    # 3. restore sepc and 32 registers (x2(sp) should be restore last) from stack

    ld x0, 0*8(sp)
    ld x1, 1*8(sp)
    ld x3, 3*8(sp)
    ld x4, 4*8(sp)
    ld x5, 5*8(sp)
    ld x6, 6*8(sp)
    ld x7, 7*8(sp)
    ld x8, 8*8(sp)
    ld x9, 9*8(sp)
    ld x10, 10*8(sp)
    ld x11, 11*8(sp)
    ld x12, 12*8(sp)
    ld x13, 13*8(sp)
    ld x14, 14*8(sp)
    ld x15, 15*8(sp)
    ld x16, 16*8(sp)
    ld x17, 17*8(sp)
    ld x18, 18*8(sp)
    ld x19, 19*8(sp)
    ld x20, 20*8(sp)
    ld x21, 21*8(sp)
    ld x22, 22*8(sp)
    ld x23, 23*8(sp)
    ld x24, 24*8(sp)    
    ld x25, 25*8(sp)
    ld x26, 26*8(sp)
    ld x27, 27*8(sp)
    ld x28, 28*8(sp)
    ld x29, 29*8(sp)
    ld x30, 30*8(sp)
    ld x31, 31*8(sp)
    ld t0, 32*8(sp)
    csrw sepc, t0
    ld t0, 33*8(sp)
    csrw sstatus, t0
    ld x2, 2*8(sp)

    addi sp, sp, 34*8

    csrr t0, sscratch
    beq t0, x0, _no_change_stack_end

    // if sscratch is not zero, it now saves the user stack pointer
    mv t1, sp   // current sp is kernel stack pointer, need to save it to sscratch
    mv sp, t0
    csrw sscratch, t1

    # 4. return from trap
_no_change_stack_end:
    sret


    .extern dummy
    .globl __dummy
__dummy:

    # change kernel stack to thread stack
    mv t0, sp
    csrr t1, sscratch
    mv sp, t1
    csrw sscratch, t0
    
    
    sret


    .globl __switch_to
    .set VM_START,  0xffffffe000000000
    .set PHY_START, 0x0000000080000000
    .equ PA2VA_OFFSET, VM_START - PHY_START
__switch_to:
    # save state to prev process
    # YOUR CODE HERE

    addi a0, a0, 4*8            # let a0 point to thread_struct

    sd ra, 0*8(a0)
    sd sp, 1*8(a0)
    sd s0, 2*8(a0)
    sd s1, 3*8(a0)
    sd s2, 4*8(a0)
    sd s3, 5*8(a0)
    sd s4, 6*8(a0)
    sd s5, 7*8(a0)
    sd s6, 8*8(a0)
    sd s7, 9*8(a0)
    sd s8, 10*8(a0)
    sd s9, 11*8(a0)
    sd s10, 12*8(a0)
    sd s11, 13*8(a0)

    # save sepc, sstatus, sscratch
    csrr t0, sepc
    csrr t1, sstatus
    csrr t2, sscratch
    sd t0, 14*8(a0)
    sd t1, 15*8(a0)
    sd t2, 16*8(a0)

    # save gpd
    csrr t0, satp
    slli t0, t0, 20             
    srli t0, t0, 20             # clear top 20 bits to get ppn
    slli t0, t0, 12             # pgd = ppn << 12
    li t1, PA2VA_OFFSET
    add t0, t0, t1   # get virtual addr of pgd
    sd t0, 17*8(a0)


    # restore state from next process
    # YOUR CODE HERE

    addi a1, a1, 4*8            # let a1 point to thread_struct

    ld ra, 0*8(a1)
    ld sp,  1*8(a1)

    addi a1, a1, 2*8            # let a1 point to thread_struct->s

    ld s0, 0*8(a1)
    ld s1, 1*8(a1)
    ld s2, 2*8(a1)
    ld s3, 3*8(a1)
    ld s4, 4*8(a1)
    ld s5, 5*8(a1)
    ld s6, 6*8(a1)
    ld s7, 7*8(a1)
    ld s8, 8*8(a1)
    ld s9, 9*8(a1)
    ld s10, 10*8(a1)
    ld s11, 11*8(a1)

    # restore sepc, sstatus, sscratch
    ld t0, 12*8(a1)
    ld t1, 13*8(a1)
    ld t2, 14*8(a1)
    csrw sepc, t0
    csrw sstatus, t1
    csrw sscratch, t2

    # restore gpd & flush TLB
    ld t0, 15*8(a1)
    li t1, PA2VA_OFFSET
    sub t0, t0, t1       # get physical addr of pgd
    srli t0, t0, 12       # pgd >> 12
    li t1, 0x8000000000000000
    or t0, t0, t1         # set satp mode to sv39
    csrw satp, t0         # set satp
    sfence.vma

    ret